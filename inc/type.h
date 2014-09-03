//定义
typedef unsigned int	b32;
typedef	unsigned short	b16;
typedef char		b8;
typedef long long	b64;

//----------------------------------------------------------------------------
// 描述符类型值说明
// 其中:
//       DA_  : Descriptor Attribute
//       D    : 数据段
//       C    : 代码段
//       S    : 系统段
//       R    : 只读
//       RW   : 读写
//       A    : 已访问
//       其它 : 可按照字面意思理解
//----------------------------------------------------------------------------
#define    DA_32		0x4000 	// 32 位段
#define    DA_LIMIT_4K	0x8000 	// 段界限粒度为 4K 字节

#define    DA_DPL0		0x00 	// DPL = 0
#define    DA_DPL1		0x20 	// DPL = 1
#define    DA_DPL2		0x40 	// DPL = 2
#define    DA_DPL3		0x60 	// DPL = 3
//----------------------------------------------------------------------------
// 存储段描述符类型值说明			设置GDT时使用
//----------------------------------------------------------------------------
#define    DA_DR		0x90 	// 存在的只读数据段类型值
#define    DA_DRW		0x92 	// 存在的可读写数据段属性值
#define    DA_DRWA		0x93 	// 存在的已访问可读写数据段类型值
#define    DA_C			0x98 	// 存在的只执行代码段属性值
#define    DA_CR		0x9A 	// 存在的可执行可读代码段属性值
#define    DA_CCO		0x9C 	// 存在的只执行一致代码段属性值
#define    DA_CCOR		0x9A //E 	// 存在的可执行可读一致代码段属性值
//----------------------------------------------------------------------------
// 系统段描述符类型值说明			设置IDT时使用
//----------------------------------------------------------------------------
#define    DA_LDT	0x82 	// 局部描述符表段类型值
#define    DA_TaskGate	0x8500 	// 任务门类型值
#define    DA_386TSS	0x89 	// 可用 386 任务状态段类型值
#define    DA_386CGate	0x8C00 	// 386 调用门类型值
#define    DA_386IGate	0x8E00 	// 386 中断门类型值
#define    DA_386TGate	0x8F00 	// 386 陷阱门类型值

#define		IA_DPL0		0x0000
#define		IA_DPL1		0x2000
#define		IA_DPL2		0x4000
#define		IA_DPL3		0x6000
//----------------------------------------------------------------------------

#define		selector_code	0x18
#define		selector_data	0x08
#define		selector_stack	0x10
#define		selector_vedio	0x20	//fs

#pragma pack (1) 
