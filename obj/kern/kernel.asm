
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 1e 21 f0    	mov    %esi,0xf0211e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 8a 5c 00 00       	call   f0105ceb <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 63 10 f0       	push   $0xf0106380
f010006d:	e8 49 36 00 00       	call   f01036bb <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 19 36 00 00       	call   f0103695 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 63 75 10 f0 	movl   $0xf0107563,(%esp)
f0100083:	e8 33 36 00 00       	call   f01036bb <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 ac 08 00 00       	call   f0100941 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 30 25 f0       	mov    $0xf0253008,%eax
f01000a6:	2d 3c 07 21 f0       	sub    $0xf021073c,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 3c 07 21 f0       	push   $0xf021073c
f01000b3:	e8 01 56 00 00       	call   f01056b9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 96 05 00 00       	call   f0100653 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ec 63 10 f0       	push   $0xf01063ec
f01000ca:	e8 ec 35 00 00       	call   f01036bb <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 5e 12 00 00       	call   f0101332 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 78 2e 00 00       	call   f0102f51 <env_init>
	trap_init();
f01000d9:	e8 d0 36 00 00       	call   f01037ae <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 ed 58 00 00       	call   f01059d0 <mp_init>
	lapic_init();
f01000e3:	e8 1e 5c 00 00       	call   f0105d06 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 f5 34 00 00       	call   f01035e2 <pic_init>

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 60 5e 00 00       	call   f0105f59 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 1e 21 f0 07 	cmpl   $0x7,0xf0211e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 a4 63 10 f0       	push   $0xf01063a4
f010010f:	6a 5a                	push   $0x5a
f0100111:	68 07 64 10 f0       	push   $0xf0106407
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 36 59 10 f0       	mov    $0xf0105936,%eax
f0100123:	2d bc 58 10 f0       	sub    $0xf01058bc,%eax
f0100128:	50                   	push   %eax
f0100129:	68 bc 58 10 f0       	push   $0xf01058bc
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 ce 55 00 00       	call   f0105706 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 20 21 f0       	mov    $0xf0212020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 a4 5b 00 00       	call   f0105ceb <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 20 21 f0       	add    $0xf0212020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 20 21 f0       	sub    $0xf0212020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 b0 21 f0       	add    $0xf021b000,%eax
f010016b:	a3 84 1e 21 f0       	mov    %eax,0xf0211e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 d3 5c 00 00       	call   f0105e54 <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0100196:	05 20 20 21 f0       	add    $0xf0212020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 24 16 1d f0       	push   $0xf01d1624
f01001a9:	e8 39 2f 00 00       	call   f01030e7 <env_create>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 7c c7 1c f0       	push   $0xf01cc77c
f01001b8:	e8 2a 2f 00 00       	call   f01030e7 <env_create>
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 35 04 00 00       	call   f01005f7 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 89 42 00 00       	call   f0104450 <sched_yield>

f01001c7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001cd:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 c8 63 10 f0       	push   $0xf01063c8
f01001df:	6a 71                	push   $0x71
f01001e1:	68 07 64 10 f0       	push   $0xf0106407
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 f3 5a 00 00       	call   f0105ceb <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 13 64 10 f0       	push   $0xf0106413
f0100201:	e8 b5 34 00 00       	call   f01036bb <cprintf>

	lapic_init();
f0100206:	e8 fb 5a 00 00       	call   f0105d06 <lapic_init>
	env_init_percpu();
f010020b:	e8 11 2d 00 00       	call   f0102f21 <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 ba 34 00 00       	call   f01036cf <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 d1 5a 00 00       	call   f0105ceb <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	// Now that we have finished some basic setup, call sched_yield()
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	spin_lock(&kernel_lock);
f010022c:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100233:	e8 21 5d 00 00       	call   f0105f59 <spin_lock>
	sched_yield();
f0100238:	e8 13 42 00 00       	call   f0104450 <sched_yield>

f010023d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	53                   	push   %ebx
f0100241:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100244:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100247:	ff 75 0c             	pushl  0xc(%ebp)
f010024a:	ff 75 08             	pushl  0x8(%ebp)
f010024d:	68 29 64 10 f0       	push   $0xf0106429
f0100252:	e8 64 34 00 00       	call   f01036bb <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 32 34 00 00       	call   f0103695 <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 63 75 10 f0 	movl   $0xf0107563,(%esp)
f010026a:	e8 4c 34 00 00       	call   f01036bb <cprintf>
	va_end(ap);
}
f010026f:	83 c4 10             	add    $0x10,%esp
f0100272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100275:	c9                   	leave  
f0100276:	c3                   	ret    

f0100277 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100277:	55                   	push   %ebp
f0100278:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010027f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100280:	a8 01                	test   $0x1,%al
f0100282:	74 0b                	je     f010028f <serial_proc_data+0x18>
f0100284:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100289:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028a:	0f b6 c0             	movzbl %al,%eax
f010028d:	eb 05                	jmp    f0100294 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010028f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100294:	5d                   	pop    %ebp
f0100295:	c3                   	ret    

f0100296 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100296:	55                   	push   %ebp
f0100297:	89 e5                	mov    %esp,%ebp
f0100299:	53                   	push   %ebx
f010029a:	83 ec 04             	sub    $0x4,%esp
f010029d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010029f:	eb 2b                	jmp    f01002cc <cons_intr+0x36>
		if (c == 0)
f01002a1:	85 c0                	test   %eax,%eax
f01002a3:	74 27                	je     f01002cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a5:	8b 0d 24 12 21 f0    	mov    0xf0211224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 12 21 f0    	mov    %edx,0xf0211224
f01002b4:	88 81 20 10 21 f0    	mov    %al,-0xfdeefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 12 21 f0 00 	movl   $0x0,0xf0211224
f01002c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002cc:	ff d3                	call   *%ebx
f01002ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d1:	75 ce                	jne    f01002a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d3:	83 c4 04             	add    $0x4,%esp
f01002d6:	5b                   	pop    %ebx
f01002d7:	5d                   	pop    %ebp
f01002d8:	c3                   	ret    

f01002d9 <kbd_proc_data>:
f01002d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002df:	a8 01                	test   $0x1,%al
f01002e1:	0f 84 f8 00 00 00    	je     f01003df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002e7:	a8 20                	test   $0x20,%al
f01002e9:	0f 85 f6 00 00 00    	jne    f01003e5 <kbd_proc_data+0x10c>
f01002ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01002f4:	ec                   	in     (%dx),%al
f01002f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002f7:	3c e0                	cmp    $0xe0,%al
f01002f9:	75 0d                	jne    f0100308 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002fb:	83 0d 00 10 21 f0 40 	orl    $0x40,0xf0211000
		return 0;
f0100302:	b8 00 00 00 00       	mov    $0x0,%eax
f0100307:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100308:	55                   	push   %ebp
f0100309:	89 e5                	mov    %esp,%ebp
f010030b:	53                   	push   %ebx
f010030c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010030f:	84 c0                	test   %al,%al
f0100311:	79 36                	jns    f0100349 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100313:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100319:	89 cb                	mov    %ecx,%ebx
f010031b:	83 e3 40             	and    $0x40,%ebx
f010031e:	83 e0 7f             	and    $0x7f,%eax
f0100321:	85 db                	test   %ebx,%ebx
f0100323:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 a0 65 10 f0 	movzbl -0xfef9a60(%edx),%eax
f0100330:	83 c8 40             	or     $0x40,%eax
f0100333:	0f b6 c0             	movzbl %al,%eax
f0100336:	f7 d0                	not    %eax
f0100338:	21 c8                	and    %ecx,%eax
f010033a:	a3 00 10 21 f0       	mov    %eax,0xf0211000
		return 0;
f010033f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100344:	e9 a4 00 00 00       	jmp    f01003ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100349:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f010034f:	f6 c1 40             	test   $0x40,%cl
f0100352:	74 0e                	je     f0100362 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100354:	83 c8 80             	or     $0xffffff80,%eax
f0100357:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100359:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035c:	89 0d 00 10 21 f0    	mov    %ecx,0xf0211000
	}

	shift |= shiftcode[data];
f0100362:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100365:	0f b6 82 a0 65 10 f0 	movzbl -0xfef9a60(%edx),%eax
f010036c:	0b 05 00 10 21 f0    	or     0xf0211000,%eax
f0100372:	0f b6 8a a0 64 10 f0 	movzbl -0xfef9b60(%edx),%ecx
f0100379:	31 c8                	xor    %ecx,%eax
f010037b:	a3 00 10 21 f0       	mov    %eax,0xf0211000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100380:	89 c1                	mov    %eax,%ecx
f0100382:	83 e1 03             	and    $0x3,%ecx
f0100385:	8b 0c 8d 80 64 10 f0 	mov    -0xfef9b80(,%ecx,4),%ecx
f010038c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100390:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100393:	a8 08                	test   $0x8,%al
f0100395:	74 1b                	je     f01003b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100397:	89 da                	mov    %ebx,%edx
f0100399:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010039c:	83 f9 19             	cmp    $0x19,%ecx
f010039f:	77 05                	ja     f01003a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003a1:	83 eb 20             	sub    $0x20,%ebx
f01003a4:	eb 0c                	jmp    f01003b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ac:	83 fa 19             	cmp    $0x19,%edx
f01003af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003b2:	f7 d0                	not    %eax
f01003b4:	a8 06                	test   $0x6,%al
f01003b6:	75 33                	jne    f01003eb <kbd_proc_data+0x112>
f01003b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003be:	75 2b                	jne    f01003eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003c0:	83 ec 0c             	sub    $0xc,%esp
f01003c3:	68 43 64 10 f0       	push   $0xf0106443
f01003c8:	e8 ee 32 00 00       	call   f01036bb <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01003d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01003d7:	ee                   	out    %al,(%dx)
f01003d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003db:	89 d8                	mov    %ebx,%eax
f01003dd:	eb 0e                	jmp    f01003ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003eb:	89 d8                	mov    %ebx,%eax
}
f01003ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003f0:	c9                   	leave  
f01003f1:	c3                   	ret    

f01003f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003f2:	55                   	push   %ebp
f01003f3:	89 e5                	mov    %esp,%ebp
f01003f5:	57                   	push   %edi
f01003f6:	56                   	push   %esi
f01003f7:	53                   	push   %ebx
f01003f8:	83 ec 1c             	sub    $0x1c,%esp
f01003fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100402:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100407:	b9 84 00 00 00       	mov    $0x84,%ecx
f010040c:	eb 09                	jmp    f0100417 <cons_putc+0x25>
f010040e:	89 ca                	mov    %ecx,%edx
f0100410:	ec                   	in     (%dx),%al
f0100411:	ec                   	in     (%dx),%al
f0100412:	ec                   	in     (%dx),%al
f0100413:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100414:	83 c3 01             	add    $0x1,%ebx
f0100417:	89 f2                	mov    %esi,%edx
f0100419:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010041a:	a8 20                	test   $0x20,%al
f010041c:	75 08                	jne    f0100426 <cons_putc+0x34>
f010041e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100424:	7e e8                	jle    f010040e <cons_putc+0x1c>
f0100426:	89 f8                	mov    %edi,%eax
f0100428:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100430:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100431:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100436:	be 79 03 00 00       	mov    $0x379,%esi
f010043b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100440:	eb 09                	jmp    f010044b <cons_putc+0x59>
f0100442:	89 ca                	mov    %ecx,%edx
f0100444:	ec                   	in     (%dx),%al
f0100445:	ec                   	in     (%dx),%al
f0100446:	ec                   	in     (%dx),%al
f0100447:	ec                   	in     (%dx),%al
f0100448:	83 c3 01             	add    $0x1,%ebx
f010044b:	89 f2                	mov    %esi,%edx
f010044d:	ec                   	in     (%dx),%al
f010044e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100454:	7f 04                	jg     f010045a <cons_putc+0x68>
f0100456:	84 c0                	test   %al,%al
f0100458:	79 e8                	jns    f0100442 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045a:	ba 78 03 00 00       	mov    $0x378,%edx
f010045f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100463:	ee                   	out    %al,(%dx)
f0100464:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100469:	b8 0d 00 00 00       	mov    $0xd,%eax
f010046e:	ee                   	out    %al,(%dx)
f010046f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100474:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100475:	89 fa                	mov    %edi,%edx
f0100477:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010047d:	89 f8                	mov    %edi,%eax
f010047f:	80 cc 07             	or     $0x7,%ah
f0100482:	85 d2                	test   %edx,%edx
f0100484:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100487:	89 f8                	mov    %edi,%eax
f0100489:	0f b6 c0             	movzbl %al,%eax
f010048c:	83 f8 09             	cmp    $0x9,%eax
f010048f:	74 74                	je     f0100505 <cons_putc+0x113>
f0100491:	83 f8 09             	cmp    $0x9,%eax
f0100494:	7f 0a                	jg     f01004a0 <cons_putc+0xae>
f0100496:	83 f8 08             	cmp    $0x8,%eax
f0100499:	74 14                	je     f01004af <cons_putc+0xbd>
f010049b:	e9 99 00 00 00       	jmp    f0100539 <cons_putc+0x147>
f01004a0:	83 f8 0a             	cmp    $0xa,%eax
f01004a3:	74 3a                	je     f01004df <cons_putc+0xed>
f01004a5:	83 f8 0d             	cmp    $0xd,%eax
f01004a8:	74 3d                	je     f01004e7 <cons_putc+0xf5>
f01004aa:	e9 8a 00 00 00       	jmp    f0100539 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004af:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004b6:	66 85 c0             	test   %ax,%ax
f01004b9:	0f 84 e6 00 00 00    	je     f01005a5 <cons_putc+0x1b3>
			crt_pos--;
f01004bf:	83 e8 01             	sub    $0x1,%eax
f01004c2:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c8:	0f b7 c0             	movzwl %ax,%eax
f01004cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d0:	83 cf 20             	or     $0x20,%edi
f01004d3:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f01004d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004dd:	eb 78                	jmp    f0100557 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004df:	66 83 05 28 12 21 f0 	addw   $0x50,0xf0211228
f01004e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e7:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f4:	c1 e8 16             	shr    $0x16,%eax
f01004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fa:	c1 e0 04             	shl    $0x4,%eax
f01004fd:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
f0100503:	eb 52                	jmp    f0100557 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100505:	b8 20 00 00 00       	mov    $0x20,%eax
f010050a:	e8 e3 fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f010050f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100514:	e8 d9 fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f0100519:	b8 20 00 00 00       	mov    $0x20,%eax
f010051e:	e8 cf fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f0100523:	b8 20 00 00 00       	mov    $0x20,%eax
f0100528:	e8 c5 fe ff ff       	call   f01003f2 <cons_putc>
		cons_putc(' ');
f010052d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100532:	e8 bb fe ff ff       	call   f01003f2 <cons_putc>
f0100537:	eb 1e                	jmp    f0100557 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100539:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f0100540:	8d 50 01             	lea    0x1(%eax),%edx
f0100543:	66 89 15 28 12 21 f0 	mov    %dx,0xf0211228
f010054a:	0f b7 c0             	movzwl %ax,%eax
f010054d:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f0100553:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// Move all the content 1 line upward
	if (crt_pos >= CRT_SIZE) {
f0100557:	66 81 3d 28 12 21 f0 	cmpw   $0x7cf,0xf0211228
f010055e:	cf 07 
f0100560:	76 43                	jbe    f01005a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100562:	a1 2c 12 21 f0       	mov    0xf021122c,%eax
f0100567:	83 ec 04             	sub    $0x4,%esp
f010056a:	68 00 0f 00 00       	push   $0xf00
f010056f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100575:	52                   	push   %edx
f0100576:	50                   	push   %eax
f0100577:	e8 8a 51 00 00       	call   f0105706 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057c:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f0100582:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100588:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010058e:	83 c4 10             	add    $0x10,%esp
f0100591:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100596:	83 c0 02             	add    $0x2,%eax
	// Move all the content 1 line upward
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100599:	39 d0                	cmp    %edx,%eax
f010059b:	75 f4                	jne    f0100591 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010059d:	66 83 2d 28 12 21 f0 	subw   $0x50,0xf0211228
f01005a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a5:	8b 0d 30 12 21 f0    	mov    0xf0211230,%ecx
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 ca                	mov    %ecx,%edx
f01005b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b3:	0f b7 1d 28 12 21 f0 	movzwl 0xf0211228,%ebx
f01005ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01005bd:	89 d8                	mov    %ebx,%eax
f01005bf:	66 c1 e8 08          	shr    $0x8,%ax
f01005c3:	89 f2                	mov    %esi,%edx
f01005c5:	ee                   	out    %al,(%dx)
f01005c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005cb:	89 ca                	mov    %ecx,%edx
f01005cd:	ee                   	out    %al,(%dx)
f01005ce:	89 d8                	mov    %ebx,%eax
f01005d0:	89 f2                	mov    %esi,%edx
f01005d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005d6:	5b                   	pop    %ebx
f01005d7:	5e                   	pop    %esi
f01005d8:	5f                   	pop    %edi
f01005d9:	5d                   	pop    %ebp
f01005da:	c3                   	ret    

f01005db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005db:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f01005e2:	74 11                	je     f01005f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005e4:	55                   	push   %ebp
f01005e5:	89 e5                	mov    %esp,%ebp
f01005e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005ea:	b8 77 02 10 f0       	mov    $0xf0100277,%eax
f01005ef:	e8 a2 fc ff ff       	call   f0100296 <cons_intr>
}
f01005f4:	c9                   	leave  
f01005f5:	f3 c3                	repz ret 

f01005f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005f7:	55                   	push   %ebp
f01005f8:	89 e5                	mov    %esp,%ebp
f01005fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005fd:	b8 d9 02 10 f0       	mov    $0xf01002d9,%eax
f0100602:	e8 8f fc ff ff       	call   f0100296 <cons_intr>
}
f0100607:	c9                   	leave  
f0100608:	c3                   	ret    

f0100609 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100609:	55                   	push   %ebp
f010060a:	89 e5                	mov    %esp,%ebp
f010060c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010060f:	e8 c7 ff ff ff       	call   f01005db <serial_intr>
	kbd_intr();
f0100614:	e8 de ff ff ff       	call   f01005f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100619:	a1 20 12 21 f0       	mov    0xf0211220,%eax
f010061e:	3b 05 24 12 21 f0    	cmp    0xf0211224,%eax
f0100624:	74 26                	je     f010064c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100626:	8d 50 01             	lea    0x1(%eax),%edx
f0100629:	89 15 20 12 21 f0    	mov    %edx,0xf0211220
f010062f:	0f b6 88 20 10 21 f0 	movzbl -0xfdeefe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100636:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100638:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010063e:	75 11                	jne    f0100651 <cons_getc+0x48>
			cons.rpos = 0;
f0100640:	c7 05 20 12 21 f0 00 	movl   $0x0,0xf0211220
f0100647:	00 00 00 
f010064a:	eb 05                	jmp    f0100651 <cons_getc+0x48>
		return c;
	}
	return 0;
f010064c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100651:	c9                   	leave  
f0100652:	c3                   	ret    

f0100653 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100653:	55                   	push   %ebp
f0100654:	89 e5                	mov    %esp,%ebp
f0100656:	57                   	push   %edi
f0100657:	56                   	push   %esi
f0100658:	53                   	push   %ebx
f0100659:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010065c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100663:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066a:	5a a5 
	if (*cp != 0xA55A) {
f010066c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100673:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100677:	74 11                	je     f010068a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100679:	c7 05 30 12 21 f0 b4 	movl   $0x3b4,0xf0211230
f0100680:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100683:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100688:	eb 16                	jmp    f01006a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010068a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100691:	c7 05 30 12 21 f0 d4 	movl   $0x3d4,0xf0211230
f0100698:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010069b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006a0:	8b 3d 30 12 21 f0    	mov    0xf0211230,%edi
f01006a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b1:	89 da                	mov    %ebx,%edx
f01006b3:	ec                   	in     (%dx),%al
f01006b4:	0f b6 c8             	movzbl %al,%ecx
f01006b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006bf:	89 fa                	mov    %edi,%edx
f01006c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c2:	89 da                	mov    %ebx,%edx
f01006c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006c5:	89 35 2c 12 21 f0    	mov    %esi,0xf021122c
	crt_pos = pos;
f01006cb:	0f b6 c0             	movzbl %al,%eax
f01006ce:	09 c8                	or     %ecx,%eax
f01006d0:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d6:	e8 1c ff ff ff       	call   f01005f7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006db:	83 ec 0c             	sub    $0xc,%esp
f01006de:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006e5:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ea:	50                   	push   %eax
f01006eb:	e8 7a 2e 00 00       	call   f010356a <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f0:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fa:	89 f2                	mov    %esi,%edx
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100702:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100707:	ee                   	out    %al,(%dx)
f0100708:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010070d:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100712:	89 da                	mov    %ebx,%edx
f0100714:	ee                   	out    %al,(%dx)
f0100715:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010071a:	b8 00 00 00 00       	mov    $0x0,%eax
f010071f:	ee                   	out    %al,(%dx)
f0100720:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100725:	b8 03 00 00 00       	mov    $0x3,%eax
f010072a:	ee                   	out    %al,(%dx)
f010072b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100730:	b8 00 00 00 00       	mov    $0x0,%eax
f0100735:	ee                   	out    %al,(%dx)
f0100736:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010073b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100740:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100741:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100746:	ec                   	in     (%dx),%al
f0100747:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100749:	83 c4 10             	add    $0x10,%esp
f010074c:	3c ff                	cmp    $0xff,%al
f010074e:	0f 95 05 34 12 21 f0 	setne  0xf0211234
f0100755:	89 f2                	mov    %esi,%edx
f0100757:	ec                   	in     (%dx),%al
f0100758:	89 da                	mov    %ebx,%edx
f010075a:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010075b:	80 f9 ff             	cmp    $0xff,%cl
f010075e:	74 21                	je     f0100781 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100760:	83 ec 0c             	sub    $0xc,%esp
f0100763:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010076a:	25 ef ff 00 00       	and    $0xffef,%eax
f010076f:	50                   	push   %eax
f0100770:	e8 f5 2d 00 00       	call   f010356a <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f010077f:	75 10                	jne    f0100791 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100781:	83 ec 0c             	sub    $0xc,%esp
f0100784:	68 4f 64 10 f0       	push   $0xf010644f
f0100789:	e8 2d 2f 00 00       	call   f01036bb <cprintf>
f010078e:	83 c4 10             	add    $0x10,%esp
}
f0100791:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100794:	5b                   	pop    %ebx
f0100795:	5e                   	pop    %esi
f0100796:	5f                   	pop    %edi
f0100797:	5d                   	pop    %ebp
f0100798:	c3                   	ret    

f0100799 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100799:	55                   	push   %ebp
f010079a:	89 e5                	mov    %esp,%ebp
f010079c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079f:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a2:	e8 4b fc ff ff       	call   f01003f2 <cons_putc>
}
f01007a7:	c9                   	leave  
f01007a8:	c3                   	ret    

f01007a9 <getchar>:

int
getchar(void)
{
f01007a9:	55                   	push   %ebp
f01007aa:	89 e5                	mov    %esp,%ebp
f01007ac:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007af:	e8 55 fe ff ff       	call   f0100609 <cons_getc>
f01007b4:	85 c0                	test   %eax,%eax
f01007b6:	74 f7                	je     f01007af <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b8:	c9                   	leave  
f01007b9:	c3                   	ret    

f01007ba <iscons>:

int
iscons(int fdnum)
{
f01007ba:	55                   	push   %ebp
f01007bb:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007bd:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c2:	5d                   	pop    %ebp
f01007c3:	c3                   	ret    

f01007c4 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c4:	55                   	push   %ebp
f01007c5:	89 e5                	mov    %esp,%ebp
f01007c7:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007ca:	68 a0 66 10 f0       	push   $0xf01066a0
f01007cf:	68 be 66 10 f0       	push   $0xf01066be
f01007d4:	68 c3 66 10 f0       	push   $0xf01066c3
f01007d9:	e8 dd 2e 00 00       	call   f01036bb <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 4c 67 10 f0       	push   $0xf010674c
f01007e6:	68 cc 66 10 f0       	push   $0xf01066cc
f01007eb:	68 c3 66 10 f0       	push   $0xf01066c3
f01007f0:	e8 c6 2e 00 00       	call   f01036bb <cprintf>
f01007f5:	83 c4 0c             	add    $0xc,%esp
f01007f8:	68 d5 66 10 f0       	push   $0xf01066d5
f01007fd:	68 ea 66 10 f0       	push   $0xf01066ea
f0100802:	68 c3 66 10 f0       	push   $0xf01066c3
f0100807:	e8 af 2e 00 00       	call   f01036bb <cprintf>
	return 0;
}
f010080c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100811:	c9                   	leave  
f0100812:	c3                   	ret    

f0100813 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100813:	55                   	push   %ebp
f0100814:	89 e5                	mov    %esp,%ebp
f0100816:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100819:	68 f4 66 10 f0       	push   $0xf01066f4
f010081e:	e8 98 2e 00 00       	call   f01036bb <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100823:	83 c4 08             	add    $0x8,%esp
f0100826:	68 0c 00 10 00       	push   $0x10000c
f010082b:	68 74 67 10 f0       	push   $0xf0106774
f0100830:	e8 86 2e 00 00       	call   f01036bb <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 0c 00 10 00       	push   $0x10000c
f010083d:	68 0c 00 10 f0       	push   $0xf010000c
f0100842:	68 9c 67 10 f0       	push   $0xf010679c
f0100847:	e8 6f 2e 00 00       	call   f01036bb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 71 63 10 00       	push   $0x106371
f0100854:	68 71 63 10 f0       	push   $0xf0106371
f0100859:	68 c0 67 10 f0       	push   $0xf01067c0
f010085e:	e8 58 2e 00 00       	call   f01036bb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 3c 07 21 00       	push   $0x21073c
f010086b:	68 3c 07 21 f0       	push   $0xf021073c
f0100870:	68 e4 67 10 f0       	push   $0xf01067e4
f0100875:	e8 41 2e 00 00       	call   f01036bb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087a:	83 c4 0c             	add    $0xc,%esp
f010087d:	68 08 30 25 00       	push   $0x253008
f0100882:	68 08 30 25 f0       	push   $0xf0253008
f0100887:	68 08 68 10 f0       	push   $0xf0106808
f010088c:	e8 2a 2e 00 00       	call   f01036bb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100891:	b8 07 34 25 f0       	mov    $0xf0253407,%eax
f0100896:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089b:	83 c4 08             	add    $0x8,%esp
f010089e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008a3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a9:	85 c0                	test   %eax,%eax
f01008ab:	0f 48 c2             	cmovs  %edx,%eax
f01008ae:	c1 f8 0a             	sar    $0xa,%eax
f01008b1:	50                   	push   %eax
f01008b2:	68 2c 68 10 f0       	push   $0xf010682c
f01008b7:	e8 ff 2d 00 00       	call   f01036bb <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c1:	c9                   	leave  
f01008c2:	c3                   	ret    

f01008c3 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c3:	55                   	push   %ebp
f01008c4:	89 e5                	mov    %esp,%ebp
f01008c6:	57                   	push   %edi
f01008c7:	56                   	push   %esi
f01008c8:	53                   	push   %ebx
f01008c9:	81 ec 2c 04 00 00    	sub    $0x42c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008cf:	89 eb                	mov    %ebp,%ebx
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
		eip = *(ebp + 1);
		debuginfo_eip(eip, &info);
		strncpy(fn_name, info.eip_fn_name, info.eip_fn_namelen);
f01008d1:	8d bd d0 fb ff ff    	lea    -0x430(%ebp),%edi
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t* ebp = (uint32_t*)read_ebp();
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
f01008d7:	eb 57                	jmp    f0100930 <mon_backtrace+0x6d>
		eip = *(ebp + 1);
f01008d9:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f01008dc:	83 ec 08             	sub    $0x8,%esp
f01008df:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008e2:	50                   	push   %eax
f01008e3:	56                   	push   %esi
f01008e4:	e8 a8 42 00 00       	call   f0104b91 <debuginfo_eip>
		strncpy(fn_name, info.eip_fn_name, info.eip_fn_namelen);
f01008e9:	83 c4 0c             	add    $0xc,%esp
f01008ec:	ff 75 dc             	pushl  -0x24(%ebp)
f01008ef:	ff 75 d8             	pushl  -0x28(%ebp)
f01008f2:	57                   	push   %edi
f01008f3:	e8 be 4c 00 00       	call   f01055b6 <strncpy>
		fn_name[info.eip_fn_namelen] = 0;
f01008f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01008fb:	c6 84 05 d0 fb ff ff 	movb   $0x0,-0x430(%ebp,%eax,1)
f0100902:	00 
		cprintf("ebp %x eip %x args %08d %08d %08d %08d %08d"
f0100903:	89 f0                	mov    %esi,%eax
f0100905:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100908:	50                   	push   %eax
f0100909:	57                   	push   %edi
f010090a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010090d:	ff 75 d0             	pushl  -0x30(%ebp)
f0100910:	ff 73 18             	pushl  0x18(%ebx)
f0100913:	ff 73 14             	pushl  0x14(%ebx)
f0100916:	ff 73 10             	pushl  0x10(%ebx)
f0100919:	ff 73 0c             	pushl  0xc(%ebx)
f010091c:	ff 73 08             	pushl  0x8(%ebx)
f010091f:	56                   	push   %esi
f0100920:	53                   	push   %ebx
f0100921:	68 58 68 10 f0       	push   $0xf0106858
f0100926:	e8 90 2d 00 00       	call   f01036bb <cprintf>
				" %s:%d: %s+%d\n", ebp, eip, *(ebp + 2), *(ebp + 3), 
				*(ebp + 4), *(ebp + 5), *(ebp + 6), info.eip_file, 
				info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t*)*ebp;
f010092b:	8b 1b                	mov    (%ebx),%ebx
f010092d:	83 c4 40             	add    $0x40,%esp
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t* ebp = (uint32_t*)read_ebp();
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
f0100930:	85 db                	test   %ebx,%ebx
f0100932:	75 a5                	jne    f01008d9 <mon_backtrace+0x16>
				*(ebp + 4), *(ebp + 5), *(ebp + 6), info.eip_file, 
				info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t*)*ebp;
	}
	return 0;
}
f0100934:	b8 00 00 00 00       	mov    $0x0,%eax
f0100939:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010093c:	5b                   	pop    %ebx
f010093d:	5e                   	pop    %esi
f010093e:	5f                   	pop    %edi
f010093f:	5d                   	pop    %ebp
f0100940:	c3                   	ret    

f0100941 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100941:	55                   	push   %ebp
f0100942:	89 e5                	mov    %esp,%ebp
f0100944:	57                   	push   %edi
f0100945:	56                   	push   %esi
f0100946:	53                   	push   %ebx
f0100947:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010094a:	68 94 68 10 f0       	push   $0xf0106894
f010094f:	e8 67 2d 00 00       	call   f01036bb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100954:	c7 04 24 b8 68 10 f0 	movl   $0xf01068b8,(%esp)
f010095b:	e8 5b 2d 00 00       	call   f01036bb <cprintf>

	if (tf != NULL)
f0100960:	83 c4 10             	add    $0x10,%esp
f0100963:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100967:	74 0e                	je     f0100977 <monitor+0x36>
		print_trapframe(tf);
f0100969:	83 ec 0c             	sub    $0xc,%esp
f010096c:	ff 75 08             	pushl  0x8(%ebp)
f010096f:	e8 33 33 00 00       	call   f0103ca7 <print_trapframe>
f0100974:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100977:	83 ec 0c             	sub    $0xc,%esp
f010097a:	68 0d 67 10 f0       	push   $0xf010670d
f010097f:	e8 c6 4a 00 00       	call   f010544a <readline>
f0100984:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100986:	83 c4 10             	add    $0x10,%esp
f0100989:	85 c0                	test   %eax,%eax
f010098b:	74 ea                	je     f0100977 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010098d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100994:	be 00 00 00 00       	mov    $0x0,%esi
f0100999:	eb 0a                	jmp    f01009a5 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010099b:	c6 03 00             	movb   $0x0,(%ebx)
f010099e:	89 f7                	mov    %esi,%edi
f01009a0:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009a3:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009a5:	0f b6 03             	movzbl (%ebx),%eax
f01009a8:	84 c0                	test   %al,%al
f01009aa:	74 63                	je     f0100a0f <monitor+0xce>
f01009ac:	83 ec 08             	sub    $0x8,%esp
f01009af:	0f be c0             	movsbl %al,%eax
f01009b2:	50                   	push   %eax
f01009b3:	68 11 67 10 f0       	push   $0xf0106711
f01009b8:	e8 bf 4c 00 00       	call   f010567c <strchr>
f01009bd:	83 c4 10             	add    $0x10,%esp
f01009c0:	85 c0                	test   %eax,%eax
f01009c2:	75 d7                	jne    f010099b <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009c4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009c7:	74 46                	je     f0100a0f <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009c9:	83 fe 0f             	cmp    $0xf,%esi
f01009cc:	75 14                	jne    f01009e2 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009ce:	83 ec 08             	sub    $0x8,%esp
f01009d1:	6a 10                	push   $0x10
f01009d3:	68 16 67 10 f0       	push   $0xf0106716
f01009d8:	e8 de 2c 00 00       	call   f01036bb <cprintf>
f01009dd:	83 c4 10             	add    $0x10,%esp
f01009e0:	eb 95                	jmp    f0100977 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009e2:	8d 7e 01             	lea    0x1(%esi),%edi
f01009e5:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009e9:	eb 03                	jmp    f01009ee <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009eb:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ee:	0f b6 03             	movzbl (%ebx),%eax
f01009f1:	84 c0                	test   %al,%al
f01009f3:	74 ae                	je     f01009a3 <monitor+0x62>
f01009f5:	83 ec 08             	sub    $0x8,%esp
f01009f8:	0f be c0             	movsbl %al,%eax
f01009fb:	50                   	push   %eax
f01009fc:	68 11 67 10 f0       	push   $0xf0106711
f0100a01:	e8 76 4c 00 00       	call   f010567c <strchr>
f0100a06:	83 c4 10             	add    $0x10,%esp
f0100a09:	85 c0                	test   %eax,%eax
f0100a0b:	74 de                	je     f01009eb <monitor+0xaa>
f0100a0d:	eb 94                	jmp    f01009a3 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a0f:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a16:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a17:	85 f6                	test   %esi,%esi
f0100a19:	0f 84 58 ff ff ff    	je     f0100977 <monitor+0x36>
f0100a1f:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a24:	83 ec 08             	sub    $0x8,%esp
f0100a27:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a2a:	ff 34 85 e0 68 10 f0 	pushl  -0xfef9720(,%eax,4)
f0100a31:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a34:	e8 e5 4b 00 00       	call   f010561e <strcmp>
f0100a39:	83 c4 10             	add    $0x10,%esp
f0100a3c:	85 c0                	test   %eax,%eax
f0100a3e:	75 21                	jne    f0100a61 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a40:	83 ec 04             	sub    $0x4,%esp
f0100a43:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a46:	ff 75 08             	pushl  0x8(%ebp)
f0100a49:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a4c:	52                   	push   %edx
f0100a4d:	56                   	push   %esi
f0100a4e:	ff 14 85 e8 68 10 f0 	call   *-0xfef9718(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a55:	83 c4 10             	add    $0x10,%esp
f0100a58:	85 c0                	test   %eax,%eax
f0100a5a:	78 25                	js     f0100a81 <monitor+0x140>
f0100a5c:	e9 16 ff ff ff       	jmp    f0100977 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a61:	83 c3 01             	add    $0x1,%ebx
f0100a64:	83 fb 03             	cmp    $0x3,%ebx
f0100a67:	75 bb                	jne    f0100a24 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a69:	83 ec 08             	sub    $0x8,%esp
f0100a6c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6f:	68 33 67 10 f0       	push   $0xf0106733
f0100a74:	e8 42 2c 00 00       	call   f01036bb <cprintf>
f0100a79:	83 c4 10             	add    $0x10,%esp
f0100a7c:	e9 f6 fe ff ff       	jmp    f0100977 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a81:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a84:	5b                   	pop    %ebx
f0100a85:	5e                   	pop    %esi
f0100a86:	5f                   	pop    %edi
f0100a87:	5d                   	pop    %ebp
f0100a88:	c3                   	ret    

f0100a89 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a89:	55                   	push   %ebp
f0100a8a:	89 e5                	mov    %esp,%ebp
f0100a8c:	56                   	push   %esi
f0100a8d:	53                   	push   %ebx
f0100a8e:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a90:	83 ec 0c             	sub    $0xc,%esp
f0100a93:	50                   	push   %eax
f0100a94:	e8 a3 2a 00 00       	call   f010353c <mc146818_read>
f0100a99:	89 c6                	mov    %eax,%esi
f0100a9b:	83 c3 01             	add    $0x1,%ebx
f0100a9e:	89 1c 24             	mov    %ebx,(%esp)
f0100aa1:	e8 96 2a 00 00       	call   f010353c <mc146818_read>
f0100aa6:	c1 e0 08             	shl    $0x8,%eax
f0100aa9:	09 f0                	or     %esi,%eax
}
f0100aab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100aae:	5b                   	pop    %ebx
f0100aaf:	5e                   	pop    %esi
f0100ab0:	5d                   	pop    %ebp
f0100ab1:	c3                   	ret    

f0100ab2 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ab2:	89 d1                	mov    %edx,%ecx
f0100ab4:	c1 e9 16             	shr    $0x16,%ecx
f0100ab7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100aba:	a8 01                	test   $0x1,%al
f0100abc:	74 52                	je     f0100b10 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100abe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ac3:	89 c1                	mov    %eax,%ecx
f0100ac5:	c1 e9 0c             	shr    $0xc,%ecx
f0100ac8:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0100ace:	72 1b                	jb     f0100aeb <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
f0100ad3:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad6:	50                   	push   %eax
f0100ad7:	68 a4 63 10 f0       	push   $0xf01063a4
f0100adc:	68 a2 03 00 00       	push   $0x3a2
f0100ae1:	68 45 72 10 f0       	push   $0xf0107245
f0100ae6:	e8 55 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100aeb:	c1 ea 0c             	shr    $0xc,%edx
f0100aee:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100af4:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100afb:	89 c2                	mov    %eax,%edx
f0100afd:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b05:	85 d2                	test   %edx,%edx
f0100b07:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b0c:	0f 44 c2             	cmove  %edx,%eax
f0100b0f:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b15:	c3                   	ret    

f0100b16 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b16:	55                   	push   %ebp
f0100b17:	89 e5                	mov    %esp,%ebp
f0100b19:	83 ec 08             	sub    $0x8,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b1c:	83 3d 38 12 21 f0 00 	cmpl   $0x0,0xf0211238
f0100b23:	75 11                	jne    f0100b36 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b25:	ba 07 40 25 f0       	mov    $0xf0254007,%edx
f0100b2a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b30:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0){
f0100b36:	85 c0                	test   %eax,%eax
f0100b38:	74 59                	je     f0100b93 <boot_alloc+0x7d>
		char* free = nextfree;
f0100b3a:	8b 0d 38 12 21 f0    	mov    0xf0211238,%ecx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100b40:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100b47:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b4d:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b53:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b59:	77 12                	ja     f0100b6d <boot_alloc+0x57>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b5b:	52                   	push   %edx
f0100b5c:	68 c8 63 10 f0       	push   $0xf01063c8
f0100b61:	6a 6f                	push   $0x6f
f0100b63:	68 45 72 10 f0       	push   $0xf0107245
f0100b68:	e8 d3 f4 ff ff       	call   f0100040 <_panic>
		if ((size_t)PADDR(nextfree) >= npages * PGSIZE) panic("boot_alloc: no enough memory");
f0100b6d:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0100b72:	c1 e0 0c             	shl    $0xc,%eax
f0100b75:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100b7b:	39 d0                	cmp    %edx,%eax
f0100b7d:	77 1b                	ja     f0100b9a <boot_alloc+0x84>
f0100b7f:	83 ec 04             	sub    $0x4,%esp
f0100b82:	68 51 72 10 f0       	push   $0xf0107251
f0100b87:	6a 6f                	push   $0x6f
f0100b89:	68 45 72 10 f0       	push   $0xf0107245
f0100b8e:	e8 ad f4 ff ff       	call   f0100040 <_panic>
		return (void*)free;
	}
	else {
		return (void*)nextfree;
f0100b93:	a1 38 12 21 f0       	mov    0xf0211238,%eax
f0100b98:	eb 02                	jmp    f0100b9c <boot_alloc+0x86>
	// LAB 2: Your code here.
	if (n > 0){
		char* free = nextfree;
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
		if ((size_t)PADDR(nextfree) >= npages * PGSIZE) panic("boot_alloc: no enough memory");
		return (void*)free;
f0100b9a:	89 c8                	mov    %ecx,%eax
	}
	else {
		return (void*)nextfree;
	}
}
f0100b9c:	c9                   	leave  
f0100b9d:	c3                   	ret    

f0100b9e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b9e:	55                   	push   %ebp
f0100b9f:	89 e5                	mov    %esp,%ebp
f0100ba1:	57                   	push   %edi
f0100ba2:	56                   	push   %esi
f0100ba3:	53                   	push   %ebx
f0100ba4:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba7:	84 c0                	test   %al,%al
f0100ba9:	0f 85 a0 02 00 00    	jne    f0100e4f <check_page_free_list+0x2b1>
f0100baf:	e9 ad 02 00 00       	jmp    f0100e61 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bb4:	83 ec 04             	sub    $0x4,%esp
f0100bb7:	68 04 69 10 f0       	push   $0xf0106904
f0100bbc:	68 d5 02 00 00       	push   $0x2d5
f0100bc1:	68 45 72 10 f0       	push   $0xf0107245
f0100bc6:	e8 75 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bcb:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bce:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bd1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bd4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bd7:	89 c2                	mov    %eax,%edx
f0100bd9:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0100bdf:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100be5:	0f 95 c2             	setne  %dl
f0100be8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100beb:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bef:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bf1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf5:	8b 00                	mov    (%eax),%eax
f0100bf7:	85 c0                	test   %eax,%eax
f0100bf9:	75 dc                	jne    f0100bd7 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bfe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c04:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c07:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c0a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c0c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c0f:	a3 40 12 21 f0       	mov    %eax,0xf0211240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c14:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c19:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100c1f:	eb 53                	jmp    f0100c74 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c21:	89 d8                	mov    %ebx,%eax
f0100c23:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100c29:	c1 f8 03             	sar    $0x3,%eax
f0100c2c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c2f:	89 c2                	mov    %eax,%edx
f0100c31:	c1 ea 16             	shr    $0x16,%edx
f0100c34:	39 f2                	cmp    %esi,%edx
f0100c36:	73 3a                	jae    f0100c72 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c38:	89 c2                	mov    %eax,%edx
f0100c3a:	c1 ea 0c             	shr    $0xc,%edx
f0100c3d:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100c43:	72 12                	jb     f0100c57 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c45:	50                   	push   %eax
f0100c46:	68 a4 63 10 f0       	push   $0xf01063a4
f0100c4b:	6a 58                	push   $0x58
f0100c4d:	68 6e 72 10 f0       	push   $0xf010726e
f0100c52:	e8 e9 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c57:	83 ec 04             	sub    $0x4,%esp
f0100c5a:	68 80 00 00 00       	push   $0x80
f0100c5f:	68 97 00 00 00       	push   $0x97
f0100c64:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c69:	50                   	push   %eax
f0100c6a:	e8 4a 4a 00 00       	call   f01056b9 <memset>
f0100c6f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c72:	8b 1b                	mov    (%ebx),%ebx
f0100c74:	85 db                	test   %ebx,%ebx
f0100c76:	75 a9                	jne    f0100c21 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c78:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c7d:	e8 94 fe ff ff       	call   f0100b16 <boot_alloc>
f0100c82:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c85:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c8b:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
		assert(pp < pages + npages);
f0100c91:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0100c96:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c99:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c9f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ca2:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca7:	e9 52 01 00 00       	jmp    f0100dfe <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cac:	39 ca                	cmp    %ecx,%edx
f0100cae:	73 19                	jae    f0100cc9 <check_page_free_list+0x12b>
f0100cb0:	68 7c 72 10 f0       	push   $0xf010727c
f0100cb5:	68 88 72 10 f0       	push   $0xf0107288
f0100cba:	68 ef 02 00 00       	push   $0x2ef
f0100cbf:	68 45 72 10 f0       	push   $0xf0107245
f0100cc4:	e8 77 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cc9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100ccc:	72 19                	jb     f0100ce7 <check_page_free_list+0x149>
f0100cce:	68 9d 72 10 f0       	push   $0xf010729d
f0100cd3:	68 88 72 10 f0       	push   $0xf0107288
f0100cd8:	68 f0 02 00 00       	push   $0x2f0
f0100cdd:	68 45 72 10 f0       	push   $0xf0107245
f0100ce2:	e8 59 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ce7:	89 d0                	mov    %edx,%eax
f0100ce9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cec:	a8 07                	test   $0x7,%al
f0100cee:	74 19                	je     f0100d09 <check_page_free_list+0x16b>
f0100cf0:	68 28 69 10 f0       	push   $0xf0106928
f0100cf5:	68 88 72 10 f0       	push   $0xf0107288
f0100cfa:	68 f1 02 00 00       	push   $0x2f1
f0100cff:	68 45 72 10 f0       	push   $0xf0107245
f0100d04:	e8 37 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d09:	c1 f8 03             	sar    $0x3,%eax
f0100d0c:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d0f:	85 c0                	test   %eax,%eax
f0100d11:	75 19                	jne    f0100d2c <check_page_free_list+0x18e>
f0100d13:	68 b1 72 10 f0       	push   $0xf01072b1
f0100d18:	68 88 72 10 f0       	push   $0xf0107288
f0100d1d:	68 f4 02 00 00       	push   $0x2f4
f0100d22:	68 45 72 10 f0       	push   $0xf0107245
f0100d27:	e8 14 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d2c:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d31:	75 19                	jne    f0100d4c <check_page_free_list+0x1ae>
f0100d33:	68 c2 72 10 f0       	push   $0xf01072c2
f0100d38:	68 88 72 10 f0       	push   $0xf0107288
f0100d3d:	68 f5 02 00 00       	push   $0x2f5
f0100d42:	68 45 72 10 f0       	push   $0xf0107245
f0100d47:	e8 f4 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d4c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d51:	75 19                	jne    f0100d6c <check_page_free_list+0x1ce>
f0100d53:	68 5c 69 10 f0       	push   $0xf010695c
f0100d58:	68 88 72 10 f0       	push   $0xf0107288
f0100d5d:	68 f6 02 00 00       	push   $0x2f6
f0100d62:	68 45 72 10 f0       	push   $0xf0107245
f0100d67:	e8 d4 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d6c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d71:	75 19                	jne    f0100d8c <check_page_free_list+0x1ee>
f0100d73:	68 db 72 10 f0       	push   $0xf01072db
f0100d78:	68 88 72 10 f0       	push   $0xf0107288
f0100d7d:	68 f7 02 00 00       	push   $0x2f7
f0100d82:	68 45 72 10 f0       	push   $0xf0107245
f0100d87:	e8 b4 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d8c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d91:	0f 86 f1 00 00 00    	jbe    f0100e88 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d97:	89 c7                	mov    %eax,%edi
f0100d99:	c1 ef 0c             	shr    $0xc,%edi
f0100d9c:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d9f:	77 12                	ja     f0100db3 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100da1:	50                   	push   %eax
f0100da2:	68 a4 63 10 f0       	push   $0xf01063a4
f0100da7:	6a 58                	push   $0x58
f0100da9:	68 6e 72 10 f0       	push   $0xf010726e
f0100dae:	e8 8d f2 ff ff       	call   f0100040 <_panic>
f0100db3:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100db9:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100dbc:	0f 86 b6 00 00 00    	jbe    f0100e78 <check_page_free_list+0x2da>
f0100dc2:	68 80 69 10 f0       	push   $0xf0106980
f0100dc7:	68 88 72 10 f0       	push   $0xf0107288
f0100dcc:	68 f8 02 00 00       	push   $0x2f8
f0100dd1:	68 45 72 10 f0       	push   $0xf0107245
f0100dd6:	e8 65 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ddb:	68 f5 72 10 f0       	push   $0xf01072f5
f0100de0:	68 88 72 10 f0       	push   $0xf0107288
f0100de5:	68 fa 02 00 00       	push   $0x2fa
f0100dea:	68 45 72 10 f0       	push   $0xf0107245
f0100def:	e8 4c f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100df4:	83 c6 01             	add    $0x1,%esi
f0100df7:	eb 03                	jmp    f0100dfc <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100df9:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dfc:	8b 12                	mov    (%edx),%edx
f0100dfe:	85 d2                	test   %edx,%edx
f0100e00:	0f 85 a6 fe ff ff    	jne    f0100cac <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e06:	85 f6                	test   %esi,%esi
f0100e08:	7f 19                	jg     f0100e23 <check_page_free_list+0x285>
f0100e0a:	68 12 73 10 f0       	push   $0xf0107312
f0100e0f:	68 88 72 10 f0       	push   $0xf0107288
f0100e14:	68 02 03 00 00       	push   $0x302
f0100e19:	68 45 72 10 f0       	push   $0xf0107245
f0100e1e:	e8 1d f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e23:	85 db                	test   %ebx,%ebx
f0100e25:	7f 19                	jg     f0100e40 <check_page_free_list+0x2a2>
f0100e27:	68 24 73 10 f0       	push   $0xf0107324
f0100e2c:	68 88 72 10 f0       	push   $0xf0107288
f0100e31:	68 03 03 00 00       	push   $0x303
f0100e36:	68 45 72 10 f0       	push   $0xf0107245
f0100e3b:	e8 00 f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e40:	83 ec 0c             	sub    $0xc,%esp
f0100e43:	68 c8 69 10 f0       	push   $0xf01069c8
f0100e48:	e8 6e 28 00 00       	call   f01036bb <cprintf>
}
f0100e4d:	eb 49                	jmp    f0100e98 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e4f:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0100e54:	85 c0                	test   %eax,%eax
f0100e56:	0f 85 6f fd ff ff    	jne    f0100bcb <check_page_free_list+0x2d>
f0100e5c:	e9 53 fd ff ff       	jmp    f0100bb4 <check_page_free_list+0x16>
f0100e61:	83 3d 40 12 21 f0 00 	cmpl   $0x0,0xf0211240
f0100e68:	0f 84 46 fd ff ff    	je     f0100bb4 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e6e:	be 00 04 00 00       	mov    $0x400,%esi
f0100e73:	e9 a1 fd ff ff       	jmp    f0100c19 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e78:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e7d:	0f 85 76 ff ff ff    	jne    f0100df9 <check_page_free_list+0x25b>
f0100e83:	e9 53 ff ff ff       	jmp    f0100ddb <check_page_free_list+0x23d>
f0100e88:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e8d:	0f 85 61 ff ff ff    	jne    f0100df4 <check_page_free_list+0x256>
f0100e93:	e9 43 ff ff ff       	jmp    f0100ddb <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e9b:	5b                   	pop    %ebx
f0100e9c:	5e                   	pop    %esi
f0100e9d:	5f                   	pop    %edi
f0100e9e:	5d                   	pop    %ebp
f0100e9f:	c3                   	ret    

f0100ea0 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ea0:	55                   	push   %ebp
f0100ea1:	89 e5                	mov    %esp,%ebp
f0100ea3:	57                   	push   %edi
f0100ea4:	56                   	push   %esi
f0100ea5:	53                   	push   %ebx
f0100ea6:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++){
f0100ea9:	8b 35 44 12 21 f0    	mov    0xf0211244,%esi
f0100eaf:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100eb5:	bf 00 00 00 00       	mov    $0x0,%edi
f0100eba:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ebf:	eb 34                	jmp    f0100ef5 <page_init+0x55>
		if (page2pa(&pages[i]) == MPENTRY_PADDR) continue;
f0100ec1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ec8:	89 d1                	mov    %edx,%ecx
f0100eca:	c1 e1 09             	shl    $0x9,%ecx
f0100ecd:	81 f9 00 70 00 00    	cmp    $0x7000,%ecx
f0100ed3:	74 1d                	je     f0100ef2 <page_init+0x52>
f0100ed5:	89 d1                	mov    %edx,%ecx
f0100ed7:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
		pages[i].pp_ref = 0;
f0100edd:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100ee3:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100ee5:	89 d3                	mov    %edx,%ebx
f0100ee7:	03 1d 90 1e 21 f0    	add    0xf0211e90,%ebx
f0100eed:	bf 01 00 00 00       	mov    $0x1,%edi
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++){
f0100ef2:	83 c0 01             	add    $0x1,%eax
f0100ef5:	39 f0                	cmp    %esi,%eax
f0100ef7:	72 c8                	jb     f0100ec1 <page_init+0x21>
f0100ef9:	89 f8                	mov    %edi,%eax
f0100efb:	84 c0                	test   %al,%al
f0100efd:	74 06                	je     f0100f05 <page_init+0x65>
f0100eff:	89 1d 40 12 21 f0    	mov    %ebx,0xf0211240
		if (page2pa(&pages[i]) == MPENTRY_PADDR) continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	i = (size_t)PADDR(boot_alloc(0)) >> PGSHIFT;
f0100f05:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f0a:	e8 07 fc ff ff       	call   f0100b16 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f0f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f14:	77 15                	ja     f0100f2b <page_init+0x8b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f16:	50                   	push   %eax
f0100f17:	68 c8 63 10 f0       	push   $0xf01063c8
f0100f1c:	68 4c 01 00 00       	push   $0x14c
f0100f21:	68 45 72 10 f0       	push   $0xf0107245
f0100f26:	e8 15 f1 ff ff       	call   f0100040 <_panic>
f0100f2b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f30:	c1 e8 0c             	shr    $0xc,%eax
f0100f33:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100f39:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	for (; i < npages; i++){
f0100f40:	be 00 00 00 00       	mov    $0x0,%esi
f0100f45:	eb 33                	jmp    f0100f7a <page_init+0xda>
		if (page2pa(&pages[i]) == MPENTRY_PADDR) continue;
f0100f47:	89 d1                	mov    %edx,%ecx
f0100f49:	c1 f9 03             	sar    $0x3,%ecx
f0100f4c:	c1 e1 0c             	shl    $0xc,%ecx
f0100f4f:	81 f9 00 70 00 00    	cmp    $0x7000,%ecx
f0100f55:	74 1d                	je     f0100f74 <page_init+0xd4>
f0100f57:	89 d1                	mov    %edx,%ecx
f0100f59:	03 0d 90 1e 21 f0    	add    0xf0211e90,%ecx
		pages[i].pp_ref = 0;
f0100f5f:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f65:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100f67:	89 d3                	mov    %edx,%ebx
f0100f69:	03 1d 90 1e 21 f0    	add    0xf0211e90,%ebx
f0100f6f:	be 01 00 00 00       	mov    $0x1,%esi
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	i = (size_t)PADDR(boot_alloc(0)) >> PGSHIFT;
	for (; i < npages; i++){
f0100f74:	83 c0 01             	add    $0x1,%eax
f0100f77:	83 c2 08             	add    $0x8,%edx
f0100f7a:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0100f80:	72 c5                	jb     f0100f47 <page_init+0xa7>
f0100f82:	89 f0                	mov    %esi,%eax
f0100f84:	84 c0                	test   %al,%al
f0100f86:	74 06                	je     f0100f8e <page_init+0xee>
f0100f88:	89 1d 40 12 21 f0    	mov    %ebx,0xf0211240
		if (page2pa(&pages[i]) == MPENTRY_PADDR) continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f91:	5b                   	pop    %ebx
f0100f92:	5e                   	pop    %esi
f0100f93:	5f                   	pop    %edi
f0100f94:	5d                   	pop    %ebp
f0100f95:	c3                   	ret    

f0100f96 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f96:	55                   	push   %ebp
f0100f97:	89 e5                	mov    %esp,%ebp
f0100f99:	53                   	push   %ebx
f0100f9a:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo* pp = page_free_list;
f0100f9d:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
	if (!pp) return NULL;
f0100fa3:	85 db                	test   %ebx,%ebx
f0100fa5:	74 5c                	je     f0101003 <page_alloc+0x6d>
	page_free_list = pp->pp_link;
f0100fa7:	8b 03                	mov    (%ebx),%eax
f0100fa9:	a3 40 12 21 f0       	mov    %eax,0xf0211240
	pp->pp_link = NULL;
f0100fae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) memset(page2kva(pp), 0, PGSIZE); 
	return pp;
f0100fb4:	89 d8                	mov    %ebx,%eax
	// Fill this function in
	struct PageInfo* pp = page_free_list;
	if (!pp) return NULL;
	page_free_list = pp->pp_link;
	pp->pp_link = NULL;
	if (alloc_flags & ALLOC_ZERO) memset(page2kva(pp), 0, PGSIZE); 
f0100fb6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fba:	74 4c                	je     f0101008 <page_alloc+0x72>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fbc:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100fc2:	c1 f8 03             	sar    $0x3,%eax
f0100fc5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fc8:	89 c2                	mov    %eax,%edx
f0100fca:	c1 ea 0c             	shr    $0xc,%edx
f0100fcd:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100fd3:	72 12                	jb     f0100fe7 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fd5:	50                   	push   %eax
f0100fd6:	68 a4 63 10 f0       	push   $0xf01063a4
f0100fdb:	6a 58                	push   $0x58
f0100fdd:	68 6e 72 10 f0       	push   $0xf010726e
f0100fe2:	e8 59 f0 ff ff       	call   f0100040 <_panic>
f0100fe7:	83 ec 04             	sub    $0x4,%esp
f0100fea:	68 00 10 00 00       	push   $0x1000
f0100fef:	6a 00                	push   $0x0
f0100ff1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ff6:	50                   	push   %eax
f0100ff7:	e8 bd 46 00 00       	call   f01056b9 <memset>
f0100ffc:	83 c4 10             	add    $0x10,%esp
	return pp;
f0100fff:	89 d8                	mov    %ebx,%eax
f0101001:	eb 05                	jmp    f0101008 <page_alloc+0x72>
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	struct PageInfo* pp = page_free_list;
	if (!pp) return NULL;
f0101003:	b8 00 00 00 00       	mov    $0x0,%eax
	page_free_list = pp->pp_link;
	pp->pp_link = NULL;
	if (alloc_flags & ALLOC_ZERO) memset(page2kva(pp), 0, PGSIZE); 
	return pp;
}
f0101008:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010100b:	c9                   	leave  
f010100c:	c3                   	ret    

f010100d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010100d:	55                   	push   %ebp
f010100e:	89 e5                	mov    %esp,%ebp
f0101010:	83 ec 08             	sub    $0x8,%esp
f0101013:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref || pp->pp_link) panic("Cannot free a page");
f0101016:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010101b:	75 05                	jne    f0101022 <page_free+0x15>
f010101d:	83 38 00             	cmpl   $0x0,(%eax)
f0101020:	74 17                	je     f0101039 <page_free+0x2c>
f0101022:	83 ec 04             	sub    $0x4,%esp
f0101025:	68 35 73 10 f0       	push   $0xf0107335
f010102a:	68 77 01 00 00       	push   $0x177
f010102f:	68 45 72 10 f0       	push   $0xf0107245
f0101034:	e8 07 f0 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0101039:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
f010103f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101041:	a3 40 12 21 f0       	mov    %eax,0xf0211240
}
f0101046:	c9                   	leave  
f0101047:	c3                   	ret    

f0101048 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101048:	55                   	push   %ebp
f0101049:	89 e5                	mov    %esp,%ebp
f010104b:	83 ec 08             	sub    $0x8,%esp
f010104e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101051:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101055:	83 e8 01             	sub    $0x1,%eax
f0101058:	66 89 42 04          	mov    %ax,0x4(%edx)
f010105c:	66 85 c0             	test   %ax,%ax
f010105f:	75 0c                	jne    f010106d <page_decref+0x25>
		page_free(pp);
f0101061:	83 ec 0c             	sub    $0xc,%esp
f0101064:	52                   	push   %edx
f0101065:	e8 a3 ff ff ff       	call   f010100d <page_free>
f010106a:	83 c4 10             	add    $0x10,%esp
}
f010106d:	c9                   	leave  
f010106e:	c3                   	ret    

f010106f <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010106f:	55                   	push   %ebp
f0101070:	89 e5                	mov    %esp,%ebp
f0101072:	56                   	push   %esi
f0101073:	53                   	push   %ebx
f0101074:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pde_t* pde = NULL;
	pte_t* pte = NULL;
	// cprintf("pgdir_walking\n");

	pde = &pgdir[PDX(va)];
f0101077:	89 f3                	mov    %esi,%ebx
f0101079:	c1 eb 16             	shr    $0x16,%ebx
f010107c:	c1 e3 02             	shl    $0x2,%ebx
f010107f:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde & PTE_P)){
f0101082:	f6 03 01             	testb  $0x1,(%ebx)
f0101085:	75 2d                	jne    f01010b4 <pgdir_walk+0x45>
		if (!create) return NULL;
f0101087:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010108b:	74 62                	je     f01010ef <pgdir_walk+0x80>
		else {
			struct PageInfo* pp = page_alloc(1);
f010108d:	83 ec 0c             	sub    $0xc,%esp
f0101090:	6a 01                	push   $0x1
f0101092:	e8 ff fe ff ff       	call   f0100f96 <page_alloc>
			if (!pp) return NULL;
f0101097:	83 c4 10             	add    $0x10,%esp
f010109a:	85 c0                	test   %eax,%eax
f010109c:	74 58                	je     f01010f6 <pgdir_walk+0x87>
			pp->pp_ref++;
f010109e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			*pde = PTE_ADDR(page2pa(pp)) | PTE_P | PTE_W | PTE_U;
f01010a3:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01010a9:	c1 f8 03             	sar    $0x3,%eax
f01010ac:	c1 e0 0c             	shl    $0xc,%eax
f01010af:	83 c8 07             	or     $0x7,%eax
f01010b2:	89 03                	mov    %eax,(%ebx)
		}
	}

	pte_t* pt = KADDR(PTE_ADDR(*pde));
f01010b4:	8b 03                	mov    (%ebx),%eax
f01010b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010bb:	89 c2                	mov    %eax,%edx
f01010bd:	c1 ea 0c             	shr    $0xc,%edx
f01010c0:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01010c6:	72 15                	jb     f01010dd <pgdir_walk+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010c8:	50                   	push   %eax
f01010c9:	68 a4 63 10 f0       	push   $0xf01063a4
f01010ce:	68 b0 01 00 00       	push   $0x1b0
f01010d3:	68 45 72 10 f0       	push   $0xf0107245
f01010d8:	e8 63 ef ff ff       	call   f0100040 <_panic>
	pte = &pt[PTX(va)];
f01010dd:	c1 ee 0a             	shr    $0xa,%esi
f01010e0:	81 e6 fc 0f 00 00    	and    $0xffc,%esi

	return pte;
f01010e6:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01010ed:	eb 0c                	jmp    f01010fb <pgdir_walk+0x8c>
	pte_t* pte = NULL;
	// cprintf("pgdir_walking\n");

	pde = &pgdir[PDX(va)];
	if (!(*pde & PTE_P)){
		if (!create) return NULL;
f01010ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01010f4:	eb 05                	jmp    f01010fb <pgdir_walk+0x8c>
		else {
			struct PageInfo* pp = page_alloc(1);
			if (!pp) return NULL;
f01010f6:	b8 00 00 00 00       	mov    $0x0,%eax

	pte_t* pt = KADDR(PTE_ADDR(*pde));
	pte = &pt[PTX(va)];

	return pte;
}
f01010fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010fe:	5b                   	pop    %ebx
f01010ff:	5e                   	pop    %esi
f0101100:	5d                   	pop    %ebp
f0101101:	c3                   	ret    

f0101102 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101102:	55                   	push   %ebp
f0101103:	89 e5                	mov    %esp,%ebp
f0101105:	57                   	push   %edi
f0101106:	56                   	push   %esi
f0101107:	53                   	push   %ebx
f0101108:	83 ec 1c             	sub    $0x1c,%esp
f010110b:	89 c7                	mov    %eax,%edi
f010110d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101110:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	int i;
	for (i = 0; i < size; i += PGSIZE){
f0101113:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t* pte = pgdir_walk(pgdir, (const void*)(va + i), 1);
		if (!pte) panic("No enough memory to map region");
		*pte = (pa + i) | perm | PTE_P;
f0101118:	8b 45 0c             	mov    0xc(%ebp),%eax
f010111b:	83 c8 01             	or     $0x1,%eax
f010111e:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int i;
	for (i = 0; i < size; i += PGSIZE){
f0101121:	eb 3d                	jmp    f0101160 <boot_map_region+0x5e>
		pte_t* pte = pgdir_walk(pgdir, (const void*)(va + i), 1);
f0101123:	83 ec 04             	sub    $0x4,%esp
f0101126:	6a 01                	push   $0x1
f0101128:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010112b:	01 f0                	add    %esi,%eax
f010112d:	50                   	push   %eax
f010112e:	57                   	push   %edi
f010112f:	e8 3b ff ff ff       	call   f010106f <pgdir_walk>
		if (!pte) panic("No enough memory to map region");
f0101134:	83 c4 10             	add    $0x10,%esp
f0101137:	85 c0                	test   %eax,%eax
f0101139:	75 17                	jne    f0101152 <boot_map_region+0x50>
f010113b:	83 ec 04             	sub    $0x4,%esp
f010113e:	68 ec 69 10 f0       	push   $0xf01069ec
f0101143:	68 c8 01 00 00       	push   $0x1c8
f0101148:	68 45 72 10 f0       	push   $0xf0107245
f010114d:	e8 ee ee ff ff       	call   f0100040 <_panic>
		*pte = (pa + i) | perm | PTE_P;
f0101152:	03 5d 08             	add    0x8(%ebp),%ebx
f0101155:	0b 5d dc             	or     -0x24(%ebp),%ebx
f0101158:	89 18                	mov    %ebx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	int i;
	for (i = 0; i < size; i += PGSIZE){
f010115a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101160:	89 f3                	mov    %esi,%ebx
f0101162:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101165:	77 bc                	ja     f0101123 <boot_map_region+0x21>
		pte_t* pte = pgdir_walk(pgdir, (const void*)(va + i), 1);
		if (!pte) panic("No enough memory to map region");
		*pte = (pa + i) | perm | PTE_P;
	}

}
f0101167:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010116a:	5b                   	pop    %ebx
f010116b:	5e                   	pop    %esi
f010116c:	5f                   	pop    %edi
f010116d:	5d                   	pop    %ebp
f010116e:	c3                   	ret    

f010116f <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010116f:	55                   	push   %ebp
f0101170:	89 e5                	mov    %esp,%ebp
f0101172:	53                   	push   %ebx
f0101173:	83 ec 08             	sub    $0x8,%esp
f0101176:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir, va, 0);
f0101179:	6a 00                	push   $0x0
f010117b:	ff 75 0c             	pushl  0xc(%ebp)
f010117e:	ff 75 08             	pushl  0x8(%ebp)
f0101181:	e8 e9 fe ff ff       	call   f010106f <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;
f0101186:	83 c4 10             	add    $0x10,%esp
f0101189:	85 c0                	test   %eax,%eax
f010118b:	74 38                	je     f01011c5 <page_lookup+0x56>
f010118d:	89 c1                	mov    %eax,%ecx
f010118f:	8b 10                	mov    (%eax),%edx
f0101191:	f6 c2 01             	test   $0x1,%dl
f0101194:	74 36                	je     f01011cc <page_lookup+0x5d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101196:	c1 ea 0c             	shr    $0xc,%edx
f0101199:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010119f:	72 14                	jb     f01011b5 <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f01011a1:	83 ec 04             	sub    $0x4,%esp
f01011a4:	68 0c 6a 10 f0       	push   $0xf0106a0c
f01011a9:	6a 51                	push   $0x51
f01011ab:	68 6e 72 10 f0       	push   $0xf010726e
f01011b0:	e8 8b ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011b5:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f01011ba:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	struct PageInfo* pp = pa2page(PTE_ADDR(*pte));
	if (pte_store) *pte_store = pte;
f01011bd:	85 db                	test   %ebx,%ebx
f01011bf:	74 10                	je     f01011d1 <page_lookup+0x62>
f01011c1:	89 0b                	mov    %ecx,(%ebx)
f01011c3:	eb 0c                	jmp    f01011d1 <page_lookup+0x62>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t* pte = pgdir_walk(pgdir, va, 0);
	if (!pte || !(*pte & PTE_P)) return NULL;
f01011c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ca:	eb 05                	jmp    f01011d1 <page_lookup+0x62>
f01011cc:	b8 00 00 00 00       	mov    $0x0,%eax
	struct PageInfo* pp = pa2page(PTE_ADDR(*pte));
	if (pte_store) *pte_store = pte;
	return pp;
}
f01011d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011d4:	c9                   	leave  
f01011d5:	c3                   	ret    

f01011d6 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011d6:	55                   	push   %ebp
f01011d7:	89 e5                	mov    %esp,%ebp
f01011d9:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011dc:	e8 0a 4b 00 00       	call   f0105ceb <cpunum>
f01011e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01011e4:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01011eb:	74 16                	je     f0101203 <tlb_invalidate+0x2d>
f01011ed:	e8 f9 4a 00 00       	call   f0105ceb <cpunum>
f01011f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011f5:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01011fb:	8b 55 08             	mov    0x8(%ebp),%edx
f01011fe:	39 50 60             	cmp    %edx,0x60(%eax)
f0101201:	75 06                	jne    f0101209 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101203:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101206:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101209:	c9                   	leave  
f010120a:	c3                   	ret    

f010120b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010120b:	55                   	push   %ebp
f010120c:	89 e5                	mov    %esp,%ebp
f010120e:	56                   	push   %esi
f010120f:	53                   	push   %ebx
f0101210:	83 ec 14             	sub    $0x14,%esp
f0101213:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101216:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte = NULL;
f0101219:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pp = page_lookup(pgdir, va, &pte);
f0101220:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101223:	50                   	push   %eax
f0101224:	56                   	push   %esi
f0101225:	53                   	push   %ebx
f0101226:	e8 44 ff ff ff       	call   f010116f <page_lookup>
	if (!pp){
f010122b:	83 c4 10             	add    $0x10,%esp
f010122e:	85 c0                	test   %eax,%eax
f0101230:	74 26                	je     f0101258 <page_remove+0x4d>
		// Do nothing
	}
	else {
		// pp->pp_ref--;
		// if (pp->pp_ref == 0) page_free(pp);
		page_decref(pp);
f0101232:	83 ec 0c             	sub    $0xc,%esp
f0101235:	50                   	push   %eax
f0101236:	e8 0d fe ff ff       	call   f0101048 <page_decref>
		if (pte) *pte = 0;
f010123b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010123e:	83 c4 10             	add    $0x10,%esp
f0101241:	85 c0                	test   %eax,%eax
f0101243:	74 06                	je     f010124b <page_remove+0x40>
f0101245:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f010124b:	83 ec 08             	sub    $0x8,%esp
f010124e:	56                   	push   %esi
f010124f:	53                   	push   %ebx
f0101250:	e8 81 ff ff ff       	call   f01011d6 <tlb_invalidate>
f0101255:	83 c4 10             	add    $0x10,%esp
	}
}
f0101258:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010125b:	5b                   	pop    %ebx
f010125c:	5e                   	pop    %esi
f010125d:	5d                   	pop    %ebp
f010125e:	c3                   	ret    

f010125f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010125f:	55                   	push   %ebp
f0101260:	89 e5                	mov    %esp,%ebp
f0101262:	57                   	push   %edi
f0101263:	56                   	push   %esi
f0101264:	53                   	push   %ebx
f0101265:	83 ec 10             	sub    $0x10,%esp
f0101268:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010126b:	8b 7d 10             	mov    0x10(%ebp),%edi
		pp->pp_ref++;
		page_remove(pgdir, va);
		*pte = PTE_ADDR(page2pa(pp)) | PTE_P | perm;
	}*/

	pte_t* pte = pgdir_walk(pgdir, va, 1);
f010126e:	6a 01                	push   $0x1
f0101270:	57                   	push   %edi
f0101271:	ff 75 08             	pushl  0x8(%ebp)
f0101274:	e8 f6 fd ff ff       	call   f010106f <pgdir_walk>
	if (!pte) return -E_NO_MEM;
f0101279:	83 c4 10             	add    $0x10,%esp
f010127c:	85 c0                	test   %eax,%eax
f010127e:	74 38                	je     f01012b8 <page_insert+0x59>
f0101280:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101282:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) page_remove(pgdir, va);
f0101287:	f6 00 01             	testb  $0x1,(%eax)
f010128a:	74 0f                	je     f010129b <page_insert+0x3c>
f010128c:	83 ec 08             	sub    $0x8,%esp
f010128f:	57                   	push   %edi
f0101290:	ff 75 08             	pushl  0x8(%ebp)
f0101293:	e8 73 ff ff ff       	call   f010120b <page_remove>
f0101298:	83 c4 10             	add    $0x10,%esp
	*pte = PTE_ADDR(page2pa(pp)) | PTE_P | perm;
f010129b:	2b 1d 90 1e 21 f0    	sub    0xf0211e90,%ebx
f01012a1:	c1 fb 03             	sar    $0x3,%ebx
f01012a4:	c1 e3 0c             	shl    $0xc,%ebx
f01012a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01012aa:	83 c8 01             	or     $0x1,%eax
f01012ad:	09 c3                	or     %eax,%ebx
f01012af:	89 1e                	mov    %ebx,(%esi)

	return 0;
f01012b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b6:	eb 05                	jmp    f01012bd <page_insert+0x5e>
		page_remove(pgdir, va);
		*pte = PTE_ADDR(page2pa(pp)) | PTE_P | perm;
	}*/

	pte_t* pte = pgdir_walk(pgdir, va, 1);
	if (!pte) return -E_NO_MEM;
f01012b8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;
	if (*pte & PTE_P) page_remove(pgdir, va);
	*pte = PTE_ADDR(page2pa(pp)) | PTE_P | perm;

	return 0;
}
f01012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012c0:	5b                   	pop    %ebx
f01012c1:	5e                   	pop    %esi
f01012c2:	5f                   	pop    %edi
f01012c3:	5d                   	pop    %ebp
f01012c4:	c3                   	ret    

f01012c5 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012c5:	55                   	push   %ebp
f01012c6:	89 e5                	mov    %esp,%ebp
f01012c8:	53                   	push   %ebx
f01012c9:	83 ec 04             	sub    $0x4,%esp
f01012cc:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	physaddr_t pa_end = ROUNDUP(pa + size, PGSIZE);
f01012cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012d2:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
	physaddr_t pa_start = ROUNDDOWN(pa, PGSIZE);
f01012d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size = pa_end - pa_start;
f01012de:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01012e4:	29 c3                	sub    %eax,%ebx
	// cprintf("mmio: base = %08x, start = %08x, size = %08x\n", base, pa_start, pa_end - pa_start);

	if (base + size > MMIOLIM) panic("mmio overflow");
f01012e6:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f01012ec:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f01012ef:	81 f9 00 00 c0 ef    	cmp    $0xefc00000,%ecx
f01012f5:	76 17                	jbe    f010130e <mmio_map_region+0x49>
f01012f7:	83 ec 04             	sub    $0x4,%esp
f01012fa:	68 48 73 10 f0       	push   $0xf0107348
f01012ff:	68 75 02 00 00       	push   $0x275
f0101304:	68 45 72 10 f0       	push   $0xf0107245
f0101309:	e8 32 ed ff ff       	call   f0100040 <_panic>

	boot_map_region(kern_pgdir, base, size, pa_start, PTE_PCD | PTE_PWT | PTE_W | PTE_P);
f010130e:	83 ec 08             	sub    $0x8,%esp
f0101311:	6a 1b                	push   $0x1b
f0101313:	50                   	push   %eax
f0101314:	89 d9                	mov    %ebx,%ecx
f0101316:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010131b:	e8 e2 fd ff ff       	call   f0101102 <boot_map_region>
	uintptr_t ret_base = base;
f0101320:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base += size;
f0101325:	01 c3                	add    %eax,%ebx
f0101327:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300

	return (void*)ret_base;

	// panic("mmio_map_region not implemented");
}
f010132d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101330:	c9                   	leave  
f0101331:	c3                   	ret    

f0101332 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101332:	55                   	push   %ebp
f0101333:	89 e5                	mov    %esp,%ebp
f0101335:	57                   	push   %edi
f0101336:	56                   	push   %esi
f0101337:	53                   	push   %ebx
f0101338:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010133b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101340:	e8 44 f7 ff ff       	call   f0100a89 <nvram_read>
f0101345:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101347:	b8 17 00 00 00       	mov    $0x17,%eax
f010134c:	e8 38 f7 ff ff       	call   f0100a89 <nvram_read>
f0101351:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101353:	b8 34 00 00 00       	mov    $0x34,%eax
f0101358:	e8 2c f7 ff ff       	call   f0100a89 <nvram_read>
f010135d:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101360:	85 c0                	test   %eax,%eax
f0101362:	74 07                	je     f010136b <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101364:	05 00 40 00 00       	add    $0x4000,%eax
f0101369:	eb 0b                	jmp    f0101376 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010136b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101371:	85 f6                	test   %esi,%esi
f0101373:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101376:	89 c2                	mov    %eax,%edx
f0101378:	c1 ea 02             	shr    $0x2,%edx
f010137b:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101381:	89 da                	mov    %ebx,%edx
f0101383:	c1 ea 02             	shr    $0x2,%edx
f0101386:	89 15 44 12 21 f0    	mov    %edx,0xf0211244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010138c:	89 c2                	mov    %eax,%edx
f010138e:	29 da                	sub    %ebx,%edx
f0101390:	52                   	push   %edx
f0101391:	53                   	push   %ebx
f0101392:	50                   	push   %eax
f0101393:	68 2c 6a 10 f0       	push   $0xf0106a2c
f0101398:	e8 1e 23 00 00       	call   f01036bb <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010139d:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013a2:	e8 6f f7 ff ff       	call   f0100b16 <boot_alloc>
f01013a7:	a3 8c 1e 21 f0       	mov    %eax,0xf0211e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013ac:	83 c4 0c             	add    $0xc,%esp
f01013af:	68 00 10 00 00       	push   $0x1000
f01013b4:	6a 00                	push   $0x0
f01013b6:	50                   	push   %eax
f01013b7:	e8 fd 42 00 00       	call   f01056b9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013bc:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013c1:	83 c4 10             	add    $0x10,%esp
f01013c4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013c9:	77 15                	ja     f01013e0 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013cb:	50                   	push   %eax
f01013cc:	68 c8 63 10 f0       	push   $0xf01063c8
f01013d1:	68 98 00 00 00       	push   $0x98
f01013d6:	68 45 72 10 f0       	push   $0xf0107245
f01013db:	e8 60 ec ff ff       	call   f0100040 <_panic>
f01013e0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013e6:	83 ca 05             	or     $0x5,%edx
f01013e9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(npages * sizeof(struct PageInfo));
f01013ef:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01013f4:	c1 e0 03             	shl    $0x3,%eax
f01013f7:	e8 1a f7 ff ff       	call   f0100b16 <boot_alloc>
f01013fc:	a3 90 1e 21 f0       	mov    %eax,0xf0211e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101401:	83 ec 04             	sub    $0x4,%esp
f0101404:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f010140a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101411:	52                   	push   %edx
f0101412:	6a 00                	push   $0x0
f0101414:	50                   	push   %eax
f0101415:	e8 9f 42 00 00       	call   f01056b9 <memset>


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV * sizeof(struct Env));
f010141a:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010141f:	e8 f2 f6 ff ff       	call   f0100b16 <boot_alloc>
f0101424:	a3 48 12 21 f0       	mov    %eax,0xf0211248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101429:	e8 72 fa ff ff       	call   f0100ea0 <page_init>

	check_page_free_list(1);
f010142e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101433:	e8 66 f7 ff ff       	call   f0100b9e <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101438:	83 c4 10             	add    $0x10,%esp
f010143b:	83 3d 90 1e 21 f0 00 	cmpl   $0x0,0xf0211e90
f0101442:	75 17                	jne    f010145b <mem_init+0x129>
		panic("'pages' is a null pointer!");
f0101444:	83 ec 04             	sub    $0x4,%esp
f0101447:	68 56 73 10 f0       	push   $0xf0107356
f010144c:	68 16 03 00 00       	push   $0x316
f0101451:	68 45 72 10 f0       	push   $0xf0107245
f0101456:	e8 e5 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010145b:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101460:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101465:	eb 05                	jmp    f010146c <mem_init+0x13a>
		++nfree;
f0101467:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010146a:	8b 00                	mov    (%eax),%eax
f010146c:	85 c0                	test   %eax,%eax
f010146e:	75 f7                	jne    f0101467 <mem_init+0x135>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101470:	83 ec 0c             	sub    $0xc,%esp
f0101473:	6a 00                	push   $0x0
f0101475:	e8 1c fb ff ff       	call   f0100f96 <page_alloc>
f010147a:	89 c7                	mov    %eax,%edi
f010147c:	83 c4 10             	add    $0x10,%esp
f010147f:	85 c0                	test   %eax,%eax
f0101481:	75 19                	jne    f010149c <mem_init+0x16a>
f0101483:	68 71 73 10 f0       	push   $0xf0107371
f0101488:	68 88 72 10 f0       	push   $0xf0107288
f010148d:	68 1e 03 00 00       	push   $0x31e
f0101492:	68 45 72 10 f0       	push   $0xf0107245
f0101497:	e8 a4 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010149c:	83 ec 0c             	sub    $0xc,%esp
f010149f:	6a 00                	push   $0x0
f01014a1:	e8 f0 fa ff ff       	call   f0100f96 <page_alloc>
f01014a6:	89 c6                	mov    %eax,%esi
f01014a8:	83 c4 10             	add    $0x10,%esp
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	75 19                	jne    f01014c8 <mem_init+0x196>
f01014af:	68 87 73 10 f0       	push   $0xf0107387
f01014b4:	68 88 72 10 f0       	push   $0xf0107288
f01014b9:	68 1f 03 00 00       	push   $0x31f
f01014be:	68 45 72 10 f0       	push   $0xf0107245
f01014c3:	e8 78 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01014c8:	83 ec 0c             	sub    $0xc,%esp
f01014cb:	6a 00                	push   $0x0
f01014cd:	e8 c4 fa ff ff       	call   f0100f96 <page_alloc>
f01014d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014d5:	83 c4 10             	add    $0x10,%esp
f01014d8:	85 c0                	test   %eax,%eax
f01014da:	75 19                	jne    f01014f5 <mem_init+0x1c3>
f01014dc:	68 9d 73 10 f0       	push   $0xf010739d
f01014e1:	68 88 72 10 f0       	push   $0xf0107288
f01014e6:	68 20 03 00 00       	push   $0x320
f01014eb:	68 45 72 10 f0       	push   $0xf0107245
f01014f0:	e8 4b eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014f5:	39 f7                	cmp    %esi,%edi
f01014f7:	75 19                	jne    f0101512 <mem_init+0x1e0>
f01014f9:	68 b3 73 10 f0       	push   $0xf01073b3
f01014fe:	68 88 72 10 f0       	push   $0xf0107288
f0101503:	68 23 03 00 00       	push   $0x323
f0101508:	68 45 72 10 f0       	push   $0xf0107245
f010150d:	e8 2e eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101512:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101515:	39 c6                	cmp    %eax,%esi
f0101517:	74 04                	je     f010151d <mem_init+0x1eb>
f0101519:	39 c7                	cmp    %eax,%edi
f010151b:	75 19                	jne    f0101536 <mem_init+0x204>
f010151d:	68 68 6a 10 f0       	push   $0xf0106a68
f0101522:	68 88 72 10 f0       	push   $0xf0107288
f0101527:	68 24 03 00 00       	push   $0x324
f010152c:	68 45 72 10 f0       	push   $0xf0107245
f0101531:	e8 0a eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101536:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010153c:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f0101542:	c1 e2 0c             	shl    $0xc,%edx
f0101545:	89 f8                	mov    %edi,%eax
f0101547:	29 c8                	sub    %ecx,%eax
f0101549:	c1 f8 03             	sar    $0x3,%eax
f010154c:	c1 e0 0c             	shl    $0xc,%eax
f010154f:	39 d0                	cmp    %edx,%eax
f0101551:	72 19                	jb     f010156c <mem_init+0x23a>
f0101553:	68 c5 73 10 f0       	push   $0xf01073c5
f0101558:	68 88 72 10 f0       	push   $0xf0107288
f010155d:	68 25 03 00 00       	push   $0x325
f0101562:	68 45 72 10 f0       	push   $0xf0107245
f0101567:	e8 d4 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010156c:	89 f0                	mov    %esi,%eax
f010156e:	29 c8                	sub    %ecx,%eax
f0101570:	c1 f8 03             	sar    $0x3,%eax
f0101573:	c1 e0 0c             	shl    $0xc,%eax
f0101576:	39 c2                	cmp    %eax,%edx
f0101578:	77 19                	ja     f0101593 <mem_init+0x261>
f010157a:	68 e2 73 10 f0       	push   $0xf01073e2
f010157f:	68 88 72 10 f0       	push   $0xf0107288
f0101584:	68 26 03 00 00       	push   $0x326
f0101589:	68 45 72 10 f0       	push   $0xf0107245
f010158e:	e8 ad ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101593:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101596:	29 c8                	sub    %ecx,%eax
f0101598:	c1 f8 03             	sar    $0x3,%eax
f010159b:	c1 e0 0c             	shl    $0xc,%eax
f010159e:	39 c2                	cmp    %eax,%edx
f01015a0:	77 19                	ja     f01015bb <mem_init+0x289>
f01015a2:	68 ff 73 10 f0       	push   $0xf01073ff
f01015a7:	68 88 72 10 f0       	push   $0xf0107288
f01015ac:	68 27 03 00 00       	push   $0x327
f01015b1:	68 45 72 10 f0       	push   $0xf0107245
f01015b6:	e8 85 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01015bb:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f01015c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015c3:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f01015ca:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01015cd:	83 ec 0c             	sub    $0xc,%esp
f01015d0:	6a 00                	push   $0x0
f01015d2:	e8 bf f9 ff ff       	call   f0100f96 <page_alloc>
f01015d7:	83 c4 10             	add    $0x10,%esp
f01015da:	85 c0                	test   %eax,%eax
f01015dc:	74 19                	je     f01015f7 <mem_init+0x2c5>
f01015de:	68 1c 74 10 f0       	push   $0xf010741c
f01015e3:	68 88 72 10 f0       	push   $0xf0107288
f01015e8:	68 2e 03 00 00       	push   $0x32e
f01015ed:	68 45 72 10 f0       	push   $0xf0107245
f01015f2:	e8 49 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015f7:	83 ec 0c             	sub    $0xc,%esp
f01015fa:	57                   	push   %edi
f01015fb:	e8 0d fa ff ff       	call   f010100d <page_free>
	page_free(pp1);
f0101600:	89 34 24             	mov    %esi,(%esp)
f0101603:	e8 05 fa ff ff       	call   f010100d <page_free>
	page_free(pp2);
f0101608:	83 c4 04             	add    $0x4,%esp
f010160b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010160e:	e8 fa f9 ff ff       	call   f010100d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101613:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010161a:	e8 77 f9 ff ff       	call   f0100f96 <page_alloc>
f010161f:	89 c6                	mov    %eax,%esi
f0101621:	83 c4 10             	add    $0x10,%esp
f0101624:	85 c0                	test   %eax,%eax
f0101626:	75 19                	jne    f0101641 <mem_init+0x30f>
f0101628:	68 71 73 10 f0       	push   $0xf0107371
f010162d:	68 88 72 10 f0       	push   $0xf0107288
f0101632:	68 35 03 00 00       	push   $0x335
f0101637:	68 45 72 10 f0       	push   $0xf0107245
f010163c:	e8 ff e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101641:	83 ec 0c             	sub    $0xc,%esp
f0101644:	6a 00                	push   $0x0
f0101646:	e8 4b f9 ff ff       	call   f0100f96 <page_alloc>
f010164b:	89 c7                	mov    %eax,%edi
f010164d:	83 c4 10             	add    $0x10,%esp
f0101650:	85 c0                	test   %eax,%eax
f0101652:	75 19                	jne    f010166d <mem_init+0x33b>
f0101654:	68 87 73 10 f0       	push   $0xf0107387
f0101659:	68 88 72 10 f0       	push   $0xf0107288
f010165e:	68 36 03 00 00       	push   $0x336
f0101663:	68 45 72 10 f0       	push   $0xf0107245
f0101668:	e8 d3 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010166d:	83 ec 0c             	sub    $0xc,%esp
f0101670:	6a 00                	push   $0x0
f0101672:	e8 1f f9 ff ff       	call   f0100f96 <page_alloc>
f0101677:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010167a:	83 c4 10             	add    $0x10,%esp
f010167d:	85 c0                	test   %eax,%eax
f010167f:	75 19                	jne    f010169a <mem_init+0x368>
f0101681:	68 9d 73 10 f0       	push   $0xf010739d
f0101686:	68 88 72 10 f0       	push   $0xf0107288
f010168b:	68 37 03 00 00       	push   $0x337
f0101690:	68 45 72 10 f0       	push   $0xf0107245
f0101695:	e8 a6 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010169a:	39 fe                	cmp    %edi,%esi
f010169c:	75 19                	jne    f01016b7 <mem_init+0x385>
f010169e:	68 b3 73 10 f0       	push   $0xf01073b3
f01016a3:	68 88 72 10 f0       	push   $0xf0107288
f01016a8:	68 39 03 00 00       	push   $0x339
f01016ad:	68 45 72 10 f0       	push   $0xf0107245
f01016b2:	e8 89 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016ba:	39 c7                	cmp    %eax,%edi
f01016bc:	74 04                	je     f01016c2 <mem_init+0x390>
f01016be:	39 c6                	cmp    %eax,%esi
f01016c0:	75 19                	jne    f01016db <mem_init+0x3a9>
f01016c2:	68 68 6a 10 f0       	push   $0xf0106a68
f01016c7:	68 88 72 10 f0       	push   $0xf0107288
f01016cc:	68 3a 03 00 00       	push   $0x33a
f01016d1:	68 45 72 10 f0       	push   $0xf0107245
f01016d6:	e8 65 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01016db:	83 ec 0c             	sub    $0xc,%esp
f01016de:	6a 00                	push   $0x0
f01016e0:	e8 b1 f8 ff ff       	call   f0100f96 <page_alloc>
f01016e5:	83 c4 10             	add    $0x10,%esp
f01016e8:	85 c0                	test   %eax,%eax
f01016ea:	74 19                	je     f0101705 <mem_init+0x3d3>
f01016ec:	68 1c 74 10 f0       	push   $0xf010741c
f01016f1:	68 88 72 10 f0       	push   $0xf0107288
f01016f6:	68 3b 03 00 00       	push   $0x33b
f01016fb:	68 45 72 10 f0       	push   $0xf0107245
f0101700:	e8 3b e9 ff ff       	call   f0100040 <_panic>
f0101705:	89 f0                	mov    %esi,%eax
f0101707:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010170d:	c1 f8 03             	sar    $0x3,%eax
f0101710:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101713:	89 c2                	mov    %eax,%edx
f0101715:	c1 ea 0c             	shr    $0xc,%edx
f0101718:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010171e:	72 12                	jb     f0101732 <mem_init+0x400>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101720:	50                   	push   %eax
f0101721:	68 a4 63 10 f0       	push   $0xf01063a4
f0101726:	6a 58                	push   $0x58
f0101728:	68 6e 72 10 f0       	push   $0xf010726e
f010172d:	e8 0e e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101732:	83 ec 04             	sub    $0x4,%esp
f0101735:	68 00 10 00 00       	push   $0x1000
f010173a:	6a 01                	push   $0x1
f010173c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101741:	50                   	push   %eax
f0101742:	e8 72 3f 00 00       	call   f01056b9 <memset>
	page_free(pp0);
f0101747:	89 34 24             	mov    %esi,(%esp)
f010174a:	e8 be f8 ff ff       	call   f010100d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010174f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101756:	e8 3b f8 ff ff       	call   f0100f96 <page_alloc>
f010175b:	83 c4 10             	add    $0x10,%esp
f010175e:	85 c0                	test   %eax,%eax
f0101760:	75 19                	jne    f010177b <mem_init+0x449>
f0101762:	68 2b 74 10 f0       	push   $0xf010742b
f0101767:	68 88 72 10 f0       	push   $0xf0107288
f010176c:	68 40 03 00 00       	push   $0x340
f0101771:	68 45 72 10 f0       	push   $0xf0107245
f0101776:	e8 c5 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010177b:	39 c6                	cmp    %eax,%esi
f010177d:	74 19                	je     f0101798 <mem_init+0x466>
f010177f:	68 49 74 10 f0       	push   $0xf0107449
f0101784:	68 88 72 10 f0       	push   $0xf0107288
f0101789:	68 41 03 00 00       	push   $0x341
f010178e:	68 45 72 10 f0       	push   $0xf0107245
f0101793:	e8 a8 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101798:	89 f0                	mov    %esi,%eax
f010179a:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01017a0:	c1 f8 03             	sar    $0x3,%eax
f01017a3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017a6:	89 c2                	mov    %eax,%edx
f01017a8:	c1 ea 0c             	shr    $0xc,%edx
f01017ab:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01017b1:	72 12                	jb     f01017c5 <mem_init+0x493>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017b3:	50                   	push   %eax
f01017b4:	68 a4 63 10 f0       	push   $0xf01063a4
f01017b9:	6a 58                	push   $0x58
f01017bb:	68 6e 72 10 f0       	push   $0xf010726e
f01017c0:	e8 7b e8 ff ff       	call   f0100040 <_panic>
f01017c5:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01017cb:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01017d1:	80 38 00             	cmpb   $0x0,(%eax)
f01017d4:	74 19                	je     f01017ef <mem_init+0x4bd>
f01017d6:	68 59 74 10 f0       	push   $0xf0107459
f01017db:	68 88 72 10 f0       	push   $0xf0107288
f01017e0:	68 44 03 00 00       	push   $0x344
f01017e5:	68 45 72 10 f0       	push   $0xf0107245
f01017ea:	e8 51 e8 ff ff       	call   f0100040 <_panic>
f01017ef:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017f2:	39 d0                	cmp    %edx,%eax
f01017f4:	75 db                	jne    f01017d1 <mem_init+0x49f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017f9:	a3 40 12 21 f0       	mov    %eax,0xf0211240

	// free the pages we took
	page_free(pp0);
f01017fe:	83 ec 0c             	sub    $0xc,%esp
f0101801:	56                   	push   %esi
f0101802:	e8 06 f8 ff ff       	call   f010100d <page_free>
	page_free(pp1);
f0101807:	89 3c 24             	mov    %edi,(%esp)
f010180a:	e8 fe f7 ff ff       	call   f010100d <page_free>
	page_free(pp2);
f010180f:	83 c4 04             	add    $0x4,%esp
f0101812:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101815:	e8 f3 f7 ff ff       	call   f010100d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010181a:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f010181f:	83 c4 10             	add    $0x10,%esp
f0101822:	eb 05                	jmp    f0101829 <mem_init+0x4f7>
		--nfree;
f0101824:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101827:	8b 00                	mov    (%eax),%eax
f0101829:	85 c0                	test   %eax,%eax
f010182b:	75 f7                	jne    f0101824 <mem_init+0x4f2>
		--nfree;
	assert(nfree == 0);
f010182d:	85 db                	test   %ebx,%ebx
f010182f:	74 19                	je     f010184a <mem_init+0x518>
f0101831:	68 63 74 10 f0       	push   $0xf0107463
f0101836:	68 88 72 10 f0       	push   $0xf0107288
f010183b:	68 51 03 00 00       	push   $0x351
f0101840:	68 45 72 10 f0       	push   $0xf0107245
f0101845:	e8 f6 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010184a:	83 ec 0c             	sub    $0xc,%esp
f010184d:	68 88 6a 10 f0       	push   $0xf0106a88
f0101852:	e8 64 1e 00 00       	call   f01036bb <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101857:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010185e:	e8 33 f7 ff ff       	call   f0100f96 <page_alloc>
f0101863:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101866:	83 c4 10             	add    $0x10,%esp
f0101869:	85 c0                	test   %eax,%eax
f010186b:	75 19                	jne    f0101886 <mem_init+0x554>
f010186d:	68 71 73 10 f0       	push   $0xf0107371
f0101872:	68 88 72 10 f0       	push   $0xf0107288
f0101877:	68 b7 03 00 00       	push   $0x3b7
f010187c:	68 45 72 10 f0       	push   $0xf0107245
f0101881:	e8 ba e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101886:	83 ec 0c             	sub    $0xc,%esp
f0101889:	6a 00                	push   $0x0
f010188b:	e8 06 f7 ff ff       	call   f0100f96 <page_alloc>
f0101890:	89 c3                	mov    %eax,%ebx
f0101892:	83 c4 10             	add    $0x10,%esp
f0101895:	85 c0                	test   %eax,%eax
f0101897:	75 19                	jne    f01018b2 <mem_init+0x580>
f0101899:	68 87 73 10 f0       	push   $0xf0107387
f010189e:	68 88 72 10 f0       	push   $0xf0107288
f01018a3:	68 b8 03 00 00       	push   $0x3b8
f01018a8:	68 45 72 10 f0       	push   $0xf0107245
f01018ad:	e8 8e e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018b2:	83 ec 0c             	sub    $0xc,%esp
f01018b5:	6a 00                	push   $0x0
f01018b7:	e8 da f6 ff ff       	call   f0100f96 <page_alloc>
f01018bc:	89 c6                	mov    %eax,%esi
f01018be:	83 c4 10             	add    $0x10,%esp
f01018c1:	85 c0                	test   %eax,%eax
f01018c3:	75 19                	jne    f01018de <mem_init+0x5ac>
f01018c5:	68 9d 73 10 f0       	push   $0xf010739d
f01018ca:	68 88 72 10 f0       	push   $0xf0107288
f01018cf:	68 b9 03 00 00       	push   $0x3b9
f01018d4:	68 45 72 10 f0       	push   $0xf0107245
f01018d9:	e8 62 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018de:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018e1:	75 19                	jne    f01018fc <mem_init+0x5ca>
f01018e3:	68 b3 73 10 f0       	push   $0xf01073b3
f01018e8:	68 88 72 10 f0       	push   $0xf0107288
f01018ed:	68 bc 03 00 00       	push   $0x3bc
f01018f2:	68 45 72 10 f0       	push   $0xf0107245
f01018f7:	e8 44 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018fc:	39 c3                	cmp    %eax,%ebx
f01018fe:	74 05                	je     f0101905 <mem_init+0x5d3>
f0101900:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101903:	75 19                	jne    f010191e <mem_init+0x5ec>
f0101905:	68 68 6a 10 f0       	push   $0xf0106a68
f010190a:	68 88 72 10 f0       	push   $0xf0107288
f010190f:	68 bd 03 00 00       	push   $0x3bd
f0101914:	68 45 72 10 f0       	push   $0xf0107245
f0101919:	e8 22 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010191e:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101923:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101926:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f010192d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101930:	83 ec 0c             	sub    $0xc,%esp
f0101933:	6a 00                	push   $0x0
f0101935:	e8 5c f6 ff ff       	call   f0100f96 <page_alloc>
f010193a:	83 c4 10             	add    $0x10,%esp
f010193d:	85 c0                	test   %eax,%eax
f010193f:	74 19                	je     f010195a <mem_init+0x628>
f0101941:	68 1c 74 10 f0       	push   $0xf010741c
f0101946:	68 88 72 10 f0       	push   $0xf0107288
f010194b:	68 c4 03 00 00       	push   $0x3c4
f0101950:	68 45 72 10 f0       	push   $0xf0107245
f0101955:	e8 e6 e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010195a:	83 ec 04             	sub    $0x4,%esp
f010195d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101960:	50                   	push   %eax
f0101961:	6a 00                	push   $0x0
f0101963:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101969:	e8 01 f8 ff ff       	call   f010116f <page_lookup>
f010196e:	83 c4 10             	add    $0x10,%esp
f0101971:	85 c0                	test   %eax,%eax
f0101973:	74 19                	je     f010198e <mem_init+0x65c>
f0101975:	68 a8 6a 10 f0       	push   $0xf0106aa8
f010197a:	68 88 72 10 f0       	push   $0xf0107288
f010197f:	68 c7 03 00 00       	push   $0x3c7
f0101984:	68 45 72 10 f0       	push   $0xf0107245
f0101989:	e8 b2 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010198e:	6a 02                	push   $0x2
f0101990:	6a 00                	push   $0x0
f0101992:	53                   	push   %ebx
f0101993:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101999:	e8 c1 f8 ff ff       	call   f010125f <page_insert>
f010199e:	83 c4 10             	add    $0x10,%esp
f01019a1:	85 c0                	test   %eax,%eax
f01019a3:	78 19                	js     f01019be <mem_init+0x68c>
f01019a5:	68 e0 6a 10 f0       	push   $0xf0106ae0
f01019aa:	68 88 72 10 f0       	push   $0xf0107288
f01019af:	68 ca 03 00 00       	push   $0x3ca
f01019b4:	68 45 72 10 f0       	push   $0xf0107245
f01019b9:	e8 82 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019be:	83 ec 0c             	sub    $0xc,%esp
f01019c1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019c4:	e8 44 f6 ff ff       	call   f010100d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019c9:	6a 02                	push   $0x2
f01019cb:	6a 00                	push   $0x0
f01019cd:	53                   	push   %ebx
f01019ce:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01019d4:	e8 86 f8 ff ff       	call   f010125f <page_insert>
f01019d9:	83 c4 20             	add    $0x20,%esp
f01019dc:	85 c0                	test   %eax,%eax
f01019de:	74 19                	je     f01019f9 <mem_init+0x6c7>
f01019e0:	68 10 6b 10 f0       	push   $0xf0106b10
f01019e5:	68 88 72 10 f0       	push   $0xf0107288
f01019ea:	68 ce 03 00 00       	push   $0x3ce
f01019ef:	68 45 72 10 f0       	push   $0xf0107245
f01019f4:	e8 47 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019f9:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019ff:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f0101a04:	89 c1                	mov    %eax,%ecx
f0101a06:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a09:	8b 17                	mov    (%edi),%edx
f0101a0b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a14:	29 c8                	sub    %ecx,%eax
f0101a16:	c1 f8 03             	sar    $0x3,%eax
f0101a19:	c1 e0 0c             	shl    $0xc,%eax
f0101a1c:	39 c2                	cmp    %eax,%edx
f0101a1e:	74 19                	je     f0101a39 <mem_init+0x707>
f0101a20:	68 40 6b 10 f0       	push   $0xf0106b40
f0101a25:	68 88 72 10 f0       	push   $0xf0107288
f0101a2a:	68 cf 03 00 00       	push   $0x3cf
f0101a2f:	68 45 72 10 f0       	push   $0xf0107245
f0101a34:	e8 07 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a39:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a3e:	89 f8                	mov    %edi,%eax
f0101a40:	e8 6d f0 ff ff       	call   f0100ab2 <check_va2pa>
f0101a45:	89 da                	mov    %ebx,%edx
f0101a47:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a4a:	c1 fa 03             	sar    $0x3,%edx
f0101a4d:	c1 e2 0c             	shl    $0xc,%edx
f0101a50:	39 d0                	cmp    %edx,%eax
f0101a52:	74 19                	je     f0101a6d <mem_init+0x73b>
f0101a54:	68 68 6b 10 f0       	push   $0xf0106b68
f0101a59:	68 88 72 10 f0       	push   $0xf0107288
f0101a5e:	68 d0 03 00 00       	push   $0x3d0
f0101a63:	68 45 72 10 f0       	push   $0xf0107245
f0101a68:	e8 d3 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a6d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a72:	74 19                	je     f0101a8d <mem_init+0x75b>
f0101a74:	68 6e 74 10 f0       	push   $0xf010746e
f0101a79:	68 88 72 10 f0       	push   $0xf0107288
f0101a7e:	68 d1 03 00 00       	push   $0x3d1
f0101a83:	68 45 72 10 f0       	push   $0xf0107245
f0101a88:	e8 b3 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a8d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a90:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a95:	74 19                	je     f0101ab0 <mem_init+0x77e>
f0101a97:	68 7f 74 10 f0       	push   $0xf010747f
f0101a9c:	68 88 72 10 f0       	push   $0xf0107288
f0101aa1:	68 d2 03 00 00       	push   $0x3d2
f0101aa6:	68 45 72 10 f0       	push   $0xf0107245
f0101aab:	e8 90 e5 ff ff       	call   f0100040 <_panic>
	
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ab0:	6a 02                	push   $0x2
f0101ab2:	68 00 10 00 00       	push   $0x1000
f0101ab7:	56                   	push   %esi
f0101ab8:	57                   	push   %edi
f0101ab9:	e8 a1 f7 ff ff       	call   f010125f <page_insert>
f0101abe:	83 c4 10             	add    $0x10,%esp
f0101ac1:	85 c0                	test   %eax,%eax
f0101ac3:	74 19                	je     f0101ade <mem_init+0x7ac>
f0101ac5:	68 98 6b 10 f0       	push   $0xf0106b98
f0101aca:	68 88 72 10 f0       	push   $0xf0107288
f0101acf:	68 d5 03 00 00       	push   $0x3d5
f0101ad4:	68 45 72 10 f0       	push   $0xf0107245
f0101ad9:	e8 62 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ade:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ae3:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101ae8:	e8 c5 ef ff ff       	call   f0100ab2 <check_va2pa>
f0101aed:	89 f2                	mov    %esi,%edx
f0101aef:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101af5:	c1 fa 03             	sar    $0x3,%edx
f0101af8:	c1 e2 0c             	shl    $0xc,%edx
f0101afb:	39 d0                	cmp    %edx,%eax
f0101afd:	74 19                	je     f0101b18 <mem_init+0x7e6>
f0101aff:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0101b04:	68 88 72 10 f0       	push   $0xf0107288
f0101b09:	68 d6 03 00 00       	push   $0x3d6
f0101b0e:	68 45 72 10 f0       	push   $0xf0107245
f0101b13:	e8 28 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b18:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b1d:	74 19                	je     f0101b38 <mem_init+0x806>
f0101b1f:	68 90 74 10 f0       	push   $0xf0107490
f0101b24:	68 88 72 10 f0       	push   $0xf0107288
f0101b29:	68 d7 03 00 00       	push   $0x3d7
f0101b2e:	68 45 72 10 f0       	push   $0xf0107245
f0101b33:	e8 08 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b38:	83 ec 0c             	sub    $0xc,%esp
f0101b3b:	6a 00                	push   $0x0
f0101b3d:	e8 54 f4 ff ff       	call   f0100f96 <page_alloc>
f0101b42:	83 c4 10             	add    $0x10,%esp
f0101b45:	85 c0                	test   %eax,%eax
f0101b47:	74 19                	je     f0101b62 <mem_init+0x830>
f0101b49:	68 1c 74 10 f0       	push   $0xf010741c
f0101b4e:	68 88 72 10 f0       	push   $0xf0107288
f0101b53:	68 da 03 00 00       	push   $0x3da
f0101b58:	68 45 72 10 f0       	push   $0xf0107245
f0101b5d:	e8 de e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b62:	6a 02                	push   $0x2
f0101b64:	68 00 10 00 00       	push   $0x1000
f0101b69:	56                   	push   %esi
f0101b6a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101b70:	e8 ea f6 ff ff       	call   f010125f <page_insert>
f0101b75:	83 c4 10             	add    $0x10,%esp
f0101b78:	85 c0                	test   %eax,%eax
f0101b7a:	74 19                	je     f0101b95 <mem_init+0x863>
f0101b7c:	68 98 6b 10 f0       	push   $0xf0106b98
f0101b81:	68 88 72 10 f0       	push   $0xf0107288
f0101b86:	68 dd 03 00 00       	push   $0x3dd
f0101b8b:	68 45 72 10 f0       	push   $0xf0107245
f0101b90:	e8 ab e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b95:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b9a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101b9f:	e8 0e ef ff ff       	call   f0100ab2 <check_va2pa>
f0101ba4:	89 f2                	mov    %esi,%edx
f0101ba6:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101bac:	c1 fa 03             	sar    $0x3,%edx
f0101baf:	c1 e2 0c             	shl    $0xc,%edx
f0101bb2:	39 d0                	cmp    %edx,%eax
f0101bb4:	74 19                	je     f0101bcf <mem_init+0x89d>
f0101bb6:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0101bbb:	68 88 72 10 f0       	push   $0xf0107288
f0101bc0:	68 de 03 00 00       	push   $0x3de
f0101bc5:	68 45 72 10 f0       	push   $0xf0107245
f0101bca:	e8 71 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bcf:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bd4:	74 19                	je     f0101bef <mem_init+0x8bd>
f0101bd6:	68 90 74 10 f0       	push   $0xf0107490
f0101bdb:	68 88 72 10 f0       	push   $0xf0107288
f0101be0:	68 df 03 00 00       	push   $0x3df
f0101be5:	68 45 72 10 f0       	push   $0xf0107245
f0101bea:	e8 51 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bef:	83 ec 0c             	sub    $0xc,%esp
f0101bf2:	6a 00                	push   $0x0
f0101bf4:	e8 9d f3 ff ff       	call   f0100f96 <page_alloc>
f0101bf9:	83 c4 10             	add    $0x10,%esp
f0101bfc:	85 c0                	test   %eax,%eax
f0101bfe:	74 19                	je     f0101c19 <mem_init+0x8e7>
f0101c00:	68 1c 74 10 f0       	push   $0xf010741c
f0101c05:	68 88 72 10 f0       	push   $0xf0107288
f0101c0a:	68 e3 03 00 00       	push   $0x3e3
f0101c0f:	68 45 72 10 f0       	push   $0xf0107245
f0101c14:	e8 27 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c19:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0101c1f:	8b 02                	mov    (%edx),%eax
f0101c21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c26:	89 c1                	mov    %eax,%ecx
f0101c28:	c1 e9 0c             	shr    $0xc,%ecx
f0101c2b:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0101c31:	72 15                	jb     f0101c48 <mem_init+0x916>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c33:	50                   	push   %eax
f0101c34:	68 a4 63 10 f0       	push   $0xf01063a4
f0101c39:	68 e6 03 00 00       	push   $0x3e6
f0101c3e:	68 45 72 10 f0       	push   $0xf0107245
f0101c43:	e8 f8 e3 ff ff       	call   f0100040 <_panic>
f0101c48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c50:	83 ec 04             	sub    $0x4,%esp
f0101c53:	6a 00                	push   $0x0
f0101c55:	68 00 10 00 00       	push   $0x1000
f0101c5a:	52                   	push   %edx
f0101c5b:	e8 0f f4 ff ff       	call   f010106f <pgdir_walk>
f0101c60:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c63:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c66:	83 c4 10             	add    $0x10,%esp
f0101c69:	39 d0                	cmp    %edx,%eax
f0101c6b:	74 19                	je     f0101c86 <mem_init+0x954>
f0101c6d:	68 04 6c 10 f0       	push   $0xf0106c04
f0101c72:	68 88 72 10 f0       	push   $0xf0107288
f0101c77:	68 e7 03 00 00       	push   $0x3e7
f0101c7c:	68 45 72 10 f0       	push   $0xf0107245
f0101c81:	e8 ba e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c86:	6a 06                	push   $0x6
f0101c88:	68 00 10 00 00       	push   $0x1000
f0101c8d:	56                   	push   %esi
f0101c8e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101c94:	e8 c6 f5 ff ff       	call   f010125f <page_insert>
f0101c99:	83 c4 10             	add    $0x10,%esp
f0101c9c:	85 c0                	test   %eax,%eax
f0101c9e:	74 19                	je     f0101cb9 <mem_init+0x987>
f0101ca0:	68 44 6c 10 f0       	push   $0xf0106c44
f0101ca5:	68 88 72 10 f0       	push   $0xf0107288
f0101caa:	68 ea 03 00 00       	push   $0x3ea
f0101caf:	68 45 72 10 f0       	push   $0xf0107245
f0101cb4:	e8 87 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cb9:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101cbf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc4:	89 f8                	mov    %edi,%eax
f0101cc6:	e8 e7 ed ff ff       	call   f0100ab2 <check_va2pa>
f0101ccb:	89 f2                	mov    %esi,%edx
f0101ccd:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101cd3:	c1 fa 03             	sar    $0x3,%edx
f0101cd6:	c1 e2 0c             	shl    $0xc,%edx
f0101cd9:	39 d0                	cmp    %edx,%eax
f0101cdb:	74 19                	je     f0101cf6 <mem_init+0x9c4>
f0101cdd:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0101ce2:	68 88 72 10 f0       	push   $0xf0107288
f0101ce7:	68 eb 03 00 00       	push   $0x3eb
f0101cec:	68 45 72 10 f0       	push   $0xf0107245
f0101cf1:	e8 4a e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101cf6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cfb:	74 19                	je     f0101d16 <mem_init+0x9e4>
f0101cfd:	68 90 74 10 f0       	push   $0xf0107490
f0101d02:	68 88 72 10 f0       	push   $0xf0107288
f0101d07:	68 ec 03 00 00       	push   $0x3ec
f0101d0c:	68 45 72 10 f0       	push   $0xf0107245
f0101d11:	e8 2a e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d16:	83 ec 04             	sub    $0x4,%esp
f0101d19:	6a 00                	push   $0x0
f0101d1b:	68 00 10 00 00       	push   $0x1000
f0101d20:	57                   	push   %edi
f0101d21:	e8 49 f3 ff ff       	call   f010106f <pgdir_walk>
f0101d26:	83 c4 10             	add    $0x10,%esp
f0101d29:	f6 00 04             	testb  $0x4,(%eax)
f0101d2c:	75 19                	jne    f0101d47 <mem_init+0xa15>
f0101d2e:	68 84 6c 10 f0       	push   $0xf0106c84
f0101d33:	68 88 72 10 f0       	push   $0xf0107288
f0101d38:	68 ed 03 00 00       	push   $0x3ed
f0101d3d:	68 45 72 10 f0       	push   $0xf0107245
f0101d42:	e8 f9 e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d47:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101d4c:	f6 00 04             	testb  $0x4,(%eax)
f0101d4f:	75 19                	jne    f0101d6a <mem_init+0xa38>
f0101d51:	68 a1 74 10 f0       	push   $0xf01074a1
f0101d56:	68 88 72 10 f0       	push   $0xf0107288
f0101d5b:	68 ee 03 00 00       	push   $0x3ee
f0101d60:	68 45 72 10 f0       	push   $0xf0107245
f0101d65:	e8 d6 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d6a:	6a 02                	push   $0x2
f0101d6c:	68 00 10 00 00       	push   $0x1000
f0101d71:	56                   	push   %esi
f0101d72:	50                   	push   %eax
f0101d73:	e8 e7 f4 ff ff       	call   f010125f <page_insert>
f0101d78:	83 c4 10             	add    $0x10,%esp
f0101d7b:	85 c0                	test   %eax,%eax
f0101d7d:	74 19                	je     f0101d98 <mem_init+0xa66>
f0101d7f:	68 98 6b 10 f0       	push   $0xf0106b98
f0101d84:	68 88 72 10 f0       	push   $0xf0107288
f0101d89:	68 f1 03 00 00       	push   $0x3f1
f0101d8e:	68 45 72 10 f0       	push   $0xf0107245
f0101d93:	e8 a8 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d98:	83 ec 04             	sub    $0x4,%esp
f0101d9b:	6a 00                	push   $0x0
f0101d9d:	68 00 10 00 00       	push   $0x1000
f0101da2:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101da8:	e8 c2 f2 ff ff       	call   f010106f <pgdir_walk>
f0101dad:	83 c4 10             	add    $0x10,%esp
f0101db0:	f6 00 02             	testb  $0x2,(%eax)
f0101db3:	75 19                	jne    f0101dce <mem_init+0xa9c>
f0101db5:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0101dba:	68 88 72 10 f0       	push   $0xf0107288
f0101dbf:	68 f2 03 00 00       	push   $0x3f2
f0101dc4:	68 45 72 10 f0       	push   $0xf0107245
f0101dc9:	e8 72 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dce:	83 ec 04             	sub    $0x4,%esp
f0101dd1:	6a 00                	push   $0x0
f0101dd3:	68 00 10 00 00       	push   $0x1000
f0101dd8:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101dde:	e8 8c f2 ff ff       	call   f010106f <pgdir_walk>
f0101de3:	83 c4 10             	add    $0x10,%esp
f0101de6:	f6 00 04             	testb  $0x4,(%eax)
f0101de9:	74 19                	je     f0101e04 <mem_init+0xad2>
f0101deb:	68 ec 6c 10 f0       	push   $0xf0106cec
f0101df0:	68 88 72 10 f0       	push   $0xf0107288
f0101df5:	68 f3 03 00 00       	push   $0x3f3
f0101dfa:	68 45 72 10 f0       	push   $0xf0107245
f0101dff:	e8 3c e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e04:	6a 02                	push   $0x2
f0101e06:	68 00 00 40 00       	push   $0x400000
f0101e0b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e0e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e14:	e8 46 f4 ff ff       	call   f010125f <page_insert>
f0101e19:	83 c4 10             	add    $0x10,%esp
f0101e1c:	85 c0                	test   %eax,%eax
f0101e1e:	78 19                	js     f0101e39 <mem_init+0xb07>
f0101e20:	68 24 6d 10 f0       	push   $0xf0106d24
f0101e25:	68 88 72 10 f0       	push   $0xf0107288
f0101e2a:	68 f6 03 00 00       	push   $0x3f6
f0101e2f:	68 45 72 10 f0       	push   $0xf0107245
f0101e34:	e8 07 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e39:	6a 02                	push   $0x2
f0101e3b:	68 00 10 00 00       	push   $0x1000
f0101e40:	53                   	push   %ebx
f0101e41:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e47:	e8 13 f4 ff ff       	call   f010125f <page_insert>
f0101e4c:	83 c4 10             	add    $0x10,%esp
f0101e4f:	85 c0                	test   %eax,%eax
f0101e51:	74 19                	je     f0101e6c <mem_init+0xb3a>
f0101e53:	68 5c 6d 10 f0       	push   $0xf0106d5c
f0101e58:	68 88 72 10 f0       	push   $0xf0107288
f0101e5d:	68 f9 03 00 00       	push   $0x3f9
f0101e62:	68 45 72 10 f0       	push   $0xf0107245
f0101e67:	e8 d4 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e6c:	83 ec 04             	sub    $0x4,%esp
f0101e6f:	6a 00                	push   $0x0
f0101e71:	68 00 10 00 00       	push   $0x1000
f0101e76:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e7c:	e8 ee f1 ff ff       	call   f010106f <pgdir_walk>
f0101e81:	83 c4 10             	add    $0x10,%esp
f0101e84:	f6 00 04             	testb  $0x4,(%eax)
f0101e87:	74 19                	je     f0101ea2 <mem_init+0xb70>
f0101e89:	68 ec 6c 10 f0       	push   $0xf0106cec
f0101e8e:	68 88 72 10 f0       	push   $0xf0107288
f0101e93:	68 fa 03 00 00       	push   $0x3fa
f0101e98:	68 45 72 10 f0       	push   $0xf0107245
f0101e9d:	e8 9e e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ea2:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101ea8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ead:	89 f8                	mov    %edi,%eax
f0101eaf:	e8 fe eb ff ff       	call   f0100ab2 <check_va2pa>
f0101eb4:	89 c1                	mov    %eax,%ecx
f0101eb6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101eb9:	89 d8                	mov    %ebx,%eax
f0101ebb:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101ec1:	c1 f8 03             	sar    $0x3,%eax
f0101ec4:	c1 e0 0c             	shl    $0xc,%eax
f0101ec7:	39 c1                	cmp    %eax,%ecx
f0101ec9:	74 19                	je     f0101ee4 <mem_init+0xbb2>
f0101ecb:	68 98 6d 10 f0       	push   $0xf0106d98
f0101ed0:	68 88 72 10 f0       	push   $0xf0107288
f0101ed5:	68 fd 03 00 00       	push   $0x3fd
f0101eda:	68 45 72 10 f0       	push   $0xf0107245
f0101edf:	e8 5c e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ee4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee9:	89 f8                	mov    %edi,%eax
f0101eeb:	e8 c2 eb ff ff       	call   f0100ab2 <check_va2pa>
f0101ef0:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ef3:	74 19                	je     f0101f0e <mem_init+0xbdc>
f0101ef5:	68 c4 6d 10 f0       	push   $0xf0106dc4
f0101efa:	68 88 72 10 f0       	push   $0xf0107288
f0101eff:	68 fe 03 00 00       	push   $0x3fe
f0101f04:	68 45 72 10 f0       	push   $0xf0107245
f0101f09:	e8 32 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f0e:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f13:	74 19                	je     f0101f2e <mem_init+0xbfc>
f0101f15:	68 b7 74 10 f0       	push   $0xf01074b7
f0101f1a:	68 88 72 10 f0       	push   $0xf0107288
f0101f1f:	68 00 04 00 00       	push   $0x400
f0101f24:	68 45 72 10 f0       	push   $0xf0107245
f0101f29:	e8 12 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f2e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f33:	74 19                	je     f0101f4e <mem_init+0xc1c>
f0101f35:	68 c8 74 10 f0       	push   $0xf01074c8
f0101f3a:	68 88 72 10 f0       	push   $0xf0107288
f0101f3f:	68 01 04 00 00       	push   $0x401
f0101f44:	68 45 72 10 f0       	push   $0xf0107245
f0101f49:	e8 f2 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f4e:	83 ec 0c             	sub    $0xc,%esp
f0101f51:	6a 00                	push   $0x0
f0101f53:	e8 3e f0 ff ff       	call   f0100f96 <page_alloc>
f0101f58:	83 c4 10             	add    $0x10,%esp
f0101f5b:	85 c0                	test   %eax,%eax
f0101f5d:	74 04                	je     f0101f63 <mem_init+0xc31>
f0101f5f:	39 c6                	cmp    %eax,%esi
f0101f61:	74 19                	je     f0101f7c <mem_init+0xc4a>
f0101f63:	68 f4 6d 10 f0       	push   $0xf0106df4
f0101f68:	68 88 72 10 f0       	push   $0xf0107288
f0101f6d:	68 04 04 00 00       	push   $0x404
f0101f72:	68 45 72 10 f0       	push   $0xf0107245
f0101f77:	e8 c4 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f7c:	83 ec 08             	sub    $0x8,%esp
f0101f7f:	6a 00                	push   $0x0
f0101f81:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101f87:	e8 7f f2 ff ff       	call   f010120b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f8c:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101f92:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f97:	89 f8                	mov    %edi,%eax
f0101f99:	e8 14 eb ff ff       	call   f0100ab2 <check_va2pa>
f0101f9e:	83 c4 10             	add    $0x10,%esp
f0101fa1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa4:	74 19                	je     f0101fbf <mem_init+0xc8d>
f0101fa6:	68 18 6e 10 f0       	push   $0xf0106e18
f0101fab:	68 88 72 10 f0       	push   $0xf0107288
f0101fb0:	68 08 04 00 00       	push   $0x408
f0101fb5:	68 45 72 10 f0       	push   $0xf0107245
f0101fba:	e8 81 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fbf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fc4:	89 f8                	mov    %edi,%eax
f0101fc6:	e8 e7 ea ff ff       	call   f0100ab2 <check_va2pa>
f0101fcb:	89 da                	mov    %ebx,%edx
f0101fcd:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101fd3:	c1 fa 03             	sar    $0x3,%edx
f0101fd6:	c1 e2 0c             	shl    $0xc,%edx
f0101fd9:	39 d0                	cmp    %edx,%eax
f0101fdb:	74 19                	je     f0101ff6 <mem_init+0xcc4>
f0101fdd:	68 c4 6d 10 f0       	push   $0xf0106dc4
f0101fe2:	68 88 72 10 f0       	push   $0xf0107288
f0101fe7:	68 09 04 00 00       	push   $0x409
f0101fec:	68 45 72 10 f0       	push   $0xf0107245
f0101ff1:	e8 4a e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ff6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ffb:	74 19                	je     f0102016 <mem_init+0xce4>
f0101ffd:	68 6e 74 10 f0       	push   $0xf010746e
f0102002:	68 88 72 10 f0       	push   $0xf0107288
f0102007:	68 0a 04 00 00       	push   $0x40a
f010200c:	68 45 72 10 f0       	push   $0xf0107245
f0102011:	e8 2a e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102016:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010201b:	74 19                	je     f0102036 <mem_init+0xd04>
f010201d:	68 c8 74 10 f0       	push   $0xf01074c8
f0102022:	68 88 72 10 f0       	push   $0xf0107288
f0102027:	68 0b 04 00 00       	push   $0x40b
f010202c:	68 45 72 10 f0       	push   $0xf0107245
f0102031:	e8 0a e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102036:	6a 00                	push   $0x0
f0102038:	68 00 10 00 00       	push   $0x1000
f010203d:	53                   	push   %ebx
f010203e:	57                   	push   %edi
f010203f:	e8 1b f2 ff ff       	call   f010125f <page_insert>
f0102044:	83 c4 10             	add    $0x10,%esp
f0102047:	85 c0                	test   %eax,%eax
f0102049:	74 19                	je     f0102064 <mem_init+0xd32>
f010204b:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0102050:	68 88 72 10 f0       	push   $0xf0107288
f0102055:	68 0e 04 00 00       	push   $0x40e
f010205a:	68 45 72 10 f0       	push   $0xf0107245
f010205f:	e8 dc df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102064:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102069:	75 19                	jne    f0102084 <mem_init+0xd52>
f010206b:	68 d9 74 10 f0       	push   $0xf01074d9
f0102070:	68 88 72 10 f0       	push   $0xf0107288
f0102075:	68 0f 04 00 00       	push   $0x40f
f010207a:	68 45 72 10 f0       	push   $0xf0107245
f010207f:	e8 bc df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102084:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102087:	74 19                	je     f01020a2 <mem_init+0xd70>
f0102089:	68 e5 74 10 f0       	push   $0xf01074e5
f010208e:	68 88 72 10 f0       	push   $0xf0107288
f0102093:	68 10 04 00 00       	push   $0x410
f0102098:	68 45 72 10 f0       	push   $0xf0107245
f010209d:	e8 9e df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01020a2:	83 ec 08             	sub    $0x8,%esp
f01020a5:	68 00 10 00 00       	push   $0x1000
f01020aa:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01020b0:	e8 56 f1 ff ff       	call   f010120b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020b5:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f01020bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01020c0:	89 f8                	mov    %edi,%eax
f01020c2:	e8 eb e9 ff ff       	call   f0100ab2 <check_va2pa>
f01020c7:	83 c4 10             	add    $0x10,%esp
f01020ca:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020cd:	74 19                	je     f01020e8 <mem_init+0xdb6>
f01020cf:	68 18 6e 10 f0       	push   $0xf0106e18
f01020d4:	68 88 72 10 f0       	push   $0xf0107288
f01020d9:	68 14 04 00 00       	push   $0x414
f01020de:	68 45 72 10 f0       	push   $0xf0107245
f01020e3:	e8 58 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020e8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ed:	89 f8                	mov    %edi,%eax
f01020ef:	e8 be e9 ff ff       	call   f0100ab2 <check_va2pa>
f01020f4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020f7:	74 19                	je     f0102112 <mem_init+0xde0>
f01020f9:	68 74 6e 10 f0       	push   $0xf0106e74
f01020fe:	68 88 72 10 f0       	push   $0xf0107288
f0102103:	68 15 04 00 00       	push   $0x415
f0102108:	68 45 72 10 f0       	push   $0xf0107245
f010210d:	e8 2e df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102112:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102117:	74 19                	je     f0102132 <mem_init+0xe00>
f0102119:	68 fa 74 10 f0       	push   $0xf01074fa
f010211e:	68 88 72 10 f0       	push   $0xf0107288
f0102123:	68 16 04 00 00       	push   $0x416
f0102128:	68 45 72 10 f0       	push   $0xf0107245
f010212d:	e8 0e df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102132:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102137:	74 19                	je     f0102152 <mem_init+0xe20>
f0102139:	68 c8 74 10 f0       	push   $0xf01074c8
f010213e:	68 88 72 10 f0       	push   $0xf0107288
f0102143:	68 17 04 00 00       	push   $0x417
f0102148:	68 45 72 10 f0       	push   $0xf0107245
f010214d:	e8 ee de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102152:	83 ec 0c             	sub    $0xc,%esp
f0102155:	6a 00                	push   $0x0
f0102157:	e8 3a ee ff ff       	call   f0100f96 <page_alloc>
f010215c:	83 c4 10             	add    $0x10,%esp
f010215f:	39 c3                	cmp    %eax,%ebx
f0102161:	75 04                	jne    f0102167 <mem_init+0xe35>
f0102163:	85 c0                	test   %eax,%eax
f0102165:	75 19                	jne    f0102180 <mem_init+0xe4e>
f0102167:	68 9c 6e 10 f0       	push   $0xf0106e9c
f010216c:	68 88 72 10 f0       	push   $0xf0107288
f0102171:	68 1a 04 00 00       	push   $0x41a
f0102176:	68 45 72 10 f0       	push   $0xf0107245
f010217b:	e8 c0 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102180:	83 ec 0c             	sub    $0xc,%esp
f0102183:	6a 00                	push   $0x0
f0102185:	e8 0c ee ff ff       	call   f0100f96 <page_alloc>
f010218a:	83 c4 10             	add    $0x10,%esp
f010218d:	85 c0                	test   %eax,%eax
f010218f:	74 19                	je     f01021aa <mem_init+0xe78>
f0102191:	68 1c 74 10 f0       	push   $0xf010741c
f0102196:	68 88 72 10 f0       	push   $0xf0107288
f010219b:	68 1d 04 00 00       	push   $0x41d
f01021a0:	68 45 72 10 f0       	push   $0xf0107245
f01021a5:	e8 96 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021aa:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f01021b0:	8b 11                	mov    (%ecx),%edx
f01021b2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bb:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01021c1:	c1 f8 03             	sar    $0x3,%eax
f01021c4:	c1 e0 0c             	shl    $0xc,%eax
f01021c7:	39 c2                	cmp    %eax,%edx
f01021c9:	74 19                	je     f01021e4 <mem_init+0xeb2>
f01021cb:	68 40 6b 10 f0       	push   $0xf0106b40
f01021d0:	68 88 72 10 f0       	push   $0xf0107288
f01021d5:	68 20 04 00 00       	push   $0x420
f01021da:	68 45 72 10 f0       	push   $0xf0107245
f01021df:	e8 5c de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01021e4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01021ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ed:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021f2:	74 19                	je     f010220d <mem_init+0xedb>
f01021f4:	68 7f 74 10 f0       	push   $0xf010747f
f01021f9:	68 88 72 10 f0       	push   $0xf0107288
f01021fe:	68 22 04 00 00       	push   $0x422
f0102203:	68 45 72 10 f0       	push   $0xf0107245
f0102208:	e8 33 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010220d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102210:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102216:	83 ec 0c             	sub    $0xc,%esp
f0102219:	50                   	push   %eax
f010221a:	e8 ee ed ff ff       	call   f010100d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010221f:	83 c4 0c             	add    $0xc,%esp
f0102222:	6a 01                	push   $0x1
f0102224:	68 00 10 40 00       	push   $0x401000
f0102229:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010222f:	e8 3b ee ff ff       	call   f010106f <pgdir_walk>
f0102234:	89 c7                	mov    %eax,%edi
f0102236:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102239:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010223e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102241:	8b 40 04             	mov    0x4(%eax),%eax
f0102244:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102249:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f010224f:	89 c2                	mov    %eax,%edx
f0102251:	c1 ea 0c             	shr    $0xc,%edx
f0102254:	83 c4 10             	add    $0x10,%esp
f0102257:	39 ca                	cmp    %ecx,%edx
f0102259:	72 15                	jb     f0102270 <mem_init+0xf3e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010225b:	50                   	push   %eax
f010225c:	68 a4 63 10 f0       	push   $0xf01063a4
f0102261:	68 29 04 00 00       	push   $0x429
f0102266:	68 45 72 10 f0       	push   $0xf0107245
f010226b:	e8 d0 dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102270:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102275:	39 c7                	cmp    %eax,%edi
f0102277:	74 19                	je     f0102292 <mem_init+0xf60>
f0102279:	68 0b 75 10 f0       	push   $0xf010750b
f010227e:	68 88 72 10 f0       	push   $0xf0107288
f0102283:	68 2a 04 00 00       	push   $0x42a
f0102288:	68 45 72 10 f0       	push   $0xf0107245
f010228d:	e8 ae dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102292:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102295:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010229c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010229f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022a5:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01022ab:	c1 f8 03             	sar    $0x3,%eax
f01022ae:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022b1:	89 c2                	mov    %eax,%edx
f01022b3:	c1 ea 0c             	shr    $0xc,%edx
f01022b6:	39 d1                	cmp    %edx,%ecx
f01022b8:	77 12                	ja     f01022cc <mem_init+0xf9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022ba:	50                   	push   %eax
f01022bb:	68 a4 63 10 f0       	push   $0xf01063a4
f01022c0:	6a 58                	push   $0x58
f01022c2:	68 6e 72 10 f0       	push   $0xf010726e
f01022c7:	e8 74 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01022cc:	83 ec 04             	sub    $0x4,%esp
f01022cf:	68 00 10 00 00       	push   $0x1000
f01022d4:	68 ff 00 00 00       	push   $0xff
f01022d9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01022de:	50                   	push   %eax
f01022df:	e8 d5 33 00 00       	call   f01056b9 <memset>
	page_free(pp0);
f01022e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01022e7:	89 3c 24             	mov    %edi,(%esp)
f01022ea:	e8 1e ed ff ff       	call   f010100d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022ef:	83 c4 0c             	add    $0xc,%esp
f01022f2:	6a 01                	push   $0x1
f01022f4:	6a 00                	push   $0x0
f01022f6:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01022fc:	e8 6e ed ff ff       	call   f010106f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102301:	89 fa                	mov    %edi,%edx
f0102303:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102309:	c1 fa 03             	sar    $0x3,%edx
f010230c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010230f:	89 d0                	mov    %edx,%eax
f0102311:	c1 e8 0c             	shr    $0xc,%eax
f0102314:	83 c4 10             	add    $0x10,%esp
f0102317:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f010231d:	72 12                	jb     f0102331 <mem_init+0xfff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010231f:	52                   	push   %edx
f0102320:	68 a4 63 10 f0       	push   $0xf01063a4
f0102325:	6a 58                	push   $0x58
f0102327:	68 6e 72 10 f0       	push   $0xf010726e
f010232c:	e8 0f dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102331:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102337:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010233a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102340:	f6 00 01             	testb  $0x1,(%eax)
f0102343:	74 19                	je     f010235e <mem_init+0x102c>
f0102345:	68 23 75 10 f0       	push   $0xf0107523
f010234a:	68 88 72 10 f0       	push   $0xf0107288
f010234f:	68 34 04 00 00       	push   $0x434
f0102354:	68 45 72 10 f0       	push   $0xf0107245
f0102359:	e8 e2 dc ff ff       	call   f0100040 <_panic>
f010235e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102361:	39 d0                	cmp    %edx,%eax
f0102363:	75 db                	jne    f0102340 <mem_init+0x100e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102365:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010236a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102370:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102373:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102379:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010237c:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240

	// free the pages we took
	page_free(pp0);
f0102382:	83 ec 0c             	sub    $0xc,%esp
f0102385:	50                   	push   %eax
f0102386:	e8 82 ec ff ff       	call   f010100d <page_free>
	page_free(pp1);
f010238b:	89 1c 24             	mov    %ebx,(%esp)
f010238e:	e8 7a ec ff ff       	call   f010100d <page_free>
	page_free(pp2);
f0102393:	89 34 24             	mov    %esi,(%esp)
f0102396:	e8 72 ec ff ff       	call   f010100d <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010239b:	83 c4 08             	add    $0x8,%esp
f010239e:	68 01 10 00 00       	push   $0x1001
f01023a3:	6a 00                	push   $0x0
f01023a5:	e8 1b ef ff ff       	call   f01012c5 <mmio_map_region>
f01023aa:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01023ac:	83 c4 08             	add    $0x8,%esp
f01023af:	68 00 10 00 00       	push   $0x1000
f01023b4:	6a 00                	push   $0x0
f01023b6:	e8 0a ef ff ff       	call   f01012c5 <mmio_map_region>
f01023bb:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01023bd:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01023c3:	83 c4 10             	add    $0x10,%esp
f01023c6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01023cc:	76 07                	jbe    f01023d5 <mem_init+0x10a3>
f01023ce:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01023d3:	76 19                	jbe    f01023ee <mem_init+0x10bc>
f01023d5:	68 c0 6e 10 f0       	push   $0xf0106ec0
f01023da:	68 88 72 10 f0       	push   $0xf0107288
f01023df:	68 44 04 00 00       	push   $0x444
f01023e4:	68 45 72 10 f0       	push   $0xf0107245
f01023e9:	e8 52 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01023ee:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01023f4:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023fa:	77 08                	ja     f0102404 <mem_init+0x10d2>
f01023fc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102402:	77 19                	ja     f010241d <mem_init+0x10eb>
f0102404:	68 e8 6e 10 f0       	push   $0xf0106ee8
f0102409:	68 88 72 10 f0       	push   $0xf0107288
f010240e:	68 45 04 00 00       	push   $0x445
f0102413:	68 45 72 10 f0       	push   $0xf0107245
f0102418:	e8 23 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010241d:	89 da                	mov    %ebx,%edx
f010241f:	09 f2                	or     %esi,%edx
f0102421:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102427:	74 19                	je     f0102442 <mem_init+0x1110>
f0102429:	68 10 6f 10 f0       	push   $0xf0106f10
f010242e:	68 88 72 10 f0       	push   $0xf0107288
f0102433:	68 47 04 00 00       	push   $0x447
f0102438:	68 45 72 10 f0       	push   $0xf0107245
f010243d:	e8 fe db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102442:	39 c6                	cmp    %eax,%esi
f0102444:	73 19                	jae    f010245f <mem_init+0x112d>
f0102446:	68 3a 75 10 f0       	push   $0xf010753a
f010244b:	68 88 72 10 f0       	push   $0xf0107288
f0102450:	68 49 04 00 00       	push   $0x449
f0102455:	68 45 72 10 f0       	push   $0xf0107245
f010245a:	e8 e1 db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010245f:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0102465:	89 da                	mov    %ebx,%edx
f0102467:	89 f8                	mov    %edi,%eax
f0102469:	e8 44 e6 ff ff       	call   f0100ab2 <check_va2pa>
f010246e:	85 c0                	test   %eax,%eax
f0102470:	74 19                	je     f010248b <mem_init+0x1159>
f0102472:	68 38 6f 10 f0       	push   $0xf0106f38
f0102477:	68 88 72 10 f0       	push   $0xf0107288
f010247c:	68 4b 04 00 00       	push   $0x44b
f0102481:	68 45 72 10 f0       	push   $0xf0107245
f0102486:	e8 b5 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010248b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102491:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102494:	89 c2                	mov    %eax,%edx
f0102496:	89 f8                	mov    %edi,%eax
f0102498:	e8 15 e6 ff ff       	call   f0100ab2 <check_va2pa>
f010249d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024a2:	74 19                	je     f01024bd <mem_init+0x118b>
f01024a4:	68 5c 6f 10 f0       	push   $0xf0106f5c
f01024a9:	68 88 72 10 f0       	push   $0xf0107288
f01024ae:	68 4c 04 00 00       	push   $0x44c
f01024b3:	68 45 72 10 f0       	push   $0xf0107245
f01024b8:	e8 83 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024bd:	89 f2                	mov    %esi,%edx
f01024bf:	89 f8                	mov    %edi,%eax
f01024c1:	e8 ec e5 ff ff       	call   f0100ab2 <check_va2pa>
f01024c6:	85 c0                	test   %eax,%eax
f01024c8:	74 19                	je     f01024e3 <mem_init+0x11b1>
f01024ca:	68 8c 6f 10 f0       	push   $0xf0106f8c
f01024cf:	68 88 72 10 f0       	push   $0xf0107288
f01024d4:	68 4d 04 00 00       	push   $0x44d
f01024d9:	68 45 72 10 f0       	push   $0xf0107245
f01024de:	e8 5d db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024e3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024e9:	89 f8                	mov    %edi,%eax
f01024eb:	e8 c2 e5 ff ff       	call   f0100ab2 <check_va2pa>
f01024f0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024f3:	74 19                	je     f010250e <mem_init+0x11dc>
f01024f5:	68 b0 6f 10 f0       	push   $0xf0106fb0
f01024fa:	68 88 72 10 f0       	push   $0xf0107288
f01024ff:	68 4e 04 00 00       	push   $0x44e
f0102504:	68 45 72 10 f0       	push   $0xf0107245
f0102509:	e8 32 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010250e:	83 ec 04             	sub    $0x4,%esp
f0102511:	6a 00                	push   $0x0
f0102513:	53                   	push   %ebx
f0102514:	57                   	push   %edi
f0102515:	e8 55 eb ff ff       	call   f010106f <pgdir_walk>
f010251a:	83 c4 10             	add    $0x10,%esp
f010251d:	f6 00 1a             	testb  $0x1a,(%eax)
f0102520:	75 19                	jne    f010253b <mem_init+0x1209>
f0102522:	68 dc 6f 10 f0       	push   $0xf0106fdc
f0102527:	68 88 72 10 f0       	push   $0xf0107288
f010252c:	68 50 04 00 00       	push   $0x450
f0102531:	68 45 72 10 f0       	push   $0xf0107245
f0102536:	e8 05 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010253b:	83 ec 04             	sub    $0x4,%esp
f010253e:	6a 00                	push   $0x0
f0102540:	53                   	push   %ebx
f0102541:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102547:	e8 23 eb ff ff       	call   f010106f <pgdir_walk>
f010254c:	8b 00                	mov    (%eax),%eax
f010254e:	83 c4 10             	add    $0x10,%esp
f0102551:	83 e0 04             	and    $0x4,%eax
f0102554:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102557:	74 19                	je     f0102572 <mem_init+0x1240>
f0102559:	68 20 70 10 f0       	push   $0xf0107020
f010255e:	68 88 72 10 f0       	push   $0xf0107288
f0102563:	68 51 04 00 00       	push   $0x451
f0102568:	68 45 72 10 f0       	push   $0xf0107245
f010256d:	e8 ce da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102572:	83 ec 04             	sub    $0x4,%esp
f0102575:	6a 00                	push   $0x0
f0102577:	53                   	push   %ebx
f0102578:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010257e:	e8 ec ea ff ff       	call   f010106f <pgdir_walk>
f0102583:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102589:	83 c4 0c             	add    $0xc,%esp
f010258c:	6a 00                	push   $0x0
f010258e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102591:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102597:	e8 d3 ea ff ff       	call   f010106f <pgdir_walk>
f010259c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01025a2:	83 c4 0c             	add    $0xc,%esp
f01025a5:	6a 00                	push   $0x0
f01025a7:	56                   	push   %esi
f01025a8:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01025ae:	e8 bc ea ff ff       	call   f010106f <pgdir_walk>
f01025b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01025b9:	c7 04 24 4c 75 10 f0 	movl   $0xf010754c,(%esp)
f01025c0:	e8 f6 10 00 00       	call   f01036bb <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct 
f01025c5:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025ca:	83 c4 10             	add    $0x10,%esp
f01025cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025d2:	77 15                	ja     f01025e9 <mem_init+0x12b7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025d4:	50                   	push   %eax
f01025d5:	68 c8 63 10 f0       	push   $0xf01063c8
f01025da:	68 c1 00 00 00       	push   $0xc1
f01025df:	68 45 72 10 f0       	push   $0xf0107245
f01025e4:	e8 57 da ff ff       	call   f0100040 <_panic>
f01025e9:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f01025ef:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01025f6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025fc:	83 ec 08             	sub    $0x8,%esp
f01025ff:	6a 05                	push   $0x5
f0102601:	05 00 00 00 10       	add    $0x10000000,%eax
f0102606:	50                   	push   %eax
f0102607:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010260c:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102611:	e8 ec ea ff ff       	call   f0101102 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct
f0102616:	a1 48 12 21 f0       	mov    0xf0211248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010261b:	83 c4 10             	add    $0x10,%esp
f010261e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102623:	77 15                	ja     f010263a <mem_init+0x1308>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102625:	50                   	push   %eax
f0102626:	68 c8 63 10 f0       	push   $0xf01063c8
f010262b:	68 cb 00 00 00       	push   $0xcb
f0102630:	68 45 72 10 f0       	push   $0xf0107245
f0102635:	e8 06 da ff ff       	call   f0100040 <_panic>
f010263a:	83 ec 08             	sub    $0x8,%esp
f010263d:	6a 05                	push   $0x5
f010263f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102644:	50                   	push   %eax
f0102645:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010264a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010264f:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102654:	e8 a9 ea ff ff       	call   f0101102 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102659:	83 c4 10             	add    $0x10,%esp
f010265c:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102661:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102666:	77 15                	ja     f010267d <mem_init+0x134b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102668:	50                   	push   %eax
f0102669:	68 c8 63 10 f0       	push   $0xf01063c8
f010266e:	68 d9 00 00 00       	push   $0xd9
f0102673:	68 45 72 10 f0       	push   $0xf0107245
f0102678:	e8 c3 d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, ROUNDUP(KSTKSIZE, 
f010267d:	83 ec 08             	sub    $0x8,%esp
f0102680:	6a 03                	push   $0x3
f0102682:	68 00 60 11 00       	push   $0x116000
f0102687:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010268c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102691:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102696:	e8 67 ea ff ff       	call   f0101102 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ((uint32_t)0xFFFFFFFF - KERNBASE) + 
f010269b:	83 c4 08             	add    $0x8,%esp
f010269e:	6a 03                	push   $0x3
f01026a0:	6a 00                	push   $0x0
f01026a2:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026a7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026ac:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01026b1:	e8 4c ea ff ff       	call   f0101102 <boot_map_region>
f01026b6:	c7 45 c4 00 30 21 f0 	movl   $0xf0213000,-0x3c(%ebp)
f01026bd:	83 c4 10             	add    $0x10,%esp
f01026c0:	bb 00 30 21 f0       	mov    $0xf0213000,%ebx
f01026c5:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026ca:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01026d0:	77 15                	ja     f01026e7 <mem_init+0x13b5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d2:	53                   	push   %ebx
f01026d3:	68 c8 63 10 f0       	push   $0xf01063c8
f01026d8:	68 1c 01 00 00       	push   $0x11c
f01026dd:	68 45 72 10 f0       	push   $0xf0107245
f01026e2:	e8 59 d9 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++){
		uintptr_t kstacktop = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop - KSTKSIZE, ROUNDUP(KSTKSIZE, 
f01026e7:	83 ec 08             	sub    $0x8,%esp
f01026ea:	6a 03                	push   $0x3
f01026ec:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01026f2:	50                   	push   %eax
f01026f3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026f8:	89 f2                	mov    %esi,%edx
f01026fa:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01026ff:	e8 fe e9 ff ff       	call   f0101102 <boot_map_region>
f0102704:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010270a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++){
f0102710:	83 c4 10             	add    $0x10,%esp
f0102713:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f0102718:	39 d8                	cmp    %ebx,%eax
f010271a:	75 ae                	jne    f01026ca <mem_init+0x1398>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010271c:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102722:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0102727:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010272a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102731:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102736:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102739:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010273f:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102742:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102747:	eb 55                	jmp    f010279e <mem_init+0x146c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102749:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010274f:	89 f8                	mov    %edi,%eax
f0102751:	e8 5c e3 ff ff       	call   f0100ab2 <check_va2pa>
f0102756:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010275d:	77 15                	ja     f0102774 <mem_init+0x1442>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010275f:	56                   	push   %esi
f0102760:	68 c8 63 10 f0       	push   $0xf01063c8
f0102765:	68 69 03 00 00       	push   $0x369
f010276a:	68 45 72 10 f0       	push   $0xf0107245
f010276f:	e8 cc d8 ff ff       	call   f0100040 <_panic>
f0102774:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010277b:	39 c2                	cmp    %eax,%edx
f010277d:	74 19                	je     f0102798 <mem_init+0x1466>
f010277f:	68 54 70 10 f0       	push   $0xf0107054
f0102784:	68 88 72 10 f0       	push   $0xf0107288
f0102789:	68 69 03 00 00       	push   $0x369
f010278e:	68 45 72 10 f0       	push   $0xf0107245
f0102793:	e8 a8 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102798:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010279e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01027a1:	77 a6                	ja     f0102749 <mem_init+0x1417>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027a3:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a9:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027ac:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01027b1:	89 da                	mov    %ebx,%edx
f01027b3:	89 f8                	mov    %edi,%eax
f01027b5:	e8 f8 e2 ff ff       	call   f0100ab2 <check_va2pa>
f01027ba:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01027c1:	77 15                	ja     f01027d8 <mem_init+0x14a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027c3:	56                   	push   %esi
f01027c4:	68 c8 63 10 f0       	push   $0xf01063c8
f01027c9:	68 6e 03 00 00       	push   $0x36e
f01027ce:	68 45 72 10 f0       	push   $0xf0107245
f01027d3:	e8 68 d8 ff ff       	call   f0100040 <_panic>
f01027d8:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01027df:	39 d0                	cmp    %edx,%eax
f01027e1:	74 19                	je     f01027fc <mem_init+0x14ca>
f01027e3:	68 88 70 10 f0       	push   $0xf0107088
f01027e8:	68 88 72 10 f0       	push   $0xf0107288
f01027ed:	68 6e 03 00 00       	push   $0x36e
f01027f2:	68 45 72 10 f0       	push   $0xf0107245
f01027f7:	e8 44 d8 ff ff       	call   f0100040 <_panic>
f01027fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102802:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102808:	75 a7                	jne    f01027b1 <mem_init+0x147f>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010280a:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010280d:	c1 e6 0c             	shl    $0xc,%esi
f0102810:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102815:	eb 30                	jmp    f0102847 <mem_init+0x1515>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102817:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010281d:	89 f8                	mov    %edi,%eax
f010281f:	e8 8e e2 ff ff       	call   f0100ab2 <check_va2pa>
f0102824:	39 c3                	cmp    %eax,%ebx
f0102826:	74 19                	je     f0102841 <mem_init+0x150f>
f0102828:	68 bc 70 10 f0       	push   $0xf01070bc
f010282d:	68 88 72 10 f0       	push   $0xf0107288
f0102832:	68 72 03 00 00       	push   $0x372
f0102837:	68 45 72 10 f0       	push   $0xf0107245
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102841:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102847:	39 f3                	cmp    %esi,%ebx
f0102849:	72 cc                	jb     f0102817 <mem_init+0x14e5>
f010284b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102850:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102853:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102856:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102859:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010285f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102862:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102864:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102867:	05 00 80 00 20       	add    $0x20008000,%eax
f010286c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010286f:	89 da                	mov    %ebx,%edx
f0102871:	89 f8                	mov    %edi,%eax
f0102873:	e8 3a e2 ff ff       	call   f0100ab2 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102878:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010287e:	77 15                	ja     f0102895 <mem_init+0x1563>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102880:	56                   	push   %esi
f0102881:	68 c8 63 10 f0       	push   $0xf01063c8
f0102886:	68 7a 03 00 00       	push   $0x37a
f010288b:	68 45 72 10 f0       	push   $0xf0107245
f0102890:	e8 ab d7 ff ff       	call   f0100040 <_panic>
f0102895:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102898:	8d 94 0b 00 30 21 f0 	lea    -0xfded000(%ebx,%ecx,1),%edx
f010289f:	39 d0                	cmp    %edx,%eax
f01028a1:	74 19                	je     f01028bc <mem_init+0x158a>
f01028a3:	68 e4 70 10 f0       	push   $0xf01070e4
f01028a8:	68 88 72 10 f0       	push   $0xf0107288
f01028ad:	68 7a 03 00 00       	push   $0x37a
f01028b2:	68 45 72 10 f0       	push   $0xf0107245
f01028b7:	e8 84 d7 ff ff       	call   f0100040 <_panic>
f01028bc:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028c2:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f01028c5:	75 a8                	jne    f010286f <mem_init+0x153d>
f01028c7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028ca:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028d0:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028d3:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01028d5:	89 da                	mov    %ebx,%edx
f01028d7:	89 f8                	mov    %edi,%eax
f01028d9:	e8 d4 e1 ff ff       	call   f0100ab2 <check_va2pa>
f01028de:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028e1:	74 19                	je     f01028fc <mem_init+0x15ca>
f01028e3:	68 2c 71 10 f0       	push   $0xf010712c
f01028e8:	68 88 72 10 f0       	push   $0xf0107288
f01028ed:	68 7c 03 00 00       	push   $0x37c
f01028f2:	68 45 72 10 f0       	push   $0xf0107245
f01028f7:	e8 44 d7 ff ff       	call   f0100040 <_panic>
f01028fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102902:	39 f3                	cmp    %esi,%ebx
f0102904:	75 cf                	jne    f01028d5 <mem_init+0x15a3>
f0102906:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102909:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102910:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102917:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010291d:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f0102922:	39 f0                	cmp    %esi,%eax
f0102924:	0f 85 2c ff ff ff    	jne    f0102856 <mem_init+0x1524>
f010292a:	b8 00 00 00 00       	mov    $0x0,%eax
f010292f:	eb 2a                	jmp    f010295b <mem_init+0x1629>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102931:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102937:	83 fa 04             	cmp    $0x4,%edx
f010293a:	77 1f                	ja     f010295b <mem_init+0x1629>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010293c:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102940:	75 7e                	jne    f01029c0 <mem_init+0x168e>
f0102942:	68 65 75 10 f0       	push   $0xf0107565
f0102947:	68 88 72 10 f0       	push   $0xf0107288
f010294c:	68 87 03 00 00       	push   $0x387
f0102951:	68 45 72 10 f0       	push   $0xf0107245
f0102956:	e8 e5 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010295b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102960:	76 3f                	jbe    f01029a1 <mem_init+0x166f>
				assert(pgdir[i] & PTE_P);
f0102962:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102965:	f6 c2 01             	test   $0x1,%dl
f0102968:	75 19                	jne    f0102983 <mem_init+0x1651>
f010296a:	68 65 75 10 f0       	push   $0xf0107565
f010296f:	68 88 72 10 f0       	push   $0xf0107288
f0102974:	68 8b 03 00 00       	push   $0x38b
f0102979:	68 45 72 10 f0       	push   $0xf0107245
f010297e:	e8 bd d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102983:	f6 c2 02             	test   $0x2,%dl
f0102986:	75 38                	jne    f01029c0 <mem_init+0x168e>
f0102988:	68 76 75 10 f0       	push   $0xf0107576
f010298d:	68 88 72 10 f0       	push   $0xf0107288
f0102992:	68 8c 03 00 00       	push   $0x38c
f0102997:	68 45 72 10 f0       	push   $0xf0107245
f010299c:	e8 9f d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029a1:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029a5:	74 19                	je     f01029c0 <mem_init+0x168e>
f01029a7:	68 87 75 10 f0       	push   $0xf0107587
f01029ac:	68 88 72 10 f0       	push   $0xf0107288
f01029b1:	68 8e 03 00 00       	push   $0x38e
f01029b6:	68 45 72 10 f0       	push   $0xf0107245
f01029bb:	e8 80 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01029c0:	83 c0 01             	add    $0x1,%eax
f01029c3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01029c8:	0f 86 63 ff ff ff    	jbe    f0102931 <mem_init+0x15ff>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029ce:	83 ec 0c             	sub    $0xc,%esp
f01029d1:	68 50 71 10 f0       	push   $0xf0107150
f01029d6:	e8 e0 0c 00 00       	call   f01036bb <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029db:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029e0:	83 c4 10             	add    $0x10,%esp
f01029e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029e8:	77 15                	ja     f01029ff <mem_init+0x16cd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029ea:	50                   	push   %eax
f01029eb:	68 c8 63 10 f0       	push   $0xf01063c8
f01029f0:	68 f3 00 00 00       	push   $0xf3
f01029f5:	68 45 72 10 f0       	push   $0xf0107245
f01029fa:	e8 41 d6 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01029ff:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a04:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a07:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a0c:	e8 8d e1 ff ff       	call   f0100b9e <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102a11:	0f 20 c0             	mov    %cr0,%eax
f0102a14:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102a17:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a1c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a1f:	83 ec 0c             	sub    $0xc,%esp
f0102a22:	6a 00                	push   $0x0
f0102a24:	e8 6d e5 ff ff       	call   f0100f96 <page_alloc>
f0102a29:	89 c3                	mov    %eax,%ebx
f0102a2b:	83 c4 10             	add    $0x10,%esp
f0102a2e:	85 c0                	test   %eax,%eax
f0102a30:	75 19                	jne    f0102a4b <mem_init+0x1719>
f0102a32:	68 71 73 10 f0       	push   $0xf0107371
f0102a37:	68 88 72 10 f0       	push   $0xf0107288
f0102a3c:	68 66 04 00 00       	push   $0x466
f0102a41:	68 45 72 10 f0       	push   $0xf0107245
f0102a46:	e8 f5 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a4b:	83 ec 0c             	sub    $0xc,%esp
f0102a4e:	6a 00                	push   $0x0
f0102a50:	e8 41 e5 ff ff       	call   f0100f96 <page_alloc>
f0102a55:	89 c7                	mov    %eax,%edi
f0102a57:	83 c4 10             	add    $0x10,%esp
f0102a5a:	85 c0                	test   %eax,%eax
f0102a5c:	75 19                	jne    f0102a77 <mem_init+0x1745>
f0102a5e:	68 87 73 10 f0       	push   $0xf0107387
f0102a63:	68 88 72 10 f0       	push   $0xf0107288
f0102a68:	68 67 04 00 00       	push   $0x467
f0102a6d:	68 45 72 10 f0       	push   $0xf0107245
f0102a72:	e8 c9 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a77:	83 ec 0c             	sub    $0xc,%esp
f0102a7a:	6a 00                	push   $0x0
f0102a7c:	e8 15 e5 ff ff       	call   f0100f96 <page_alloc>
f0102a81:	89 c6                	mov    %eax,%esi
f0102a83:	83 c4 10             	add    $0x10,%esp
f0102a86:	85 c0                	test   %eax,%eax
f0102a88:	75 19                	jne    f0102aa3 <mem_init+0x1771>
f0102a8a:	68 9d 73 10 f0       	push   $0xf010739d
f0102a8f:	68 88 72 10 f0       	push   $0xf0107288
f0102a94:	68 68 04 00 00       	push   $0x468
f0102a99:	68 45 72 10 f0       	push   $0xf0107245
f0102a9e:	e8 9d d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102aa3:	83 ec 0c             	sub    $0xc,%esp
f0102aa6:	53                   	push   %ebx
f0102aa7:	e8 61 e5 ff ff       	call   f010100d <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aac:	89 f8                	mov    %edi,%eax
f0102aae:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102ab4:	c1 f8 03             	sar    $0x3,%eax
f0102ab7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102aba:	89 c2                	mov    %eax,%edx
f0102abc:	c1 ea 0c             	shr    $0xc,%edx
f0102abf:	83 c4 10             	add    $0x10,%esp
f0102ac2:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102ac8:	72 12                	jb     f0102adc <mem_init+0x17aa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aca:	50                   	push   %eax
f0102acb:	68 a4 63 10 f0       	push   $0xf01063a4
f0102ad0:	6a 58                	push   $0x58
f0102ad2:	68 6e 72 10 f0       	push   $0xf010726e
f0102ad7:	e8 64 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102adc:	83 ec 04             	sub    $0x4,%esp
f0102adf:	68 00 10 00 00       	push   $0x1000
f0102ae4:	6a 01                	push   $0x1
f0102ae6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aeb:	50                   	push   %eax
f0102aec:	e8 c8 2b 00 00       	call   f01056b9 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102af1:	89 f0                	mov    %esi,%eax
f0102af3:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102af9:	c1 f8 03             	sar    $0x3,%eax
f0102afc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102aff:	89 c2                	mov    %eax,%edx
f0102b01:	c1 ea 0c             	shr    $0xc,%edx
f0102b04:	83 c4 10             	add    $0x10,%esp
f0102b07:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102b0d:	72 12                	jb     f0102b21 <mem_init+0x17ef>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b0f:	50                   	push   %eax
f0102b10:	68 a4 63 10 f0       	push   $0xf01063a4
f0102b15:	6a 58                	push   $0x58
f0102b17:	68 6e 72 10 f0       	push   $0xf010726e
f0102b1c:	e8 1f d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b21:	83 ec 04             	sub    $0x4,%esp
f0102b24:	68 00 10 00 00       	push   $0x1000
f0102b29:	6a 02                	push   $0x2
f0102b2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b30:	50                   	push   %eax
f0102b31:	e8 83 2b 00 00       	call   f01056b9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b36:	6a 02                	push   $0x2
f0102b38:	68 00 10 00 00       	push   $0x1000
f0102b3d:	57                   	push   %edi
f0102b3e:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102b44:	e8 16 e7 ff ff       	call   f010125f <page_insert>
	assert(pp1->pp_ref == 1);
f0102b49:	83 c4 20             	add    $0x20,%esp
f0102b4c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b51:	74 19                	je     f0102b6c <mem_init+0x183a>
f0102b53:	68 6e 74 10 f0       	push   $0xf010746e
f0102b58:	68 88 72 10 f0       	push   $0xf0107288
f0102b5d:	68 6d 04 00 00       	push   $0x46d
f0102b62:	68 45 72 10 f0       	push   $0xf0107245
f0102b67:	e8 d4 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b6c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b73:	01 01 01 
f0102b76:	74 19                	je     f0102b91 <mem_init+0x185f>
f0102b78:	68 70 71 10 f0       	push   $0xf0107170
f0102b7d:	68 88 72 10 f0       	push   $0xf0107288
f0102b82:	68 6e 04 00 00       	push   $0x46e
f0102b87:	68 45 72 10 f0       	push   $0xf0107245
f0102b8c:	e8 af d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b91:	6a 02                	push   $0x2
f0102b93:	68 00 10 00 00       	push   $0x1000
f0102b98:	56                   	push   %esi
f0102b99:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102b9f:	e8 bb e6 ff ff       	call   f010125f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ba4:	83 c4 10             	add    $0x10,%esp
f0102ba7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bae:	02 02 02 
f0102bb1:	74 19                	je     f0102bcc <mem_init+0x189a>
f0102bb3:	68 94 71 10 f0       	push   $0xf0107194
f0102bb8:	68 88 72 10 f0       	push   $0xf0107288
f0102bbd:	68 70 04 00 00       	push   $0x470
f0102bc2:	68 45 72 10 f0       	push   $0xf0107245
f0102bc7:	e8 74 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102bcc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102bd1:	74 19                	je     f0102bec <mem_init+0x18ba>
f0102bd3:	68 90 74 10 f0       	push   $0xf0107490
f0102bd8:	68 88 72 10 f0       	push   $0xf0107288
f0102bdd:	68 71 04 00 00       	push   $0x471
f0102be2:	68 45 72 10 f0       	push   $0xf0107245
f0102be7:	e8 54 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bec:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bf1:	74 19                	je     f0102c0c <mem_init+0x18da>
f0102bf3:	68 fa 74 10 f0       	push   $0xf01074fa
f0102bf8:	68 88 72 10 f0       	push   $0xf0107288
f0102bfd:	68 72 04 00 00       	push   $0x472
f0102c02:	68 45 72 10 f0       	push   $0xf0107245
f0102c07:	e8 34 d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c0c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c13:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c16:	89 f0                	mov    %esi,%eax
f0102c18:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102c1e:	c1 f8 03             	sar    $0x3,%eax
f0102c21:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c24:	89 c2                	mov    %eax,%edx
f0102c26:	c1 ea 0c             	shr    $0xc,%edx
f0102c29:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102c2f:	72 12                	jb     f0102c43 <mem_init+0x1911>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c31:	50                   	push   %eax
f0102c32:	68 a4 63 10 f0       	push   $0xf01063a4
f0102c37:	6a 58                	push   $0x58
f0102c39:	68 6e 72 10 f0       	push   $0xf010726e
f0102c3e:	e8 fd d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c43:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c4a:	03 03 03 
f0102c4d:	74 19                	je     f0102c68 <mem_init+0x1936>
f0102c4f:	68 b8 71 10 f0       	push   $0xf01071b8
f0102c54:	68 88 72 10 f0       	push   $0xf0107288
f0102c59:	68 74 04 00 00       	push   $0x474
f0102c5e:	68 45 72 10 f0       	push   $0xf0107245
f0102c63:	e8 d8 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c68:	83 ec 08             	sub    $0x8,%esp
f0102c6b:	68 00 10 00 00       	push   $0x1000
f0102c70:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102c76:	e8 90 e5 ff ff       	call   f010120b <page_remove>
	assert(pp2->pp_ref == 0);
f0102c7b:	83 c4 10             	add    $0x10,%esp
f0102c7e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c83:	74 19                	je     f0102c9e <mem_init+0x196c>
f0102c85:	68 c8 74 10 f0       	push   $0xf01074c8
f0102c8a:	68 88 72 10 f0       	push   $0xf0107288
f0102c8f:	68 76 04 00 00       	push   $0x476
f0102c94:	68 45 72 10 f0       	push   $0xf0107245
f0102c99:	e8 a2 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c9e:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102ca4:	8b 11                	mov    (%ecx),%edx
f0102ca6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102cac:	89 d8                	mov    %ebx,%eax
f0102cae:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102cb4:	c1 f8 03             	sar    $0x3,%eax
f0102cb7:	c1 e0 0c             	shl    $0xc,%eax
f0102cba:	39 c2                	cmp    %eax,%edx
f0102cbc:	74 19                	je     f0102cd7 <mem_init+0x19a5>
f0102cbe:	68 40 6b 10 f0       	push   $0xf0106b40
f0102cc3:	68 88 72 10 f0       	push   $0xf0107288
f0102cc8:	68 79 04 00 00       	push   $0x479
f0102ccd:	68 45 72 10 f0       	push   $0xf0107245
f0102cd2:	e8 69 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102cd7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cdd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ce2:	74 19                	je     f0102cfd <mem_init+0x19cb>
f0102ce4:	68 7f 74 10 f0       	push   $0xf010747f
f0102ce9:	68 88 72 10 f0       	push   $0xf0107288
f0102cee:	68 7b 04 00 00       	push   $0x47b
f0102cf3:	68 45 72 10 f0       	push   $0xf0107245
f0102cf8:	e8 43 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102cfd:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d03:	83 ec 0c             	sub    $0xc,%esp
f0102d06:	53                   	push   %ebx
f0102d07:	e8 01 e3 ff ff       	call   f010100d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d0c:	c7 04 24 e4 71 10 f0 	movl   $0xf01071e4,(%esp)
f0102d13:	e8 a3 09 00 00       	call   f01036bb <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d18:	83 c4 10             	add    $0x10,%esp
f0102d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d1e:	5b                   	pop    %ebx
f0102d1f:	5e                   	pop    %esi
f0102d20:	5f                   	pop    %edi
f0102d21:	5d                   	pop    %ebp
f0102d22:	c3                   	ret    

f0102d23 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d23:	55                   	push   %ebp
f0102d24:	89 e5                	mov    %esp,%ebp
f0102d26:	57                   	push   %edi
f0102d27:	56                   	push   %esi
f0102d28:	53                   	push   %ebx
f0102d29:	83 ec 1c             	sub    $0x1c,%esp
f0102d2c:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	const void* va_start = ROUNDDOWN(va, PGSIZE);
f0102d2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d32:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	const void* va_end = va + len;
f0102d38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d3b:	03 45 10             	add    0x10(%ebp),%eax
f0102d3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// No page table allocated
			user_mem_check_addr = (iva < va)? ((uintptr_t)va):
				((uintptr_t)iva);
			return -E_FAULT;
		}
		if ((*pte & (perm | PTE_P)) != (perm | PTE_P)){
f0102d41:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d44:	83 ce 01             	or     $0x1,%esi
{
	// LAB 3: Your code here.
	const void* va_start = ROUNDDOWN(va, PGSIZE);
	const void* va_end = va + len;
	const void* iva;
	for (iva = va_start; iva < va_end; iva += PGSIZE){
f0102d47:	eb 6f                	jmp    f0102db8 <user_mem_check+0x95>
		if ((uintptr_t)iva >= ULIM) {
f0102d49:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0102d4c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d52:	76 15                	jbe    f0102d69 <user_mem_check+0x46>
			user_mem_check_addr = (iva < va)? ((uintptr_t)va): 
f0102d54:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d57:	89 d8                	mov    %ebx,%eax
f0102d59:	0f 42 45 0c          	cmovb  0xc(%ebp),%eax
f0102d5d:	a3 3c 12 21 f0       	mov    %eax,0xf021123c
				((uintptr_t)iva);
			return -E_FAULT;
f0102d62:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d67:	eb 59                	jmp    f0102dc2 <user_mem_check+0x9f>
		}
		pte_t* pte = pgdir_walk(env->env_pgdir, iva, 0);
f0102d69:	83 ec 04             	sub    $0x4,%esp
f0102d6c:	6a 00                	push   $0x0
f0102d6e:	53                   	push   %ebx
f0102d6f:	ff 77 60             	pushl  0x60(%edi)
f0102d72:	e8 f8 e2 ff ff       	call   f010106f <pgdir_walk>
		if (!pte) {
f0102d77:	83 c4 10             	add    $0x10,%esp
f0102d7a:	85 c0                	test   %eax,%eax
f0102d7c:	75 16                	jne    f0102d94 <user_mem_check+0x71>
			// No page table allocated
			user_mem_check_addr = (iva < va)? ((uintptr_t)va):
f0102d7e:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d81:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d84:	0f 42 45 0c          	cmovb  0xc(%ebp),%eax
f0102d88:	a3 3c 12 21 f0       	mov    %eax,0xf021123c
				((uintptr_t)iva);
			return -E_FAULT;
f0102d8d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d92:	eb 2e                	jmp    f0102dc2 <user_mem_check+0x9f>
		}
		if ((*pte & (perm | PTE_P)) != (perm | PTE_P)){
f0102d94:	89 f2                	mov    %esi,%edx
f0102d96:	23 10                	and    (%eax),%edx
f0102d98:	39 d6                	cmp    %edx,%esi
f0102d9a:	74 16                	je     f0102db2 <user_mem_check+0x8f>
			// Page table allocated, but no page allocated or no perm
			user_mem_check_addr = (iva < va)? ((uintptr_t)va):
f0102d9c:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102da2:	0f 42 45 0c          	cmovb  0xc(%ebp),%eax
f0102da6:	a3 3c 12 21 f0       	mov    %eax,0xf021123c
				((uintptr_t)iva);
			return -E_FAULT;
f0102dab:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102db0:	eb 10                	jmp    f0102dc2 <user_mem_check+0x9f>
{
	// LAB 3: Your code here.
	const void* va_start = ROUNDDOWN(va, PGSIZE);
	const void* va_end = va + len;
	const void* iva;
	for (iva = va_start; iva < va_end; iva += PGSIZE){
f0102db2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102db8:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102dbb:	72 8c                	jb     f0102d49 <user_mem_check+0x26>
				((uintptr_t)iva);
			return -E_FAULT;
		}
	}

	return 0;
f0102dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dc5:	5b                   	pop    %ebx
f0102dc6:	5e                   	pop    %esi
f0102dc7:	5f                   	pop    %edi
f0102dc8:	5d                   	pop    %ebp
f0102dc9:	c3                   	ret    

f0102dca <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102dca:	55                   	push   %ebp
f0102dcb:	89 e5                	mov    %esp,%ebp
f0102dcd:	53                   	push   %ebx
f0102dce:	83 ec 04             	sub    $0x4,%esp
f0102dd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102dd4:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dd7:	83 c8 04             	or     $0x4,%eax
f0102dda:	50                   	push   %eax
f0102ddb:	ff 75 10             	pushl  0x10(%ebp)
f0102dde:	ff 75 0c             	pushl  0xc(%ebp)
f0102de1:	53                   	push   %ebx
f0102de2:	e8 3c ff ff ff       	call   f0102d23 <user_mem_check>
f0102de7:	83 c4 10             	add    $0x10,%esp
f0102dea:	85 c0                	test   %eax,%eax
f0102dec:	79 21                	jns    f0102e0f <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102dee:	83 ec 04             	sub    $0x4,%esp
f0102df1:	ff 35 3c 12 21 f0    	pushl  0xf021123c
f0102df7:	ff 73 48             	pushl  0x48(%ebx)
f0102dfa:	68 10 72 10 f0       	push   $0xf0107210
f0102dff:	e8 b7 08 00 00       	call   f01036bb <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e04:	89 1c 24             	mov    %ebx,(%esp)
f0102e07:	e8 ac 05 00 00       	call   f01033b8 <env_destroy>
f0102e0c:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e12:	c9                   	leave  
f0102e13:	c3                   	ret    

f0102e14 <region_alloc>:
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	if (len == 0) return;
f0102e14:	85 c9                	test   %ecx,%ecx
f0102e16:	74 6a                	je     f0102e82 <region_alloc+0x6e>
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e18:	55                   	push   %ebp
f0102e19:	89 e5                	mov    %esp,%ebp
f0102e1b:	57                   	push   %edi
f0102e1c:	56                   	push   %esi
f0102e1d:	53                   	push   %ebx
f0102e1e:	83 ec 0c             	sub    $0xc,%esp
f0102e21:	89 d3                	mov    %edx,%ebx
f0102e23:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	if (len == 0) return;
	uint32_t va_end = ROUNDUP((uint32_t)va + len, PGSIZE);
f0102e25:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102e2c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uint32_t va_start = ROUNDDOWN((uint32_t)va, PGSIZE);
f0102e32:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	len = va_end - va_start;

	uint32_t i = va_start;
	for (; i < va_end; i += PGSIZE){
f0102e38:	eb 3d                	jmp    f0102e77 <region_alloc+0x63>
		struct PageInfo* pp = page_alloc(0);
f0102e3a:	83 ec 0c             	sub    $0xc,%esp
f0102e3d:	6a 00                	push   $0x0
f0102e3f:	e8 52 e1 ff ff       	call   f0100f96 <page_alloc>
		if (!pp) panic("No memory for env");
f0102e44:	83 c4 10             	add    $0x10,%esp
f0102e47:	85 c0                	test   %eax,%eax
f0102e49:	75 17                	jne    f0102e62 <region_alloc+0x4e>
f0102e4b:	83 ec 04             	sub    $0x4,%esp
f0102e4e:	68 95 75 10 f0       	push   $0xf0107595
f0102e53:	68 38 01 00 00       	push   $0x138
f0102e58:	68 a7 75 10 f0       	push   $0xf01075a7
f0102e5d:	e8 de d1 ff ff       	call   f0100040 <_panic>
		//boot_map_region(e->env_pgdir, i, PGSIZE, page2pa(pp), PTE_U | PTE_W);
		page_insert(e->env_pgdir, pp, (void*)i, PTE_U | PTE_W | PTE_P);
f0102e62:	6a 07                	push   $0x7
f0102e64:	53                   	push   %ebx
f0102e65:	50                   	push   %eax
f0102e66:	ff 77 60             	pushl  0x60(%edi)
f0102e69:	e8 f1 e3 ff ff       	call   f010125f <page_insert>
	uint32_t va_end = ROUNDUP((uint32_t)va + len, PGSIZE);
	uint32_t va_start = ROUNDDOWN((uint32_t)va, PGSIZE);
	len = va_end - va_start;

	uint32_t i = va_start;
	for (; i < va_end; i += PGSIZE){
f0102e6e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e74:	83 c4 10             	add    $0x10,%esp
f0102e77:	39 f3                	cmp    %esi,%ebx
f0102e79:	72 bf                	jb     f0102e3a <region_alloc+0x26>
		struct PageInfo* pp = page_alloc(0);
		if (!pp) panic("No memory for env");
		//boot_map_region(e->env_pgdir, i, PGSIZE, page2pa(pp), PTE_U | PTE_W);
		page_insert(e->env_pgdir, pp, (void*)i, PTE_U | PTE_W | PTE_P);
	}
}
f0102e7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e7e:	5b                   	pop    %ebx
f0102e7f:	5e                   	pop    %esi
f0102e80:	5f                   	pop    %edi
f0102e81:	5d                   	pop    %ebp
f0102e82:	f3 c3                	repz ret 

f0102e84 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e84:	55                   	push   %ebp
f0102e85:	89 e5                	mov    %esp,%ebp
f0102e87:	56                   	push   %esi
f0102e88:	53                   	push   %ebx
f0102e89:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e8c:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e8f:	85 c0                	test   %eax,%eax
f0102e91:	75 1a                	jne    f0102ead <envid2env+0x29>
		*env_store = curenv;
f0102e93:	e8 53 2e 00 00       	call   f0105ceb <cpunum>
f0102e98:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e9b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ea4:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102ea6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eab:	eb 70                	jmp    f0102f1d <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102ead:	89 c3                	mov    %eax,%ebx
f0102eaf:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102eb5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102eb8:	03 1d 48 12 21 f0    	add    0xf0211248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ebe:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102ec2:	74 05                	je     f0102ec9 <envid2env+0x45>
f0102ec4:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102ec7:	74 10                	je     f0102ed9 <envid2env+0x55>
		*env_store = 0;
f0102ec9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ecc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ed2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ed7:	eb 44                	jmp    f0102f1d <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ed9:	84 d2                	test   %dl,%dl
f0102edb:	74 36                	je     f0102f13 <envid2env+0x8f>
f0102edd:	e8 09 2e 00 00       	call   f0105ceb <cpunum>
f0102ee2:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ee5:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f0102eeb:	74 26                	je     f0102f13 <envid2env+0x8f>
f0102eed:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ef0:	e8 f6 2d 00 00       	call   f0105ceb <cpunum>
f0102ef5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ef8:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102efe:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f01:	74 10                	je     f0102f13 <envid2env+0x8f>
		*env_store = 0;
f0102f03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f0c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f11:	eb 0a                	jmp    f0102f1d <envid2env+0x99>
	}

	*env_store = e;
f0102f13:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f16:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f18:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f1d:	5b                   	pop    %ebx
f0102f1e:	5e                   	pop    %esi
f0102f1f:	5d                   	pop    %ebp
f0102f20:	c3                   	ret    

f0102f21 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f21:	55                   	push   %ebp
f0102f22:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102f24:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102f29:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102f2c:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f31:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102f33:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102f35:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f3a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102f3c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102f3e:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102f40:	ea 47 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f47
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102f47:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f4c:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f4f:	5d                   	pop    %ebp
f0102f50:	c3                   	ret    

f0102f51 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f51:	55                   	push   %ebp
f0102f52:	89 e5                	mov    %esp,%ebp
f0102f54:	56                   	push   %esi
f0102f55:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV - 1; i >= 0; i--){
		envs[i].env_id = 0;
f0102f56:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
f0102f5c:	8b 15 4c 12 21 f0    	mov    0xf021124c,%edx
f0102f62:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f68:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f6b:	89 c1                	mov    %eax,%ecx
f0102f6d:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f74:	89 50 44             	mov    %edx,0x44(%eax)
f0102f77:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102f7a:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV - 1; i >= 0; i--){
f0102f7c:	39 d8                	cmp    %ebx,%eax
f0102f7e:	75 eb                	jne    f0102f6b <env_init+0x1a>
f0102f80:	89 35 4c 12 21 f0    	mov    %esi,0xf021124c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f86:	e8 96 ff ff ff       	call   f0102f21 <env_init_percpu>
}
f0102f8b:	5b                   	pop    %ebx
f0102f8c:	5e                   	pop    %esi
f0102f8d:	5d                   	pop    %ebp
f0102f8e:	c3                   	ret    

f0102f8f <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f8f:	55                   	push   %ebp
f0102f90:	89 e5                	mov    %esp,%ebp
f0102f92:	53                   	push   %ebx
f0102f93:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f96:	8b 1d 4c 12 21 f0    	mov    0xf021124c,%ebx
f0102f9c:	85 db                	test   %ebx,%ebx
f0102f9e:	0f 84 32 01 00 00    	je     f01030d6 <env_alloc+0x147>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fa4:	83 ec 0c             	sub    $0xc,%esp
f0102fa7:	6a 01                	push   $0x1
f0102fa9:	e8 e8 df ff ff       	call   f0100f96 <page_alloc>
f0102fae:	83 c4 10             	add    $0x10,%esp
f0102fb1:	85 c0                	test   %eax,%eax
f0102fb3:	0f 84 24 01 00 00    	je     f01030dd <env_alloc+0x14e>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102fb9:	89 c2                	mov    %eax,%edx
f0102fbb:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102fc1:	c1 fa 03             	sar    $0x3,%edx
f0102fc4:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fc7:	89 d1                	mov    %edx,%ecx
f0102fc9:	c1 e9 0c             	shr    $0xc,%ecx
f0102fcc:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0102fd2:	72 12                	jb     f0102fe6 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fd4:	52                   	push   %edx
f0102fd5:	68 a4 63 10 f0       	push   $0xf01063a4
f0102fda:	6a 58                	push   $0x58
f0102fdc:	68 6e 72 10 f0       	push   $0xf010726e
f0102fe1:	e8 5a d0 ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f0102fe6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102fec:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f0102fef:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	boot_map_region(e->env_pgdir, KSTACKTOP - KSTKSIZE, ROUNDUP(KSTKSIZE,
				PGSIZE), PADDR(bootstack), PTE_W | PTE_P);

	boot_map_region(e->env_pgdir, KERNBASE, ((uint32_t)0xFFFFFFFF - KERNBASE)
			+ 1, 0, PTE_W | PTE_P);*/
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102ff4:	83 ec 04             	sub    $0x4,%esp
f0102ff7:	68 00 10 00 00       	push   $0x1000
f0102ffc:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0103002:	ff 73 60             	pushl  0x60(%ebx)
f0103005:	e8 64 27 00 00       	call   f010576e <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010300a:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010300d:	83 c4 10             	add    $0x10,%esp
f0103010:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103015:	77 15                	ja     f010302c <env_alloc+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103017:	50                   	push   %eax
f0103018:	68 c8 63 10 f0       	push   $0xf01063c8
f010301d:	68 d1 00 00 00       	push   $0xd1
f0103022:	68 a7 75 10 f0       	push   $0xf01075a7
f0103027:	e8 14 d0 ff ff       	call   f0100040 <_panic>
f010302c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103032:	83 ca 05             	or     $0x5,%edx
f0103035:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010303b:	8b 43 48             	mov    0x48(%ebx),%eax
f010303e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103043:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103048:	ba 00 10 00 00       	mov    $0x1000,%edx
f010304d:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103050:	89 da                	mov    %ebx,%edx
f0103052:	2b 15 48 12 21 f0    	sub    0xf0211248,%edx
f0103058:	c1 fa 02             	sar    $0x2,%edx
f010305b:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103061:	09 d0                	or     %edx,%eax
f0103063:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103066:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103069:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010306c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103073:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010307a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103081:	83 ec 04             	sub    $0x4,%esp
f0103084:	6a 44                	push   $0x44
f0103086:	6a 00                	push   $0x0
f0103088:	53                   	push   %ebx
f0103089:	e8 2b 26 00 00       	call   f01056b9 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010308e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103094:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010309a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030a0:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030a7:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030ad:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030b4:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01030bb:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01030bf:	8b 43 44             	mov    0x44(%ebx),%eax
f01030c2:	a3 4c 12 21 f0       	mov    %eax,0xf021124c
	*newenv_store = e;
f01030c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01030ca:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01030cc:	83 c4 10             	add    $0x10,%esp
f01030cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01030d4:	eb 0c                	jmp    f01030e2 <env_alloc+0x153>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030d6:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01030db:	eb 05                	jmp    f01030e2 <env_alloc+0x153>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01030dd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030e5:	c9                   	leave  
f01030e6:	c3                   	ret    

f01030e7 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01030e7:	55                   	push   %ebp
f01030e8:	89 e5                	mov    %esp,%ebp
f01030ea:	57                   	push   %edi
f01030eb:	56                   	push   %esi
f01030ec:	53                   	push   %ebx
f01030ed:	83 ec 34             	sub    $0x34,%esp
f01030f0:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env* newenv;
	int ret = env_alloc(&newenv, 0);
f01030f3:	6a 00                	push   $0x0
f01030f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030f8:	50                   	push   %eax
f01030f9:	e8 91 fe ff ff       	call   f0102f8f <env_alloc>
	if (ret) panic("env_create: %e", ret);
f01030fe:	83 c4 10             	add    $0x10,%esp
f0103101:	85 c0                	test   %eax,%eax
f0103103:	74 15                	je     f010311a <env_create+0x33>
f0103105:	50                   	push   %eax
f0103106:	68 b2 75 10 f0       	push   $0xf01075b2
f010310b:	68 a1 01 00 00       	push   $0x1a1
f0103110:	68 a7 75 10 f0       	push   $0xf01075a7
f0103115:	e8 26 cf ff ff       	call   f0100040 <_panic>

	load_icode(newenv, binary);
f010311a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010311d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	// Switch page table
	lcr3(PADDR(e->env_pgdir));
f0103120:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103123:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103128:	77 15                	ja     f010313f <env_create+0x58>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010312a:	50                   	push   %eax
f010312b:	68 c8 63 10 f0       	push   $0xf01063c8
f0103130:	68 75 01 00 00       	push   $0x175
f0103135:	68 a7 75 10 f0       	push   $0xf01075a7
f010313a:	e8 01 cf ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010313f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103144:	0f 22 d8             	mov    %eax,%cr3
	struct Elf* elfhdr = (struct Elf*)binary;

	// Is this a valid ELF?
	if (elfhdr->e_magic != ELF_MAGIC) panic("Not a valid ELF");
f0103147:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010314d:	74 17                	je     f0103166 <env_create+0x7f>
f010314f:	83 ec 04             	sub    $0x4,%esp
f0103152:	68 c1 75 10 f0       	push   $0xf01075c1
f0103157:	68 79 01 00 00       	push   $0x179
f010315c:	68 a7 75 10 f0       	push   $0xf01075a7
f0103161:	e8 da ce ff ff       	call   f0100040 <_panic>

	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
f0103166:	89 fb                	mov    %edi,%ebx
f0103168:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* eph = ph + elfhdr->e_phnum;
f010316b:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010316f:	c1 e6 05             	shl    $0x5,%esi
f0103172:	01 de                	add    %ebx,%esi
f0103174:	eb 44                	jmp    f01031ba <env_create+0xd3>
	for (; ph < eph; ph++){
		if (ph->p_type == ELF_PROG_LOAD){
f0103176:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103179:	75 3c                	jne    f01031b7 <env_create+0xd0>
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f010317b:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010317e:	8b 53 08             	mov    0x8(%ebx),%edx
f0103181:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103184:	e8 8b fc ff ff       	call   f0102e14 <region_alloc>
			memcpy((void*)ph->p_va, (void*)(binary + ph->p_offset), 
f0103189:	83 ec 04             	sub    $0x4,%esp
f010318c:	ff 73 10             	pushl  0x10(%ebx)
f010318f:	89 f8                	mov    %edi,%eax
f0103191:	03 43 04             	add    0x4(%ebx),%eax
f0103194:	50                   	push   %eax
f0103195:	ff 73 08             	pushl  0x8(%ebx)
f0103198:	e8 d1 25 00 00       	call   f010576e <memcpy>
					ph->p_filesz);
			memset((void*)ph->p_va + ph->p_filesz, 0, 
					ph->p_memsz - ph->p_filesz);
f010319d:	8b 43 10             	mov    0x10(%ebx),%eax
	for (; ph < eph; ph++){
		if (ph->p_type == ELF_PROG_LOAD){
			region_alloc(e, (void*)ph->p_va, ph->p_memsz);
			memcpy((void*)ph->p_va, (void*)(binary + ph->p_offset), 
					ph->p_filesz);
			memset((void*)ph->p_va + ph->p_filesz, 0, 
f01031a0:	83 c4 0c             	add    $0xc,%esp
f01031a3:	8b 53 14             	mov    0x14(%ebx),%edx
f01031a6:	29 c2                	sub    %eax,%edx
f01031a8:	52                   	push   %edx
f01031a9:	6a 00                	push   $0x0
f01031ab:	03 43 08             	add    0x8(%ebx),%eax
f01031ae:	50                   	push   %eax
f01031af:	e8 05 25 00 00       	call   f01056b9 <memset>
f01031b4:	83 c4 10             	add    $0x10,%esp
	// Is this a valid ELF?
	if (elfhdr->e_magic != ELF_MAGIC) panic("Not a valid ELF");

	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elfhdr + elfhdr->e_phoff);
	struct Proghdr* eph = ph + elfhdr->e_phnum;
	for (; ph < eph; ph++){
f01031b7:	83 c3 20             	add    $0x20,%ebx
f01031ba:	39 de                	cmp    %ebx,%esi
f01031bc:	77 b8                	ja     f0103176 <env_create+0x8f>

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f01031be:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031c3:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031c8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01031cb:	89 f0                	mov    %esi,%eax
f01031cd:	e8 42 fc ff ff       	call   f0102e14 <region_alloc>

	// Setting entry point
	e->env_tf.tf_eip = elfhdr->e_entry;
f01031d2:	8b 47 18             	mov    0x18(%edi),%eax
f01031d5:	89 46 30             	mov    %eax,0x30(%esi)

	// Restore page table
	lcr3(PADDR(kern_pgdir));
f01031d8:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031e2:	77 15                	ja     f01031f9 <env_create+0x112>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031e4:	50                   	push   %eax
f01031e5:	68 c8 63 10 f0       	push   $0xf01063c8
f01031ea:	68 91 01 00 00       	push   $0x191
f01031ef:	68 a7 75 10 f0       	push   $0xf01075a7
f01031f4:	e8 47 ce ff ff       	call   f0100040 <_panic>
f01031f9:	05 00 00 00 10       	add    $0x10000000,%eax
f01031fe:	0f 22 d8             	mov    %eax,%cr3
	struct Env* newenv;
	int ret = env_alloc(&newenv, 0);
	if (ret) panic("env_create: %e", ret);

	load_icode(newenv, binary);
	newenv->env_type = type;
f0103201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103204:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103207:	89 50 50             	mov    %edx,0x50(%eax)
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
}
f010320a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010320d:	5b                   	pop    %ebx
f010320e:	5e                   	pop    %esi
f010320f:	5f                   	pop    %edi
f0103210:	5d                   	pop    %ebp
f0103211:	c3                   	ret    

f0103212 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103212:	55                   	push   %ebp
f0103213:	89 e5                	mov    %esp,%ebp
f0103215:	57                   	push   %edi
f0103216:	56                   	push   %esi
f0103217:	53                   	push   %ebx
f0103218:	83 ec 1c             	sub    $0x1c,%esp
f010321b:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010321e:	e8 c8 2a 00 00       	call   f0105ceb <cpunum>
f0103223:	6b c0 74             	imul   $0x74,%eax,%eax
f0103226:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010322d:	39 b8 28 20 21 f0    	cmp    %edi,-0xfdedfd8(%eax)
f0103233:	75 30                	jne    f0103265 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103235:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010323f:	77 15                	ja     f0103256 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103241:	50                   	push   %eax
f0103242:	68 c8 63 10 f0       	push   $0xf01063c8
f0103247:	68 b7 01 00 00       	push   $0x1b7
f010324c:	68 a7 75 10 f0       	push   $0xf01075a7
f0103251:	e8 ea cd ff ff       	call   f0100040 <_panic>
f0103256:	05 00 00 00 10       	add    $0x10000000,%eax
f010325b:	0f 22 d8             	mov    %eax,%cr3
f010325e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103265:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103268:	89 d0                	mov    %edx,%eax
f010326a:	c1 e0 02             	shl    $0x2,%eax
f010326d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103270:	8b 47 60             	mov    0x60(%edi),%eax
f0103273:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103276:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010327c:	0f 84 a8 00 00 00    	je     f010332a <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103282:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103288:	89 f0                	mov    %esi,%eax
f010328a:	c1 e8 0c             	shr    $0xc,%eax
f010328d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103290:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f0103296:	77 15                	ja     f01032ad <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103298:	56                   	push   %esi
f0103299:	68 a4 63 10 f0       	push   $0xf01063a4
f010329e:	68 c6 01 00 00       	push   $0x1c6
f01032a3:	68 a7 75 10 f0       	push   $0xf01075a7
f01032a8:	e8 93 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032b0:	c1 e0 16             	shl    $0x16,%eax
f01032b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032b6:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01032bb:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01032c2:	01 
f01032c3:	74 17                	je     f01032dc <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032c5:	83 ec 08             	sub    $0x8,%esp
f01032c8:	89 d8                	mov    %ebx,%eax
f01032ca:	c1 e0 0c             	shl    $0xc,%eax
f01032cd:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01032d0:	50                   	push   %eax
f01032d1:	ff 77 60             	pushl  0x60(%edi)
f01032d4:	e8 32 df ff ff       	call   f010120b <page_remove>
f01032d9:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032dc:	83 c3 01             	add    $0x1,%ebx
f01032df:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032e5:	75 d4                	jne    f01032bb <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032e7:	8b 47 60             	mov    0x60(%edi),%eax
f01032ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032ed:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01032f7:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01032fd:	72 14                	jb     f0103313 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01032ff:	83 ec 04             	sub    $0x4,%esp
f0103302:	68 0c 6a 10 f0       	push   $0xf0106a0c
f0103307:	6a 51                	push   $0x51
f0103309:	68 6e 72 10 f0       	push   $0xf010726e
f010330e:	e8 2d cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103313:	83 ec 0c             	sub    $0xc,%esp
f0103316:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f010331b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010331e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103321:	50                   	push   %eax
f0103322:	e8 21 dd ff ff       	call   f0101048 <page_decref>
f0103327:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010332a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010332e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103331:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103336:	0f 85 29 ff ff ff    	jne    f0103265 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010333c:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010333f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103344:	77 15                	ja     f010335b <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103346:	50                   	push   %eax
f0103347:	68 c8 63 10 f0       	push   $0xf01063c8
f010334c:	68 d4 01 00 00       	push   $0x1d4
f0103351:	68 a7 75 10 f0       	push   $0xf01075a7
f0103356:	e8 e5 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010335b:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103362:	05 00 00 00 10       	add    $0x10000000,%eax
f0103367:	c1 e8 0c             	shr    $0xc,%eax
f010336a:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0103370:	72 14                	jb     f0103386 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103372:	83 ec 04             	sub    $0x4,%esp
f0103375:	68 0c 6a 10 f0       	push   $0xf0106a0c
f010337a:	6a 51                	push   $0x51
f010337c:	68 6e 72 10 f0       	push   $0xf010726e
f0103381:	e8 ba cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103386:	83 ec 0c             	sub    $0xc,%esp
f0103389:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f010338f:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103392:	50                   	push   %eax
f0103393:	e8 b0 dc ff ff       	call   f0101048 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103398:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010339f:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
f01033a4:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033a7:	89 3d 4c 12 21 f0    	mov    %edi,0xf021124c
}
f01033ad:	83 c4 10             	add    $0x10,%esp
f01033b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033b3:	5b                   	pop    %ebx
f01033b4:	5e                   	pop    %esi
f01033b5:	5f                   	pop    %edi
f01033b6:	5d                   	pop    %ebp
f01033b7:	c3                   	ret    

f01033b8 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01033b8:	55                   	push   %ebp
f01033b9:	89 e5                	mov    %esp,%ebp
f01033bb:	53                   	push   %ebx
f01033bc:	83 ec 04             	sub    $0x4,%esp
f01033bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01033c2:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01033c6:	75 19                	jne    f01033e1 <env_destroy+0x29>
f01033c8:	e8 1e 29 00 00       	call   f0105ceb <cpunum>
f01033cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d0:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01033d6:	74 09                	je     f01033e1 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033d8:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033df:	eb 33                	jmp    f0103414 <env_destroy+0x5c>
	}

	env_free(e);
f01033e1:	83 ec 0c             	sub    $0xc,%esp
f01033e4:	53                   	push   %ebx
f01033e5:	e8 28 fe ff ff       	call   f0103212 <env_free>

	if (curenv == e) {
f01033ea:	e8 fc 28 00 00       	call   f0105ceb <cpunum>
f01033ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01033f2:	83 c4 10             	add    $0x10,%esp
f01033f5:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01033fb:	75 17                	jne    f0103414 <env_destroy+0x5c>
		curenv = NULL;
f01033fd:	e8 e9 28 00 00       	call   f0105ceb <cpunum>
f0103402:	6b c0 74             	imul   $0x74,%eax,%eax
f0103405:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f010340c:	00 00 00 
		sched_yield();
f010340f:	e8 3c 10 00 00       	call   f0104450 <sched_yield>
	}
}
f0103414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103417:	c9                   	leave  
f0103418:	c3                   	ret    

f0103419 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103419:	55                   	push   %ebp
f010341a:	89 e5                	mov    %esp,%ebp
f010341c:	53                   	push   %ebx
f010341d:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103420:	e8 c6 28 00 00       	call   f0105ceb <cpunum>
f0103425:	6b c0 74             	imul   $0x74,%eax,%eax
f0103428:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f010342e:	e8 b8 28 00 00       	call   f0105ceb <cpunum>
f0103433:	89 43 5c             	mov    %eax,0x5c(%ebx)

	spin_unlock(&kernel_lock);
f0103436:	83 ec 0c             	sub    $0xc,%esp
f0103439:	68 c0 03 12 f0       	push   $0xf01203c0
f010343e:	e8 b3 2b 00 00       	call   f0105ff6 <spin_unlock>

	asm volatile(
f0103443:	8b 65 08             	mov    0x8(%ebp),%esp
f0103446:	61                   	popa   
f0103447:	07                   	pop    %es
f0103448:	1f                   	pop    %ds
f0103449:	83 c4 08             	add    $0x8,%esp
f010344c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010344d:	83 c4 0c             	add    $0xc,%esp
f0103450:	68 d1 75 10 f0       	push   $0xf01075d1
f0103455:	68 0d 02 00 00       	push   $0x20d
f010345a:	68 a7 75 10 f0       	push   $0xf01075a7
f010345f:	e8 dc cb ff ff       	call   f0100040 <_panic>

f0103464 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103464:	55                   	push   %ebp
f0103465:	89 e5                	mov    %esp,%ebp
f0103467:	53                   	push   %ebx
f0103468:	83 ec 04             	sub    $0x4,%esp
f010346b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// envid_t curenvid = (curenv)? curenv->env_id: 0;
	// cprintf("env_run: curenv = %08x, e = %08x\n", curenvid, e->env_id);
	if (curenv != e){
f010346e:	e8 78 28 00 00       	call   f0105ceb <cpunum>
f0103473:	6b c0 74             	imul   $0x74,%eax,%eax
f0103476:	39 98 28 20 21 f0    	cmp    %ebx,-0xfdedfd8(%eax)
f010347c:	0f 84 a4 00 00 00    	je     f0103526 <env_run+0xc2>
		if (curenv && curenv->env_status == ENV_RUNNING)
f0103482:	e8 64 28 00 00       	call   f0105ceb <cpunum>
f0103487:	6b c0 74             	imul   $0x74,%eax,%eax
f010348a:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103491:	74 29                	je     f01034bc <env_run+0x58>
f0103493:	e8 53 28 00 00       	call   f0105ceb <cpunum>
f0103498:	6b c0 74             	imul   $0x74,%eax,%eax
f010349b:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01034a1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01034a5:	75 15                	jne    f01034bc <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f01034a7:	e8 3f 28 00 00       	call   f0105ceb <cpunum>
f01034ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01034af:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01034b5:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f01034bc:	e8 2a 28 00 00       	call   f0105ceb <cpunum>
f01034c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c4:	89 98 28 20 21 f0    	mov    %ebx,-0xfdedfd8(%eax)
		curenv->env_status = ENV_RUNNING;
f01034ca:	e8 1c 28 00 00       	call   f0105ceb <cpunum>
f01034cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d2:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01034d8:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f01034df:	e8 07 28 00 00       	call   f0105ceb <cpunum>
f01034e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01034e7:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01034ed:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f01034f1:	e8 f5 27 00 00       	call   f0105ceb <cpunum>
f01034f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01034f9:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01034ff:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103502:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103507:	77 15                	ja     f010351e <env_run+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103509:	50                   	push   %eax
f010350a:	68 c8 63 10 f0       	push   $0xf01063c8
f010350f:	68 33 02 00 00       	push   $0x233
f0103514:	68 a7 75 10 f0       	push   $0xf01075a7
f0103519:	e8 22 cb ff ff       	call   f0100040 <_panic>
f010351e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103523:	0f 22 d8             	mov    %eax,%cr3
	}

	env_pop_tf(&curenv->env_tf);
f0103526:	e8 c0 27 00 00       	call   f0105ceb <cpunum>
f010352b:	83 ec 0c             	sub    $0xc,%esp
f010352e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103531:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103537:	e8 dd fe ff ff       	call   f0103419 <env_pop_tf>

f010353c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010353c:	55                   	push   %ebp
f010353d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010353f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103544:	8b 45 08             	mov    0x8(%ebp),%eax
f0103547:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103548:	ba 71 00 00 00       	mov    $0x71,%edx
f010354d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010354e:	0f b6 c0             	movzbl %al,%eax
}
f0103551:	5d                   	pop    %ebp
f0103552:	c3                   	ret    

f0103553 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103553:	55                   	push   %ebp
f0103554:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103556:	ba 70 00 00 00       	mov    $0x70,%edx
f010355b:	8b 45 08             	mov    0x8(%ebp),%eax
f010355e:	ee                   	out    %al,(%dx)
f010355f:	ba 71 00 00 00       	mov    $0x71,%edx
f0103564:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103567:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103568:	5d                   	pop    %ebp
f0103569:	c3                   	ret    

f010356a <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010356a:	55                   	push   %ebp
f010356b:	89 e5                	mov    %esp,%ebp
f010356d:	56                   	push   %esi
f010356e:	53                   	push   %ebx
f010356f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103572:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103578:	80 3d 50 12 21 f0 00 	cmpb   $0x0,0xf0211250
f010357f:	74 5a                	je     f01035db <irq_setmask_8259A+0x71>
f0103581:	89 c6                	mov    %eax,%esi
f0103583:	ba 21 00 00 00       	mov    $0x21,%edx
f0103588:	ee                   	out    %al,(%dx)
f0103589:	66 c1 e8 08          	shr    $0x8,%ax
f010358d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103592:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103593:	83 ec 0c             	sub    $0xc,%esp
f0103596:	68 dd 75 10 f0       	push   $0xf01075dd
f010359b:	e8 1b 01 00 00       	call   f01036bb <cprintf>
f01035a0:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01035a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01035a8:	0f b7 f6             	movzwl %si,%esi
f01035ab:	f7 d6                	not    %esi
f01035ad:	0f a3 de             	bt     %ebx,%esi
f01035b0:	73 11                	jae    f01035c3 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01035b2:	83 ec 08             	sub    $0x8,%esp
f01035b5:	53                   	push   %ebx
f01035b6:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01035bb:	e8 fb 00 00 00       	call   f01036bb <cprintf>
f01035c0:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01035c3:	83 c3 01             	add    $0x1,%ebx
f01035c6:	83 fb 10             	cmp    $0x10,%ebx
f01035c9:	75 e2                	jne    f01035ad <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01035cb:	83 ec 0c             	sub    $0xc,%esp
f01035ce:	68 63 75 10 f0       	push   $0xf0107563
f01035d3:	e8 e3 00 00 00       	call   f01036bb <cprintf>
f01035d8:	83 c4 10             	add    $0x10,%esp
}
f01035db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035de:	5b                   	pop    %ebx
f01035df:	5e                   	pop    %esi
f01035e0:	5d                   	pop    %ebp
f01035e1:	c3                   	ret    

f01035e2 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01035e2:	c6 05 50 12 21 f0 01 	movb   $0x1,0xf0211250
f01035e9:	ba 21 00 00 00       	mov    $0x21,%edx
f01035ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035f3:	ee                   	out    %al,(%dx)
f01035f4:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035f9:	ee                   	out    %al,(%dx)
f01035fa:	ba 20 00 00 00       	mov    $0x20,%edx
f01035ff:	b8 11 00 00 00       	mov    $0x11,%eax
f0103604:	ee                   	out    %al,(%dx)
f0103605:	ba 21 00 00 00       	mov    $0x21,%edx
f010360a:	b8 20 00 00 00       	mov    $0x20,%eax
f010360f:	ee                   	out    %al,(%dx)
f0103610:	b8 04 00 00 00       	mov    $0x4,%eax
f0103615:	ee                   	out    %al,(%dx)
f0103616:	b8 03 00 00 00       	mov    $0x3,%eax
f010361b:	ee                   	out    %al,(%dx)
f010361c:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103621:	b8 11 00 00 00       	mov    $0x11,%eax
f0103626:	ee                   	out    %al,(%dx)
f0103627:	ba a1 00 00 00       	mov    $0xa1,%edx
f010362c:	b8 28 00 00 00       	mov    $0x28,%eax
f0103631:	ee                   	out    %al,(%dx)
f0103632:	b8 02 00 00 00       	mov    $0x2,%eax
f0103637:	ee                   	out    %al,(%dx)
f0103638:	b8 01 00 00 00       	mov    $0x1,%eax
f010363d:	ee                   	out    %al,(%dx)
f010363e:	ba 20 00 00 00       	mov    $0x20,%edx
f0103643:	b8 68 00 00 00       	mov    $0x68,%eax
f0103648:	ee                   	out    %al,(%dx)
f0103649:	b8 0a 00 00 00       	mov    $0xa,%eax
f010364e:	ee                   	out    %al,(%dx)
f010364f:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103654:	b8 68 00 00 00       	mov    $0x68,%eax
f0103659:	ee                   	out    %al,(%dx)
f010365a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010365f:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103660:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103667:	66 83 f8 ff          	cmp    $0xffff,%ax
f010366b:	74 13                	je     f0103680 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010366d:	55                   	push   %ebp
f010366e:	89 e5                	mov    %esp,%ebp
f0103670:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103673:	0f b7 c0             	movzwl %ax,%eax
f0103676:	50                   	push   %eax
f0103677:	e8 ee fe ff ff       	call   f010356a <irq_setmask_8259A>
f010367c:	83 c4 10             	add    $0x10,%esp
}
f010367f:	c9                   	leave  
f0103680:	f3 c3                	repz ret 

f0103682 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103682:	55                   	push   %ebp
f0103683:	89 e5                	mov    %esp,%ebp
f0103685:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103688:	ff 75 08             	pushl  0x8(%ebp)
f010368b:	e8 09 d1 ff ff       	call   f0100799 <cputchar>
	*cnt++;
}
f0103690:	83 c4 10             	add    $0x10,%esp
f0103693:	c9                   	leave  
f0103694:	c3                   	ret    

f0103695 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103695:	55                   	push   %ebp
f0103696:	89 e5                	mov    %esp,%ebp
f0103698:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010369b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036a2:	ff 75 0c             	pushl  0xc(%ebp)
f01036a5:	ff 75 08             	pushl  0x8(%ebp)
f01036a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036ab:	50                   	push   %eax
f01036ac:	68 82 36 10 f0       	push   $0xf0103682
f01036b1:	e8 9e 18 00 00       	call   f0104f54 <vprintfmt>
	return cnt;
}
f01036b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036b9:	c9                   	leave  
f01036ba:	c3                   	ret    

f01036bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036bb:	55                   	push   %ebp
f01036bc:	89 e5                	mov    %esp,%ebp
f01036be:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01036c4:	50                   	push   %eax
f01036c5:	ff 75 08             	pushl  0x8(%ebp)
f01036c8:	e8 c8 ff ff ff       	call   f0103695 <vcprintf>
	va_end(ap);

	return cnt;
}
f01036cd:	c9                   	leave  
f01036ce:	c3                   	ret    

f01036cf <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01036cf:	55                   	push   %ebp
f01036d0:	89 e5                	mov    %esp,%ebp
f01036d2:	57                   	push   %edi
f01036d3:	56                   	push   %esi
f01036d4:	53                   	push   %ebx
f01036d5:	83 ec 0c             	sub    $0xc,%esp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	// ts.ts_esp0 = KSTACKTOP;
	// ts.ts_ss0 = GD_KD;
	// ts.ts_iomb = sizeof(struct Taskstate);
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)(percpu_kstacks[cpunum()]);
f01036d8:	e8 0e 26 00 00       	call   f0105ceb <cpunum>
f01036dd:	89 c3                	mov    %eax,%ebx
f01036df:	e8 07 26 00 00       	call   f0105ceb <cpunum>
f01036e4:	6b db 74             	imul   $0x74,%ebx,%ebx
f01036e7:	c1 e0 0f             	shl    $0xf,%eax
f01036ea:	05 00 30 21 f0       	add    $0xf0213000,%eax
f01036ef:	89 83 30 20 21 f0    	mov    %eax,-0xfdedfd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01036f5:	e8 f1 25 00 00       	call   f0105ceb <cpunum>
f01036fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01036fd:	66 c7 80 34 20 21 f0 	movw   $0x10,-0xfdedfcc(%eax)
f0103704:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103706:	e8 e0 25 00 00       	call   f0105ceb <cpunum>
f010370b:	6b c0 74             	imul   $0x74,%eax,%eax
f010370e:	66 c7 80 92 20 21 f0 	movw   $0x68,-0xfdedf6e(%eax)
f0103715:	68 00 

	// Initialize the TSS slot of the gdt.
	// gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
	// 				sizeof(struct Taskstate) - 1, 0);
	// gdt[GD_TSS0 >> 3].sd_s = 0;
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, 
f0103717:	e8 cf 25 00 00       	call   f0105ceb <cpunum>
f010371c:	8d 58 05             	lea    0x5(%eax),%ebx
f010371f:	e8 c7 25 00 00       	call   f0105ceb <cpunum>
f0103724:	89 c7                	mov    %eax,%edi
f0103726:	e8 c0 25 00 00       	call   f0105ceb <cpunum>
f010372b:	89 c6                	mov    %eax,%esi
f010372d:	e8 b9 25 00 00       	call   f0105ceb <cpunum>
f0103732:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f0103739:	f0 67 00 
f010373c:	6b ff 74             	imul   $0x74,%edi,%edi
f010373f:	81 c7 2c 20 21 f0    	add    $0xf021202c,%edi
f0103745:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f010374c:	f0 
f010374d:	6b d6 74             	imul   $0x74,%esi,%edx
f0103750:	81 c2 2c 20 21 f0    	add    $0xf021202c,%edx
f0103756:	c1 ea 10             	shr    $0x10,%edx
f0103759:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103760:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103767:	99 
f0103768:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010376f:	40 
f0103770:	6b c0 74             	imul   $0x74,%eax,%eax
f0103773:	05 2c 20 21 f0       	add    $0xf021202c,%eax
f0103778:	c1 e8 18             	shr    $0x18,%eax
f010377b:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
			(uint32_t)(&(thiscpu->cpu_ts)), 
			sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103782:	e8 64 25 00 00       	call   f0105ceb <cpunum>
f0103787:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010378e:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	// ltr(GD_TSS0);
	ltr(GD_TSS0 + (cpunum() << 3));
f010378f:	e8 57 25 00 00       	call   f0105ceb <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103794:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f010379b:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010379e:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f01037a3:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01037a6:	83 c4 0c             	add    $0xc,%esp
f01037a9:	5b                   	pop    %ebx
f01037aa:	5e                   	pop    %esi
f01037ab:	5f                   	pop    %edi
f01037ac:	5d                   	pop    %ebp
f01037ad:	c3                   	ret    

f01037ae <trap_init>:
}


void
trap_init(void)
{
f01037ae:	55                   	push   %ebp
f01037af:	89 e5                	mov    %esp,%ebp
f01037b1:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, trap_divide, 0);
f01037b4:	b8 d4 42 10 f0       	mov    $0xf01042d4,%eax
f01037b9:	66 a3 60 12 21 f0    	mov    %ax,0xf0211260
f01037bf:	66 c7 05 62 12 21 f0 	movw   $0x8,0xf0211262
f01037c6:	08 00 
f01037c8:	c6 05 64 12 21 f0 00 	movb   $0x0,0xf0211264
f01037cf:	c6 05 65 12 21 f0 8e 	movb   $0x8e,0xf0211265
f01037d6:	c1 e8 10             	shr    $0x10,%eax
f01037d9:	66 a3 66 12 21 f0    	mov    %ax,0xf0211266
	SETGATE(idt[T_DEBUG], 0, GD_KT, trap_debug, 0);
f01037df:	b8 de 42 10 f0       	mov    $0xf01042de,%eax
f01037e4:	66 a3 68 12 21 f0    	mov    %ax,0xf0211268
f01037ea:	66 c7 05 6a 12 21 f0 	movw   $0x8,0xf021126a
f01037f1:	08 00 
f01037f3:	c6 05 6c 12 21 f0 00 	movb   $0x0,0xf021126c
f01037fa:	c6 05 6d 12 21 f0 8e 	movb   $0x8e,0xf021126d
f0103801:	c1 e8 10             	shr    $0x10,%eax
f0103804:	66 a3 6e 12 21 f0    	mov    %ax,0xf021126e
	SETGATE(idt[T_NMI], 0, GD_KT, trap_nmi, 0);
f010380a:	b8 e8 42 10 f0       	mov    $0xf01042e8,%eax
f010380f:	66 a3 70 12 21 f0    	mov    %ax,0xf0211270
f0103815:	66 c7 05 72 12 21 f0 	movw   $0x8,0xf0211272
f010381c:	08 00 
f010381e:	c6 05 74 12 21 f0 00 	movb   $0x0,0xf0211274
f0103825:	c6 05 75 12 21 f0 8e 	movb   $0x8e,0xf0211275
f010382c:	c1 e8 10             	shr    $0x10,%eax
f010382f:	66 a3 76 12 21 f0    	mov    %ax,0xf0211276
	SETGATE(idt[T_BRKPT], 0, GD_KT, trap_brkpt, 3);
f0103835:	b8 ee 42 10 f0       	mov    $0xf01042ee,%eax
f010383a:	66 a3 78 12 21 f0    	mov    %ax,0xf0211278
f0103840:	66 c7 05 7a 12 21 f0 	movw   $0x8,0xf021127a
f0103847:	08 00 
f0103849:	c6 05 7c 12 21 f0 00 	movb   $0x0,0xf021127c
f0103850:	c6 05 7d 12 21 f0 ee 	movb   $0xee,0xf021127d
f0103857:	c1 e8 10             	shr    $0x10,%eax
f010385a:	66 a3 7e 12 21 f0    	mov    %ax,0xf021127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, trap_oflow, 0);
f0103860:	b8 f4 42 10 f0       	mov    $0xf01042f4,%eax
f0103865:	66 a3 80 12 21 f0    	mov    %ax,0xf0211280
f010386b:	66 c7 05 82 12 21 f0 	movw   $0x8,0xf0211282
f0103872:	08 00 
f0103874:	c6 05 84 12 21 f0 00 	movb   $0x0,0xf0211284
f010387b:	c6 05 85 12 21 f0 8e 	movb   $0x8e,0xf0211285
f0103882:	c1 e8 10             	shr    $0x10,%eax
f0103885:	66 a3 86 12 21 f0    	mov    %ax,0xf0211286
	SETGATE(idt[T_BOUND], 0, GD_KT, trap_bound, 0);
f010388b:	b8 fa 42 10 f0       	mov    $0xf01042fa,%eax
f0103890:	66 a3 88 12 21 f0    	mov    %ax,0xf0211288
f0103896:	66 c7 05 8a 12 21 f0 	movw   $0x8,0xf021128a
f010389d:	08 00 
f010389f:	c6 05 8c 12 21 f0 00 	movb   $0x0,0xf021128c
f01038a6:	c6 05 8d 12 21 f0 8e 	movb   $0x8e,0xf021128d
f01038ad:	c1 e8 10             	shr    $0x10,%eax
f01038b0:	66 a3 8e 12 21 f0    	mov    %ax,0xf021128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, trap_illop, 0);
f01038b6:	b8 00 43 10 f0       	mov    $0xf0104300,%eax
f01038bb:	66 a3 90 12 21 f0    	mov    %ax,0xf0211290
f01038c1:	66 c7 05 92 12 21 f0 	movw   $0x8,0xf0211292
f01038c8:	08 00 
f01038ca:	c6 05 94 12 21 f0 00 	movb   $0x0,0xf0211294
f01038d1:	c6 05 95 12 21 f0 8e 	movb   $0x8e,0xf0211295
f01038d8:	c1 e8 10             	shr    $0x10,%eax
f01038db:	66 a3 96 12 21 f0    	mov    %ax,0xf0211296
	SETGATE(idt[T_DEVICE], 0, GD_KT, trap_device, 0);
f01038e1:	b8 06 43 10 f0       	mov    $0xf0104306,%eax
f01038e6:	66 a3 98 12 21 f0    	mov    %ax,0xf0211298
f01038ec:	66 c7 05 9a 12 21 f0 	movw   $0x8,0xf021129a
f01038f3:	08 00 
f01038f5:	c6 05 9c 12 21 f0 00 	movb   $0x0,0xf021129c
f01038fc:	c6 05 9d 12 21 f0 8e 	movb   $0x8e,0xf021129d
f0103903:	c1 e8 10             	shr    $0x10,%eax
f0103906:	66 a3 9e 12 21 f0    	mov    %ax,0xf021129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, trap_dblflt, 0);
f010390c:	b8 0c 43 10 f0       	mov    $0xf010430c,%eax
f0103911:	66 a3 a0 12 21 f0    	mov    %ax,0xf02112a0
f0103917:	66 c7 05 a2 12 21 f0 	movw   $0x8,0xf02112a2
f010391e:	08 00 
f0103920:	c6 05 a4 12 21 f0 00 	movb   $0x0,0xf02112a4
f0103927:	c6 05 a5 12 21 f0 8e 	movb   $0x8e,0xf02112a5
f010392e:	c1 e8 10             	shr    $0x10,%eax
f0103931:	66 a3 a6 12 21 f0    	mov    %ax,0xf02112a6
	SETGATE(idt[T_TSS], 0, GD_KT, trap_tss, 0);
f0103937:	b8 10 43 10 f0       	mov    $0xf0104310,%eax
f010393c:	66 a3 b0 12 21 f0    	mov    %ax,0xf02112b0
f0103942:	66 c7 05 b2 12 21 f0 	movw   $0x8,0xf02112b2
f0103949:	08 00 
f010394b:	c6 05 b4 12 21 f0 00 	movb   $0x0,0xf02112b4
f0103952:	c6 05 b5 12 21 f0 8e 	movb   $0x8e,0xf02112b5
f0103959:	c1 e8 10             	shr    $0x10,%eax
f010395c:	66 a3 b6 12 21 f0    	mov    %ax,0xf02112b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, trap_segnp, 0);
f0103962:	b8 14 43 10 f0       	mov    $0xf0104314,%eax
f0103967:	66 a3 b8 12 21 f0    	mov    %ax,0xf02112b8
f010396d:	66 c7 05 ba 12 21 f0 	movw   $0x8,0xf02112ba
f0103974:	08 00 
f0103976:	c6 05 bc 12 21 f0 00 	movb   $0x0,0xf02112bc
f010397d:	c6 05 bd 12 21 f0 8e 	movb   $0x8e,0xf02112bd
f0103984:	c1 e8 10             	shr    $0x10,%eax
f0103987:	66 a3 be 12 21 f0    	mov    %ax,0xf02112be
	SETGATE(idt[T_STACK], 0, GD_KT, trap_stack, 0);
f010398d:	b8 18 43 10 f0       	mov    $0xf0104318,%eax
f0103992:	66 a3 c0 12 21 f0    	mov    %ax,0xf02112c0
f0103998:	66 c7 05 c2 12 21 f0 	movw   $0x8,0xf02112c2
f010399f:	08 00 
f01039a1:	c6 05 c4 12 21 f0 00 	movb   $0x0,0xf02112c4
f01039a8:	c6 05 c5 12 21 f0 8e 	movb   $0x8e,0xf02112c5
f01039af:	c1 e8 10             	shr    $0x10,%eax
f01039b2:	66 a3 c6 12 21 f0    	mov    %ax,0xf02112c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, trap_gpflt, 0);
f01039b8:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f01039bd:	66 a3 c8 12 21 f0    	mov    %ax,0xf02112c8
f01039c3:	66 c7 05 ca 12 21 f0 	movw   $0x8,0xf02112ca
f01039ca:	08 00 
f01039cc:	c6 05 cc 12 21 f0 00 	movb   $0x0,0xf02112cc
f01039d3:	c6 05 cd 12 21 f0 8e 	movb   $0x8e,0xf02112cd
f01039da:	c1 e8 10             	shr    $0x10,%eax
f01039dd:	66 a3 ce 12 21 f0    	mov    %ax,0xf02112ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, trap_pgflt, 0);
f01039e3:	b8 20 43 10 f0       	mov    $0xf0104320,%eax
f01039e8:	66 a3 d0 12 21 f0    	mov    %ax,0xf02112d0
f01039ee:	66 c7 05 d2 12 21 f0 	movw   $0x8,0xf02112d2
f01039f5:	08 00 
f01039f7:	c6 05 d4 12 21 f0 00 	movb   $0x0,0xf02112d4
f01039fe:	c6 05 d5 12 21 f0 8e 	movb   $0x8e,0xf02112d5
f0103a05:	c1 e8 10             	shr    $0x10,%eax
f0103a08:	66 a3 d6 12 21 f0    	mov    %ax,0xf02112d6
	SETGATE(idt[T_FPERR], 0, GD_KT, trap_fperr, 0);
f0103a0e:	b8 24 43 10 f0       	mov    $0xf0104324,%eax
f0103a13:	66 a3 e0 12 21 f0    	mov    %ax,0xf02112e0
f0103a19:	66 c7 05 e2 12 21 f0 	movw   $0x8,0xf02112e2
f0103a20:	08 00 
f0103a22:	c6 05 e4 12 21 f0 00 	movb   $0x0,0xf02112e4
f0103a29:	c6 05 e5 12 21 f0 8e 	movb   $0x8e,0xf02112e5
f0103a30:	c1 e8 10             	shr    $0x10,%eax
f0103a33:	66 a3 e6 12 21 f0    	mov    %ax,0xf02112e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, trap_align, 0);
f0103a39:	b8 28 43 10 f0       	mov    $0xf0104328,%eax
f0103a3e:	66 a3 e8 12 21 f0    	mov    %ax,0xf02112e8
f0103a44:	66 c7 05 ea 12 21 f0 	movw   $0x8,0xf02112ea
f0103a4b:	08 00 
f0103a4d:	c6 05 ec 12 21 f0 00 	movb   $0x0,0xf02112ec
f0103a54:	c6 05 ed 12 21 f0 8e 	movb   $0x8e,0xf02112ed
f0103a5b:	c1 e8 10             	shr    $0x10,%eax
f0103a5e:	66 a3 ee 12 21 f0    	mov    %ax,0xf02112ee
	SETGATE(idt[T_MCHK], 0, GD_KT, trap_mchk, 0);
f0103a64:	b8 2c 43 10 f0       	mov    $0xf010432c,%eax
f0103a69:	66 a3 f0 12 21 f0    	mov    %ax,0xf02112f0
f0103a6f:	66 c7 05 f2 12 21 f0 	movw   $0x8,0xf02112f2
f0103a76:	08 00 
f0103a78:	c6 05 f4 12 21 f0 00 	movb   $0x0,0xf02112f4
f0103a7f:	c6 05 f5 12 21 f0 8e 	movb   $0x8e,0xf02112f5
f0103a86:	c1 e8 10             	shr    $0x10,%eax
f0103a89:	66 a3 f6 12 21 f0    	mov    %ax,0xf02112f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, trap_simderr, 0);
f0103a8f:	b8 32 43 10 f0       	mov    $0xf0104332,%eax
f0103a94:	66 a3 f8 12 21 f0    	mov    %ax,0xf02112f8
f0103a9a:	66 c7 05 fa 12 21 f0 	movw   $0x8,0xf02112fa
f0103aa1:	08 00 
f0103aa3:	c6 05 fc 12 21 f0 00 	movb   $0x0,0xf02112fc
f0103aaa:	c6 05 fd 12 21 f0 8e 	movb   $0x8e,0xf02112fd
f0103ab1:	c1 e8 10             	shr    $0x10,%eax
f0103ab4:	66 a3 fe 12 21 f0    	mov    %ax,0xf02112fe

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f0103aba:	b8 38 43 10 f0       	mov    $0xf0104338,%eax
f0103abf:	66 a3 60 13 21 f0    	mov    %ax,0xf0211360
f0103ac5:	66 c7 05 62 13 21 f0 	movw   $0x8,0xf0211362
f0103acc:	08 00 
f0103ace:	c6 05 64 13 21 f0 00 	movb   $0x0,0xf0211364
f0103ad5:	c6 05 65 13 21 f0 8e 	movb   $0x8e,0xf0211365
f0103adc:	c1 e8 10             	shr    $0x10,%eax
f0103adf:	66 a3 66 13 21 f0    	mov    %ax,0xf0211366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f0103ae5:	b8 3e 43 10 f0       	mov    $0xf010433e,%eax
f0103aea:	66 a3 68 13 21 f0    	mov    %ax,0xf0211368
f0103af0:	66 c7 05 6a 13 21 f0 	movw   $0x8,0xf021136a
f0103af7:	08 00 
f0103af9:	c6 05 6c 13 21 f0 00 	movb   $0x0,0xf021136c
f0103b00:	c6 05 6d 13 21 f0 8e 	movb   $0x8e,0xf021136d
f0103b07:	c1 e8 10             	shr    $0x10,%eax
f0103b0a:	66 a3 6e 13 21 f0    	mov    %ax,0xf021136e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f0103b10:	b8 44 43 10 f0       	mov    $0xf0104344,%eax
f0103b15:	66 a3 80 13 21 f0    	mov    %ax,0xf0211380
f0103b1b:	66 c7 05 82 13 21 f0 	movw   $0x8,0xf0211382
f0103b22:	08 00 
f0103b24:	c6 05 84 13 21 f0 00 	movb   $0x0,0xf0211384
f0103b2b:	c6 05 85 13 21 f0 8e 	movb   $0x8e,0xf0211385
f0103b32:	c1 e8 10             	shr    $0x10,%eax
f0103b35:	66 a3 86 13 21 f0    	mov    %ax,0xf0211386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f0103b3b:	b8 4a 43 10 f0       	mov    $0xf010434a,%eax
f0103b40:	66 a3 98 13 21 f0    	mov    %ax,0xf0211398
f0103b46:	66 c7 05 9a 13 21 f0 	movw   $0x8,0xf021139a
f0103b4d:	08 00 
f0103b4f:	c6 05 9c 13 21 f0 00 	movb   $0x0,0xf021139c
f0103b56:	c6 05 9d 13 21 f0 8e 	movb   $0x8e,0xf021139d
f0103b5d:	c1 e8 10             	shr    $0x10,%eax
f0103b60:	66 a3 9e 13 21 f0    	mov    %ax,0xf021139e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f0103b66:	b8 50 43 10 f0       	mov    $0xf0104350,%eax
f0103b6b:	66 a3 d0 13 21 f0    	mov    %ax,0xf02113d0
f0103b71:	66 c7 05 d2 13 21 f0 	movw   $0x8,0xf02113d2
f0103b78:	08 00 
f0103b7a:	c6 05 d4 13 21 f0 00 	movb   $0x0,0xf02113d4
f0103b81:	c6 05 d5 13 21 f0 8e 	movb   $0x8e,0xf02113d5
f0103b88:	c1 e8 10             	shr    $0x10,%eax
f0103b8b:	66 a3 d6 13 21 f0    	mov    %ax,0xf02113d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f0103b91:	b8 56 43 10 f0       	mov    $0xf0104356,%eax
f0103b96:	66 a3 f8 13 21 f0    	mov    %ax,0xf02113f8
f0103b9c:	66 c7 05 fa 13 21 f0 	movw   $0x8,0xf02113fa
f0103ba3:	08 00 
f0103ba5:	c6 05 fc 13 21 f0 00 	movb   $0x0,0xf02113fc
f0103bac:	c6 05 fd 13 21 f0 8e 	movb   $0x8e,0xf02113fd
f0103bb3:	c1 e8 10             	shr    $0x10,%eax
f0103bb6:	66 a3 fe 13 21 f0    	mov    %ax,0xf02113fe

	SETGATE(idt[T_SYSCALL], 0, GD_KT, trap_syscall, 3);
f0103bbc:	b8 5c 43 10 f0       	mov    $0xf010435c,%eax
f0103bc1:	66 a3 e0 13 21 f0    	mov    %ax,0xf02113e0
f0103bc7:	66 c7 05 e2 13 21 f0 	movw   $0x8,0xf02113e2
f0103bce:	08 00 
f0103bd0:	c6 05 e4 13 21 f0 00 	movb   $0x0,0xf02113e4
f0103bd7:	c6 05 e5 13 21 f0 ee 	movb   $0xee,0xf02113e5
f0103bde:	c1 e8 10             	shr    $0x10,%eax
f0103be1:	66 a3 e6 13 21 f0    	mov    %ax,0xf02113e6
	SETGATE(idt[T_DEFAULT], 0, GD_KT, trap_default, 3);
f0103be7:	b8 62 43 10 f0       	mov    $0xf0104362,%eax
f0103bec:	66 a3 00 22 21 f0    	mov    %ax,0xf0212200
f0103bf2:	66 c7 05 02 22 21 f0 	movw   $0x8,0xf0212202
f0103bf9:	08 00 
f0103bfb:	c6 05 04 22 21 f0 00 	movb   $0x0,0xf0212204
f0103c02:	c6 05 05 22 21 f0 ee 	movb   $0xee,0xf0212205
f0103c09:	c1 e8 10             	shr    $0x10,%eax
f0103c0c:	66 a3 06 22 21 f0    	mov    %ax,0xf0212206

	// Per-CPU setup 
	trap_init_percpu();
f0103c12:	e8 b8 fa ff ff       	call   f01036cf <trap_init_percpu>
}
f0103c17:	c9                   	leave  
f0103c18:	c3                   	ret    

f0103c19 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c19:	55                   	push   %ebp
f0103c1a:	89 e5                	mov    %esp,%ebp
f0103c1c:	53                   	push   %ebx
f0103c1d:	83 ec 0c             	sub    $0xc,%esp
f0103c20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c23:	ff 33                	pushl  (%ebx)
f0103c25:	68 f1 75 10 f0       	push   $0xf01075f1
f0103c2a:	e8 8c fa ff ff       	call   f01036bb <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c2f:	83 c4 08             	add    $0x8,%esp
f0103c32:	ff 73 04             	pushl  0x4(%ebx)
f0103c35:	68 00 76 10 f0       	push   $0xf0107600
f0103c3a:	e8 7c fa ff ff       	call   f01036bb <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c3f:	83 c4 08             	add    $0x8,%esp
f0103c42:	ff 73 08             	pushl  0x8(%ebx)
f0103c45:	68 0f 76 10 f0       	push   $0xf010760f
f0103c4a:	e8 6c fa ff ff       	call   f01036bb <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103c4f:	83 c4 08             	add    $0x8,%esp
f0103c52:	ff 73 0c             	pushl  0xc(%ebx)
f0103c55:	68 1e 76 10 f0       	push   $0xf010761e
f0103c5a:	e8 5c fa ff ff       	call   f01036bb <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103c5f:	83 c4 08             	add    $0x8,%esp
f0103c62:	ff 73 10             	pushl  0x10(%ebx)
f0103c65:	68 2d 76 10 f0       	push   $0xf010762d
f0103c6a:	e8 4c fa ff ff       	call   f01036bb <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c6f:	83 c4 08             	add    $0x8,%esp
f0103c72:	ff 73 14             	pushl  0x14(%ebx)
f0103c75:	68 3c 76 10 f0       	push   $0xf010763c
f0103c7a:	e8 3c fa ff ff       	call   f01036bb <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c7f:	83 c4 08             	add    $0x8,%esp
f0103c82:	ff 73 18             	pushl  0x18(%ebx)
f0103c85:	68 4b 76 10 f0       	push   $0xf010764b
f0103c8a:	e8 2c fa ff ff       	call   f01036bb <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c8f:	83 c4 08             	add    $0x8,%esp
f0103c92:	ff 73 1c             	pushl  0x1c(%ebx)
f0103c95:	68 5a 76 10 f0       	push   $0xf010765a
f0103c9a:	e8 1c fa ff ff       	call   f01036bb <cprintf>
}
f0103c9f:	83 c4 10             	add    $0x10,%esp
f0103ca2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ca5:	c9                   	leave  
f0103ca6:	c3                   	ret    

f0103ca7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103ca7:	55                   	push   %ebp
f0103ca8:	89 e5                	mov    %esp,%ebp
f0103caa:	56                   	push   %esi
f0103cab:	53                   	push   %ebx
f0103cac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103caf:	e8 37 20 00 00       	call   f0105ceb <cpunum>
f0103cb4:	83 ec 04             	sub    $0x4,%esp
f0103cb7:	50                   	push   %eax
f0103cb8:	53                   	push   %ebx
f0103cb9:	68 be 76 10 f0       	push   $0xf01076be
f0103cbe:	e8 f8 f9 ff ff       	call   f01036bb <cprintf>
	print_regs(&tf->tf_regs);
f0103cc3:	89 1c 24             	mov    %ebx,(%esp)
f0103cc6:	e8 4e ff ff ff       	call   f0103c19 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ccb:	83 c4 08             	add    $0x8,%esp
f0103cce:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103cd2:	50                   	push   %eax
f0103cd3:	68 dc 76 10 f0       	push   $0xf01076dc
f0103cd8:	e8 de f9 ff ff       	call   f01036bb <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103cdd:	83 c4 08             	add    $0x8,%esp
f0103ce0:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ce4:	50                   	push   %eax
f0103ce5:	68 ef 76 10 f0       	push   $0xf01076ef
f0103cea:	e8 cc f9 ff ff       	call   f01036bb <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103cef:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103cf2:	83 c4 10             	add    $0x10,%esp
f0103cf5:	83 f8 13             	cmp    $0x13,%eax
f0103cf8:	77 09                	ja     f0103d03 <print_trapframe+0x5c>
		return excnames[trapno];
f0103cfa:	8b 14 85 80 79 10 f0 	mov    -0xfef8680(,%eax,4),%edx
f0103d01:	eb 1f                	jmp    f0103d22 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103d03:	83 f8 30             	cmp    $0x30,%eax
f0103d06:	74 15                	je     f0103d1d <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103d08:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103d0b:	83 fa 10             	cmp    $0x10,%edx
f0103d0e:	b9 88 76 10 f0       	mov    $0xf0107688,%ecx
f0103d13:	ba 75 76 10 f0       	mov    $0xf0107675,%edx
f0103d18:	0f 43 d1             	cmovae %ecx,%edx
f0103d1b:	eb 05                	jmp    f0103d22 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103d1d:	ba 69 76 10 f0       	mov    $0xf0107669,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d22:	83 ec 04             	sub    $0x4,%esp
f0103d25:	52                   	push   %edx
f0103d26:	50                   	push   %eax
f0103d27:	68 02 77 10 f0       	push   $0xf0107702
f0103d2c:	e8 8a f9 ff ff       	call   f01036bb <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d31:	83 c4 10             	add    $0x10,%esp
f0103d34:	3b 1d 60 1a 21 f0    	cmp    0xf0211a60,%ebx
f0103d3a:	75 1a                	jne    f0103d56 <print_trapframe+0xaf>
f0103d3c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d40:	75 14                	jne    f0103d56 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103d42:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103d45:	83 ec 08             	sub    $0x8,%esp
f0103d48:	50                   	push   %eax
f0103d49:	68 14 77 10 f0       	push   $0xf0107714
f0103d4e:	e8 68 f9 ff ff       	call   f01036bb <cprintf>
f0103d53:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103d56:	83 ec 08             	sub    $0x8,%esp
f0103d59:	ff 73 2c             	pushl  0x2c(%ebx)
f0103d5c:	68 23 77 10 f0       	push   $0xf0107723
f0103d61:	e8 55 f9 ff ff       	call   f01036bb <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103d66:	83 c4 10             	add    $0x10,%esp
f0103d69:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d6d:	75 49                	jne    f0103db8 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103d6f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103d72:	89 c2                	mov    %eax,%edx
f0103d74:	83 e2 01             	and    $0x1,%edx
f0103d77:	ba a2 76 10 f0       	mov    $0xf01076a2,%edx
f0103d7c:	b9 97 76 10 f0       	mov    $0xf0107697,%ecx
f0103d81:	0f 44 ca             	cmove  %edx,%ecx
f0103d84:	89 c2                	mov    %eax,%edx
f0103d86:	83 e2 02             	and    $0x2,%edx
f0103d89:	ba b4 76 10 f0       	mov    $0xf01076b4,%edx
f0103d8e:	be ae 76 10 f0       	mov    $0xf01076ae,%esi
f0103d93:	0f 45 d6             	cmovne %esi,%edx
f0103d96:	83 e0 04             	and    $0x4,%eax
f0103d99:	be ee 77 10 f0       	mov    $0xf01077ee,%esi
f0103d9e:	b8 b9 76 10 f0       	mov    $0xf01076b9,%eax
f0103da3:	0f 44 c6             	cmove  %esi,%eax
f0103da6:	51                   	push   %ecx
f0103da7:	52                   	push   %edx
f0103da8:	50                   	push   %eax
f0103da9:	68 31 77 10 f0       	push   $0xf0107731
f0103dae:	e8 08 f9 ff ff       	call   f01036bb <cprintf>
f0103db3:	83 c4 10             	add    $0x10,%esp
f0103db6:	eb 10                	jmp    f0103dc8 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103db8:	83 ec 0c             	sub    $0xc,%esp
f0103dbb:	68 63 75 10 f0       	push   $0xf0107563
f0103dc0:	e8 f6 f8 ff ff       	call   f01036bb <cprintf>
f0103dc5:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103dc8:	83 ec 08             	sub    $0x8,%esp
f0103dcb:	ff 73 30             	pushl  0x30(%ebx)
f0103dce:	68 40 77 10 f0       	push   $0xf0107740
f0103dd3:	e8 e3 f8 ff ff       	call   f01036bb <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103dd8:	83 c4 08             	add    $0x8,%esp
f0103ddb:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103ddf:	50                   	push   %eax
f0103de0:	68 4f 77 10 f0       	push   $0xf010774f
f0103de5:	e8 d1 f8 ff ff       	call   f01036bb <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103dea:	83 c4 08             	add    $0x8,%esp
f0103ded:	ff 73 38             	pushl  0x38(%ebx)
f0103df0:	68 62 77 10 f0       	push   $0xf0107762
f0103df5:	e8 c1 f8 ff ff       	call   f01036bb <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103dfa:	83 c4 10             	add    $0x10,%esp
f0103dfd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e01:	74 25                	je     f0103e28 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e03:	83 ec 08             	sub    $0x8,%esp
f0103e06:	ff 73 3c             	pushl  0x3c(%ebx)
f0103e09:	68 71 77 10 f0       	push   $0xf0107771
f0103e0e:	e8 a8 f8 ff ff       	call   f01036bb <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e13:	83 c4 08             	add    $0x8,%esp
f0103e16:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e1a:	50                   	push   %eax
f0103e1b:	68 80 77 10 f0       	push   $0xf0107780
f0103e20:	e8 96 f8 ff ff       	call   f01036bb <cprintf>
f0103e25:	83 c4 10             	add    $0x10,%esp
	}
}
f0103e28:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e2b:	5b                   	pop    %ebx
f0103e2c:	5e                   	pop    %esi
f0103e2d:	5d                   	pop    %ebp
f0103e2e:	c3                   	ret    

f0103e2f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e2f:	55                   	push   %ebp
f0103e30:	89 e5                	mov    %esp,%ebp
f0103e32:	57                   	push   %edi
f0103e33:	56                   	push   %esi
f0103e34:	53                   	push   %ebx
f0103e35:	83 ec 0c             	sub    $0xc,%esp
f0103e38:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103e3b:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0){
f0103e3e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e42:	75 1e                	jne    f0103e62 <page_fault_handler+0x33>
		print_trapframe(tf);
f0103e44:	83 ec 0c             	sub    $0xc,%esp
f0103e47:	53                   	push   %ebx
f0103e48:	e8 5a fe ff ff       	call   f0103ca7 <print_trapframe>
		panic("Kernel-mode page fault at %08x", fault_va);
f0103e4d:	56                   	push   %esi
f0103e4e:	68 38 79 10 f0       	push   $0xf0107938
f0103e53:	68 70 01 00 00       	push   $0x170
f0103e58:	68 93 77 10 f0       	push   $0xf0107793
f0103e5d:	e8 de c1 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// print_trapframe(tf);
	if (curenv->env_pgfault_upcall){
f0103e62:	e8 84 1e 00 00       	call   f0105ceb <cpunum>
f0103e67:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e6a:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103e70:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103e74:	0f 84 f7 01 00 00    	je     f0104071 <page_fault_handler+0x242>
		// cprintf("Have pgfault upcall\n");
		// Check the page fault upcall
		user_mem_assert(curenv, curenv->env_pgfault_upcall, 1, PTE_P | PTE_U);
f0103e7a:	e8 6c 1e 00 00       	call   f0105ceb <cpunum>
f0103e7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e82:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103e88:	8b 78 64             	mov    0x64(%eax),%edi
f0103e8b:	e8 5b 1e 00 00       	call   f0105ceb <cpunum>
f0103e90:	6a 05                	push   $0x5
f0103e92:	6a 01                	push   $0x1
f0103e94:	57                   	push   %edi
f0103e95:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e98:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103e9e:	e8 27 ef ff ff       	call   f0102dca <user_mem_assert>
		uintptr_t esp = curenv->env_tf.tf_esp;
f0103ea3:	e8 43 1e 00 00       	call   f0105ceb <cpunum>
f0103ea8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eab:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103eb1:	8b 78 3c             	mov    0x3c(%eax),%edi
		if (esp >= USTACKTOP - PGSIZE && esp <= USTACKTOP - 1){
f0103eb4:	8d 87 00 30 40 11    	lea    0x11403000(%edi),%eax
f0103eba:	83 c4 10             	add    $0x10,%esp
f0103ebd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0103ec2:	0f 87 e1 00 00 00    	ja     f0103fa9 <page_fault_handler+0x17a>
			// From user stack
			user_mem_assert(curenv, (const void*)(UXSTACKTOP - sizeof(struct 
f0103ec8:	e8 1e 1e 00 00       	call   f0105ceb <cpunum>
f0103ecd:	6a 07                	push   $0x7
f0103ecf:	6a 34                	push   $0x34
f0103ed1:	68 cc ff bf ee       	push   $0xeebfffcc
f0103ed6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed9:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103edf:	e8 e6 ee ff ff       	call   f0102dca <user_mem_assert>
							UTrapframe)), sizeof(struct UTrapframe), 
					PTE_P | PTE_U | PTE_W);
			struct UTrapframe* utf = (struct UTrapframe*)(UXSTACKTOP - 
					sizeof(struct UTrapframe));
			utf->utf_fault_va = fault_va;
f0103ee4:	89 35 cc ff bf ee    	mov    %esi,0xeebfffcc
			utf->utf_err = curenv->env_tf.tf_err;   
f0103eea:	e8 fc 1d 00 00       	call   f0105ceb <cpunum>
f0103eef:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ef2:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103ef8:	8b 40 2c             	mov    0x2c(%eax),%eax
f0103efb:	a3 d0 ff bf ee       	mov    %eax,0xeebfffd0

			utf->utf_regs = curenv->env_tf.tf_regs;
f0103f00:	e8 e6 1d 00 00       	call   f0105ceb <cpunum>
f0103f05:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f08:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f0103f0e:	bf d4 ff bf ee       	mov    $0xeebfffd4,%edi
f0103f13:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			utf->utf_eip = curenv->env_tf.tf_eip;
f0103f1a:	e8 cc 1d 00 00       	call   f0105ceb <cpunum>
f0103f1f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f22:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103f28:	8b 40 30             	mov    0x30(%eax),%eax
f0103f2b:	a3 f4 ff bf ee       	mov    %eax,0xeebffff4
			utf->utf_eflags = curenv->env_tf.tf_eflags;
f0103f30:	e8 b6 1d 00 00       	call   f0105ceb <cpunum>
f0103f35:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f38:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103f3e:	8b 40 38             	mov    0x38(%eax),%eax
f0103f41:	a3 f8 ff bf ee       	mov    %eax,0xeebffff8
			utf->utf_esp = curenv->env_tf.tf_esp;
f0103f46:	e8 a0 1d 00 00       	call   f0105ceb <cpunum>
f0103f4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f4e:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103f54:	8b 40 3c             	mov    0x3c(%eax),%eax
f0103f57:	a3 fc ff bf ee       	mov    %eax,0xeebffffc

			// Now branch
			curenv->env_tf.tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f0103f5c:	e8 8a 1d 00 00       	call   f0105ceb <cpunum>
f0103f61:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f64:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f0103f6a:	e8 7c 1d 00 00       	call   f0105ceb <cpunum>
f0103f6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f72:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103f78:	8b 40 64             	mov    0x64(%eax),%eax
f0103f7b:	89 43 30             	mov    %eax,0x30(%ebx)
			curenv->env_tf.tf_esp = (uintptr_t)utf;
f0103f7e:	e8 68 1d 00 00       	call   f0105ceb <cpunum>
f0103f83:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f86:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103f8c:	c7 40 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%eax)
			env_run(curenv);
f0103f93:	e8 53 1d 00 00       	call   f0105ceb <cpunum>
f0103f98:	83 c4 04             	add    $0x4,%esp
f0103f9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f9e:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103fa4:	e8 bb f4 ff ff       	call   f0103464 <env_run>
		}
		else if (esp >= UXSTACKTOP - PGSIZE && esp <= UXSTACKTOP - 1){
f0103fa9:	8d 87 00 10 40 11    	lea    0x11401000(%edi),%eax
f0103faf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0103fb4:	0f 87 b7 00 00 00    	ja     f0104071 <page_fault_handler+0x242>
			// From user exception stack
			struct UTrapframe* utf = (struct UTrapframe*)((char*)esp - 
					sizeof(struct UTrapframe) - 4);
f0103fba:	8d 5f c8             	lea    -0x38(%edi),%ebx
			utf->utf_fault_va = fault_va;
f0103fbd:	89 77 c8             	mov    %esi,-0x38(%edi)
			utf->utf_err = curenv->env_tf.tf_err;   
f0103fc0:	e8 26 1d 00 00       	call   f0105ceb <cpunum>
f0103fc5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc8:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103fce:	8b 40 2c             	mov    0x2c(%eax),%eax
f0103fd1:	89 43 04             	mov    %eax,0x4(%ebx)

			utf->utf_regs = curenv->env_tf.tf_regs;
f0103fd4:	e8 12 1d 00 00       	call   f0105ceb <cpunum>
f0103fd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fdc:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f0103fe2:	83 ef 30             	sub    $0x30,%edi
f0103fe5:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103fea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			utf->utf_eip = curenv->env_tf.tf_eip;
f0103fec:	e8 fa 1c 00 00       	call   f0105ceb <cpunum>
f0103ff1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff4:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103ffa:	8b 40 30             	mov    0x30(%eax),%eax
f0103ffd:	89 43 28             	mov    %eax,0x28(%ebx)
			utf->utf_eflags = curenv->env_tf.tf_eflags;
f0104000:	e8 e6 1c 00 00       	call   f0105ceb <cpunum>
f0104005:	6b c0 74             	imul   $0x74,%eax,%eax
f0104008:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010400e:	8b 40 38             	mov    0x38(%eax),%eax
f0104011:	89 43 2c             	mov    %eax,0x2c(%ebx)
			utf->utf_esp = curenv->env_tf.tf_esp;
f0104014:	e8 d2 1c 00 00       	call   f0105ceb <cpunum>
f0104019:	6b c0 74             	imul   $0x74,%eax,%eax
f010401c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104022:	8b 40 3c             	mov    0x3c(%eax),%eax
f0104025:	89 43 30             	mov    %eax,0x30(%ebx)

			// Now branch
			curenv->env_tf.tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f0104028:	e8 be 1c 00 00       	call   f0105ceb <cpunum>
f010402d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104030:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f0104036:	e8 b0 1c 00 00       	call   f0105ceb <cpunum>
f010403b:	6b c0 74             	imul   $0x74,%eax,%eax
f010403e:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104044:	8b 40 64             	mov    0x64(%eax),%eax
f0104047:	89 46 30             	mov    %eax,0x30(%esi)
			curenv->env_tf.tf_esp = (uintptr_t)utf;
f010404a:	e8 9c 1c 00 00       	call   f0105ceb <cpunum>
f010404f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104052:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104058:	89 58 3c             	mov    %ebx,0x3c(%eax)
			env_run(curenv);
f010405b:	e8 8b 1c 00 00       	call   f0105ceb <cpunum>
f0104060:	83 ec 0c             	sub    $0xc,%esp
f0104063:	6b c0 74             	imul   $0x74,%eax,%eax
f0104066:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f010406c:	e8 f3 f3 ff ff       	call   f0103464 <env_run>
		}
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104071:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104074:	e8 72 1c 00 00       	call   f0105ceb <cpunum>
			env_run(curenv);
		}
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104079:	57                   	push   %edi
f010407a:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f010407b:	6b c0 74             	imul   $0x74,%eax,%eax
			env_run(curenv);
		}
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010407e:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104084:	ff 70 48             	pushl  0x48(%eax)
f0104087:	68 58 79 10 f0       	push   $0xf0107958
f010408c:	e8 2a f6 ff ff       	call   f01036bb <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104091:	89 1c 24             	mov    %ebx,(%esp)
f0104094:	e8 0e fc ff ff       	call   f0103ca7 <print_trapframe>
	env_destroy(curenv);
f0104099:	e8 4d 1c 00 00       	call   f0105ceb <cpunum>
f010409e:	83 c4 04             	add    $0x4,%esp
f01040a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a4:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01040aa:	e8 09 f3 ff ff       	call   f01033b8 <env_destroy>
}
f01040af:	83 c4 10             	add    $0x10,%esp
f01040b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040b5:	5b                   	pop    %ebx
f01040b6:	5e                   	pop    %esi
f01040b7:	5f                   	pop    %edi
f01040b8:	5d                   	pop    %ebp
f01040b9:	c3                   	ret    

f01040ba <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040ba:	55                   	push   %ebp
f01040bb:	89 e5                	mov    %esp,%ebp
f01040bd:	57                   	push   %edi
f01040be:	56                   	push   %esi
f01040bf:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040c2:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040c3:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f01040ca:	74 01                	je     f01040cd <trap+0x13>
		asm volatile("hlt");
f01040cc:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040cd:	e8 19 1c 00 00       	call   f0105ceb <cpunum>
f01040d2:	6b d0 74             	imul   $0x74,%eax,%edx
f01040d5:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01040db:	b8 01 00 00 00       	mov    $0x1,%eax
f01040e0:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01040e4:	83 f8 02             	cmp    $0x2,%eax
f01040e7:	75 10                	jne    f01040f9 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01040e9:	83 ec 0c             	sub    $0xc,%esp
f01040ec:	68 c0 03 12 f0       	push   $0xf01203c0
f01040f1:	e8 63 1e 00 00       	call   f0105f59 <spin_lock>
f01040f6:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01040f9:	9c                   	pushf  
f01040fa:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01040fb:	f6 c4 02             	test   $0x2,%ah
f01040fe:	74 19                	je     f0104119 <trap+0x5f>
f0104100:	68 9f 77 10 f0       	push   $0xf010779f
f0104105:	68 88 72 10 f0       	push   $0xf0107288
f010410a:	68 39 01 00 00       	push   $0x139
f010410f:	68 93 77 10 f0       	push   $0xf0107793
f0104114:	e8 27 bf ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104119:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010411d:	83 e0 03             	and    $0x3,%eax
f0104120:	66 83 f8 03          	cmp    $0x3,%ax
f0104124:	0f 85 a0 00 00 00    	jne    f01041ca <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		spin_lock(&kernel_lock);
f010412a:	83 ec 0c             	sub    $0xc,%esp
f010412d:	68 c0 03 12 f0       	push   $0xf01203c0
f0104132:	e8 22 1e 00 00       	call   f0105f59 <spin_lock>
		assert(curenv);
f0104137:	e8 af 1b 00 00       	call   f0105ceb <cpunum>
f010413c:	6b c0 74             	imul   $0x74,%eax,%eax
f010413f:	83 c4 10             	add    $0x10,%esp
f0104142:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0104149:	75 19                	jne    f0104164 <trap+0xaa>
f010414b:	68 b8 77 10 f0       	push   $0xf01077b8
f0104150:	68 88 72 10 f0       	push   $0xf0107288
f0104155:	68 41 01 00 00       	push   $0x141
f010415a:	68 93 77 10 f0       	push   $0xf0107793
f010415f:	e8 dc be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104164:	e8 82 1b 00 00       	call   f0105ceb <cpunum>
f0104169:	6b c0 74             	imul   $0x74,%eax,%eax
f010416c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104172:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104176:	75 2d                	jne    f01041a5 <trap+0xeb>
			env_free(curenv);
f0104178:	e8 6e 1b 00 00       	call   f0105ceb <cpunum>
f010417d:	83 ec 0c             	sub    $0xc,%esp
f0104180:	6b c0 74             	imul   $0x74,%eax,%eax
f0104183:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104189:	e8 84 f0 ff ff       	call   f0103212 <env_free>
			curenv = NULL;
f010418e:	e8 58 1b 00 00       	call   f0105ceb <cpunum>
f0104193:	6b c0 74             	imul   $0x74,%eax,%eax
f0104196:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f010419d:	00 00 00 
			sched_yield();
f01041a0:	e8 ab 02 00 00       	call   f0104450 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041a5:	e8 41 1b 00 00       	call   f0105ceb <cpunum>
f01041aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ad:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01041b3:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041b8:	89 c7                	mov    %eax,%edi
f01041ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041bc:	e8 2a 1b 00 00       	call   f0105ceb <cpunum>
f01041c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c4:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041ca:	89 35 60 1a 21 f0    	mov    %esi,0xf0211a60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01041d0:	8b 46 28             	mov    0x28(%esi),%eax
f01041d3:	83 f8 27             	cmp    $0x27,%eax
f01041d6:	75 1d                	jne    f01041f5 <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f01041d8:	83 ec 0c             	sub    $0xc,%esp
f01041db:	68 bf 77 10 f0       	push   $0xf01077bf
f01041e0:	e8 d6 f4 ff ff       	call   f01036bb <cprintf>
		print_trapframe(tf);
f01041e5:	89 34 24             	mov    %esi,(%esp)
f01041e8:	e8 ba fa ff ff       	call   f0103ca7 <print_trapframe>
f01041ed:	83 c4 10             	add    $0x10,%esp
f01041f0:	e9 9e 00 00 00       	jmp    f0104293 <trap+0x1d9>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01041f5:	83 f8 20             	cmp    $0x20,%eax
f01041f8:	75 0a                	jne    f0104204 <trap+0x14a>
		lapic_eoi();
f01041fa:	e8 37 1c 00 00       	call   f0105e36 <lapic_eoi>
		// cprintf("Time out\n");
		sched_yield();
f01041ff:	e8 4c 02 00 00       	call   f0104450 <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	if (tf->tf_trapno == T_PGFLT){
f0104204:	83 f8 0e             	cmp    $0xe,%eax
f0104207:	75 0e                	jne    f0104217 <trap+0x15d>
		page_fault_handler(tf);
f0104209:	83 ec 0c             	sub    $0xc,%esp
f010420c:	56                   	push   %esi
f010420d:	e8 1d fc ff ff       	call   f0103e2f <page_fault_handler>
f0104212:	83 c4 10             	add    $0x10,%esp
f0104215:	eb 7c                	jmp    f0104293 <trap+0x1d9>
	}
	else if (tf->tf_trapno == T_BRKPT){
f0104217:	83 f8 03             	cmp    $0x3,%eax
f010421a:	75 0e                	jne    f010422a <trap+0x170>
		monitor(tf);
f010421c:	83 ec 0c             	sub    $0xc,%esp
f010421f:	56                   	push   %esi
f0104220:	e8 1c c7 ff ff       	call   f0100941 <monitor>
f0104225:	83 c4 10             	add    $0x10,%esp
f0104228:	eb 69                	jmp    f0104293 <trap+0x1d9>
	}
	else if (tf->tf_trapno == T_SYSCALL){
f010422a:	83 f8 30             	cmp    $0x30,%eax
f010422d:	75 21                	jne    f0104250 <trap+0x196>
		uint32_t a2 = tf->tf_regs.reg_ecx;
		uint32_t a3 = tf->tf_regs.reg_ebx;
		uint32_t a4 = tf->tf_regs.reg_edi;
		uint32_t a5 = tf->tf_regs.reg_esi;
		// cprintf("System call No: %u\n", syscallno);
		int32_t ret = syscall(syscallno, a1, a2, a3, a4, a5);
f010422f:	83 ec 08             	sub    $0x8,%esp
f0104232:	ff 76 04             	pushl  0x4(%esi)
f0104235:	ff 36                	pushl  (%esi)
f0104237:	ff 76 10             	pushl  0x10(%esi)
f010423a:	ff 76 18             	pushl  0x18(%esi)
f010423d:	ff 76 14             	pushl  0x14(%esi)
f0104240:	ff 76 1c             	pushl  0x1c(%esi)
f0104243:	e8 af 02 00 00       	call   f01044f7 <syscall>
		// asm volatile("movl %0, %%eax":: "r" (ret) : "%eax");
		tf->tf_regs.reg_eax = ret;
f0104248:	89 46 1c             	mov    %eax,0x1c(%esi)
f010424b:	83 c4 20             	add    $0x20,%esp
f010424e:	eb 43                	jmp    f0104293 <trap+0x1d9>
	}
	else {
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f0104250:	83 ec 0c             	sub    $0xc,%esp
f0104253:	56                   	push   %esi
f0104254:	e8 4e fa ff ff       	call   f0103ca7 <print_trapframe>
		if (tf->tf_cs == GD_KT)
f0104259:	83 c4 10             	add    $0x10,%esp
f010425c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104261:	75 17                	jne    f010427a <trap+0x1c0>
			panic("unhandled trap in kernel");
f0104263:	83 ec 04             	sub    $0x4,%esp
f0104266:	68 dc 77 10 f0       	push   $0xf01077dc
f010426b:	68 1e 01 00 00       	push   $0x11e
f0104270:	68 93 77 10 f0       	push   $0xf0107793
f0104275:	e8 c6 bd ff ff       	call   f0100040 <_panic>
		else {
			env_destroy(curenv);
f010427a:	e8 6c 1a 00 00       	call   f0105ceb <cpunum>
f010427f:	83 ec 0c             	sub    $0xc,%esp
f0104282:	6b c0 74             	imul   $0x74,%eax,%eax
f0104285:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f010428b:	e8 28 f1 ff ff       	call   f01033b8 <env_destroy>
f0104290:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104293:	e8 53 1a 00 00       	call   f0105ceb <cpunum>
f0104298:	6b c0 74             	imul   $0x74,%eax,%eax
f010429b:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01042a2:	74 2a                	je     f01042ce <trap+0x214>
f01042a4:	e8 42 1a 00 00       	call   f0105ceb <cpunum>
f01042a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ac:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01042b2:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042b6:	75 16                	jne    f01042ce <trap+0x214>
		env_run(curenv);
f01042b8:	e8 2e 1a 00 00       	call   f0105ceb <cpunum>
f01042bd:	83 ec 0c             	sub    $0xc,%esp
f01042c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c3:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01042c9:	e8 96 f1 ff ff       	call   f0103464 <env_run>
	else
		sched_yield();
f01042ce:	e8 7d 01 00 00       	call   f0104450 <sched_yield>
f01042d3:	90                   	nop

f01042d4 <trap_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(trap_divide, T_DIVIDE)
f01042d4:	6a 00                	push   $0x0
f01042d6:	6a 00                	push   $0x0
f01042d8:	e9 8e 00 00 00       	jmp    f010436b <_alltraps>
f01042dd:	90                   	nop

f01042de <trap_debug>:
TRAPHANDLER_NOEC(trap_debug, T_DEBUG)
f01042de:	6a 00                	push   $0x0
f01042e0:	6a 01                	push   $0x1
f01042e2:	e9 84 00 00 00       	jmp    f010436b <_alltraps>
f01042e7:	90                   	nop

f01042e8 <trap_nmi>:
TRAPHANDLER_NOEC(trap_nmi, T_NMI)
f01042e8:	6a 00                	push   $0x0
f01042ea:	6a 02                	push   $0x2
f01042ec:	eb 7d                	jmp    f010436b <_alltraps>

f01042ee <trap_brkpt>:
TRAPHANDLER_NOEC(trap_brkpt, T_BRKPT)
f01042ee:	6a 00                	push   $0x0
f01042f0:	6a 03                	push   $0x3
f01042f2:	eb 77                	jmp    f010436b <_alltraps>

f01042f4 <trap_oflow>:
TRAPHANDLER_NOEC(trap_oflow, T_OFLOW)
f01042f4:	6a 00                	push   $0x0
f01042f6:	6a 04                	push   $0x4
f01042f8:	eb 71                	jmp    f010436b <_alltraps>

f01042fa <trap_bound>:
TRAPHANDLER_NOEC(trap_bound, T_BOUND)
f01042fa:	6a 00                	push   $0x0
f01042fc:	6a 05                	push   $0x5
f01042fe:	eb 6b                	jmp    f010436b <_alltraps>

f0104300 <trap_illop>:
TRAPHANDLER_NOEC(trap_illop, T_ILLOP)
f0104300:	6a 00                	push   $0x0
f0104302:	6a 06                	push   $0x6
f0104304:	eb 65                	jmp    f010436b <_alltraps>

f0104306 <trap_device>:
TRAPHANDLER_NOEC(trap_device, T_DEVICE)
f0104306:	6a 00                	push   $0x0
f0104308:	6a 07                	push   $0x7
f010430a:	eb 5f                	jmp    f010436b <_alltraps>

f010430c <trap_dblflt>:
TRAPHANDLER(trap_dblflt, T_DBLFLT)
f010430c:	6a 08                	push   $0x8
f010430e:	eb 5b                	jmp    f010436b <_alltraps>

f0104310 <trap_tss>:
TRAPHANDLER(trap_tss, T_TSS)
f0104310:	6a 0a                	push   $0xa
f0104312:	eb 57                	jmp    f010436b <_alltraps>

f0104314 <trap_segnp>:
TRAPHANDLER(trap_segnp, T_SEGNP)
f0104314:	6a 0b                	push   $0xb
f0104316:	eb 53                	jmp    f010436b <_alltraps>

f0104318 <trap_stack>:
TRAPHANDLER(trap_stack, T_STACK)
f0104318:	6a 0c                	push   $0xc
f010431a:	eb 4f                	jmp    f010436b <_alltraps>

f010431c <trap_gpflt>:
TRAPHANDLER(trap_gpflt, T_GPFLT)
f010431c:	6a 0d                	push   $0xd
f010431e:	eb 4b                	jmp    f010436b <_alltraps>

f0104320 <trap_pgflt>:
TRAPHANDLER(trap_pgflt, T_PGFLT)
f0104320:	6a 0e                	push   $0xe
f0104322:	eb 47                	jmp    f010436b <_alltraps>

f0104324 <trap_fperr>:
TRAPHANDLER(trap_fperr, T_FPERR)
f0104324:	6a 10                	push   $0x10
f0104326:	eb 43                	jmp    f010436b <_alltraps>

f0104328 <trap_align>:
TRAPHANDLER(trap_align, T_ALIGN)
f0104328:	6a 11                	push   $0x11
f010432a:	eb 3f                	jmp    f010436b <_alltraps>

f010432c <trap_mchk>:
TRAPHANDLER_NOEC(trap_mchk, T_MCHK)
f010432c:	6a 00                	push   $0x0
f010432e:	6a 12                	push   $0x12
f0104330:	eb 39                	jmp    f010436b <_alltraps>

f0104332 <trap_simderr>:
TRAPHANDLER_NOEC(trap_simderr, T_SIMDERR)
f0104332:	6a 00                	push   $0x0
f0104334:	6a 13                	push   $0x13
f0104336:	eb 33                	jmp    f010436b <_alltraps>

f0104338 <irq_timer>:

TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET + IRQ_TIMER)
f0104338:	6a 00                	push   $0x0
f010433a:	6a 20                	push   $0x20
f010433c:	eb 2d                	jmp    f010436b <_alltraps>

f010433e <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET + IRQ_KBD)
f010433e:	6a 00                	push   $0x0
f0104340:	6a 21                	push   $0x21
f0104342:	eb 27                	jmp    f010436b <_alltraps>

f0104344 <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET + IRQ_SERIAL)
f0104344:	6a 00                	push   $0x0
f0104346:	6a 24                	push   $0x24
f0104348:	eb 21                	jmp    f010436b <_alltraps>

f010434a <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f010434a:	6a 00                	push   $0x0
f010434c:	6a 27                	push   $0x27
f010434e:	eb 1b                	jmp    f010436b <_alltraps>

f0104350 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET + IRQ_IDE)
f0104350:	6a 00                	push   $0x0
f0104352:	6a 2e                	push   $0x2e
f0104354:	eb 15                	jmp    f010436b <_alltraps>

f0104356 <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET + IRQ_ERROR)
f0104356:	6a 00                	push   $0x0
f0104358:	6a 33                	push   $0x33
f010435a:	eb 0f                	jmp    f010436b <_alltraps>

f010435c <trap_syscall>:

TRAPHANDLER_NOEC(trap_syscall, T_SYSCALL)
f010435c:	6a 00                	push   $0x0
f010435e:	6a 30                	push   $0x30
f0104360:	eb 09                	jmp    f010436b <_alltraps>

f0104362 <trap_default>:
TRAPHANDLER_NOEC(trap_default, T_DEFAULT)
f0104362:	6a 00                	push   $0x0
f0104364:	68 f4 01 00 00       	push   $0x1f4
f0104369:	eb 00                	jmp    f010436b <_alltraps>

f010436b <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f010436b:	1e                   	push   %ds
	pushl %es
f010436c:	06                   	push   %es
	pushal
f010436d:	60                   	pusha  

	movw $GD_KD, %ax
f010436e:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104372:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104374:	8e c0                	mov    %eax,%es

	pushl %esp
f0104376:	54                   	push   %esp
	call trap
f0104377:	e8 3e fd ff ff       	call   f01040ba <trap>

f010437c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010437c:	55                   	push   %ebp
f010437d:	89 e5                	mov    %esp,%ebp
f010437f:	83 ec 08             	sub    $0x8,%esp
f0104382:	a1 48 12 21 f0       	mov    0xf0211248,%eax
f0104387:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010438a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010438f:	8b 02                	mov    (%edx),%eax
f0104391:	83 e8 01             	sub    $0x1,%eax
f0104394:	83 f8 02             	cmp    $0x2,%eax
f0104397:	76 10                	jbe    f01043a9 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104399:	83 c1 01             	add    $0x1,%ecx
f010439c:	83 c2 7c             	add    $0x7c,%edx
f010439f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043a5:	75 e8                	jne    f010438f <sched_halt+0x13>
f01043a7:	eb 08                	jmp    f01043b1 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01043a9:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043af:	75 1f                	jne    f01043d0 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01043b1:	83 ec 0c             	sub    $0xc,%esp
f01043b4:	68 d0 79 10 f0       	push   $0xf01079d0
f01043b9:	e8 fd f2 ff ff       	call   f01036bb <cprintf>
f01043be:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01043c1:	83 ec 0c             	sub    $0xc,%esp
f01043c4:	6a 00                	push   $0x0
f01043c6:	e8 76 c5 ff ff       	call   f0100941 <monitor>
f01043cb:	83 c4 10             	add    $0x10,%esp
f01043ce:	eb f1                	jmp    f01043c1 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01043d0:	e8 16 19 00 00       	call   f0105ceb <cpunum>
f01043d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d8:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01043df:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01043e2:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043ec:	77 12                	ja     f0104400 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043ee:	50                   	push   %eax
f01043ef:	68 c8 63 10 f0       	push   $0xf01063c8
f01043f4:	6a 51                	push   $0x51
f01043f6:	68 f9 79 10 f0       	push   $0xf01079f9
f01043fb:	e8 40 bc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104400:	05 00 00 00 10       	add    $0x10000000,%eax
f0104405:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104408:	e8 de 18 00 00       	call   f0105ceb <cpunum>
f010440d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104410:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104416:	b8 02 00 00 00       	mov    $0x2,%eax
f010441b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010441f:	83 ec 0c             	sub    $0xc,%esp
f0104422:	68 c0 03 12 f0       	push   $0xf01203c0
f0104427:	e8 ca 1b 00 00       	call   f0105ff6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010442c:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010442e:	e8 b8 18 00 00       	call   f0105ceb <cpunum>
f0104433:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104436:	8b 80 30 20 21 f0    	mov    -0xfdedfd0(%eax),%eax
f010443c:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104441:	89 c4                	mov    %eax,%esp
f0104443:	6a 00                	push   $0x0
f0104445:	6a 00                	push   $0x0
f0104447:	fb                   	sti    
f0104448:	f4                   	hlt    
f0104449:	eb fd                	jmp    f0104448 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010444b:	83 c4 10             	add    $0x10,%esp
f010444e:	c9                   	leave  
f010444f:	c3                   	ret    

f0104450 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104450:	55                   	push   %ebp
f0104451:	89 e5                	mov    %esp,%ebp
f0104453:	53                   	push   %ebx
f0104454:	83 ec 04             	sub    $0x4,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = NULL;
	uint32_t cur;
	if (curenv) {
f0104457:	e8 8f 18 00 00       	call   f0105ceb <cpunum>
f010445c:	6b c0 74             	imul   $0x74,%eax,%eax
		cur = ENVX(curenv->env_id);
		// cprintf("sched: current envid = %08x\n", curenv->env_id);
	}
	else cur = 0;
f010445f:	b9 00 00 00 00       	mov    $0x0,%ecx
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = NULL;
	uint32_t cur;
	if (curenv) {
f0104464:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f010446b:	74 17                	je     f0104484 <sched_yield+0x34>
		cur = ENVX(curenv->env_id);
f010446d:	e8 79 18 00 00       	call   f0105ceb <cpunum>
f0104472:	6b c0 74             	imul   $0x74,%eax,%eax
f0104475:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010447b:	8b 48 48             	mov    0x48(%eax),%ecx
f010447e:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		// cprintf("sched: current envid = %08x\n", curenv->env_id);
	}
	else cur = 0;
	uint32_t i = cur;
	do {
		if (envs[i].env_status == ENV_RUNNABLE){
f0104484:	8b 1d 48 12 21 f0    	mov    0xf0211248,%ebx
	if (curenv) {
		cur = ENVX(curenv->env_id);
		// cprintf("sched: current envid = %08x\n", curenv->env_id);
	}
	else cur = 0;
	uint32_t i = cur;
f010448a:	89 c8                	mov    %ecx,%eax
	do {
		if (envs[i].env_status == ENV_RUNNABLE){
f010448c:	6b d0 7c             	imul   $0x7c,%eax,%edx
f010448f:	01 da                	add    %ebx,%edx
f0104491:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104495:	74 0e                	je     f01044a5 <sched_yield+0x55>
			idle = &envs[i];
			break;
		}
		i = (i + 1) % NENV;
f0104497:	83 c0 01             	add    $0x1,%eax
f010449a:	25 ff 03 00 00       	and    $0x3ff,%eax
	} while (i != cur);
f010449f:	39 c1                	cmp    %eax,%ecx
f01044a1:	75 e9                	jne    f010448c <sched_yield+0x3c>
f01044a3:	eb 0d                	jmp    f01044b2 <sched_yield+0x62>
	// if (idle)
	// 	cprintf("sched: chosen envid = %08x\n", idle->env_id);

	if (idle) env_run(idle);
f01044a5:	85 d2                	test   %edx,%edx
f01044a7:	74 09                	je     f01044b2 <sched_yield+0x62>
f01044a9:	83 ec 0c             	sub    $0xc,%esp
f01044ac:	52                   	push   %edx
f01044ad:	e8 b2 ef ff ff       	call   f0103464 <env_run>
	else if (curenv && curenv->env_status == ENV_RUNNING) env_run(curenv);
f01044b2:	e8 34 18 00 00       	call   f0105ceb <cpunum>
f01044b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ba:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01044c1:	74 2a                	je     f01044ed <sched_yield+0x9d>
f01044c3:	e8 23 18 00 00       	call   f0105ceb <cpunum>
f01044c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01044cb:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01044d1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01044d5:	75 16                	jne    f01044ed <sched_yield+0x9d>
f01044d7:	e8 0f 18 00 00       	call   f0105ceb <cpunum>
f01044dc:	83 ec 0c             	sub    $0xc,%esp
f01044df:	6b c0 74             	imul   $0x74,%eax,%eax
f01044e2:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01044e8:	e8 77 ef ff ff       	call   f0103464 <env_run>

	// sched_halt never returns
	sched_halt();
f01044ed:	e8 8a fe ff ff       	call   f010437c <sched_halt>
}
f01044f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01044f5:	c9                   	leave  
f01044f6:	c3                   	ret    

f01044f7 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01044f7:	55                   	push   %ebp
f01044f8:	89 e5                	mov    %esp,%ebp
f01044fa:	53                   	push   %ebx
f01044fb:	83 ec 14             	sub    $0x14,%esp
f01044fe:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0104501:	83 f8 0d             	cmp    $0xd,%eax
f0104504:	0f 87 22 05 00 00    	ja     f0104a2c <syscall+0x535>
f010450a:	ff 24 85 1c 7a 10 f0 	jmp    *-0xfef85e4(,%eax,4)
		if (!(*pte & PTE_U)) {
			env_destroy(curenv);
			return;
		}
	} */
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);
f0104511:	e8 d5 17 00 00       	call   f0105ceb <cpunum>
f0104516:	6a 05                	push   $0x5
f0104518:	ff 75 10             	pushl  0x10(%ebp)
f010451b:	ff 75 0c             	pushl  0xc(%ebp)
f010451e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104521:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104527:	e8 9e e8 ff ff       	call   f0102dca <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010452c:	83 c4 0c             	add    $0xc,%esp
f010452f:	ff 75 0c             	pushl  0xc(%ebp)
f0104532:	ff 75 10             	pushl  0x10(%ebp)
f0104535:	68 06 7a 10 f0       	push   $0xf0107a06
f010453a:	e8 7c f1 ff ff       	call   f01036bb <cprintf>
f010453f:	83 c4 10             	add    $0x10,%esp
	// panic("syscall not implemented");

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
f0104542:	b8 00 00 00 00       	mov    $0x0,%eax
f0104547:	e9 4a 05 00 00       	jmp    f0104a96 <syscall+0x59f>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010454c:	e8 b8 c0 ff ff       	call   f0100609 <cons_getc>
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104551:	e9 40 05 00 00       	jmp    f0104a96 <syscall+0x59f>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104556:	e8 90 17 00 00       	call   f0105ceb <cpunum>
f010455b:	6b c0 74             	imul   $0x74,%eax,%eax
f010455e:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104564:	8b 40 48             	mov    0x48(%eax),%eax
		sys_cputs((const char*)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
f0104567:	e9 2a 05 00 00       	jmp    f0104a96 <syscall+0x59f>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010456c:	83 ec 04             	sub    $0x4,%esp
f010456f:	6a 01                	push   $0x1
f0104571:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104574:	50                   	push   %eax
f0104575:	ff 75 0c             	pushl  0xc(%ebp)
f0104578:	e8 07 e9 ff ff       	call   f0102e84 <envid2env>
f010457d:	83 c4 10             	add    $0x10,%esp
f0104580:	85 c0                	test   %eax,%eax
f0104582:	0f 88 0e 05 00 00    	js     f0104a96 <syscall+0x59f>
		return r;
	env_destroy(e);
f0104588:	83 ec 0c             	sub    $0xc,%esp
f010458b:	ff 75 f4             	pushl  -0xc(%ebp)
f010458e:	e8 25 ee ff ff       	call   f01033b8 <env_destroy>
f0104593:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104596:	b8 00 00 00 00       	mov    $0x0,%eax
f010459b:	e9 f6 04 00 00       	jmp    f0104a96 <syscall+0x59f>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01045a0:	e8 ab fe ff ff       	call   f0104450 <sched_yield>
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	struct Env* env = NULL;
f01045a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	assert(curenv);             // An environment should be running
f01045ac:	e8 3a 17 00 00       	call   f0105ceb <cpunum>
f01045b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b4:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01045bb:	75 16                	jne    f01045d3 <syscall+0xdc>
f01045bd:	68 b8 77 10 f0       	push   $0xf01077b8
f01045c2:	68 88 72 10 f0       	push   $0xf0107288
f01045c7:	6a 5e                	push   $0x5e
f01045c9:	68 0b 7a 10 f0       	push   $0xf0107a0b
f01045ce:	e8 6d ba ff ff       	call   f0100040 <_panic>
	int ret = env_alloc(&env, curenv->env_id);
f01045d3:	e8 13 17 00 00       	call   f0105ceb <cpunum>
f01045d8:	83 ec 08             	sub    $0x8,%esp
f01045db:	6b c0 74             	imul   $0x74,%eax,%eax
f01045de:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01045e4:	ff 70 48             	pushl  0x48(%eax)
f01045e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045ea:	50                   	push   %eax
f01045eb:	e8 9f e9 ff ff       	call   f0102f8f <env_alloc>
	if (ret) return ret;
f01045f0:	83 c4 10             	add    $0x10,%esp
f01045f3:	85 c0                	test   %eax,%eax
f01045f5:	0f 85 9b 04 00 00    	jne    f0104a96 <syscall+0x59f>

	env->env_status = ENV_NOT_RUNNABLE;
f01045fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045fe:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memcpy(&(env->env_tf), &(curenv->env_tf), 
f0104605:	e8 e1 16 00 00       	call   f0105ceb <cpunum>
f010460a:	83 ec 04             	sub    $0x4,%esp
f010460d:	6a 44                	push   $0x44
f010460f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104612:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104618:	ff 75 f4             	pushl  -0xc(%ebp)
f010461b:	e8 4e 11 00 00       	call   f010576e <memcpy>
			sizeof(struct Trapframe));
	env->env_tf.tf_regs.reg_eax = 0;     // Return 0 in the new environment
f0104620:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104623:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env->env_id;
f010462a:	8b 40 48             	mov    0x48(%eax),%eax
f010462d:	83 c4 10             	add    $0x10,%esp
f0104630:	e9 61 04 00 00       	jmp    f0104a96 <syscall+0x59f>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env* env;
	int ret = envid2env(envid, &env, 1);
f0104635:	83 ec 04             	sub    $0x4,%esp
f0104638:	6a 01                	push   $0x1
f010463a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010463d:	50                   	push   %eax
f010463e:	ff 75 0c             	pushl  0xc(%ebp)
f0104641:	e8 3e e8 ff ff       	call   f0102e84 <envid2env>
	if (ret) return ret;
f0104646:	83 c4 10             	add    $0x10,%esp
f0104649:	85 c0                	test   %eax,%eax
f010464b:	0f 85 45 04 00 00    	jne    f0104a96 <syscall+0x59f>

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104651:	8b 45 10             	mov    0x10(%ebp),%eax
f0104654:	83 e8 02             	sub    $0x2,%eax
f0104657:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010465c:	75 13                	jne    f0104671 <syscall+0x17a>
		return -E_INVAL;

	env->env_status = status;
f010465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104661:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104664:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104667:	b8 00 00 00 00       	mov    $0x0,%eax
f010466c:	e9 25 04 00 00       	jmp    f0104a96 <syscall+0x59f>
	struct Env* env;
	int ret = envid2env(envid, &env, 1);
	if (ret) return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104671:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f0104676:	e9 1b 04 00 00       	jmp    f0104a96 <syscall+0x59f>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env* env;
	int ret = envid2env(envid, &env, 1);
f010467b:	83 ec 04             	sub    $0x4,%esp
f010467e:	6a 01                	push   $0x1
f0104680:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104683:	50                   	push   %eax
f0104684:	ff 75 0c             	pushl  0xc(%ebp)
f0104687:	e8 f8 e7 ff ff       	call   f0102e84 <envid2env>
	if (ret) return ret;
f010468c:	83 c4 10             	add    $0x10,%esp
f010468f:	85 c0                	test   %eax,%eax
f0104691:	0f 85 ff 03 00 00    	jne    f0104a96 <syscall+0x59f>

	if ((uintptr_t)va > UTOP || (uintptr_t)va % PGSIZE)
f0104697:	81 7d 10 00 00 c0 ee 	cmpl   $0xeec00000,0x10(%ebp)
f010469e:	77 48                	ja     f01046e8 <syscall+0x1f1>
f01046a0:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01046a7:	75 49                	jne    f01046f2 <syscall+0x1fb>
		return -E_INVAL;

	if (!(perm & PTE_P)) return -E_INVAL;
	if (!(perm & PTE_U)) return -E_INVAL;
f01046a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01046ac:	83 e0 05             	and    $0x5,%eax
f01046af:	83 f8 05             	cmp    $0x5,%eax
f01046b2:	75 48                	jne    f01046fc <syscall+0x205>
	if (perm & ~PTE_P & ~PTE_U & ~PTE_AVAIL & ~PTE_W) return -E_INVAL;
f01046b4:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01046bb:	75 49                	jne    f0104706 <syscall+0x20f>

	struct PageInfo* pp = page_alloc(1);
f01046bd:	83 ec 0c             	sub    $0xc,%esp
f01046c0:	6a 01                	push   $0x1
f01046c2:	e8 cf c8 ff ff       	call   f0100f96 <page_alloc>
	if (!pp) return -E_NO_MEM;
f01046c7:	83 c4 10             	add    $0x10,%esp
f01046ca:	85 c0                	test   %eax,%eax
f01046cc:	74 42                	je     f0104710 <syscall+0x219>

	return page_insert(env->env_pgdir, pp, va, perm);
f01046ce:	ff 75 14             	pushl  0x14(%ebp)
f01046d1:	ff 75 10             	pushl  0x10(%ebp)
f01046d4:	50                   	push   %eax
f01046d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01046d8:	ff 70 60             	pushl  0x60(%eax)
f01046db:	e8 7f cb ff ff       	call   f010125f <page_insert>
f01046e0:	83 c4 10             	add    $0x10,%esp
f01046e3:	e9 ae 03 00 00       	jmp    f0104a96 <syscall+0x59f>
	struct Env* env;
	int ret = envid2env(envid, &env, 1);
	if (ret) return ret;

	if ((uintptr_t)va > UTOP || (uintptr_t)va % PGSIZE)
		return -E_INVAL;
f01046e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046ed:	e9 a4 03 00 00       	jmp    f0104a96 <syscall+0x59f>
f01046f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046f7:	e9 9a 03 00 00       	jmp    f0104a96 <syscall+0x59f>

	if (!(perm & PTE_P)) return -E_INVAL;
	if (!(perm & PTE_U)) return -E_INVAL;
f01046fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104701:	e9 90 03 00 00       	jmp    f0104a96 <syscall+0x59f>
	if (perm & ~PTE_P & ~PTE_U & ~PTE_AVAIL & ~PTE_W) return -E_INVAL;
f0104706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010470b:	e9 86 03 00 00       	jmp    f0104a96 <syscall+0x59f>

	struct PageInfo* pp = page_alloc(1);
	if (!pp) return -E_NO_MEM;
f0104710:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void*)a2, a3);
f0104715:	e9 7c 03 00 00       	jmp    f0104a96 <syscall+0x59f>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	struct Env* srcenv;
	struct Env* dstenv;
	int ret = envid2env(srcenvid, &srcenv, 1);
f010471a:	83 ec 04             	sub    $0x4,%esp
f010471d:	6a 01                	push   $0x1
f010471f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104722:	50                   	push   %eax
f0104723:	ff 75 0c             	pushl  0xc(%ebp)
f0104726:	e8 59 e7 ff ff       	call   f0102e84 <envid2env>
	if (ret) return ret;
f010472b:	83 c4 10             	add    $0x10,%esp
f010472e:	85 c0                	test   %eax,%eax
f0104730:	0f 85 60 03 00 00    	jne    f0104a96 <syscall+0x59f>
	ret = envid2env(dstenvid, &dstenv, 1);
f0104736:	83 ec 04             	sub    $0x4,%esp
f0104739:	6a 01                	push   $0x1
f010473b:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010473e:	50                   	push   %eax
f010473f:	ff 75 14             	pushl  0x14(%ebp)
f0104742:	e8 3d e7 ff ff       	call   f0102e84 <envid2env>
	if (ret) return ret;
f0104747:	83 c4 10             	add    $0x10,%esp
f010474a:	85 c0                	test   %eax,%eax
f010474c:	0f 85 44 03 00 00    	jne    f0104a96 <syscall+0x59f>

	if ((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE)
f0104752:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104759:	77 73                	ja     f01047ce <syscall+0x2d7>
		return -E_INVAL;
	if ((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE)
f010475b:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104762:	75 74                	jne    f01047d8 <syscall+0x2e1>
f0104764:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010476b:	77 6b                	ja     f01047d8 <syscall+0x2e1>
f010476d:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104774:	75 6c                	jne    f01047e2 <syscall+0x2eb>
		return -E_INVAL;

	if (!(perm & PTE_P)) return -E_INVAL;
	if (!(perm & PTE_U)) return -E_INVAL;
f0104776:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104779:	83 e0 05             	and    $0x5,%eax
f010477c:	83 f8 05             	cmp    $0x5,%eax
f010477f:	75 6b                	jne    f01047ec <syscall+0x2f5>
	if (perm & ~PTE_P & ~PTE_U & ~PTE_AVAIL & ~PTE_W) return -E_INVAL;
f0104781:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104788:	75 6c                	jne    f01047f6 <syscall+0x2ff>

	struct PageInfo* pp;
	pte_t* pte;
	pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f010478a:	83 ec 04             	sub    $0x4,%esp
f010478d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104790:	50                   	push   %eax
f0104791:	ff 75 10             	pushl  0x10(%ebp)
f0104794:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104797:	ff 70 60             	pushl  0x60(%eax)
f010479a:	e8 d0 c9 ff ff       	call   f010116f <page_lookup>
	if (!pp) return -E_INVAL;
f010479f:	83 c4 10             	add    $0x10,%esp
f01047a2:	85 c0                	test   %eax,%eax
f01047a4:	74 5a                	je     f0104800 <syscall+0x309>
	if (!(*pte & PTE_W) && perm & PTE_W) return -E_INVAL;
f01047a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01047a9:	f6 02 02             	testb  $0x2,(%edx)
f01047ac:	75 06                	jne    f01047b4 <syscall+0x2bd>
f01047ae:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01047b2:	75 56                	jne    f010480a <syscall+0x313>

	ret = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f01047b4:	ff 75 1c             	pushl  0x1c(%ebp)
f01047b7:	ff 75 18             	pushl  0x18(%ebp)
f01047ba:	50                   	push   %eax
f01047bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047be:	ff 70 60             	pushl  0x60(%eax)
f01047c1:	e8 99 ca ff ff       	call   f010125f <page_insert>
f01047c6:	83 c4 10             	add    $0x10,%esp
f01047c9:	e9 c8 02 00 00       	jmp    f0104a96 <syscall+0x59f>
	if (ret) return ret;
	ret = envid2env(dstenvid, &dstenv, 1);
	if (ret) return ret;

	if ((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE)
		return -E_INVAL;
f01047ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047d3:	e9 be 02 00 00       	jmp    f0104a96 <syscall+0x59f>
	if ((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE)
		return -E_INVAL;
f01047d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047dd:	e9 b4 02 00 00       	jmp    f0104a96 <syscall+0x59f>
f01047e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047e7:	e9 aa 02 00 00       	jmp    f0104a96 <syscall+0x59f>

	if (!(perm & PTE_P)) return -E_INVAL;
	if (!(perm & PTE_U)) return -E_INVAL;
f01047ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047f1:	e9 a0 02 00 00       	jmp    f0104a96 <syscall+0x59f>
	if (perm & ~PTE_P & ~PTE_U & ~PTE_AVAIL & ~PTE_W) return -E_INVAL;
f01047f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047fb:	e9 96 02 00 00       	jmp    f0104a96 <syscall+0x59f>

	struct PageInfo* pp;
	pte_t* pte;
	pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (!pp) return -E_INVAL;
f0104800:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104805:	e9 8c 02 00 00       	jmp    f0104a96 <syscall+0x59f>
	if (!(*pte & PTE_W) && perm & PTE_W) return -E_INVAL;
f010480a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void*)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f010480f:	e9 82 02 00 00       	jmp    f0104a96 <syscall+0x59f>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* env;
	int ret = envid2env(envid, &env, 1);
f0104814:	83 ec 04             	sub    $0x4,%esp
f0104817:	6a 01                	push   $0x1
f0104819:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010481c:	50                   	push   %eax
f010481d:	ff 75 0c             	pushl  0xc(%ebp)
f0104820:	e8 5f e6 ff ff       	call   f0102e84 <envid2env>
	if (ret) return ret;
f0104825:	83 c4 10             	add    $0x10,%esp
f0104828:	85 c0                	test   %eax,%eax
f010482a:	0f 85 66 02 00 00    	jne    f0104a96 <syscall+0x59f>

	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
f0104830:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104837:	77 27                	ja     f0104860 <syscall+0x369>
f0104839:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104840:	75 28                	jne    f010486a <syscall+0x373>
		return -E_INVAL;

	page_remove(env->env_pgdir, va);
f0104842:	83 ec 08             	sub    $0x8,%esp
f0104845:	ff 75 10             	pushl  0x10(%ebp)
f0104848:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010484b:	ff 70 60             	pushl  0x60(%eax)
f010484e:	e8 b8 c9 ff ff       	call   f010120b <page_remove>
f0104853:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104856:	b8 00 00 00 00       	mov    $0x0,%eax
f010485b:	e9 36 02 00 00       	jmp    f0104a96 <syscall+0x59f>
	struct Env* env;
	int ret = envid2env(envid, &env, 1);
	if (ret) return ret;

	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
		return -E_INVAL;
f0104860:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104865:	e9 2c 02 00 00       	jmp    f0104a96 <syscall+0x59f>
f010486a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void*)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void*)a2);
f010486f:	e9 22 02 00 00       	jmp    f0104a96 <syscall+0x59f>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env* env;
	int ret = envid2env(envid, &env, 1);
f0104874:	83 ec 04             	sub    $0x4,%esp
f0104877:	6a 01                	push   $0x1
f0104879:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010487c:	50                   	push   %eax
f010487d:	ff 75 0c             	pushl  0xc(%ebp)
f0104880:	e8 ff e5 ff ff       	call   f0102e84 <envid2env>
	if (ret) return ret;
f0104885:	83 c4 10             	add    $0x10,%esp
f0104888:	85 c0                	test   %eax,%eax
f010488a:	0f 85 06 02 00 00    	jne    f0104a96 <syscall+0x59f>

	env->env_pgfault_upcall = func;
f0104890:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104893:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104896:	89 4a 64             	mov    %ecx,0x64(%edx)
	case SYS_page_map:
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void*)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104899:	e9 f8 01 00 00       	jmp    f0104a96 <syscall+0x59f>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	int ret;
	struct Env* env;
	if ((ret = envid2env(envid, &env, 0)) < 0)
f010489e:	83 ec 04             	sub    $0x4,%esp
f01048a1:	6a 00                	push   $0x0
f01048a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01048a6:	50                   	push   %eax
f01048a7:	ff 75 0c             	pushl  0xc(%ebp)
f01048aa:	e8 d5 e5 ff ff       	call   f0102e84 <envid2env>
f01048af:	83 c4 10             	add    $0x10,%esp
f01048b2:	85 c0                	test   %eax,%eax
f01048b4:	0f 88 dc 01 00 00    	js     f0104a96 <syscall+0x59f>
		return ret;

	if (!(env->env_ipc_recving))
f01048ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01048bd:	80 7b 68 00          	cmpb   $0x0,0x68(%ebx)
f01048c1:	0f 84 d7 00 00 00    	je     f010499e <syscall+0x4a7>
		return -E_IPC_NOT_RECV;

	if ((uintptr_t)srcva < UTOP){
f01048c7:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01048ce:	0f 87 9c 01 00 00    	ja     f0104a70 <syscall+0x579>
		if ((uintptr_t)srcva % PGSIZE)
f01048d4:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01048db:	0f 85 c7 00 00 00    	jne    f01049a8 <syscall+0x4b1>
			return -E_INVAL;
		if (!(perm & PTE_P))
			return -E_INVAL;
		if (!(perm & PTE_U))
f01048e1:	8b 45 18             	mov    0x18(%ebp),%eax
f01048e4:	83 e0 05             	and    $0x5,%eax
f01048e7:	83 f8 05             	cmp    $0x5,%eax
f01048ea:	0f 85 c2 00 00 00    	jne    f01049b2 <syscall+0x4bb>
			return -E_INVAL;
		if (perm & ~PTE_P & ~PTE_U & PTE_W & PTE_AVAIL)
			return -E_INVAL;
		pte_t* pte = pgdir_walk(curenv->env_pgdir, srcva, 0);
f01048f0:	e8 f6 13 00 00       	call   f0105ceb <cpunum>
f01048f5:	83 ec 04             	sub    $0x4,%esp
f01048f8:	6a 00                	push   $0x0
f01048fa:	ff 75 14             	pushl  0x14(%ebp)
f01048fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104900:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104906:	ff 70 60             	pushl  0x60(%eax)
f0104909:	e8 61 c7 ff ff       	call   f010106f <pgdir_walk>
		if (!pte)
f010490e:	83 c4 10             	add    $0x10,%esp
f0104911:	85 c0                	test   %eax,%eax
f0104913:	0f 84 a3 00 00 00    	je     f01049bc <syscall+0x4c5>
			return -E_INVAL;
		if (!(*pte & PTE_P))
f0104919:	8b 00                	mov    (%eax),%eax
f010491b:	a8 01                	test   $0x1,%al
f010491d:	0f 84 a3 00 00 00    	je     f01049c6 <syscall+0x4cf>
			return -E_INVAL;
		if (!(*pte & PTE_W) && (perm & PTE_W))
f0104923:	a8 02                	test   $0x2,%al
f0104925:	0f 85 0f 01 00 00    	jne    f0104a3a <syscall+0x543>
f010492b:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010492f:	0f 84 05 01 00 00    	je     f0104a3a <syscall+0x543>
f0104935:	e9 96 00 00 00       	jmp    f01049d0 <syscall+0x4d9>
	env->env_ipc_recving = false;
	env->env_ipc_from = curenv->env_id;
	env->env_ipc_value = value;
	if ((uintptr_t)srcva < UTOP && (uintptr_t)(env->env_ipc_dstva) < UTOP){
		// Has page to send and the receiver is asking for a page
		env->env_ipc_perm = perm;
f010493a:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010493d:	89 58 78             	mov    %ebx,0x78(%eax)
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, NULL);
f0104940:	e8 a6 13 00 00       	call   f0105ceb <cpunum>
f0104945:	83 ec 04             	sub    $0x4,%esp
f0104948:	6a 00                	push   $0x0
f010494a:	ff 75 14             	pushl  0x14(%ebp)
f010494d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104950:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104956:	ff 70 60             	pushl  0x60(%eax)
f0104959:	e8 11 c8 ff ff       	call   f010116f <page_lookup>
		if ((ret = page_insert(env->env_pgdir, pp, 
						env->env_ipc_dstva, perm)) < 0)
f010495e:	8b 55 f4             	mov    -0xc(%ebp),%edx
	env->env_ipc_value = value;
	if ((uintptr_t)srcva < UTOP && (uintptr_t)(env->env_ipc_dstva) < UTOP){
		// Has page to send and the receiver is asking for a page
		env->env_ipc_perm = perm;
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, NULL);
		if ((ret = page_insert(env->env_pgdir, pp, 
f0104961:	ff 75 18             	pushl  0x18(%ebp)
f0104964:	ff 72 6c             	pushl  0x6c(%edx)
f0104967:	50                   	push   %eax
f0104968:	ff 72 60             	pushl  0x60(%edx)
f010496b:	e8 ef c8 ff ff       	call   f010125f <page_insert>
f0104970:	83 c4 20             	add    $0x20,%esp
f0104973:	85 c0                	test   %eax,%eax
f0104975:	79 0c                	jns    f0104983 <syscall+0x48c>
f0104977:	e9 1a 01 00 00       	jmp    f0104a96 <syscall+0x59f>
						env->env_ipc_dstva, perm)) < 0)
			return ret;
	} 
	else {
		env->env_ipc_perm = 0;
f010497c:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}

	env->env_tf.tf_regs.reg_eax = 0;
f0104983:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104986:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	env->env_status = ENV_RUNNABLE;
f010498d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	return 0;
f0104994:	b8 00 00 00 00       	mov    $0x0,%eax
f0104999:	e9 f8 00 00 00       	jmp    f0104a96 <syscall+0x59f>
	struct Env* env;
	if ((ret = envid2env(envid, &env, 0)) < 0)
		return ret;

	if (!(env->env_ipc_recving))
		return -E_IPC_NOT_RECV;
f010499e:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01049a3:	e9 ee 00 00 00       	jmp    f0104a96 <syscall+0x59f>

	if ((uintptr_t)srcva < UTOP){
		if ((uintptr_t)srcva % PGSIZE)
			return -E_INVAL;
f01049a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049ad:	e9 e4 00 00 00       	jmp    f0104a96 <syscall+0x59f>
		if (!(perm & PTE_P))
			return -E_INVAL;
		if (!(perm & PTE_U))
			return -E_INVAL;
f01049b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049b7:	e9 da 00 00 00       	jmp    f0104a96 <syscall+0x59f>
		if (perm & ~PTE_P & ~PTE_U & PTE_W & PTE_AVAIL)
			return -E_INVAL;
		pte_t* pte = pgdir_walk(curenv->env_pgdir, srcva, 0);
		if (!pte)
			return -E_INVAL;
f01049bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049c1:	e9 d0 00 00 00       	jmp    f0104a96 <syscall+0x59f>
		if (!(*pte & PTE_P))
			return -E_INVAL;
f01049c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049cb:	e9 c6 00 00 00       	jmp    f0104a96 <syscall+0x59f>
		if (!(*pte & PTE_W) && (perm & PTE_W))
			return -E_INVAL;
f01049d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049d5:	e9 bc 00 00 00       	jmp    f0104a96 <syscall+0x59f>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE)
f01049da:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01049e1:	77 09                	ja     f01049ec <syscall+0x4f5>
f01049e3:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01049ea:	75 47                	jne    f0104a33 <syscall+0x53c>
		return -E_INVAL;
	curenv->env_ipc_recving = true;
f01049ec:	e8 fa 12 00 00       	call   f0105ceb <cpunum>
f01049f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f4:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01049fa:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f01049fe:	e8 e8 12 00 00       	call   f0105ceb <cpunum>
f0104a03:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a06:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a0f:	89 58 6c             	mov    %ebx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a12:	e8 d4 12 00 00       	call   f0105ceb <cpunum>
f0104a17:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1a:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104a20:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104a27:	e8 24 fa ff ff       	call   f0104450 <sched_yield>
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void*)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void*)a1);
	default:
		return -E_INVAL;
f0104a2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a31:	eb 63                	jmp    f0104a96 <syscall+0x59f>
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void*)a2);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void*)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void*)a1);
f0104a33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a38:	eb 5c                	jmp    f0104a96 <syscall+0x59f>
		if (!(*pte & PTE_W) && (perm & PTE_W))
			return -E_INVAL;
	}

	// The send succeeds
	env->env_ipc_recving = false;
f0104a3a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104a3d:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env->env_ipc_from = curenv->env_id;
f0104a41:	e8 a5 12 00 00       	call   f0105ceb <cpunum>
f0104a46:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a49:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104a4f:	8b 40 48             	mov    0x48(%eax),%eax
f0104a52:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f0104a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a58:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a5b:	89 48 70             	mov    %ecx,0x70(%eax)
	if ((uintptr_t)srcva < UTOP && (uintptr_t)(env->env_ipc_dstva) < UTOP){
f0104a5e:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0104a65:	0f 87 11 ff ff ff    	ja     f010497c <syscall+0x485>
f0104a6b:	e9 ca fe ff ff       	jmp    f010493a <syscall+0x443>
		if (!(*pte & PTE_W) && (perm & PTE_W))
			return -E_INVAL;
	}

	// The send succeeds
	env->env_ipc_recving = false;
f0104a70:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env->env_ipc_from = curenv->env_id;
f0104a74:	e8 72 12 00 00       	call   f0105ceb <cpunum>
f0104a79:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a7c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104a82:	8b 40 48             	mov    0x48(%eax),%eax
f0104a85:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f0104a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a8e:	89 48 70             	mov    %ecx,0x70(%eax)
f0104a91:	e9 e6 fe ff ff       	jmp    f010497c <syscall+0x485>
	case SYS_ipc_recv:
		return sys_ipc_recv((void*)a1);
	default:
		return -E_INVAL;
	}
}
f0104a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104a99:	c9                   	leave  
f0104a9a:	c3                   	ret    

f0104a9b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104a9b:	55                   	push   %ebp
f0104a9c:	89 e5                	mov    %esp,%ebp
f0104a9e:	57                   	push   %edi
f0104a9f:	56                   	push   %esi
f0104aa0:	53                   	push   %ebx
f0104aa1:	83 ec 14             	sub    $0x14,%esp
f0104aa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104aa7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104aaa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104aad:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ab0:	8b 1a                	mov    (%edx),%ebx
f0104ab2:	8b 01                	mov    (%ecx),%eax
f0104ab4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ab7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104abe:	eb 7f                	jmp    f0104b3f <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ac3:	01 d8                	add    %ebx,%eax
f0104ac5:	89 c6                	mov    %eax,%esi
f0104ac7:	c1 ee 1f             	shr    $0x1f,%esi
f0104aca:	01 c6                	add    %eax,%esi
f0104acc:	d1 fe                	sar    %esi
f0104ace:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104ad1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ad4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104ad7:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ad9:	eb 03                	jmp    f0104ade <stab_binsearch+0x43>
			m--;
f0104adb:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ade:	39 c3                	cmp    %eax,%ebx
f0104ae0:	7f 0d                	jg     f0104aef <stab_binsearch+0x54>
f0104ae2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ae6:	83 ea 0c             	sub    $0xc,%edx
f0104ae9:	39 f9                	cmp    %edi,%ecx
f0104aeb:	75 ee                	jne    f0104adb <stab_binsearch+0x40>
f0104aed:	eb 05                	jmp    f0104af4 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104aef:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104af2:	eb 4b                	jmp    f0104b3f <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104af4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104af7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104afa:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104afe:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b01:	76 11                	jbe    f0104b14 <stab_binsearch+0x79>
			*region_left = m;
f0104b03:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104b06:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104b08:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b0b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b12:	eb 2b                	jmp    f0104b3f <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104b14:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b17:	73 14                	jae    f0104b2d <stab_binsearch+0x92>
			*region_right = m - 1;
f0104b19:	83 e8 01             	sub    $0x1,%eax
f0104b1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b22:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b24:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b2b:	eb 12                	jmp    f0104b3f <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104b2d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b30:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104b32:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b36:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b38:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104b3f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104b42:	0f 8e 78 ff ff ff    	jle    f0104ac0 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104b48:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b4c:	75 0f                	jne    f0104b5d <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104b4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b51:	8b 00                	mov    (%eax),%eax
f0104b53:	83 e8 01             	sub    $0x1,%eax
f0104b56:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b59:	89 06                	mov    %eax,(%esi)
f0104b5b:	eb 2c                	jmp    f0104b89 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b60:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b62:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b65:	8b 0e                	mov    (%esi),%ecx
f0104b67:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b6a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b6d:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b70:	eb 03                	jmp    f0104b75 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104b72:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b75:	39 c8                	cmp    %ecx,%eax
f0104b77:	7e 0b                	jle    f0104b84 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104b79:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b7d:	83 ea 0c             	sub    $0xc,%edx
f0104b80:	39 df                	cmp    %ebx,%edi
f0104b82:	75 ee                	jne    f0104b72 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104b84:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b87:	89 06                	mov    %eax,(%esi)
	}
}
f0104b89:	83 c4 14             	add    $0x14,%esp
f0104b8c:	5b                   	pop    %ebx
f0104b8d:	5e                   	pop    %esi
f0104b8e:	5f                   	pop    %edi
f0104b8f:	5d                   	pop    %ebp
f0104b90:	c3                   	ret    

f0104b91 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b91:	55                   	push   %ebp
f0104b92:	89 e5                	mov    %esp,%ebp
f0104b94:	57                   	push   %edi
f0104b95:	56                   	push   %esi
f0104b96:	53                   	push   %ebx
f0104b97:	83 ec 3c             	sub    $0x3c,%esp
f0104b9a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ba0:	c7 03 54 7a 10 f0    	movl   $0xf0107a54,(%ebx)
	info->eip_line = 0;
f0104ba6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104bad:	c7 43 08 54 7a 10 f0 	movl   $0xf0107a54,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104bb4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104bbb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104bbe:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104bc5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104bcb:	0f 87 9a 00 00 00    	ja     f0104c6b <debuginfo_eip+0xda>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if ((user_mem_check(curenv, usd, sizeof(struct UserStabData), 
f0104bd1:	e8 15 11 00 00       	call   f0105ceb <cpunum>
f0104bd6:	6a 05                	push   $0x5
f0104bd8:	6a 10                	push   $0x10
f0104bda:	68 00 00 20 00       	push   $0x200000
f0104bdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be2:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104be8:	e8 36 e1 ff ff       	call   f0102d23 <user_mem_check>
f0104bed:	83 c4 10             	add    $0x10,%esp
f0104bf0:	85 c0                	test   %eax,%eax
f0104bf2:	0f 88 35 02 00 00    	js     f0104e2d <debuginfo_eip+0x29c>
						PTE_P | PTE_U)) < 0)
			return -1;

		stabs = usd->stabs;
f0104bf8:	a1 00 00 20 00       	mov    0x200000,%eax
f0104bfd:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104c00:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104c06:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104c0c:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104c0f:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104c14:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ((user_mem_check(curenv, stabs, (stab_end - stabs) * sizeof(struct Stab), 
f0104c17:	e8 cf 10 00 00       	call   f0105ceb <cpunum>
f0104c1c:	6a 05                	push   $0x5
f0104c1e:	89 fa                	mov    %edi,%edx
f0104c20:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104c23:	29 ca                	sub    %ecx,%edx
f0104c25:	52                   	push   %edx
f0104c26:	51                   	push   %ecx
f0104c27:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2a:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104c30:	e8 ee e0 ff ff       	call   f0102d23 <user_mem_check>
f0104c35:	83 c4 10             	add    $0x10,%esp
f0104c38:	85 c0                	test   %eax,%eax
f0104c3a:	0f 88 f4 01 00 00    	js     f0104e34 <debuginfo_eip+0x2a3>
						PTE_P | PTE_U)) < 0)
			return -1;
		if ((user_mem_check(curenv, stabstr, stabstr_end - stabstr, 
f0104c40:	e8 a6 10 00 00       	call   f0105ceb <cpunum>
f0104c45:	6a 05                	push   $0x5
f0104c47:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104c4a:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104c4d:	29 ca                	sub    %ecx,%edx
f0104c4f:	52                   	push   %edx
f0104c50:	51                   	push   %ecx
f0104c51:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c54:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104c5a:	e8 c4 e0 ff ff       	call   f0102d23 <user_mem_check>
f0104c5f:	83 c4 10             	add    $0x10,%esp
f0104c62:	85 c0                	test   %eax,%eax
f0104c64:	79 1f                	jns    f0104c85 <debuginfo_eip+0xf4>
f0104c66:	e9 d0 01 00 00       	jmp    f0104e3b <debuginfo_eip+0x2aa>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104c6b:	c7 45 bc 30 5a 11 f0 	movl   $0xf0115a30,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104c72:	c7 45 b8 1d 23 11 f0 	movl   $0xf011231d,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104c79:	bf 1c 23 11 f0       	mov    $0xf011231c,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104c7e:	c7 45 c0 08 80 10 f0 	movl   $0xf0108008,-0x40(%ebp)
						PTE_P | PTE_U)) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c85:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104c88:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104c8b:	0f 83 b1 01 00 00    	jae    f0104e42 <debuginfo_eip+0x2b1>
f0104c91:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104c95:	0f 85 ae 01 00 00    	jne    f0104e49 <debuginfo_eip+0x2b8>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c9b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104ca2:	2b 7d c0             	sub    -0x40(%ebp),%edi
f0104ca5:	c1 ff 02             	sar    $0x2,%edi
f0104ca8:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0104cae:	83 e8 01             	sub    $0x1,%eax
f0104cb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104cb4:	83 ec 08             	sub    $0x8,%esp
f0104cb7:	56                   	push   %esi
f0104cb8:	6a 64                	push   $0x64
f0104cba:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104cbd:	89 d1                	mov    %edx,%ecx
f0104cbf:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104cc2:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104cc5:	89 f8                	mov    %edi,%eax
f0104cc7:	e8 cf fd ff ff       	call   f0104a9b <stab_binsearch>
	if (lfile == 0)
f0104ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ccf:	83 c4 10             	add    $0x10,%esp
f0104cd2:	85 c0                	test   %eax,%eax
f0104cd4:	0f 84 76 01 00 00    	je     f0104e50 <debuginfo_eip+0x2bf>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104cda:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ce0:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104ce3:	83 ec 08             	sub    $0x8,%esp
f0104ce6:	56                   	push   %esi
f0104ce7:	6a 24                	push   $0x24
f0104ce9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104cec:	89 d1                	mov    %edx,%ecx
f0104cee:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104cf1:	89 f8                	mov    %edi,%eax
f0104cf3:	e8 a3 fd ff ff       	call   f0104a9b <stab_binsearch>

	if (lfun <= rfun) {
f0104cf8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104cfb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cfe:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104d01:	83 c4 10             	add    $0x10,%esp
f0104d04:	39 d0                	cmp    %edx,%eax
f0104d06:	7f 2b                	jg     f0104d33 <debuginfo_eip+0x1a2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104d08:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d0b:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104d0e:	8b 11                	mov    (%ecx),%edx
f0104d10:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104d13:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0104d16:	39 fa                	cmp    %edi,%edx
f0104d18:	73 06                	jae    f0104d20 <debuginfo_eip+0x18f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104d1a:	03 55 b8             	add    -0x48(%ebp),%edx
f0104d1d:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104d20:	8b 51 08             	mov    0x8(%ecx),%edx
f0104d23:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104d26:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104d28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104d2b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104d2e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104d31:	eb 0f                	jmp    f0104d42 <debuginfo_eip+0x1b1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104d33:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104d36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104d3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d3f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104d42:	83 ec 08             	sub    $0x8,%esp
f0104d45:	6a 3a                	push   $0x3a
f0104d47:	ff 73 08             	pushl  0x8(%ebx)
f0104d4a:	e8 4e 09 00 00       	call   f010569d <strfind>
f0104d4f:	2b 43 08             	sub    0x8(%ebx),%eax
f0104d52:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104d55:	83 c4 08             	add    $0x8,%esp
f0104d58:	56                   	push   %esi
f0104d59:	6a 44                	push   $0x44
f0104d5b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104d5e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104d61:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d64:	89 f8                	mov    %edi,%eax
f0104d66:	e8 30 fd ff ff       	call   f0104a9b <stab_binsearch>
	if (lline != rline) return -1;
f0104d6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104d6e:	83 c4 10             	add    $0x10,%esp
f0104d71:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104d74:	0f 85 dd 00 00 00    	jne    f0104e57 <debuginfo_eip+0x2c6>
	info->eip_line = stabs[lline].n_desc;
f0104d7a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d7d:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104d80:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104d84:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d8a:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104d8e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d91:	eb 0a                	jmp    f0104d9d <debuginfo_eip+0x20c>
f0104d93:	83 e8 01             	sub    $0x1,%eax
f0104d96:	83 ea 0c             	sub    $0xc,%edx
f0104d99:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104d9d:	39 c7                	cmp    %eax,%edi
f0104d9f:	7e 05                	jle    f0104da6 <debuginfo_eip+0x215>
f0104da1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104da4:	eb 47                	jmp    f0104ded <debuginfo_eip+0x25c>
	       && stabs[lline].n_type != N_SOL
f0104da6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104daa:	80 f9 84             	cmp    $0x84,%cl
f0104dad:	75 0e                	jne    f0104dbd <debuginfo_eip+0x22c>
f0104daf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104db2:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104db6:	74 1c                	je     f0104dd4 <debuginfo_eip+0x243>
f0104db8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104dbb:	eb 17                	jmp    f0104dd4 <debuginfo_eip+0x243>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104dbd:	80 f9 64             	cmp    $0x64,%cl
f0104dc0:	75 d1                	jne    f0104d93 <debuginfo_eip+0x202>
f0104dc2:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104dc6:	74 cb                	je     f0104d93 <debuginfo_eip+0x202>
f0104dc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104dcb:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104dcf:	74 03                	je     f0104dd4 <debuginfo_eip+0x243>
f0104dd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104dd4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104dd7:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104dda:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104ddd:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104de0:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104de3:	29 f0                	sub    %esi,%eax
f0104de5:	39 c2                	cmp    %eax,%edx
f0104de7:	73 04                	jae    f0104ded <debuginfo_eip+0x25c>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104de9:	01 f2                	add    %esi,%edx
f0104deb:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ded:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104df0:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104df3:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104df8:	39 f2                	cmp    %esi,%edx
f0104dfa:	7d 67                	jge    f0104e63 <debuginfo_eip+0x2d2>
		for (lline = lfun + 1;
f0104dfc:	83 c2 01             	add    $0x1,%edx
f0104dff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104e02:	89 d0                	mov    %edx,%eax
f0104e04:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104e07:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104e0a:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104e0d:	eb 04                	jmp    f0104e13 <debuginfo_eip+0x282>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104e0f:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104e13:	39 c6                	cmp    %eax,%esi
f0104e15:	7e 47                	jle    f0104e5e <debuginfo_eip+0x2cd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104e17:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104e1b:	83 c0 01             	add    $0x1,%eax
f0104e1e:	83 c2 0c             	add    $0xc,%edx
f0104e21:	80 f9 a0             	cmp    $0xa0,%cl
f0104e24:	74 e9                	je     f0104e0f <debuginfo_eip+0x27e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e26:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e2b:	eb 36                	jmp    f0104e63 <debuginfo_eip+0x2d2>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if ((user_mem_check(curenv, usd, sizeof(struct UserStabData), 
						PTE_P | PTE_U)) < 0)
			return -1;
f0104e2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e32:	eb 2f                	jmp    f0104e63 <debuginfo_eip+0x2d2>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ((user_mem_check(curenv, stabs, (stab_end - stabs) * sizeof(struct Stab), 
						PTE_P | PTE_U)) < 0)
			return -1;
f0104e34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e39:	eb 28                	jmp    f0104e63 <debuginfo_eip+0x2d2>
		if ((user_mem_check(curenv, stabstr, stabstr_end - stabstr, 
						PTE_P | PTE_U)) < 0)
			return -1;
f0104e3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e40:	eb 21                	jmp    f0104e63 <debuginfo_eip+0x2d2>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e47:	eb 1a                	jmp    f0104e63 <debuginfo_eip+0x2d2>
f0104e49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e4e:	eb 13                	jmp    f0104e63 <debuginfo_eip+0x2d2>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104e50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e55:	eb 0c                	jmp    f0104e63 <debuginfo_eip+0x2d2>
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline != rline) return -1;
f0104e57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e5c:	eb 05                	jmp    f0104e63 <debuginfo_eip+0x2d2>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e66:	5b                   	pop    %ebx
f0104e67:	5e                   	pop    %esi
f0104e68:	5f                   	pop    %edi
f0104e69:	5d                   	pop    %ebp
f0104e6a:	c3                   	ret    

f0104e6b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e6b:	55                   	push   %ebp
f0104e6c:	89 e5                	mov    %esp,%ebp
f0104e6e:	57                   	push   %edi
f0104e6f:	56                   	push   %esi
f0104e70:	53                   	push   %ebx
f0104e71:	83 ec 1c             	sub    $0x1c,%esp
f0104e74:	89 c7                	mov    %eax,%edi
f0104e76:	89 d6                	mov    %edx,%esi
f0104e78:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e7b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e81:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e84:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e87:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e8c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e8f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e92:	39 d3                	cmp    %edx,%ebx
f0104e94:	72 05                	jb     f0104e9b <printnum+0x30>
f0104e96:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e99:	77 45                	ja     f0104ee0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e9b:	83 ec 0c             	sub    $0xc,%esp
f0104e9e:	ff 75 18             	pushl  0x18(%ebp)
f0104ea1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ea4:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104ea7:	53                   	push   %ebx
f0104ea8:	ff 75 10             	pushl  0x10(%ebp)
f0104eab:	83 ec 08             	sub    $0x8,%esp
f0104eae:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104eb1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104eb4:	ff 75 dc             	pushl  -0x24(%ebp)
f0104eb7:	ff 75 d8             	pushl  -0x28(%ebp)
f0104eba:	e8 31 12 00 00       	call   f01060f0 <__udivdi3>
f0104ebf:	83 c4 18             	add    $0x18,%esp
f0104ec2:	52                   	push   %edx
f0104ec3:	50                   	push   %eax
f0104ec4:	89 f2                	mov    %esi,%edx
f0104ec6:	89 f8                	mov    %edi,%eax
f0104ec8:	e8 9e ff ff ff       	call   f0104e6b <printnum>
f0104ecd:	83 c4 20             	add    $0x20,%esp
f0104ed0:	eb 18                	jmp    f0104eea <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104ed2:	83 ec 08             	sub    $0x8,%esp
f0104ed5:	56                   	push   %esi
f0104ed6:	ff 75 18             	pushl  0x18(%ebp)
f0104ed9:	ff d7                	call   *%edi
f0104edb:	83 c4 10             	add    $0x10,%esp
f0104ede:	eb 03                	jmp    f0104ee3 <printnum+0x78>
f0104ee0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104ee3:	83 eb 01             	sub    $0x1,%ebx
f0104ee6:	85 db                	test   %ebx,%ebx
f0104ee8:	7f e8                	jg     f0104ed2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104eea:	83 ec 08             	sub    $0x8,%esp
f0104eed:	56                   	push   %esi
f0104eee:	83 ec 04             	sub    $0x4,%esp
f0104ef1:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ef4:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ef7:	ff 75 dc             	pushl  -0x24(%ebp)
f0104efa:	ff 75 d8             	pushl  -0x28(%ebp)
f0104efd:	e8 1e 13 00 00       	call   f0106220 <__umoddi3>
f0104f02:	83 c4 14             	add    $0x14,%esp
f0104f05:	0f be 80 5e 7a 10 f0 	movsbl -0xfef85a2(%eax),%eax
f0104f0c:	50                   	push   %eax
f0104f0d:	ff d7                	call   *%edi
}
f0104f0f:	83 c4 10             	add    $0x10,%esp
f0104f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f15:	5b                   	pop    %ebx
f0104f16:	5e                   	pop    %esi
f0104f17:	5f                   	pop    %edi
f0104f18:	5d                   	pop    %ebp
f0104f19:	c3                   	ret    

f0104f1a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f1a:	55                   	push   %ebp
f0104f1b:	89 e5                	mov    %esp,%ebp
f0104f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f20:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f24:	8b 10                	mov    (%eax),%edx
f0104f26:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f29:	73 0a                	jae    f0104f35 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104f2b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f2e:	89 08                	mov    %ecx,(%eax)
f0104f30:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f33:	88 02                	mov    %al,(%edx)
}
f0104f35:	5d                   	pop    %ebp
f0104f36:	c3                   	ret    

f0104f37 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104f37:	55                   	push   %ebp
f0104f38:	89 e5                	mov    %esp,%ebp
f0104f3a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104f3d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f40:	50                   	push   %eax
f0104f41:	ff 75 10             	pushl  0x10(%ebp)
f0104f44:	ff 75 0c             	pushl  0xc(%ebp)
f0104f47:	ff 75 08             	pushl  0x8(%ebp)
f0104f4a:	e8 05 00 00 00       	call   f0104f54 <vprintfmt>
	va_end(ap);
}
f0104f4f:	83 c4 10             	add    $0x10,%esp
f0104f52:	c9                   	leave  
f0104f53:	c3                   	ret    

f0104f54 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104f54:	55                   	push   %ebp
f0104f55:	89 e5                	mov    %esp,%ebp
f0104f57:	57                   	push   %edi
f0104f58:	56                   	push   %esi
f0104f59:	53                   	push   %ebx
f0104f5a:	83 ec 2c             	sub    $0x2c,%esp
f0104f5d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f63:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f66:	eb 12                	jmp    f0104f7a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f68:	85 c0                	test   %eax,%eax
f0104f6a:	0f 84 6a 04 00 00    	je     f01053da <vprintfmt+0x486>
				return;
			putch(ch, putdat);
f0104f70:	83 ec 08             	sub    $0x8,%esp
f0104f73:	53                   	push   %ebx
f0104f74:	50                   	push   %eax
f0104f75:	ff d6                	call   *%esi
f0104f77:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f7a:	83 c7 01             	add    $0x1,%edi
f0104f7d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f81:	83 f8 25             	cmp    $0x25,%eax
f0104f84:	75 e2                	jne    f0104f68 <vprintfmt+0x14>
f0104f86:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104f8a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104f91:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f98:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104f9f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104fa4:	eb 07                	jmp    f0104fad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104fa9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fad:	8d 47 01             	lea    0x1(%edi),%eax
f0104fb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fb3:	0f b6 07             	movzbl (%edi),%eax
f0104fb6:	0f b6 d0             	movzbl %al,%edx
f0104fb9:	83 e8 23             	sub    $0x23,%eax
f0104fbc:	3c 55                	cmp    $0x55,%al
f0104fbe:	0f 87 fb 03 00 00    	ja     f01053bf <vprintfmt+0x46b>
f0104fc4:	0f b6 c0             	movzbl %al,%eax
f0104fc7:	ff 24 85 a0 7b 10 f0 	jmp    *-0xfef8460(,%eax,4)
f0104fce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104fd1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104fd5:	eb d6                	jmp    f0104fad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fda:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fdf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104fe2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104fe5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104fe9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104fec:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104fef:	83 f9 09             	cmp    $0x9,%ecx
f0104ff2:	77 3f                	ja     f0105033 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104ff4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104ff7:	eb e9                	jmp    f0104fe2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104ff9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ffc:	8b 00                	mov    (%eax),%eax
f0104ffe:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105001:	8b 45 14             	mov    0x14(%ebp),%eax
f0105004:	8d 40 04             	lea    0x4(%eax),%eax
f0105007:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010500a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010500d:	eb 2a                	jmp    f0105039 <vprintfmt+0xe5>
f010500f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105012:	85 c0                	test   %eax,%eax
f0105014:	ba 00 00 00 00       	mov    $0x0,%edx
f0105019:	0f 49 d0             	cmovns %eax,%edx
f010501c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010501f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105022:	eb 89                	jmp    f0104fad <vprintfmt+0x59>
f0105024:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105027:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010502e:	e9 7a ff ff ff       	jmp    f0104fad <vprintfmt+0x59>
f0105033:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105036:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105039:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010503d:	0f 89 6a ff ff ff    	jns    f0104fad <vprintfmt+0x59>
				width = precision, precision = -1;
f0105043:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105046:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105049:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105050:	e9 58 ff ff ff       	jmp    f0104fad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105055:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105058:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010505b:	e9 4d ff ff ff       	jmp    f0104fad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105060:	8b 45 14             	mov    0x14(%ebp),%eax
f0105063:	8d 78 04             	lea    0x4(%eax),%edi
f0105066:	83 ec 08             	sub    $0x8,%esp
f0105069:	53                   	push   %ebx
f010506a:	ff 30                	pushl  (%eax)
f010506c:	ff d6                	call   *%esi
			break;
f010506e:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105071:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105074:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105077:	e9 fe fe ff ff       	jmp    f0104f7a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010507c:	8b 45 14             	mov    0x14(%ebp),%eax
f010507f:	8d 78 04             	lea    0x4(%eax),%edi
f0105082:	8b 00                	mov    (%eax),%eax
f0105084:	99                   	cltd   
f0105085:	31 d0                	xor    %edx,%eax
f0105087:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105089:	83 f8 0f             	cmp    $0xf,%eax
f010508c:	7f 0b                	jg     f0105099 <vprintfmt+0x145>
f010508e:	8b 14 85 00 7d 10 f0 	mov    -0xfef8300(,%eax,4),%edx
f0105095:	85 d2                	test   %edx,%edx
f0105097:	75 1b                	jne    f01050b4 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0105099:	50                   	push   %eax
f010509a:	68 76 7a 10 f0       	push   $0xf0107a76
f010509f:	53                   	push   %ebx
f01050a0:	56                   	push   %esi
f01050a1:	e8 91 fe ff ff       	call   f0104f37 <printfmt>
f01050a6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01050a9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01050af:	e9 c6 fe ff ff       	jmp    f0104f7a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01050b4:	52                   	push   %edx
f01050b5:	68 9a 72 10 f0       	push   $0xf010729a
f01050ba:	53                   	push   %ebx
f01050bb:	56                   	push   %esi
f01050bc:	e8 76 fe ff ff       	call   f0104f37 <printfmt>
f01050c1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01050c4:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050ca:	e9 ab fe ff ff       	jmp    f0104f7a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01050cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01050d2:	83 c0 04             	add    $0x4,%eax
f01050d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01050d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01050db:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01050dd:	85 ff                	test   %edi,%edi
f01050df:	b8 6f 7a 10 f0       	mov    $0xf0107a6f,%eax
f01050e4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01050e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050eb:	0f 8e 94 00 00 00    	jle    f0105185 <vprintfmt+0x231>
f01050f1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01050f5:	0f 84 98 00 00 00    	je     f0105193 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f01050fb:	83 ec 08             	sub    $0x8,%esp
f01050fe:	ff 75 d0             	pushl  -0x30(%ebp)
f0105101:	57                   	push   %edi
f0105102:	e8 4c 04 00 00       	call   f0105553 <strnlen>
f0105107:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010510a:	29 c1                	sub    %eax,%ecx
f010510c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010510f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105112:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105116:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105119:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010511c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010511e:	eb 0f                	jmp    f010512f <vprintfmt+0x1db>
					putch(padc, putdat);
f0105120:	83 ec 08             	sub    $0x8,%esp
f0105123:	53                   	push   %ebx
f0105124:	ff 75 e0             	pushl  -0x20(%ebp)
f0105127:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105129:	83 ef 01             	sub    $0x1,%edi
f010512c:	83 c4 10             	add    $0x10,%esp
f010512f:	85 ff                	test   %edi,%edi
f0105131:	7f ed                	jg     f0105120 <vprintfmt+0x1cc>
f0105133:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105136:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105139:	85 c9                	test   %ecx,%ecx
f010513b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105140:	0f 49 c1             	cmovns %ecx,%eax
f0105143:	29 c1                	sub    %eax,%ecx
f0105145:	89 75 08             	mov    %esi,0x8(%ebp)
f0105148:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010514b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010514e:	89 cb                	mov    %ecx,%ebx
f0105150:	eb 4d                	jmp    f010519f <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105152:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105156:	74 1b                	je     f0105173 <vprintfmt+0x21f>
f0105158:	0f be c0             	movsbl %al,%eax
f010515b:	83 e8 20             	sub    $0x20,%eax
f010515e:	83 f8 5e             	cmp    $0x5e,%eax
f0105161:	76 10                	jbe    f0105173 <vprintfmt+0x21f>
					putch('?', putdat);
f0105163:	83 ec 08             	sub    $0x8,%esp
f0105166:	ff 75 0c             	pushl  0xc(%ebp)
f0105169:	6a 3f                	push   $0x3f
f010516b:	ff 55 08             	call   *0x8(%ebp)
f010516e:	83 c4 10             	add    $0x10,%esp
f0105171:	eb 0d                	jmp    f0105180 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0105173:	83 ec 08             	sub    $0x8,%esp
f0105176:	ff 75 0c             	pushl  0xc(%ebp)
f0105179:	52                   	push   %edx
f010517a:	ff 55 08             	call   *0x8(%ebp)
f010517d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105180:	83 eb 01             	sub    $0x1,%ebx
f0105183:	eb 1a                	jmp    f010519f <vprintfmt+0x24b>
f0105185:	89 75 08             	mov    %esi,0x8(%ebp)
f0105188:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010518b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010518e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105191:	eb 0c                	jmp    f010519f <vprintfmt+0x24b>
f0105193:	89 75 08             	mov    %esi,0x8(%ebp)
f0105196:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105199:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010519c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010519f:	83 c7 01             	add    $0x1,%edi
f01051a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01051a6:	0f be d0             	movsbl %al,%edx
f01051a9:	85 d2                	test   %edx,%edx
f01051ab:	74 23                	je     f01051d0 <vprintfmt+0x27c>
f01051ad:	85 f6                	test   %esi,%esi
f01051af:	78 a1                	js     f0105152 <vprintfmt+0x1fe>
f01051b1:	83 ee 01             	sub    $0x1,%esi
f01051b4:	79 9c                	jns    f0105152 <vprintfmt+0x1fe>
f01051b6:	89 df                	mov    %ebx,%edi
f01051b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01051bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051be:	eb 18                	jmp    f01051d8 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01051c0:	83 ec 08             	sub    $0x8,%esp
f01051c3:	53                   	push   %ebx
f01051c4:	6a 20                	push   $0x20
f01051c6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01051c8:	83 ef 01             	sub    $0x1,%edi
f01051cb:	83 c4 10             	add    $0x10,%esp
f01051ce:	eb 08                	jmp    f01051d8 <vprintfmt+0x284>
f01051d0:	89 df                	mov    %ebx,%edi
f01051d2:	8b 75 08             	mov    0x8(%ebp),%esi
f01051d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051d8:	85 ff                	test   %edi,%edi
f01051da:	7f e4                	jg     f01051c0 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01051dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01051df:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051e5:	e9 90 fd ff ff       	jmp    f0104f7a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051ea:	83 f9 01             	cmp    $0x1,%ecx
f01051ed:	7e 19                	jle    f0105208 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f01051ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f2:	8b 50 04             	mov    0x4(%eax),%edx
f01051f5:	8b 00                	mov    (%eax),%eax
f01051f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01051fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105200:	8d 40 08             	lea    0x8(%eax),%eax
f0105203:	89 45 14             	mov    %eax,0x14(%ebp)
f0105206:	eb 38                	jmp    f0105240 <vprintfmt+0x2ec>
	else if (lflag)
f0105208:	85 c9                	test   %ecx,%ecx
f010520a:	74 1b                	je     f0105227 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f010520c:	8b 45 14             	mov    0x14(%ebp),%eax
f010520f:	8b 00                	mov    (%eax),%eax
f0105211:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105214:	89 c1                	mov    %eax,%ecx
f0105216:	c1 f9 1f             	sar    $0x1f,%ecx
f0105219:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010521c:	8b 45 14             	mov    0x14(%ebp),%eax
f010521f:	8d 40 04             	lea    0x4(%eax),%eax
f0105222:	89 45 14             	mov    %eax,0x14(%ebp)
f0105225:	eb 19                	jmp    f0105240 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0105227:	8b 45 14             	mov    0x14(%ebp),%eax
f010522a:	8b 00                	mov    (%eax),%eax
f010522c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010522f:	89 c1                	mov    %eax,%ecx
f0105231:	c1 f9 1f             	sar    $0x1f,%ecx
f0105234:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105237:	8b 45 14             	mov    0x14(%ebp),%eax
f010523a:	8d 40 04             	lea    0x4(%eax),%eax
f010523d:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105240:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105243:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105246:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010524b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010524f:	0f 89 36 01 00 00    	jns    f010538b <vprintfmt+0x437>
				putch('-', putdat);
f0105255:	83 ec 08             	sub    $0x8,%esp
f0105258:	53                   	push   %ebx
f0105259:	6a 2d                	push   $0x2d
f010525b:	ff d6                	call   *%esi
				num = -(long long) num;
f010525d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105260:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105263:	f7 da                	neg    %edx
f0105265:	83 d1 00             	adc    $0x0,%ecx
f0105268:	f7 d9                	neg    %ecx
f010526a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010526d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105272:	e9 14 01 00 00       	jmp    f010538b <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105277:	83 f9 01             	cmp    $0x1,%ecx
f010527a:	7e 18                	jle    f0105294 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f010527c:	8b 45 14             	mov    0x14(%ebp),%eax
f010527f:	8b 10                	mov    (%eax),%edx
f0105281:	8b 48 04             	mov    0x4(%eax),%ecx
f0105284:	8d 40 08             	lea    0x8(%eax),%eax
f0105287:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010528a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010528f:	e9 f7 00 00 00       	jmp    f010538b <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0105294:	85 c9                	test   %ecx,%ecx
f0105296:	74 1a                	je     f01052b2 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0105298:	8b 45 14             	mov    0x14(%ebp),%eax
f010529b:	8b 10                	mov    (%eax),%edx
f010529d:	b9 00 00 00 00       	mov    $0x0,%ecx
f01052a2:	8d 40 04             	lea    0x4(%eax),%eax
f01052a5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01052a8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052ad:	e9 d9 00 00 00       	jmp    f010538b <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01052b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01052b5:	8b 10                	mov    (%eax),%edx
f01052b7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01052bc:	8d 40 04             	lea    0x4(%eax),%eax
f01052bf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01052c2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052c7:	e9 bf 00 00 00       	jmp    f010538b <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01052cc:	83 f9 01             	cmp    $0x1,%ecx
f01052cf:	7e 13                	jle    f01052e4 <vprintfmt+0x390>
		return va_arg(*ap, long long);
f01052d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01052d4:	8b 50 04             	mov    0x4(%eax),%edx
f01052d7:	8b 00                	mov    (%eax),%eax
f01052d9:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01052dc:	8d 49 08             	lea    0x8(%ecx),%ecx
f01052df:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01052e2:	eb 28                	jmp    f010530c <vprintfmt+0x3b8>
	else if (lflag)
f01052e4:	85 c9                	test   %ecx,%ecx
f01052e6:	74 13                	je     f01052fb <vprintfmt+0x3a7>
		return va_arg(*ap, long);
f01052e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052eb:	8b 10                	mov    (%eax),%edx
f01052ed:	89 d0                	mov    %edx,%eax
f01052ef:	99                   	cltd   
f01052f0:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01052f3:	8d 49 04             	lea    0x4(%ecx),%ecx
f01052f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01052f9:	eb 11                	jmp    f010530c <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
f01052fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01052fe:	8b 10                	mov    (%eax),%edx
f0105300:	89 d0                	mov    %edx,%eax
f0105302:	99                   	cltd   
f0105303:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105306:	8d 49 04             	lea    0x4(%ecx),%ecx
f0105309:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
f010530c:	89 d1                	mov    %edx,%ecx
f010530e:	89 c2                	mov    %eax,%edx
			base = 8;
f0105310:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105315:	eb 74                	jmp    f010538b <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105317:	83 ec 08             	sub    $0x8,%esp
f010531a:	53                   	push   %ebx
f010531b:	6a 30                	push   $0x30
f010531d:	ff d6                	call   *%esi
			putch('x', putdat);
f010531f:	83 c4 08             	add    $0x8,%esp
f0105322:	53                   	push   %ebx
f0105323:	6a 78                	push   $0x78
f0105325:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105327:	8b 45 14             	mov    0x14(%ebp),%eax
f010532a:	8b 10                	mov    (%eax),%edx
f010532c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105331:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105334:	8d 40 04             	lea    0x4(%eax),%eax
f0105337:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010533a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010533f:	eb 4a                	jmp    f010538b <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105341:	83 f9 01             	cmp    $0x1,%ecx
f0105344:	7e 15                	jle    f010535b <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
f0105346:	8b 45 14             	mov    0x14(%ebp),%eax
f0105349:	8b 10                	mov    (%eax),%edx
f010534b:	8b 48 04             	mov    0x4(%eax),%ecx
f010534e:	8d 40 08             	lea    0x8(%eax),%eax
f0105351:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105354:	b8 10 00 00 00       	mov    $0x10,%eax
f0105359:	eb 30                	jmp    f010538b <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010535b:	85 c9                	test   %ecx,%ecx
f010535d:	74 17                	je     f0105376 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
f010535f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105362:	8b 10                	mov    (%eax),%edx
f0105364:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105369:	8d 40 04             	lea    0x4(%eax),%eax
f010536c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010536f:	b8 10 00 00 00       	mov    $0x10,%eax
f0105374:	eb 15                	jmp    f010538b <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0105376:	8b 45 14             	mov    0x14(%ebp),%eax
f0105379:	8b 10                	mov    (%eax),%edx
f010537b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105380:	8d 40 04             	lea    0x4(%eax),%eax
f0105383:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105386:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010538b:	83 ec 0c             	sub    $0xc,%esp
f010538e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105392:	57                   	push   %edi
f0105393:	ff 75 e0             	pushl  -0x20(%ebp)
f0105396:	50                   	push   %eax
f0105397:	51                   	push   %ecx
f0105398:	52                   	push   %edx
f0105399:	89 da                	mov    %ebx,%edx
f010539b:	89 f0                	mov    %esi,%eax
f010539d:	e8 c9 fa ff ff       	call   f0104e6b <printnum>
			break;
f01053a2:	83 c4 20             	add    $0x20,%esp
f01053a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053a8:	e9 cd fb ff ff       	jmp    f0104f7a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01053ad:	83 ec 08             	sub    $0x8,%esp
f01053b0:	53                   	push   %ebx
f01053b1:	52                   	push   %edx
f01053b2:	ff d6                	call   *%esi
			break;
f01053b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01053ba:	e9 bb fb ff ff       	jmp    f0104f7a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01053bf:	83 ec 08             	sub    $0x8,%esp
f01053c2:	53                   	push   %ebx
f01053c3:	6a 25                	push   $0x25
f01053c5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01053c7:	83 c4 10             	add    $0x10,%esp
f01053ca:	eb 03                	jmp    f01053cf <vprintfmt+0x47b>
f01053cc:	83 ef 01             	sub    $0x1,%edi
f01053cf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01053d3:	75 f7                	jne    f01053cc <vprintfmt+0x478>
f01053d5:	e9 a0 fb ff ff       	jmp    f0104f7a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01053da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053dd:	5b                   	pop    %ebx
f01053de:	5e                   	pop    %esi
f01053df:	5f                   	pop    %edi
f01053e0:	5d                   	pop    %ebp
f01053e1:	c3                   	ret    

f01053e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01053e2:	55                   	push   %ebp
f01053e3:	89 e5                	mov    %esp,%ebp
f01053e5:	83 ec 18             	sub    $0x18,%esp
f01053e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01053eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01053ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01053f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01053f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01053ff:	85 c0                	test   %eax,%eax
f0105401:	74 26                	je     f0105429 <vsnprintf+0x47>
f0105403:	85 d2                	test   %edx,%edx
f0105405:	7e 22                	jle    f0105429 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105407:	ff 75 14             	pushl  0x14(%ebp)
f010540a:	ff 75 10             	pushl  0x10(%ebp)
f010540d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105410:	50                   	push   %eax
f0105411:	68 1a 4f 10 f0       	push   $0xf0104f1a
f0105416:	e8 39 fb ff ff       	call   f0104f54 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010541b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010541e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105421:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105424:	83 c4 10             	add    $0x10,%esp
f0105427:	eb 05                	jmp    f010542e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010542e:	c9                   	leave  
f010542f:	c3                   	ret    

f0105430 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105430:	55                   	push   %ebp
f0105431:	89 e5                	mov    %esp,%ebp
f0105433:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105436:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105439:	50                   	push   %eax
f010543a:	ff 75 10             	pushl  0x10(%ebp)
f010543d:	ff 75 0c             	pushl  0xc(%ebp)
f0105440:	ff 75 08             	pushl  0x8(%ebp)
f0105443:	e8 9a ff ff ff       	call   f01053e2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105448:	c9                   	leave  
f0105449:	c3                   	ret    

f010544a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010544a:	55                   	push   %ebp
f010544b:	89 e5                	mov    %esp,%ebp
f010544d:	57                   	push   %edi
f010544e:	56                   	push   %esi
f010544f:	53                   	push   %ebx
f0105450:	83 ec 0c             	sub    $0xc,%esp
f0105453:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105456:	85 c0                	test   %eax,%eax
f0105458:	74 11                	je     f010546b <readline+0x21>
		cprintf("%s", prompt);
f010545a:	83 ec 08             	sub    $0x8,%esp
f010545d:	50                   	push   %eax
f010545e:	68 9a 72 10 f0       	push   $0xf010729a
f0105463:	e8 53 e2 ff ff       	call   f01036bb <cprintf>
f0105468:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010546b:	83 ec 0c             	sub    $0xc,%esp
f010546e:	6a 00                	push   $0x0
f0105470:	e8 45 b3 ff ff       	call   f01007ba <iscons>
f0105475:	89 c7                	mov    %eax,%edi
f0105477:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010547a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010547f:	e8 25 b3 ff ff       	call   f01007a9 <getchar>
f0105484:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105486:	85 c0                	test   %eax,%eax
f0105488:	79 29                	jns    f01054b3 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010548a:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f010548f:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105492:	0f 84 9b 00 00 00    	je     f0105533 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105498:	83 ec 08             	sub    $0x8,%esp
f010549b:	53                   	push   %ebx
f010549c:	68 5f 7d 10 f0       	push   $0xf0107d5f
f01054a1:	e8 15 e2 ff ff       	call   f01036bb <cprintf>
f01054a6:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01054a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01054ae:	e9 80 00 00 00       	jmp    f0105533 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01054b3:	83 f8 08             	cmp    $0x8,%eax
f01054b6:	0f 94 c2             	sete   %dl
f01054b9:	83 f8 7f             	cmp    $0x7f,%eax
f01054bc:	0f 94 c0             	sete   %al
f01054bf:	08 c2                	or     %al,%dl
f01054c1:	74 1a                	je     f01054dd <readline+0x93>
f01054c3:	85 f6                	test   %esi,%esi
f01054c5:	7e 16                	jle    f01054dd <readline+0x93>
			if (echoing)
f01054c7:	85 ff                	test   %edi,%edi
f01054c9:	74 0d                	je     f01054d8 <readline+0x8e>
				cputchar('\b');
f01054cb:	83 ec 0c             	sub    $0xc,%esp
f01054ce:	6a 08                	push   $0x8
f01054d0:	e8 c4 b2 ff ff       	call   f0100799 <cputchar>
f01054d5:	83 c4 10             	add    $0x10,%esp
			i--;
f01054d8:	83 ee 01             	sub    $0x1,%esi
f01054db:	eb a2                	jmp    f010547f <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01054dd:	83 fb 1f             	cmp    $0x1f,%ebx
f01054e0:	7e 26                	jle    f0105508 <readline+0xbe>
f01054e2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01054e8:	7f 1e                	jg     f0105508 <readline+0xbe>
			if (echoing)
f01054ea:	85 ff                	test   %edi,%edi
f01054ec:	74 0c                	je     f01054fa <readline+0xb0>
				cputchar(c);
f01054ee:	83 ec 0c             	sub    $0xc,%esp
f01054f1:	53                   	push   %ebx
f01054f2:	e8 a2 b2 ff ff       	call   f0100799 <cputchar>
f01054f7:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01054fa:	88 9e 80 1a 21 f0    	mov    %bl,-0xfdee580(%esi)
f0105500:	8d 76 01             	lea    0x1(%esi),%esi
f0105503:	e9 77 ff ff ff       	jmp    f010547f <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105508:	83 fb 0a             	cmp    $0xa,%ebx
f010550b:	74 09                	je     f0105516 <readline+0xcc>
f010550d:	83 fb 0d             	cmp    $0xd,%ebx
f0105510:	0f 85 69 ff ff ff    	jne    f010547f <readline+0x35>
			if (echoing)
f0105516:	85 ff                	test   %edi,%edi
f0105518:	74 0d                	je     f0105527 <readline+0xdd>
				cputchar('\n');
f010551a:	83 ec 0c             	sub    $0xc,%esp
f010551d:	6a 0a                	push   $0xa
f010551f:	e8 75 b2 ff ff       	call   f0100799 <cputchar>
f0105524:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105527:	c6 86 80 1a 21 f0 00 	movb   $0x0,-0xfdee580(%esi)
			return buf;
f010552e:	b8 80 1a 21 f0       	mov    $0xf0211a80,%eax
		}
	}
}
f0105533:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105536:	5b                   	pop    %ebx
f0105537:	5e                   	pop    %esi
f0105538:	5f                   	pop    %edi
f0105539:	5d                   	pop    %ebp
f010553a:	c3                   	ret    

f010553b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010553b:	55                   	push   %ebp
f010553c:	89 e5                	mov    %esp,%ebp
f010553e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105541:	b8 00 00 00 00       	mov    $0x0,%eax
f0105546:	eb 03                	jmp    f010554b <strlen+0x10>
		n++;
f0105548:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010554b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010554f:	75 f7                	jne    f0105548 <strlen+0xd>
		n++;
	return n;
}
f0105551:	5d                   	pop    %ebp
f0105552:	c3                   	ret    

f0105553 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105553:	55                   	push   %ebp
f0105554:	89 e5                	mov    %esp,%ebp
f0105556:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105559:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010555c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105561:	eb 03                	jmp    f0105566 <strnlen+0x13>
		n++;
f0105563:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105566:	39 c2                	cmp    %eax,%edx
f0105568:	74 08                	je     f0105572 <strnlen+0x1f>
f010556a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010556e:	75 f3                	jne    f0105563 <strnlen+0x10>
f0105570:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105572:	5d                   	pop    %ebp
f0105573:	c3                   	ret    

f0105574 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105574:	55                   	push   %ebp
f0105575:	89 e5                	mov    %esp,%ebp
f0105577:	53                   	push   %ebx
f0105578:	8b 45 08             	mov    0x8(%ebp),%eax
f010557b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010557e:	89 c2                	mov    %eax,%edx
f0105580:	83 c2 01             	add    $0x1,%edx
f0105583:	83 c1 01             	add    $0x1,%ecx
f0105586:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010558a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010558d:	84 db                	test   %bl,%bl
f010558f:	75 ef                	jne    f0105580 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105591:	5b                   	pop    %ebx
f0105592:	5d                   	pop    %ebp
f0105593:	c3                   	ret    

f0105594 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105594:	55                   	push   %ebp
f0105595:	89 e5                	mov    %esp,%ebp
f0105597:	53                   	push   %ebx
f0105598:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010559b:	53                   	push   %ebx
f010559c:	e8 9a ff ff ff       	call   f010553b <strlen>
f01055a1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01055a4:	ff 75 0c             	pushl  0xc(%ebp)
f01055a7:	01 d8                	add    %ebx,%eax
f01055a9:	50                   	push   %eax
f01055aa:	e8 c5 ff ff ff       	call   f0105574 <strcpy>
	return dst;
}
f01055af:	89 d8                	mov    %ebx,%eax
f01055b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01055b4:	c9                   	leave  
f01055b5:	c3                   	ret    

f01055b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01055b6:	55                   	push   %ebp
f01055b7:	89 e5                	mov    %esp,%ebp
f01055b9:	56                   	push   %esi
f01055ba:	53                   	push   %ebx
f01055bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01055be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01055c1:	89 f3                	mov    %esi,%ebx
f01055c3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055c6:	89 f2                	mov    %esi,%edx
f01055c8:	eb 0f                	jmp    f01055d9 <strncpy+0x23>
		*dst++ = *src;
f01055ca:	83 c2 01             	add    $0x1,%edx
f01055cd:	0f b6 01             	movzbl (%ecx),%eax
f01055d0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01055d3:	80 39 01             	cmpb   $0x1,(%ecx)
f01055d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055d9:	39 da                	cmp    %ebx,%edx
f01055db:	75 ed                	jne    f01055ca <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01055dd:	89 f0                	mov    %esi,%eax
f01055df:	5b                   	pop    %ebx
f01055e0:	5e                   	pop    %esi
f01055e1:	5d                   	pop    %ebp
f01055e2:	c3                   	ret    

f01055e3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01055e3:	55                   	push   %ebp
f01055e4:	89 e5                	mov    %esp,%ebp
f01055e6:	56                   	push   %esi
f01055e7:	53                   	push   %ebx
f01055e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01055eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01055ee:	8b 55 10             	mov    0x10(%ebp),%edx
f01055f1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01055f3:	85 d2                	test   %edx,%edx
f01055f5:	74 21                	je     f0105618 <strlcpy+0x35>
f01055f7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01055fb:	89 f2                	mov    %esi,%edx
f01055fd:	eb 09                	jmp    f0105608 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01055ff:	83 c2 01             	add    $0x1,%edx
f0105602:	83 c1 01             	add    $0x1,%ecx
f0105605:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105608:	39 c2                	cmp    %eax,%edx
f010560a:	74 09                	je     f0105615 <strlcpy+0x32>
f010560c:	0f b6 19             	movzbl (%ecx),%ebx
f010560f:	84 db                	test   %bl,%bl
f0105611:	75 ec                	jne    f01055ff <strlcpy+0x1c>
f0105613:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105615:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105618:	29 f0                	sub    %esi,%eax
}
f010561a:	5b                   	pop    %ebx
f010561b:	5e                   	pop    %esi
f010561c:	5d                   	pop    %ebp
f010561d:	c3                   	ret    

f010561e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010561e:	55                   	push   %ebp
f010561f:	89 e5                	mov    %esp,%ebp
f0105621:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105624:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105627:	eb 06                	jmp    f010562f <strcmp+0x11>
		p++, q++;
f0105629:	83 c1 01             	add    $0x1,%ecx
f010562c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010562f:	0f b6 01             	movzbl (%ecx),%eax
f0105632:	84 c0                	test   %al,%al
f0105634:	74 04                	je     f010563a <strcmp+0x1c>
f0105636:	3a 02                	cmp    (%edx),%al
f0105638:	74 ef                	je     f0105629 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010563a:	0f b6 c0             	movzbl %al,%eax
f010563d:	0f b6 12             	movzbl (%edx),%edx
f0105640:	29 d0                	sub    %edx,%eax
}
f0105642:	5d                   	pop    %ebp
f0105643:	c3                   	ret    

f0105644 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105644:	55                   	push   %ebp
f0105645:	89 e5                	mov    %esp,%ebp
f0105647:	53                   	push   %ebx
f0105648:	8b 45 08             	mov    0x8(%ebp),%eax
f010564b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010564e:	89 c3                	mov    %eax,%ebx
f0105650:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105653:	eb 06                	jmp    f010565b <strncmp+0x17>
		n--, p++, q++;
f0105655:	83 c0 01             	add    $0x1,%eax
f0105658:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010565b:	39 d8                	cmp    %ebx,%eax
f010565d:	74 15                	je     f0105674 <strncmp+0x30>
f010565f:	0f b6 08             	movzbl (%eax),%ecx
f0105662:	84 c9                	test   %cl,%cl
f0105664:	74 04                	je     f010566a <strncmp+0x26>
f0105666:	3a 0a                	cmp    (%edx),%cl
f0105668:	74 eb                	je     f0105655 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010566a:	0f b6 00             	movzbl (%eax),%eax
f010566d:	0f b6 12             	movzbl (%edx),%edx
f0105670:	29 d0                	sub    %edx,%eax
f0105672:	eb 05                	jmp    f0105679 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105674:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105679:	5b                   	pop    %ebx
f010567a:	5d                   	pop    %ebp
f010567b:	c3                   	ret    

f010567c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010567c:	55                   	push   %ebp
f010567d:	89 e5                	mov    %esp,%ebp
f010567f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105682:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105686:	eb 07                	jmp    f010568f <strchr+0x13>
		if (*s == c)
f0105688:	38 ca                	cmp    %cl,%dl
f010568a:	74 0f                	je     f010569b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010568c:	83 c0 01             	add    $0x1,%eax
f010568f:	0f b6 10             	movzbl (%eax),%edx
f0105692:	84 d2                	test   %dl,%dl
f0105694:	75 f2                	jne    f0105688 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105696:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010569b:	5d                   	pop    %ebp
f010569c:	c3                   	ret    

f010569d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010569d:	55                   	push   %ebp
f010569e:	89 e5                	mov    %esp,%ebp
f01056a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01056a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056a7:	eb 03                	jmp    f01056ac <strfind+0xf>
f01056a9:	83 c0 01             	add    $0x1,%eax
f01056ac:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01056af:	38 ca                	cmp    %cl,%dl
f01056b1:	74 04                	je     f01056b7 <strfind+0x1a>
f01056b3:	84 d2                	test   %dl,%dl
f01056b5:	75 f2                	jne    f01056a9 <strfind+0xc>
			break;
	return (char *) s;
}
f01056b7:	5d                   	pop    %ebp
f01056b8:	c3                   	ret    

f01056b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01056b9:	55                   	push   %ebp
f01056ba:	89 e5                	mov    %esp,%ebp
f01056bc:	57                   	push   %edi
f01056bd:	56                   	push   %esi
f01056be:	53                   	push   %ebx
f01056bf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01056c5:	85 c9                	test   %ecx,%ecx
f01056c7:	74 36                	je     f01056ff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01056c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01056cf:	75 28                	jne    f01056f9 <memset+0x40>
f01056d1:	f6 c1 03             	test   $0x3,%cl
f01056d4:	75 23                	jne    f01056f9 <memset+0x40>
		c &= 0xFF;
f01056d6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01056da:	89 d3                	mov    %edx,%ebx
f01056dc:	c1 e3 08             	shl    $0x8,%ebx
f01056df:	89 d6                	mov    %edx,%esi
f01056e1:	c1 e6 18             	shl    $0x18,%esi
f01056e4:	89 d0                	mov    %edx,%eax
f01056e6:	c1 e0 10             	shl    $0x10,%eax
f01056e9:	09 f0                	or     %esi,%eax
f01056eb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01056ed:	89 d8                	mov    %ebx,%eax
f01056ef:	09 d0                	or     %edx,%eax
f01056f1:	c1 e9 02             	shr    $0x2,%ecx
f01056f4:	fc                   	cld    
f01056f5:	f3 ab                	rep stos %eax,%es:(%edi)
f01056f7:	eb 06                	jmp    f01056ff <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01056f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056fc:	fc                   	cld    
f01056fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01056ff:	89 f8                	mov    %edi,%eax
f0105701:	5b                   	pop    %ebx
f0105702:	5e                   	pop    %esi
f0105703:	5f                   	pop    %edi
f0105704:	5d                   	pop    %ebp
f0105705:	c3                   	ret    

f0105706 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105706:	55                   	push   %ebp
f0105707:	89 e5                	mov    %esp,%ebp
f0105709:	57                   	push   %edi
f010570a:	56                   	push   %esi
f010570b:	8b 45 08             	mov    0x8(%ebp),%eax
f010570e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105711:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105714:	39 c6                	cmp    %eax,%esi
f0105716:	73 35                	jae    f010574d <memmove+0x47>
f0105718:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010571b:	39 d0                	cmp    %edx,%eax
f010571d:	73 2e                	jae    f010574d <memmove+0x47>
		s += n;
		d += n;
f010571f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105722:	89 d6                	mov    %edx,%esi
f0105724:	09 fe                	or     %edi,%esi
f0105726:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010572c:	75 13                	jne    f0105741 <memmove+0x3b>
f010572e:	f6 c1 03             	test   $0x3,%cl
f0105731:	75 0e                	jne    f0105741 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105733:	83 ef 04             	sub    $0x4,%edi
f0105736:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105739:	c1 e9 02             	shr    $0x2,%ecx
f010573c:	fd                   	std    
f010573d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010573f:	eb 09                	jmp    f010574a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105741:	83 ef 01             	sub    $0x1,%edi
f0105744:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105747:	fd                   	std    
f0105748:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010574a:	fc                   	cld    
f010574b:	eb 1d                	jmp    f010576a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010574d:	89 f2                	mov    %esi,%edx
f010574f:	09 c2                	or     %eax,%edx
f0105751:	f6 c2 03             	test   $0x3,%dl
f0105754:	75 0f                	jne    f0105765 <memmove+0x5f>
f0105756:	f6 c1 03             	test   $0x3,%cl
f0105759:	75 0a                	jne    f0105765 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010575b:	c1 e9 02             	shr    $0x2,%ecx
f010575e:	89 c7                	mov    %eax,%edi
f0105760:	fc                   	cld    
f0105761:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105763:	eb 05                	jmp    f010576a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105765:	89 c7                	mov    %eax,%edi
f0105767:	fc                   	cld    
f0105768:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010576a:	5e                   	pop    %esi
f010576b:	5f                   	pop    %edi
f010576c:	5d                   	pop    %ebp
f010576d:	c3                   	ret    

f010576e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010576e:	55                   	push   %ebp
f010576f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105771:	ff 75 10             	pushl  0x10(%ebp)
f0105774:	ff 75 0c             	pushl  0xc(%ebp)
f0105777:	ff 75 08             	pushl  0x8(%ebp)
f010577a:	e8 87 ff ff ff       	call   f0105706 <memmove>
}
f010577f:	c9                   	leave  
f0105780:	c3                   	ret    

f0105781 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105781:	55                   	push   %ebp
f0105782:	89 e5                	mov    %esp,%ebp
f0105784:	56                   	push   %esi
f0105785:	53                   	push   %ebx
f0105786:	8b 45 08             	mov    0x8(%ebp),%eax
f0105789:	8b 55 0c             	mov    0xc(%ebp),%edx
f010578c:	89 c6                	mov    %eax,%esi
f010578e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105791:	eb 1a                	jmp    f01057ad <memcmp+0x2c>
		if (*s1 != *s2)
f0105793:	0f b6 08             	movzbl (%eax),%ecx
f0105796:	0f b6 1a             	movzbl (%edx),%ebx
f0105799:	38 d9                	cmp    %bl,%cl
f010579b:	74 0a                	je     f01057a7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010579d:	0f b6 c1             	movzbl %cl,%eax
f01057a0:	0f b6 db             	movzbl %bl,%ebx
f01057a3:	29 d8                	sub    %ebx,%eax
f01057a5:	eb 0f                	jmp    f01057b6 <memcmp+0x35>
		s1++, s2++;
f01057a7:	83 c0 01             	add    $0x1,%eax
f01057aa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01057ad:	39 f0                	cmp    %esi,%eax
f01057af:	75 e2                	jne    f0105793 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01057b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057b6:	5b                   	pop    %ebx
f01057b7:	5e                   	pop    %esi
f01057b8:	5d                   	pop    %ebp
f01057b9:	c3                   	ret    

f01057ba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01057ba:	55                   	push   %ebp
f01057bb:	89 e5                	mov    %esp,%ebp
f01057bd:	53                   	push   %ebx
f01057be:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01057c1:	89 c1                	mov    %eax,%ecx
f01057c3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01057c6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01057ca:	eb 0a                	jmp    f01057d6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01057cc:	0f b6 10             	movzbl (%eax),%edx
f01057cf:	39 da                	cmp    %ebx,%edx
f01057d1:	74 07                	je     f01057da <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01057d3:	83 c0 01             	add    $0x1,%eax
f01057d6:	39 c8                	cmp    %ecx,%eax
f01057d8:	72 f2                	jb     f01057cc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01057da:	5b                   	pop    %ebx
f01057db:	5d                   	pop    %ebp
f01057dc:	c3                   	ret    

f01057dd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01057dd:	55                   	push   %ebp
f01057de:	89 e5                	mov    %esp,%ebp
f01057e0:	57                   	push   %edi
f01057e1:	56                   	push   %esi
f01057e2:	53                   	push   %ebx
f01057e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01057e9:	eb 03                	jmp    f01057ee <strtol+0x11>
		s++;
f01057eb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01057ee:	0f b6 01             	movzbl (%ecx),%eax
f01057f1:	3c 20                	cmp    $0x20,%al
f01057f3:	74 f6                	je     f01057eb <strtol+0xe>
f01057f5:	3c 09                	cmp    $0x9,%al
f01057f7:	74 f2                	je     f01057eb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01057f9:	3c 2b                	cmp    $0x2b,%al
f01057fb:	75 0a                	jne    f0105807 <strtol+0x2a>
		s++;
f01057fd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105800:	bf 00 00 00 00       	mov    $0x0,%edi
f0105805:	eb 11                	jmp    f0105818 <strtol+0x3b>
f0105807:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010580c:	3c 2d                	cmp    $0x2d,%al
f010580e:	75 08                	jne    f0105818 <strtol+0x3b>
		s++, neg = 1;
f0105810:	83 c1 01             	add    $0x1,%ecx
f0105813:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105818:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010581e:	75 15                	jne    f0105835 <strtol+0x58>
f0105820:	80 39 30             	cmpb   $0x30,(%ecx)
f0105823:	75 10                	jne    f0105835 <strtol+0x58>
f0105825:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105829:	75 7c                	jne    f01058a7 <strtol+0xca>
		s += 2, base = 16;
f010582b:	83 c1 02             	add    $0x2,%ecx
f010582e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105833:	eb 16                	jmp    f010584b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105835:	85 db                	test   %ebx,%ebx
f0105837:	75 12                	jne    f010584b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105839:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010583e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105841:	75 08                	jne    f010584b <strtol+0x6e>
		s++, base = 8;
f0105843:	83 c1 01             	add    $0x1,%ecx
f0105846:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010584b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105850:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105853:	0f b6 11             	movzbl (%ecx),%edx
f0105856:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105859:	89 f3                	mov    %esi,%ebx
f010585b:	80 fb 09             	cmp    $0x9,%bl
f010585e:	77 08                	ja     f0105868 <strtol+0x8b>
			dig = *s - '0';
f0105860:	0f be d2             	movsbl %dl,%edx
f0105863:	83 ea 30             	sub    $0x30,%edx
f0105866:	eb 22                	jmp    f010588a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105868:	8d 72 9f             	lea    -0x61(%edx),%esi
f010586b:	89 f3                	mov    %esi,%ebx
f010586d:	80 fb 19             	cmp    $0x19,%bl
f0105870:	77 08                	ja     f010587a <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105872:	0f be d2             	movsbl %dl,%edx
f0105875:	83 ea 57             	sub    $0x57,%edx
f0105878:	eb 10                	jmp    f010588a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010587a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010587d:	89 f3                	mov    %esi,%ebx
f010587f:	80 fb 19             	cmp    $0x19,%bl
f0105882:	77 16                	ja     f010589a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105884:	0f be d2             	movsbl %dl,%edx
f0105887:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010588a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010588d:	7d 0b                	jge    f010589a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010588f:	83 c1 01             	add    $0x1,%ecx
f0105892:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105896:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105898:	eb b9                	jmp    f0105853 <strtol+0x76>

	if (endptr)
f010589a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010589e:	74 0d                	je     f01058ad <strtol+0xd0>
		*endptr = (char *) s;
f01058a0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058a3:	89 0e                	mov    %ecx,(%esi)
f01058a5:	eb 06                	jmp    f01058ad <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058a7:	85 db                	test   %ebx,%ebx
f01058a9:	74 98                	je     f0105843 <strtol+0x66>
f01058ab:	eb 9e                	jmp    f010584b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01058ad:	89 c2                	mov    %eax,%edx
f01058af:	f7 da                	neg    %edx
f01058b1:	85 ff                	test   %edi,%edi
f01058b3:	0f 45 c2             	cmovne %edx,%eax
}
f01058b6:	5b                   	pop    %ebx
f01058b7:	5e                   	pop    %esi
f01058b8:	5f                   	pop    %edi
f01058b9:	5d                   	pop    %ebp
f01058ba:	c3                   	ret    
f01058bb:	90                   	nop

f01058bc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01058bc:	fa                   	cli    

	xorw    %ax, %ax
f01058bd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01058bf:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01058c1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01058c3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01058c5:	0f 01 16             	lgdtl  (%esi)
f01058c8:	74 70                	je     f010593a <mpsearch1+0x3>
	movl    %cr0, %eax
f01058ca:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01058cd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01058d1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01058d4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01058da:	08 00                	or     %al,(%eax)

f01058dc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01058dc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01058e0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01058e2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01058e4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01058e6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01058ea:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01058ec:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01058ee:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01058f3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01058f6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01058f9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01058fe:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105901:	8b 25 84 1e 21 f0    	mov    0xf0211e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105907:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010590c:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105911:	ff d0                	call   *%eax

f0105913 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105913:	eb fe                	jmp    f0105913 <spin>
f0105915:	8d 76 00             	lea    0x0(%esi),%esi

f0105918 <gdt>:
	...
f0105920:	ff                   	(bad)  
f0105921:	ff 00                	incl   (%eax)
f0105923:	00 00                	add    %al,(%eax)
f0105925:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010592c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105930 <gdtdesc>:
f0105930:	17                   	pop    %ss
f0105931:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105936 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105936:	90                   	nop

f0105937 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105937:	55                   	push   %ebp
f0105938:	89 e5                	mov    %esp,%ebp
f010593a:	57                   	push   %edi
f010593b:	56                   	push   %esi
f010593c:	53                   	push   %ebx
f010593d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105940:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0105946:	89 c3                	mov    %eax,%ebx
f0105948:	c1 eb 0c             	shr    $0xc,%ebx
f010594b:	39 cb                	cmp    %ecx,%ebx
f010594d:	72 12                	jb     f0105961 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010594f:	50                   	push   %eax
f0105950:	68 a4 63 10 f0       	push   $0xf01063a4
f0105955:	6a 57                	push   $0x57
f0105957:	68 fd 7e 10 f0       	push   $0xf0107efd
f010595c:	e8 df a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105961:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105967:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105969:	89 c2                	mov    %eax,%edx
f010596b:	c1 ea 0c             	shr    $0xc,%edx
f010596e:	39 ca                	cmp    %ecx,%edx
f0105970:	72 12                	jb     f0105984 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105972:	50                   	push   %eax
f0105973:	68 a4 63 10 f0       	push   $0xf01063a4
f0105978:	6a 57                	push   $0x57
f010597a:	68 fd 7e 10 f0       	push   $0xf0107efd
f010597f:	e8 bc a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105984:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010598a:	eb 2f                	jmp    f01059bb <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010598c:	83 ec 04             	sub    $0x4,%esp
f010598f:	6a 04                	push   $0x4
f0105991:	68 0d 7f 10 f0       	push   $0xf0107f0d
f0105996:	53                   	push   %ebx
f0105997:	e8 e5 fd ff ff       	call   f0105781 <memcmp>
f010599c:	83 c4 10             	add    $0x10,%esp
f010599f:	85 c0                	test   %eax,%eax
f01059a1:	75 15                	jne    f01059b8 <mpsearch1+0x81>
f01059a3:	89 da                	mov    %ebx,%edx
f01059a5:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01059a8:	0f b6 0a             	movzbl (%edx),%ecx
f01059ab:	01 c8                	add    %ecx,%eax
f01059ad:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059b0:	39 d7                	cmp    %edx,%edi
f01059b2:	75 f4                	jne    f01059a8 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059b4:	84 c0                	test   %al,%al
f01059b6:	74 0e                	je     f01059c6 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01059b8:	83 c3 10             	add    $0x10,%ebx
f01059bb:	39 f3                	cmp    %esi,%ebx
f01059bd:	72 cd                	jb     f010598c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01059bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01059c4:	eb 02                	jmp    f01059c8 <mpsearch1+0x91>
f01059c6:	89 d8                	mov    %ebx,%eax
}
f01059c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059cb:	5b                   	pop    %ebx
f01059cc:	5e                   	pop    %esi
f01059cd:	5f                   	pop    %edi
f01059ce:	5d                   	pop    %ebp
f01059cf:	c3                   	ret    

f01059d0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01059d0:	55                   	push   %ebp
f01059d1:	89 e5                	mov    %esp,%ebp
f01059d3:	57                   	push   %edi
f01059d4:	56                   	push   %esi
f01059d5:	53                   	push   %ebx
f01059d6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01059d9:	c7 05 c0 23 21 f0 20 	movl   $0xf0212020,0xf02123c0
f01059e0:	20 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059e3:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f01059ea:	75 16                	jne    f0105a02 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059ec:	68 00 04 00 00       	push   $0x400
f01059f1:	68 a4 63 10 f0       	push   $0xf01063a4
f01059f6:	6a 6f                	push   $0x6f
f01059f8:	68 fd 7e 10 f0       	push   $0xf0107efd
f01059fd:	e8 3e a6 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105a02:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105a09:	85 c0                	test   %eax,%eax
f0105a0b:	74 16                	je     f0105a23 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105a0d:	c1 e0 04             	shl    $0x4,%eax
f0105a10:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a15:	e8 1d ff ff ff       	call   f0105937 <mpsearch1>
f0105a1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a1d:	85 c0                	test   %eax,%eax
f0105a1f:	75 3c                	jne    f0105a5d <mp_init+0x8d>
f0105a21:	eb 20                	jmp    f0105a43 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105a23:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105a2a:	c1 e0 0a             	shl    $0xa,%eax
f0105a2d:	2d 00 04 00 00       	sub    $0x400,%eax
f0105a32:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a37:	e8 fb fe ff ff       	call   f0105937 <mpsearch1>
f0105a3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a3f:	85 c0                	test   %eax,%eax
f0105a41:	75 1a                	jne    f0105a5d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105a43:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a48:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105a4d:	e8 e5 fe ff ff       	call   f0105937 <mpsearch1>
f0105a52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105a55:	85 c0                	test   %eax,%eax
f0105a57:	0f 84 6e 02 00 00    	je     f0105ccb <mp_init+0x2fb>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105a5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a60:	8b 70 04             	mov    0x4(%eax),%esi
f0105a63:	85 f6                	test   %esi,%esi
f0105a65:	74 06                	je     f0105a6d <mp_init+0x9d>
f0105a67:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105a6b:	74 15                	je     f0105a82 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105a6d:	83 ec 0c             	sub    $0xc,%esp
f0105a70:	68 70 7d 10 f0       	push   $0xf0107d70
f0105a75:	e8 41 dc ff ff       	call   f01036bb <cprintf>
f0105a7a:	83 c4 10             	add    $0x10,%esp
f0105a7d:	e9 49 02 00 00       	jmp    f0105ccb <mp_init+0x2fb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a82:	89 f0                	mov    %esi,%eax
f0105a84:	c1 e8 0c             	shr    $0xc,%eax
f0105a87:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0105a8d:	72 15                	jb     f0105aa4 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a8f:	56                   	push   %esi
f0105a90:	68 a4 63 10 f0       	push   $0xf01063a4
f0105a95:	68 90 00 00 00       	push   $0x90
f0105a9a:	68 fd 7e 10 f0       	push   $0xf0107efd
f0105a9f:	e8 9c a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105aa4:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105aaa:	83 ec 04             	sub    $0x4,%esp
f0105aad:	6a 04                	push   $0x4
f0105aaf:	68 12 7f 10 f0       	push   $0xf0107f12
f0105ab4:	53                   	push   %ebx
f0105ab5:	e8 c7 fc ff ff       	call   f0105781 <memcmp>
f0105aba:	83 c4 10             	add    $0x10,%esp
f0105abd:	85 c0                	test   %eax,%eax
f0105abf:	74 15                	je     f0105ad6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105ac1:	83 ec 0c             	sub    $0xc,%esp
f0105ac4:	68 a0 7d 10 f0       	push   $0xf0107da0
f0105ac9:	e8 ed db ff ff       	call   f01036bb <cprintf>
f0105ace:	83 c4 10             	add    $0x10,%esp
f0105ad1:	e9 f5 01 00 00       	jmp    f0105ccb <mp_init+0x2fb>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105ad6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105ada:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105ade:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105ae1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105ae6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aeb:	eb 0d                	jmp    f0105afa <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105aed:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105af4:	f0 
f0105af5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105af7:	83 c0 01             	add    $0x1,%eax
f0105afa:	39 c7                	cmp    %eax,%edi
f0105afc:	75 ef                	jne    f0105aed <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105afe:	84 d2                	test   %dl,%dl
f0105b00:	74 15                	je     f0105b17 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105b02:	83 ec 0c             	sub    $0xc,%esp
f0105b05:	68 d4 7d 10 f0       	push   $0xf0107dd4
f0105b0a:	e8 ac db ff ff       	call   f01036bb <cprintf>
f0105b0f:	83 c4 10             	add    $0x10,%esp
f0105b12:	e9 b4 01 00 00       	jmp    f0105ccb <mp_init+0x2fb>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105b17:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105b1b:	3c 01                	cmp    $0x1,%al
f0105b1d:	74 1d                	je     f0105b3c <mp_init+0x16c>
f0105b1f:	3c 04                	cmp    $0x4,%al
f0105b21:	74 19                	je     f0105b3c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105b23:	83 ec 08             	sub    $0x8,%esp
f0105b26:	0f b6 c0             	movzbl %al,%eax
f0105b29:	50                   	push   %eax
f0105b2a:	68 f8 7d 10 f0       	push   $0xf0107df8
f0105b2f:	e8 87 db ff ff       	call   f01036bb <cprintf>
f0105b34:	83 c4 10             	add    $0x10,%esp
f0105b37:	e9 8f 01 00 00       	jmp    f0105ccb <mp_init+0x2fb>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b3c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105b40:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b44:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b49:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105b4e:	01 ce                	add    %ecx,%esi
f0105b50:	eb 0d                	jmp    f0105b5f <mp_init+0x18f>
f0105b52:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105b59:	f0 
f0105b5a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b5c:	83 c0 01             	add    $0x1,%eax
f0105b5f:	39 c7                	cmp    %eax,%edi
f0105b61:	75 ef                	jne    f0105b52 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b63:	89 d0                	mov    %edx,%eax
f0105b65:	02 43 2a             	add    0x2a(%ebx),%al
f0105b68:	74 15                	je     f0105b7f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105b6a:	83 ec 0c             	sub    $0xc,%esp
f0105b6d:	68 18 7e 10 f0       	push   $0xf0107e18
f0105b72:	e8 44 db ff ff       	call   f01036bb <cprintf>
f0105b77:	83 c4 10             	add    $0x10,%esp
f0105b7a:	e9 4c 01 00 00       	jmp    f0105ccb <mp_init+0x2fb>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105b7f:	85 db                	test   %ebx,%ebx
f0105b81:	0f 84 44 01 00 00    	je     f0105ccb <mp_init+0x2fb>
		return;
	ismp = 1;
f0105b87:	c7 05 00 20 21 f0 01 	movl   $0x1,0xf0212000
f0105b8e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105b91:	8b 43 24             	mov    0x24(%ebx),%eax
f0105b94:	a3 00 30 25 f0       	mov    %eax,0xf0253000
	cprintf("mp_init: lapicaddr = %08x\n", lapicaddr);
f0105b99:	83 ec 08             	sub    $0x8,%esp
f0105b9c:	50                   	push   %eax
f0105b9d:	68 17 7f 10 f0       	push   $0xf0107f17
f0105ba2:	e8 14 db ff ff       	call   f01036bb <cprintf>

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ba7:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105baa:	83 c4 10             	add    $0x10,%esp
f0105bad:	be 00 00 00 00       	mov    $0x0,%esi
f0105bb2:	e9 85 00 00 00       	jmp    f0105c3c <mp_init+0x26c>
		switch (*p) {
f0105bb7:	0f b6 07             	movzbl (%edi),%eax
f0105bba:	84 c0                	test   %al,%al
f0105bbc:	74 06                	je     f0105bc4 <mp_init+0x1f4>
f0105bbe:	3c 04                	cmp    $0x4,%al
f0105bc0:	77 55                	ja     f0105c17 <mp_init+0x247>
f0105bc2:	eb 4e                	jmp    f0105c12 <mp_init+0x242>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105bc4:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105bc8:	74 11                	je     f0105bdb <mp_init+0x20b>
				bootcpu = &cpus[ncpu];
f0105bca:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0105bd1:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105bd6:	a3 c0 23 21 f0       	mov    %eax,0xf02123c0
			if (ncpu < NCPU) {
f0105bdb:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f0105be0:	83 f8 07             	cmp    $0x7,%eax
f0105be3:	7f 13                	jg     f0105bf8 <mp_init+0x228>
				cpus[ncpu].cpu_id = ncpu;
f0105be5:	6b d0 74             	imul   $0x74,%eax,%edx
f0105be8:	88 82 20 20 21 f0    	mov    %al,-0xfdedfe0(%edx)
				ncpu++;
f0105bee:	83 c0 01             	add    $0x1,%eax
f0105bf1:	a3 c4 23 21 f0       	mov    %eax,0xf02123c4
f0105bf6:	eb 15                	jmp    f0105c0d <mp_init+0x23d>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105bf8:	83 ec 08             	sub    $0x8,%esp
f0105bfb:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105bff:	50                   	push   %eax
f0105c00:	68 48 7e 10 f0       	push   $0xf0107e48
f0105c05:	e8 b1 da ff ff       	call   f01036bb <cprintf>
f0105c0a:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c0d:	83 c7 14             	add    $0x14,%edi
			continue;
f0105c10:	eb 27                	jmp    f0105c39 <mp_init+0x269>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c12:	83 c7 08             	add    $0x8,%edi
			continue;
f0105c15:	eb 22                	jmp    f0105c39 <mp_init+0x269>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c17:	83 ec 08             	sub    $0x8,%esp
f0105c1a:	0f b6 c0             	movzbl %al,%eax
f0105c1d:	50                   	push   %eax
f0105c1e:	68 70 7e 10 f0       	push   $0xf0107e70
f0105c23:	e8 93 da ff ff       	call   f01036bb <cprintf>
			ismp = 0;
f0105c28:	c7 05 00 20 21 f0 00 	movl   $0x0,0xf0212000
f0105c2f:	00 00 00 
			i = conf->entry;
f0105c32:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105c36:	83 c4 10             	add    $0x10,%esp
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;
	cprintf("mp_init: lapicaddr = %08x\n", lapicaddr);

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c39:	83 c6 01             	add    $0x1,%esi
f0105c3c:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105c40:	39 c6                	cmp    %eax,%esi
f0105c42:	0f 82 6f ff ff ff    	jb     f0105bb7 <mp_init+0x1e7>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105c48:	a1 c0 23 21 f0       	mov    0xf02123c0,%eax
f0105c4d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105c54:	83 3d 00 20 21 f0 00 	cmpl   $0x0,0xf0212000
f0105c5b:	75 26                	jne    f0105c83 <mp_init+0x2b3>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105c5d:	c7 05 c4 23 21 f0 01 	movl   $0x1,0xf02123c4
f0105c64:	00 00 00 
		lapicaddr = 0;
f0105c67:	c7 05 00 30 25 f0 00 	movl   $0x0,0xf0253000
f0105c6e:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105c71:	83 ec 0c             	sub    $0xc,%esp
f0105c74:	68 90 7e 10 f0       	push   $0xf0107e90
f0105c79:	e8 3d da ff ff       	call   f01036bb <cprintf>
		return;
f0105c7e:	83 c4 10             	add    $0x10,%esp
f0105c81:	eb 48                	jmp    f0105ccb <mp_init+0x2fb>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105c83:	83 ec 04             	sub    $0x4,%esp
f0105c86:	ff 35 c4 23 21 f0    	pushl  0xf02123c4
f0105c8c:	0f b6 00             	movzbl (%eax),%eax
f0105c8f:	50                   	push   %eax
f0105c90:	68 32 7f 10 f0       	push   $0xf0107f32
f0105c95:	e8 21 da ff ff       	call   f01036bb <cprintf>

	if (mp->imcrp) {
f0105c9a:	83 c4 10             	add    $0x10,%esp
f0105c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ca0:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105ca4:	74 25                	je     f0105ccb <mp_init+0x2fb>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105ca6:	83 ec 0c             	sub    $0xc,%esp
f0105ca9:	68 bc 7e 10 f0       	push   $0xf0107ebc
f0105cae:	e8 08 da ff ff       	call   f01036bb <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105cb3:	ba 22 00 00 00       	mov    $0x22,%edx
f0105cb8:	b8 70 00 00 00       	mov    $0x70,%eax
f0105cbd:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105cbe:	ba 23 00 00 00       	mov    $0x23,%edx
f0105cc3:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105cc4:	83 c8 01             	or     $0x1,%eax
f0105cc7:	ee                   	out    %al,(%dx)
f0105cc8:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cce:	5b                   	pop    %ebx
f0105ccf:	5e                   	pop    %esi
f0105cd0:	5f                   	pop    %edi
f0105cd1:	5d                   	pop    %ebp
f0105cd2:	c3                   	ret    

f0105cd3 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105cd3:	55                   	push   %ebp
f0105cd4:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105cd6:	8b 0d 04 30 25 f0    	mov    0xf0253004,%ecx
f0105cdc:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105cdf:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105ce1:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105ce6:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105ce9:	5d                   	pop    %ebp
f0105cea:	c3                   	ret    

f0105ceb <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105ceb:	55                   	push   %ebp
f0105cec:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105cee:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105cf3:	85 c0                	test   %eax,%eax
f0105cf5:	74 08                	je     f0105cff <cpunum+0x14>
		return lapic[ID] >> 24;
f0105cf7:	8b 40 20             	mov    0x20(%eax),%eax
f0105cfa:	c1 e8 18             	shr    $0x18,%eax
f0105cfd:	eb 05                	jmp    f0105d04 <cpunum+0x19>
	return 0;
f0105cff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d04:	5d                   	pop    %ebp
f0105d05:	c3                   	ret    

f0105d06 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105d06:	a1 00 30 25 f0       	mov    0xf0253000,%eax
f0105d0b:	85 c0                	test   %eax,%eax
f0105d0d:	0f 84 21 01 00 00    	je     f0105e34 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105d13:	55                   	push   %ebp
f0105d14:	89 e5                	mov    %esp,%ebp
f0105d16:	83 ec 10             	sub    $0x10,%esp
		return;
	// cprintf("lapicaddr = %08x\n", lapicaddr);

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105d19:	68 00 10 00 00       	push   $0x1000
f0105d1e:	50                   	push   %eax
f0105d1f:	e8 a1 b5 ff ff       	call   f01012c5 <mmio_map_region>
f0105d24:	a3 04 30 25 f0       	mov    %eax,0xf0253004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d29:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d2e:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105d33:	e8 9b ff ff ff       	call   f0105cd3 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105d38:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105d3d:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105d42:	e8 8c ff ff ff       	call   f0105cd3 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105d47:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105d4c:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105d51:	e8 7d ff ff ff       	call   f0105cd3 <lapicw>
	lapicw(TICR, 10000000); 
f0105d56:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105d5b:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105d60:	e8 6e ff ff ff       	call   f0105cd3 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105d65:	e8 81 ff ff ff       	call   f0105ceb <cpunum>
f0105d6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d6d:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105d72:	83 c4 10             	add    $0x10,%esp
f0105d75:	39 05 c0 23 21 f0    	cmp    %eax,0xf02123c0
f0105d7b:	74 0f                	je     f0105d8c <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105d7d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d82:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105d87:	e8 47 ff ff ff       	call   f0105cd3 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105d8c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d91:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105d96:	e8 38 ff ff ff       	call   f0105cd3 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105d9b:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105da0:	8b 40 30             	mov    0x30(%eax),%eax
f0105da3:	c1 e8 10             	shr    $0x10,%eax
f0105da6:	3c 03                	cmp    $0x3,%al
f0105da8:	76 0f                	jbe    f0105db9 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105daa:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105daf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105db4:	e8 1a ff ff ff       	call   f0105cd3 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105db9:	ba 33 00 00 00       	mov    $0x33,%edx
f0105dbe:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105dc3:	e8 0b ff ff ff       	call   f0105cd3 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105dc8:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dcd:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105dd2:	e8 fc fe ff ff       	call   f0105cd3 <lapicw>
	lapicw(ESR, 0);
f0105dd7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ddc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105de1:	e8 ed fe ff ff       	call   f0105cd3 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105de6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105deb:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105df0:	e8 de fe ff ff       	call   f0105cd3 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105df5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dfa:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dff:	e8 cf fe ff ff       	call   f0105cd3 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e04:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105e09:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e0e:	e8 c0 fe ff ff       	call   f0105cd3 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105e13:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105e19:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e1f:	f6 c4 10             	test   $0x10,%ah
f0105e22:	75 f5                	jne    f0105e19 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105e24:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e29:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e2e:	e8 a0 fe ff ff       	call   f0105cd3 <lapicw>
}
f0105e33:	c9                   	leave  
f0105e34:	f3 c3                	repz ret 

f0105e36 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105e36:	83 3d 04 30 25 f0 00 	cmpl   $0x0,0xf0253004
f0105e3d:	74 13                	je     f0105e52 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105e3f:	55                   	push   %ebp
f0105e40:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105e42:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e47:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e4c:	e8 82 fe ff ff       	call   f0105cd3 <lapicw>
}
f0105e51:	5d                   	pop    %ebp
f0105e52:	f3 c3                	repz ret 

f0105e54 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105e54:	55                   	push   %ebp
f0105e55:	89 e5                	mov    %esp,%ebp
f0105e57:	56                   	push   %esi
f0105e58:	53                   	push   %ebx
f0105e59:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105e5f:	ba 70 00 00 00       	mov    $0x70,%edx
f0105e64:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105e69:	ee                   	out    %al,(%dx)
f0105e6a:	ba 71 00 00 00       	mov    $0x71,%edx
f0105e6f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105e74:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e75:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105e7c:	75 19                	jne    f0105e97 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e7e:	68 67 04 00 00       	push   $0x467
f0105e83:	68 a4 63 10 f0       	push   $0xf01063a4
f0105e88:	68 99 00 00 00       	push   $0x99
f0105e8d:	68 4f 7f 10 f0       	push   $0xf0107f4f
f0105e92:	e8 a9 a1 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105e97:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105e9e:	00 00 
	wrv[1] = addr >> 4;
f0105ea0:	89 d8                	mov    %ebx,%eax
f0105ea2:	c1 e8 04             	shr    $0x4,%eax
f0105ea5:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105eab:	c1 e6 18             	shl    $0x18,%esi
f0105eae:	89 f2                	mov    %esi,%edx
f0105eb0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105eb5:	e8 19 fe ff ff       	call   f0105cd3 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105eba:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105ebf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ec4:	e8 0a fe ff ff       	call   f0105cd3 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105ec9:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105ece:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ed3:	e8 fb fd ff ff       	call   f0105cd3 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ed8:	c1 eb 0c             	shr    $0xc,%ebx
f0105edb:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ede:	89 f2                	mov    %esi,%edx
f0105ee0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ee5:	e8 e9 fd ff ff       	call   f0105cd3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105eea:	89 da                	mov    %ebx,%edx
f0105eec:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ef1:	e8 dd fd ff ff       	call   f0105cd3 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ef6:	89 f2                	mov    %esi,%edx
f0105ef8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105efd:	e8 d1 fd ff ff       	call   f0105cd3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f02:	89 da                	mov    %ebx,%edx
f0105f04:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f09:	e8 c5 fd ff ff       	call   f0105cd3 <lapicw>
		microdelay(200);
	}
}
f0105f0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f11:	5b                   	pop    %ebx
f0105f12:	5e                   	pop    %esi
f0105f13:	5d                   	pop    %ebp
f0105f14:	c3                   	ret    

f0105f15 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105f15:	55                   	push   %ebp
f0105f16:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105f18:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f1b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105f21:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f26:	e8 a8 fd ff ff       	call   f0105cd3 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f2b:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f0105f31:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f37:	f6 c4 10             	test   $0x10,%ah
f0105f3a:	75 f5                	jne    f0105f31 <lapic_ipi+0x1c>
		;
}
f0105f3c:	5d                   	pop    %ebp
f0105f3d:	c3                   	ret    

f0105f3e <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105f3e:	55                   	push   %ebp
f0105f3f:	89 e5                	mov    %esp,%ebp
f0105f41:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105f44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f4d:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105f50:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105f57:	5d                   	pop    %ebp
f0105f58:	c3                   	ret    

f0105f59 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105f59:	55                   	push   %ebp
f0105f5a:	89 e5                	mov    %esp,%ebp
f0105f5c:	56                   	push   %esi
f0105f5d:	53                   	push   %ebx
f0105f5e:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f61:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105f64:	74 14                	je     f0105f7a <spin_lock+0x21>
f0105f66:	8b 73 08             	mov    0x8(%ebx),%esi
f0105f69:	e8 7d fd ff ff       	call   f0105ceb <cpunum>
f0105f6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f71:	05 20 20 21 f0       	add    $0xf0212020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105f76:	39 c6                	cmp    %eax,%esi
f0105f78:	74 07                	je     f0105f81 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105f7a:	ba 01 00 00 00       	mov    $0x1,%edx
f0105f7f:	eb 20                	jmp    f0105fa1 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105f81:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105f84:	e8 62 fd ff ff       	call   f0105ceb <cpunum>
f0105f89:	83 ec 0c             	sub    $0xc,%esp
f0105f8c:	53                   	push   %ebx
f0105f8d:	50                   	push   %eax
f0105f8e:	68 5c 7f 10 f0       	push   $0xf0107f5c
f0105f93:	6a 41                	push   $0x41
f0105f95:	68 c0 7f 10 f0       	push   $0xf0107fc0
f0105f9a:	e8 a1 a0 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105f9f:	f3 90                	pause  
f0105fa1:	89 d0                	mov    %edx,%eax
f0105fa3:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105fa6:	85 c0                	test   %eax,%eax
f0105fa8:	75 f5                	jne    f0105f9f <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105faa:	e8 3c fd ff ff       	call   f0105ceb <cpunum>
f0105faf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fb2:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105fb7:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105fba:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105fbd:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105fbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fc4:	eb 0b                	jmp    f0105fd1 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105fc6:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105fc9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105fcc:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105fce:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105fd1:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105fd7:	76 11                	jbe    f0105fea <spin_lock+0x91>
f0105fd9:	83 f8 09             	cmp    $0x9,%eax
f0105fdc:	7e e8                	jle    f0105fc6 <spin_lock+0x6d>
f0105fde:	eb 0a                	jmp    f0105fea <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105fe0:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105fe7:	83 c0 01             	add    $0x1,%eax
f0105fea:	83 f8 09             	cmp    $0x9,%eax
f0105fed:	7e f1                	jle    f0105fe0 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105fef:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105ff2:	5b                   	pop    %ebx
f0105ff3:	5e                   	pop    %esi
f0105ff4:	5d                   	pop    %ebp
f0105ff5:	c3                   	ret    

f0105ff6 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105ff6:	55                   	push   %ebp
f0105ff7:	89 e5                	mov    %esp,%ebp
f0105ff9:	57                   	push   %edi
f0105ffa:	56                   	push   %esi
f0105ffb:	53                   	push   %ebx
f0105ffc:	83 ec 4c             	sub    $0x4c,%esp
f0105fff:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106002:	83 3e 00             	cmpl   $0x0,(%esi)
f0106005:	74 18                	je     f010601f <spin_unlock+0x29>
f0106007:	8b 5e 08             	mov    0x8(%esi),%ebx
f010600a:	e8 dc fc ff ff       	call   f0105ceb <cpunum>
f010600f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106012:	05 20 20 21 f0       	add    $0xf0212020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106017:	39 c3                	cmp    %eax,%ebx
f0106019:	0f 84 a5 00 00 00    	je     f01060c4 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010601f:	83 ec 04             	sub    $0x4,%esp
f0106022:	6a 28                	push   $0x28
f0106024:	8d 46 0c             	lea    0xc(%esi),%eax
f0106027:	50                   	push   %eax
f0106028:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010602b:	53                   	push   %ebx
f010602c:	e8 d5 f6 ff ff       	call   f0105706 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106031:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106034:	0f b6 38             	movzbl (%eax),%edi
f0106037:	8b 76 04             	mov    0x4(%esi),%esi
f010603a:	e8 ac fc ff ff       	call   f0105ceb <cpunum>
f010603f:	57                   	push   %edi
f0106040:	56                   	push   %esi
f0106041:	50                   	push   %eax
f0106042:	68 88 7f 10 f0       	push   $0xf0107f88
f0106047:	e8 6f d6 ff ff       	call   f01036bb <cprintf>
f010604c:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010604f:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106052:	eb 54                	jmp    f01060a8 <spin_unlock+0xb2>
f0106054:	83 ec 08             	sub    $0x8,%esp
f0106057:	57                   	push   %edi
f0106058:	50                   	push   %eax
f0106059:	e8 33 eb ff ff       	call   f0104b91 <debuginfo_eip>
f010605e:	83 c4 10             	add    $0x10,%esp
f0106061:	85 c0                	test   %eax,%eax
f0106063:	78 27                	js     f010608c <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106065:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106067:	83 ec 04             	sub    $0x4,%esp
f010606a:	89 c2                	mov    %eax,%edx
f010606c:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010606f:	52                   	push   %edx
f0106070:	ff 75 b0             	pushl  -0x50(%ebp)
f0106073:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106076:	ff 75 ac             	pushl  -0x54(%ebp)
f0106079:	ff 75 a8             	pushl  -0x58(%ebp)
f010607c:	50                   	push   %eax
f010607d:	68 d0 7f 10 f0       	push   $0xf0107fd0
f0106082:	e8 34 d6 ff ff       	call   f01036bb <cprintf>
f0106087:	83 c4 20             	add    $0x20,%esp
f010608a:	eb 12                	jmp    f010609e <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010608c:	83 ec 08             	sub    $0x8,%esp
f010608f:	ff 36                	pushl  (%esi)
f0106091:	68 e7 7f 10 f0       	push   $0xf0107fe7
f0106096:	e8 20 d6 ff ff       	call   f01036bb <cprintf>
f010609b:	83 c4 10             	add    $0x10,%esp
f010609e:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01060a1:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01060a4:	39 c3                	cmp    %eax,%ebx
f01060a6:	74 08                	je     f01060b0 <spin_unlock+0xba>
f01060a8:	89 de                	mov    %ebx,%esi
f01060aa:	8b 03                	mov    (%ebx),%eax
f01060ac:	85 c0                	test   %eax,%eax
f01060ae:	75 a4                	jne    f0106054 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01060b0:	83 ec 04             	sub    $0x4,%esp
f01060b3:	68 ef 7f 10 f0       	push   $0xf0107fef
f01060b8:	6a 67                	push   $0x67
f01060ba:	68 c0 7f 10 f0       	push   $0xf0107fc0
f01060bf:	e8 7c 9f ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01060c4:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01060cb:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01060d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01060d7:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01060da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01060dd:	5b                   	pop    %ebx
f01060de:	5e                   	pop    %esi
f01060df:	5f                   	pop    %edi
f01060e0:	5d                   	pop    %ebp
f01060e1:	c3                   	ret    
f01060e2:	66 90                	xchg   %ax,%ax
f01060e4:	66 90                	xchg   %ax,%ax
f01060e6:	66 90                	xchg   %ax,%ax
f01060e8:	66 90                	xchg   %ax,%ax
f01060ea:	66 90                	xchg   %ax,%ax
f01060ec:	66 90                	xchg   %ax,%ax
f01060ee:	66 90                	xchg   %ax,%ax

f01060f0 <__udivdi3>:
f01060f0:	55                   	push   %ebp
f01060f1:	57                   	push   %edi
f01060f2:	56                   	push   %esi
f01060f3:	53                   	push   %ebx
f01060f4:	83 ec 1c             	sub    $0x1c,%esp
f01060f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01060fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01060ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106103:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106107:	85 f6                	test   %esi,%esi
f0106109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010610d:	89 ca                	mov    %ecx,%edx
f010610f:	89 f8                	mov    %edi,%eax
f0106111:	75 3d                	jne    f0106150 <__udivdi3+0x60>
f0106113:	39 cf                	cmp    %ecx,%edi
f0106115:	0f 87 c5 00 00 00    	ja     f01061e0 <__udivdi3+0xf0>
f010611b:	85 ff                	test   %edi,%edi
f010611d:	89 fd                	mov    %edi,%ebp
f010611f:	75 0b                	jne    f010612c <__udivdi3+0x3c>
f0106121:	b8 01 00 00 00       	mov    $0x1,%eax
f0106126:	31 d2                	xor    %edx,%edx
f0106128:	f7 f7                	div    %edi
f010612a:	89 c5                	mov    %eax,%ebp
f010612c:	89 c8                	mov    %ecx,%eax
f010612e:	31 d2                	xor    %edx,%edx
f0106130:	f7 f5                	div    %ebp
f0106132:	89 c1                	mov    %eax,%ecx
f0106134:	89 d8                	mov    %ebx,%eax
f0106136:	89 cf                	mov    %ecx,%edi
f0106138:	f7 f5                	div    %ebp
f010613a:	89 c3                	mov    %eax,%ebx
f010613c:	89 d8                	mov    %ebx,%eax
f010613e:	89 fa                	mov    %edi,%edx
f0106140:	83 c4 1c             	add    $0x1c,%esp
f0106143:	5b                   	pop    %ebx
f0106144:	5e                   	pop    %esi
f0106145:	5f                   	pop    %edi
f0106146:	5d                   	pop    %ebp
f0106147:	c3                   	ret    
f0106148:	90                   	nop
f0106149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106150:	39 ce                	cmp    %ecx,%esi
f0106152:	77 74                	ja     f01061c8 <__udivdi3+0xd8>
f0106154:	0f bd fe             	bsr    %esi,%edi
f0106157:	83 f7 1f             	xor    $0x1f,%edi
f010615a:	0f 84 98 00 00 00    	je     f01061f8 <__udivdi3+0x108>
f0106160:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106165:	89 f9                	mov    %edi,%ecx
f0106167:	89 c5                	mov    %eax,%ebp
f0106169:	29 fb                	sub    %edi,%ebx
f010616b:	d3 e6                	shl    %cl,%esi
f010616d:	89 d9                	mov    %ebx,%ecx
f010616f:	d3 ed                	shr    %cl,%ebp
f0106171:	89 f9                	mov    %edi,%ecx
f0106173:	d3 e0                	shl    %cl,%eax
f0106175:	09 ee                	or     %ebp,%esi
f0106177:	89 d9                	mov    %ebx,%ecx
f0106179:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010617d:	89 d5                	mov    %edx,%ebp
f010617f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106183:	d3 ed                	shr    %cl,%ebp
f0106185:	89 f9                	mov    %edi,%ecx
f0106187:	d3 e2                	shl    %cl,%edx
f0106189:	89 d9                	mov    %ebx,%ecx
f010618b:	d3 e8                	shr    %cl,%eax
f010618d:	09 c2                	or     %eax,%edx
f010618f:	89 d0                	mov    %edx,%eax
f0106191:	89 ea                	mov    %ebp,%edx
f0106193:	f7 f6                	div    %esi
f0106195:	89 d5                	mov    %edx,%ebp
f0106197:	89 c3                	mov    %eax,%ebx
f0106199:	f7 64 24 0c          	mull   0xc(%esp)
f010619d:	39 d5                	cmp    %edx,%ebp
f010619f:	72 10                	jb     f01061b1 <__udivdi3+0xc1>
f01061a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01061a5:	89 f9                	mov    %edi,%ecx
f01061a7:	d3 e6                	shl    %cl,%esi
f01061a9:	39 c6                	cmp    %eax,%esi
f01061ab:	73 07                	jae    f01061b4 <__udivdi3+0xc4>
f01061ad:	39 d5                	cmp    %edx,%ebp
f01061af:	75 03                	jne    f01061b4 <__udivdi3+0xc4>
f01061b1:	83 eb 01             	sub    $0x1,%ebx
f01061b4:	31 ff                	xor    %edi,%edi
f01061b6:	89 d8                	mov    %ebx,%eax
f01061b8:	89 fa                	mov    %edi,%edx
f01061ba:	83 c4 1c             	add    $0x1c,%esp
f01061bd:	5b                   	pop    %ebx
f01061be:	5e                   	pop    %esi
f01061bf:	5f                   	pop    %edi
f01061c0:	5d                   	pop    %ebp
f01061c1:	c3                   	ret    
f01061c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01061c8:	31 ff                	xor    %edi,%edi
f01061ca:	31 db                	xor    %ebx,%ebx
f01061cc:	89 d8                	mov    %ebx,%eax
f01061ce:	89 fa                	mov    %edi,%edx
f01061d0:	83 c4 1c             	add    $0x1c,%esp
f01061d3:	5b                   	pop    %ebx
f01061d4:	5e                   	pop    %esi
f01061d5:	5f                   	pop    %edi
f01061d6:	5d                   	pop    %ebp
f01061d7:	c3                   	ret    
f01061d8:	90                   	nop
f01061d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061e0:	89 d8                	mov    %ebx,%eax
f01061e2:	f7 f7                	div    %edi
f01061e4:	31 ff                	xor    %edi,%edi
f01061e6:	89 c3                	mov    %eax,%ebx
f01061e8:	89 d8                	mov    %ebx,%eax
f01061ea:	89 fa                	mov    %edi,%edx
f01061ec:	83 c4 1c             	add    $0x1c,%esp
f01061ef:	5b                   	pop    %ebx
f01061f0:	5e                   	pop    %esi
f01061f1:	5f                   	pop    %edi
f01061f2:	5d                   	pop    %ebp
f01061f3:	c3                   	ret    
f01061f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01061f8:	39 ce                	cmp    %ecx,%esi
f01061fa:	72 0c                	jb     f0106208 <__udivdi3+0x118>
f01061fc:	31 db                	xor    %ebx,%ebx
f01061fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106202:	0f 87 34 ff ff ff    	ja     f010613c <__udivdi3+0x4c>
f0106208:	bb 01 00 00 00       	mov    $0x1,%ebx
f010620d:	e9 2a ff ff ff       	jmp    f010613c <__udivdi3+0x4c>
f0106212:	66 90                	xchg   %ax,%ax
f0106214:	66 90                	xchg   %ax,%ax
f0106216:	66 90                	xchg   %ax,%ax
f0106218:	66 90                	xchg   %ax,%ax
f010621a:	66 90                	xchg   %ax,%ax
f010621c:	66 90                	xchg   %ax,%ax
f010621e:	66 90                	xchg   %ax,%ax

f0106220 <__umoddi3>:
f0106220:	55                   	push   %ebp
f0106221:	57                   	push   %edi
f0106222:	56                   	push   %esi
f0106223:	53                   	push   %ebx
f0106224:	83 ec 1c             	sub    $0x1c,%esp
f0106227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010622b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010622f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106233:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106237:	85 d2                	test   %edx,%edx
f0106239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010623d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106241:	89 f3                	mov    %esi,%ebx
f0106243:	89 3c 24             	mov    %edi,(%esp)
f0106246:	89 74 24 04          	mov    %esi,0x4(%esp)
f010624a:	75 1c                	jne    f0106268 <__umoddi3+0x48>
f010624c:	39 f7                	cmp    %esi,%edi
f010624e:	76 50                	jbe    f01062a0 <__umoddi3+0x80>
f0106250:	89 c8                	mov    %ecx,%eax
f0106252:	89 f2                	mov    %esi,%edx
f0106254:	f7 f7                	div    %edi
f0106256:	89 d0                	mov    %edx,%eax
f0106258:	31 d2                	xor    %edx,%edx
f010625a:	83 c4 1c             	add    $0x1c,%esp
f010625d:	5b                   	pop    %ebx
f010625e:	5e                   	pop    %esi
f010625f:	5f                   	pop    %edi
f0106260:	5d                   	pop    %ebp
f0106261:	c3                   	ret    
f0106262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106268:	39 f2                	cmp    %esi,%edx
f010626a:	89 d0                	mov    %edx,%eax
f010626c:	77 52                	ja     f01062c0 <__umoddi3+0xa0>
f010626e:	0f bd ea             	bsr    %edx,%ebp
f0106271:	83 f5 1f             	xor    $0x1f,%ebp
f0106274:	75 5a                	jne    f01062d0 <__umoddi3+0xb0>
f0106276:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010627a:	0f 82 e0 00 00 00    	jb     f0106360 <__umoddi3+0x140>
f0106280:	39 0c 24             	cmp    %ecx,(%esp)
f0106283:	0f 86 d7 00 00 00    	jbe    f0106360 <__umoddi3+0x140>
f0106289:	8b 44 24 08          	mov    0x8(%esp),%eax
f010628d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106291:	83 c4 1c             	add    $0x1c,%esp
f0106294:	5b                   	pop    %ebx
f0106295:	5e                   	pop    %esi
f0106296:	5f                   	pop    %edi
f0106297:	5d                   	pop    %ebp
f0106298:	c3                   	ret    
f0106299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01062a0:	85 ff                	test   %edi,%edi
f01062a2:	89 fd                	mov    %edi,%ebp
f01062a4:	75 0b                	jne    f01062b1 <__umoddi3+0x91>
f01062a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01062ab:	31 d2                	xor    %edx,%edx
f01062ad:	f7 f7                	div    %edi
f01062af:	89 c5                	mov    %eax,%ebp
f01062b1:	89 f0                	mov    %esi,%eax
f01062b3:	31 d2                	xor    %edx,%edx
f01062b5:	f7 f5                	div    %ebp
f01062b7:	89 c8                	mov    %ecx,%eax
f01062b9:	f7 f5                	div    %ebp
f01062bb:	89 d0                	mov    %edx,%eax
f01062bd:	eb 99                	jmp    f0106258 <__umoddi3+0x38>
f01062bf:	90                   	nop
f01062c0:	89 c8                	mov    %ecx,%eax
f01062c2:	89 f2                	mov    %esi,%edx
f01062c4:	83 c4 1c             	add    $0x1c,%esp
f01062c7:	5b                   	pop    %ebx
f01062c8:	5e                   	pop    %esi
f01062c9:	5f                   	pop    %edi
f01062ca:	5d                   	pop    %ebp
f01062cb:	c3                   	ret    
f01062cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01062d0:	8b 34 24             	mov    (%esp),%esi
f01062d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01062d8:	89 e9                	mov    %ebp,%ecx
f01062da:	29 ef                	sub    %ebp,%edi
f01062dc:	d3 e0                	shl    %cl,%eax
f01062de:	89 f9                	mov    %edi,%ecx
f01062e0:	89 f2                	mov    %esi,%edx
f01062e2:	d3 ea                	shr    %cl,%edx
f01062e4:	89 e9                	mov    %ebp,%ecx
f01062e6:	09 c2                	or     %eax,%edx
f01062e8:	89 d8                	mov    %ebx,%eax
f01062ea:	89 14 24             	mov    %edx,(%esp)
f01062ed:	89 f2                	mov    %esi,%edx
f01062ef:	d3 e2                	shl    %cl,%edx
f01062f1:	89 f9                	mov    %edi,%ecx
f01062f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01062f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01062fb:	d3 e8                	shr    %cl,%eax
f01062fd:	89 e9                	mov    %ebp,%ecx
f01062ff:	89 c6                	mov    %eax,%esi
f0106301:	d3 e3                	shl    %cl,%ebx
f0106303:	89 f9                	mov    %edi,%ecx
f0106305:	89 d0                	mov    %edx,%eax
f0106307:	d3 e8                	shr    %cl,%eax
f0106309:	89 e9                	mov    %ebp,%ecx
f010630b:	09 d8                	or     %ebx,%eax
f010630d:	89 d3                	mov    %edx,%ebx
f010630f:	89 f2                	mov    %esi,%edx
f0106311:	f7 34 24             	divl   (%esp)
f0106314:	89 d6                	mov    %edx,%esi
f0106316:	d3 e3                	shl    %cl,%ebx
f0106318:	f7 64 24 04          	mull   0x4(%esp)
f010631c:	39 d6                	cmp    %edx,%esi
f010631e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106322:	89 d1                	mov    %edx,%ecx
f0106324:	89 c3                	mov    %eax,%ebx
f0106326:	72 08                	jb     f0106330 <__umoddi3+0x110>
f0106328:	75 11                	jne    f010633b <__umoddi3+0x11b>
f010632a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010632e:	73 0b                	jae    f010633b <__umoddi3+0x11b>
f0106330:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106334:	1b 14 24             	sbb    (%esp),%edx
f0106337:	89 d1                	mov    %edx,%ecx
f0106339:	89 c3                	mov    %eax,%ebx
f010633b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010633f:	29 da                	sub    %ebx,%edx
f0106341:	19 ce                	sbb    %ecx,%esi
f0106343:	89 f9                	mov    %edi,%ecx
f0106345:	89 f0                	mov    %esi,%eax
f0106347:	d3 e0                	shl    %cl,%eax
f0106349:	89 e9                	mov    %ebp,%ecx
f010634b:	d3 ea                	shr    %cl,%edx
f010634d:	89 e9                	mov    %ebp,%ecx
f010634f:	d3 ee                	shr    %cl,%esi
f0106351:	09 d0                	or     %edx,%eax
f0106353:	89 f2                	mov    %esi,%edx
f0106355:	83 c4 1c             	add    $0x1c,%esp
f0106358:	5b                   	pop    %ebx
f0106359:	5e                   	pop    %esi
f010635a:	5f                   	pop    %edi
f010635b:	5d                   	pop    %ebp
f010635c:	c3                   	ret    
f010635d:	8d 76 00             	lea    0x0(%esi),%esi
f0106360:	29 f9                	sub    %edi,%ecx
f0106362:	19 d6                	sbb    %edx,%esi
f0106364:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010636c:	e9 18 ff ff ff       	jmp    f0106289 <__umoddi3+0x69>
