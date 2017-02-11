
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 50 29 11 f0       	mov    $0xf0112950,%eax
f010004b:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 23 11 f0       	push   $0xf0112300
f0100058:	e8 7a 15 00 00       	call   f01015d7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 1a 10 f0       	push   $0xf0101a80
f010006f:	e8 03 0a 00 00       	call   f0100a77 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 88 08 00 00       	call   f0100901 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 0b 07 00 00       	call   f0100791 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 9b 1a 10 f0       	push   $0xf0101a9b
f01000b5:	e8 bd 09 00 00       	call   f0100a77 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 8d 09 00 00       	call   f0100a51 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 d7 1a 10 f0 	movl   $0xf0101ad7,(%esp)
f01000cb:	e8 a7 09 00 00       	call   f0100a77 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 b4 06 00 00       	call   f0100791 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 b3 1a 10 f0       	push   $0xf0101ab3
f01000f7:	e8 7b 09 00 00       	call   f0100a77 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 49 09 00 00       	call   f0100a51 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 d7 1a 10 f0 	movl   $0xf0101ad7,(%esp)
f010010f:	e8 63 09 00 00       	call   f0100a77 <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f0100159:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f8 00 00 00    	je     f0100284 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010018c:	a8 20                	test   $0x20,%al
f010018e:	0f 85 f6 00 00 00    	jne    f010028a <kbd_proc_data+0x10c>
f0100194:	ba 60 00 00 00       	mov    $0x60,%edx
f0100199:	ec                   	in     (%dx),%al
f010019a:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010019c:	3c e0                	cmp    $0xe0,%al
f010019e:	75 0d                	jne    f01001ad <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001a0:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ac:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	53                   	push   %ebx
f01001b1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001b4:	84 c0                	test   %al,%al
f01001b6:	79 36                	jns    f01001ee <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b8:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 20 1c 10 f0 	movzbl -0xfefe3e0(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 20 1c 10 f0 	movzbl -0xfefe3e0(%edx),%eax
f0100211:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100217:	0f b6 8a 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 00 1b 10 f0 	mov    -0xfefe500(,%ecx,4),%ecx
f0100231:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100235:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100238:	a8 08                	test   $0x8,%al
f010023a:	74 1b                	je     f0100257 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010023c:	89 da                	mov    %ebx,%edx
f010023e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100241:	83 f9 19             	cmp    $0x19,%ecx
f0100244:	77 05                	ja     f010024b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100246:	83 eb 20             	sub    $0x20,%ebx
f0100249:	eb 0c                	jmp    f0100257 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010024b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010024e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100251:	83 fa 19             	cmp    $0x19,%edx
f0100254:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100257:	f7 d0                	not    %eax
f0100259:	a8 06                	test   $0x6,%al
f010025b:	75 33                	jne    f0100290 <kbd_proc_data+0x112>
f010025d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100263:	75 2b                	jne    f0100290 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100265:	83 ec 0c             	sub    $0xc,%esp
f0100268:	68 cd 1a 10 f0       	push   $0xf0101acd
f010026d:	e8 05 08 00 00       	call   f0100a77 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100272:	ba 92 00 00 00       	mov    $0x92,%edx
f0100277:	b8 03 00 00 00       	mov    $0x3,%eax
f010027c:	ee                   	out    %al,(%dx)
f010027d:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
f0100282:	eb 0e                	jmp    f0100292 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100289:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010028a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010028f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100290:	89 d8                	mov    %ebx,%eax
}
f0100292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100295:	c9                   	leave  
f0100296:	c3                   	ret    

f0100297 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
f010029a:	57                   	push   %edi
f010029b:	56                   	push   %esi
f010029c:	53                   	push   %ebx
f010029d:	83 ec 1c             	sub    $0x1c,%esp
f01002a0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ac:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b1:	eb 09                	jmp    f01002bc <cons_putc+0x25>
f01002b3:	89 ca                	mov    %ecx,%edx
f01002b5:	ec                   	in     (%dx),%al
f01002b6:	ec                   	in     (%dx),%al
f01002b7:	ec                   	in     (%dx),%al
f01002b8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002b9:	83 c3 01             	add    $0x1,%ebx
f01002bc:	89 f2                	mov    %esi,%edx
f01002be:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bf:	a8 20                	test   $0x20,%al
f01002c1:	75 08                	jne    f01002cb <cons_putc+0x34>
f01002c3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002c9:	7e e8                	jle    f01002b3 <cons_putc+0x1c>
f01002cb:	89 f8                	mov    %edi,%eax
f01002cd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d5:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002db:	be 79 03 00 00       	mov    $0x379,%esi
f01002e0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e5:	eb 09                	jmp    f01002f0 <cons_putc+0x59>
f01002e7:	89 ca                	mov    %ecx,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	83 c3 01             	add    $0x1,%ebx
f01002f0:	89 f2                	mov    %esi,%edx
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f9:	7f 04                	jg     f01002ff <cons_putc+0x68>
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 e8                	jns    f01002e7 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba 78 03 00 00       	mov    $0x378,%edx
f0100304:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100308:	ee                   	out    %al,(%dx)
f0100309:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010030e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	b8 08 00 00 00       	mov    $0x8,%eax
f0100319:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031a:	89 fa                	mov    %edi,%edx
f010031c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	80 cc 07             	or     $0x7,%ah
f0100327:	85 d2                	test   %edx,%edx
f0100329:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	83 f8 09             	cmp    $0x9,%eax
f0100334:	74 74                	je     f01003aa <cons_putc+0x113>
f0100336:	83 f8 09             	cmp    $0x9,%eax
f0100339:	7f 0a                	jg     f0100345 <cons_putc+0xae>
f010033b:	83 f8 08             	cmp    $0x8,%eax
f010033e:	74 14                	je     f0100354 <cons_putc+0xbd>
f0100340:	e9 99 00 00 00       	jmp    f01003de <cons_putc+0x147>
f0100345:	83 f8 0a             	cmp    $0xa,%eax
f0100348:	74 3a                	je     f0100384 <cons_putc+0xed>
f010034a:	83 f8 0d             	cmp    $0xd,%eax
f010034d:	74 3d                	je     f010038c <cons_putc+0xf5>
f010034f:	e9 8a 00 00 00       	jmp    f01003de <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100354:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f01003a8:	eb 52                	jmp    f01003fc <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003aa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003af:	e8 e3 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b9:	e8 d9 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003be:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c3:	e8 cf fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cd:	e8 c5 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 bb fe ff ff       	call   f0100297 <cons_putc>
f01003dc:	eb 1e                	jmp    f01003fc <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003de:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// Move all the content 1 line upward
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 03 12 00 00       	call   f0101624 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100427:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010042d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100433:	83 c4 10             	add    $0x10,%esp
f0100436:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043b:	83 c0 02             	add    $0x2,%eax
	// Move all the content 1 line upward
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043e:	39 d0                	cmp    %edx,%eax
f0100440:	75 f4                	jne    f0100436 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100442:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f010045f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	66 c1 e8 08          	shr    $0x8,%ax
f0100468:	89 f2                	mov    %esi,%edx
f010046a:	ee                   	out    %al,(%dx)
f010046b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100470:	89 ca                	mov    %ecx,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	89 d8                	mov    %ebx,%eax
f0100475:	89 f2                	mov    %esi,%edx
f0100477:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047b:	5b                   	pop    %ebx
f010047c:	5e                   	pop    %esi
f010047d:	5f                   	pop    %edi
f010047e:	5d                   	pop    %ebp
f010047f:	c3                   	ret    

f0100480 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100480:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f0100487:	74 11                	je     f010049a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010048f:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100494:	e8 a2 fc ff ff       	call   f010013b <cons_intr>
}
f0100499:	c9                   	leave  
f010049a:	f3 c3                	repz ret 

f010049c <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a2:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004a7:	e8 8f fc ff ff       	call   f010013b <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b4:	e8 c7 ff ff ff       	call   f0100480 <serial_intr>
	kbd_intr();
f01004b9:	e8 de ff ff ff       	call   f010049c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004be:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f01004c3:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f01004d4:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004db:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004dd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e3:	75 11                	jne    f01004f6 <cons_getc+0x48>
			cons.rpos = 0;
f01004e5:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f01004ec:	00 00 00 
f01004ef:	eb 05                	jmp    f01004f6 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	57                   	push   %edi
f01004fc:	56                   	push   %esi
f01004fd:	53                   	push   %ebx
f01004fe:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100501:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100508:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010050f:	5a a5 
	if (*cp != 0xA55A) {
f0100511:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100518:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051c:	74 11                	je     f010052f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010051e:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100525:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100528:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010052d:	eb 16                	jmp    f0100545 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010052f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100536:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010053d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100540:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100545:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f010054b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100550:	89 fa                	mov    %edi,%edx
f0100552:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100553:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100556:	89 da                	mov    %ebx,%edx
f0100558:	ec                   	in     (%dx),%al
f0100559:	0f b6 c8             	movzbl %al,%ecx
f010055c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100564:	89 fa                	mov    %edi,%edx
f0100566:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100567:	89 da                	mov    %ebx,%edx
f0100569:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010056a:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100580:	b8 00 00 00 00       	mov    $0x0,%eax
f0100585:	89 f2                	mov    %esi,%edx
f0100587:	ee                   	out    %al,(%dx)
f0100588:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010058d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100592:	ee                   	out    %al,(%dx)
f0100593:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100598:	b8 0c 00 00 00       	mov    $0xc,%eax
f010059d:	89 da                	mov    %ebx,%edx
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005cb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d4:	3c ff                	cmp    $0xff,%al
f01005d6:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	89 da                	mov    %ebx,%edx
f01005e2:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e3:	80 f9 ff             	cmp    $0xff,%cl
f01005e6:	75 10                	jne    f01005f8 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005e8:	83 ec 0c             	sub    $0xc,%esp
f01005eb:	68 d9 1a 10 f0       	push   $0xf0101ad9
f01005f0:	e8 82 04 00 00       	call   f0100a77 <cprintf>
f01005f5:	83 c4 10             	add    $0x10,%esp
}
f01005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005fb:	5b                   	pop    %ebx
f01005fc:	5e                   	pop    %esi
f01005fd:	5f                   	pop    %edi
f01005fe:	5d                   	pop    %ebp
f01005ff:	c3                   	ret    

f0100600 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100606:	8b 45 08             	mov    0x8(%ebp),%eax
f0100609:	e8 89 fc ff ff       	call   f0100297 <cons_putc>
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <getchar>:

int
getchar(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100616:	e8 93 fe ff ff       	call   f01004ae <cons_getc>
f010061b:	85 c0                	test   %eax,%eax
f010061d:	74 f7                	je     f0100616 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <iscons>:

int
iscons(int fdnum)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100624:	b8 01 00 00 00       	mov    $0x1,%eax
f0100629:	5d                   	pop    %ebp
f010062a:	c3                   	ret    

f010062b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100631:	68 20 1d 10 f0       	push   $0xf0101d20
f0100636:	68 3e 1d 10 f0       	push   $0xf0101d3e
f010063b:	68 43 1d 10 f0       	push   $0xf0101d43
f0100640:	e8 32 04 00 00       	call   f0100a77 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 ac 1d 10 f0       	push   $0xf0101dac
f010064d:	68 4c 1d 10 f0       	push   $0xf0101d4c
f0100652:	68 43 1d 10 f0       	push   $0xf0101d43
f0100657:	e8 1b 04 00 00       	call   f0100a77 <cprintf>
	return 0;
}
f010065c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100661:	c9                   	leave  
f0100662:	c3                   	ret    

f0100663 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100663:	55                   	push   %ebp
f0100664:	89 e5                	mov    %esp,%ebp
f0100666:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100669:	68 55 1d 10 f0       	push   $0xf0101d55
f010066e:	e8 04 04 00 00       	call   f0100a77 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100673:	83 c4 08             	add    $0x8,%esp
f0100676:	68 0c 00 10 00       	push   $0x10000c
f010067b:	68 d4 1d 10 f0       	push   $0xf0101dd4
f0100680:	e8 f2 03 00 00       	call   f0100a77 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100685:	83 c4 0c             	add    $0xc,%esp
f0100688:	68 0c 00 10 00       	push   $0x10000c
f010068d:	68 0c 00 10 f0       	push   $0xf010000c
f0100692:	68 fc 1d 10 f0       	push   $0xf0101dfc
f0100697:	e8 db 03 00 00       	call   f0100a77 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 61 1a 10 00       	push   $0x101a61
f01006a4:	68 61 1a 10 f0       	push   $0xf0101a61
f01006a9:	68 20 1e 10 f0       	push   $0xf0101e20
f01006ae:	e8 c4 03 00 00       	call   f0100a77 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 00 23 11 00       	push   $0x112300
f01006bb:	68 00 23 11 f0       	push   $0xf0112300
f01006c0:	68 44 1e 10 f0       	push   $0xf0101e44
f01006c5:	e8 ad 03 00 00       	call   f0100a77 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 50 29 11 00       	push   $0x112950
f01006d2:	68 50 29 11 f0       	push   $0xf0112950
f01006d7:	68 68 1e 10 f0       	push   $0xf0101e68
f01006dc:	e8 96 03 00 00       	call   f0100a77 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e1:	b8 4f 2d 11 f0       	mov    $0xf0112d4f,%eax
f01006e6:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006eb:	83 c4 08             	add    $0x8,%esp
f01006ee:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006f3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	0f 48 c2             	cmovs  %edx,%eax
f01006fe:	c1 f8 0a             	sar    $0xa,%eax
f0100701:	50                   	push   %eax
f0100702:	68 8c 1e 10 f0       	push   $0xf0101e8c
f0100707:	e8 6b 03 00 00       	call   f0100a77 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010070c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100711:	c9                   	leave  
f0100712:	c3                   	ret    

