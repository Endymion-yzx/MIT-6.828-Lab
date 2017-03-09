
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b3 12 00 00       	call   8012e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 40 31 80 00       	push   $0x803140
  8000b7:	e8 61 13 00 00       	call   80141d <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 57 31 80 00       	push   $0x803157
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 67 31 80 00       	push   $0x803167
  8000e0:	e8 5f 12 00 00       	call   801344 <_panic>
	diskno = d;
  8000e5:	a3 00 40 80 00       	mov    %eax,0x804000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 70 31 80 00       	push   $0x803170
  80010b:	68 7d 31 80 00       	push   $0x80317d
  800110:	6a 44                	push   $0x44
  800112:	68 67 31 80 00       	push   $0x803167
  800117:	e8 28 12 00 00       	call   801344 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 70 31 80 00       	push   $0x803170
  8001cf:	68 7d 31 80 00       	push   $0x80317d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 67 31 80 00       	push   $0x803167
  8001db:	e8 64 11 00 00       	call   801344 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 40 80 00 	movzbl 0x804000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	53                   	push   %ebx
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  80027e:	8b 01                	mov    (%ecx),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800280:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  800286:	89 d3                	mov    %edx,%ebx
  800288:	c1 eb 0c             	shr    $0xc,%ebx
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028b:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800291:	76 1b                	jbe    8002ae <bc_pgfault+0x3a>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	ff 71 04             	pushl  0x4(%ecx)
  800299:	50                   	push   %eax
  80029a:	ff 71 28             	pushl  0x28(%ecx)
  80029d:	68 94 31 80 00       	push   $0x803194
  8002a2:	6a 27                	push   $0x27
  8002a4:	68 2a 32 80 00       	push   $0x80322a
  8002a9:	e8 96 10 00 00       	call   801344 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ae:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 17                	je     8002cf <bc_pgfault+0x5b>
  8002b8:	3b 5a 04             	cmp    0x4(%edx),%ebx
  8002bb:	72 12                	jb     8002cf <bc_pgfault+0x5b>
		panic("reading non-existent block %08x\n", blockno);
  8002bd:	53                   	push   %ebx
  8002be:	68 c4 31 80 00       	push   $0x8031c4
  8002c3:	6a 2b                	push   $0x2b
  8002c5:	68 2a 32 80 00       	push   $0x80322a
  8002ca:	e8 75 10 00 00       	call   801344 <_panic>
	//
	// LAB 5: you code here:

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002cf:	89 c2                	mov    %eax,%edx
  8002d1:	c1 ea 0c             	shr    $0xc,%edx
  8002d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8002e4:	52                   	push   %edx
  8002e5:	50                   	push   %eax
  8002e6:	6a 00                	push   $0x0
  8002e8:	50                   	push   %eax
  8002e9:	6a 00                	push   $0x0
  8002eb:	e8 9f 1b 00 00       	call   801e8f <sys_page_map>
  8002f0:	83 c4 20             	add    $0x20,%esp
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	79 12                	jns    800309 <bc_pgfault+0x95>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8002f7:	50                   	push   %eax
  8002f8:	68 e8 31 80 00       	push   $0x8031e8
  8002fd:	6a 37                	push   $0x37
  8002ff:	68 2a 32 80 00       	push   $0x80322a
  800304:	e8 3b 10 00 00       	call   801344 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800309:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  800310:	74 22                	je     800334 <bc_pgfault+0xc0>
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	53                   	push   %ebx
  800316:	e8 39 03 00 00       	call   800654 <block_is_free>
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	84 c0                	test   %al,%al
  800320:	74 12                	je     800334 <bc_pgfault+0xc0>
		panic("reading free block %08x\n", blockno);
  800322:	53                   	push   %ebx
  800323:	68 32 32 80 00       	push   $0x803232
  800328:	6a 3d                	push   $0x3d
  80032a:	68 2a 32 80 00       	push   $0x80322a
  80032f:	e8 10 10 00 00       	call   801344 <_panic>
}
  800334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800337:	c9                   	leave  
  800338:	c3                   	ret    

00800339 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800342:	85 c0                	test   %eax,%eax
  800344:	74 0f                	je     800355 <diskaddr+0x1c>
  800346:	8b 15 08 90 80 00    	mov    0x809008,%edx
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 17                	je     800367 <diskaddr+0x2e>
  800350:	3b 42 04             	cmp    0x4(%edx),%eax
  800353:	72 12                	jb     800367 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800355:	50                   	push   %eax
  800356:	68 08 32 80 00       	push   $0x803208
  80035b:	6a 09                	push   $0x9
  80035d:	68 2a 32 80 00       	push   $0x80322a
  800362:	e8 dd 0f 00 00       	call   801344 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  800367:	05 00 00 01 00       	add    $0x10000,%eax
  80036c:	c1 e0 0c             	shl    $0xc,%eax
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  800377:	89 d0                	mov    %edx,%eax
  800379:	c1 e8 16             	shr    $0x16,%eax
  80037c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	f6 c1 01             	test   $0x1,%cl
  80038b:	74 0d                	je     80039a <va_is_mapped+0x29>
  80038d:	c1 ea 0c             	shr    $0xc,%edx
  800390:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800397:	83 e0 01             	and    $0x1,%eax
  80039a:	83 e0 01             	and    $0x1,%eax
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	c1 e8 0c             	shr    $0xc,%eax
  8003a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003af:	c1 e8 06             	shr    $0x6,%eax
  8003b2:	83 e0 01             	and    $0x1,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003c0:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  8003c6:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  8003cc:	76 12                	jbe    8003e0 <flush_block+0x29>
		panic("flush_block of bad va %08x", addr);
  8003ce:	50                   	push   %eax
  8003cf:	68 4b 32 80 00       	push   $0x80324b
  8003d4:	6a 4d                	push   $0x4d
  8003d6:	68 2a 32 80 00       	push   $0x80322a
  8003db:	e8 64 0f 00 00       	call   801344 <_panic>

	// LAB 5: Your code here.
	panic("flush_block not implemented");
  8003e0:	83 ec 04             	sub    $0x4,%esp
  8003e3:	68 66 32 80 00       	push   $0x803266
  8003e8:	6a 50                	push   $0x50
  8003ea:	68 2a 32 80 00       	push   $0x80322a
  8003ef:	e8 50 0f 00 00       	call   801344 <_panic>

008003f4 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8003fd:	6a 01                	push   $0x1
  8003ff:	e8 35 ff ff ff       	call   800339 <diskaddr>
  800404:	83 c4 0c             	add    $0xc,%esp
  800407:	68 08 01 00 00       	push   $0x108
  80040c:	50                   	push   %eax
  80040d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800413:	50                   	push   %eax
  800414:	e8 c2 17 00 00       	call   801bdb <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800419:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800420:	e8 14 ff ff ff       	call   800339 <diskaddr>
  800425:	83 c4 08             	add    $0x8,%esp
  800428:	68 82 32 80 00       	push   $0x803282
  80042d:	50                   	push   %eax
  80042e:	e8 16 16 00 00       	call   801a49 <strcpy>
	flush_block(diskaddr(1));
  800433:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80043a:	e8 fa fe ff ff       	call   800339 <diskaddr>
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	e8 70 ff ff ff       	call   8003b7 <flush_block>

00800447 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	83 ec 14             	sub    $0x14,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  80044d:	68 74 02 80 00       	push   $0x800274
  800452:	e8 e6 1b 00 00       	call   80203d <set_pgfault_handler>
	check_bc();
  800457:	e8 98 ff ff ff       	call   8003f4 <check_bc>

0080045c <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	57                   	push   %edi
  800460:	56                   	push   %esi
  800461:	53                   	push   %ebx
  800462:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  800468:	89 95 64 ff ff ff    	mov    %edx,-0x9c(%ebp)
  80046e:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  800474:	eb 03                	jmp    800479 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800476:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800479:	80 38 2f             	cmpb   $0x2f,(%eax)
  80047c:	74 f8                	je     800476 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  80047e:	8b 3d 08 90 80 00    	mov    0x809008,%edi
  800484:	8d 4f 08             	lea    0x8(%edi),%ecx
  800487:	89 8d 5c ff ff ff    	mov    %ecx,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;
  80048d:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800494:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
  80049a:	85 c9                	test   %ecx,%ecx
  80049c:	0f 84 3d 01 00 00    	je     8005df <walk_path+0x183>
		*pdir = 0;
  8004a2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8004a8:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  8004ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  8004b4:	80 38 00             	cmpb   $0x0,(%eax)
  8004b7:	0f 84 f3 00 00 00    	je     8005b0 <walk_path+0x154>
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	eb 03                	jmp    8004c4 <walk_path+0x68>
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  8004c1:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8004c4:	0f b6 13             	movzbl (%ebx),%edx
  8004c7:	80 fa 2f             	cmp    $0x2f,%dl
  8004ca:	74 04                	je     8004d0 <walk_path+0x74>
  8004cc:	84 d2                	test   %dl,%dl
  8004ce:	75 f1                	jne    8004c1 <walk_path+0x65>
			path++;
		if (path - p >= MAXNAMELEN)
  8004d0:	89 de                	mov    %ebx,%esi
  8004d2:	29 c6                	sub    %eax,%esi
  8004d4:	83 fe 7f             	cmp    $0x7f,%esi
  8004d7:	0f 8f f4 00 00 00    	jg     8005d1 <walk_path+0x175>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8004dd:	83 ec 04             	sub    $0x4,%esp
  8004e0:	56                   	push   %esi
  8004e1:	50                   	push   %eax
  8004e2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8004e8:	50                   	push   %eax
  8004e9:	e8 ed 16 00 00       	call   801bdb <memmove>
		name[path - p] = '\0';
  8004ee:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  8004f5:	00 
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 03                	jmp    8004fe <walk_path+0xa2>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8004fb:	83 c3 01             	add    $0x1,%ebx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8004fe:	0f b6 13             	movzbl (%ebx),%edx
  800501:	80 fa 2f             	cmp    $0x2f,%dl
  800504:	74 f5                	je     8004fb <walk_path+0x9f>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800506:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  80050d:	0f 85 c5 00 00 00    	jne    8005d8 <walk_path+0x17c>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800513:	8b 8f 88 00 00 00    	mov    0x88(%edi),%ecx
  800519:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
  80051f:	74 19                	je     80053a <walk_path+0xde>
  800521:	68 89 32 80 00       	push   $0x803289
  800526:	68 7d 31 80 00       	push   $0x80317d
  80052b:	68 ab 00 00 00       	push   $0xab
  800530:	68 a6 32 80 00       	push   $0x8032a6
  800535:	e8 0a 0e 00 00       	call   801344 <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80053a:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
  800540:	85 c9                	test   %ecx,%ecx
  800542:	0f 49 c1             	cmovns %ecx,%eax
  800545:	c1 f8 0c             	sar    $0xc,%eax
  800548:	85 c0                	test   %eax,%eax
  80054a:	74 17                	je     800563 <walk_path+0x107>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80054c:	83 ec 04             	sub    $0x4,%esp
  80054f:	68 78 33 80 00       	push   $0x803378
  800554:	68 99 00 00 00       	push   $0x99
  800559:	68 a6 32 80 00       	push   $0x8032a6
  80055e:	e8 e1 0d 00 00       	call   801344 <_panic>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800563:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800568:	84 d2                	test   %dl,%dl
  80056a:	0f 85 86 00 00 00    	jne    8005f6 <walk_path+0x19a>
				if (pdir)
  800570:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800576:	85 c0                	test   %eax,%eax
  800578:	74 08                	je     800582 <walk_path+0x126>
					*pdir = dir;
  80057a:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  800580:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800582:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800586:	74 15                	je     80059d <walk_path+0x141>
					strcpy(lastelem, name);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800591:	50                   	push   %eax
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 af 14 00 00       	call   801a49 <strcpy>
  80059a:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  80059d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8005a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  8005a9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8005ae:	eb 46                	jmp    8005f6 <walk_path+0x19a>
		}
	}

	if (pdir)
		*pdir = dir;
  8005b0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8005b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = f;
  8005bc:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8005c2:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  8005c8:	89 08                	mov    %ecx,(%eax)
	return 0;
  8005ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cf:	eb 25                	jmp    8005f6 <walk_path+0x19a>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  8005d1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8005d6:	eb 1e                	jmp    8005f6 <walk_path+0x19a>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  8005d8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8005dd:	eb 17                	jmp    8005f6 <walk_path+0x19a>
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  8005df:	8b 8d 60 ff ff ff    	mov    -0xa0(%ebp),%ecx
  8005e5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	while (*path != '\0') {
  8005eb:	80 38 00             	cmpb   $0x0,(%eax)
  8005ee:	0f 85 c9 fe ff ff    	jne    8004bd <walk_path+0x61>
  8005f4:	eb c6                	jmp    8005bc <walk_path+0x160>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  8005f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f9:	5b                   	pop    %ebx
  8005fa:	5e                   	pop    %esi
  8005fb:	5f                   	pop    %edi
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800604:	a1 08 90 80 00       	mov    0x809008,%eax
  800609:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80060f:	74 14                	je     800625 <check_super+0x27>
		panic("bad file system magic number");
  800611:	83 ec 04             	sub    $0x4,%esp
  800614:	68 ae 32 80 00       	push   $0x8032ae
  800619:	6a 0f                	push   $0xf
  80061b:	68 a6 32 80 00       	push   $0x8032a6
  800620:	e8 1f 0d 00 00       	call   801344 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800625:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80062c:	76 14                	jbe    800642 <check_super+0x44>
		panic("file system is too large");
  80062e:	83 ec 04             	sub    $0x4,%esp
  800631:	68 cb 32 80 00       	push   $0x8032cb
  800636:	6a 12                	push   $0x12
  800638:	68 a6 32 80 00       	push   $0x8032a6
  80063d:	e8 02 0d 00 00       	call   801344 <_panic>

	cprintf("superblock is good\n");
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	68 e4 32 80 00       	push   $0x8032e4
  80064a:	e8 ce 0d 00 00       	call   80141d <cprintf>
}
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	c9                   	leave  
  800653:	c3                   	ret    

00800654 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	53                   	push   %ebx
  800658:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80065b:	8b 15 08 90 80 00    	mov    0x809008,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	74 24                	je     800689 <block_is_free+0x35>
		return 0;
  800665:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  80066a:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80066d:	76 1f                	jbe    80068e <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80066f:	89 cb                	mov    %ecx,%ebx
  800671:	c1 eb 05             	shr    $0x5,%ebx
  800674:	b8 01 00 00 00       	mov    $0x1,%eax
  800679:	d3 e0                	shl    %cl,%eax
  80067b:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800681:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800684:	0f 95 c0             	setne  %al
  800687:	eb 05                	jmp    80068e <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800689:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80068e:	5b                   	pop    %ebx
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	53                   	push   %ebx
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	75 14                	jne    8006b3 <free_block+0x22>
		panic("attempt to free zero block");
  80069f:	83 ec 04             	sub    $0x4,%esp
  8006a2:	68 f8 32 80 00       	push   $0x8032f8
  8006a7:	6a 2d                	push   $0x2d
  8006a9:	68 a6 32 80 00       	push   $0x8032a6
  8006ae:	e8 91 0c 00 00       	call   801344 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8006b3:	89 cb                	mov    %ecx,%ebx
  8006b5:	c1 eb 05             	shr    $0x5,%ebx
  8006b8:	8b 15 04 90 80 00    	mov    0x809004,%edx
  8006be:	b8 01 00 00 00       	mov    $0x1,%eax
  8006c3:	d3 e0                	shl    %cl,%eax
  8006c5:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  8006c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 0c             	sub    $0xc,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	panic("alloc_block not implemented");
  8006d3:	68 13 33 80 00       	push   $0x803313
  8006d8:	6a 41                	push   $0x41
  8006da:	68 a6 32 80 00       	push   $0x8032a6
  8006df:	e8 60 0c 00 00       	call   801344 <_panic>

008006e4 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8006e9:	a1 08 90 80 00       	mov    0x809008,%eax
  8006ee:	8b 70 04             	mov    0x4(%eax),%esi
  8006f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f6:	eb 29                	jmp    800721 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  8006f8:	8d 43 02             	lea    0x2(%ebx),%eax
  8006fb:	50                   	push   %eax
  8006fc:	e8 53 ff ff ff       	call   800654 <block_is_free>
  800701:	83 c4 04             	add    $0x4,%esp
  800704:	84 c0                	test   %al,%al
  800706:	74 16                	je     80071e <check_bitmap+0x3a>
  800708:	68 2f 33 80 00       	push   $0x80332f
  80070d:	68 7d 31 80 00       	push   $0x80317d
  800712:	6a 50                	push   $0x50
  800714:	68 a6 32 80 00       	push   $0x8032a6
  800719:	e8 26 0c 00 00       	call   801344 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80071e:	83 c3 01             	add    $0x1,%ebx
  800721:	89 d8                	mov    %ebx,%eax
  800723:	c1 e0 0f             	shl    $0xf,%eax
  800726:	39 f0                	cmp    %esi,%eax
  800728:	72 ce                	jb     8006f8 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80072a:	83 ec 0c             	sub    $0xc,%esp
  80072d:	6a 00                	push   $0x0
  80072f:	e8 20 ff ff ff       	call   800654 <block_is_free>
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	84 c0                	test   %al,%al
  800739:	74 16                	je     800751 <check_bitmap+0x6d>
  80073b:	68 43 33 80 00       	push   $0x803343
  800740:	68 7d 31 80 00       	push   $0x80317d
  800745:	6a 53                	push   $0x53
  800747:	68 a6 32 80 00       	push   $0x8032a6
  80074c:	e8 f3 0b 00 00       	call   801344 <_panic>
	assert(!block_is_free(1));
  800751:	83 ec 0c             	sub    $0xc,%esp
  800754:	6a 01                	push   $0x1
  800756:	e8 f9 fe ff ff       	call   800654 <block_is_free>
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	84 c0                	test   %al,%al
  800760:	74 16                	je     800778 <check_bitmap+0x94>
  800762:	68 55 33 80 00       	push   $0x803355
  800767:	68 7d 31 80 00       	push   $0x80317d
  80076c:	6a 54                	push   $0x54
  80076e:	68 a6 32 80 00       	push   $0x8032a6
  800773:	e8 cc 0b 00 00       	call   801344 <_panic>

	cprintf("bitmap is good\n");
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	68 67 33 80 00       	push   $0x803367
  800780:	e8 98 0c 00 00       	call   80141d <cprintf>
}
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800795:	e8 c5 f8 ff ff       	call   80005f <ide_probe_disk1>
  80079a:	84 c0                	test   %al,%al
  80079c:	74 0f                	je     8007ad <fs_init+0x1e>
		ide_set_disk(1);
  80079e:	83 ec 0c             	sub    $0xc,%esp
  8007a1:	6a 01                	push   $0x1
  8007a3:	e8 1b f9 ff ff       	call   8000c3 <ide_set_disk>
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 0d                	jmp    8007ba <fs_init+0x2b>
	else
		ide_set_disk(0);
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	6a 00                	push   $0x0
  8007b2:	e8 0c f9 ff ff       	call   8000c3 <ide_set_disk>
  8007b7:	83 c4 10             	add    $0x10,%esp
	bc_init();
  8007ba:	e8 88 fc ff ff       	call   800447 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	6a 01                	push   $0x1
  8007c4:	e8 70 fb ff ff       	call   800339 <diskaddr>
  8007c9:	a3 08 90 80 00       	mov    %eax,0x809008
	check_super();
  8007ce:	e8 2b fe ff ff       	call   8005fe <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8007d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8007da:	e8 5a fb ff ff       	call   800339 <diskaddr>
  8007df:	a3 04 90 80 00       	mov    %eax,0x809004
	check_bitmap();
  8007e4:	e8 fb fe ff ff       	call   8006e4 <check_bitmap>
	
}
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 0c             	sub    $0xc,%esp
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8007f4:	68 78 33 80 00       	push   $0x803378
  8007f9:	68 99 00 00 00       	push   $0x99
  8007fe:	68 a6 32 80 00       	push   $0x8032a6
  800803:	e8 3c 0b 00 00       	call   801344 <_panic>

