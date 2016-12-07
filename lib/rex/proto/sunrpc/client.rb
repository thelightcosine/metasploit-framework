# frozen_string_literal: true
# -*- coding: binary -*-
require 'rex/socket'
require 'rex/encoder/xdr'

module Rex
  module Proto
    module SunRPC
      class RPCError < ::StandardError
        def initialize(msg = 'RPC operation failed')
          super
          @msg = msg
        end

        def to_s
          @msg
        end
      end

      class RPCTimeout < RuntimeError
        def initialize(msg = 'Operation timed out.')
          @msg = msg
        end

        def to_s
          @msg
        end
      end

      # XXX: CPORT!
      class Client
        AUTH_NULL = 0
        AUTH_UNIX = 1

        PMAP_PROG = 100000
        PMAP_VERS = 2
        PMAP_GETPORT = 3

        CALL = 0

        attr_accessor :rhost, :rport, :proto, :program, :version
        attr_accessor :pport, :call_sock, :timeout, :context

        attr_accessor :should_fragment

        def initialize(opts)
          self.rhost   = opts[:rhost]
          self.rport   = opts[:rport]
          self.program = opts[:program]
          self.version = opts[:version]
          self.timeout = opts[:timeout] || 20
          self.context = opts[:context] || {}
          self.proto   = opts[:proto]

          if proto.downcase !~ /^(tcp|udp)$/
            raise ::Rex::ArgumentError, 'Protocol is not "tcp" or "udp"'
          end

          @pport = nil

          @auth_type = AUTH_NULL
          @auth_data = ''

          @call_sock = nil
        end

        # XXX: Add optional parameter to have proto be something else
        def create
          proto_num = 0
          if @proto.eql?('tcp')
            proto_num = 6
          elsif @proto.eql?('udp')
            proto_num = 17
          end

          buf =
            Rex::Encoder::XDR.encode(CALL, 2, PMAP_PROG, PMAP_VERS, PMAP_GETPORT,
                                     @auth_type, [@auth_data, 400], AUTH_NULL, '',
                                     @program, @version, proto_num, 0)

          sock = make_rpc(@proto, @rhost, @rport)
          send_rpc(sock, buf)
          ret = recv_rpc(sock)
          close_rpc(sock)

          ret
        end

        def call(procedure, buffer, maxwait = timeout)
          buf =
            Rex::Encoder::XDR.encode(CALL, 2, @program, @version, procedure,
                                     @auth_type, [@auth_data, 400], AUTH_NULL, '') +
            buffer

          @call_sock = make_rpc(@proto, @rhost, @pport) unless @call_sock

          send_rpc(@call_sock, buf)
          recv_rpc(@call_sock, maxwait)
        end

        def destroy
          close_rpc(@call_sock) if @call_sock
          @call_sock = nil
        end

        def authnull_create
          @auth_type = AUTH_NULL
          @auth_data = ''
        end

        def authunix_create(host, uid, gid, groupz)
          raise ::Rex::ArgumentError, 'Hostname length is too long' if host.length > 255
          # 10?
          raise ::Rex::ArgumentError, 'Too many groups' if groupz.length > 10

          @auth_type = AUTH_UNIX
          @auth_data =
            Rex::Encoder::XDR.encode(0, host, uid, gid, groupz) # XXX: TIME! GROUPZ?!
        end

        # XXX: Dirty, integrate some sort of request system into create/call?
        def portmap_req(host, port, rpc_vers, procedure, buffer)
          buf = Rex::Encoder::XDR.encode(CALL, 2, PMAP_PROG, rpc_vers, procedure,
                                         AUTH_NULL, '', AUTH_NULL, '') + buffer

          sock = make_rpc('tcp', host, port)
          send_rpc(sock, buf)
          ret = recv_rpc(sock)
          close_rpc(sock)

          ret
        end

        private

        def make_rpc(proto, host, port)
          Rex::Socket.create(
            'PeerHost'	=> host,
            'PeerPort'	=> port,
            'Proto'		=> proto,
            'Timeout'   => timeout,
            'Context'   => context
          )
        end

        def build_tcp(buf)
          unless should_fragment
            return Rex::Encoder::XDR.encode(0x80000000 | buf.length) + buf
          end

          str = buf.dup

          fragmented = ''

          until str.empty?
            frag = str.slice!(0, rand(3) + 1)
            len = frag.size
            len |= 0x80000000 if str.empty?

            fragmented += Rex::Encoder::XDR.encode(len) + frag
          end

          fragmented
        end

        def send_rpc(sock, buf)
          buf = gen_xid + buf
          buf = build_tcp(buf) if sock.type?.eql?('tcp')
          sock.put(buf)
        end

        def recv_rpc(sock, maxwait = timeout)
          buf = nil
          begin
            Timeout.timeout(maxwait) { buf = sock.get }
          rescue ::Timeout
          end

          return nil unless buf

          buf.slice!(0..3)
          buf.slice!(0..3) if sock.type?.eql?('tcp')
          return buf if buf.length > 1
          nil
        end

        def close_rpc(sock)
          sock.close
        end

        def gen_xid
          Rex::Encoder::XDR.encode(rand(0xffffffff) + 1)
        end
      end
    end
  end
end