f0100713 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100713:	55                   	push   %ebp
f0100714:	89 e5                	mov    %esp,%ebp
f0100716:	57                   	push   %edi
f0100717:	56                   	push   %esi
f0100718:	53                   	push   %ebx
f0100719:	81 ec 2c 04 00 00    	sub    $0x42c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010071f:	89 eb                	mov    %ebp,%ebx
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
		eip = *(ebp + 1);
		debuginfo_eip(eip, &info);
		strncpy(fn_name, info.eip_fn_name, info.eip_fn_namelen);
f0100721:	8d bd d0 fb ff ff    	lea    -0x430(%ebp),%edi
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t* ebp = (uint32_t*)read_ebp();
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
f0100727:	eb 57                	jmp    f0100780 <mon_backtrace+0x6d>
		eip = *(ebp + 1);
f0100729:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f010072c:	83 ec 08             	sub    $0x8,%esp
f010072f:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100732:	50                   	push   %eax
f0100733:	56                   	push   %esi
f0100734:	e8 48 04 00 00       	call   f0100b81 <debuginfo_eip>
		strncpy(fn_name, info.eip_fn_name, info.eip_fn_namelen);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	ff 75 dc             	pushl  -0x24(%ebp)
f010073f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100742:	57                   	push   %edi
f0100743:	e8 8c 0d 00 00       	call   f01014d4 <strncpy>
		fn_name[info.eip_fn_namelen] = 0;
f0100748:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010074b:	c6 84 05 d0 fb ff ff 	movb   $0x0,-0x430(%ebp,%eax,1)
f0100752:	00 
		cprintf("ebp %x eip %x args %08d %08d %08d %08d %08d"
f0100753:	89 f0                	mov    %esi,%eax
f0100755:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100758:	50                   	push   %eax
f0100759:	57                   	push   %edi
f010075a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010075d:	ff 75 d0             	pushl  -0x30(%ebp)
f0100760:	ff 73 18             	pushl  0x18(%ebx)
f0100763:	ff 73 14             	pushl  0x14(%ebx)
f0100766:	ff 73 10             	pushl  0x10(%ebx)
f0100769:	ff 73 0c             	pushl  0xc(%ebx)
f010076c:	ff 73 08             	pushl  0x8(%ebx)
f010076f:	56                   	push   %esi
f0100770:	53                   	push   %ebx
f0100771:	68 b8 1e 10 f0       	push   $0xf0101eb8
f0100776:	e8 fc 02 00 00       	call   f0100a77 <cprintf>
				" %s:%d: %s+%d\n", ebp, eip, *(ebp + 2), *(ebp + 3), 
				*(ebp + 4), *(ebp + 5), *(ebp + 6), info.eip_file, 
				info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t*)*ebp;
f010077b:	8b 1b                	mov    (%ebx),%ebx
f010077d:	83 c4 40             	add    $0x40,%esp
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t* ebp = (uint32_t*)read_ebp();
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
f0100780:	85 db                	test   %ebx,%ebx
f0100782:	75 a5                	jne    f0100729 <mon_backtrace+0x16>
				*(ebp + 4), *(ebp + 5), *(ebp + 6), info.eip_file, 
				info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t*)*ebp;
	}
	return 0;
}
f0100784:	b8 00 00 00 00       	mov    $0x0,%eax
f0100789:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010078c:	5b                   	pop    %ebx
f010078d:	5e                   	pop    %esi
f010078e:	5f                   	pop    %edi
f010078f:	5d                   	pop    %ebp
f0100790:	c3                   	ret    

f0100791 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100791:	55                   	push   %ebp
f0100792:	89 e5                	mov    %esp,%ebp
f0100794:	57                   	push   %edi
f0100795:	56                   	push   %esi
f0100796:	53                   	push   %ebx
f0100797:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010079a:	68 f4 1e 10 f0       	push   $0xf0101ef4
f010079f:	e8 d3 02 00 00       	call   f0100a77 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007a4:	c7 04 24 18 1f 10 f0 	movl   $0xf0101f18,(%esp)
f01007ab:	e8 c7 02 00 00       	call   f0100a77 <cprintf>
f01007b0:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007b3:	83 ec 0c             	sub    $0xc,%esp
f01007b6:	68 6e 1d 10 f0       	push   $0xf0101d6e
f01007bb:	e8 c0 0b 00 00       	call   f0101380 <readline>
f01007c0:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007c2:	83 c4 10             	add    $0x10,%esp
f01007c5:	85 c0                	test   %eax,%eax
f01007c7:	74 ea                	je     f01007b3 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007c9:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007d0:	be 00 00 00 00       	mov    $0x0,%esi
f01007d5:	eb 0a                	jmp    f01007e1 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007d7:	c6 03 00             	movb   $0x0,(%ebx)
f01007da:	89 f7                	mov    %esi,%edi
f01007dc:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007df:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007e1:	0f b6 03             	movzbl (%ebx),%eax
f01007e4:	84 c0                	test   %al,%al
f01007e6:	74 63                	je     f010084b <monitor+0xba>
f01007e8:	83 ec 08             	sub    $0x8,%esp
f01007eb:	0f be c0             	movsbl %al,%eax
f01007ee:	50                   	push   %eax
f01007ef:	68 72 1d 10 f0       	push   $0xf0101d72
f01007f4:	e8 a1 0d 00 00       	call   f010159a <strchr>
f01007f9:	83 c4 10             	add    $0x10,%esp
f01007fc:	85 c0                	test   %eax,%eax
f01007fe:	75 d7                	jne    f01007d7 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100800:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100803:	74 46                	je     f010084b <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100805:	83 fe 0f             	cmp    $0xf,%esi
f0100808:	75 14                	jne    f010081e <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010080a:	83 ec 08             	sub    $0x8,%esp
f010080d:	6a 10                	push   $0x10
f010080f:	68 77 1d 10 f0       	push   $0xf0101d77
f0100814:	e8 5e 02 00 00       	call   f0100a77 <cprintf>
f0100819:	83 c4 10             	add    $0x10,%esp
f010081c:	eb 95                	jmp    f01007b3 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010081e:	8d 7e 01             	lea    0x1(%esi),%edi
f0100821:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100825:	eb 03                	jmp    f010082a <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100827:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010082a:	0f b6 03             	movzbl (%ebx),%eax
f010082d:	84 c0                	test   %al,%al
f010082f:	74 ae                	je     f01007df <monitor+0x4e>
f0100831:	83 ec 08             	sub    $0x8,%esp
f0100834:	0f be c0             	movsbl %al,%eax
f0100837:	50                   	push   %eax
f0100838:	68 72 1d 10 f0       	push   $0xf0101d72
f010083d:	e8 58 0d 00 00       	call   f010159a <strchr>
f0100842:	83 c4 10             	add    $0x10,%esp
f0100845:	85 c0                	test   %eax,%eax
f0100847:	74 de                	je     f0100827 <monitor+0x96>
f0100849:	eb 94                	jmp    f01007df <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f010084b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100852:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100853:	85 f6                	test   %esi,%esi
f0100855:	0f 84 58 ff ff ff    	je     f01007b3 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010085b:	83 ec 08             	sub    $0x8,%esp
f010085e:	68 3e 1d 10 f0       	push   $0xf0101d3e
f0100863:	ff 75 a8             	pushl  -0x58(%ebp)
f0100866:	e8 d1 0c 00 00       	call   f010153c <strcmp>
f010086b:	83 c4 10             	add    $0x10,%esp
f010086e:	85 c0                	test   %eax,%eax
f0100870:	74 1e                	je     f0100890 <monitor+0xff>
f0100872:	83 ec 08             	sub    $0x8,%esp
f0100875:	68 4c 1d 10 f0       	push   $0xf0101d4c
f010087a:	ff 75 a8             	pushl  -0x58(%ebp)
f010087d:	e8 ba 0c 00 00       	call   f010153c <strcmp>
f0100882:	83 c4 10             	add    $0x10,%esp
f0100885:	85 c0                	test   %eax,%eax
f0100887:	75 2f                	jne    f01008b8 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100889:	b8 01 00 00 00       	mov    $0x1,%eax
f010088e:	eb 05                	jmp    f0100895 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100890:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100895:	83 ec 04             	sub    $0x4,%esp
f0100898:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010089b:	01 d0                	add    %edx,%eax
f010089d:	ff 75 08             	pushl  0x8(%ebp)
f01008a0:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008a3:	51                   	push   %ecx
f01008a4:	56                   	push   %esi
f01008a5:	ff 14 85 48 1f 10 f0 	call   *-0xfefe0b8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008ac:	83 c4 10             	add    $0x10,%esp
f01008af:	85 c0                	test   %eax,%eax
f01008b1:	78 1d                	js     f01008d0 <monitor+0x13f>
f01008b3:	e9 fb fe ff ff       	jmp    f01007b3 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008b8:	83 ec 08             	sub    $0x8,%esp
f01008bb:	ff 75 a8             	pushl  -0x58(%ebp)
f01008be:	68 94 1d 10 f0       	push   $0xf0101d94
f01008c3:	e8 af 01 00 00       	call   f0100a77 <cprintf>
f01008c8:	83 c4 10             	add    $0x10,%esp
f01008cb:	e9 e3 fe ff ff       	jmp    f01007b3 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d3:	5b                   	pop    %ebx
f01008d4:	5e                   	pop    %esi
f01008d5:	5f                   	pop    %edi
f01008d6:	5d                   	pop    %ebp
f01008d7:	c3                   	ret    

f01008d8 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01008d8:	55                   	push   %ebp
f01008d9:	89 e5                	mov    %esp,%ebp
f01008db:	56                   	push   %esi
f01008dc:	53                   	push   %ebx
f01008dd:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01008df:	83 ec 0c             	sub    $0xc,%esp
f01008e2:	50                   	push   %eax
f01008e3:	e8 28 01 00 00       	call   f0100a10 <mc146818_read>
f01008e8:	89 c6                	mov    %eax,%esi
f01008ea:	83 c3 01             	add    $0x1,%ebx
f01008ed:	89 1c 24             	mov    %ebx,(%esp)
f01008f0:	e8 1b 01 00 00       	call   f0100a10 <mc146818_read>
f01008f5:	c1 e0 08             	shl    $0x8,%eax
f01008f8:	09 f0                	or     %esi,%eax
}
f01008fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008fd:	5b                   	pop    %ebx
f01008fe:	5e                   	pop    %esi
f01008ff:	5d                   	pop    %ebp
f0100900:	c3                   	ret    

f0100901 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100901:	55                   	push   %ebp
f0100902:	89 e5                	mov    %esp,%ebp
f0100904:	56                   	push   %esi
f0100905:	53                   	push   %ebx
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100906:	b8 15 00 00 00       	mov    $0x15,%eax
f010090b:	e8 c8 ff ff ff       	call   f01008d8 <nvram_read>
f0100910:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100912:	b8 17 00 00 00       	mov    $0x17,%eax
f0100917:	e8 bc ff ff ff       	call   f01008d8 <nvram_read>
f010091c:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010091e:	b8 34 00 00 00       	mov    $0x34,%eax
f0100923:	e8 b0 ff ff ff       	call   f01008d8 <nvram_read>
f0100928:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010092b:	85 c0                	test   %eax,%eax
f010092d:	74 07                	je     f0100936 <mem_init+0x35>
		totalmem = 16 * 1024 + ext16mem;
f010092f:	05 00 40 00 00       	add    $0x4000,%eax
f0100934:	eb 0b                	jmp    f0100941 <mem_init+0x40>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0100936:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010093c:	85 f6                	test   %esi,%esi
f010093e:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100941:	89 c2                	mov    %eax,%edx
f0100943:	c1 ea 02             	shr    $0x2,%edx
f0100946:	89 15 44 29 11 f0    	mov    %edx,0xf0112944
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010094c:	89 c2                	mov    %eax,%edx
f010094e:	29 da                	sub    %ebx,%edx
f0100950:	52                   	push   %edx
f0100951:	53                   	push   %ebx
f0100952:	50                   	push   %eax
f0100953:	68 58 1f 10 f0       	push   $0xf0101f58
f0100958:	e8 1a 01 00 00       	call   f0100a77 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f010095d:	83 c4 0c             	add    $0xc,%esp
f0100960:	68 94 1f 10 f0       	push   $0xf0101f94
f0100965:	68 86 00 00 00       	push   $0x86
f010096a:	68 c0 1f 10 f0       	push   $0xf0101fc0
f010096f:	e8 17 f7 ff ff       	call   f010008b <_panic>