00800808 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800813:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  800819:	50                   	push   %eax
  80081a:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  800820:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	e8 2e fc ff ff       	call   80045c <walk_path>
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	85 c0                	test   %eax,%eax
  800833:	0f 84 82 00 00 00    	je     8008bb <file_create+0xb3>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800839:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80083c:	0f 85 85 00 00 00    	jne    8008c7 <file_create+0xbf>
  800842:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 76                	je     8008c2 <file_create+0xba>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80084c:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  800852:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  800858:	74 19                	je     800873 <file_create+0x6b>
  80085a:	68 89 32 80 00       	push   $0x803289
  80085f:	68 7d 31 80 00       	push   $0x80317d
  800864:	68 c4 00 00 00       	push   $0xc4
  800869:	68 a6 32 80 00       	push   $0x8032a6
  80086e:	e8 d1 0a 00 00       	call   801344 <_panic>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800873:	be 00 10 00 00       	mov    $0x1000,%esi
  800878:	89 d8                	mov    %ebx,%eax
  80087a:	99                   	cltd   
  80087b:	f7 fe                	idiv   %esi
  80087d:	85 c0                	test   %eax,%eax
  80087f:	74 17                	je     800898 <file_create+0x90>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800881:	83 ec 04             	sub    $0x4,%esp
  800884:	68 78 33 80 00       	push   $0x803378
  800889:	68 99 00 00 00       	push   $0x99
  80088e:	68 a6 32 80 00       	push   $0x8032a6
  800893:	e8 ac 0a 00 00       	call   801344 <_panic>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800898:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80089e:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8008a4:	83 ec 04             	sub    $0x4,%esp
  8008a7:	68 78 33 80 00       	push   $0x803378
  8008ac:	68 99 00 00 00       	push   $0x99
  8008b1:	68 a6 32 80 00       	push   $0x8032a6
  8008b6:	e8 89 0a 00 00       	call   801344 <_panic>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8008bb:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8008c0:	eb 05                	jmp    8008c7 <file_create+0xbf>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  8008c2:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  8008c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  8008d4:	6a 00                	push   $0x0
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	e8 76 fb ff ff       	call   80045c <walk_path>
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8008fa:	39 d0                	cmp    %edx,%eax
  8008fc:	7e 27                	jle    800925 <file_read+0x3d>
		return 0;

	count = MIN(count, f->f_size - offset);
  8008fe:	29 d0                	sub    %edx,%eax
  800900:	3b 45 10             	cmp    0x10(%ebp),%eax
  800903:	0f 47 45 10          	cmova  0x10(%ebp),%eax

	for (pos = offset; pos < offset + count; ) {
  800907:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80090a:	39 ca                	cmp    %ecx,%edx
  80090c:	73 1c                	jae    80092a <file_read+0x42>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80090e:	83 ec 04             	sub    $0x4,%esp
  800911:	68 78 33 80 00       	push   $0x803378
  800916:	68 99 00 00 00       	push   $0x99
  80091b:	68 a6 32 80 00       	push   $0x8032a6
  800920:	e8 1f 0a 00 00       	call   801344 <_panic>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800934:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800937:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80093d:	39 f0                	cmp    %esi,%eax
  80093f:	7e 65                	jle    8009a6 <file_set_size+0x7a>
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800941:	8d 96 fe 1f 00 00    	lea    0x1ffe(%esi),%edx
  800947:	89 f1                	mov    %esi,%ecx
  800949:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
  80094f:	0f 49 d1             	cmovns %ecx,%edx
  800952:	c1 fa 0c             	sar    $0xc,%edx
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800955:	8d 88 fe 1f 00 00    	lea    0x1ffe(%eax),%ecx
  80095b:	05 ff 0f 00 00       	add    $0xfff,%eax
  800960:	0f 48 c1             	cmovs  %ecx,%eax
  800963:	c1 f8 0c             	sar    $0xc,%eax
  800966:	39 d0                	cmp    %edx,%eax
  800968:	76 17                	jbe    800981 <file_set_size+0x55>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  80096a:	83 ec 04             	sub    $0x4,%esp
  80096d:	68 98 33 80 00       	push   $0x803398
  800972:	68 8a 00 00 00       	push   $0x8a
  800977:	68 a6 32 80 00       	push   $0x8032a6
  80097c:	e8 c3 09 00 00       	call   801344 <_panic>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800981:	83 fa 0a             	cmp    $0xa,%edx
  800984:	77 20                	ja     8009a6 <file_set_size+0x7a>
  800986:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80098c:	85 c0                	test   %eax,%eax
  80098e:	74 16                	je     8009a6 <file_set_size+0x7a>
		free_block(f->f_indirect);
  800990:	83 ec 0c             	sub    $0xc,%esp
  800993:	50                   	push   %eax
  800994:	e8 f8 fc ff ff       	call   800691 <free_block>
		f->f_indirect = 0;
  800999:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  8009a0:	00 00 00 
  8009a3:	83 c4 10             	add    $0x10,%esp
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  8009a6:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  8009ac:	83 ec 0c             	sub    $0xc,%esp
  8009af:	53                   	push   %ebx
  8009b0:	e8 02 fa ff ff       	call   8003b7 <flush_block>
	return 0;
}
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	83 ec 0c             	sub    $0xc,%esp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009d0:	8b 7d 14             	mov    0x14(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  8009d3:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
  8009d6:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
  8009dc:	76 11                	jbe    8009ef <file_write+0x2e>
		if ((r = file_set_size(f, offset + count)) < 0)
  8009de:	83 ec 08             	sub    $0x8,%esp
  8009e1:	56                   	push   %esi
  8009e2:	50                   	push   %eax
  8009e3:	e8 44 ff ff ff       	call   80092c <file_set_size>
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	78 1d                	js     800a0c <file_write+0x4b>
			return r;

	for (pos = offset; pos < offset + count; ) {
  8009ef:	39 f7                	cmp    %esi,%edi
  8009f1:	73 17                	jae    800a0a <file_write+0x49>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8009f3:	83 ec 04             	sub    $0x4,%esp
  8009f6:	68 78 33 80 00       	push   $0x803378
  8009fb:	68 99 00 00 00       	push   $0x99
  800a00:	68 a6 32 80 00       	push   $0x8032a6
  800a05:	e8 3a 09 00 00       	call   801344 <_panic>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800a0a:	89 d8                	mov    %ebx,%eax
}
  800a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	83 ec 04             	sub    $0x4,%esp
  800a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800a1e:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800a24:	05 ff 0f 00 00       	add    $0xfff,%eax
  800a29:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800a2e:	7e 17                	jle    800a47 <file_flush+0x33>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800a30:	83 ec 04             	sub    $0x4,%esp
  800a33:	68 98 33 80 00       	push   $0x803398
  800a38:	68 8a 00 00 00       	push   $0x8a
  800a3d:	68 a6 32 80 00       	push   $0x8032a6
  800a42:	e8 fd 08 00 00       	call   801344 <_panic>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800a47:	83 ec 0c             	sub    $0xc,%esp
  800a4a:	53                   	push   %ebx
  800a4b:	e8 67 f9 ff ff       	call   8003b7 <flush_block>
	if (f->f_indirect)
  800a50:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800a56:	83 c4 10             	add    $0x10,%esp
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	74 14                	je     800a71 <file_flush+0x5d>
		flush_block(diskaddr(f->f_indirect));
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	50                   	push   %eax
  800a61:	e8 d3 f8 ff ff       	call   800339 <diskaddr>
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 49 f9 ff ff       	call   8003b7 <flush_block>
  800a6e:	83 c4 10             	add    $0x10,%esp
}
  800a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	53                   	push   %ebx
  800a7a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800a7d:	bb 01 00 00 00       	mov    $0x1,%ebx
  800a82:	eb 17                	jmp    800a9b <fs_sync+0x25>
		flush_block(diskaddr(i));
  800a84:	83 ec 0c             	sub    $0xc,%esp
  800a87:	53                   	push   %ebx
  800a88:	e8 ac f8 ff ff       	call   800339 <diskaddr>
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 22 f9 ff ff       	call   8003b7 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800a95:	83 c3 01             	add    $0x1,%ebx
  800a98:	83 c4 10             	add    $0x10,%esp
  800a9b:	a1 08 90 80 00       	mov    0x809008,%eax
  800aa0:	39 58 04             	cmp    %ebx,0x4(%eax)
  800aa3:	77 df                	ja     800a84 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  800aa5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800aba:	68 b8 33 80 00       	push   $0x8033b8
  800abf:	68 e8 00 00 00       	push   $0xe8
  800ac4:	68 d4 33 80 00       	push   $0x8033d4
  800ac9:	e8 76 08 00 00       	call   801344 <_panic>

00800ace <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800ad4:	e8 9d ff ff ff       	call   800a76 <fs_sync>
	return 0;
}
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	ba 60 40 80 00       	mov    $0x804060,%edx
	int i;
	uintptr_t va = FILEVA;
  800ae8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800af2:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800af4:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800af7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	83 c2 10             	add    $0x10,%edx
  800b03:	3d 00 04 00 00       	cmp    $0x400,%eax
  800b08:	75 e8                	jne    800af2 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800b14:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	89 d8                	mov    %ebx,%eax
  800b1e:	c1 e0 04             	shl    $0x4,%eax
  800b21:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800b27:	e8 62 1e 00 00       	call   80298e <pageref>
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	74 07                	je     800b3a <openfile_alloc+0x2e>
  800b33:	83 f8 01             	cmp    $0x1,%eax
  800b36:	74 20                	je     800b58 <openfile_alloc+0x4c>
  800b38:	eb 51                	jmp    800b8b <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800b3a:	83 ec 04             	sub    $0x4,%esp
  800b3d:	6a 07                	push   $0x7
  800b3f:	89 d8                	mov    %ebx,%eax
  800b41:	c1 e0 04             	shl    $0x4,%eax
  800b44:	ff b0 6c 40 80 00    	pushl  0x80406c(%eax)
  800b4a:	6a 00                	push   $0x0
  800b4c:	e8 fb 12 00 00       	call   801e4c <sys_page_alloc>
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	85 c0                	test   %eax,%eax
  800b56:	78 43                	js     800b9b <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800b58:	c1 e3 04             	shl    $0x4,%ebx
  800b5b:	8d 83 60 40 80 00    	lea    0x804060(%ebx),%eax
  800b61:	81 83 60 40 80 00 00 	addl   $0x400,0x804060(%ebx)
  800b68:	04 00 00 
			*o = &opentab[i];
  800b6b:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800b6d:	83 ec 04             	sub    $0x4,%esp
  800b70:	68 00 10 00 00       	push   $0x1000
  800b75:	6a 00                	push   $0x0
  800b77:	ff b3 6c 40 80 00    	pushl  0x80406c(%ebx)
  800b7d:	e8 0c 10 00 00       	call   801b8e <memset>
			return (*o)->o_fileid;
  800b82:	8b 06                	mov    (%esi),%eax
  800b84:	8b 00                	mov    (%eax),%eax
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb 10                	jmp    800b9b <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800b8b:	83 c3 01             	add    $0x1,%ebx
  800b8e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800b94:	75 83                	jne    800b19 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800b96:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 18             	sub    $0x18,%esp
  800bab:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800bae:	89 fb                	mov    %edi,%ebx
  800bb0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800bb6:	89 de                	mov    %ebx,%esi
  800bb8:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800bbb:	ff b6 6c 40 80 00    	pushl  0x80406c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800bc1:	81 c6 60 40 80 00    	add    $0x804060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800bc7:	e8 c2 1d 00 00       	call   80298e <pageref>
  800bcc:	83 c4 10             	add    $0x10,%esp
  800bcf:	83 f8 01             	cmp    $0x1,%eax
  800bd2:	7e 17                	jle    800beb <openfile_lookup+0x49>
  800bd4:	c1 e3 04             	shl    $0x4,%ebx
  800bd7:	3b bb 60 40 80 00    	cmp    0x804060(%ebx),%edi
  800bdd:	75 13                	jne    800bf2 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  800bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800be2:	89 30                	mov    %esi,(%eax)
	return 0;
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	eb 0c                	jmp    800bf7 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800beb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf0:	eb 05                	jmp    800bf7 <openfile_lookup+0x55>
  800bf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	53                   	push   %ebx
  800c03:	83 ec 18             	sub    $0x18,%esp
  800c06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800c09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0c:	50                   	push   %eax
  800c0d:	ff 33                	pushl  (%ebx)
  800c0f:	ff 75 08             	pushl  0x8(%ebp)
  800c12:	e8 8b ff ff ff       	call   800ba2 <openfile_lookup>
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	78 14                	js     800c32 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800c1e:	83 ec 08             	sub    $0x8,%esp
  800c21:	ff 73 04             	pushl  0x4(%ebx)
  800c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c27:	ff 70 04             	pushl  0x4(%eax)
  800c2a:	e8 fd fc ff ff       	call   80092c <file_set_size>
  800c2f:	83 c4 10             	add    $0x10,%esp
}
  800c32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 18             	sub    $0x18,%esp
  800c3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800c41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c44:	50                   	push   %eax
  800c45:	ff 33                	pushl  (%ebx)
  800c47:	ff 75 08             	pushl  0x8(%ebp)
  800c4a:	e8 53 ff ff ff       	call   800ba2 <openfile_lookup>
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	85 c0                	test   %eax,%eax
  800c54:	78 3f                	js     800c95 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5c:	ff 70 04             	pushl  0x4(%eax)
  800c5f:	53                   	push   %ebx
  800c60:	e8 e4 0d 00 00       	call   801a49 <strcpy>
	ret->ret_size = o->o_file->f_size;
  800c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c68:	8b 50 04             	mov    0x4(%eax),%edx
  800c6b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800c71:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  800c77:	8b 40 04             	mov    0x4(%eax),%eax
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c84:	0f 94 c0             	sete   %al
  800c87:	0f b6 c0             	movzbl %al,%eax
  800c8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800ca0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca3:	50                   	push   %eax
  800ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca7:	ff 30                	pushl  (%eax)
  800ca9:	ff 75 08             	pushl  0x8(%ebp)
  800cac:	e8 f1 fe ff ff       	call   800ba2 <openfile_lookup>
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	78 16                	js     800cce <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbe:	ff 70 04             	pushl  0x4(%eax)
  800cc1:	e8 4e fd ff ff       	call   800a14 <file_flush>
	return 0;
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cce:	c9                   	leave  
  800ccf:	c3                   	ret    

00800cd0 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	53                   	push   %ebx
  800cd4:	81 ec 18 04 00 00    	sub    $0x418,%esp
  800cda:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800cdd:	68 00 04 00 00       	push   $0x400
  800ce2:	53                   	push   %ebx
  800ce3:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800ce9:	50                   	push   %eax
  800cea:	e8 ec 0e 00 00       	call   801bdb <memmove>
	path[MAXPATHLEN-1] = 0;
  800cef:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  800cf3:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800cf9:	89 04 24             	mov    %eax,(%esp)
  800cfc:	e8 0b fe ff ff       	call   800b0c <openfile_alloc>
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	85 c0                	test   %eax,%eax
  800d06:	0f 88 f0 00 00 00    	js     800dfc <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  800d0c:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  800d13:	74 33                	je     800d48 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  800d15:	83 ec 08             	sub    $0x8,%esp
  800d18:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d1e:	50                   	push   %eax
  800d1f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	e8 dd fa ff ff       	call   800808 <file_create>
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	79 37                	jns    800d69 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  800d32:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  800d39:	0f 85 bd 00 00 00    	jne    800dfc <serve_open+0x12c>
  800d3f:	83 f8 f3             	cmp    $0xfffffff3,%eax
  800d42:	0f 85 b4 00 00 00    	jne    800dfc <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  800d48:	83 ec 08             	sub    $0x8,%esp
  800d4b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d51:	50                   	push   %eax
  800d52:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d58:	50                   	push   %eax
  800d59:	e8 70 fb ff ff       	call   8008ce <file_open>
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	0f 88 93 00 00 00    	js     800dfc <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  800d69:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  800d70:	74 17                	je     800d89 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  800d72:	83 ec 08             	sub    $0x8,%esp
  800d75:	6a 00                	push   $0x0
  800d77:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  800d7d:	e8 aa fb ff ff       	call   80092c <file_set_size>
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	85 c0                	test   %eax,%eax
  800d87:	78 73                	js     800dfc <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800d92:	50                   	push   %eax
  800d93:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800d99:	50                   	push   %eax
  800d9a:	e8 2f fb ff ff       	call   8008ce <file_open>
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 56                	js     800dfc <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  800da6:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800dac:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800db2:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800db5:	8b 50 0c             	mov    0xc(%eax),%edx
  800db8:	8b 08                	mov    (%eax),%ecx
  800dba:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800dbd:	8b 48 0c             	mov    0xc(%eax),%ecx
  800dc0:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800dc6:	83 e2 03             	and    $0x3,%edx
  800dc9:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  800dcc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dcf:	8b 15 64 80 80 00    	mov    0x808064,%edx
  800dd5:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  800dd7:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800ddd:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800de3:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  800de6:	8b 50 0c             	mov    0xc(%eax),%edx
  800de9:	8b 45 10             	mov    0x10(%ebp),%eax
  800dec:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  800dee:	8b 45 14             	mov    0x14(%ebp),%eax
  800df1:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  800df7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800e09:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800e0c:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  800e0f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	53                   	push   %ebx
  800e1a:	ff 35 44 40 80 00    	pushl  0x804044
  800e20:	56                   	push   %esi
  800e21:	e8 87 12 00 00       	call   8020ad <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  800e2d:	75 15                	jne    800e44 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	ff 75 f4             	pushl  -0xc(%ebp)
  800e35:	68 00 34 80 00       	push   $0x803400
  800e3a:	e8 de 05 00 00       	call   80141d <cprintf>
				whom);
			continue; // just leave it hanging...
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	eb cb                	jmp    800e0f <serve+0xe>
		}

		pg = NULL;
  800e44:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  800e4b:	83 f8 01             	cmp    $0x1,%eax
  800e4e:	75 18                	jne    800e68 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800e50:	53                   	push   %ebx
  800e51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e54:	50                   	push   %eax
  800e55:	ff 35 44 40 80 00    	pushl  0x804044
  800e5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5e:	e8 6d fe ff ff       	call   800cd0 <serve_open>
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	eb 3c                	jmp    800ea4 <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  800e68:	83 f8 08             	cmp    $0x8,%eax
  800e6b:	77 1e                	ja     800e8b <serve+0x8a>
  800e6d:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  800e74:	85 d2                	test   %edx,%edx
  800e76:	74 13                	je     800e8b <serve+0x8a>
			r = handlers[req](whom, fsreq);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	ff 35 44 40 80 00    	pushl  0x804044
  800e81:	ff 75 f4             	pushl  -0xc(%ebp)
  800e84:	ff d2                	call   *%edx
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	eb 19                	jmp    800ea4 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	50                   	push   %eax
  800e92:	68 30 34 80 00       	push   $0x803430
  800e97:	e8 81 05 00 00       	call   80141d <cprintf>
  800e9c:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  800e9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800ea4:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea7:	ff 75 ec             	pushl  -0x14(%ebp)
  800eaa:	50                   	push   %eax
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	e8 6f 12 00 00       	call   802122 <ipc_send>
		sys_page_unmap(0, fsreq);
  800eb3:	83 c4 08             	add    $0x8,%esp
  800eb6:	ff 35 44 40 80 00    	pushl  0x804044
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 0e 10 00 00       	call   801ed1 <sys_page_unmap>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	e9 44 ff ff ff       	jmp    800e0f <serve+0xe>

00800ecb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  800ed1:	c7 05 60 80 80 00 de 	movl   $0x8033de,0x808060
  800ed8:	33 80 00 
	cprintf("FS is running\n");
  800edb:	68 e1 33 80 00       	push   $0x8033e1
  800ee0:	e8 38 05 00 00       	call   80141d <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  800ee5:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  800eea:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  800eef:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  800ef1:	c7 04 24 f0 33 80 00 	movl   $0x8033f0,(%esp)
  800ef8:	e8 20 05 00 00       	call   80141d <cprintf>

	serve_init();
  800efd:	e8 de fb ff ff       	call   800ae0 <serve_init>
	fs_init();
  800f02:	e8 88 f8 ff ff       	call   80078f <fs_init>
        fs_test();
  800f07:	e8 05 00 00 00       	call   800f11 <fs_test>
	serve();
  800f0c:	e8 f0 fe ff ff       	call   800e01 <serve>

