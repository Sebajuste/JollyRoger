class_name NetStreamWriter
extends NetStream


var _bit_packer: NetBitPackerWriter


func _init(byte_buffer: NetByteBuffer):
	_bit_packer = NetBitPackerWriter.new(byte_buffer)


func is_writing() -> bool:
	return true


func is_reading() -> bool:
	return false


func serialize_bits(value: int, bits: int) -> int:
	var _r := _bit_packer.write(value, bits)
	return value


func flush():
	_bit_packer.flush()