f0100974 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100974:	55                   	push   %ebp
f0100975:	89 e5                	mov    %esp,%ebp
f0100977:	53                   	push   %ebx
f0100978:	8b 1d 38 25 11 f0    	mov    0xf0112538,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010097e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100983:	b8 00 00 00 00       	mov    $0x0,%eax
f0100988:	eb 27                	jmp    f01009b1 <page_init+0x3d>
f010098a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100991:	89 d1                	mov    %edx,%ecx
f0100993:	03 0d 4c 29 11 f0    	add    0xf011294c,%ecx
f0100999:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010099f:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01009a1:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f01009a4:	89 d3                	mov    %edx,%ebx
f01009a6:	03 1d 4c 29 11 f0    	add    0xf011294c,%ebx
f01009ac:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01009b1:	3b 05 44 29 11 f0    	cmp    0xf0112944,%eax
f01009b7:	72 d1                	jb     f010098a <page_init+0x16>
f01009b9:	84 d2                	test   %dl,%dl
f01009bb:	74 06                	je     f01009c3 <page_init+0x4f>
f01009bd:	89 1d 38 25 11 f0    	mov    %ebx,0xf0112538
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01009c3:	5b                   	pop    %ebx
f01009c4:	5d                   	pop    %ebp
f01009c5:	c3                   	ret    

f01009c6 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01009c6:	55                   	push   %ebp
f01009c7:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f01009c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ce:	5d                   	pop    %ebp
f01009cf:	c3                   	ret    

f01009d0 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01009d0:	55                   	push   %ebp
f01009d1:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f01009d3:	5d                   	pop    %ebp
f01009d4:	c3                   	ret    

f01009d5 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01009d5:	55                   	push   %ebp
f01009d6:	89 e5                	mov    %esp,%ebp
f01009d8:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01009db:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f01009e0:	5d                   	pop    %ebp
f01009e1:	c3                   	ret    

f01009e2 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01009e2:	55                   	push   %ebp
f01009e3:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f01009e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ea:	5d                   	pop    %ebp
f01009eb:	c3                   	ret    

f01009ec <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01009ec:	55                   	push   %ebp
f01009ed:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f01009ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01009f4:	5d                   	pop    %ebp
f01009f5:	c3                   	ret    

f01009f6 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01009f6:	55                   	push   %ebp
f01009f7:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f01009f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009fe:	5d                   	pop    %ebp
f01009ff:	c3                   	ret    

f0100a00 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100a00:	55                   	push   %ebp
f0100a01:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100a03:	5d                   	pop    %ebp
f0100a04:	c3                   	ret    

f0100a05 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100a05:	55                   	push   %ebp
f0100a06:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100a08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a0b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100a0e:	5d                   	pop    %ebp
f0100a0f:	c3                   	ret    

f0100a10 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100a13:	ba 70 00 00 00       	mov    $0x70,%edx
f0100a18:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a1b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100a1c:	ba 71 00 00 00       	mov    $0x71,%edx
f0100a21:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100a22:	0f b6 c0             	movzbl %al,%eax
}
f0100a25:	5d                   	pop    %ebp
f0100a26:	c3                   	ret    

f0100a27 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100a27:	55                   	push   %ebp
f0100a28:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100a2a:	ba 70 00 00 00       	mov    $0x70,%edx
f0100a2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a32:	ee                   	out    %al,(%dx)
f0100a33:	ba 71 00 00 00       	mov    $0x71,%edx
f0100a38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a3b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100a3c:	5d                   	pop    %ebp
f0100a3d:	c3                   	ret    

f0100a3e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a3e:	55                   	push   %ebp
f0100a3f:	89 e5                	mov    %esp,%ebp
f0100a41:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100a44:	ff 75 08             	pushl  0x8(%ebp)
f0100a47:	e8 b4 fb ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f0100a4c:	83 c4 10             	add    $0x10,%esp
f0100a4f:	c9                   	leave  
f0100a50:	c3                   	ret    

f0100a51 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a51:	55                   	push   %ebp
f0100a52:	89 e5                	mov    %esp,%ebp
f0100a54:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100a57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a5e:	ff 75 0c             	pushl  0xc(%ebp)
f0100a61:	ff 75 08             	pushl  0x8(%ebp)
f0100a64:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a67:	50                   	push   %eax
f0100a68:	68 3e 0a 10 f0       	push   $0xf0100a3e
f0100a6d:	e8 18 04 00 00       	call   f0100e8a <vprintfmt>
	return cnt;
}
f0100a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a75:	c9                   	leave  
f0100a76:	c3                   	ret    

f0100a77 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a77:	55                   	push   %ebp
f0100a78:	89 e5                	mov    %esp,%ebp
f0100a7a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a7d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a80:	50                   	push   %eax
f0100a81:	ff 75 08             	pushl  0x8(%ebp)
f0100a84:	e8 c8 ff ff ff       	call   f0100a51 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a89:	c9                   	leave  
f0100a8a:	c3                   	ret    

f0100a8b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a8b:	55                   	push   %ebp
f0100a8c:	89 e5                	mov    %esp,%ebp
f0100a8e:	57                   	push   %edi
f0100a8f:	56                   	push   %esi
f0100a90:	53                   	push   %ebx
f0100a91:	83 ec 14             	sub    $0x14,%esp
f0100a94:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a9a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100aa0:	8b 1a                	mov    (%edx),%ebx
f0100aa2:	8b 01                	mov    (%ecx),%eax
f0100aa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100aa7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100aae:	eb 7f                	jmp    f0100b2f <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ab3:	01 d8                	add    %ebx,%eax
f0100ab5:	89 c6                	mov    %eax,%esi
f0100ab7:	c1 ee 1f             	shr    $0x1f,%esi
f0100aba:	01 c6                	add    %eax,%esi
f0100abc:	d1 fe                	sar    %esi
f0100abe:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100ac1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ac4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100ac7:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ac9:	eb 03                	jmp    f0100ace <stab_binsearch+0x43>
			m--;
f0100acb:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ace:	39 c3                	cmp    %eax,%ebx
f0100ad0:	7f 0d                	jg     f0100adf <stab_binsearch+0x54>
f0100ad2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100ad6:	83 ea 0c             	sub    $0xc,%edx
f0100ad9:	39 f9                	cmp    %edi,%ecx
f0100adb:	75 ee                	jne    f0100acb <stab_binsearch+0x40>
f0100add:	eb 05                	jmp    f0100ae4 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100adf:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100ae2:	eb 4b                	jmp    f0100b2f <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100ae4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ae7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100aea:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100aee:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100af1:	76 11                	jbe    f0100b04 <stab_binsearch+0x79>
			*region_left = m;
f0100af3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100af6:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100af8:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100afb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b02:	eb 2b                	jmp    f0100b2f <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100b04:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100b07:	73 14                	jae    f0100b1d <stab_binsearch+0x92>
			*region_right = m - 1;
f0100b09:	83 e8 01             	sub    $0x1,%eax
f0100b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100b12:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b14:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b1b:	eb 12                	jmp    f0100b2f <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b1d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b20:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100b22:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b26:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b28:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100b2f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b32:	0f 8e 78 ff ff ff    	jle    f0100ab0 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100b38:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b3c:	75 0f                	jne    f0100b4d <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100b3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b41:	8b 00                	mov    (%eax),%eax
f0100b43:	83 e8 01             	sub    $0x1,%eax
f0100b46:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100b49:	89 06                	mov    %eax,(%esi)
f0100b4b:	eb 2c                	jmp    f0100b79 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b50:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b52:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b55:	8b 0e                	mov    (%esi),%ecx
f0100b57:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b5a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100b5d:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b60:	eb 03                	jmp    f0100b65 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100b62:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b65:	39 c8                	cmp    %ecx,%eax
f0100b67:	7e 0b                	jle    f0100b74 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100b69:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100b6d:	83 ea 0c             	sub    $0xc,%edx
f0100b70:	39 df                	cmp    %ebx,%edi
f0100b72:	75 ee                	jne    f0100b62 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b74:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b77:	89 06                	mov    %eax,(%esi)
	}
}
f0100b79:	83 c4 14             	add    $0x14,%esp
f0100b7c:	5b                   	pop    %ebx
f0100b7d:	5e                   	pop    %esi
f0100b7e:	5f                   	pop    %edi
f0100b7f:	5d                   	pop    %ebp
f0100b80:	c3                   	ret    

f0100b81 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b81:	55                   	push   %ebp
f0100b82:	89 e5                	mov    %esp,%ebp
f0100b84:	57                   	push   %edi
f0100b85:	56                   	push   %esi
f0100b86:	53                   	push   %ebx
f0100b87:	83 ec 3c             	sub    $0x3c,%esp
f0100b8a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b90:	c7 03 cc 1f 10 f0    	movl   $0xf0101fcc,(%ebx)
	info->eip_line = 0;
f0100b96:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b9d:	c7 43 08 cc 1f 10 f0 	movl   $0xf0101fcc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100ba4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100bab:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100bae:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100bb5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100bbb:	76 11                	jbe    f0100bce <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bbd:	b8 2e 7f 10 f0       	mov    $0xf0107f2e,%eax
f0100bc2:	3d 5d 63 10 f0       	cmp    $0xf010635d,%eax
f0100bc7:	77 19                	ja     f0100be2 <debuginfo_eip+0x61>
f0100bc9:	e9 aa 01 00 00       	jmp    f0100d78 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100bce:	83 ec 04             	sub    $0x4,%esp
f0100bd1:	68 d6 1f 10 f0       	push   $0xf0101fd6
f0100bd6:	6a 7f                	push   $0x7f
f0100bd8:	68 e3 1f 10 f0       	push   $0xf0101fe3
f0100bdd:	e8 a9 f4 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100be2:	80 3d 2d 7f 10 f0 00 	cmpb   $0x0,0xf0107f2d
f0100be9:	0f 85 90 01 00 00    	jne    f0100d7f <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bf6:	b8 5c 63 10 f0       	mov    $0xf010635c,%eax
f0100bfb:	2d 04 22 10 f0       	sub    $0xf0102204,%eax
f0100c00:	c1 f8 02             	sar    $0x2,%eax
f0100c03:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100c09:	83 e8 01             	sub    $0x1,%eax
f0100c0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c0f:	83 ec 08             	sub    $0x8,%esp
f0100c12:	56                   	push   %esi
f0100c13:	6a 64                	push   $0x64
f0100c15:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c18:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c1b:	b8 04 22 10 f0       	mov    $0xf0102204,%eax
f0100c20:	e8 66 fe ff ff       	call   f0100a8b <stab_binsearch>
	if (lfile == 0)
f0100c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c28:	83 c4 10             	add    $0x10,%esp
f0100c2b:	85 c0                	test   %eax,%eax
f0100c2d:	0f 84 53 01 00 00    	je     f0100d86 <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c33:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c36:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c39:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c3c:	83 ec 08             	sub    $0x8,%esp
f0100c3f:	56                   	push   %esi
f0100c40:	6a 24                	push   $0x24
f0100c42:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c45:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c48:	b8 04 22 10 f0       	mov    $0xf0102204,%eax
f0100c4d:	e8 39 fe ff ff       	call   f0100a8b <stab_binsearch>

	if (lfun <= rfun) {
f0100c52:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c55:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c58:	83 c4 10             	add    $0x10,%esp
f0100c5b:	39 d0                	cmp    %edx,%eax
f0100c5d:	7f 40                	jg     f0100c9f <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c5f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100c62:	c1 e1 02             	shl    $0x2,%ecx
f0100c65:	8d b9 04 22 10 f0    	lea    -0xfefddfc(%ecx),%edi
f0100c6b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100c6e:	8b b9 04 22 10 f0    	mov    -0xfefddfc(%ecx),%edi
f0100c74:	b9 2e 7f 10 f0       	mov    $0xf0107f2e,%ecx
f0100c79:	81 e9 5d 63 10 f0    	sub    $0xf010635d,%ecx
f0100c7f:	39 cf                	cmp    %ecx,%edi
f0100c81:	73 09                	jae    f0100c8c <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c83:	81 c7 5d 63 10 f0    	add    $0xf010635d,%edi
f0100c89:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c8c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c8f:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100c92:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c95:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c97:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c9a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c9d:	eb 0f                	jmp    f0100cae <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c9f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100ca2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100ca8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cab:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100cae:	83 ec 08             	sub    $0x8,%esp
f0100cb1:	6a 3a                	push   $0x3a
f0100cb3:	ff 73 08             	pushl  0x8(%ebx)
f0100cb6:	e8 00 09 00 00       	call   f01015bb <strfind>
f0100cbb:	2b 43 08             	sub    0x8(%ebx),%eax
f0100cbe:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100cc1:	83 c4 08             	add    $0x8,%esp
f0100cc4:	56                   	push   %esi
f0100cc5:	6a 44                	push   $0x44
f0100cc7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100cca:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100ccd:	b8 04 22 10 f0       	mov    $0xf0102204,%eax
f0100cd2:	e8 b4 fd ff ff       	call   f0100a8b <stab_binsearch>
	if (lline != rline) return -1;
f0100cd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100cda:	83 c4 10             	add    $0x10,%esp
f0100cdd:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100ce0:	0f 85 a7 00 00 00    	jne    f0100d8d <debuginfo_eip+0x20c>
	info->eip_line = stabs[lline].n_desc;
f0100ce6:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100ce9:	8d 04 85 04 22 10 f0 	lea    -0xfefddfc(,%eax,4),%eax
f0100cf0:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100cf4:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cf7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100cfa:	eb 06                	jmp    f0100d02 <debuginfo_eip+0x181>
f0100cfc:	83 ea 01             	sub    $0x1,%edx
f0100cff:	83 e8 0c             	sub    $0xc,%eax
f0100d02:	39 d6                	cmp    %edx,%esi
f0100d04:	7f 34                	jg     f0100d3a <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100d06:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100d0a:	80 f9 84             	cmp    $0x84,%cl
f0100d0d:	74 0b                	je     f0100d1a <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d0f:	80 f9 64             	cmp    $0x64,%cl
f0100d12:	75 e8                	jne    f0100cfc <debuginfo_eip+0x17b>
f0100d14:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100d18:	74 e2                	je     f0100cfc <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d1a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100d1d:	8b 14 85 04 22 10 f0 	mov    -0xfefddfc(,%eax,4),%edx
f0100d24:	b8 2e 7f 10 f0       	mov    $0xf0107f2e,%eax
f0100d29:	2d 5d 63 10 f0       	sub    $0xf010635d,%eax
f0100d2e:	39 c2                	cmp    %eax,%edx
f0100d30:	73 08                	jae    f0100d3a <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d32:	81 c2 5d 63 10 f0    	add    $0xf010635d,%edx
f0100d38:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d3a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d3d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d40:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d45:	39 f2                	cmp    %esi,%edx
f0100d47:	7d 50                	jge    f0100d99 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100d49:	83 c2 01             	add    $0x1,%edx
f0100d4c:	89 d0                	mov    %edx,%eax
f0100d4e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d51:	8d 14 95 04 22 10 f0 	lea    -0xfefddfc(,%edx,4),%edx
f0100d58:	eb 04                	jmp    f0100d5e <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100d5a:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d5e:	39 c6                	cmp    %eax,%esi
f0100d60:	7e 32                	jle    f0100d94 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d62:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100d66:	83 c0 01             	add    $0x1,%eax
f0100d69:	83 c2 0c             	add    $0xc,%edx
f0100d6c:	80 f9 a0             	cmp    $0xa0,%cl
f0100d6f:	74 e9                	je     f0100d5a <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d71:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d76:	eb 21                	jmp    f0100d99 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d7d:	eb 1a                	jmp    f0100d99 <debuginfo_eip+0x218>
f0100d7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d84:	eb 13                	jmp    f0100d99 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d8b:	eb 0c                	jmp    f0100d99 <debuginfo_eip+0x218>
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline != rline) return -1;
f0100d8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d92:	eb 05                	jmp    f0100d99 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d9c:	5b                   	pop    %ebx
f0100d9d:	5e                   	pop    %esi
f0100d9e:	5f                   	pop    %edi
f0100d9f:	5d                   	pop    %ebp
f0100da0:	c3                   	ret    

