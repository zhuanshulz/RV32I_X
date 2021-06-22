import os
import binascii

if __name__ == '__main__':
    data = ''
    filepath = 'test'
    binfile = open(filepath,'rb')
    size = os.path.getsize(filepath)
    for i in range(int(size/4)):
        temp = str(binascii.b2a_hex(binfile.read(1)))
        temp = str(binascii.b2a_hex(binfile.read(1))) + temp
        temp = str(binascii.b2a_hex(binfile.read(1))) + temp
        temp = str(binascii.b2a_hex(binfile.read(1))) + temp
        data += temp+'\n'
    binfile.close()
    filepath = 'test.data'
    datafile = open(filepath, 'w')
    datafile.write(data)
    datafile.close()