00800f11 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	53                   	push   %ebx
  800f15:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  800f18:	6a 07                	push   $0x7
  800f1a:	68 00 10 00 00       	push   $0x1000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 26 0f 00 00       	call   801e4c <sys_page_alloc>
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 12                	jns    800f3f <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 53 34 80 00       	push   $0x803453
  800f33:	6a 12                	push   $0x12
  800f35:	68 66 34 80 00       	push   $0x803466
  800f3a:	e8 05 04 00 00       	call   801344 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	68 00 10 00 00       	push   $0x1000
  800f47:	ff 35 04 90 80 00    	pushl  0x809004
  800f4d:	68 00 10 00 00       	push   $0x1000
  800f52:	e8 84 0c 00 00       	call   801bdb <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  800f57:	e8 71 f7 ff ff       	call   8006cd <alloc_block>
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <fs_test+0x64>
		panic("alloc_block: %e", r);
  800f63:	50                   	push   %eax
  800f64:	68 70 34 80 00       	push   $0x803470
  800f69:	6a 17                	push   $0x17
  800f6b:	68 66 34 80 00       	push   $0x803466
  800f70:	e8 cf 03 00 00       	call   801344 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  800f75:	8d 50 1f             	lea    0x1f(%eax),%edx
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	0f 49 d0             	cmovns %eax,%edx
  800f7d:	c1 fa 05             	sar    $0x5,%edx
  800f80:	89 c3                	mov    %eax,%ebx
  800f82:	c1 fb 1f             	sar    $0x1f,%ebx
  800f85:	c1 eb 1b             	shr    $0x1b,%ebx
  800f88:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  800f8b:	83 e1 1f             	and    $0x1f,%ecx
  800f8e:	29 d9                	sub    %ebx,%ecx
  800f90:	b8 01 00 00 00       	mov    $0x1,%eax
  800f95:	d3 e0                	shl    %cl,%eax
  800f97:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  800f9e:	75 16                	jne    800fb6 <fs_test+0xa5>
  800fa0:	68 80 34 80 00       	push   $0x803480
  800fa5:	68 7d 31 80 00       	push   $0x80317d
  800faa:	6a 19                	push   $0x19
  800fac:	68 66 34 80 00       	push   $0x803466
  800fb1:	e8 8e 03 00 00       	call   801344 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  800fb6:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
  800fbc:	85 04 91             	test   %eax,(%ecx,%edx,4)
  800fbf:	74 16                	je     800fd7 <fs_test+0xc6>
  800fc1:	68 f8 35 80 00       	push   $0x8035f8
  800fc6:	68 7d 31 80 00       	push   $0x80317d
  800fcb:	6a 1b                	push   $0x1b
  800fcd:	68 66 34 80 00       	push   $0x803466
  800fd2:	e8 6d 03 00 00       	call   801344 <_panic>
	cprintf("alloc_block is good\n");
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	68 9b 34 80 00       	push   $0x80349b
  800fdf:	e8 39 04 00 00       	call   80141d <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	68 b0 34 80 00       	push   $0x8034b0
  800ff0:	e8 d9 f8 ff ff       	call   8008ce <file_open>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ffb:	74 1b                	je     801018 <fs_test+0x107>
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	c1 ea 1f             	shr    $0x1f,%edx
  801002:	84 d2                	test   %dl,%dl
  801004:	74 12                	je     801018 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801006:	50                   	push   %eax
  801007:	68 bb 34 80 00       	push   $0x8034bb
  80100c:	6a 1f                	push   $0x1f
  80100e:	68 66 34 80 00       	push   $0x803466
  801013:	e8 2c 03 00 00       	call   801344 <_panic>
	else if (r == 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	75 14                	jne    801030 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 18 36 80 00       	push   $0x803618
  801024:	6a 21                	push   $0x21
  801026:	68 66 34 80 00       	push   $0x803466
  80102b:	e8 14 03 00 00       	call   801344 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801030:	83 ec 08             	sub    $0x8,%esp
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	68 d4 34 80 00       	push   $0x8034d4
  80103c:	e8 8d f8 ff ff       	call   8008ce <file_open>
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 12                	jns    80105a <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801048:	50                   	push   %eax
  801049:	68 dd 34 80 00       	push   $0x8034dd
  80104e:	6a 23                	push   $0x23
  801050:	68 66 34 80 00       	push   $0x803466
  801055:	e8 ea 02 00 00       	call   801344 <_panic>
	cprintf("file_open is good\n");
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	68 f4 34 80 00       	push   $0x8034f4
  801062:	e8 b6 03 00 00       	call   80141d <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801067:	83 c4 0c             	add    $0xc,%esp
  80106a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106d:	50                   	push   %eax
  80106e:	6a 00                	push   $0x0
  801070:	ff 75 f4             	pushl  -0xc(%ebp)
  801073:	e8 76 f7 ff ff       	call   8007ee <file_get_block>
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	79 12                	jns    801091 <fs_test+0x180>
		panic("file_get_block: %e", r);
  80107f:	50                   	push   %eax
  801080:	68 07 35 80 00       	push   $0x803507
  801085:	6a 27                	push   $0x27
  801087:	68 66 34 80 00       	push   $0x803466
  80108c:	e8 b3 02 00 00       	call   801344 <_panic>
	if (strcmp(blk, msg) != 0)
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	68 38 36 80 00       	push   $0x803638
  801099:	ff 75 f0             	pushl  -0x10(%ebp)
  80109c:	e8 52 0a 00 00       	call   801af3 <strcmp>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	74 14                	je     8010bc <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	68 60 36 80 00       	push   $0x803660
  8010b0:	6a 29                	push   $0x29
  8010b2:	68 66 34 80 00       	push   $0x803466
  8010b7:	e8 88 02 00 00       	call   801344 <_panic>
	cprintf("file_get_block is good\n");
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	68 1a 35 80 00       	push   $0x80351a
  8010c4:	e8 54 03 00 00       	call   80141d <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8010c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cc:	0f b6 10             	movzbl (%eax),%edx
  8010cf:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8010d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d4:	c1 e8 0c             	shr    $0xc,%eax
  8010d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	a8 40                	test   $0x40,%al
  8010e3:	75 16                	jne    8010fb <fs_test+0x1ea>
  8010e5:	68 33 35 80 00       	push   $0x803533
  8010ea:	68 7d 31 80 00       	push   $0x80317d
  8010ef:	6a 2d                	push   $0x2d
  8010f1:	68 66 34 80 00       	push   $0x803466
  8010f6:	e8 49 02 00 00       	call   801344 <_panic>
	file_flush(f);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801101:	e8 0e f9 ff ff       	call   800a14 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801106:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801109:	c1 e8 0c             	shr    $0xc,%eax
  80110c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	a8 40                	test   $0x40,%al
  801118:	74 16                	je     801130 <fs_test+0x21f>
  80111a:	68 32 35 80 00       	push   $0x803532
  80111f:	68 7d 31 80 00       	push   $0x80317d
  801124:	6a 2f                	push   $0x2f
  801126:	68 66 34 80 00       	push   $0x803466
  80112b:	e8 14 02 00 00       	call   801344 <_panic>
	cprintf("file_flush is good\n");
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	68 4e 35 80 00       	push   $0x80354e
  801138:	e8 e0 02 00 00       	call   80141d <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	6a 00                	push   $0x0
  801142:	ff 75 f4             	pushl  -0xc(%ebp)
  801145:	e8 e2 f7 ff ff       	call   80092c <file_set_size>
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 12                	jns    801163 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801151:	50                   	push   %eax
  801152:	68 62 35 80 00       	push   $0x803562
  801157:	6a 33                	push   $0x33
  801159:	68 66 34 80 00       	push   $0x803466
  80115e:	e8 e1 01 00 00       	call   801344 <_panic>
	assert(f->f_direct[0] == 0);
  801163:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801166:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80116d:	74 16                	je     801185 <fs_test+0x274>
  80116f:	68 74 35 80 00       	push   $0x803574
  801174:	68 7d 31 80 00       	push   $0x80317d
  801179:	6a 34                	push   $0x34
  80117b:	68 66 34 80 00       	push   $0x803466
  801180:	e8 bf 01 00 00       	call   801344 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801185:	c1 e8 0c             	shr    $0xc,%eax
  801188:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118f:	a8 40                	test   $0x40,%al
  801191:	74 16                	je     8011a9 <fs_test+0x298>
  801193:	68 88 35 80 00       	push   $0x803588
  801198:	68 7d 31 80 00       	push   $0x80317d
  80119d:	6a 35                	push   $0x35
  80119f:	68 66 34 80 00       	push   $0x803466
  8011a4:	e8 9b 01 00 00       	call   801344 <_panic>
	cprintf("file_truncate is good\n");
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	68 a2 35 80 00       	push   $0x8035a2
  8011b1:	e8 67 02 00 00       	call   80141d <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8011b6:	c7 04 24 38 36 80 00 	movl   $0x803638,(%esp)
  8011bd:	e8 4e 08 00 00       	call   801a10 <strlen>
  8011c2:	83 c4 08             	add    $0x8,%esp
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c9:	e8 5e f7 ff ff       	call   80092c <file_set_size>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	79 12                	jns    8011e7 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  8011d5:	50                   	push   %eax
  8011d6:	68 b9 35 80 00       	push   $0x8035b9
  8011db:	6a 39                	push   $0x39
  8011dd:	68 66 34 80 00       	push   $0x803466
  8011e2:	e8 5d 01 00 00       	call   801344 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 0c             	shr    $0xc,%edx
  8011ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f6:	f6 c2 40             	test   $0x40,%dl
  8011f9:	74 16                	je     801211 <fs_test+0x300>
  8011fb:	68 88 35 80 00       	push   $0x803588
  801200:	68 7d 31 80 00       	push   $0x80317d
  801205:	6a 3a                	push   $0x3a
  801207:	68 66 34 80 00       	push   $0x803466
  80120c:	e8 33 01 00 00       	call   801344 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801217:	52                   	push   %edx
  801218:	6a 00                	push   $0x0
  80121a:	50                   	push   %eax
  80121b:	e8 ce f5 ff ff       	call   8007ee <file_get_block>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	79 12                	jns    801239 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801227:	50                   	push   %eax
  801228:	68 cd 35 80 00       	push   $0x8035cd
  80122d:	6a 3c                	push   $0x3c
  80122f:	68 66 34 80 00       	push   $0x803466
  801234:	e8 0b 01 00 00       	call   801344 <_panic>
	strcpy(blk, msg);
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	68 38 36 80 00       	push   $0x803638
  801241:	ff 75 f0             	pushl  -0x10(%ebp)
  801244:	e8 00 08 00 00       	call   801a49 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124c:	c1 e8 0c             	shr    $0xc,%eax
  80124f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	a8 40                	test   $0x40,%al
  80125b:	75 16                	jne    801273 <fs_test+0x362>
  80125d:	68 33 35 80 00       	push   $0x803533
  801262:	68 7d 31 80 00       	push   $0x80317d
  801267:	6a 3e                	push   $0x3e
  801269:	68 66 34 80 00       	push   $0x803466
  80126e:	e8 d1 00 00 00       	call   801344 <_panic>
	file_flush(f);
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	ff 75 f4             	pushl  -0xc(%ebp)
  801279:	e8 96 f7 ff ff       	call   800a14 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	c1 e8 0c             	shr    $0xc,%eax
  801284:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	a8 40                	test   $0x40,%al
  801290:	74 16                	je     8012a8 <fs_test+0x397>
  801292:	68 32 35 80 00       	push   $0x803532
  801297:	68 7d 31 80 00       	push   $0x80317d
  80129c:	6a 40                	push   $0x40
  80129e:	68 66 34 80 00       	push   $0x803466
  8012a3:	e8 9c 00 00 00       	call   801344 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8012a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
  8012ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b5:	a8 40                	test   $0x40,%al
  8012b7:	74 16                	je     8012cf <fs_test+0x3be>
  8012b9:	68 88 35 80 00       	push   $0x803588
  8012be:	68 7d 31 80 00       	push   $0x80317d
  8012c3:	6a 41                	push   $0x41
  8012c5:	68 66 34 80 00       	push   $0x803466
  8012ca:	e8 75 00 00 00       	call   801344 <_panic>
	cprintf("file rewrite is good\n");
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	68 e2 35 80 00       	push   $0x8035e2
  8012d7:	e8 41 01 00 00       	call   80141d <cprintf>
}
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8012ef:	e8 1a 0b 00 00       	call   801e0e <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8012f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801301:	a3 0c 90 80 00       	mov    %eax,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801306:	85 db                	test   %ebx,%ebx
  801308:	7e 07                	jle    801311 <libmain+0x2d>
		binaryname = argv[0];
  80130a:	8b 06                	mov    (%esi),%eax
  80130c:	a3 60 80 80 00       	mov    %eax,0x808060

	// call user main routine
	umain(argc, argv);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	e8 b0 fb ff ff       	call   800ecb <umain>

	// exit gracefully
	exit();
  80131b:	e8 0a 00 00 00       	call   80132a <exit>
}
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801330:	e8 45 10 00 00       	call   80237a <close_all>
	sys_env_destroy(0);
  801335:	83 ec 0c             	sub    $0xc,%esp
  801338:	6a 00                	push   $0x0
  80133a:	e8 8e 0a 00 00       	call   801dcd <sys_env_destroy>
}
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801349:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80134c:	8b 35 60 80 80 00    	mov    0x808060,%esi
  801352:	e8 b7 0a 00 00       	call   801e0e <sys_getenvid>
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	ff 75 0c             	pushl  0xc(%ebp)
  80135d:	ff 75 08             	pushl  0x8(%ebp)
  801360:	56                   	push   %esi
  801361:	50                   	push   %eax
  801362:	68 90 36 80 00       	push   $0x803690
  801367:	e8 b1 00 00 00       	call   80141d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80136c:	83 c4 18             	add    $0x18,%esp
  80136f:	53                   	push   %ebx
  801370:	ff 75 10             	pushl  0x10(%ebp)
  801373:	e8 54 00 00 00       	call   8013cc <vcprintf>
	cprintf("\n");
  801378:	c7 04 24 87 32 80 00 	movl   $0x803287,(%esp)
  80137f:	e8 99 00 00 00       	call   80141d <cprintf>
  801384:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801387:	cc                   	int3   
  801388:	eb fd                	jmp    801387 <_panic+0x43>