f0100da1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100da1:	55                   	push   %ebp
f0100da2:	89 e5                	mov    %esp,%ebp
f0100da4:	57                   	push   %edi
f0100da5:	56                   	push   %esi
f0100da6:	53                   	push   %ebx
f0100da7:	83 ec 1c             	sub    $0x1c,%esp
f0100daa:	89 c7                	mov    %eax,%edi
f0100dac:	89 d6                	mov    %edx,%esi
f0100dae:	8b 45 08             	mov    0x8(%ebp),%eax
f0100db1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100db4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100db7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100dba:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100dc2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100dc5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100dc8:	39 d3                	cmp    %edx,%ebx
f0100dca:	72 05                	jb     f0100dd1 <printnum+0x30>
f0100dcc:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100dcf:	77 45                	ja     f0100e16 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100dd1:	83 ec 0c             	sub    $0xc,%esp
f0100dd4:	ff 75 18             	pushl  0x18(%ebp)
f0100dd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dda:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100ddd:	53                   	push   %ebx
f0100dde:	ff 75 10             	pushl  0x10(%ebp)
f0100de1:	83 ec 08             	sub    $0x8,%esp
f0100de4:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100de7:	ff 75 e0             	pushl  -0x20(%ebp)
f0100dea:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ded:	ff 75 d8             	pushl  -0x28(%ebp)
f0100df0:	e8 eb 09 00 00       	call   f01017e0 <__udivdi3>
f0100df5:	83 c4 18             	add    $0x18,%esp
f0100df8:	52                   	push   %edx
f0100df9:	50                   	push   %eax
f0100dfa:	89 f2                	mov    %esi,%edx
f0100dfc:	89 f8                	mov    %edi,%eax
f0100dfe:	e8 9e ff ff ff       	call   f0100da1 <printnum>
f0100e03:	83 c4 20             	add    $0x20,%esp
f0100e06:	eb 18                	jmp    f0100e20 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e08:	83 ec 08             	sub    $0x8,%esp
f0100e0b:	56                   	push   %esi
f0100e0c:	ff 75 18             	pushl  0x18(%ebp)
f0100e0f:	ff d7                	call   *%edi
f0100e11:	83 c4 10             	add    $0x10,%esp
f0100e14:	eb 03                	jmp    f0100e19 <printnum+0x78>
f0100e16:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e19:	83 eb 01             	sub    $0x1,%ebx
f0100e1c:	85 db                	test   %ebx,%ebx
f0100e1e:	7f e8                	jg     f0100e08 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e20:	83 ec 08             	sub    $0x8,%esp
f0100e23:	56                   	push   %esi
f0100e24:	83 ec 04             	sub    $0x4,%esp
f0100e27:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e2a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e2d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100e30:	ff 75 d8             	pushl  -0x28(%ebp)
f0100e33:	e8 d8 0a 00 00       	call   f0101910 <__umoddi3>
f0100e38:	83 c4 14             	add    $0x14,%esp
f0100e3b:	0f be 80 f1 1f 10 f0 	movsbl -0xfefe00f(%eax),%eax
f0100e42:	50                   	push   %eax
f0100e43:	ff d7                	call   *%edi
}
f0100e45:	83 c4 10             	add    $0x10,%esp
f0100e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e4b:	5b                   	pop    %ebx
f0100e4c:	5e                   	pop    %esi
f0100e4d:	5f                   	pop    %edi
f0100e4e:	5d                   	pop    %ebp
f0100e4f:	c3                   	ret    

f0100e50 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e50:	55                   	push   %ebp
f0100e51:	89 e5                	mov    %esp,%ebp
f0100e53:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e56:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e5a:	8b 10                	mov    (%eax),%edx
f0100e5c:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e5f:	73 0a                	jae    f0100e6b <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e61:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e64:	89 08                	mov    %ecx,(%eax)
f0100e66:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e69:	88 02                	mov    %al,(%edx)
}
f0100e6b:	5d                   	pop    %ebp
f0100e6c:	c3                   	ret    

f0100e6d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100e6d:	55                   	push   %ebp
f0100e6e:	89 e5                	mov    %esp,%ebp
f0100e70:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e73:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e76:	50                   	push   %eax
f0100e77:	ff 75 10             	pushl  0x10(%ebp)
f0100e7a:	ff 75 0c             	pushl  0xc(%ebp)
f0100e7d:	ff 75 08             	pushl  0x8(%ebp)
f0100e80:	e8 05 00 00 00       	call   f0100e8a <vprintfmt>
	va_end(ap);
}
f0100e85:	83 c4 10             	add    $0x10,%esp
f0100e88:	c9                   	leave  
f0100e89:	c3                   	ret    

f0100e8a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e8a:	55                   	push   %ebp
f0100e8b:	89 e5                	mov    %esp,%ebp
f0100e8d:	57                   	push   %edi
f0100e8e:	56                   	push   %esi
f0100e8f:	53                   	push   %ebx
f0100e90:	83 ec 2c             	sub    $0x2c,%esp
f0100e93:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e99:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e9c:	eb 12                	jmp    f0100eb0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e9e:	85 c0                	test   %eax,%eax
f0100ea0:	0f 84 6a 04 00 00    	je     f0101310 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
f0100ea6:	83 ec 08             	sub    $0x8,%esp
f0100ea9:	53                   	push   %ebx
f0100eaa:	50                   	push   %eax
f0100eab:	ff d6                	call   *%esi
f0100ead:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100eb0:	83 c7 01             	add    $0x1,%edi
f0100eb3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100eb7:	83 f8 25             	cmp    $0x25,%eax
f0100eba:	75 e2                	jne    f0100e9e <vprintfmt+0x14>
f0100ebc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100ec0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100ec7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ece:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100ed5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100eda:	eb 07                	jmp    f0100ee3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100edc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100edf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee3:	8d 47 01             	lea    0x1(%edi),%eax
f0100ee6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ee9:	0f b6 07             	movzbl (%edi),%eax
f0100eec:	0f b6 d0             	movzbl %al,%edx
f0100eef:	83 e8 23             	sub    $0x23,%eax
f0100ef2:	3c 55                	cmp    $0x55,%al
f0100ef4:	0f 87 fb 03 00 00    	ja     f01012f5 <vprintfmt+0x46b>
f0100efa:	0f b6 c0             	movzbl %al,%eax
f0100efd:	ff 24 85 80 20 10 f0 	jmp    *-0xfefdf80(,%eax,4)
f0100f04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100f07:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100f0b:	eb d6                	jmp    f0100ee3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f15:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100f18:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100f1b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100f1f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100f22:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100f25:	83 f9 09             	cmp    $0x9,%ecx
f0100f28:	77 3f                	ja     f0100f69 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100f2a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100f2d:	eb e9                	jmp    f0100f18 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100f2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f32:	8b 00                	mov    (%eax),%eax
f0100f34:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f37:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3a:	8d 40 04             	lea    0x4(%eax),%eax
f0100f3d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100f43:	eb 2a                	jmp    f0100f6f <vprintfmt+0xe5>
f0100f45:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f48:	85 c0                	test   %eax,%eax
f0100f4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f4f:	0f 49 d0             	cmovns %eax,%edx
f0100f52:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f58:	eb 89                	jmp    f0100ee3 <vprintfmt+0x59>
f0100f5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f5d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100f64:	e9 7a ff ff ff       	jmp    f0100ee3 <vprintfmt+0x59>
f0100f69:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100f6c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100f6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f73:	0f 89 6a ff ff ff    	jns    f0100ee3 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f7f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f86:	e9 58 ff ff ff       	jmp    f0100ee3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f8b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f91:	e9 4d ff ff ff       	jmp    f0100ee3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f96:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f99:	8d 78 04             	lea    0x4(%eax),%edi
f0100f9c:	83 ec 08             	sub    $0x8,%esp
f0100f9f:	53                   	push   %ebx
f0100fa0:	ff 30                	pushl  (%eax)
f0100fa2:	ff d6                	call   *%esi
			break;
f0100fa4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100fa7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100faa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100fad:	e9 fe fe ff ff       	jmp    f0100eb0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100fb2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fb5:	8d 78 04             	lea    0x4(%eax),%edi
f0100fb8:	8b 00                	mov    (%eax),%eax
f0100fba:	99                   	cltd   
f0100fbb:	31 d0                	xor    %edx,%eax
f0100fbd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100fbf:	83 f8 06             	cmp    $0x6,%eax
f0100fc2:	7f 0b                	jg     f0100fcf <vprintfmt+0x145>
f0100fc4:	8b 14 85 d8 21 10 f0 	mov    -0xfefde28(,%eax,4),%edx
f0100fcb:	85 d2                	test   %edx,%edx
f0100fcd:	75 1b                	jne    f0100fea <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0100fcf:	50                   	push   %eax
f0100fd0:	68 09 20 10 f0       	push   $0xf0102009
f0100fd5:	53                   	push   %ebx
f0100fd6:	56                   	push   %esi
f0100fd7:	e8 91 fe ff ff       	call   f0100e6d <printfmt>
f0100fdc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100fdf:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fe2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100fe5:	e9 c6 fe ff ff       	jmp    f0100eb0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100fea:	52                   	push   %edx
f0100feb:	68 12 20 10 f0       	push   $0xf0102012
f0100ff0:	53                   	push   %ebx
f0100ff1:	56                   	push   %esi
f0100ff2:	e8 76 fe ff ff       	call   f0100e6d <printfmt>
f0100ff7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ffa:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ffd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101000:	e9 ab fe ff ff       	jmp    f0100eb0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101005:	8b 45 14             	mov    0x14(%ebp),%eax
f0101008:	83 c0 04             	add    $0x4,%eax
f010100b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010100e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101011:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101013:	85 ff                	test   %edi,%edi
f0101015:	b8 02 20 10 f0       	mov    $0xf0102002,%eax
f010101a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010101d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101021:	0f 8e 94 00 00 00    	jle    f01010bb <vprintfmt+0x231>
f0101027:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010102b:	0f 84 98 00 00 00    	je     f01010c9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101031:	83 ec 08             	sub    $0x8,%esp
f0101034:	ff 75 d0             	pushl  -0x30(%ebp)
f0101037:	57                   	push   %edi
f0101038:	e8 34 04 00 00       	call   f0101471 <strnlen>
f010103d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101040:	29 c1                	sub    %eax,%ecx
f0101042:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101045:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101048:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010104c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010104f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101052:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101054:	eb 0f                	jmp    f0101065 <vprintfmt+0x1db>
					putch(padc, putdat);
