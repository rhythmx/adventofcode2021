require 'irb'
class BitReadBuf
    def initialize(str_or_bits, bitmode=false)
        if bitmode
            @bits = str_or_bits
            return
        end
        str = str_or_bits
        @bits = []
        str.each_char do |byte|
            nibble = nil
            nibble = byte.ord - '0'.ord if (byte >= '0' and byte <= '9') 
            nibble = byte.ord - 'A'.ord + 10 if (byte >= 'A' and byte <= 'F')
            if nibble
                nibble = ("%04b"%nibble).each_char.map{|c| c.to_i}.to_a # "0011" => [0,0,1,1]
                @bits += nibble
            end
        end
    end

    def read_bit()
        @bits.shift
    end

    def read_uint(nbits)
        num = 0
        nbits.times do
            num *= 2
            num += read_bit()
        end
        num
    end

    def read_bits(nbits)
        bits = []
        nbits.times do
            bits << read_bit()
        end
        bits
    end
end

class Packet
    attr_accessor :version
    attr_accessor :type
    attr_accessor :payload 
    attr_accessor :subpackets

    def initialize()
        @subpackets = []
    end
end


class PacketReader

    def initialize(buf)
        @buf = buf
        @packets = []
    end  

    def read_packet(packet)
        packet.version = @buf.read_uint(3)
        packet.type = @buf.read_uint(3)
        packet.payload = nil
        if packet.type == 4
            # Read literal packet
            payload = []
            while @buf.read_bit() == 1
                payload += @buf.read_bits(4)
            end
            payload += @buf.read_bits(4)
            packet.payload = Integer(payload.map{|i|i.to_s}.join(""),2)
        else 
            length_type_id = @buf.read_bit()
            puts "length type id is #{length_type_id}"
            if length_type_id == 0
                total_len = @buf.read_uint(15)
                puts "total_len #{total_len}"
                # binding.irb
                packetbits = @buf.read_bits(total_len)
                subbuf = BitReadBuf.new(packetbits, true)
                subreader = PacketReader.new(subbuf)
                packets = []
                running = true
                while running
                    begin
                        packet = Packet.new()
                        subreader.read_packet(packet)
                        packets << packet
                    rescue => ex
                        puts ex.inspect
                        running = false
                    end
                end
                packet.subpackets = packets
            else
                npackets = @buf.read_uint(11)
                subreader = PacketReader.new(@buf)
                packets = []
                npackets.times do
                    begin
                        packet = Packet.new
                        subreader.read_packet(packet)
                        packets << packet
                    rescue
                    end
                end
                packet.subpackets = packets
            end
        end
    end 
end

# buf = BitReadBuf.new("D2FE28")
buf = BitReadBuf.new("38006F45291200")
# buf = BitReadBuf.new("8A004A801A8002F478")
puts buf.inspect
reader = PacketReader.new(buf)
packet = Packet.new()
reader.read_packet(packet)
puts packet.inspect