0080138a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	53                   	push   %ebx
  80138e:	83 ec 04             	sub    $0x4,%esp
  801391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801394:	8b 13                	mov    (%ebx),%edx
  801396:	8d 42 01             	lea    0x1(%edx),%eax
  801399:	89 03                	mov    %eax,(%ebx)
  80139b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013a7:	75 1a                	jne    8013c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	68 ff 00 00 00       	push   $0xff
  8013b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8013b4:	50                   	push   %eax
  8013b5:	e8 d6 09 00 00       	call   801d90 <sys_cputs>
		b->idx = 0;
  8013ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8013c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8013d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8013dc:	00 00 00 
	b.cnt = 0;
  8013df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8013e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	ff 75 08             	pushl  0x8(%ebp)
  8013ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	68 8a 13 80 00       	push   $0x80138a
  8013fb:	e8 1a 01 00 00       	call   80151a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801400:	83 c4 08             	add    $0x8,%esp
  801403:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801409:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80140f:	50                   	push   %eax
  801410:	e8 7b 09 00 00       	call   801d90 <sys_cputs>

	return b.cnt;
}
  801415:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801423:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801426:	50                   	push   %eax
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	e8 9d ff ff ff       	call   8013cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 1c             	sub    $0x1c,%esp
  80143a:	89 c7                	mov    %eax,%edi
  80143c:	89 d6                	mov    %edx,%esi
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	8b 55 0c             	mov    0xc(%ebp),%edx
  801444:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801447:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80144a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801452:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801455:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801458:	39 d3                	cmp    %edx,%ebx
  80145a:	72 05                	jb     801461 <printnum+0x30>
  80145c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80145f:	77 45                	ja     8014a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	ff 75 18             	pushl  0x18(%ebp)
  801467:	8b 45 14             	mov    0x14(%ebp),%eax
  80146a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80146d:	53                   	push   %ebx
  80146e:	ff 75 10             	pushl  0x10(%ebp)
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 e4             	pushl  -0x1c(%ebp)
  801477:	ff 75 e0             	pushl  -0x20(%ebp)
  80147a:	ff 75 dc             	pushl  -0x24(%ebp)
  80147d:	ff 75 d8             	pushl  -0x28(%ebp)
  801480:	e8 2b 1a 00 00       	call   802eb0 <__udivdi3>
  801485:	83 c4 18             	add    $0x18,%esp
  801488:	52                   	push   %edx
  801489:	50                   	push   %eax
  80148a:	89 f2                	mov    %esi,%edx
  80148c:	89 f8                	mov    %edi,%eax
  80148e:	e8 9e ff ff ff       	call   801431 <printnum>
  801493:	83 c4 20             	add    $0x20,%esp
  801496:	eb 18                	jmp    8014b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	56                   	push   %esi
  80149c:	ff 75 18             	pushl  0x18(%ebp)
  80149f:	ff d7                	call   *%edi
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	eb 03                	jmp    8014a9 <printnum+0x78>
  8014a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014a9:	83 eb 01             	sub    $0x1,%ebx
  8014ac:	85 db                	test   %ebx,%ebx
  8014ae:	7f e8                	jg     801498 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	56                   	push   %esi
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8014bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8014c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8014c3:	e8 18 1b 00 00       	call   802fe0 <__umoddi3>
  8014c8:	83 c4 14             	add    $0x14,%esp
  8014cb:	0f be 80 b3 36 80 00 	movsbl 0x8036b3(%eax),%eax
  8014d2:	50                   	push   %eax
  8014d3:	ff d7                	call   *%edi
}
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8014e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8014ea:	8b 10                	mov    (%eax),%edx
  8014ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8014ef:	73 0a                	jae    8014fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8014f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8014f4:	89 08                	mov    %ecx,(%eax)
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	88 02                	mov    %al,(%edx)
}
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801503:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801506:	50                   	push   %eax
  801507:	ff 75 10             	pushl  0x10(%ebp)
  80150a:	ff 75 0c             	pushl  0xc(%ebp)
  80150d:	ff 75 08             	pushl  0x8(%ebp)
  801510:	e8 05 00 00 00       	call   80151a <vprintfmt>
	va_end(ap);
}
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	57                   	push   %edi
  80151e:	56                   	push   %esi
  80151f:	53                   	push   %ebx
  801520:	83 ec 2c             	sub    $0x2c,%esp
  801523:	8b 75 08             	mov    0x8(%ebp),%esi
  801526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801529:	8b 7d 10             	mov    0x10(%ebp),%edi
  80152c:	eb 12                	jmp    801540 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80152e:	85 c0                	test   %eax,%eax
  801530:	0f 84 6a 04 00 00    	je     8019a0 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	53                   	push   %ebx
  80153a:	50                   	push   %eax
  80153b:	ff d6                	call   *%esi
  80153d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801540:	83 c7 01             	add    $0x1,%edi
  801543:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801547:	83 f8 25             	cmp    $0x25,%eax
  80154a:	75 e2                	jne    80152e <vprintfmt+0x14>
  80154c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801550:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801557:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80155e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156a:	eb 07                	jmp    801573 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80156c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80156f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801573:	8d 47 01             	lea    0x1(%edi),%eax
  801576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801579:	0f b6 07             	movzbl (%edi),%eax
  80157c:	0f b6 d0             	movzbl %al,%edx
  80157f:	83 e8 23             	sub    $0x23,%eax
  801582:	3c 55                	cmp    $0x55,%al
  801584:	0f 87 fb 03 00 00    	ja     801985 <vprintfmt+0x46b>
  80158a:	0f b6 c0             	movzbl %al,%eax
  80158d:	ff 24 85 00 38 80 00 	jmp    *0x803800(,%eax,4)
  801594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801597:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80159b:	eb d6                	jmp    801573 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8015ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8015af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8015b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8015b5:	83 f9 09             	cmp    $0x9,%ecx
  8015b8:	77 3f                	ja     8015f9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8015bd:	eb e9                	jmp    8015a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c2:	8b 00                	mov    (%eax),%eax
  8015c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8015c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ca:	8d 40 04             	lea    0x4(%eax),%eax
  8015cd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8015d3:	eb 2a                	jmp    8015ff <vprintfmt+0xe5>
  8015d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	ba 00 00 00 00       	mov    $0x0,%edx
  8015df:	0f 49 d0             	cmovns %eax,%edx
  8015e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e8:	eb 89                	jmp    801573 <vprintfmt+0x59>
  8015ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8015ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8015f4:	e9 7a ff ff ff       	jmp    801573 <vprintfmt+0x59>
  8015f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8015fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8015ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801603:	0f 89 6a ff ff ff    	jns    801573 <vprintfmt+0x59>
				width = precision, precision = -1;
  801609:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80160c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80160f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801616:	e9 58 ff ff ff       	jmp    801573 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80161b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801621:	e9 4d ff ff ff       	jmp    801573 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801626:	8b 45 14             	mov    0x14(%ebp),%eax
  801629:	8d 78 04             	lea    0x4(%eax),%edi
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	53                   	push   %ebx
  801630:	ff 30                	pushl  (%eax)
  801632:	ff d6                	call   *%esi
			break;
  801634:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801637:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80163a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80163d:	e9 fe fe ff ff       	jmp    801540 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801642:	8b 45 14             	mov    0x14(%ebp),%eax
  801645:	8d 78 04             	lea    0x4(%eax),%edi
  801648:	8b 00                	mov    (%eax),%eax
  80164a:	99                   	cltd   
  80164b:	31 d0                	xor    %edx,%eax
  80164d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80164f:	83 f8 0f             	cmp    $0xf,%eax
  801652:	7f 0b                	jg     80165f <vprintfmt+0x145>
  801654:	8b 14 85 60 39 80 00 	mov    0x803960(,%eax,4),%edx
  80165b:	85 d2                	test   %edx,%edx
  80165d:	75 1b                	jne    80167a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80165f:	50                   	push   %eax
  801660:	68 cb 36 80 00       	push   $0x8036cb
  801665:	53                   	push   %ebx
  801666:	56                   	push   %esi
  801667:	e8 91 fe ff ff       	call   8014fd <printfmt>
  80166c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80166f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801675:	e9 c6 fe ff ff       	jmp    801540 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80167a:	52                   	push   %edx
  80167b:	68 8f 31 80 00       	push   $0x80318f
  801680:	53                   	push   %ebx
  801681:	56                   	push   %esi
  801682:	e8 76 fe ff ff       	call   8014fd <printfmt>
  801687:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80168a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80168d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801690:	e9 ab fe ff ff       	jmp    801540 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801695:	8b 45 14             	mov    0x14(%ebp),%eax
  801698:	83 c0 04             	add    $0x4,%eax
  80169b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80169e:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8016a3:	85 ff                	test   %edi,%edi
  8016a5:	b8 c4 36 80 00       	mov    $0x8036c4,%eax
  8016aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8016ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016b1:	0f 8e 94 00 00 00    	jle    80174b <vprintfmt+0x231>
  8016b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8016bb:	0f 84 98 00 00 00    	je     801759 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8016c7:	57                   	push   %edi
  8016c8:	e8 5b 03 00 00       	call   801a28 <strnlen>
  8016cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8016d0:	29 c1                	sub    %eax,%ecx
  8016d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8016d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8016d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8016dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8016e2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8016e4:	eb 0f                	jmp    8016f5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8016ef:	83 ef 01             	sub    $0x1,%edi
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 ff                	test   %edi,%edi
  8016f7:	7f ed                	jg     8016e6 <vprintfmt+0x1cc>
  8016f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8016fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8016ff:	85 c9                	test   %ecx,%ecx
  801701:	b8 00 00 00 00       	mov    $0x0,%eax
  801706:	0f 49 c1             	cmovns %ecx,%eax
  801709:	29 c1                	sub    %eax,%ecx
  80170b:	89 75 08             	mov    %esi,0x8(%ebp)
  80170e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801711:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801714:	89 cb                	mov    %ecx,%ebx
  801716:	eb 4d                	jmp    801765 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801718:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80171c:	74 1b                	je     801739 <vprintfmt+0x21f>
  80171e:	0f be c0             	movsbl %al,%eax
  801721:	83 e8 20             	sub    $0x20,%eax
  801724:	83 f8 5e             	cmp    $0x5e,%eax
  801727:	76 10                	jbe    801739 <vprintfmt+0x21f>
					putch('?', putdat);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	6a 3f                	push   $0x3f
  801731:	ff 55 08             	call   *0x8(%ebp)
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	eb 0d                	jmp    801746 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	ff 75 0c             	pushl  0xc(%ebp)
  80173f:	52                   	push   %edx
  801740:	ff 55 08             	call   *0x8(%ebp)
  801743:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801746:	83 eb 01             	sub    $0x1,%ebx
  801749:	eb 1a                	jmp    801765 <vprintfmt+0x24b>
  80174b:	89 75 08             	mov    %esi,0x8(%ebp)
  80174e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801751:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801754:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801757:	eb 0c                	jmp    801765 <vprintfmt+0x24b>
  801759:	89 75 08             	mov    %esi,0x8(%ebp)
  80175c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80175f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801765:	83 c7 01             	add    $0x1,%edi
  801768:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80176c:	0f be d0             	movsbl %al,%edx
  80176f:	85 d2                	test   %edx,%edx
  801771:	74 23                	je     801796 <vprintfmt+0x27c>
  801773:	85 f6                	test   %esi,%esi
  801775:	78 a1                	js     801718 <vprintfmt+0x1fe>
  801777:	83 ee 01             	sub    $0x1,%esi
  80177a:	79 9c                	jns    801718 <vprintfmt+0x1fe>
  80177c:	89 df                	mov    %ebx,%edi
  80177e:	8b 75 08             	mov    0x8(%ebp),%esi
  801781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801784:	eb 18                	jmp    80179e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	53                   	push   %ebx
  80178a:	6a 20                	push   $0x20
  80178c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80178e:	83 ef 01             	sub    $0x1,%edi
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	eb 08                	jmp    80179e <vprintfmt+0x284>
  801796:	89 df                	mov    %ebx,%edi
  801798:	8b 75 08             	mov    0x8(%ebp),%esi
  80179b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80179e:	85 ff                	test   %edi,%edi
  8017a0:	7f e4                	jg     801786 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8017a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ab:	e9 90 fd ff ff       	jmp    801540 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8017b0:	83 f9 01             	cmp    $0x1,%ecx
  8017b3:	7e 19                	jle    8017ce <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8017b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b8:	8b 50 04             	mov    0x4(%eax),%edx
  8017bb:	8b 00                	mov    (%eax),%eax
  8017bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8017c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c6:	8d 40 08             	lea    0x8(%eax),%eax
  8017c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8017cc:	eb 38                	jmp    801806 <vprintfmt+0x2ec>
	else if (lflag)
  8017ce:	85 c9                	test   %ecx,%ecx
  8017d0:	74 1b                	je     8017ed <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8017d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d5:	8b 00                	mov    (%eax),%eax
  8017d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017da:	89 c1                	mov    %eax,%ecx
  8017dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8017df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8017e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e5:	8d 40 04             	lea    0x4(%eax),%eax
  8017e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8017eb:	eb 19                	jmp    801806 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8017ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f0:	8b 00                	mov    (%eax),%eax
  8017f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017f5:	89 c1                	mov    %eax,%ecx
  8017f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8017fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8017fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801800:	8d 40 04             	lea    0x4(%eax),%eax
  801803:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801806:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801809:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80180c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801811:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801815:	0f 89 36 01 00 00    	jns    801951 <vprintfmt+0x437>
				putch('-', putdat);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	53                   	push   %ebx
  80181f:	6a 2d                	push   $0x2d
  801821:	ff d6                	call   *%esi
				num = -(long long) num;
  801823:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801826:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801829:	f7 da                	neg    %edx
  80182b:	83 d1 00             	adc    $0x0,%ecx
  80182e:	f7 d9                	neg    %ecx
  801830:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801833:	b8 0a 00 00 00       	mov    $0xa,%eax
  801838:	e9 14 01 00 00       	jmp    801951 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80183d:	83 f9 01             	cmp    $0x1,%ecx
  801840:	7e 18                	jle    80185a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801842:	8b 45 14             	mov    0x14(%ebp),%eax
  801845:	8b 10                	mov    (%eax),%edx
  801847:	8b 48 04             	mov    0x4(%eax),%ecx
  80184a:	8d 40 08             	lea    0x8(%eax),%eax
  80184d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801850:	b8 0a 00 00 00       	mov    $0xa,%eax
  801855:	e9 f7 00 00 00       	jmp    801951 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80185a:	85 c9                	test   %ecx,%ecx
  80185c:	74 1a                	je     801878 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80185e:	8b 45 14             	mov    0x14(%ebp),%eax
  801861:	8b 10                	mov    (%eax),%edx
  801863:	b9 00 00 00 00       	mov    $0x0,%ecx
  801868:	8d 40 04             	lea    0x4(%eax),%eax
  80186b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80186e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801873:	e9 d9 00 00 00       	jmp    801951 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801878:	8b 45 14             	mov    0x14(%ebp),%eax
  80187b:	8b 10                	mov    (%eax),%edx
  80187d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801882:	8d 40 04             	lea    0x4(%eax),%eax
  801885:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801888:	b8 0a 00 00 00       	mov    $0xa,%eax
  80188d:	e9 bf 00 00 00       	jmp    801951 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801892:	83 f9 01             	cmp    $0x1,%ecx
  801895:	7e 13                	jle    8018aa <vprintfmt+0x390>
		return va_arg(*ap, long long);
  801897:	8b 45 14             	mov    0x14(%ebp),%eax
  80189a:	8b 50 04             	mov    0x4(%eax),%edx
  80189d:	8b 00                	mov    (%eax),%eax
  80189f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8018a2:	8d 49 08             	lea    0x8(%ecx),%ecx
  8018a5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8018a8:	eb 28                	jmp    8018d2 <vprintfmt+0x3b8>
	else if (lflag)
  8018aa:	85 c9                	test   %ecx,%ecx
  8018ac:	74 13                	je     8018c1 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8018ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b1:	8b 10                	mov    (%eax),%edx
  8018b3:	89 d0                	mov    %edx,%eax
  8018b5:	99                   	cltd   
  8018b6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8018b9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8018bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8018bf:	eb 11                	jmp    8018d2 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8018c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c4:	8b 10                	mov    (%eax),%edx
  8018c6:	89 d0                	mov    %edx,%eax
  8018c8:	99                   	cltd   
  8018c9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8018cc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8018cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8018d2:	89 d1                	mov    %edx,%ecx
  8018d4:	89 c2                	mov    %eax,%edx
			base = 8;
  8018d6:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8018db:	eb 74                	jmp    801951 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	53                   	push   %ebx
  8018e1:	6a 30                	push   $0x30
  8018e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8018e5:	83 c4 08             	add    $0x8,%esp
  8018e8:	53                   	push   %ebx
  8018e9:	6a 78                	push   $0x78
  8018eb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8018ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f0:	8b 10                	mov    (%eax),%edx
  8018f2:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018f7:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018fa:	8d 40 04             	lea    0x4(%eax),%eax
  8018fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801900:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801905:	eb 4a                	jmp    801951 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801907:	83 f9 01             	cmp    $0x1,%ecx
  80190a:	7e 15                	jle    801921 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80190c:	8b 45 14             	mov    0x14(%ebp),%eax
  80190f:	8b 10                	mov    (%eax),%edx
  801911:	8b 48 04             	mov    0x4(%eax),%ecx
  801914:	8d 40 08             	lea    0x8(%eax),%eax
  801917:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80191a:	b8 10 00 00 00       	mov    $0x10,%eax
  80191f:	eb 30                	jmp    801951 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801921:	85 c9                	test   %ecx,%ecx
  801923:	74 17                	je     80193c <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  801925:	8b 45 14             	mov    0x14(%ebp),%eax
  801928:	8b 10                	mov    (%eax),%edx
  80192a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80192f:	8d 40 04             	lea    0x4(%eax),%eax
  801932:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801935:	b8 10 00 00 00       	mov    $0x10,%eax
  80193a:	eb 15                	jmp    801951 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80193c:	8b 45 14             	mov    0x14(%ebp),%eax
  80193f:	8b 10                	mov    (%eax),%edx
  801941:	b9 00 00 00 00       	mov    $0x0,%ecx
  801946:	8d 40 04             	lea    0x4(%eax),%eax
  801949:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80194c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801951:	83 ec 0c             	sub    $0xc,%esp
  801954:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801958:	57                   	push   %edi
  801959:	ff 75 e0             	pushl  -0x20(%ebp)
  80195c:	50                   	push   %eax
  80195d:	51                   	push   %ecx
  80195e:	52                   	push   %edx
  80195f:	89 da                	mov    %ebx,%edx
  801961:	89 f0                	mov    %esi,%eax
  801963:	e8 c9 fa ff ff       	call   801431 <printnum>
			break;
  801968:	83 c4 20             	add    $0x20,%esp
  80196b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80196e:	e9 cd fb ff ff       	jmp    801540 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	53                   	push   %ebx
  801977:	52                   	push   %edx
  801978:	ff d6                	call   *%esi
			break;
  80197a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801980:	e9 bb fb ff ff       	jmp    801540 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	53                   	push   %ebx
  801989:	6a 25                	push   $0x25
  80198b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	eb 03                	jmp    801995 <vprintfmt+0x47b>
  801992:	83 ef 01             	sub    $0x1,%edi
  801995:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801999:	75 f7                	jne    801992 <vprintfmt+0x478>
  80199b:	e9 a0 fb ff ff       	jmp    801540 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 18             	sub    $0x18,%esp
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	74 26                	je     8019ef <vsnprintf+0x47>
  8019c9:	85 d2                	test   %edx,%edx
  8019cb:	7e 22                	jle    8019ef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019cd:	ff 75 14             	pushl  0x14(%ebp)
  8019d0:	ff 75 10             	pushl  0x10(%ebp)
  8019d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019d6:	50                   	push   %eax
  8019d7:	68 e0 14 80 00       	push   $0x8014e0
  8019dc:	e8 39 fb ff ff       	call   80151a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	eb 05                	jmp    8019f4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019ff:	50                   	push   %eax
  801a00:	ff 75 10             	pushl  0x10(%ebp)
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	ff 75 08             	pushl  0x8(%ebp)
  801a09:	e8 9a ff ff ff       	call   8019a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1b:	eb 03                	jmp    801a20 <strlen+0x10>
		n++;
  801a1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a24:	75 f7                	jne    801a1d <strlen+0xd>
		n++;
	return n;
}
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	eb 03                	jmp    801a3b <strnlen+0x13>
		n++;
  801a38:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a3b:	39 c2                	cmp    %eax,%edx
  801a3d:	74 08                	je     801a47 <strnlen+0x1f>
  801a3f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a43:	75 f3                	jne    801a38 <strnlen+0x10>
  801a45:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	53                   	push   %ebx
  801a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a53:	89 c2                	mov    %eax,%edx
  801a55:	83 c2 01             	add    $0x1,%edx
  801a58:	83 c1 01             	add    $0x1,%ecx
  801a5b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a5f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a62:	84 db                	test   %bl,%bl
  801a64:	75 ef                	jne    801a55 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a66:	5b                   	pop    %ebx
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	53                   	push   %ebx
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a70:	53                   	push   %ebx
  801a71:	e8 9a ff ff ff       	call   801a10 <strlen>
  801a76:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a79:	ff 75 0c             	pushl  0xc(%ebp)
  801a7c:	01 d8                	add    %ebx,%eax
  801a7e:	50                   	push   %eax
  801a7f:	e8 c5 ff ff ff       	call   801a49 <strcpy>
	return dst;
}
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	8b 75 08             	mov    0x8(%ebp),%esi
  801a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a96:	89 f3                	mov    %esi,%ebx
  801a98:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a9b:	89 f2                	mov    %esi,%edx
  801a9d:	eb 0f                	jmp    801aae <strncpy+0x23>
		*dst++ = *src;
  801a9f:	83 c2 01             	add    $0x1,%edx
  801aa2:	0f b6 01             	movzbl (%ecx),%eax
  801aa5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801aa8:	80 39 01             	cmpb   $0x1,(%ecx)
  801aab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aae:	39 da                	cmp    %ebx,%edx
  801ab0:	75 ed                	jne    801a9f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ab2:	89 f0                	mov    %esi,%eax
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac3:	8b 55 10             	mov    0x10(%ebp),%edx
  801ac6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ac8:	85 d2                	test   %edx,%edx
  801aca:	74 21                	je     801aed <strlcpy+0x35>
  801acc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ad0:	89 f2                	mov    %esi,%edx
  801ad2:	eb 09                	jmp    801add <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ad4:	83 c2 01             	add    $0x1,%edx
  801ad7:	83 c1 01             	add    $0x1,%ecx
  801ada:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801add:	39 c2                	cmp    %eax,%edx
  801adf:	74 09                	je     801aea <strlcpy+0x32>
  801ae1:	0f b6 19             	movzbl (%ecx),%ebx
  801ae4:	84 db                	test   %bl,%bl
  801ae6:	75 ec                	jne    801ad4 <strlcpy+0x1c>
  801ae8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801aea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801aed:	29 f0                	sub    %esi,%eax
}
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801afc:	eb 06                	jmp    801b04 <strcmp+0x11>
		p++, q++;
  801afe:	83 c1 01             	add    $0x1,%ecx
  801b01:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b04:	0f b6 01             	movzbl (%ecx),%eax
  801b07:	84 c0                	test   %al,%al
  801b09:	74 04                	je     801b0f <strcmp+0x1c>
  801b0b:	3a 02                	cmp    (%edx),%al
  801b0d:	74 ef                	je     801afe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b0f:	0f b6 c0             	movzbl %al,%eax
  801b12:	0f b6 12             	movzbl (%edx),%edx
  801b15:	29 d0                	sub    %edx,%eax
}
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	53                   	push   %ebx
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b28:	eb 06                	jmp    801b30 <strncmp+0x17>
		n--, p++, q++;
  801b2a:	83 c0 01             	add    $0x1,%eax
  801b2d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b30:	39 d8                	cmp    %ebx,%eax
  801b32:	74 15                	je     801b49 <strncmp+0x30>
  801b34:	0f b6 08             	movzbl (%eax),%ecx
  801b37:	84 c9                	test   %cl,%cl
  801b39:	74 04                	je     801b3f <strncmp+0x26>
  801b3b:	3a 0a                	cmp    (%edx),%cl
  801b3d:	74 eb                	je     801b2a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b3f:	0f b6 00             	movzbl (%eax),%eax
  801b42:	0f b6 12             	movzbl (%edx),%edx
  801b45:	29 d0                	sub    %edx,%eax
  801b47:	eb 05                	jmp    801b4e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b4e:	5b                   	pop    %ebx
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b5b:	eb 07                	jmp    801b64 <strchr+0x13>
		if (*s == c)
  801b5d:	38 ca                	cmp    %cl,%dl
  801b5f:	74 0f                	je     801b70 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b61:	83 c0 01             	add    $0x1,%eax
  801b64:	0f b6 10             	movzbl (%eax),%edx
  801b67:	84 d2                	test   %dl,%dl
  801b69:	75 f2                	jne    801b5d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	8b 45 08             	mov    0x8(%ebp),%eax
  801b78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b7c:	eb 03                	jmp    801b81 <strfind+0xf>
  801b7e:	83 c0 01             	add    $0x1,%eax
  801b81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b84:	38 ca                	cmp    %cl,%dl
  801b86:	74 04                	je     801b8c <strfind+0x1a>
  801b88:	84 d2                	test   %dl,%dl
  801b8a:	75 f2                	jne    801b7e <strfind+0xc>
			break;
	return (char *) s;
}
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b9a:	85 c9                	test   %ecx,%ecx
  801b9c:	74 36                	je     801bd4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ba4:	75 28                	jne    801bce <memset+0x40>
  801ba6:	f6 c1 03             	test   $0x3,%cl
  801ba9:	75 23                	jne    801bce <memset+0x40>
		c &= 0xFF;
  801bab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801baf:	89 d3                	mov    %edx,%ebx
  801bb1:	c1 e3 08             	shl    $0x8,%ebx
  801bb4:	89 d6                	mov    %edx,%esi
  801bb6:	c1 e6 18             	shl    $0x18,%esi
  801bb9:	89 d0                	mov    %edx,%eax
  801bbb:	c1 e0 10             	shl    $0x10,%eax
  801bbe:	09 f0                	or     %esi,%eax
  801bc0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bc2:	89 d8                	mov    %ebx,%eax
  801bc4:	09 d0                	or     %edx,%eax
  801bc6:	c1 e9 02             	shr    $0x2,%ecx
  801bc9:	fc                   	cld    
  801bca:	f3 ab                	rep stos %eax,%es:(%edi)
  801bcc:	eb 06                	jmp    801bd4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd1:	fc                   	cld    
  801bd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bd4:	89 f8                	mov    %edi,%eax
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5f                   	pop    %edi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801be9:	39 c6                	cmp    %eax,%esi
  801beb:	73 35                	jae    801c22 <memmove+0x47>
  801bed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bf0:	39 d0                	cmp    %edx,%eax
  801bf2:	73 2e                	jae    801c22 <memmove+0x47>
		s += n;
		d += n;
  801bf4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bf7:	89 d6                	mov    %edx,%esi
  801bf9:	09 fe                	or     %edi,%esi
  801bfb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c01:	75 13                	jne    801c16 <memmove+0x3b>
  801c03:	f6 c1 03             	test   $0x3,%cl
  801c06:	75 0e                	jne    801c16 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c08:	83 ef 04             	sub    $0x4,%edi
  801c0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c0e:	c1 e9 02             	shr    $0x2,%ecx
  801c11:	fd                   	std    
  801c12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c14:	eb 09                	jmp    801c1f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c16:	83 ef 01             	sub    $0x1,%edi
  801c19:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c1c:	fd                   	std    
  801c1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c1f:	fc                   	cld    
  801c20:	eb 1d                	jmp    801c3f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c22:	89 f2                	mov    %esi,%edx
  801c24:	09 c2                	or     %eax,%edx
  801c26:	f6 c2 03             	test   $0x3,%dl
  801c29:	75 0f                	jne    801c3a <memmove+0x5f>
  801c2b:	f6 c1 03             	test   $0x3,%cl
  801c2e:	75 0a                	jne    801c3a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c30:	c1 e9 02             	shr    $0x2,%ecx
  801c33:	89 c7                	mov    %eax,%edi
  801c35:	fc                   	cld    
  801c36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c38:	eb 05                	jmp    801c3f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c3a:	89 c7                	mov    %eax,%edi
  801c3c:	fc                   	cld    
  801c3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c3f:	5e                   	pop    %esi
  801c40:	5f                   	pop    %edi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c46:	ff 75 10             	pushl  0x10(%ebp)
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	ff 75 08             	pushl  0x8(%ebp)
  801c4f:	e8 87 ff ff ff       	call   801bdb <memmove>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c61:	89 c6                	mov    %eax,%esi
  801c63:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c66:	eb 1a                	jmp    801c82 <memcmp+0x2c>
		if (*s1 != *s2)
  801c68:	0f b6 08             	movzbl (%eax),%ecx
  801c6b:	0f b6 1a             	movzbl (%edx),%ebx
  801c6e:	38 d9                	cmp    %bl,%cl
  801c70:	74 0a                	je     801c7c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c72:	0f b6 c1             	movzbl %cl,%eax
  801c75:	0f b6 db             	movzbl %bl,%ebx
  801c78:	29 d8                	sub    %ebx,%eax
  801c7a:	eb 0f                	jmp    801c8b <memcmp+0x35>
		s1++, s2++;
  801c7c:	83 c0 01             	add    $0x1,%eax
  801c7f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c82:	39 f0                	cmp    %esi,%eax
  801c84:	75 e2                	jne    801c68 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	53                   	push   %ebx
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c96:	89 c1                	mov    %eax,%ecx
  801c98:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c9b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c9f:	eb 0a                	jmp    801cab <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ca1:	0f b6 10             	movzbl (%eax),%edx
  801ca4:	39 da                	cmp    %ebx,%edx
  801ca6:	74 07                	je     801caf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ca8:	83 c0 01             	add    $0x1,%eax
  801cab:	39 c8                	cmp    %ecx,%eax
  801cad:	72 f2                	jb     801ca1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801caf:	5b                   	pop    %ebx
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	57                   	push   %edi
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cbe:	eb 03                	jmp    801cc3 <strtol+0x11>
		s++;
  801cc0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cc3:	0f b6 01             	movzbl (%ecx),%eax
  801cc6:	3c 20                	cmp    $0x20,%al
  801cc8:	74 f6                	je     801cc0 <strtol+0xe>
  801cca:	3c 09                	cmp    $0x9,%al
  801ccc:	74 f2                	je     801cc0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cce:	3c 2b                	cmp    $0x2b,%al
  801cd0:	75 0a                	jne    801cdc <strtol+0x2a>
		s++;
  801cd2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801cd5:	bf 00 00 00 00       	mov    $0x0,%edi
  801cda:	eb 11                	jmp    801ced <strtol+0x3b>
  801cdc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ce1:	3c 2d                	cmp    $0x2d,%al
  801ce3:	75 08                	jne    801ced <strtol+0x3b>
		s++, neg = 1;
  801ce5:	83 c1 01             	add    $0x1,%ecx
  801ce8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ced:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cf3:	75 15                	jne    801d0a <strtol+0x58>
  801cf5:	80 39 30             	cmpb   $0x30,(%ecx)
  801cf8:	75 10                	jne    801d0a <strtol+0x58>
  801cfa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cfe:	75 7c                	jne    801d7c <strtol+0xca>
		s += 2, base = 16;
  801d00:	83 c1 02             	add    $0x2,%ecx
  801d03:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d08:	eb 16                	jmp    801d20 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d0a:	85 db                	test   %ebx,%ebx
  801d0c:	75 12                	jne    801d20 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d13:	80 39 30             	cmpb   $0x30,(%ecx)
  801d16:	75 08                	jne    801d20 <strtol+0x6e>
		s++, base = 8;
  801d18:	83 c1 01             	add    $0x1,%ecx
  801d1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
  801d25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d28:	0f b6 11             	movzbl (%ecx),%edx
  801d2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d2e:	89 f3                	mov    %esi,%ebx
  801d30:	80 fb 09             	cmp    $0x9,%bl
  801d33:	77 08                	ja     801d3d <strtol+0x8b>
			dig = *s - '0';
  801d35:	0f be d2             	movsbl %dl,%edx
  801d38:	83 ea 30             	sub    $0x30,%edx
  801d3b:	eb 22                	jmp    801d5f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d40:	89 f3                	mov    %esi,%ebx
  801d42:	80 fb 19             	cmp    $0x19,%bl
  801d45:	77 08                	ja     801d4f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d47:	0f be d2             	movsbl %dl,%edx
  801d4a:	83 ea 57             	sub    $0x57,%edx
  801d4d:	eb 10                	jmp    801d5f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d52:	89 f3                	mov    %esi,%ebx
  801d54:	80 fb 19             	cmp    $0x19,%bl
  801d57:	77 16                	ja     801d6f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d59:	0f be d2             	movsbl %dl,%edx
  801d5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d62:	7d 0b                	jge    801d6f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d64:	83 c1 01             	add    $0x1,%ecx
  801d67:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d6d:	eb b9                	jmp    801d28 <strtol+0x76>

	if (endptr)
  801d6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d73:	74 0d                	je     801d82 <strtol+0xd0>
		*endptr = (char *) s;
  801d75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d78:	89 0e                	mov    %ecx,(%esi)
  801d7a:	eb 06                	jmp    801d82 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d7c:	85 db                	test   %ebx,%ebx
  801d7e:	74 98                	je     801d18 <strtol+0x66>
  801d80:	eb 9e                	jmp    801d20 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d82:	89 c2                	mov    %eax,%edx
  801d84:	f7 da                	neg    %edx
  801d86:	85 ff                	test   %edi,%edi
  801d88:	0f 45 c2             	cmovne %edx,%eax
}
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5f                   	pop    %edi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    