f0101056:	83 ec 08             	sub    $0x8,%esp
f0101059:	53                   	push   %ebx
f010105a:	ff 75 e0             	pushl  -0x20(%ebp)
f010105d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010105f:	83 ef 01             	sub    $0x1,%edi
f0101062:	83 c4 10             	add    $0x10,%esp
f0101065:	85 ff                	test   %edi,%edi
f0101067:	7f ed                	jg     f0101056 <vprintfmt+0x1cc>
f0101069:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010106c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010106f:	85 c9                	test   %ecx,%ecx
f0101071:	b8 00 00 00 00       	mov    $0x0,%eax
f0101076:	0f 49 c1             	cmovns %ecx,%eax
f0101079:	29 c1                	sub    %eax,%ecx
f010107b:	89 75 08             	mov    %esi,0x8(%ebp)
f010107e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101081:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101084:	89 cb                	mov    %ecx,%ebx
f0101086:	eb 4d                	jmp    f01010d5 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101088:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010108c:	74 1b                	je     f01010a9 <vprintfmt+0x21f>
f010108e:	0f be c0             	movsbl %al,%eax
f0101091:	83 e8 20             	sub    $0x20,%eax
f0101094:	83 f8 5e             	cmp    $0x5e,%eax
f0101097:	76 10                	jbe    f01010a9 <vprintfmt+0x21f>
					putch('?', putdat);
f0101099:	83 ec 08             	sub    $0x8,%esp
f010109c:	ff 75 0c             	pushl  0xc(%ebp)
f010109f:	6a 3f                	push   $0x3f
f01010a1:	ff 55 08             	call   *0x8(%ebp)
f01010a4:	83 c4 10             	add    $0x10,%esp
f01010a7:	eb 0d                	jmp    f01010b6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f01010a9:	83 ec 08             	sub    $0x8,%esp
f01010ac:	ff 75 0c             	pushl  0xc(%ebp)
f01010af:	52                   	push   %edx
f01010b0:	ff 55 08             	call   *0x8(%ebp)
f01010b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010b6:	83 eb 01             	sub    $0x1,%ebx
f01010b9:	eb 1a                	jmp    f01010d5 <vprintfmt+0x24b>
f01010bb:	89 75 08             	mov    %esi,0x8(%ebp)
f01010be:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01010c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01010c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01010c7:	eb 0c                	jmp    f01010d5 <vprintfmt+0x24b>
f01010c9:	89 75 08             	mov    %esi,0x8(%ebp)
f01010cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01010cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01010d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01010d5:	83 c7 01             	add    $0x1,%edi
f01010d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01010dc:	0f be d0             	movsbl %al,%edx
f01010df:	85 d2                	test   %edx,%edx
f01010e1:	74 23                	je     f0101106 <vprintfmt+0x27c>
f01010e3:	85 f6                	test   %esi,%esi
f01010e5:	78 a1                	js     f0101088 <vprintfmt+0x1fe>
f01010e7:	83 ee 01             	sub    $0x1,%esi
f01010ea:	79 9c                	jns    f0101088 <vprintfmt+0x1fe>
f01010ec:	89 df                	mov    %ebx,%edi
f01010ee:	8b 75 08             	mov    0x8(%ebp),%esi
f01010f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010f4:	eb 18                	jmp    f010110e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01010f6:	83 ec 08             	sub    $0x8,%esp
f01010f9:	53                   	push   %ebx
f01010fa:	6a 20                	push   $0x20
f01010fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010fe:	83 ef 01             	sub    $0x1,%edi
f0101101:	83 c4 10             	add    $0x10,%esp
f0101104:	eb 08                	jmp    f010110e <vprintfmt+0x284>
f0101106:	89 df                	mov    %ebx,%edi
f0101108:	8b 75 08             	mov    0x8(%ebp),%esi
f010110b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010110e:	85 ff                	test   %edi,%edi
f0101110:	7f e4                	jg     f01010f6 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101112:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101115:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101118:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010111b:	e9 90 fd ff ff       	jmp    f0100eb0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101120:	83 f9 01             	cmp    $0x1,%ecx
f0101123:	7e 19                	jle    f010113e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0101125:	8b 45 14             	mov    0x14(%ebp),%eax
f0101128:	8b 50 04             	mov    0x4(%eax),%edx
f010112b:	8b 00                	mov    (%eax),%eax
f010112d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101130:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101133:	8b 45 14             	mov    0x14(%ebp),%eax
f0101136:	8d 40 08             	lea    0x8(%eax),%eax
f0101139:	89 45 14             	mov    %eax,0x14(%ebp)
f010113c:	eb 38                	jmp    f0101176 <vprintfmt+0x2ec>
	else if (lflag)
f010113e:	85 c9                	test   %ecx,%ecx
f0101140:	74 1b                	je     f010115d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0101142:	8b 45 14             	mov    0x14(%ebp),%eax
f0101145:	8b 00                	mov    (%eax),%eax
f0101147:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010114a:	89 c1                	mov    %eax,%ecx
f010114c:	c1 f9 1f             	sar    $0x1f,%ecx
f010114f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101152:	8b 45 14             	mov    0x14(%ebp),%eax
f0101155:	8d 40 04             	lea    0x4(%eax),%eax
f0101158:	89 45 14             	mov    %eax,0x14(%ebp)
f010115b:	eb 19                	jmp    f0101176 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f010115d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101160:	8b 00                	mov    (%eax),%eax
f0101162:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101165:	89 c1                	mov    %eax,%ecx
f0101167:	c1 f9 1f             	sar    $0x1f,%ecx
f010116a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010116d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101170:	8d 40 04             	lea    0x4(%eax),%eax
f0101173:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101176:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101179:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010117c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101181:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101185:	0f 89 36 01 00 00    	jns    f01012c1 <vprintfmt+0x437>
				putch('-', putdat);
f010118b:	83 ec 08             	sub    $0x8,%esp
f010118e:	53                   	push   %ebx
f010118f:	6a 2d                	push   $0x2d
f0101191:	ff d6                	call   *%esi
				num = -(long long) num;
f0101193:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101196:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101199:	f7 da                	neg    %edx
f010119b:	83 d1 00             	adc    $0x0,%ecx
f010119e:	f7 d9                	neg    %ecx
f01011a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01011a3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01011a8:	e9 14 01 00 00       	jmp    f01012c1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01011ad:	83 f9 01             	cmp    $0x1,%ecx
f01011b0:	7e 18                	jle    f01011ca <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f01011b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b5:	8b 10                	mov    (%eax),%edx
f01011b7:	8b 48 04             	mov    0x4(%eax),%ecx
f01011ba:	8d 40 08             	lea    0x8(%eax),%eax
f01011bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01011c0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01011c5:	e9 f7 00 00 00       	jmp    f01012c1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01011ca:	85 c9                	test   %ecx,%ecx
f01011cc:	74 1a                	je     f01011e8 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f01011ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d1:	8b 10                	mov    (%eax),%edx
f01011d3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011d8:	8d 40 04             	lea    0x4(%eax),%eax
f01011db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01011de:	b8 0a 00 00 00       	mov    $0xa,%eax
f01011e3:	e9 d9 00 00 00       	jmp    f01012c1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01011e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011eb:	8b 10                	mov    (%eax),%edx
f01011ed:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011f2:	8d 40 04             	lea    0x4(%eax),%eax
f01011f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01011f8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01011fd:	e9 bf 00 00 00       	jmp    f01012c1 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101202:	83 f9 01             	cmp    $0x1,%ecx
f0101205:	7e 13                	jle    f010121a <vprintfmt+0x390>
		return va_arg(*ap, long long);
f0101207:	8b 45 14             	mov    0x14(%ebp),%eax
f010120a:	8b 50 04             	mov    0x4(%eax),%edx
f010120d:	8b 00                	mov    (%eax),%eax
f010120f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101212:	8d 49 08             	lea    0x8(%ecx),%ecx
f0101215:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101218:	eb 28                	jmp    f0101242 <vprintfmt+0x3b8>
	else if (lflag)
f010121a:	85 c9                	test   %ecx,%ecx
f010121c:	74 13                	je     f0101231 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
f010121e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101221:	8b 10                	mov    (%eax),%edx
f0101223:	89 d0                	mov    %edx,%eax
f0101225:	99                   	cltd   
f0101226:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101229:	8d 49 04             	lea    0x4(%ecx),%ecx
f010122c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010122f:	eb 11                	jmp    f0101242 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
f0101231:	8b 45 14             	mov    0x14(%ebp),%eax
f0101234:	8b 10                	mov    (%eax),%edx
f0101236:	89 d0                	mov    %edx,%eax
f0101238:	99                   	cltd   
f0101239:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010123c:	8d 49 04             	lea    0x4(%ecx),%ecx
f010123f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
f0101242:	89 d1                	mov    %edx,%ecx
f0101244:	89 c2                	mov    %eax,%edx
			base = 8;
f0101246:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f010124b:	eb 74                	jmp    f01012c1 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010124d:	83 ec 08             	sub    $0x8,%esp
f0101250:	53                   	push   %ebx
f0101251:	6a 30                	push   $0x30
f0101253:	ff d6                	call   *%esi
			putch('x', putdat);
f0101255:	83 c4 08             	add    $0x8,%esp
f0101258:	53                   	push   %ebx
f0101259:	6a 78                	push   $0x78
f010125b:	ff d6                	call   *%esi
			num = (unsigned long long)
f010125d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101260:	8b 10                	mov    (%eax),%edx
f0101262:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101267:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010126a:	8d 40 04             	lea    0x4(%eax),%eax
f010126d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101270:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0101275:	eb 4a                	jmp    f01012c1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101277:	83 f9 01             	cmp    $0x1,%ecx
f010127a:	7e 15                	jle    f0101291 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
f010127c:	8b 45 14             	mov    0x14(%ebp),%eax
f010127f:	8b 10                	mov    (%eax),%edx
f0101281:	8b 48 04             	mov    0x4(%eax),%ecx
f0101284:	8d 40 08             	lea    0x8(%eax),%eax
f0101287:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010128a:	b8 10 00 00 00       	mov    $0x10,%eax
f010128f:	eb 30                	jmp    f01012c1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0101291:	85 c9                	test   %ecx,%ecx
f0101293:	74 17                	je     f01012ac <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
f0101295:	8b 45 14             	mov    0x14(%ebp),%eax
f0101298:	8b 10                	mov    (%eax),%edx
f010129a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010129f:	8d 40 04             	lea    0x4(%eax),%eax
f01012a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01012a5:	b8 10 00 00 00       	mov    $0x10,%eax
f01012aa:	eb 15                	jmp    f01012c1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01012ac:	8b 45 14             	mov    0x14(%ebp),%eax
f01012af:	8b 10                	mov    (%eax),%edx
f01012b1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012b6:	8d 40 04             	lea    0x4(%eax),%eax
f01012b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01012bc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01012c1:	83 ec 0c             	sub    $0xc,%esp
f01012c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01012c8:	57                   	push   %edi
f01012c9:	ff 75 e0             	pushl  -0x20(%ebp)
f01012cc:	50                   	push   %eax
f01012cd:	51                   	push   %ecx
f01012ce:	52                   	push   %edx
f01012cf:	89 da                	mov    %ebx,%edx
f01012d1:	89 f0                	mov    %esi,%eax
f01012d3:	e8 c9 fa ff ff       	call   f0100da1 <printnum>
			break;
f01012d8:	83 c4 20             	add    $0x20,%esp
f01012db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01012de:	e9 cd fb ff ff       	jmp    f0100eb0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01012e3:	83 ec 08             	sub    $0x8,%esp
f01012e6:	53                   	push   %ebx
f01012e7:	52                   	push   %edx
f01012e8:	ff d6                	call   *%esi
			break;
f01012ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01012f0:	e9 bb fb ff ff       	jmp    f0100eb0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01012f5:	83 ec 08             	sub    $0x8,%esp
f01012f8:	53                   	push   %ebx
f01012f9:	6a 25                	push   $0x25
f01012fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01012fd:	83 c4 10             	add    $0x10,%esp
f0101300:	eb 03                	jmp    f0101305 <vprintfmt+0x47b>
f0101302:	83 ef 01             	sub    $0x1,%edi
f0101305:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101309:	75 f7                	jne    f0101302 <vprintfmt+0x478>
f010130b:	e9 a0 fb ff ff       	jmp    f0100eb0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101310:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101313:	5b                   	pop    %ebx
f0101314:	5e                   	pop    %esi
f0101315:	5f                   	pop    %edi
f0101316:	5d                   	pop    %ebp
f0101317:	c3                   	ret    

f0101318 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101318:	55                   	push   %ebp
f0101319:	89 e5                	mov    %esp,%ebp
f010131b:	83 ec 18             	sub    $0x18,%esp
f010131e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101321:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101324:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101327:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010132b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010132e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101335:	85 c0                	test   %eax,%eax
f0101337:	74 26                	je     f010135f <vsnprintf+0x47>
f0101339:	85 d2                	test   %edx,%edx
f010133b:	7e 22                	jle    f010135f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010133d:	ff 75 14             	pushl  0x14(%ebp)
f0101340:	ff 75 10             	pushl  0x10(%ebp)
f0101343:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101346:	50                   	push   %eax
f0101347:	68 50 0e 10 f0       	push   $0xf0100e50
f010134c:	e8 39 fb ff ff       	call   f0100e8a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101351:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101354:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101357:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010135a:	83 c4 10             	add    $0x10,%esp
f010135d:	eb 05                	jmp    f0101364 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010135f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101364:	c9                   	leave  
f0101365:	c3                   	ret    

