		DB	'KERNALLL'		;Eight Bite OEM
BytePerSec	DW	0X0200			;扇区字节数(Bytes Per Sector)
SecPerClus	DB	0x01			;每簇扇区数（Sectors Per Cluster)
ReservedSec	DW	0x0001			;保留扇区数（Reserved Sector）
NumOfFAT	DB	0x02			;FAT数(Number of FAT)
RooEntries	DW	0x0070			;根目录项数(Root Entries)
SmallSector	DW	0x1680			;小扇区数(Small Sector)
MediaDescriptor	DB	0xF0			;媒体描述符( Media Descriptor)
SectorsPerFAT	DW	0x0017			;每FAT扇区数(Sectors Per FAT)
SectorsPerTrark	DW	0x0024			;每道扇区数(Sectors Per Trark)
NumberOfHead	DW	0x0002			;磁头数(Number of head)
HiddenSector	DD	0x00000000		;隐藏扇区数(Hidden Sector)
LargeSector	DD	0x00000000		;大扇区数(Large Sector)

;-----------------------------------------------------------------------------------------------
;拓展BPB
;-----------------------------------------------------------------------------------------------
PhyDrivNum	DB	0x00			;物理驱动器号( Physical Drive Number)
Reserved	DB	0x00			;保留(Reserved)
ExetBootSign	DB	0x29			;扩展引导标签(Extended Boot Signature)
VolSerNum	DD	0xABA13358		;卷序号(Volume Serial Number)
VoluLabel	DB	"           "		;卷标(Volume Label)
FileSysType	DB	"FAT16   "		;文件系统类型(File System Type)