00801d90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	57                   	push   %edi
  801d94:	56                   	push   %esi
  801d95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  801da1:	89 c3                	mov    %eax,%ebx
  801da3:	89 c7                	mov    %eax,%edi
  801da5:	89 c6                	mov    %eax,%esi
  801da7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801da9:	5b                   	pop    %ebx
  801daa:	5e                   	pop    %esi
  801dab:	5f                   	pop    %edi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <sys_cgetc>:

int
sys_cgetc(void)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801db4:	ba 00 00 00 00       	mov    $0x0,%edx
  801db9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbe:	89 d1                	mov    %edx,%ecx
  801dc0:	89 d3                	mov    %edx,%ebx
  801dc2:	89 d7                	mov    %edx,%edi
  801dc4:	89 d6                	mov    %edx,%esi
  801dc6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	57                   	push   %edi
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ddb:	b8 03 00 00 00       	mov    $0x3,%eax
  801de0:	8b 55 08             	mov    0x8(%ebp),%edx
  801de3:	89 cb                	mov    %ecx,%ebx
  801de5:	89 cf                	mov    %ecx,%edi
  801de7:	89 ce                	mov    %ecx,%esi
  801de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801deb:	85 c0                	test   %eax,%eax
  801ded:	7e 17                	jle    801e06 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801def:	83 ec 0c             	sub    $0xc,%esp
  801df2:	50                   	push   %eax
  801df3:	6a 03                	push   $0x3
  801df5:	68 bf 39 80 00       	push   $0x8039bf
  801dfa:	6a 23                	push   $0x23
  801dfc:	68 dc 39 80 00       	push   $0x8039dc
  801e01:	e8 3e f5 ff ff       	call   801344 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e09:	5b                   	pop    %ebx
  801e0a:	5e                   	pop    %esi
  801e0b:	5f                   	pop    %edi
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	57                   	push   %edi
  801e12:	56                   	push   %esi
  801e13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e14:	ba 00 00 00 00       	mov    $0x0,%edx
  801e19:	b8 02 00 00 00       	mov    $0x2,%eax
  801e1e:	89 d1                	mov    %edx,%ecx
  801e20:	89 d3                	mov    %edx,%ebx
  801e22:	89 d7                	mov    %edx,%edi
  801e24:	89 d6                	mov    %edx,%esi
  801e26:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <sys_yield>:

void
sys_yield(void)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	57                   	push   %edi
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e33:	ba 00 00 00 00       	mov    $0x0,%edx
  801e38:	b8 0b 00 00 00       	mov    $0xb,%eax
  801e3d:	89 d1                	mov    %edx,%ecx
  801e3f:	89 d3                	mov    %edx,%ebx
  801e41:	89 d7                	mov    %edx,%edi
  801e43:	89 d6                	mov    %edx,%esi
  801e45:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	57                   	push   %edi
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e55:	be 00 00 00 00       	mov    $0x0,%esi
  801e5a:	b8 04 00 00 00       	mov    $0x4,%eax
  801e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e62:	8b 55 08             	mov    0x8(%ebp),%edx
  801e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e68:	89 f7                	mov    %esi,%edi
  801e6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	7e 17                	jle    801e87 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801e70:	83 ec 0c             	sub    $0xc,%esp
  801e73:	50                   	push   %eax
  801e74:	6a 04                	push   $0x4
  801e76:	68 bf 39 80 00       	push   $0x8039bf
  801e7b:	6a 23                	push   $0x23
  801e7d:	68 dc 39 80 00       	push   $0x8039dc
  801e82:	e8 bd f4 ff ff       	call   801344 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	57                   	push   %edi
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801e98:	b8 05 00 00 00       	mov    $0x5,%eax
  801e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea6:	8b 7d 14             	mov    0x14(%ebp),%edi
  801ea9:	8b 75 18             	mov    0x18(%ebp),%esi
  801eac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	7e 17                	jle    801ec9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	50                   	push   %eax
  801eb6:	6a 05                	push   $0x5
  801eb8:	68 bf 39 80 00       	push   $0x8039bf
  801ebd:	6a 23                	push   $0x23
  801ebf:	68 dc 39 80 00       	push   $0x8039dc
  801ec4:	e8 7b f4 ff ff       	call   801344 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801ec9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5f                   	pop    %edi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	57                   	push   %edi
  801ed5:	56                   	push   %esi
  801ed6:	53                   	push   %ebx
  801ed7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801eda:	bb 00 00 00 00       	mov    $0x0,%ebx
  801edf:	b8 06 00 00 00       	mov    $0x6,%eax
  801ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  801eea:	89 df                	mov    %ebx,%edi
  801eec:	89 de                	mov    %ebx,%esi
  801eee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	7e 17                	jle    801f0b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801ef4:	83 ec 0c             	sub    $0xc,%esp
  801ef7:	50                   	push   %eax
  801ef8:	6a 06                	push   $0x6
  801efa:	68 bf 39 80 00       	push   $0x8039bf
  801eff:	6a 23                	push   $0x23
  801f01:	68 dc 39 80 00       	push   $0x8039dc
  801f06:	e8 39 f4 ff ff       	call   801344 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5f                   	pop    %edi
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    

00801f13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	57                   	push   %edi
  801f17:	56                   	push   %esi
  801f18:	53                   	push   %ebx
  801f19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f21:	b8 08 00 00 00       	mov    $0x8,%eax
  801f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f29:	8b 55 08             	mov    0x8(%ebp),%edx
  801f2c:	89 df                	mov    %ebx,%edi
  801f2e:	89 de                	mov    %ebx,%esi
  801f30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801f32:	85 c0                	test   %eax,%eax
  801f34:	7e 17                	jle    801f4d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801f36:	83 ec 0c             	sub    $0xc,%esp
  801f39:	50                   	push   %eax
  801f3a:	6a 08                	push   $0x8
  801f3c:	68 bf 39 80 00       	push   $0x8039bf
  801f41:	6a 23                	push   $0x23
  801f43:	68 dc 39 80 00       	push   $0x8039dc
  801f48:	e8 f7 f3 ff ff       	call   801344 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f50:	5b                   	pop    %ebx
  801f51:	5e                   	pop    %esi
  801f52:	5f                   	pop    %edi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	57                   	push   %edi
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f63:	b8 09 00 00 00       	mov    $0x9,%eax
  801f68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f6e:	89 df                	mov    %ebx,%edi
  801f70:	89 de                	mov    %ebx,%esi
  801f72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801f74:	85 c0                	test   %eax,%eax
  801f76:	7e 17                	jle    801f8f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801f78:	83 ec 0c             	sub    $0xc,%esp
  801f7b:	50                   	push   %eax
  801f7c:	6a 09                	push   $0x9
  801f7e:	68 bf 39 80 00       	push   $0x8039bf
  801f83:	6a 23                	push   $0x23
  801f85:	68 dc 39 80 00       	push   $0x8039dc
  801f8a:	e8 b5 f3 ff ff       	call   801344 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f92:	5b                   	pop    %ebx
  801f93:	5e                   	pop    %esi
  801f94:	5f                   	pop    %edi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    

00801f97 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	57                   	push   %edi
  801f9b:	56                   	push   %esi
  801f9c:	53                   	push   %ebx
  801f9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801fa0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fa5:	b8 0a 00 00 00       	mov    $0xa,%eax
  801faa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fad:	8b 55 08             	mov    0x8(%ebp),%edx
  801fb0:	89 df                	mov    %ebx,%edi
  801fb2:	89 de                	mov    %ebx,%esi
  801fb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	7e 17                	jle    801fd1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	50                   	push   %eax
  801fbe:	6a 0a                	push   $0xa
  801fc0:	68 bf 39 80 00       	push   $0x8039bf
  801fc5:	6a 23                	push   $0x23
  801fc7:	68 dc 39 80 00       	push   $0x8039dc
  801fcc:	e8 73 f3 ff ff       	call   801344 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	57                   	push   %edi
  801fdd:	56                   	push   %esi
  801fde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801fdf:	be 00 00 00 00       	mov    $0x0,%esi
  801fe4:	b8 0c 00 00 00       	mov    $0xc,%eax
  801fe9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fec:	8b 55 08             	mov    0x8(%ebp),%edx
  801fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ff2:	8b 7d 14             	mov    0x14(%ebp),%edi
  801ff5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801ff7:	5b                   	pop    %ebx
  801ff8:	5e                   	pop    %esi
  801ff9:	5f                   	pop    %edi
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    

00801ffc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	57                   	push   %edi
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802005:	b9 00 00 00 00       	mov    $0x0,%ecx
  80200a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80200f:	8b 55 08             	mov    0x8(%ebp),%edx
  802012:	89 cb                	mov    %ecx,%ebx
  802014:	89 cf                	mov    %ecx,%edi
  802016:	89 ce                	mov    %ecx,%esi
  802018:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80201a:	85 c0                	test   %eax,%eax
  80201c:	7e 17                	jle    802035 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80201e:	83 ec 0c             	sub    $0xc,%esp
  802021:	50                   	push   %eax
  802022:	6a 0d                	push   $0xd
  802024:	68 bf 39 80 00       	push   $0x8039bf
  802029:	6a 23                	push   $0x23
  80202b:	68 dc 39 80 00       	push   $0x8039dc
  802030:	e8 0f f3 ff ff       	call   801344 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802035:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802043:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  80204a:	75 31                	jne    80207d <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  80204c:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802051:	8b 40 48             	mov    0x48(%eax),%eax
  802054:	83 ec 04             	sub    $0x4,%esp
  802057:	6a 07                	push   $0x7
  802059:	68 00 f0 bf ee       	push   $0xeebff000
  80205e:	50                   	push   %eax
  80205f:	e8 e8 fd ff ff       	call   801e4c <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  802064:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802069:	8b 40 48             	mov    0x48(%eax),%eax
  80206c:	83 c4 08             	add    $0x8,%esp
  80206f:	68 87 20 80 00       	push   $0x802087
  802074:	50                   	push   %eax
  802075:	e8 1d ff ff ff       	call   801f97 <sys_env_set_pgfault_upcall>
  80207a:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80207d:	8b 45 08             	mov    0x8(%ebp),%eax
  802080:	a3 10 90 80 00       	mov    %eax,0x809010
}
  802085:	c9                   	leave  
  802086:	c3                   	ret    

00802087 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802087:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802088:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  80208d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80208f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  802092:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  802095:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  802099:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  80209d:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  8020a0:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  8020a2:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8020a6:	61                   	popa   
	addl $4, %esp        // skip eip
  8020a7:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  8020aa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8020ab:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020ac:	c3                   	ret    

008020ad <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020ad:	55                   	push   %ebp
  8020ae:	89 e5                	mov    %esp,%ebp
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	74 0e                	je     8020cd <ipc_recv+0x20>
  8020bf:	83 ec 0c             	sub    $0xc,%esp
  8020c2:	50                   	push   %eax
  8020c3:	e8 34 ff ff ff       	call   801ffc <sys_ipc_recv>
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	eb 10                	jmp    8020dd <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8020cd:	83 ec 0c             	sub    $0xc,%esp
  8020d0:	68 00 00 c0 ee       	push   $0xeec00000
  8020d5:	e8 22 ff ff ff       	call   801ffc <sys_ipc_recv>
  8020da:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	74 16                	je     8020f7 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  8020e1:	85 f6                	test   %esi,%esi
  8020e3:	74 06                	je     8020eb <ipc_recv+0x3e>
  8020e5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020eb:	85 db                	test   %ebx,%ebx
  8020ed:	74 2c                	je     80211b <ipc_recv+0x6e>
  8020ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020f5:	eb 24                	jmp    80211b <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	74 0a                	je     802105 <ipc_recv+0x58>
  8020fb:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802100:	8b 40 74             	mov    0x74(%eax),%eax
  802103:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  802105:	85 db                	test   %ebx,%ebx
  802107:	74 0a                	je     802113 <ipc_recv+0x66>
  802109:	a1 0c 90 80 00       	mov    0x80900c,%eax
  80210e:	8b 40 78             	mov    0x78(%eax),%eax
  802111:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802113:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802118:	8b 40 70             	mov    0x70(%eax),%eax
}
  80211b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80211e:	5b                   	pop    %ebx
  80211f:	5e                   	pop    %esi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    

00802122 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802122:	55                   	push   %ebp
  802123:	89 e5                	mov    %esp,%ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 0c             	sub    $0xc,%esp
  80212b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80212e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802131:	8b 45 10             	mov    0x10(%ebp),%eax
  802134:	85 c0                	test   %eax,%eax
  802136:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80213b:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  80213e:	ff 75 14             	pushl  0x14(%ebp)
  802141:	53                   	push   %ebx
  802142:	56                   	push   %esi
  802143:	57                   	push   %edi
  802144:	e8 90 fe ff ff       	call   801fd9 <sys_ipc_try_send>
		if (ret == 0) break;
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	85 c0                	test   %eax,%eax
  80214e:	74 1e                	je     80216e <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  802150:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802153:	74 12                	je     802167 <ipc_send+0x45>
  802155:	50                   	push   %eax
  802156:	68 ea 39 80 00       	push   $0x8039ea
  80215b:	6a 39                	push   $0x39
  80215d:	68 f7 39 80 00       	push   $0x8039f7
  802162:	e8 dd f1 ff ff       	call   801344 <_panic>
		sys_yield();
  802167:	e8 c1 fc ff ff       	call   801e2d <sys_yield>
	}
  80216c:	eb d0                	jmp    80213e <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  80216e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802171:	5b                   	pop    %ebx
  802172:	5e                   	pop    %esi
  802173:	5f                   	pop    %edi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    

00802176 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80217c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802181:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802184:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80218a:	8b 52 50             	mov    0x50(%edx),%edx
  80218d:	39 ca                	cmp    %ecx,%edx
  80218f:	75 0d                	jne    80219e <ipc_find_env+0x28>
			return envs[i].env_id;
  802191:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802194:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802199:	8b 40 48             	mov    0x48(%eax),%eax
  80219c:	eb 0f                	jmp    8021ad <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80219e:	83 c0 01             	add    $0x1,%eax
  8021a1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a6:	75 d9                	jne    802181 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8021b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b5:	05 00 00 00 30       	add    $0x30000000,%eax
  8021ba:	c1 e8 0c             	shr    $0xc,%eax
}
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    

008021bf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8021c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c5:	05 00 00 00 30       	add    $0x30000000,%eax
  8021ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8021cf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021dc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8021e1:	89 c2                	mov    %eax,%edx
  8021e3:	c1 ea 16             	shr    $0x16,%edx
  8021e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021ed:	f6 c2 01             	test   $0x1,%dl
  8021f0:	74 11                	je     802203 <fd_alloc+0x2d>
  8021f2:	89 c2                	mov    %eax,%edx
  8021f4:	c1 ea 0c             	shr    $0xc,%edx
  8021f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8021fe:	f6 c2 01             	test   $0x1,%dl
  802201:	75 09                	jne    80220c <fd_alloc+0x36>
			*fd_store = fd;
  802203:	89 01                	mov    %eax,(%ecx)
			return 0;
  802205:	b8 00 00 00 00       	mov    $0x0,%eax
  80220a:	eb 17                	jmp    802223 <fd_alloc+0x4d>
  80220c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802211:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802216:	75 c9                	jne    8021e1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802218:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80221e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80222b:	83 f8 1f             	cmp    $0x1f,%eax
  80222e:	77 36                	ja     802266 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802230:	c1 e0 0c             	shl    $0xc,%eax
  802233:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802238:	89 c2                	mov    %eax,%edx
  80223a:	c1 ea 16             	shr    $0x16,%edx
  80223d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802244:	f6 c2 01             	test   $0x1,%dl
  802247:	74 24                	je     80226d <fd_lookup+0x48>
  802249:	89 c2                	mov    %eax,%edx
  80224b:	c1 ea 0c             	shr    $0xc,%edx
  80224e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802255:	f6 c2 01             	test   $0x1,%dl
  802258:	74 1a                	je     802274 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80225a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80225d:	89 02                	mov    %eax,(%edx)
	return 0;
  80225f:	b8 00 00 00 00       	mov    $0x0,%eax
  802264:	eb 13                	jmp    802279 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802266:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80226b:	eb 0c                	jmp    802279 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80226d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802272:	eb 05                	jmp    802279 <fd_lookup+0x54>
  802274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    

0080227b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 08             	sub    $0x8,%esp
  802281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802284:	ba 84 3a 80 00       	mov    $0x803a84,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802289:	eb 13                	jmp    80229e <dev_lookup+0x23>
  80228b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80228e:	39 08                	cmp    %ecx,(%eax)
  802290:	75 0c                	jne    80229e <dev_lookup+0x23>
			*dev = devtab[i];
  802292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802295:	89 01                	mov    %eax,(%ecx)
			return 0;
  802297:	b8 00 00 00 00       	mov    $0x0,%eax
  80229c:	eb 2e                	jmp    8022cc <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80229e:	8b 02                	mov    (%edx),%eax
  8022a0:	85 c0                	test   %eax,%eax
  8022a2:	75 e7                	jne    80228b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8022a4:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8022a9:	8b 40 48             	mov    0x48(%eax),%eax
  8022ac:	83 ec 04             	sub    $0x4,%esp
  8022af:	51                   	push   %ecx
  8022b0:	50                   	push   %eax
  8022b1:	68 04 3a 80 00       	push   $0x803a04
  8022b6:	e8 62 f1 ff ff       	call   80141d <cprintf>
	*dev = 0;
  8022bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8022c4:	83 c4 10             	add    $0x10,%esp
  8022c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8022cc:	c9                   	leave  
  8022cd:	c3                   	ret    

008022ce <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	56                   	push   %esi
  8022d2:	53                   	push   %ebx
  8022d3:	83 ec 10             	sub    $0x10,%esp
  8022d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8022d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8022dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022df:	50                   	push   %eax
  8022e0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8022e6:	c1 e8 0c             	shr    $0xc,%eax
  8022e9:	50                   	push   %eax
  8022ea:	e8 36 ff ff ff       	call   802225 <fd_lookup>
  8022ef:	83 c4 08             	add    $0x8,%esp
  8022f2:	85 c0                	test   %eax,%eax
  8022f4:	78 05                	js     8022fb <fd_close+0x2d>
	    || fd != fd2)
  8022f6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8022f9:	74 0c                	je     802307 <fd_close+0x39>
		return (must_exist ? r : 0);
  8022fb:	84 db                	test   %bl,%bl
  8022fd:	ba 00 00 00 00       	mov    $0x0,%edx
  802302:	0f 44 c2             	cmove  %edx,%eax
  802305:	eb 41                	jmp    802348 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802307:	83 ec 08             	sub    $0x8,%esp
  80230a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80230d:	50                   	push   %eax
  80230e:	ff 36                	pushl  (%esi)
  802310:	e8 66 ff ff ff       	call   80227b <dev_lookup>
  802315:	89 c3                	mov    %eax,%ebx
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	85 c0                	test   %eax,%eax
  80231c:	78 1a                	js     802338 <fd_close+0x6a>
		if (dev->dev_close)
  80231e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802321:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802324:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802329:	85 c0                	test   %eax,%eax
  80232b:	74 0b                	je     802338 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80232d:	83 ec 0c             	sub    $0xc,%esp
  802330:	56                   	push   %esi
  802331:	ff d0                	call   *%eax
  802333:	89 c3                	mov    %eax,%ebx
  802335:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802338:	83 ec 08             	sub    $0x8,%esp
  80233b:	56                   	push   %esi
  80233c:	6a 00                	push   $0x0
  80233e:	e8 8e fb ff ff       	call   801ed1 <sys_page_unmap>
	return r;
  802343:	83 c4 10             	add    $0x10,%esp
  802346:	89 d8                	mov    %ebx,%eax
}
  802348:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80234b:	5b                   	pop    %ebx
  80234c:	5e                   	pop    %esi
  80234d:	5d                   	pop    %ebp
  80234e:	c3                   	ret    