f0101366 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101366:	55                   	push   %ebp
f0101367:	89 e5                	mov    %esp,%ebp
f0101369:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010136c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010136f:	50                   	push   %eax
f0101370:	ff 75 10             	pushl  0x10(%ebp)
f0101373:	ff 75 0c             	pushl  0xc(%ebp)
f0101376:	ff 75 08             	pushl  0x8(%ebp)
f0101379:	e8 9a ff ff ff       	call   f0101318 <vsnprintf>
	va_end(ap);

	return rc;
}
f010137e:	c9                   	leave  
f010137f:	c3                   	ret    

f0101380 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101380:	55                   	push   %ebp
f0101381:	89 e5                	mov    %esp,%ebp
f0101383:	57                   	push   %edi
f0101384:	56                   	push   %esi
f0101385:	53                   	push   %ebx
f0101386:	83 ec 0c             	sub    $0xc,%esp
f0101389:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010138c:	85 c0                	test   %eax,%eax
f010138e:	74 11                	je     f01013a1 <readline+0x21>
		cprintf("%s", prompt);
f0101390:	83 ec 08             	sub    $0x8,%esp
f0101393:	50                   	push   %eax
f0101394:	68 12 20 10 f0       	push   $0xf0102012
f0101399:	e8 d9 f6 ff ff       	call   f0100a77 <cprintf>
f010139e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01013a1:	83 ec 0c             	sub    $0xc,%esp
f01013a4:	6a 00                	push   $0x0
f01013a6:	e8 76 f2 ff ff       	call   f0100621 <iscons>
f01013ab:	89 c7                	mov    %eax,%edi
f01013ad:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01013b0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01013b5:	e8 56 f2 ff ff       	call   f0100610 <getchar>
f01013ba:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01013bc:	85 c0                	test   %eax,%eax
f01013be:	79 18                	jns    f01013d8 <readline+0x58>
			cprintf("read error: %e\n", c);
f01013c0:	83 ec 08             	sub    $0x8,%esp
f01013c3:	50                   	push   %eax
f01013c4:	68 f4 21 10 f0       	push   $0xf01021f4
f01013c9:	e8 a9 f6 ff ff       	call   f0100a77 <cprintf>
			return NULL;
f01013ce:	83 c4 10             	add    $0x10,%esp
f01013d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01013d6:	eb 79                	jmp    f0101451 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013d8:	83 f8 08             	cmp    $0x8,%eax
f01013db:	0f 94 c2             	sete   %dl
f01013de:	83 f8 7f             	cmp    $0x7f,%eax
f01013e1:	0f 94 c0             	sete   %al
f01013e4:	08 c2                	or     %al,%dl
f01013e6:	74 1a                	je     f0101402 <readline+0x82>
f01013e8:	85 f6                	test   %esi,%esi
f01013ea:	7e 16                	jle    f0101402 <readline+0x82>
			if (echoing)
f01013ec:	85 ff                	test   %edi,%edi
f01013ee:	74 0d                	je     f01013fd <readline+0x7d>
				cputchar('\b');
f01013f0:	83 ec 0c             	sub    $0xc,%esp
f01013f3:	6a 08                	push   $0x8
f01013f5:	e8 06 f2 ff ff       	call   f0100600 <cputchar>
f01013fa:	83 c4 10             	add    $0x10,%esp
			i--;
f01013fd:	83 ee 01             	sub    $0x1,%esi
f0101400:	eb b3                	jmp    f01013b5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101402:	83 fb 1f             	cmp    $0x1f,%ebx
f0101405:	7e 23                	jle    f010142a <readline+0xaa>
f0101407:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010140d:	7f 1b                	jg     f010142a <readline+0xaa>
			if (echoing)
f010140f:	85 ff                	test   %edi,%edi
f0101411:	74 0c                	je     f010141f <readline+0x9f>
				cputchar(c);
f0101413:	83 ec 0c             	sub    $0xc,%esp
f0101416:	53                   	push   %ebx
f0101417:	e8 e4 f1 ff ff       	call   f0100600 <cputchar>
f010141c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010141f:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101425:	8d 76 01             	lea    0x1(%esi),%esi
f0101428:	eb 8b                	jmp    f01013b5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010142a:	83 fb 0a             	cmp    $0xa,%ebx
f010142d:	74 05                	je     f0101434 <readline+0xb4>
f010142f:	83 fb 0d             	cmp    $0xd,%ebx
f0101432:	75 81                	jne    f01013b5 <readline+0x35>
			if (echoing)
f0101434:	85 ff                	test   %edi,%edi
f0101436:	74 0d                	je     f0101445 <readline+0xc5>
				cputchar('\n');
f0101438:	83 ec 0c             	sub    $0xc,%esp
f010143b:	6a 0a                	push   $0xa
f010143d:	e8 be f1 ff ff       	call   f0100600 <cputchar>
f0101442:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101445:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f010144c:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101451:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101454:	5b                   	pop    %ebx
f0101455:	5e                   	pop    %esi
f0101456:	5f                   	pop    %edi
f0101457:	5d                   	pop    %ebp
f0101458:	c3                   	ret    

f0101459 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101459:	55                   	push   %ebp
f010145a:	89 e5                	mov    %esp,%ebp
f010145c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010145f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101464:	eb 03                	jmp    f0101469 <strlen+0x10>
		n++;
f0101466:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101469:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010146d:	75 f7                	jne    f0101466 <strlen+0xd>
		n++;
	return n;
}
f010146f:	5d                   	pop    %ebp
f0101470:	c3                   	ret    

f0101471 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101471:	55                   	push   %ebp
f0101472:	89 e5                	mov    %esp,%ebp
f0101474:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101477:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010147a:	ba 00 00 00 00       	mov    $0x0,%edx
f010147f:	eb 03                	jmp    f0101484 <strnlen+0x13>
		n++;
f0101481:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101484:	39 c2                	cmp    %eax,%edx
f0101486:	74 08                	je     f0101490 <strnlen+0x1f>
f0101488:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010148c:	75 f3                	jne    f0101481 <strnlen+0x10>
f010148e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101490:	5d                   	pop    %ebp
f0101491:	c3                   	ret    

f0101492 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101492:	55                   	push   %ebp
f0101493:	89 e5                	mov    %esp,%ebp
f0101495:	53                   	push   %ebx
f0101496:	8b 45 08             	mov    0x8(%ebp),%eax
f0101499:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010149c:	89 c2                	mov    %eax,%edx
f010149e:	83 c2 01             	add    $0x1,%edx
f01014a1:	83 c1 01             	add    $0x1,%ecx
f01014a4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01014a8:	88 5a ff             	mov    %bl,-0x1(%edx)
f01014ab:	84 db                	test   %bl,%bl
f01014ad:	75 ef                	jne    f010149e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01014af:	5b                   	pop    %ebx
f01014b0:	5d                   	pop    %ebp
f01014b1:	c3                   	ret    

f01014b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01014b2:	55                   	push   %ebp
f01014b3:	89 e5                	mov    %esp,%ebp
f01014b5:	53                   	push   %ebx
f01014b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01014b9:	53                   	push   %ebx
f01014ba:	e8 9a ff ff ff       	call   f0101459 <strlen>
f01014bf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01014c2:	ff 75 0c             	pushl  0xc(%ebp)
f01014c5:	01 d8                	add    %ebx,%eax
f01014c7:	50                   	push   %eax
f01014c8:	e8 c5 ff ff ff       	call   f0101492 <strcpy>
	return dst;
}
f01014cd:	89 d8                	mov    %ebx,%eax
f01014cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014d2:	c9                   	leave  
f01014d3:	c3                   	ret    

f01014d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014d4:	55                   	push   %ebp
f01014d5:	89 e5                	mov    %esp,%ebp
f01014d7:	56                   	push   %esi
f01014d8:	53                   	push   %ebx
f01014d9:	8b 75 08             	mov    0x8(%ebp),%esi
f01014dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014df:	89 f3                	mov    %esi,%ebx
f01014e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014e4:	89 f2                	mov    %esi,%edx
f01014e6:	eb 0f                	jmp    f01014f7 <strncpy+0x23>
		*dst++ = *src;
f01014e8:	83 c2 01             	add    $0x1,%edx
f01014eb:	0f b6 01             	movzbl (%ecx),%eax
f01014ee:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014f1:	80 39 01             	cmpb   $0x1,(%ecx)
f01014f4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014f7:	39 da                	cmp    %ebx,%edx
f01014f9:	75 ed                	jne    f01014e8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01014fb:	89 f0                	mov    %esi,%eax
f01014fd:	5b                   	pop    %ebx
f01014fe:	5e                   	pop    %esi
f01014ff:	5d                   	pop    %ebp
f0101500:	c3                   	ret    

f0101501 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101501:	55                   	push   %ebp
f0101502:	89 e5                	mov    %esp,%ebp
f0101504:	56                   	push   %esi
f0101505:	53                   	push   %ebx
f0101506:	8b 75 08             	mov    0x8(%ebp),%esi
f0101509:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010150c:	8b 55 10             	mov    0x10(%ebp),%edx
f010150f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101511:	85 d2                	test   %edx,%edx
f0101513:	74 21                	je     f0101536 <strlcpy+0x35>
f0101515:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101519:	89 f2                	mov    %esi,%edx
f010151b:	eb 09                	jmp    f0101526 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010151d:	83 c2 01             	add    $0x1,%edx
f0101520:	83 c1 01             	add    $0x1,%ecx
f0101523:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101526:	39 c2                	cmp    %eax,%edx
f0101528:	74 09                	je     f0101533 <strlcpy+0x32>
f010152a:	0f b6 19             	movzbl (%ecx),%ebx
f010152d:	84 db                	test   %bl,%bl
f010152f:	75 ec                	jne    f010151d <strlcpy+0x1c>
f0101531:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101533:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101536:	29 f0                	sub    %esi,%eax
}
f0101538:	5b                   	pop    %ebx
f0101539:	5e                   	pop    %esi
f010153a:	5d                   	pop    %ebp
f010153b:	c3                   	ret    

f010153c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010153c:	55                   	push   %ebp
f010153d:	89 e5                	mov    %esp,%ebp
f010153f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101542:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101545:	eb 06                	jmp    f010154d <strcmp+0x11>
		p++, q++;
f0101547:	83 c1 01             	add    $0x1,%ecx
f010154a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010154d:	0f b6 01             	movzbl (%ecx),%eax
f0101550:	84 c0                	test   %al,%al
f0101552:	74 04                	je     f0101558 <strcmp+0x1c>
f0101554:	3a 02                	cmp    (%edx),%al
f0101556:	74 ef                	je     f0101547 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101558:	0f b6 c0             	movzbl %al,%eax
f010155b:	0f b6 12             	movzbl (%edx),%edx
f010155e:	29 d0                	sub    %edx,%eax
}
f0101560:	5d                   	pop    %ebp
f0101561:	c3                   	ret    

f0101562 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101562:	55                   	push   %ebp
f0101563:	89 e5                	mov    %esp,%ebp
f0101565:	53                   	push   %ebx
f0101566:	8b 45 08             	mov    0x8(%ebp),%eax
f0101569:	8b 55 0c             	mov    0xc(%ebp),%edx
f010156c:	89 c3                	mov    %eax,%ebx
f010156e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101571:	eb 06                	jmp    f0101579 <strncmp+0x17>
		n--, p++, q++;
f0101573:	83 c0 01             	add    $0x1,%eax
f0101576:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101579:	39 d8                	cmp    %ebx,%eax
f010157b:	74 15                	je     f0101592 <strncmp+0x30>
f010157d:	0f b6 08             	movzbl (%eax),%ecx
f0101580:	84 c9                	test   %cl,%cl
f0101582:	74 04                	je     f0101588 <strncmp+0x26>
f0101584:	3a 0a                	cmp    (%edx),%cl
f0101586:	74 eb                	je     f0101573 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101588:	0f b6 00             	movzbl (%eax),%eax
f010158b:	0f b6 12             	movzbl (%edx),%edx
f010158e:	29 d0                	sub    %edx,%eax
f0101590:	eb 05                	jmp    f0101597 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101592:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101597:	5b                   	pop    %ebx
f0101598:	5d                   	pop    %ebp
f0101599:	c3                   	ret    

f010159a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010159a:	55                   	push   %ebp
f010159b:	89 e5                	mov    %esp,%ebp
f010159d:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015a4:	eb 07                	jmp    f01015ad <strchr+0x13>
		if (*s == c)
f01015a6:	38 ca                	cmp    %cl,%dl
f01015a8:	74 0f                	je     f01015b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01015aa:	83 c0 01             	add    $0x1,%eax
f01015ad:	0f b6 10             	movzbl (%eax),%edx
f01015b0:	84 d2                	test   %dl,%dl
f01015b2:	75 f2                	jne    f01015a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01015b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015b9:	5d                   	pop    %ebp
f01015ba:	c3                   	ret    