0080234f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802358:	50                   	push   %eax
  802359:	ff 75 08             	pushl  0x8(%ebp)
  80235c:	e8 c4 fe ff ff       	call   802225 <fd_lookup>
  802361:	83 c4 08             	add    $0x8,%esp
  802364:	85 c0                	test   %eax,%eax
  802366:	78 10                	js     802378 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802368:	83 ec 08             	sub    $0x8,%esp
  80236b:	6a 01                	push   $0x1
  80236d:	ff 75 f4             	pushl  -0xc(%ebp)
  802370:	e8 59 ff ff ff       	call   8022ce <fd_close>
  802375:	83 c4 10             	add    $0x10,%esp
}
  802378:	c9                   	leave  
  802379:	c3                   	ret    

0080237a <close_all>:

void
close_all(void)
{
  80237a:	55                   	push   %ebp
  80237b:	89 e5                	mov    %esp,%ebp
  80237d:	53                   	push   %ebx
  80237e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802381:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	53                   	push   %ebx
  80238a:	e8 c0 ff ff ff       	call   80234f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80238f:	83 c3 01             	add    $0x1,%ebx
  802392:	83 c4 10             	add    $0x10,%esp
  802395:	83 fb 20             	cmp    $0x20,%ebx
  802398:	75 ec                	jne    802386 <close_all+0xc>
		close(i);
}
  80239a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80239d:	c9                   	leave  
  80239e:	c3                   	ret    

0080239f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	57                   	push   %edi
  8023a3:	56                   	push   %esi
  8023a4:	53                   	push   %ebx
  8023a5:	83 ec 2c             	sub    $0x2c,%esp
  8023a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8023ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8023ae:	50                   	push   %eax
  8023af:	ff 75 08             	pushl  0x8(%ebp)
  8023b2:	e8 6e fe ff ff       	call   802225 <fd_lookup>
  8023b7:	83 c4 08             	add    $0x8,%esp
  8023ba:	85 c0                	test   %eax,%eax
  8023bc:	0f 88 c1 00 00 00    	js     802483 <dup+0xe4>
		return r;
	close(newfdnum);
  8023c2:	83 ec 0c             	sub    $0xc,%esp
  8023c5:	56                   	push   %esi
  8023c6:	e8 84 ff ff ff       	call   80234f <close>

	newfd = INDEX2FD(newfdnum);
  8023cb:	89 f3                	mov    %esi,%ebx
  8023cd:	c1 e3 0c             	shl    $0xc,%ebx
  8023d0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8023d6:	83 c4 04             	add    $0x4,%esp
  8023d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023dc:	e8 de fd ff ff       	call   8021bf <fd2data>
  8023e1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8023e3:	89 1c 24             	mov    %ebx,(%esp)
  8023e6:	e8 d4 fd ff ff       	call   8021bf <fd2data>
  8023eb:	83 c4 10             	add    $0x10,%esp
  8023ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8023f1:	89 f8                	mov    %edi,%eax
  8023f3:	c1 e8 16             	shr    $0x16,%eax
  8023f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8023fd:	a8 01                	test   $0x1,%al
  8023ff:	74 37                	je     802438 <dup+0x99>
  802401:	89 f8                	mov    %edi,%eax
  802403:	c1 e8 0c             	shr    $0xc,%eax
  802406:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80240d:	f6 c2 01             	test   $0x1,%dl
  802410:	74 26                	je     802438 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802412:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802419:	83 ec 0c             	sub    $0xc,%esp
  80241c:	25 07 0e 00 00       	and    $0xe07,%eax
  802421:	50                   	push   %eax
  802422:	ff 75 d4             	pushl  -0x2c(%ebp)
  802425:	6a 00                	push   $0x0
  802427:	57                   	push   %edi
  802428:	6a 00                	push   $0x0
  80242a:	e8 60 fa ff ff       	call   801e8f <sys_page_map>
  80242f:	89 c7                	mov    %eax,%edi
  802431:	83 c4 20             	add    $0x20,%esp
  802434:	85 c0                	test   %eax,%eax
  802436:	78 2e                	js     802466 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802438:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	c1 e8 0c             	shr    $0xc,%eax
  802440:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802447:	83 ec 0c             	sub    $0xc,%esp
  80244a:	25 07 0e 00 00       	and    $0xe07,%eax
  80244f:	50                   	push   %eax
  802450:	53                   	push   %ebx
  802451:	6a 00                	push   $0x0
  802453:	52                   	push   %edx
  802454:	6a 00                	push   $0x0
  802456:	e8 34 fa ff ff       	call   801e8f <sys_page_map>
  80245b:	89 c7                	mov    %eax,%edi
  80245d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802460:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802462:	85 ff                	test   %edi,%edi
  802464:	79 1d                	jns    802483 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802466:	83 ec 08             	sub    $0x8,%esp
  802469:	53                   	push   %ebx
  80246a:	6a 00                	push   $0x0
  80246c:	e8 60 fa ff ff       	call   801ed1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802471:	83 c4 08             	add    $0x8,%esp
  802474:	ff 75 d4             	pushl  -0x2c(%ebp)
  802477:	6a 00                	push   $0x0
  802479:	e8 53 fa ff ff       	call   801ed1 <sys_page_unmap>
	return r;
  80247e:	83 c4 10             	add    $0x10,%esp
  802481:	89 f8                	mov    %edi,%eax
}
  802483:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802486:	5b                   	pop    %ebx
  802487:	5e                   	pop    %esi
  802488:	5f                   	pop    %edi
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    

0080248b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	53                   	push   %ebx
  80248f:	83 ec 14             	sub    $0x14,%esp
  802492:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802495:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802498:	50                   	push   %eax
  802499:	53                   	push   %ebx
  80249a:	e8 86 fd ff ff       	call   802225 <fd_lookup>
  80249f:	83 c4 08             	add    $0x8,%esp
  8024a2:	89 c2                	mov    %eax,%edx
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	78 6d                	js     802515 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8024a8:	83 ec 08             	sub    $0x8,%esp
  8024ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ae:	50                   	push   %eax
  8024af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024b2:	ff 30                	pushl  (%eax)
  8024b4:	e8 c2 fd ff ff       	call   80227b <dev_lookup>
  8024b9:	83 c4 10             	add    $0x10,%esp
  8024bc:	85 c0                	test   %eax,%eax
  8024be:	78 4c                	js     80250c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8024c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8024c3:	8b 42 08             	mov    0x8(%edx),%eax
  8024c6:	83 e0 03             	and    $0x3,%eax
  8024c9:	83 f8 01             	cmp    $0x1,%eax
  8024cc:	75 21                	jne    8024ef <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8024ce:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8024d3:	8b 40 48             	mov    0x48(%eax),%eax
  8024d6:	83 ec 04             	sub    $0x4,%esp
  8024d9:	53                   	push   %ebx
  8024da:	50                   	push   %eax
  8024db:	68 48 3a 80 00       	push   $0x803a48
  8024e0:	e8 38 ef ff ff       	call   80141d <cprintf>
		return -E_INVAL;
  8024e5:	83 c4 10             	add    $0x10,%esp
  8024e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8024ed:	eb 26                	jmp    802515 <read+0x8a>
	}
	if (!dev->dev_read)
  8024ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f2:	8b 40 08             	mov    0x8(%eax),%eax
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	74 17                	je     802510 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8024f9:	83 ec 04             	sub    $0x4,%esp
  8024fc:	ff 75 10             	pushl  0x10(%ebp)
  8024ff:	ff 75 0c             	pushl  0xc(%ebp)
  802502:	52                   	push   %edx
  802503:	ff d0                	call   *%eax
  802505:	89 c2                	mov    %eax,%edx
  802507:	83 c4 10             	add    $0x10,%esp
  80250a:	eb 09                	jmp    802515 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80250c:	89 c2                	mov    %eax,%edx
  80250e:	eb 05                	jmp    802515 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802510:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802515:	89 d0                	mov    %edx,%eax
  802517:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80251a:	c9                   	leave  
  80251b:	c3                   	ret    

0080251c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80251c:	55                   	push   %ebp
  80251d:	89 e5                	mov    %esp,%ebp
  80251f:	57                   	push   %edi
  802520:	56                   	push   %esi
  802521:	53                   	push   %ebx
  802522:	83 ec 0c             	sub    $0xc,%esp
  802525:	8b 7d 08             	mov    0x8(%ebp),%edi
  802528:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80252b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802530:	eb 21                	jmp    802553 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802532:	83 ec 04             	sub    $0x4,%esp
  802535:	89 f0                	mov    %esi,%eax
  802537:	29 d8                	sub    %ebx,%eax
  802539:	50                   	push   %eax
  80253a:	89 d8                	mov    %ebx,%eax
  80253c:	03 45 0c             	add    0xc(%ebp),%eax
  80253f:	50                   	push   %eax
  802540:	57                   	push   %edi
  802541:	e8 45 ff ff ff       	call   80248b <read>
		if (m < 0)
  802546:	83 c4 10             	add    $0x10,%esp
  802549:	85 c0                	test   %eax,%eax
  80254b:	78 10                	js     80255d <readn+0x41>
			return m;
		if (m == 0)
  80254d:	85 c0                	test   %eax,%eax
  80254f:	74 0a                	je     80255b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802551:	01 c3                	add    %eax,%ebx
  802553:	39 f3                	cmp    %esi,%ebx
  802555:	72 db                	jb     802532 <readn+0x16>
  802557:	89 d8                	mov    %ebx,%eax
  802559:	eb 02                	jmp    80255d <readn+0x41>
  80255b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80255d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802560:	5b                   	pop    %ebx
  802561:	5e                   	pop    %esi
  802562:	5f                   	pop    %edi
  802563:	5d                   	pop    %ebp
  802564:	c3                   	ret    

00802565 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	53                   	push   %ebx
  802569:	83 ec 14             	sub    $0x14,%esp
  80256c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80256f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802572:	50                   	push   %eax
  802573:	53                   	push   %ebx
  802574:	e8 ac fc ff ff       	call   802225 <fd_lookup>
  802579:	83 c4 08             	add    $0x8,%esp
  80257c:	89 c2                	mov    %eax,%edx
  80257e:	85 c0                	test   %eax,%eax
  802580:	78 68                	js     8025ea <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802582:	83 ec 08             	sub    $0x8,%esp
  802585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802588:	50                   	push   %eax
  802589:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80258c:	ff 30                	pushl  (%eax)
  80258e:	e8 e8 fc ff ff       	call   80227b <dev_lookup>
  802593:	83 c4 10             	add    $0x10,%esp
  802596:	85 c0                	test   %eax,%eax
  802598:	78 47                	js     8025e1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80259a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80259d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8025a1:	75 21                	jne    8025c4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8025a3:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8025a8:	8b 40 48             	mov    0x48(%eax),%eax
  8025ab:	83 ec 04             	sub    $0x4,%esp
  8025ae:	53                   	push   %ebx
  8025af:	50                   	push   %eax
  8025b0:	68 64 3a 80 00       	push   $0x803a64
  8025b5:	e8 63 ee ff ff       	call   80141d <cprintf>
		return -E_INVAL;
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8025c2:	eb 26                	jmp    8025ea <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8025c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8025ca:	85 d2                	test   %edx,%edx
  8025cc:	74 17                	je     8025e5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8025ce:	83 ec 04             	sub    $0x4,%esp
  8025d1:	ff 75 10             	pushl  0x10(%ebp)
  8025d4:	ff 75 0c             	pushl  0xc(%ebp)
  8025d7:	50                   	push   %eax
  8025d8:	ff d2                	call   *%edx
  8025da:	89 c2                	mov    %eax,%edx
  8025dc:	83 c4 10             	add    $0x10,%esp
  8025df:	eb 09                	jmp    8025ea <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8025e1:	89 c2                	mov    %eax,%edx
  8025e3:	eb 05                	jmp    8025ea <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8025e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8025ea:	89 d0                	mov    %edx,%eax
  8025ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025ef:	c9                   	leave  
  8025f0:	c3                   	ret    

008025f1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025f7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8025fa:	50                   	push   %eax
  8025fb:	ff 75 08             	pushl  0x8(%ebp)
  8025fe:	e8 22 fc ff ff       	call   802225 <fd_lookup>
  802603:	83 c4 08             	add    $0x8,%esp
  802606:	85 c0                	test   %eax,%eax
  802608:	78 0e                	js     802618 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80260a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80260d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802610:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802613:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802618:	c9                   	leave  
  802619:	c3                   	ret    

0080261a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80261a:	55                   	push   %ebp
  80261b:	89 e5                	mov    %esp,%ebp
  80261d:	53                   	push   %ebx
  80261e:	83 ec 14             	sub    $0x14,%esp
  802621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802624:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802627:	50                   	push   %eax
  802628:	53                   	push   %ebx
  802629:	e8 f7 fb ff ff       	call   802225 <fd_lookup>
  80262e:	83 c4 08             	add    $0x8,%esp
  802631:	89 c2                	mov    %eax,%edx
  802633:	85 c0                	test   %eax,%eax
  802635:	78 65                	js     80269c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802637:	83 ec 08             	sub    $0x8,%esp
  80263a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80263d:	50                   	push   %eax
  80263e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802641:	ff 30                	pushl  (%eax)
  802643:	e8 33 fc ff ff       	call   80227b <dev_lookup>
  802648:	83 c4 10             	add    $0x10,%esp
  80264b:	85 c0                	test   %eax,%eax
  80264d:	78 44                	js     802693 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80264f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802652:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802656:	75 21                	jne    802679 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802658:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80265d:	8b 40 48             	mov    0x48(%eax),%eax
  802660:	83 ec 04             	sub    $0x4,%esp
  802663:	53                   	push   %ebx
  802664:	50                   	push   %eax
  802665:	68 24 3a 80 00       	push   $0x803a24
  80266a:	e8 ae ed ff ff       	call   80141d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80266f:	83 c4 10             	add    $0x10,%esp
  802672:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802677:	eb 23                	jmp    80269c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802679:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80267c:	8b 52 18             	mov    0x18(%edx),%edx
  80267f:	85 d2                	test   %edx,%edx
  802681:	74 14                	je     802697 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802683:	83 ec 08             	sub    $0x8,%esp
  802686:	ff 75 0c             	pushl  0xc(%ebp)
  802689:	50                   	push   %eax
  80268a:	ff d2                	call   *%edx
  80268c:	89 c2                	mov    %eax,%edx
  80268e:	83 c4 10             	add    $0x10,%esp
  802691:	eb 09                	jmp    80269c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802693:	89 c2                	mov    %eax,%edx
  802695:	eb 05                	jmp    80269c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802697:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80269c:	89 d0                	mov    %edx,%eax
  80269e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026a1:	c9                   	leave  
  8026a2:	c3                   	ret    

008026a3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8026a3:	55                   	push   %ebp
  8026a4:	89 e5                	mov    %esp,%ebp
  8026a6:	53                   	push   %ebx
  8026a7:	83 ec 14             	sub    $0x14,%esp
  8026aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8026ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026b0:	50                   	push   %eax
  8026b1:	ff 75 08             	pushl  0x8(%ebp)
  8026b4:	e8 6c fb ff ff       	call   802225 <fd_lookup>
  8026b9:	83 c4 08             	add    $0x8,%esp
  8026bc:	89 c2                	mov    %eax,%edx
  8026be:	85 c0                	test   %eax,%eax
  8026c0:	78 58                	js     80271a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8026c2:	83 ec 08             	sub    $0x8,%esp
  8026c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026c8:	50                   	push   %eax
  8026c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026cc:	ff 30                	pushl  (%eax)
  8026ce:	e8 a8 fb ff ff       	call   80227b <dev_lookup>
  8026d3:	83 c4 10             	add    $0x10,%esp
  8026d6:	85 c0                	test   %eax,%eax
  8026d8:	78 37                	js     802711 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8026da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026dd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8026e1:	74 32                	je     802715 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8026e3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8026e6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8026ed:	00 00 00 
	stat->st_isdir = 0;
  8026f0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8026f7:	00 00 00 
	stat->st_dev = dev;
  8026fa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802700:	83 ec 08             	sub    $0x8,%esp
  802703:	53                   	push   %ebx
  802704:	ff 75 f0             	pushl  -0x10(%ebp)
  802707:	ff 50 14             	call   *0x14(%eax)
  80270a:	89 c2                	mov    %eax,%edx
  80270c:	83 c4 10             	add    $0x10,%esp
  80270f:	eb 09                	jmp    80271a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802711:	89 c2                	mov    %eax,%edx
  802713:	eb 05                	jmp    80271a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802715:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80271a:	89 d0                	mov    %edx,%eax
  80271c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80271f:	c9                   	leave  
  802720:	c3                   	ret    

00802721 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802721:	55                   	push   %ebp
  802722:	89 e5                	mov    %esp,%ebp
  802724:	56                   	push   %esi
  802725:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802726:	83 ec 08             	sub    $0x8,%esp
  802729:	6a 00                	push   $0x0
  80272b:	ff 75 08             	pushl  0x8(%ebp)
  80272e:	e8 b7 01 00 00       	call   8028ea <open>
  802733:	89 c3                	mov    %eax,%ebx
  802735:	83 c4 10             	add    $0x10,%esp
  802738:	85 c0                	test   %eax,%eax
  80273a:	78 1b                	js     802757 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80273c:	83 ec 08             	sub    $0x8,%esp
  80273f:	ff 75 0c             	pushl  0xc(%ebp)
  802742:	50                   	push   %eax
  802743:	e8 5b ff ff ff       	call   8026a3 <fstat>
  802748:	89 c6                	mov    %eax,%esi
	close(fd);
  80274a:	89 1c 24             	mov    %ebx,(%esp)
  80274d:	e8 fd fb ff ff       	call   80234f <close>
	return r;
  802752:	83 c4 10             	add    $0x10,%esp
  802755:	89 f0                	mov    %esi,%eax
}
  802757:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80275a:	5b                   	pop    %ebx
  80275b:	5e                   	pop    %esi
  80275c:	5d                   	pop    %ebp
  80275d:	c3                   	ret    

0080275e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80275e:	55                   	push   %ebp
  80275f:	89 e5                	mov    %esp,%ebp
  802761:	56                   	push   %esi
  802762:	53                   	push   %ebx
  802763:	89 c6                	mov    %eax,%esi
  802765:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802767:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80276e:	75 12                	jne    802782 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802770:	83 ec 0c             	sub    $0xc,%esp
  802773:	6a 01                	push   $0x1
  802775:	e8 fc f9 ff ff       	call   802176 <ipc_find_env>
  80277a:	a3 00 90 80 00       	mov    %eax,0x809000
  80277f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802782:	6a 07                	push   $0x7
  802784:	68 00 a0 80 00       	push   $0x80a000
  802789:	56                   	push   %esi
  80278a:	ff 35 00 90 80 00    	pushl  0x809000
  802790:	e8 8d f9 ff ff       	call   802122 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802795:	83 c4 0c             	add    $0xc,%esp
  802798:	6a 00                	push   $0x0
  80279a:	53                   	push   %ebx
  80279b:	6a 00                	push   $0x0
  80279d:	e8 0b f9 ff ff       	call   8020ad <ipc_recv>
}
  8027a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027a5:	5b                   	pop    %ebx
  8027a6:	5e                   	pop    %esi
  8027a7:	5d                   	pop    %ebp
  8027a8:	c3                   	ret    

008027a9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8027a9:	55                   	push   %ebp
  8027aa:	89 e5                	mov    %esp,%ebp
  8027ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8027af:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8027b5:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  8027ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027bd:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8027c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8027c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8027cc:	e8 8d ff ff ff       	call   80275e <fsipc>
}
  8027d1:	c9                   	leave  
  8027d2:	c3                   	ret    

008027d3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8027d3:	55                   	push   %ebp
  8027d4:	89 e5                	mov    %esp,%ebp
  8027d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8027d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8027dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8027df:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  8027e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8027e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8027ee:	e8 6b ff ff ff       	call   80275e <fsipc>
}
  8027f3:	c9                   	leave  
  8027f4:	c3                   	ret    

008027f5 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8027f5:	55                   	push   %ebp
  8027f6:	89 e5                	mov    %esp,%ebp
  8027f8:	53                   	push   %ebx
  8027f9:	83 ec 04             	sub    $0x4,%esp
  8027fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8027ff:	8b 45 08             	mov    0x8(%ebp),%eax
  802802:	8b 40 0c             	mov    0xc(%eax),%eax
  802805:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80280a:	ba 00 00 00 00       	mov    $0x0,%edx
  80280f:	b8 05 00 00 00       	mov    $0x5,%eax
  802814:	e8 45 ff ff ff       	call   80275e <fsipc>
  802819:	85 c0                	test   %eax,%eax
  80281b:	78 2c                	js     802849 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80281d:	83 ec 08             	sub    $0x8,%esp
  802820:	68 00 a0 80 00       	push   $0x80a000
  802825:	53                   	push   %ebx
  802826:	e8 1e f2 ff ff       	call   801a49 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80282b:	a1 80 a0 80 00       	mov    0x80a080,%eax
  802830:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802836:	a1 84 a0 80 00       	mov    0x80a084,%eax
  80283b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802841:	83 c4 10             	add    $0x10,%esp
  802844:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802849:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80284c:	c9                   	leave  
  80284d:	c3                   	ret    

0080284e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80284e:	55                   	push   %ebp
  80284f:	89 e5                	mov    %esp,%ebp
  802851:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802854:	68 94 3a 80 00       	push   $0x803a94
  802859:	68 90 00 00 00       	push   $0x90
  80285e:	68 b2 3a 80 00       	push   $0x803ab2
  802863:	e8 dc ea ff ff       	call   801344 <_panic>

00802868 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802868:	55                   	push   %ebp
  802869:	89 e5                	mov    %esp,%ebp
  80286b:	56                   	push   %esi
  80286c:	53                   	push   %ebx
  80286d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802870:	8b 45 08             	mov    0x8(%ebp),%eax
  802873:	8b 40 0c             	mov    0xc(%eax),%eax
  802876:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  80287b:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802881:	ba 00 00 00 00       	mov    $0x0,%edx
  802886:	b8 03 00 00 00       	mov    $0x3,%eax
  80288b:	e8 ce fe ff ff       	call   80275e <fsipc>
  802890:	89 c3                	mov    %eax,%ebx
  802892:	85 c0                	test   %eax,%eax
  802894:	78 4b                	js     8028e1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802896:	39 c6                	cmp    %eax,%esi
  802898:	73 16                	jae    8028b0 <devfile_read+0x48>
  80289a:	68 bd 3a 80 00       	push   $0x803abd
  80289f:	68 7d 31 80 00       	push   $0x80317d
  8028a4:	6a 7c                	push   $0x7c
  8028a6:	68 b2 3a 80 00       	push   $0x803ab2
  8028ab:	e8 94 ea ff ff       	call   801344 <_panic>
	assert(r <= PGSIZE);
  8028b0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8028b5:	7e 16                	jle    8028cd <devfile_read+0x65>
  8028b7:	68 c4 3a 80 00       	push   $0x803ac4
  8028bc:	68 7d 31 80 00       	push   $0x80317d
  8028c1:	6a 7d                	push   $0x7d
  8028c3:	68 b2 3a 80 00       	push   $0x803ab2
  8028c8:	e8 77 ea ff ff       	call   801344 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8028cd:	83 ec 04             	sub    $0x4,%esp
  8028d0:	50                   	push   %eax
  8028d1:	68 00 a0 80 00       	push   $0x80a000
  8028d6:	ff 75 0c             	pushl  0xc(%ebp)
  8028d9:	e8 fd f2 ff ff       	call   801bdb <memmove>
	return r;
  8028de:	83 c4 10             	add    $0x10,%esp
}
  8028e1:	89 d8                	mov    %ebx,%eax
  8028e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028e6:	5b                   	pop    %ebx
  8028e7:	5e                   	pop    %esi
  8028e8:	5d                   	pop    %ebp
  8028e9:	c3                   	ret    

008028ea <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8028ea:	55                   	push   %ebp
  8028eb:	89 e5                	mov    %esp,%ebp
  8028ed:	53                   	push   %ebx
  8028ee:	83 ec 20             	sub    $0x20,%esp
  8028f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8028f4:	53                   	push   %ebx
  8028f5:	e8 16 f1 ff ff       	call   801a10 <strlen>
  8028fa:	83 c4 10             	add    $0x10,%esp
  8028fd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802902:	7f 67                	jg     80296b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802904:	83 ec 0c             	sub    $0xc,%esp
  802907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80290a:	50                   	push   %eax
  80290b:	e8 c6 f8 ff ff       	call   8021d6 <fd_alloc>
  802910:	83 c4 10             	add    $0x10,%esp
		return r;
  802913:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802915:	85 c0                	test   %eax,%eax
  802917:	78 57                	js     802970 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802919:	83 ec 08             	sub    $0x8,%esp
  80291c:	53                   	push   %ebx
  80291d:	68 00 a0 80 00       	push   $0x80a000
  802922:	e8 22 f1 ff ff       	call   801a49 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80292a:	a3 00 a4 80 00       	mov    %eax,0x80a400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80292f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802932:	b8 01 00 00 00       	mov    $0x1,%eax
  802937:	e8 22 fe ff ff       	call   80275e <fsipc>
  80293c:	89 c3                	mov    %eax,%ebx
  80293e:	83 c4 10             	add    $0x10,%esp
  802941:	85 c0                	test   %eax,%eax
  802943:	79 14                	jns    802959 <open+0x6f>
		fd_close(fd, 0);
  802945:	83 ec 08             	sub    $0x8,%esp
  802948:	6a 00                	push   $0x0
  80294a:	ff 75 f4             	pushl  -0xc(%ebp)
  80294d:	e8 7c f9 ff ff       	call   8022ce <fd_close>
		return r;
  802952:	83 c4 10             	add    $0x10,%esp
  802955:	89 da                	mov    %ebx,%edx
  802957:	eb 17                	jmp    802970 <open+0x86>
	}

	return fd2num(fd);
  802959:	83 ec 0c             	sub    $0xc,%esp
  80295c:	ff 75 f4             	pushl  -0xc(%ebp)
  80295f:	e8 4b f8 ff ff       	call   8021af <fd2num>
  802964:	89 c2                	mov    %eax,%edx
  802966:	83 c4 10             	add    $0x10,%esp
  802969:	eb 05                	jmp    802970 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80296b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802970:	89 d0                	mov    %edx,%eax
  802972:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802975:	c9                   	leave  
  802976:	c3                   	ret    

00802977 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802977:	55                   	push   %ebp
  802978:	89 e5                	mov    %esp,%ebp
  80297a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80297d:	ba 00 00 00 00       	mov    $0x0,%edx
  802982:	b8 08 00 00 00       	mov    $0x8,%eax
  802987:	e8 d2 fd ff ff       	call   80275e <fsipc>
}
  80298c:	c9                   	leave  
  80298d:	c3                   	ret    

0080298e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80298e:	55                   	push   %ebp
  80298f:	89 e5                	mov    %esp,%ebp
  802991:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802994:	89 d0                	mov    %edx,%eax
  802996:	c1 e8 16             	shr    $0x16,%eax
  802999:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029a0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029a5:	f6 c1 01             	test   $0x1,%cl
  8029a8:	74 1d                	je     8029c7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029aa:	c1 ea 0c             	shr    $0xc,%edx
  8029ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029b4:	f6 c2 01             	test   $0x1,%dl
  8029b7:	74 0e                	je     8029c7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029b9:	c1 ea 0c             	shr    $0xc,%edx
  8029bc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029c3:	ef 
  8029c4:	0f b7 c0             	movzwl %ax,%eax
}
  8029c7:	5d                   	pop    %ebp
  8029c8:	c3                   	ret    

008029c9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8029c9:	55                   	push   %ebp
  8029ca:	89 e5                	mov    %esp,%ebp
  8029cc:	56                   	push   %esi
  8029cd:	53                   	push   %ebx
  8029ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8029d1:	83 ec 0c             	sub    $0xc,%esp
  8029d4:	ff 75 08             	pushl  0x8(%ebp)
  8029d7:	e8 e3 f7 ff ff       	call   8021bf <fd2data>
  8029dc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8029de:	83 c4 08             	add    $0x8,%esp
  8029e1:	68 d0 3a 80 00       	push   $0x803ad0
  8029e6:	53                   	push   %ebx
  8029e7:	e8 5d f0 ff ff       	call   801a49 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8029ec:	8b 46 04             	mov    0x4(%esi),%eax
  8029ef:	2b 06                	sub    (%esi),%eax
  8029f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8029f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8029fe:	00 00 00 
	stat->st_dev = &devpipe;
  802a01:	c7 83 88 00 00 00 80 	movl   $0x808080,0x88(%ebx)
  802a08:	80 80 00 
	return 0;
}
  802a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  802a10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a13:	5b                   	pop    %ebx
  802a14:	5e                   	pop    %esi
  802a15:	5d                   	pop    %ebp
  802a16:	c3                   	ret    

00802a17 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a17:	55                   	push   %ebp
  802a18:	89 e5                	mov    %esp,%ebp
  802a1a:	53                   	push   %ebx
  802a1b:	83 ec 0c             	sub    $0xc,%esp
  802a1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a21:	53                   	push   %ebx
  802a22:	6a 00                	push   $0x0
  802a24:	e8 a8 f4 ff ff       	call   801ed1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a29:	89 1c 24             	mov    %ebx,(%esp)
  802a2c:	e8 8e f7 ff ff       	call   8021bf <fd2data>
  802a31:	83 c4 08             	add    $0x8,%esp
  802a34:	50                   	push   %eax
  802a35:	6a 00                	push   $0x0
  802a37:	e8 95 f4 ff ff       	call   801ed1 <sys_page_unmap>
}
  802a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a3f:	c9                   	leave  
  802a40:	c3                   	ret    

00802a41 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802a41:	55                   	push   %ebp
  802a42:	89 e5                	mov    %esp,%ebp
  802a44:	57                   	push   %edi
  802a45:	56                   	push   %esi
  802a46:	53                   	push   %ebx
  802a47:	83 ec 1c             	sub    $0x1c,%esp
  802a4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802a4d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802a4f:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802a54:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802a57:	83 ec 0c             	sub    $0xc,%esp
  802a5a:	ff 75 e0             	pushl  -0x20(%ebp)
  802a5d:	e8 2c ff ff ff       	call   80298e <pageref>
  802a62:	89 c3                	mov    %eax,%ebx
  802a64:	89 3c 24             	mov    %edi,(%esp)
  802a67:	e8 22 ff ff ff       	call   80298e <pageref>
  802a6c:	83 c4 10             	add    $0x10,%esp
  802a6f:	39 c3                	cmp    %eax,%ebx
  802a71:	0f 94 c1             	sete   %cl
  802a74:	0f b6 c9             	movzbl %cl,%ecx
  802a77:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802a7a:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802a80:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802a83:	39 ce                	cmp    %ecx,%esi
  802a85:	74 1b                	je     802aa2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802a87:	39 c3                	cmp    %eax,%ebx
  802a89:	75 c4                	jne    802a4f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802a8b:	8b 42 58             	mov    0x58(%edx),%eax
  802a8e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a91:	50                   	push   %eax
  802a92:	56                   	push   %esi
  802a93:	68 d7 3a 80 00       	push   $0x803ad7
  802a98:	e8 80 e9 ff ff       	call   80141d <cprintf>
  802a9d:	83 c4 10             	add    $0x10,%esp
  802aa0:	eb ad                	jmp    802a4f <_pipeisclosed+0xe>
	}
}
  802aa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802aa8:	5b                   	pop    %ebx
  802aa9:	5e                   	pop    %esi
  802aaa:	5f                   	pop    %edi
  802aab:	5d                   	pop    %ebp
  802aac:	c3                   	ret    

00802aad <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802aad:	55                   	push   %ebp
  802aae:	89 e5                	mov    %esp,%ebp
  802ab0:	57                   	push   %edi
  802ab1:	56                   	push   %esi
  802ab2:	53                   	push   %ebx
  802ab3:	83 ec 28             	sub    $0x28,%esp
  802ab6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ab9:	56                   	push   %esi
  802aba:	e8 00 f7 ff ff       	call   8021bf <fd2data>
  802abf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ac1:	83 c4 10             	add    $0x10,%esp
  802ac4:	bf 00 00 00 00       	mov    $0x0,%edi
  802ac9:	eb 4b                	jmp    802b16 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802acb:	89 da                	mov    %ebx,%edx
  802acd:	89 f0                	mov    %esi,%eax
  802acf:	e8 6d ff ff ff       	call   802a41 <_pipeisclosed>
  802ad4:	85 c0                	test   %eax,%eax
  802ad6:	75 48                	jne    802b20 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802ad8:	e8 50 f3 ff ff       	call   801e2d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802add:	8b 43 04             	mov    0x4(%ebx),%eax
  802ae0:	8b 0b                	mov    (%ebx),%ecx
  802ae2:	8d 51 20             	lea    0x20(%ecx),%edx
  802ae5:	39 d0                	cmp    %edx,%eax
  802ae7:	73 e2                	jae    802acb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802aec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802af0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802af3:	89 c2                	mov    %eax,%edx
  802af5:	c1 fa 1f             	sar    $0x1f,%edx
  802af8:	89 d1                	mov    %edx,%ecx
  802afa:	c1 e9 1b             	shr    $0x1b,%ecx
  802afd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802b00:	83 e2 1f             	and    $0x1f,%edx
  802b03:	29 ca                	sub    %ecx,%edx
  802b05:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802b09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b0d:	83 c0 01             	add    $0x1,%eax
  802b10:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b13:	83 c7 01             	add    $0x1,%edi
  802b16:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802b19:	75 c2                	jne    802add <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  802b1e:	eb 05                	jmp    802b25 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b20:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b28:	5b                   	pop    %ebx
  802b29:	5e                   	pop    %esi
  802b2a:	5f                   	pop    %edi
  802b2b:	5d                   	pop    %ebp
  802b2c:	c3                   	ret    

00802b2d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b2d:	55                   	push   %ebp
  802b2e:	89 e5                	mov    %esp,%ebp
  802b30:	57                   	push   %edi
  802b31:	56                   	push   %esi
  802b32:	53                   	push   %ebx
  802b33:	83 ec 18             	sub    $0x18,%esp
  802b36:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802b39:	57                   	push   %edi
  802b3a:	e8 80 f6 ff ff       	call   8021bf <fd2data>
  802b3f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b41:	83 c4 10             	add    $0x10,%esp
  802b44:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b49:	eb 3d                	jmp    802b88 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b4b:	85 db                	test   %ebx,%ebx
  802b4d:	74 04                	je     802b53 <devpipe_read+0x26>
				return i;
  802b4f:	89 d8                	mov    %ebx,%eax
  802b51:	eb 44                	jmp    802b97 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b53:	89 f2                	mov    %esi,%edx
  802b55:	89 f8                	mov    %edi,%eax
  802b57:	e8 e5 fe ff ff       	call   802a41 <_pipeisclosed>
  802b5c:	85 c0                	test   %eax,%eax
  802b5e:	75 32                	jne    802b92 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802b60:	e8 c8 f2 ff ff       	call   801e2d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802b65:	8b 06                	mov    (%esi),%eax
  802b67:	3b 46 04             	cmp    0x4(%esi),%eax
  802b6a:	74 df                	je     802b4b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802b6c:	99                   	cltd   
  802b6d:	c1 ea 1b             	shr    $0x1b,%edx
  802b70:	01 d0                	add    %edx,%eax
  802b72:	83 e0 1f             	and    $0x1f,%eax
  802b75:	29 d0                	sub    %edx,%eax
  802b77:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b7f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802b82:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b85:	83 c3 01             	add    $0x1,%ebx
  802b88:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802b8b:	75 d8                	jne    802b65 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802b8d:	8b 45 10             	mov    0x10(%ebp),%eax
  802b90:	eb 05                	jmp    802b97 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b92:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b9a:	5b                   	pop    %ebx
  802b9b:	5e                   	pop    %esi
  802b9c:	5f                   	pop    %edi
  802b9d:	5d                   	pop    %ebp
  802b9e:	c3                   	ret    

00802b9f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802b9f:	55                   	push   %ebp
  802ba0:	89 e5                	mov    %esp,%ebp
  802ba2:	56                   	push   %esi
  802ba3:	53                   	push   %ebx
  802ba4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802ba7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802baa:	50                   	push   %eax
  802bab:	e8 26 f6 ff ff       	call   8021d6 <fd_alloc>
  802bb0:	83 c4 10             	add    $0x10,%esp
  802bb3:	89 c2                	mov    %eax,%edx
  802bb5:	85 c0                	test   %eax,%eax
  802bb7:	0f 88 2c 01 00 00    	js     802ce9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bbd:	83 ec 04             	sub    $0x4,%esp
  802bc0:	68 07 04 00 00       	push   $0x407
  802bc5:	ff 75 f4             	pushl  -0xc(%ebp)
  802bc8:	6a 00                	push   $0x0
  802bca:	e8 7d f2 ff ff       	call   801e4c <sys_page_alloc>
  802bcf:	83 c4 10             	add    $0x10,%esp
  802bd2:	89 c2                	mov    %eax,%edx
  802bd4:	85 c0                	test   %eax,%eax
  802bd6:	0f 88 0d 01 00 00    	js     802ce9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802bdc:	83 ec 0c             	sub    $0xc,%esp
  802bdf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802be2:	50                   	push   %eax
  802be3:	e8 ee f5 ff ff       	call   8021d6 <fd_alloc>
  802be8:	89 c3                	mov    %eax,%ebx
  802bea:	83 c4 10             	add    $0x10,%esp
  802bed:	85 c0                	test   %eax,%eax
  802bef:	0f 88 e2 00 00 00    	js     802cd7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bf5:	83 ec 04             	sub    $0x4,%esp
  802bf8:	68 07 04 00 00       	push   $0x407
  802bfd:	ff 75 f0             	pushl  -0x10(%ebp)
  802c00:	6a 00                	push   $0x0
  802c02:	e8 45 f2 ff ff       	call   801e4c <sys_page_alloc>
  802c07:	89 c3                	mov    %eax,%ebx
  802c09:	83 c4 10             	add    $0x10,%esp
  802c0c:	85 c0                	test   %eax,%eax
  802c0e:	0f 88 c3 00 00 00    	js     802cd7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c14:	83 ec 0c             	sub    $0xc,%esp
  802c17:	ff 75 f4             	pushl  -0xc(%ebp)
  802c1a:	e8 a0 f5 ff ff       	call   8021bf <fd2data>
  802c1f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c21:	83 c4 0c             	add    $0xc,%esp
  802c24:	68 07 04 00 00       	push   $0x407
  802c29:	50                   	push   %eax
  802c2a:	6a 00                	push   $0x0
  802c2c:	e8 1b f2 ff ff       	call   801e4c <sys_page_alloc>
  802c31:	89 c3                	mov    %eax,%ebx
  802c33:	83 c4 10             	add    $0x10,%esp
  802c36:	85 c0                	test   %eax,%eax
  802c38:	0f 88 89 00 00 00    	js     802cc7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c3e:	83 ec 0c             	sub    $0xc,%esp
  802c41:	ff 75 f0             	pushl  -0x10(%ebp)
  802c44:	e8 76 f5 ff ff       	call   8021bf <fd2data>
  802c49:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802c50:	50                   	push   %eax
  802c51:	6a 00                	push   $0x0
  802c53:	56                   	push   %esi
  802c54:	6a 00                	push   $0x0
  802c56:	e8 34 f2 ff ff       	call   801e8f <sys_page_map>
  802c5b:	89 c3                	mov    %eax,%ebx
  802c5d:	83 c4 20             	add    $0x20,%esp
  802c60:	85 c0                	test   %eax,%eax
  802c62:	78 55                	js     802cb9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802c64:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c6d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c72:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802c79:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c82:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c87:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802c8e:	83 ec 0c             	sub    $0xc,%esp
  802c91:	ff 75 f4             	pushl  -0xc(%ebp)
  802c94:	e8 16 f5 ff ff       	call   8021af <fd2num>
  802c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c9c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802c9e:	83 c4 04             	add    $0x4,%esp
  802ca1:	ff 75 f0             	pushl  -0x10(%ebp)
  802ca4:	e8 06 f5 ff ff       	call   8021af <fd2num>
  802ca9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802cac:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802caf:	83 c4 10             	add    $0x10,%esp
  802cb2:	ba 00 00 00 00       	mov    $0x0,%edx
  802cb7:	eb 30                	jmp    802ce9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802cb9:	83 ec 08             	sub    $0x8,%esp
  802cbc:	56                   	push   %esi
  802cbd:	6a 00                	push   $0x0
  802cbf:	e8 0d f2 ff ff       	call   801ed1 <sys_page_unmap>
  802cc4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802cc7:	83 ec 08             	sub    $0x8,%esp
  802cca:	ff 75 f0             	pushl  -0x10(%ebp)
  802ccd:	6a 00                	push   $0x0
  802ccf:	e8 fd f1 ff ff       	call   801ed1 <sys_page_unmap>
  802cd4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802cd7:	83 ec 08             	sub    $0x8,%esp
  802cda:	ff 75 f4             	pushl  -0xc(%ebp)
  802cdd:	6a 00                	push   $0x0
  802cdf:	e8 ed f1 ff ff       	call   801ed1 <sys_page_unmap>
  802ce4:	83 c4 10             	add    $0x10,%esp
  802ce7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802ce9:	89 d0                	mov    %edx,%eax
  802ceb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802cee:	5b                   	pop    %ebx
  802cef:	5e                   	pop    %esi
  802cf0:	5d                   	pop    %ebp
  802cf1:	c3                   	ret    

00802cf2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802cf2:	55                   	push   %ebp
  802cf3:	89 e5                	mov    %esp,%ebp
  802cf5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cfb:	50                   	push   %eax
  802cfc:	ff 75 08             	pushl  0x8(%ebp)
  802cff:	e8 21 f5 ff ff       	call   802225 <fd_lookup>
  802d04:	83 c4 10             	add    $0x10,%esp
  802d07:	85 c0                	test   %eax,%eax
  802d09:	78 18                	js     802d23 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d0b:	83 ec 0c             	sub    $0xc,%esp
  802d0e:	ff 75 f4             	pushl  -0xc(%ebp)
  802d11:	e8 a9 f4 ff ff       	call   8021bf <fd2data>
	return _pipeisclosed(fd, p);
  802d16:	89 c2                	mov    %eax,%edx
  802d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d1b:	e8 21 fd ff ff       	call   802a41 <_pipeisclosed>
  802d20:	83 c4 10             	add    $0x10,%esp
}
  802d23:	c9                   	leave  
  802d24:	c3                   	ret    