f01015bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01015bb:	55                   	push   %ebp
f01015bc:	89 e5                	mov    %esp,%ebp
f01015be:	8b 45 08             	mov    0x8(%ebp),%eax
f01015c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015c5:	eb 03                	jmp    f01015ca <strfind+0xf>
f01015c7:	83 c0 01             	add    $0x1,%eax
f01015ca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01015cd:	38 ca                	cmp    %cl,%dl
f01015cf:	74 04                	je     f01015d5 <strfind+0x1a>
f01015d1:	84 d2                	test   %dl,%dl
f01015d3:	75 f2                	jne    f01015c7 <strfind+0xc>
			break;
	return (char *) s;
}
f01015d5:	5d                   	pop    %ebp
f01015d6:	c3                   	ret    

f01015d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015d7:	55                   	push   %ebp
f01015d8:	89 e5                	mov    %esp,%ebp
f01015da:	57                   	push   %edi
f01015db:	56                   	push   %esi
f01015dc:	53                   	push   %ebx
f01015dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015e3:	85 c9                	test   %ecx,%ecx
f01015e5:	74 36                	je     f010161d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015ed:	75 28                	jne    f0101617 <memset+0x40>
f01015ef:	f6 c1 03             	test   $0x3,%cl
f01015f2:	75 23                	jne    f0101617 <memset+0x40>
		c &= 0xFF;
f01015f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015f8:	89 d3                	mov    %edx,%ebx
f01015fa:	c1 e3 08             	shl    $0x8,%ebx
f01015fd:	89 d6                	mov    %edx,%esi
f01015ff:	c1 e6 18             	shl    $0x18,%esi
f0101602:	89 d0                	mov    %edx,%eax
f0101604:	c1 e0 10             	shl    $0x10,%eax
f0101607:	09 f0                	or     %esi,%eax
f0101609:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010160b:	89 d8                	mov    %ebx,%eax
f010160d:	09 d0                	or     %edx,%eax
f010160f:	c1 e9 02             	shr    $0x2,%ecx
f0101612:	fc                   	cld    
f0101613:	f3 ab                	rep stos %eax,%es:(%edi)
f0101615:	eb 06                	jmp    f010161d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101617:	8b 45 0c             	mov    0xc(%ebp),%eax
f010161a:	fc                   	cld    
f010161b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010161d:	89 f8                	mov    %edi,%eax
f010161f:	5b                   	pop    %ebx
f0101620:	5e                   	pop    %esi
f0101621:	5f                   	pop    %edi
f0101622:	5d                   	pop    %ebp
f0101623:	c3                   	ret    

f0101624 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101624:	55                   	push   %ebp
f0101625:	89 e5                	mov    %esp,%ebp
f0101627:	57                   	push   %edi
f0101628:	56                   	push   %esi
f0101629:	8b 45 08             	mov    0x8(%ebp),%eax
f010162c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010162f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101632:	39 c6                	cmp    %eax,%esi
f0101634:	73 35                	jae    f010166b <memmove+0x47>
f0101636:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101639:	39 d0                	cmp    %edx,%eax
f010163b:	73 2e                	jae    f010166b <memmove+0x47>
		s += n;
		d += n;
f010163d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101640:	89 d6                	mov    %edx,%esi
f0101642:	09 fe                	or     %edi,%esi
f0101644:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010164a:	75 13                	jne    f010165f <memmove+0x3b>
f010164c:	f6 c1 03             	test   $0x3,%cl
f010164f:	75 0e                	jne    f010165f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101651:	83 ef 04             	sub    $0x4,%edi
f0101654:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101657:	c1 e9 02             	shr    $0x2,%ecx
f010165a:	fd                   	std    
f010165b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010165d:	eb 09                	jmp    f0101668 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010165f:	83 ef 01             	sub    $0x1,%edi
f0101662:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101665:	fd                   	std    
f0101666:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101668:	fc                   	cld    
f0101669:	eb 1d                	jmp    f0101688 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010166b:	89 f2                	mov    %esi,%edx
f010166d:	09 c2                	or     %eax,%edx
f010166f:	f6 c2 03             	test   $0x3,%dl
f0101672:	75 0f                	jne    f0101683 <memmove+0x5f>
f0101674:	f6 c1 03             	test   $0x3,%cl
f0101677:	75 0a                	jne    f0101683 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101679:	c1 e9 02             	shr    $0x2,%ecx
f010167c:	89 c7                	mov    %eax,%edi
f010167e:	fc                   	cld    
f010167f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101681:	eb 05                	jmp    f0101688 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101683:	89 c7                	mov    %eax,%edi
f0101685:	fc                   	cld    
f0101686:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101688:	5e                   	pop    %esi
f0101689:	5f                   	pop    %edi
f010168a:	5d                   	pop    %ebp
f010168b:	c3                   	ret    

f010168c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010168c:	55                   	push   %ebp
f010168d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010168f:	ff 75 10             	pushl  0x10(%ebp)
f0101692:	ff 75 0c             	pushl  0xc(%ebp)
f0101695:	ff 75 08             	pushl  0x8(%ebp)
f0101698:	e8 87 ff ff ff       	call   f0101624 <memmove>
}
f010169d:	c9                   	leave  
f010169e:	c3                   	ret    

f010169f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010169f:	55                   	push   %ebp
f01016a0:	89 e5                	mov    %esp,%ebp
f01016a2:	56                   	push   %esi
f01016a3:	53                   	push   %ebx
f01016a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01016a7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016aa:	89 c6                	mov    %eax,%esi
f01016ac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016af:	eb 1a                	jmp    f01016cb <memcmp+0x2c>
		if (*s1 != *s2)
f01016b1:	0f b6 08             	movzbl (%eax),%ecx
f01016b4:	0f b6 1a             	movzbl (%edx),%ebx
f01016b7:	38 d9                	cmp    %bl,%cl
f01016b9:	74 0a                	je     f01016c5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01016bb:	0f b6 c1             	movzbl %cl,%eax
f01016be:	0f b6 db             	movzbl %bl,%ebx
f01016c1:	29 d8                	sub    %ebx,%eax
f01016c3:	eb 0f                	jmp    f01016d4 <memcmp+0x35>
		s1++, s2++;
f01016c5:	83 c0 01             	add    $0x1,%eax
f01016c8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016cb:	39 f0                	cmp    %esi,%eax
f01016cd:	75 e2                	jne    f01016b1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01016cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016d4:	5b                   	pop    %ebx
f01016d5:	5e                   	pop    %esi
f01016d6:	5d                   	pop    %ebp
f01016d7:	c3                   	ret    

f01016d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016d8:	55                   	push   %ebp
f01016d9:	89 e5                	mov    %esp,%ebp
f01016db:	53                   	push   %ebx
f01016dc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01016df:	89 c1                	mov    %eax,%ecx
f01016e1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01016e4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016e8:	eb 0a                	jmp    f01016f4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016ea:	0f b6 10             	movzbl (%eax),%edx
f01016ed:	39 da                	cmp    %ebx,%edx
f01016ef:	74 07                	je     f01016f8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01016f1:	83 c0 01             	add    $0x1,%eax
f01016f4:	39 c8                	cmp    %ecx,%eax
f01016f6:	72 f2                	jb     f01016ea <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01016f8:	5b                   	pop    %ebx
f01016f9:	5d                   	pop    %ebp
f01016fa:	c3                   	ret    

f01016fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016fb:	55                   	push   %ebp
f01016fc:	89 e5                	mov    %esp,%ebp
f01016fe:	57                   	push   %edi
f01016ff:	56                   	push   %esi
f0101700:	53                   	push   %ebx
f0101701:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101704:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101707:	eb 03                	jmp    f010170c <strtol+0x11>
		s++;
f0101709:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010170c:	0f b6 01             	movzbl (%ecx),%eax
f010170f:	3c 20                	cmp    $0x20,%al
f0101711:	74 f6                	je     f0101709 <strtol+0xe>
f0101713:	3c 09                	cmp    $0x9,%al
f0101715:	74 f2                	je     f0101709 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101717:	3c 2b                	cmp    $0x2b,%al
f0101719:	75 0a                	jne    f0101725 <strtol+0x2a>
		s++;
f010171b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010171e:	bf 00 00 00 00       	mov    $0x0,%edi
f0101723:	eb 11                	jmp    f0101736 <strtol+0x3b>
f0101725:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010172a:	3c 2d                	cmp    $0x2d,%al
f010172c:	75 08                	jne    f0101736 <strtol+0x3b>
		s++, neg = 1;
f010172e:	83 c1 01             	add    $0x1,%ecx
f0101731:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101736:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010173c:	75 15                	jne    f0101753 <strtol+0x58>
f010173e:	80 39 30             	cmpb   $0x30,(%ecx)
f0101741:	75 10                	jne    f0101753 <strtol+0x58>
f0101743:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101747:	75 7c                	jne    f01017c5 <strtol+0xca>
		s += 2, base = 16;
f0101749:	83 c1 02             	add    $0x2,%ecx
f010174c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101751:	eb 16                	jmp    f0101769 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101753:	85 db                	test   %ebx,%ebx
f0101755:	75 12                	jne    f0101769 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101757:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010175c:	80 39 30             	cmpb   $0x30,(%ecx)
f010175f:	75 08                	jne    f0101769 <strtol+0x6e>
		s++, base = 8;
f0101761:	83 c1 01             	add    $0x1,%ecx
f0101764:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101769:	b8 00 00 00 00       	mov    $0x0,%eax
f010176e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101771:	0f b6 11             	movzbl (%ecx),%edx
f0101774:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101777:	89 f3                	mov    %esi,%ebx
f0101779:	80 fb 09             	cmp    $0x9,%bl
f010177c:	77 08                	ja     f0101786 <strtol+0x8b>
			dig = *s - '0';
f010177e:	0f be d2             	movsbl %dl,%edx
f0101781:	83 ea 30             	sub    $0x30,%edx
f0101784:	eb 22                	jmp    f01017a8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101786:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101789:	89 f3                	mov    %esi,%ebx
f010178b:	80 fb 19             	cmp    $0x19,%bl
f010178e:	77 08                	ja     f0101798 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101790:	0f be d2             	movsbl %dl,%edx
f0101793:	83 ea 57             	sub    $0x57,%edx
f0101796:	eb 10                	jmp    f01017a8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101798:	8d 72 bf             	lea    -0x41(%edx),%esi
f010179b:	89 f3                	mov    %esi,%ebx
f010179d:	80 fb 19             	cmp    $0x19,%bl
f01017a0:	77 16                	ja     f01017b8 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01017a2:	0f be d2             	movsbl %dl,%edx
f01017a5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01017a8:	3b 55 10             	cmp    0x10(%ebp),%edx
f01017ab:	7d 0b                	jge    f01017b8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01017ad:	83 c1 01             	add    $0x1,%ecx
f01017b0:	0f af 45 10          	imul   0x10(%ebp),%eax
f01017b4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01017b6:	eb b9                	jmp    f0101771 <strtol+0x76>

	if (endptr)
f01017b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017bc:	74 0d                	je     f01017cb <strtol+0xd0>
		*endptr = (char *) s;
f01017be:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017c1:	89 0e                	mov    %ecx,(%esi)
f01017c3:	eb 06                	jmp    f01017cb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01017c5:	85 db                	test   %ebx,%ebx
f01017c7:	74 98                	je     f0101761 <strtol+0x66>
f01017c9:	eb 9e                	jmp    f0101769 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01017cb:	89 c2                	mov    %eax,%edx
f01017cd:	f7 da                	neg    %edx
f01017cf:	85 ff                	test   %edi,%edi
f01017d1:	0f 45 c2             	cmovne %edx,%eax
}
f01017d4:	5b                   	pop    %ebx
f01017d5:	5e                   	pop    %esi
f01017d6:	5f                   	pop    %edi
f01017d7:	5d                   	pop    %ebp
f01017d8:	c3                   	ret    
f01017d9:	66 90                	xchg   %ax,%ax
f01017db:	66 90                	xchg   %ax,%ax
f01017dd:	66 90                	xchg   %ax,%ax
f01017df:	90                   	nop

f01017e0 <__udivdi3>:
f01017e0:	55                   	push   %ebp
f01017e1:	57                   	push   %edi
f01017e2:	56                   	push   %esi
f01017e3:	53                   	push   %ebx
f01017e4:	83 ec 1c             	sub    $0x1c,%esp
f01017e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01017eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01017ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01017f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017f7:	85 f6                	test   %esi,%esi
f01017f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01017fd:	89 ca                	mov    %ecx,%edx
f01017ff:	89 f8                	mov    %edi,%eax
f0101801:	75 3d                	jne    f0101840 <__udivdi3+0x60>
f0101803:	39 cf                	cmp    %ecx,%edi
f0101805:	0f 87 c5 00 00 00    	ja     f01018d0 <__udivdi3+0xf0>
f010180b:	85 ff                	test   %edi,%edi
f010180d:	89 fd                	mov    %edi,%ebp
f010180f:	75 0b                	jne    f010181c <__udivdi3+0x3c>
f0101811:	b8 01 00 00 00       	mov    $0x1,%eax
f0101816:	31 d2                	xor    %edx,%edx
f0101818:	f7 f7                	div    %edi
f010181a:	89 c5                	mov    %eax,%ebp
f010181c:	89 c8                	mov    %ecx,%eax
f010181e:	31 d2                	xor    %edx,%edx
f0101820:	f7 f5                	div    %ebp
f0101822:	89 c1                	mov    %eax,%ecx
f0101824:	89 d8                	mov    %ebx,%eax
f0101826:	89 cf                	mov    %ecx,%edi
f0101828:	f7 f5                	div    %ebp
f010182a:	89 c3                	mov    %eax,%ebx
f010182c:	89 d8                	mov    %ebx,%eax
f010182e:	89 fa                	mov    %edi,%edx
f0101830:	83 c4 1c             	add    $0x1c,%esp
f0101833:	5b                   	pop    %ebx
f0101834:	5e                   	pop    %esi
f0101835:	5f                   	pop    %edi
f0101836:	5d                   	pop    %ebp
f0101837:	c3                   	ret    
f0101838:	90                   	nop
f0101839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101840:	39 ce                	cmp    %ecx,%esi
f0101842:	77 74                	ja     f01018b8 <__udivdi3+0xd8>
f0101844:	0f bd fe             	bsr    %esi,%edi
f0101847:	83 f7 1f             	xor    $0x1f,%edi
f010184a:	0f 84 98 00 00 00    	je     f01018e8 <__udivdi3+0x108>
f0101850:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101855:	89 f9                	mov    %edi,%ecx
f0101857:	89 c5                	mov    %eax,%ebp
f0101859:	29 fb                	sub    %edi,%ebx
f010185b:	d3 e6                	shl    %cl,%esi
f010185d:	89 d9                	mov    %ebx,%ecx
f010185f:	d3 ed                	shr    %cl,%ebp
f0101861:	89 f9                	mov    %edi,%ecx
f0101863:	d3 e0                	shl    %cl,%eax
f0101865:	09 ee                	or     %ebp,%esi
f0101867:	89 d9                	mov    %ebx,%ecx
f0101869:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010186d:	89 d5                	mov    %edx,%ebp
f010186f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101873:	d3 ed                	shr    %cl,%ebp
f0101875:	89 f9                	mov    %edi,%ecx
f0101877:	d3 e2                	shl    %cl,%edx
f0101879:	89 d9                	mov    %ebx,%ecx
f010187b:	d3 e8                	shr    %cl,%eax
f010187d:	09 c2                	or     %eax,%edx
f010187f:	89 d0                	mov    %edx,%eax
f0101881:	89 ea                	mov    %ebp,%edx
f0101883:	f7 f6                	div    %esi
f0101885:	89 d5                	mov    %edx,%ebp
f0101887:	89 c3                	mov    %eax,%ebx
f0101889:	f7 64 24 0c          	mull   0xc(%esp)
f010188d:	39 d5                	cmp    %edx,%ebp
f010188f:	72 10                	jb     f01018a1 <__udivdi3+0xc1>
f0101891:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101895:	89 f9                	mov    %edi,%ecx
f0101897:	d3 e6                	shl    %cl,%esi
f0101899:	39 c6                	cmp    %eax,%esi
f010189b:	73 07                	jae    f01018a4 <__udivdi3+0xc4>
f010189d:	39 d5                	cmp    %edx,%ebp
f010189f:	75 03                	jne    f01018a4 <__udivdi3+0xc4>
f01018a1:	83 eb 01             	sub    $0x1,%ebx
f01018a4:	31 ff                	xor    %edi,%edi
f01018a6:	89 d8                	mov    %ebx,%eax
f01018a8:	89 fa                	mov    %edi,%edx
f01018aa:	83 c4 1c             	add    $0x1c,%esp
f01018ad:	5b                   	pop    %ebx
f01018ae:	5e                   	pop    %esi
f01018af:	5f                   	pop    %edi
f01018b0:	5d                   	pop    %ebp
f01018b1:	c3                   	ret    
f01018b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018b8:	31 ff                	xor    %edi,%edi
f01018ba:	31 db                	xor    %ebx,%ebx
f01018bc:	89 d8                	mov    %ebx,%eax
f01018be:	89 fa                	mov    %edi,%edx
f01018c0:	83 c4 1c             	add    $0x1c,%esp
f01018c3:	5b                   	pop    %ebx
f01018c4:	5e                   	pop    %esi
f01018c5:	5f                   	pop    %edi
f01018c6:	5d                   	pop    %ebp
f01018c7:	c3                   	ret    
f01018c8:	90                   	nop
f01018c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018d0:	89 d8                	mov    %ebx,%eax
f01018d2:	f7 f7                	div    %edi
f01018d4:	31 ff                	xor    %edi,%edi
f01018d6:	89 c3                	mov    %eax,%ebx
f01018d8:	89 d8                	mov    %ebx,%eax
f01018da:	89 fa                	mov    %edi,%edx
f01018dc:	83 c4 1c             	add    $0x1c,%esp
f01018df:	5b                   	pop    %ebx
f01018e0:	5e                   	pop    %esi
f01018e1:	5f                   	pop    %edi
f01018e2:	5d                   	pop    %ebp
f01018e3:	c3                   	ret    
f01018e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018e8:	39 ce                	cmp    %ecx,%esi
f01018ea:	72 0c                	jb     f01018f8 <__udivdi3+0x118>
f01018ec:	31 db                	xor    %ebx,%ebx
f01018ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01018f2:	0f 87 34 ff ff ff    	ja     f010182c <__udivdi3+0x4c>
f01018f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01018fd:	e9 2a ff ff ff       	jmp    f010182c <__udivdi3+0x4c>
f0101902:	66 90                	xchg   %ax,%ax
f0101904:	66 90                	xchg   %ax,%ax
f0101906:	66 90                	xchg   %ax,%ax
f0101908:	66 90                	xchg   %ax,%ax
f010190a:	66 90                	xchg   %ax,%ax
f010190c:	66 90                	xchg   %ax,%ax
f010190e:	66 90                	xchg   %ax,%ax

f0101910 <__umoddi3>:
f0101910:	55                   	push   %ebp
f0101911:	57                   	push   %edi
f0101912:	56                   	push   %esi
f0101913:	53                   	push   %ebx
f0101914:	83 ec 1c             	sub    $0x1c,%esp
f0101917:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010191b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010191f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101923:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101927:	85 d2                	test   %edx,%edx
f0101929:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010192d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101931:	89 f3                	mov    %esi,%ebx
f0101933:	89 3c 24             	mov    %edi,(%esp)
f0101936:	89 74 24 04          	mov    %esi,0x4(%esp)
f010193a:	75 1c                	jne    f0101958 <__umoddi3+0x48>
f010193c:	39 f7                	cmp    %esi,%edi
f010193e:	76 50                	jbe    f0101990 <__umoddi3+0x80>
f0101940:	89 c8                	mov    %ecx,%eax
f0101942:	89 f2                	mov    %esi,%edx
f0101944:	f7 f7                	div    %edi
f0101946:	89 d0                	mov    %edx,%eax
f0101948:	31 d2                	xor    %edx,%edx
f010194a:	83 c4 1c             	add    $0x1c,%esp
f010194d:	5b                   	pop    %ebx
f010194e:	5e                   	pop    %esi
f010194f:	5f                   	pop    %edi
f0101950:	5d                   	pop    %ebp
f0101951:	c3                   	ret    
f0101952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101958:	39 f2                	cmp    %esi,%edx
f010195a:	89 d0                	mov    %edx,%eax
f010195c:	77 52                	ja     f01019b0 <__umoddi3+0xa0>
f010195e:	0f bd ea             	bsr    %edx,%ebp
f0101961:	83 f5 1f             	xor    $0x1f,%ebp
f0101964:	75 5a                	jne    f01019c0 <__umoddi3+0xb0>
f0101966:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010196a:	0f 82 e0 00 00 00    	jb     f0101a50 <__umoddi3+0x140>
f0101970:	39 0c 24             	cmp    %ecx,(%esp)
f0101973:	0f 86 d7 00 00 00    	jbe    f0101a50 <__umoddi3+0x140>
f0101979:	8b 44 24 08          	mov    0x8(%esp),%eax
f010197d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101981:	83 c4 1c             	add    $0x1c,%esp
f0101984:	5b                   	pop    %ebx
f0101985:	5e                   	pop    %esi
f0101986:	5f                   	pop    %edi
f0101987:	5d                   	pop    %ebp
f0101988:	c3                   	ret    
f0101989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101990:	85 ff                	test   %edi,%edi
f0101992:	89 fd                	mov    %edi,%ebp
f0101994:	75 0b                	jne    f01019a1 <__umoddi3+0x91>
f0101996:	b8 01 00 00 00       	mov    $0x1,%eax
f010199b:	31 d2                	xor    %edx,%edx
f010199d:	f7 f7                	div    %edi
f010199f:	89 c5                	mov    %eax,%ebp
f01019a1:	89 f0                	mov    %esi,%eax
f01019a3:	31 d2                	xor    %edx,%edx
f01019a5:	f7 f5                	div    %ebp
f01019a7:	89 c8                	mov    %ecx,%eax
f01019a9:	f7 f5                	div    %ebp
f01019ab:	89 d0                	mov    %edx,%eax
f01019ad:	eb 99                	jmp    f0101948 <__umoddi3+0x38>
f01019af:	90                   	nop
f01019b0:	89 c8                	mov    %ecx,%eax
f01019b2:	89 f2                	mov    %esi,%edx
f01019b4:	83 c4 1c             	add    $0x1c,%esp
f01019b7:	5b                   	pop    %ebx
f01019b8:	5e                   	pop    %esi
f01019b9:	5f                   	pop    %edi
f01019ba:	5d                   	pop    %ebp
f01019bb:	c3                   	ret    
f01019bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019c0:	8b 34 24             	mov    (%esp),%esi
f01019c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01019c8:	89 e9                	mov    %ebp,%ecx
f01019ca:	29 ef                	sub    %ebp,%edi
f01019cc:	d3 e0                	shl    %cl,%eax
f01019ce:	89 f9                	mov    %edi,%ecx
f01019d0:	89 f2                	mov    %esi,%edx
f01019d2:	d3 ea                	shr    %cl,%edx
f01019d4:	89 e9                	mov    %ebp,%ecx
f01019d6:	09 c2                	or     %eax,%edx
f01019d8:	89 d8                	mov    %ebx,%eax
f01019da:	89 14 24             	mov    %edx,(%esp)
f01019dd:	89 f2                	mov    %esi,%edx
f01019df:	d3 e2                	shl    %cl,%edx
f01019e1:	89 f9                	mov    %edi,%ecx
f01019e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01019e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01019eb:	d3 e8                	shr    %cl,%eax
f01019ed:	89 e9                	mov    %ebp,%ecx
f01019ef:	89 c6                	mov    %eax,%esi
f01019f1:	d3 e3                	shl    %cl,%ebx
f01019f3:	89 f9                	mov    %edi,%ecx
f01019f5:	89 d0                	mov    %edx,%eax
f01019f7:	d3 e8                	shr    %cl,%eax
f01019f9:	89 e9                	mov    %ebp,%ecx
f01019fb:	09 d8                	or     %ebx,%eax
f01019fd:	89 d3                	mov    %edx,%ebx
f01019ff:	89 f2                	mov    %esi,%edx
f0101a01:	f7 34 24             	divl   (%esp)
f0101a04:	89 d6                	mov    %edx,%esi
f0101a06:	d3 e3                	shl    %cl,%ebx
f0101a08:	f7 64 24 04          	mull   0x4(%esp)
f0101a0c:	39 d6                	cmp    %edx,%esi
f0101a0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101a12:	89 d1                	mov    %edx,%ecx
f0101a14:	89 c3                	mov    %eax,%ebx
f0101a16:	72 08                	jb     f0101a20 <__umoddi3+0x110>
f0101a18:	75 11                	jne    f0101a2b <__umoddi3+0x11b>
f0101a1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101a1e:	73 0b                	jae    f0101a2b <__umoddi3+0x11b>
f0101a20:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101a24:	1b 14 24             	sbb    (%esp),%edx
f0101a27:	89 d1                	mov    %edx,%ecx
f0101a29:	89 c3                	mov    %eax,%ebx
f0101a2b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0101a2f:	29 da                	sub    %ebx,%edx
f0101a31:	19 ce                	sbb    %ecx,%esi
f0101a33:	89 f9                	mov    %edi,%ecx
f0101a35:	89 f0                	mov    %esi,%eax
f0101a37:	d3 e0                	shl    %cl,%eax
f0101a39:	89 e9                	mov    %ebp,%ecx
f0101a3b:	d3 ea                	shr    %cl,%edx
f0101a3d:	89 e9                	mov    %ebp,%ecx
f0101a3f:	d3 ee                	shr    %cl,%esi
f0101a41:	09 d0                	or     %edx,%eax
f0101a43:	89 f2                	mov    %esi,%edx
f0101a45:	83 c4 1c             	add    $0x1c,%esp
f0101a48:	5b                   	pop    %ebx
f0101a49:	5e                   	pop    %esi
f0101a4a:	5f                   	pop    %edi
f0101a4b:	5d                   	pop    %ebp
f0101a4c:	c3                   	ret    
f0101a4d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a50:	29 f9                	sub    %edi,%ecx
f0101a52:	19 d6                	sbb    %edx,%esi
f0101a54:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101a58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a5c:	e9 18 ff ff ff       	jmp    f0101979 <__umoddi3+0x69>