00802d25 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802d25:	55                   	push   %ebp
  802d26:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802d28:	b8 00 00 00 00       	mov    $0x0,%eax
  802d2d:	5d                   	pop    %ebp
  802d2e:	c3                   	ret    

00802d2f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802d2f:	55                   	push   %ebp
  802d30:	89 e5                	mov    %esp,%ebp
  802d32:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802d35:	68 ef 3a 80 00       	push   $0x803aef
  802d3a:	ff 75 0c             	pushl  0xc(%ebp)
  802d3d:	e8 07 ed ff ff       	call   801a49 <strcpy>
	return 0;
}
  802d42:	b8 00 00 00 00       	mov    $0x0,%eax
  802d47:	c9                   	leave  
  802d48:	c3                   	ret    

00802d49 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802d49:	55                   	push   %ebp
  802d4a:	89 e5                	mov    %esp,%ebp
  802d4c:	57                   	push   %edi
  802d4d:	56                   	push   %esi
  802d4e:	53                   	push   %ebx
  802d4f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d55:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802d5a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d60:	eb 2d                	jmp    802d8f <devcons_write+0x46>
		m = n - tot;
  802d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802d65:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802d67:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802d6a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802d6f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802d72:	83 ec 04             	sub    $0x4,%esp
  802d75:	53                   	push   %ebx
  802d76:	03 45 0c             	add    0xc(%ebp),%eax
  802d79:	50                   	push   %eax
  802d7a:	57                   	push   %edi
  802d7b:	e8 5b ee ff ff       	call   801bdb <memmove>
		sys_cputs(buf, m);
  802d80:	83 c4 08             	add    $0x8,%esp
  802d83:	53                   	push   %ebx
  802d84:	57                   	push   %edi
  802d85:	e8 06 f0 ff ff       	call   801d90 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d8a:	01 de                	add    %ebx,%esi
  802d8c:	83 c4 10             	add    $0x10,%esp
  802d8f:	89 f0                	mov    %esi,%eax
  802d91:	3b 75 10             	cmp    0x10(%ebp),%esi
  802d94:	72 cc                	jb     802d62 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d99:	5b                   	pop    %ebx
  802d9a:	5e                   	pop    %esi
  802d9b:	5f                   	pop    %edi
  802d9c:	5d                   	pop    %ebp
  802d9d:	c3                   	ret    

00802d9e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802d9e:	55                   	push   %ebp
  802d9f:	89 e5                	mov    %esp,%ebp
  802da1:	83 ec 08             	sub    $0x8,%esp
  802da4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802da9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802dad:	74 2a                	je     802dd9 <devcons_read+0x3b>
  802daf:	eb 05                	jmp    802db6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802db1:	e8 77 f0 ff ff       	call   801e2d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802db6:	e8 f3 ef ff ff       	call   801dae <sys_cgetc>
  802dbb:	85 c0                	test   %eax,%eax
  802dbd:	74 f2                	je     802db1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802dbf:	85 c0                	test   %eax,%eax
  802dc1:	78 16                	js     802dd9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802dc3:	83 f8 04             	cmp    $0x4,%eax
  802dc6:	74 0c                	je     802dd4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  802dcb:	88 02                	mov    %al,(%edx)
	return 1;
  802dcd:	b8 01 00 00 00       	mov    $0x1,%eax
  802dd2:	eb 05                	jmp    802dd9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802dd9:	c9                   	leave  
  802dda:	c3                   	ret    

00802ddb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802ddb:	55                   	push   %ebp
  802ddc:	89 e5                	mov    %esp,%ebp
  802dde:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802de1:	8b 45 08             	mov    0x8(%ebp),%eax
  802de4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802de7:	6a 01                	push   $0x1
  802de9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802dec:	50                   	push   %eax
  802ded:	e8 9e ef ff ff       	call   801d90 <sys_cputs>
}
  802df2:	83 c4 10             	add    $0x10,%esp
  802df5:	c9                   	leave  
  802df6:	c3                   	ret    

00802df7 <getchar>:

int
getchar(void)
{
  802df7:	55                   	push   %ebp
  802df8:	89 e5                	mov    %esp,%ebp
  802dfa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802dfd:	6a 01                	push   $0x1
  802dff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802e02:	50                   	push   %eax
  802e03:	6a 00                	push   $0x0
  802e05:	e8 81 f6 ff ff       	call   80248b <read>
	if (r < 0)
  802e0a:	83 c4 10             	add    $0x10,%esp
  802e0d:	85 c0                	test   %eax,%eax
  802e0f:	78 0f                	js     802e20 <getchar+0x29>
		return r;
	if (r < 1)
  802e11:	85 c0                	test   %eax,%eax
  802e13:	7e 06                	jle    802e1b <getchar+0x24>
		return -E_EOF;
	return c;
  802e15:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802e19:	eb 05                	jmp    802e20 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802e1b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802e20:	c9                   	leave  
  802e21:	c3                   	ret    

00802e22 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802e22:	55                   	push   %ebp
  802e23:	89 e5                	mov    %esp,%ebp
  802e25:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e2b:	50                   	push   %eax
  802e2c:	ff 75 08             	pushl  0x8(%ebp)
  802e2f:	e8 f1 f3 ff ff       	call   802225 <fd_lookup>
  802e34:	83 c4 10             	add    $0x10,%esp
  802e37:	85 c0                	test   %eax,%eax
  802e39:	78 11                	js     802e4c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e3e:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  802e44:	39 10                	cmp    %edx,(%eax)
  802e46:	0f 94 c0             	sete   %al
  802e49:	0f b6 c0             	movzbl %al,%eax
}
  802e4c:	c9                   	leave  
  802e4d:	c3                   	ret    

00802e4e <opencons>:

int
opencons(void)
{
  802e4e:	55                   	push   %ebp
  802e4f:	89 e5                	mov    %esp,%ebp
  802e51:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802e54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e57:	50                   	push   %eax
  802e58:	e8 79 f3 ff ff       	call   8021d6 <fd_alloc>
  802e5d:	83 c4 10             	add    $0x10,%esp
		return r;
  802e60:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802e62:	85 c0                	test   %eax,%eax
  802e64:	78 3e                	js     802ea4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802e66:	83 ec 04             	sub    $0x4,%esp
  802e69:	68 07 04 00 00       	push   $0x407
  802e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  802e71:	6a 00                	push   $0x0
  802e73:	e8 d4 ef ff ff       	call   801e4c <sys_page_alloc>
  802e78:	83 c4 10             	add    $0x10,%esp
		return r;
  802e7b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802e7d:	85 c0                	test   %eax,%eax
  802e7f:	78 23                	js     802ea4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802e81:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  802e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e8a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802e96:	83 ec 0c             	sub    $0xc,%esp
  802e99:	50                   	push   %eax
  802e9a:	e8 10 f3 ff ff       	call   8021af <fd2num>
  802e9f:	89 c2                	mov    %eax,%edx
  802ea1:	83 c4 10             	add    $0x10,%esp
}
  802ea4:	89 d0                	mov    %edx,%eax
  802ea6:	c9                   	leave  
  802ea7:	c3                   	ret    
  802ea8:	66 90                	xchg   %ax,%ax
  802eaa:	66 90                	xchg   %ax,%ax
  802eac:	66 90                	xchg   %ax,%ax
  802eae:	66 90                	xchg   %ax,%ax

00802eb0 <__udivdi3>:
  802eb0:	55                   	push   %ebp
  802eb1:	57                   	push   %edi
  802eb2:	56                   	push   %esi
  802eb3:	53                   	push   %ebx
  802eb4:	83 ec 1c             	sub    $0x1c,%esp
  802eb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802ebb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802ebf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ec7:	85 f6                	test   %esi,%esi
  802ec9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ecd:	89 ca                	mov    %ecx,%edx
  802ecf:	89 f8                	mov    %edi,%eax
  802ed1:	75 3d                	jne    802f10 <__udivdi3+0x60>
  802ed3:	39 cf                	cmp    %ecx,%edi
  802ed5:	0f 87 c5 00 00 00    	ja     802fa0 <__udivdi3+0xf0>
  802edb:	85 ff                	test   %edi,%edi
  802edd:	89 fd                	mov    %edi,%ebp
  802edf:	75 0b                	jne    802eec <__udivdi3+0x3c>
  802ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  802ee6:	31 d2                	xor    %edx,%edx
  802ee8:	f7 f7                	div    %edi
  802eea:	89 c5                	mov    %eax,%ebp
  802eec:	89 c8                	mov    %ecx,%eax
  802eee:	31 d2                	xor    %edx,%edx
  802ef0:	f7 f5                	div    %ebp
  802ef2:	89 c1                	mov    %eax,%ecx
  802ef4:	89 d8                	mov    %ebx,%eax
  802ef6:	89 cf                	mov    %ecx,%edi
  802ef8:	f7 f5                	div    %ebp
  802efa:	89 c3                	mov    %eax,%ebx
  802efc:	89 d8                	mov    %ebx,%eax
  802efe:	89 fa                	mov    %edi,%edx
  802f00:	83 c4 1c             	add    $0x1c,%esp
  802f03:	5b                   	pop    %ebx
  802f04:	5e                   	pop    %esi
  802f05:	5f                   	pop    %edi
  802f06:	5d                   	pop    %ebp
  802f07:	c3                   	ret    
  802f08:	90                   	nop
  802f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802f10:	39 ce                	cmp    %ecx,%esi
  802f12:	77 74                	ja     802f88 <__udivdi3+0xd8>
  802f14:	0f bd fe             	bsr    %esi,%edi
  802f17:	83 f7 1f             	xor    $0x1f,%edi
  802f1a:	0f 84 98 00 00 00    	je     802fb8 <__udivdi3+0x108>
  802f20:	bb 20 00 00 00       	mov    $0x20,%ebx
  802f25:	89 f9                	mov    %edi,%ecx
  802f27:	89 c5                	mov    %eax,%ebp
  802f29:	29 fb                	sub    %edi,%ebx
  802f2b:	d3 e6                	shl    %cl,%esi
  802f2d:	89 d9                	mov    %ebx,%ecx
  802f2f:	d3 ed                	shr    %cl,%ebp
  802f31:	89 f9                	mov    %edi,%ecx
  802f33:	d3 e0                	shl    %cl,%eax
  802f35:	09 ee                	or     %ebp,%esi
  802f37:	89 d9                	mov    %ebx,%ecx
  802f39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802f3d:	89 d5                	mov    %edx,%ebp
  802f3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802f43:	d3 ed                	shr    %cl,%ebp
  802f45:	89 f9                	mov    %edi,%ecx
  802f47:	d3 e2                	shl    %cl,%edx
  802f49:	89 d9                	mov    %ebx,%ecx
  802f4b:	d3 e8                	shr    %cl,%eax
  802f4d:	09 c2                	or     %eax,%edx
  802f4f:	89 d0                	mov    %edx,%eax
  802f51:	89 ea                	mov    %ebp,%edx
  802f53:	f7 f6                	div    %esi
  802f55:	89 d5                	mov    %edx,%ebp
  802f57:	89 c3                	mov    %eax,%ebx
  802f59:	f7 64 24 0c          	mull   0xc(%esp)
  802f5d:	39 d5                	cmp    %edx,%ebp
  802f5f:	72 10                	jb     802f71 <__udivdi3+0xc1>
  802f61:	8b 74 24 08          	mov    0x8(%esp),%esi
  802f65:	89 f9                	mov    %edi,%ecx
  802f67:	d3 e6                	shl    %cl,%esi
  802f69:	39 c6                	cmp    %eax,%esi
  802f6b:	73 07                	jae    802f74 <__udivdi3+0xc4>
  802f6d:	39 d5                	cmp    %edx,%ebp
  802f6f:	75 03                	jne    802f74 <__udivdi3+0xc4>
  802f71:	83 eb 01             	sub    $0x1,%ebx
  802f74:	31 ff                	xor    %edi,%edi
  802f76:	89 d8                	mov    %ebx,%eax
  802f78:	89 fa                	mov    %edi,%edx
  802f7a:	83 c4 1c             	add    $0x1c,%esp
  802f7d:	5b                   	pop    %ebx
  802f7e:	5e                   	pop    %esi
  802f7f:	5f                   	pop    %edi
  802f80:	5d                   	pop    %ebp
  802f81:	c3                   	ret    
  802f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802f88:	31 ff                	xor    %edi,%edi
  802f8a:	31 db                	xor    %ebx,%ebx
  802f8c:	89 d8                	mov    %ebx,%eax
  802f8e:	89 fa                	mov    %edi,%edx
  802f90:	83 c4 1c             	add    $0x1c,%esp
  802f93:	5b                   	pop    %ebx
  802f94:	5e                   	pop    %esi
  802f95:	5f                   	pop    %edi
  802f96:	5d                   	pop    %ebp
  802f97:	c3                   	ret    
  802f98:	90                   	nop
  802f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802fa0:	89 d8                	mov    %ebx,%eax
  802fa2:	f7 f7                	div    %edi
  802fa4:	31 ff                	xor    %edi,%edi
  802fa6:	89 c3                	mov    %eax,%ebx
  802fa8:	89 d8                	mov    %ebx,%eax
  802faa:	89 fa                	mov    %edi,%edx
  802fac:	83 c4 1c             	add    $0x1c,%esp
  802faf:	5b                   	pop    %ebx
  802fb0:	5e                   	pop    %esi
  802fb1:	5f                   	pop    %edi
  802fb2:	5d                   	pop    %ebp
  802fb3:	c3                   	ret    
  802fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802fb8:	39 ce                	cmp    %ecx,%esi
  802fba:	72 0c                	jb     802fc8 <__udivdi3+0x118>
  802fbc:	31 db                	xor    %ebx,%ebx
  802fbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802fc2:	0f 87 34 ff ff ff    	ja     802efc <__udivdi3+0x4c>
  802fc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  802fcd:	e9 2a ff ff ff       	jmp    802efc <__udivdi3+0x4c>
  802fd2:	66 90                	xchg   %ax,%ax
  802fd4:	66 90                	xchg   %ax,%ax
  802fd6:	66 90                	xchg   %ax,%ax
  802fd8:	66 90                	xchg   %ax,%ax
  802fda:	66 90                	xchg   %ax,%ax
  802fdc:	66 90                	xchg   %ax,%ax
  802fde:	66 90                	xchg   %ax,%ax

00802fe0 <__umoddi3>:
  802fe0:	55                   	push   %ebp
  802fe1:	57                   	push   %edi
  802fe2:	56                   	push   %esi
  802fe3:	53                   	push   %ebx
  802fe4:	83 ec 1c             	sub    $0x1c,%esp
  802fe7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802feb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802fef:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ff7:	85 d2                	test   %edx,%edx
  802ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803001:	89 f3                	mov    %esi,%ebx
  803003:	89 3c 24             	mov    %edi,(%esp)
  803006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80300a:	75 1c                	jne    803028 <__umoddi3+0x48>
  80300c:	39 f7                	cmp    %esi,%edi
  80300e:	76 50                	jbe    803060 <__umoddi3+0x80>
  803010:	89 c8                	mov    %ecx,%eax
  803012:	89 f2                	mov    %esi,%edx
  803014:	f7 f7                	div    %edi
  803016:	89 d0                	mov    %edx,%eax
  803018:	31 d2                	xor    %edx,%edx
  80301a:	83 c4 1c             	add    $0x1c,%esp
  80301d:	5b                   	pop    %ebx
  80301e:	5e                   	pop    %esi
  80301f:	5f                   	pop    %edi
  803020:	5d                   	pop    %ebp
  803021:	c3                   	ret    
  803022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803028:	39 f2                	cmp    %esi,%edx
  80302a:	89 d0                	mov    %edx,%eax
  80302c:	77 52                	ja     803080 <__umoddi3+0xa0>
  80302e:	0f bd ea             	bsr    %edx,%ebp
  803031:	83 f5 1f             	xor    $0x1f,%ebp
  803034:	75 5a                	jne    803090 <__umoddi3+0xb0>
  803036:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80303a:	0f 82 e0 00 00 00    	jb     803120 <__umoddi3+0x140>
  803040:	39 0c 24             	cmp    %ecx,(%esp)
  803043:	0f 86 d7 00 00 00    	jbe    803120 <__umoddi3+0x140>
  803049:	8b 44 24 08          	mov    0x8(%esp),%eax
  80304d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803051:	83 c4 1c             	add    $0x1c,%esp
  803054:	5b                   	pop    %ebx
  803055:	5e                   	pop    %esi
  803056:	5f                   	pop    %edi
  803057:	5d                   	pop    %ebp
  803058:	c3                   	ret    
  803059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803060:	85 ff                	test   %edi,%edi
  803062:	89 fd                	mov    %edi,%ebp
  803064:	75 0b                	jne    803071 <__umoddi3+0x91>
  803066:	b8 01 00 00 00       	mov    $0x1,%eax
  80306b:	31 d2                	xor    %edx,%edx
  80306d:	f7 f7                	div    %edi
  80306f:	89 c5                	mov    %eax,%ebp
  803071:	89 f0                	mov    %esi,%eax
  803073:	31 d2                	xor    %edx,%edx
  803075:	f7 f5                	div    %ebp
  803077:	89 c8                	mov    %ecx,%eax
  803079:	f7 f5                	div    %ebp
  80307b:	89 d0                	mov    %edx,%eax
  80307d:	eb 99                	jmp    803018 <__umoddi3+0x38>
  80307f:	90                   	nop
  803080:	89 c8                	mov    %ecx,%eax
  803082:	89 f2                	mov    %esi,%edx
  803084:	83 c4 1c             	add    $0x1c,%esp
  803087:	5b                   	pop    %ebx
  803088:	5e                   	pop    %esi
  803089:	5f                   	pop    %edi
  80308a:	5d                   	pop    %ebp
  80308b:	c3                   	ret    
  80308c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803090:	8b 34 24             	mov    (%esp),%esi
  803093:	bf 20 00 00 00       	mov    $0x20,%edi
  803098:	89 e9                	mov    %ebp,%ecx
  80309a:	29 ef                	sub    %ebp,%edi
  80309c:	d3 e0                	shl    %cl,%eax
  80309e:	89 f9                	mov    %edi,%ecx
  8030a0:	89 f2                	mov    %esi,%edx
  8030a2:	d3 ea                	shr    %cl,%edx
  8030a4:	89 e9                	mov    %ebp,%ecx
  8030a6:	09 c2                	or     %eax,%edx
  8030a8:	89 d8                	mov    %ebx,%eax
  8030aa:	89 14 24             	mov    %edx,(%esp)
  8030ad:	89 f2                	mov    %esi,%edx
  8030af:	d3 e2                	shl    %cl,%edx
  8030b1:	89 f9                	mov    %edi,%ecx
  8030b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8030b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8030bb:	d3 e8                	shr    %cl,%eax
  8030bd:	89 e9                	mov    %ebp,%ecx
  8030bf:	89 c6                	mov    %eax,%esi
  8030c1:	d3 e3                	shl    %cl,%ebx
  8030c3:	89 f9                	mov    %edi,%ecx
  8030c5:	89 d0                	mov    %edx,%eax
  8030c7:	d3 e8                	shr    %cl,%eax
  8030c9:	89 e9                	mov    %ebp,%ecx
  8030cb:	09 d8                	or     %ebx,%eax
  8030cd:	89 d3                	mov    %edx,%ebx
  8030cf:	89 f2                	mov    %esi,%edx
  8030d1:	f7 34 24             	divl   (%esp)
  8030d4:	89 d6                	mov    %edx,%esi
  8030d6:	d3 e3                	shl    %cl,%ebx
  8030d8:	f7 64 24 04          	mull   0x4(%esp)
  8030dc:	39 d6                	cmp    %edx,%esi
  8030de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030e2:	89 d1                	mov    %edx,%ecx
  8030e4:	89 c3                	mov    %eax,%ebx
  8030e6:	72 08                	jb     8030f0 <__umoddi3+0x110>
  8030e8:	75 11                	jne    8030fb <__umoddi3+0x11b>
  8030ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8030ee:	73 0b                	jae    8030fb <__umoddi3+0x11b>
  8030f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8030f4:	1b 14 24             	sbb    (%esp),%edx
  8030f7:	89 d1                	mov    %edx,%ecx
  8030f9:	89 c3                	mov    %eax,%ebx
  8030fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8030ff:	29 da                	sub    %ebx,%edx
  803101:	19 ce                	sbb    %ecx,%esi
  803103:	89 f9                	mov    %edi,%ecx
  803105:	89 f0                	mov    %esi,%eax
  803107:	d3 e0                	shl    %cl,%eax
  803109:	89 e9                	mov    %ebp,%ecx
  80310b:	d3 ea                	shr    %cl,%edx
  80310d:	89 e9                	mov    %ebp,%ecx
  80310f:	d3 ee                	shr    %cl,%esi
  803111:	09 d0                	or     %edx,%eax
  803113:	89 f2                	mov    %esi,%edx
  803115:	83 c4 1c             	add    $0x1c,%esp
  803118:	5b                   	pop    %ebx
  803119:	5e                   	pop    %esi
  80311a:	5f                   	pop    %edi
  80311b:	5d                   	pop    %ebp
  80311c:	c3                   	ret    
  80311d:	8d 76 00             	lea    0x0(%esi),%esi
  803120:	29 f9                	sub    %edi,%ecx
  803122:	19 d6                	sbb    %edx,%esi
  803124:	89 74 24 04          	mov    %esi,0x4(%esp)
  803128:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80312c:	e9 18 ff ff ff       	jmp    803049 <__umoddi3+0x69>
