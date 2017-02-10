
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
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 60 19 10 f0       	push   $0xf0101960
f0100050:	e8 17 09 00 00       	call   f010096c <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 f3 06 00 00       	call   f010076e <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 7c 19 10 f0       	push   $0xf010197c
f0100087:	e8 e0 08 00 00       	call   f010096c <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 1b 14 00 00       	call   f01014cc <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 97 19 10 f0       	push   $0xf0101997
f01000c3:	e8 a4 08 00 00       	call   f010096c <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 0b 07 00 00       	call   f01007ec <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 b2 19 10 f0       	push   $0xf01019b2
f0100110:	e8 57 08 00 00       	call   f010096c <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 27 08 00 00       	call   f0100946 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 ee 19 10 f0 	movl   $0xf01019ee,(%esp)
f0100126:	e8 41 08 00 00       	call   f010096c <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 b4 06 00 00       	call   f01007ec <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 ca 19 10 f0       	push   $0xf01019ca
f0100152:	e8 15 08 00 00       	call   f010096c <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 e3 07 00 00       	call   f0100946 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 ee 19 10 f0 	movl   $0xf01019ee,(%esp)
f010016a:	e8 fd 07 00 00       	call   f010096c <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 40 1b 10 f0 	movzbl -0xfefe4c0(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 40 1b 10 f0 	movzbl -0xfefe4c0(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a 40 1a 10 f0 	movzbl -0xfefe5c0(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d 20 1a 10 f0 	mov    -0xfefe5e0(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 e4 19 10 f0       	push   $0xf01019e4
f01002c8:	e8 9f 06 00 00       	call   f010096c <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// Move all the content 1 line upward
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 9d 10 00 00       	call   f0101519 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// Move all the content 1 line upward
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 f0 19 10 f0       	push   $0xf01019f0
f010064b:	e8 1c 03 00 00       	call   f010096c <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 40 1c 10 f0       	push   $0xf0101c40
f0100691:	68 5e 1c 10 f0       	push   $0xf0101c5e
f0100696:	68 63 1c 10 f0       	push   $0xf0101c63
f010069b:	e8 cc 02 00 00       	call   f010096c <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 cc 1c 10 f0       	push   $0xf0101ccc
f01006a8:	68 6c 1c 10 f0       	push   $0xf0101c6c
f01006ad:	68 63 1c 10 f0       	push   $0xf0101c63
f01006b2:	e8 b5 02 00 00       	call   f010096c <cprintf>
	return 0;
}
f01006b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006bc:	c9                   	leave  
f01006bd:	c3                   	ret    

f01006be <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006be:	55                   	push   %ebp
f01006bf:	89 e5                	mov    %esp,%ebp
f01006c1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c4:	68 75 1c 10 f0       	push   $0xf0101c75
f01006c9:	e8 9e 02 00 00       	call   f010096c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ce:	83 c4 08             	add    $0x8,%esp
f01006d1:	68 0c 00 10 00       	push   $0x10000c
f01006d6:	68 f4 1c 10 f0       	push   $0xf0101cf4
f01006db:	e8 8c 02 00 00       	call   f010096c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006e0:	83 c4 0c             	add    $0xc,%esp
f01006e3:	68 0c 00 10 00       	push   $0x10000c
f01006e8:	68 0c 00 10 f0       	push   $0xf010000c
f01006ed:	68 1c 1d 10 f0       	push   $0xf0101d1c
f01006f2:	e8 75 02 00 00       	call   f010096c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 51 19 10 00       	push   $0x101951
f01006ff:	68 51 19 10 f0       	push   $0xf0101951
f0100704:	68 40 1d 10 f0       	push   $0xf0101d40
f0100709:	e8 5e 02 00 00       	call   f010096c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 00 23 11 00       	push   $0x112300
f0100716:	68 00 23 11 f0       	push   $0xf0112300
f010071b:	68 64 1d 10 f0       	push   $0xf0101d64
f0100720:	e8 47 02 00 00       	call   f010096c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 44 29 11 00       	push   $0x112944
f010072d:	68 44 29 11 f0       	push   $0xf0112944
f0100732:	68 88 1d 10 f0       	push   $0xf0101d88
f0100737:	e8 30 02 00 00       	call   f010096c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010073c:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100741:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100746:	83 c4 08             	add    $0x8,%esp
f0100749:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010074e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100754:	85 c0                	test   %eax,%eax
f0100756:	0f 48 c2             	cmovs  %edx,%eax
f0100759:	c1 f8 0a             	sar    $0xa,%eax
f010075c:	50                   	push   %eax
f010075d:	68 ac 1d 10 f0       	push   $0xf0101dac
f0100762:	e8 05 02 00 00       	call   f010096c <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100767:	b8 00 00 00 00       	mov    $0x0,%eax
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076e:	55                   	push   %ebp
f010076f:	89 e5                	mov    %esp,%ebp
f0100771:	57                   	push   %edi
f0100772:	56                   	push   %esi
f0100773:	53                   	push   %ebx
f0100774:	81 ec 2c 04 00 00    	sub    $0x42c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010077a:	89 eb                	mov    %ebp,%ebx
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
		eip = *(ebp + 1);
		debuginfo_eip(eip, &info);
		strncpy(fn_name, info.eip_fn_name, info.eip_fn_namelen);
f010077c:	8d bd d0 fb ff ff    	lea    -0x430(%ebp),%edi
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t* ebp = (uint32_t*)read_ebp();
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
f0100782:	eb 57                	jmp    f01007db <mon_backtrace+0x6d>
		eip = *(ebp + 1);
f0100784:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip(eip, &info);
f0100787:	83 ec 08             	sub    $0x8,%esp
f010078a:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010078d:	50                   	push   %eax
f010078e:	56                   	push   %esi
f010078f:	e8 e2 02 00 00       	call   f0100a76 <debuginfo_eip>
		strncpy(fn_name, info.eip_fn_name, info.eip_fn_namelen);
f0100794:	83 c4 0c             	add    $0xc,%esp
f0100797:	ff 75 dc             	pushl  -0x24(%ebp)
f010079a:	ff 75 d8             	pushl  -0x28(%ebp)
f010079d:	57                   	push   %edi
f010079e:	e8 26 0c 00 00       	call   f01013c9 <strncpy>
		fn_name[info.eip_fn_namelen] = 0;
f01007a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01007a6:	c6 84 05 d0 fb ff ff 	movb   $0x0,-0x430(%ebp,%eax,1)
f01007ad:	00 
		cprintf("ebp %x eip %x args %08d %08d %08d %08d %08d"
f01007ae:	89 f0                	mov    %esi,%eax
f01007b0:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007b3:	50                   	push   %eax
f01007b4:	57                   	push   %edi
f01007b5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007b8:	ff 75 d0             	pushl  -0x30(%ebp)
f01007bb:	ff 73 18             	pushl  0x18(%ebx)
f01007be:	ff 73 14             	pushl  0x14(%ebx)
f01007c1:	ff 73 10             	pushl  0x10(%ebx)
f01007c4:	ff 73 0c             	pushl  0xc(%ebx)
f01007c7:	ff 73 08             	pushl  0x8(%ebx)
f01007ca:	56                   	push   %esi
f01007cb:	53                   	push   %ebx
f01007cc:	68 d8 1d 10 f0       	push   $0xf0101dd8
f01007d1:	e8 96 01 00 00       	call   f010096c <cprintf>
				" %s:%d: %s+%d\n", ebp, eip, *(ebp + 2), *(ebp + 3), 
				*(ebp + 4), *(ebp + 5), *(ebp + 6), info.eip_file, 
				info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t*)*ebp;
f01007d6:	8b 1b                	mov    (%ebx),%ebx
f01007d8:	83 c4 40             	add    $0x40,%esp
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t* ebp = (uint32_t*)read_ebp();
	uintptr_t eip;
	char fn_name[1024];
	while (ebp){
f01007db:	85 db                	test   %ebx,%ebx
f01007dd:	75 a5                	jne    f0100784 <mon_backtrace+0x16>
				*(ebp + 4), *(ebp + 5), *(ebp + 6), info.eip_file, 
				info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t*)*ebp;
	}
	return 0;
}
f01007df:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007e7:	5b                   	pop    %ebx
f01007e8:	5e                   	pop    %esi
f01007e9:	5f                   	pop    %edi
f01007ea:	5d                   	pop    %ebp
f01007eb:	c3                   	ret    

f01007ec <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ec:	55                   	push   %ebp
f01007ed:	89 e5                	mov    %esp,%ebp
f01007ef:	57                   	push   %edi
f01007f0:	56                   	push   %esi
f01007f1:	53                   	push   %ebx
f01007f2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007f5:	68 14 1e 10 f0       	push   $0xf0101e14
f01007fa:	e8 6d 01 00 00       	call   f010096c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007ff:	c7 04 24 38 1e 10 f0 	movl   $0xf0101e38,(%esp)
f0100806:	e8 61 01 00 00       	call   f010096c <cprintf>
f010080b:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010080e:	83 ec 0c             	sub    $0xc,%esp
f0100811:	68 8e 1c 10 f0       	push   $0xf0101c8e
f0100816:	e8 5a 0a 00 00       	call   f0101275 <readline>
f010081b:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010081d:	83 c4 10             	add    $0x10,%esp
f0100820:	85 c0                	test   %eax,%eax
f0100822:	74 ea                	je     f010080e <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100824:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010082b:	be 00 00 00 00       	mov    $0x0,%esi
f0100830:	eb 0a                	jmp    f010083c <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100832:	c6 03 00             	movb   $0x0,(%ebx)
f0100835:	89 f7                	mov    %esi,%edi
f0100837:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010083a:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010083c:	0f b6 03             	movzbl (%ebx),%eax
f010083f:	84 c0                	test   %al,%al
f0100841:	74 63                	je     f01008a6 <monitor+0xba>
f0100843:	83 ec 08             	sub    $0x8,%esp
f0100846:	0f be c0             	movsbl %al,%eax
f0100849:	50                   	push   %eax
f010084a:	68 92 1c 10 f0       	push   $0xf0101c92
f010084f:	e8 3b 0c 00 00       	call   f010148f <strchr>
f0100854:	83 c4 10             	add    $0x10,%esp
f0100857:	85 c0                	test   %eax,%eax
f0100859:	75 d7                	jne    f0100832 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010085b:	80 3b 00             	cmpb   $0x0,(%ebx)
f010085e:	74 46                	je     f01008a6 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100860:	83 fe 0f             	cmp    $0xf,%esi
f0100863:	75 14                	jne    f0100879 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100865:	83 ec 08             	sub    $0x8,%esp
f0100868:	6a 10                	push   $0x10
f010086a:	68 97 1c 10 f0       	push   $0xf0101c97
f010086f:	e8 f8 00 00 00       	call   f010096c <cprintf>
f0100874:	83 c4 10             	add    $0x10,%esp
f0100877:	eb 95                	jmp    f010080e <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100879:	8d 7e 01             	lea    0x1(%esi),%edi
f010087c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100880:	eb 03                	jmp    f0100885 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100882:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100885:	0f b6 03             	movzbl (%ebx),%eax
f0100888:	84 c0                	test   %al,%al
f010088a:	74 ae                	je     f010083a <monitor+0x4e>
f010088c:	83 ec 08             	sub    $0x8,%esp
f010088f:	0f be c0             	movsbl %al,%eax
f0100892:	50                   	push   %eax
f0100893:	68 92 1c 10 f0       	push   $0xf0101c92
f0100898:	e8 f2 0b 00 00       	call   f010148f <strchr>
f010089d:	83 c4 10             	add    $0x10,%esp
f01008a0:	85 c0                	test   %eax,%eax
f01008a2:	74 de                	je     f0100882 <monitor+0x96>
f01008a4:	eb 94                	jmp    f010083a <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008a6:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008ad:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008ae:	85 f6                	test   %esi,%esi
f01008b0:	0f 84 58 ff ff ff    	je     f010080e <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008b6:	83 ec 08             	sub    $0x8,%esp
f01008b9:	68 5e 1c 10 f0       	push   $0xf0101c5e
f01008be:	ff 75 a8             	pushl  -0x58(%ebp)
f01008c1:	e8 6b 0b 00 00       	call   f0101431 <strcmp>
f01008c6:	83 c4 10             	add    $0x10,%esp
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 1e                	je     f01008eb <monitor+0xff>
f01008cd:	83 ec 08             	sub    $0x8,%esp
f01008d0:	68 6c 1c 10 f0       	push   $0xf0101c6c
f01008d5:	ff 75 a8             	pushl  -0x58(%ebp)
f01008d8:	e8 54 0b 00 00       	call   f0101431 <strcmp>
f01008dd:	83 c4 10             	add    $0x10,%esp
f01008e0:	85 c0                	test   %eax,%eax
f01008e2:	75 2f                	jne    f0100913 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01008e9:	eb 05                	jmp    f01008f0 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008eb:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01008f0:	83 ec 04             	sub    $0x4,%esp
f01008f3:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008f6:	01 d0                	add    %edx,%eax
f01008f8:	ff 75 08             	pushl  0x8(%ebp)
f01008fb:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008fe:	51                   	push   %ecx
f01008ff:	56                   	push   %esi
f0100900:	ff 14 85 68 1e 10 f0 	call   *-0xfefe198(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100907:	83 c4 10             	add    $0x10,%esp
f010090a:	85 c0                	test   %eax,%eax
f010090c:	78 1d                	js     f010092b <monitor+0x13f>
f010090e:	e9 fb fe ff ff       	jmp    f010080e <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100913:	83 ec 08             	sub    $0x8,%esp
f0100916:	ff 75 a8             	pushl  -0x58(%ebp)
f0100919:	68 b4 1c 10 f0       	push   $0xf0101cb4
f010091e:	e8 49 00 00 00       	call   f010096c <cprintf>
f0100923:	83 c4 10             	add    $0x10,%esp
f0100926:	e9 e3 fe ff ff       	jmp    f010080e <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010092b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092e:	5b                   	pop    %ebx
f010092f:	5e                   	pop    %esi
f0100930:	5f                   	pop    %edi
f0100931:	5d                   	pop    %ebp
f0100932:	c3                   	ret    

f0100933 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100933:	55                   	push   %ebp
f0100934:	89 e5                	mov    %esp,%ebp
f0100936:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100939:	ff 75 08             	pushl  0x8(%ebp)
f010093c:	e8 1a fd ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f0100941:	83 c4 10             	add    $0x10,%esp
f0100944:	c9                   	leave  
f0100945:	c3                   	ret    

f0100946 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100946:	55                   	push   %ebp
f0100947:	89 e5                	mov    %esp,%ebp
f0100949:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010094c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100953:	ff 75 0c             	pushl  0xc(%ebp)
f0100956:	ff 75 08             	pushl  0x8(%ebp)
f0100959:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010095c:	50                   	push   %eax
f010095d:	68 33 09 10 f0       	push   $0xf0100933
f0100962:	e8 18 04 00 00       	call   f0100d7f <vprintfmt>
	return cnt;
}
f0100967:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010096a:	c9                   	leave  
f010096b:	c3                   	ret    

f010096c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010096c:	55                   	push   %ebp
f010096d:	89 e5                	mov    %esp,%ebp
f010096f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100972:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100975:	50                   	push   %eax
f0100976:	ff 75 08             	pushl  0x8(%ebp)
f0100979:	e8 c8 ff ff ff       	call   f0100946 <vcprintf>
	va_end(ap);

	return cnt;
}
f010097e:	c9                   	leave  
f010097f:	c3                   	ret    

f0100980 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100980:	55                   	push   %ebp
f0100981:	89 e5                	mov    %esp,%ebp
f0100983:	57                   	push   %edi
f0100984:	56                   	push   %esi
f0100985:	53                   	push   %ebx
f0100986:	83 ec 14             	sub    $0x14,%esp
f0100989:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010098c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010098f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100992:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100995:	8b 1a                	mov    (%edx),%ebx
f0100997:	8b 01                	mov    (%ecx),%eax
f0100999:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010099c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009a3:	eb 7f                	jmp    f0100a24 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009a8:	01 d8                	add    %ebx,%eax
f01009aa:	89 c6                	mov    %eax,%esi
f01009ac:	c1 ee 1f             	shr    $0x1f,%esi
f01009af:	01 c6                	add    %eax,%esi
f01009b1:	d1 fe                	sar    %esi
f01009b3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009b6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009b9:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009bc:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009be:	eb 03                	jmp    f01009c3 <stab_binsearch+0x43>
			m--;
f01009c0:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009c3:	39 c3                	cmp    %eax,%ebx
f01009c5:	7f 0d                	jg     f01009d4 <stab_binsearch+0x54>
f01009c7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009cb:	83 ea 0c             	sub    $0xc,%edx
f01009ce:	39 f9                	cmp    %edi,%ecx
f01009d0:	75 ee                	jne    f01009c0 <stab_binsearch+0x40>
f01009d2:	eb 05                	jmp    f01009d9 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009d4:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009d7:	eb 4b                	jmp    f0100a24 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009d9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009dc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009df:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009e3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009e6:	76 11                	jbe    f01009f9 <stab_binsearch+0x79>
			*region_left = m;
f01009e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009eb:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009ed:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009f0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009f7:	eb 2b                	jmp    f0100a24 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01009f9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009fc:	73 14                	jae    f0100a12 <stab_binsearch+0x92>
			*region_right = m - 1;
f01009fe:	83 e8 01             	sub    $0x1,%eax
f0100a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a04:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a07:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a09:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a10:	eb 12                	jmp    f0100a24 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a12:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a15:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a17:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a1b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a1d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a24:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a27:	0f 8e 78 ff ff ff    	jle    f01009a5 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a2d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a31:	75 0f                	jne    f0100a42 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a36:	8b 00                	mov    (%eax),%eax
f0100a38:	83 e8 01             	sub    $0x1,%eax
f0100a3b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a3e:	89 06                	mov    %eax,(%esi)
f0100a40:	eb 2c                	jmp    f0100a6e <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a42:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a45:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a47:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a4a:	8b 0e                	mov    (%esi),%ecx
f0100a4c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a4f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a52:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a55:	eb 03                	jmp    f0100a5a <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a57:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a5a:	39 c8                	cmp    %ecx,%eax
f0100a5c:	7e 0b                	jle    f0100a69 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a5e:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a62:	83 ea 0c             	sub    $0xc,%edx
f0100a65:	39 df                	cmp    %ebx,%edi
f0100a67:	75 ee                	jne    f0100a57 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a69:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a6c:	89 06                	mov    %eax,(%esi)
	}
}
f0100a6e:	83 c4 14             	add    $0x14,%esp
f0100a71:	5b                   	pop    %ebx
f0100a72:	5e                   	pop    %esi
f0100a73:	5f                   	pop    %edi
f0100a74:	5d                   	pop    %ebp
f0100a75:	c3                   	ret    

f0100a76 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a76:	55                   	push   %ebp
f0100a77:	89 e5                	mov    %esp,%ebp
f0100a79:	57                   	push   %edi
f0100a7a:	56                   	push   %esi
f0100a7b:	53                   	push   %ebx
f0100a7c:	83 ec 3c             	sub    $0x3c,%esp
f0100a7f:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a85:	c7 03 78 1e 10 f0    	movl   $0xf0101e78,(%ebx)
	info->eip_line = 0;
f0100a8b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a92:	c7 43 08 78 1e 10 f0 	movl   $0xf0101e78,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a99:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100aa0:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100aa3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aaa:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ab0:	76 11                	jbe    f0100ac3 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ab2:	b8 e6 73 10 f0       	mov    $0xf01073e6,%eax
f0100ab7:	3d c5 5a 10 f0       	cmp    $0xf0105ac5,%eax
f0100abc:	77 19                	ja     f0100ad7 <debuginfo_eip+0x61>
f0100abe:	e9 aa 01 00 00       	jmp    f0100c6d <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ac3:	83 ec 04             	sub    $0x4,%esp
f0100ac6:	68 82 1e 10 f0       	push   $0xf0101e82
f0100acb:	6a 7f                	push   $0x7f
f0100acd:	68 8f 1e 10 f0       	push   $0xf0101e8f
f0100ad2:	e8 0f f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ad7:	80 3d e5 73 10 f0 00 	cmpb   $0x0,0xf01073e5
f0100ade:	0f 85 90 01 00 00    	jne    f0100c74 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ae4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100aeb:	b8 c4 5a 10 f0       	mov    $0xf0105ac4,%eax
f0100af0:	2d b0 20 10 f0       	sub    $0xf01020b0,%eax
f0100af5:	c1 f8 02             	sar    $0x2,%eax
f0100af8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100afe:	83 e8 01             	sub    $0x1,%eax
f0100b01:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b04:	83 ec 08             	sub    $0x8,%esp
f0100b07:	56                   	push   %esi
f0100b08:	6a 64                	push   $0x64
f0100b0a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b0d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b10:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100b15:	e8 66 fe ff ff       	call   f0100980 <stab_binsearch>
	if (lfile == 0)
f0100b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b1d:	83 c4 10             	add    $0x10,%esp
f0100b20:	85 c0                	test   %eax,%eax
f0100b22:	0f 84 53 01 00 00    	je     f0100c7b <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b28:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b31:	83 ec 08             	sub    $0x8,%esp
f0100b34:	56                   	push   %esi
f0100b35:	6a 24                	push   $0x24
f0100b37:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b3a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b3d:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100b42:	e8 39 fe ff ff       	call   f0100980 <stab_binsearch>

	if (lfun <= rfun) {
f0100b47:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b4d:	83 c4 10             	add    $0x10,%esp
f0100b50:	39 d0                	cmp    %edx,%eax
f0100b52:	7f 40                	jg     f0100b94 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b54:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b57:	c1 e1 02             	shl    $0x2,%ecx
f0100b5a:	8d b9 b0 20 10 f0    	lea    -0xfefdf50(%ecx),%edi
f0100b60:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b63:	8b b9 b0 20 10 f0    	mov    -0xfefdf50(%ecx),%edi
f0100b69:	b9 e6 73 10 f0       	mov    $0xf01073e6,%ecx
f0100b6e:	81 e9 c5 5a 10 f0    	sub    $0xf0105ac5,%ecx
f0100b74:	39 cf                	cmp    %ecx,%edi
f0100b76:	73 09                	jae    f0100b81 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b78:	81 c7 c5 5a 10 f0    	add    $0xf0105ac5,%edi
f0100b7e:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b81:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100b84:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b87:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100b8a:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100b8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100b8f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100b92:	eb 0f                	jmp    f0100ba3 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b94:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100b9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ba3:	83 ec 08             	sub    $0x8,%esp
f0100ba6:	6a 3a                	push   $0x3a
f0100ba8:	ff 73 08             	pushl  0x8(%ebx)
f0100bab:	e8 00 09 00 00       	call   f01014b0 <strfind>
f0100bb0:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bb3:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bb6:	83 c4 08             	add    $0x8,%esp
f0100bb9:	56                   	push   %esi
f0100bba:	6a 44                	push   $0x44
f0100bbc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bbf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100bc2:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100bc7:	e8 b4 fd ff ff       	call   f0100980 <stab_binsearch>
	if (lline != rline) return -1;
f0100bcc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100bcf:	83 c4 10             	add    $0x10,%esp
f0100bd2:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100bd5:	0f 85 a7 00 00 00    	jne    f0100c82 <debuginfo_eip+0x20c>
	info->eip_line = stabs[lline].n_desc;
f0100bdb:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100bde:	8d 04 85 b0 20 10 f0 	lea    -0xfefdf50(,%eax,4),%eax
f0100be5:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100be9:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bef:	eb 06                	jmp    f0100bf7 <debuginfo_eip+0x181>
f0100bf1:	83 ea 01             	sub    $0x1,%edx
f0100bf4:	83 e8 0c             	sub    $0xc,%eax
f0100bf7:	39 d6                	cmp    %edx,%esi
f0100bf9:	7f 34                	jg     f0100c2f <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100bfb:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100bff:	80 f9 84             	cmp    $0x84,%cl
f0100c02:	74 0b                	je     f0100c0f <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c04:	80 f9 64             	cmp    $0x64,%cl
f0100c07:	75 e8                	jne    f0100bf1 <debuginfo_eip+0x17b>
f0100c09:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c0d:	74 e2                	je     f0100bf1 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c0f:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c12:	8b 14 85 b0 20 10 f0 	mov    -0xfefdf50(,%eax,4),%edx
f0100c19:	b8 e6 73 10 f0       	mov    $0xf01073e6,%eax
f0100c1e:	2d c5 5a 10 f0       	sub    $0xf0105ac5,%eax
f0100c23:	39 c2                	cmp    %eax,%edx
f0100c25:	73 08                	jae    f0100c2f <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c27:	81 c2 c5 5a 10 f0    	add    $0xf0105ac5,%edx
f0100c2d:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c32:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c35:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c3a:	39 f2                	cmp    %esi,%edx
f0100c3c:	7d 50                	jge    f0100c8e <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100c3e:	83 c2 01             	add    $0x1,%edx
f0100c41:	89 d0                	mov    %edx,%eax
f0100c43:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c46:	8d 14 95 b0 20 10 f0 	lea    -0xfefdf50(,%edx,4),%edx
f0100c4d:	eb 04                	jmp    f0100c53 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c4f:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c53:	39 c6                	cmp    %eax,%esi
f0100c55:	7e 32                	jle    f0100c89 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c57:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c5b:	83 c0 01             	add    $0x1,%eax
f0100c5e:	83 c2 0c             	add    $0xc,%edx
f0100c61:	80 f9 a0             	cmp    $0xa0,%cl
f0100c64:	74 e9                	je     f0100c4f <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c66:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c6b:	eb 21                	jmp    f0100c8e <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c72:	eb 1a                	jmp    f0100c8e <debuginfo_eip+0x218>
f0100c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c79:	eb 13                	jmp    f0100c8e <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c80:	eb 0c                	jmp    f0100c8e <debuginfo_eip+0x218>
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline != rline) return -1;
f0100c82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c87:	eb 05                	jmp    f0100c8e <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c89:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c91:	5b                   	pop    %ebx
f0100c92:	5e                   	pop    %esi
f0100c93:	5f                   	pop    %edi
f0100c94:	5d                   	pop    %ebp
f0100c95:	c3                   	ret    

f0100c96 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c96:	55                   	push   %ebp
f0100c97:	89 e5                	mov    %esp,%ebp
f0100c99:	57                   	push   %edi
f0100c9a:	56                   	push   %esi
f0100c9b:	53                   	push   %ebx
f0100c9c:	83 ec 1c             	sub    $0x1c,%esp
f0100c9f:	89 c7                	mov    %eax,%edi
f0100ca1:	89 d6                	mov    %edx,%esi
f0100ca3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ca9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cac:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100caf:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cb2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cb7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cba:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cbd:	39 d3                	cmp    %edx,%ebx
f0100cbf:	72 05                	jb     f0100cc6 <printnum+0x30>
f0100cc1:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cc4:	77 45                	ja     f0100d0b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cc6:	83 ec 0c             	sub    $0xc,%esp
f0100cc9:	ff 75 18             	pushl  0x18(%ebp)
f0100ccc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ccf:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100cd2:	53                   	push   %ebx
f0100cd3:	ff 75 10             	pushl  0x10(%ebp)
f0100cd6:	83 ec 08             	sub    $0x8,%esp
f0100cd9:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cdc:	ff 75 e0             	pushl  -0x20(%ebp)
f0100cdf:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ce2:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ce5:	e8 e6 09 00 00       	call   f01016d0 <__udivdi3>
f0100cea:	83 c4 18             	add    $0x18,%esp
f0100ced:	52                   	push   %edx
f0100cee:	50                   	push   %eax
f0100cef:	89 f2                	mov    %esi,%edx
f0100cf1:	89 f8                	mov    %edi,%eax
f0100cf3:	e8 9e ff ff ff       	call   f0100c96 <printnum>
f0100cf8:	83 c4 20             	add    $0x20,%esp
f0100cfb:	eb 18                	jmp    f0100d15 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100cfd:	83 ec 08             	sub    $0x8,%esp
f0100d00:	56                   	push   %esi
f0100d01:	ff 75 18             	pushl  0x18(%ebp)
f0100d04:	ff d7                	call   *%edi
f0100d06:	83 c4 10             	add    $0x10,%esp
f0100d09:	eb 03                	jmp    f0100d0e <printnum+0x78>
f0100d0b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d0e:	83 eb 01             	sub    $0x1,%ebx
f0100d11:	85 db                	test   %ebx,%ebx
f0100d13:	7f e8                	jg     f0100cfd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d15:	83 ec 08             	sub    $0x8,%esp
f0100d18:	56                   	push   %esi
f0100d19:	83 ec 04             	sub    $0x4,%esp
f0100d1c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d1f:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d22:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d25:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d28:	e8 d3 0a 00 00       	call   f0101800 <__umoddi3>
f0100d2d:	83 c4 14             	add    $0x14,%esp
f0100d30:	0f be 80 9d 1e 10 f0 	movsbl -0xfefe163(%eax),%eax
f0100d37:	50                   	push   %eax
f0100d38:	ff d7                	call   *%edi
}
f0100d3a:	83 c4 10             	add    $0x10,%esp
f0100d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d40:	5b                   	pop    %ebx
f0100d41:	5e                   	pop    %esi
f0100d42:	5f                   	pop    %edi
f0100d43:	5d                   	pop    %ebp
f0100d44:	c3                   	ret    

f0100d45 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d45:	55                   	push   %ebp
f0100d46:	89 e5                	mov    %esp,%ebp
f0100d48:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d4b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d4f:	8b 10                	mov    (%eax),%edx
f0100d51:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d54:	73 0a                	jae    f0100d60 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d56:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100d59:	89 08                	mov    %ecx,(%eax)
f0100d5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d5e:	88 02                	mov    %al,(%edx)
}
f0100d60:	5d                   	pop    %ebp
f0100d61:	c3                   	ret    

f0100d62 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100d62:	55                   	push   %ebp
f0100d63:	89 e5                	mov    %esp,%ebp
f0100d65:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d68:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d6b:	50                   	push   %eax
f0100d6c:	ff 75 10             	pushl  0x10(%ebp)
f0100d6f:	ff 75 0c             	pushl  0xc(%ebp)
f0100d72:	ff 75 08             	pushl  0x8(%ebp)
f0100d75:	e8 05 00 00 00       	call   f0100d7f <vprintfmt>
	va_end(ap);
}
f0100d7a:	83 c4 10             	add    $0x10,%esp
f0100d7d:	c9                   	leave  
f0100d7e:	c3                   	ret    

f0100d7f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d7f:	55                   	push   %ebp
f0100d80:	89 e5                	mov    %esp,%ebp
f0100d82:	57                   	push   %edi
f0100d83:	56                   	push   %esi
f0100d84:	53                   	push   %ebx
f0100d85:	83 ec 2c             	sub    $0x2c,%esp
f0100d88:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d8e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100d91:	eb 12                	jmp    f0100da5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100d93:	85 c0                	test   %eax,%eax
f0100d95:	0f 84 6a 04 00 00    	je     f0101205 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
f0100d9b:	83 ec 08             	sub    $0x8,%esp
f0100d9e:	53                   	push   %ebx
f0100d9f:	50                   	push   %eax
f0100da0:	ff d6                	call   *%esi
f0100da2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100da5:	83 c7 01             	add    $0x1,%edi
f0100da8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100dac:	83 f8 25             	cmp    $0x25,%eax
f0100daf:	75 e2                	jne    f0100d93 <vprintfmt+0x14>
f0100db1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100db5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100dbc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100dc3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100dca:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100dcf:	eb 07                	jmp    f0100dd8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100dd4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dd8:	8d 47 01             	lea    0x1(%edi),%eax
f0100ddb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100dde:	0f b6 07             	movzbl (%edi),%eax
f0100de1:	0f b6 d0             	movzbl %al,%edx
f0100de4:	83 e8 23             	sub    $0x23,%eax
f0100de7:	3c 55                	cmp    $0x55,%al
f0100de9:	0f 87 fb 03 00 00    	ja     f01011ea <vprintfmt+0x46b>
f0100def:	0f b6 c0             	movzbl %al,%eax
f0100df2:	ff 24 85 2c 1f 10 f0 	jmp    *-0xfefe0d4(,%eax,4)
f0100df9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100dfc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e00:	eb d6                	jmp    f0100dd8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e05:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e0a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e0d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e10:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100e14:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100e17:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100e1a:	83 f9 09             	cmp    $0x9,%ecx
f0100e1d:	77 3f                	ja     f0100e5e <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e1f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e22:	eb e9                	jmp    f0100e0d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e24:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e27:	8b 00                	mov    (%eax),%eax
f0100e29:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e2f:	8d 40 04             	lea    0x4(%eax),%eax
f0100e32:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e38:	eb 2a                	jmp    f0100e64 <vprintfmt+0xe5>
f0100e3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e3d:	85 c0                	test   %eax,%eax
f0100e3f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e44:	0f 49 d0             	cmovns %eax,%edx
f0100e47:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e4d:	eb 89                	jmp    f0100dd8 <vprintfmt+0x59>
f0100e4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e52:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100e59:	e9 7a ff ff ff       	jmp    f0100dd8 <vprintfmt+0x59>
f0100e5e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100e61:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100e64:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e68:	0f 89 6a ff ff ff    	jns    f0100dd8 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100e6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100e71:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e74:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e7b:	e9 58 ff ff ff       	jmp    f0100dd8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e80:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100e86:	e9 4d ff ff ff       	jmp    f0100dd8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e8e:	8d 78 04             	lea    0x4(%eax),%edi
f0100e91:	83 ec 08             	sub    $0x8,%esp
f0100e94:	53                   	push   %ebx
f0100e95:	ff 30                	pushl  (%eax)
f0100e97:	ff d6                	call   *%esi
			break;
f0100e99:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e9c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100ea2:	e9 fe fe ff ff       	jmp    f0100da5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ea7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eaa:	8d 78 04             	lea    0x4(%eax),%edi
f0100ead:	8b 00                	mov    (%eax),%eax
f0100eaf:	99                   	cltd   
f0100eb0:	31 d0                	xor    %edx,%eax
f0100eb2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100eb4:	83 f8 06             	cmp    $0x6,%eax
f0100eb7:	7f 0b                	jg     f0100ec4 <vprintfmt+0x145>
f0100eb9:	8b 14 85 84 20 10 f0 	mov    -0xfefdf7c(,%eax,4),%edx
f0100ec0:	85 d2                	test   %edx,%edx
f0100ec2:	75 1b                	jne    f0100edf <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0100ec4:	50                   	push   %eax
f0100ec5:	68 b5 1e 10 f0       	push   $0xf0101eb5
f0100eca:	53                   	push   %ebx
f0100ecb:	56                   	push   %esi
f0100ecc:	e8 91 fe ff ff       	call   f0100d62 <printfmt>
f0100ed1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ed4:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100eda:	e9 c6 fe ff ff       	jmp    f0100da5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100edf:	52                   	push   %edx
f0100ee0:	68 be 1e 10 f0       	push   $0xf0101ebe
f0100ee5:	53                   	push   %ebx
f0100ee6:	56                   	push   %esi
f0100ee7:	e8 76 fe ff ff       	call   f0100d62 <printfmt>
f0100eec:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100eef:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ef2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ef5:	e9 ab fe ff ff       	jmp    f0100da5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100efa:	8b 45 14             	mov    0x14(%ebp),%eax
f0100efd:	83 c0 04             	add    $0x4,%eax
f0100f00:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f03:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f06:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f08:	85 ff                	test   %edi,%edi
f0100f0a:	b8 ae 1e 10 f0       	mov    $0xf0101eae,%eax
f0100f0f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f12:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f16:	0f 8e 94 00 00 00    	jle    f0100fb0 <vprintfmt+0x231>
f0100f1c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f20:	0f 84 98 00 00 00    	je     f0100fbe <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f26:	83 ec 08             	sub    $0x8,%esp
f0100f29:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f2c:	57                   	push   %edi
f0100f2d:	e8 34 04 00 00       	call   f0101366 <strnlen>
f0100f32:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f35:	29 c1                	sub    %eax,%ecx
f0100f37:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100f3a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f3d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f41:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f44:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f47:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f49:	eb 0f                	jmp    f0100f5a <vprintfmt+0x1db>
					putch(padc, putdat);
f0100f4b:	83 ec 08             	sub    $0x8,%esp
f0100f4e:	53                   	push   %ebx
f0100f4f:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f52:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f54:	83 ef 01             	sub    $0x1,%edi
f0100f57:	83 c4 10             	add    $0x10,%esp
f0100f5a:	85 ff                	test   %edi,%edi
f0100f5c:	7f ed                	jg     f0100f4b <vprintfmt+0x1cc>
f0100f5e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f61:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100f64:	85 c9                	test   %ecx,%ecx
f0100f66:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f6b:	0f 49 c1             	cmovns %ecx,%eax
f0100f6e:	29 c1                	sub    %eax,%ecx
f0100f70:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f73:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f76:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f79:	89 cb                	mov    %ecx,%ebx
f0100f7b:	eb 4d                	jmp    f0100fca <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100f7d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100f81:	74 1b                	je     f0100f9e <vprintfmt+0x21f>
f0100f83:	0f be c0             	movsbl %al,%eax
f0100f86:	83 e8 20             	sub    $0x20,%eax
f0100f89:	83 f8 5e             	cmp    $0x5e,%eax
f0100f8c:	76 10                	jbe    f0100f9e <vprintfmt+0x21f>
					putch('?', putdat);
f0100f8e:	83 ec 08             	sub    $0x8,%esp
f0100f91:	ff 75 0c             	pushl  0xc(%ebp)
f0100f94:	6a 3f                	push   $0x3f
f0100f96:	ff 55 08             	call   *0x8(%ebp)
f0100f99:	83 c4 10             	add    $0x10,%esp
f0100f9c:	eb 0d                	jmp    f0100fab <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0100f9e:	83 ec 08             	sub    $0x8,%esp
f0100fa1:	ff 75 0c             	pushl  0xc(%ebp)
f0100fa4:	52                   	push   %edx
f0100fa5:	ff 55 08             	call   *0x8(%ebp)
f0100fa8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fab:	83 eb 01             	sub    $0x1,%ebx
f0100fae:	eb 1a                	jmp    f0100fca <vprintfmt+0x24b>
f0100fb0:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fb3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fb6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fb9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100fbc:	eb 0c                	jmp    f0100fca <vprintfmt+0x24b>
f0100fbe:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fc1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fc4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fc7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100fca:	83 c7 01             	add    $0x1,%edi
f0100fcd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100fd1:	0f be d0             	movsbl %al,%edx
f0100fd4:	85 d2                	test   %edx,%edx
f0100fd6:	74 23                	je     f0100ffb <vprintfmt+0x27c>
f0100fd8:	85 f6                	test   %esi,%esi
f0100fda:	78 a1                	js     f0100f7d <vprintfmt+0x1fe>
f0100fdc:	83 ee 01             	sub    $0x1,%esi
f0100fdf:	79 9c                	jns    f0100f7d <vprintfmt+0x1fe>
f0100fe1:	89 df                	mov    %ebx,%edi
f0100fe3:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fe6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100fe9:	eb 18                	jmp    f0101003 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100feb:	83 ec 08             	sub    $0x8,%esp
f0100fee:	53                   	push   %ebx
f0100fef:	6a 20                	push   $0x20
f0100ff1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100ff3:	83 ef 01             	sub    $0x1,%edi
f0100ff6:	83 c4 10             	add    $0x10,%esp
f0100ff9:	eb 08                	jmp    f0101003 <vprintfmt+0x284>
f0100ffb:	89 df                	mov    %ebx,%edi
f0100ffd:	8b 75 08             	mov    0x8(%ebp),%esi
f0101000:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101003:	85 ff                	test   %edi,%edi
f0101005:	7f e4                	jg     f0100feb <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101007:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010100a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010100d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101010:	e9 90 fd ff ff       	jmp    f0100da5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101015:	83 f9 01             	cmp    $0x1,%ecx
f0101018:	7e 19                	jle    f0101033 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f010101a:	8b 45 14             	mov    0x14(%ebp),%eax
f010101d:	8b 50 04             	mov    0x4(%eax),%edx
f0101020:	8b 00                	mov    (%eax),%eax
f0101022:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101025:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101028:	8b 45 14             	mov    0x14(%ebp),%eax
f010102b:	8d 40 08             	lea    0x8(%eax),%eax
f010102e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101031:	eb 38                	jmp    f010106b <vprintfmt+0x2ec>
	else if (lflag)
f0101033:	85 c9                	test   %ecx,%ecx
f0101035:	74 1b                	je     f0101052 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0101037:	8b 45 14             	mov    0x14(%ebp),%eax
f010103a:	8b 00                	mov    (%eax),%eax
f010103c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010103f:	89 c1                	mov    %eax,%ecx
f0101041:	c1 f9 1f             	sar    $0x1f,%ecx
f0101044:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101047:	8b 45 14             	mov    0x14(%ebp),%eax
f010104a:	8d 40 04             	lea    0x4(%eax),%eax
f010104d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101050:	eb 19                	jmp    f010106b <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0101052:	8b 45 14             	mov    0x14(%ebp),%eax
f0101055:	8b 00                	mov    (%eax),%eax
f0101057:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010105a:	89 c1                	mov    %eax,%ecx
f010105c:	c1 f9 1f             	sar    $0x1f,%ecx
f010105f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101062:	8b 45 14             	mov    0x14(%ebp),%eax
f0101065:	8d 40 04             	lea    0x4(%eax),%eax
f0101068:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010106b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010106e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101071:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101076:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010107a:	0f 89 36 01 00 00    	jns    f01011b6 <vprintfmt+0x437>
				putch('-', putdat);
f0101080:	83 ec 08             	sub    $0x8,%esp
f0101083:	53                   	push   %ebx
f0101084:	6a 2d                	push   $0x2d
f0101086:	ff d6                	call   *%esi
				num = -(long long) num;
f0101088:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010108b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010108e:	f7 da                	neg    %edx
f0101090:	83 d1 00             	adc    $0x0,%ecx
f0101093:	f7 d9                	neg    %ecx
f0101095:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101098:	b8 0a 00 00 00       	mov    $0xa,%eax
f010109d:	e9 14 01 00 00       	jmp    f01011b6 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010a2:	83 f9 01             	cmp    $0x1,%ecx
f01010a5:	7e 18                	jle    f01010bf <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f01010a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010aa:	8b 10                	mov    (%eax),%edx
f01010ac:	8b 48 04             	mov    0x4(%eax),%ecx
f01010af:	8d 40 08             	lea    0x8(%eax),%eax
f01010b2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01010b5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010ba:	e9 f7 00 00 00       	jmp    f01011b6 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01010bf:	85 c9                	test   %ecx,%ecx
f01010c1:	74 1a                	je     f01010dd <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f01010c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c6:	8b 10                	mov    (%eax),%edx
f01010c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010cd:	8d 40 04             	lea    0x4(%eax),%eax
f01010d0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01010d3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010d8:	e9 d9 00 00 00       	jmp    f01011b6 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01010dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e0:	8b 10                	mov    (%eax),%edx
f01010e2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010e7:	8d 40 04             	lea    0x4(%eax),%eax
f01010ea:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01010ed:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010f2:	e9 bf 00 00 00       	jmp    f01011b6 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010f7:	83 f9 01             	cmp    $0x1,%ecx
f01010fa:	7e 13                	jle    f010110f <vprintfmt+0x390>
		return va_arg(*ap, long long);
f01010fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ff:	8b 50 04             	mov    0x4(%eax),%edx
f0101102:	8b 00                	mov    (%eax),%eax
f0101104:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101107:	8d 49 08             	lea    0x8(%ecx),%ecx
f010110a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010110d:	eb 28                	jmp    f0101137 <vprintfmt+0x3b8>
	else if (lflag)
f010110f:	85 c9                	test   %ecx,%ecx
f0101111:	74 13                	je     f0101126 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
f0101113:	8b 45 14             	mov    0x14(%ebp),%eax
f0101116:	8b 10                	mov    (%eax),%edx
f0101118:	89 d0                	mov    %edx,%eax
f010111a:	99                   	cltd   
f010111b:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010111e:	8d 49 04             	lea    0x4(%ecx),%ecx
f0101121:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101124:	eb 11                	jmp    f0101137 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
f0101126:	8b 45 14             	mov    0x14(%ebp),%eax
f0101129:	8b 10                	mov    (%eax),%edx
f010112b:	89 d0                	mov    %edx,%eax
f010112d:	99                   	cltd   
f010112e:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101131:	8d 49 04             	lea    0x4(%ecx),%ecx
f0101134:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
f0101137:	89 d1                	mov    %edx,%ecx
f0101139:	89 c2                	mov    %eax,%edx
			base = 8;
f010113b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0101140:	eb 74                	jmp    f01011b6 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0101142:	83 ec 08             	sub    $0x8,%esp
f0101145:	53                   	push   %ebx
f0101146:	6a 30                	push   $0x30
f0101148:	ff d6                	call   *%esi
			putch('x', putdat);
f010114a:	83 c4 08             	add    $0x8,%esp
f010114d:	53                   	push   %ebx
f010114e:	6a 78                	push   $0x78
f0101150:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101152:	8b 45 14             	mov    0x14(%ebp),%eax
f0101155:	8b 10                	mov    (%eax),%edx
f0101157:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010115c:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010115f:	8d 40 04             	lea    0x4(%eax),%eax
f0101162:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101165:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010116a:	eb 4a                	jmp    f01011b6 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010116c:	83 f9 01             	cmp    $0x1,%ecx
f010116f:	7e 15                	jle    f0101186 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
f0101171:	8b 45 14             	mov    0x14(%ebp),%eax
f0101174:	8b 10                	mov    (%eax),%edx
f0101176:	8b 48 04             	mov    0x4(%eax),%ecx
f0101179:	8d 40 08             	lea    0x8(%eax),%eax
f010117c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010117f:	b8 10 00 00 00       	mov    $0x10,%eax
f0101184:	eb 30                	jmp    f01011b6 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0101186:	85 c9                	test   %ecx,%ecx
f0101188:	74 17                	je     f01011a1 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
f010118a:	8b 45 14             	mov    0x14(%ebp),%eax
f010118d:	8b 10                	mov    (%eax),%edx
f010118f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101194:	8d 40 04             	lea    0x4(%eax),%eax
f0101197:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010119a:	b8 10 00 00 00       	mov    $0x10,%eax
f010119f:	eb 15                	jmp    f01011b6 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01011a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01011a4:	8b 10                	mov    (%eax),%edx
f01011a6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011ab:	8d 40 04             	lea    0x4(%eax),%eax
f01011ae:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01011b1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01011b6:	83 ec 0c             	sub    $0xc,%esp
f01011b9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01011bd:	57                   	push   %edi
f01011be:	ff 75 e0             	pushl  -0x20(%ebp)
f01011c1:	50                   	push   %eax
f01011c2:	51                   	push   %ecx
f01011c3:	52                   	push   %edx
f01011c4:	89 da                	mov    %ebx,%edx
f01011c6:	89 f0                	mov    %esi,%eax
f01011c8:	e8 c9 fa ff ff       	call   f0100c96 <printnum>
			break;
f01011cd:	83 c4 20             	add    $0x20,%esp
f01011d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011d3:	e9 cd fb ff ff       	jmp    f0100da5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011d8:	83 ec 08             	sub    $0x8,%esp
f01011db:	53                   	push   %ebx
f01011dc:	52                   	push   %edx
f01011dd:	ff d6                	call   *%esi
			break;
f01011df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01011e5:	e9 bb fb ff ff       	jmp    f0100da5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011ea:	83 ec 08             	sub    $0x8,%esp
f01011ed:	53                   	push   %ebx
f01011ee:	6a 25                	push   $0x25
f01011f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011f2:	83 c4 10             	add    $0x10,%esp
f01011f5:	eb 03                	jmp    f01011fa <vprintfmt+0x47b>
f01011f7:	83 ef 01             	sub    $0x1,%edi
f01011fa:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01011fe:	75 f7                	jne    f01011f7 <vprintfmt+0x478>
f0101200:	e9 a0 fb ff ff       	jmp    f0100da5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101205:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101208:	5b                   	pop    %ebx
f0101209:	5e                   	pop    %esi
f010120a:	5f                   	pop    %edi
f010120b:	5d                   	pop    %ebp
f010120c:	c3                   	ret    

f010120d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010120d:	55                   	push   %ebp
f010120e:	89 e5                	mov    %esp,%ebp
f0101210:	83 ec 18             	sub    $0x18,%esp
f0101213:	8b 45 08             	mov    0x8(%ebp),%eax
f0101216:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101219:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010121c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101220:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101223:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010122a:	85 c0                	test   %eax,%eax
f010122c:	74 26                	je     f0101254 <vsnprintf+0x47>
f010122e:	85 d2                	test   %edx,%edx
f0101230:	7e 22                	jle    f0101254 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101232:	ff 75 14             	pushl  0x14(%ebp)
f0101235:	ff 75 10             	pushl  0x10(%ebp)
f0101238:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010123b:	50                   	push   %eax
f010123c:	68 45 0d 10 f0       	push   $0xf0100d45
f0101241:	e8 39 fb ff ff       	call   f0100d7f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101246:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101249:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010124f:	83 c4 10             	add    $0x10,%esp
f0101252:	eb 05                	jmp    f0101259 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101259:	c9                   	leave  
f010125a:	c3                   	ret    

f010125b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010125b:	55                   	push   %ebp
f010125c:	89 e5                	mov    %esp,%ebp
f010125e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101261:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101264:	50                   	push   %eax
f0101265:	ff 75 10             	pushl  0x10(%ebp)
f0101268:	ff 75 0c             	pushl  0xc(%ebp)
f010126b:	ff 75 08             	pushl  0x8(%ebp)
f010126e:	e8 9a ff ff ff       	call   f010120d <vsnprintf>
	va_end(ap);

	return rc;
}
f0101273:	c9                   	leave  
f0101274:	c3                   	ret    

f0101275 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101275:	55                   	push   %ebp
f0101276:	89 e5                	mov    %esp,%ebp
f0101278:	57                   	push   %edi
f0101279:	56                   	push   %esi
f010127a:	53                   	push   %ebx
f010127b:	83 ec 0c             	sub    $0xc,%esp
f010127e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101281:	85 c0                	test   %eax,%eax
f0101283:	74 11                	je     f0101296 <readline+0x21>
		cprintf("%s", prompt);
f0101285:	83 ec 08             	sub    $0x8,%esp
f0101288:	50                   	push   %eax
f0101289:	68 be 1e 10 f0       	push   $0xf0101ebe
f010128e:	e8 d9 f6 ff ff       	call   f010096c <cprintf>
f0101293:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101296:	83 ec 0c             	sub    $0xc,%esp
f0101299:	6a 00                	push   $0x0
f010129b:	e8 dc f3 ff ff       	call   f010067c <iscons>
f01012a0:	89 c7                	mov    %eax,%edi
f01012a2:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01012a5:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01012aa:	e8 bc f3 ff ff       	call   f010066b <getchar>
f01012af:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012b1:	85 c0                	test   %eax,%eax
f01012b3:	79 18                	jns    f01012cd <readline+0x58>
			cprintf("read error: %e\n", c);
f01012b5:	83 ec 08             	sub    $0x8,%esp
f01012b8:	50                   	push   %eax
f01012b9:	68 a0 20 10 f0       	push   $0xf01020a0
f01012be:	e8 a9 f6 ff ff       	call   f010096c <cprintf>
			return NULL;
f01012c3:	83 c4 10             	add    $0x10,%esp
f01012c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012cb:	eb 79                	jmp    f0101346 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012cd:	83 f8 08             	cmp    $0x8,%eax
f01012d0:	0f 94 c2             	sete   %dl
f01012d3:	83 f8 7f             	cmp    $0x7f,%eax
f01012d6:	0f 94 c0             	sete   %al
f01012d9:	08 c2                	or     %al,%dl
f01012db:	74 1a                	je     f01012f7 <readline+0x82>
f01012dd:	85 f6                	test   %esi,%esi
f01012df:	7e 16                	jle    f01012f7 <readline+0x82>
			if (echoing)
f01012e1:	85 ff                	test   %edi,%edi
f01012e3:	74 0d                	je     f01012f2 <readline+0x7d>
				cputchar('\b');
f01012e5:	83 ec 0c             	sub    $0xc,%esp
f01012e8:	6a 08                	push   $0x8
f01012ea:	e8 6c f3 ff ff       	call   f010065b <cputchar>
f01012ef:	83 c4 10             	add    $0x10,%esp
			i--;
f01012f2:	83 ee 01             	sub    $0x1,%esi
f01012f5:	eb b3                	jmp    f01012aa <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012f7:	83 fb 1f             	cmp    $0x1f,%ebx
f01012fa:	7e 23                	jle    f010131f <readline+0xaa>
f01012fc:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101302:	7f 1b                	jg     f010131f <readline+0xaa>
			if (echoing)
f0101304:	85 ff                	test   %edi,%edi
f0101306:	74 0c                	je     f0101314 <readline+0x9f>
				cputchar(c);
f0101308:	83 ec 0c             	sub    $0xc,%esp
f010130b:	53                   	push   %ebx
f010130c:	e8 4a f3 ff ff       	call   f010065b <cputchar>
f0101311:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101314:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f010131a:	8d 76 01             	lea    0x1(%esi),%esi
f010131d:	eb 8b                	jmp    f01012aa <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010131f:	83 fb 0a             	cmp    $0xa,%ebx
f0101322:	74 05                	je     f0101329 <readline+0xb4>
f0101324:	83 fb 0d             	cmp    $0xd,%ebx
f0101327:	75 81                	jne    f01012aa <readline+0x35>
			if (echoing)
f0101329:	85 ff                	test   %edi,%edi
f010132b:	74 0d                	je     f010133a <readline+0xc5>
				cputchar('\n');
f010132d:	83 ec 0c             	sub    $0xc,%esp
f0101330:	6a 0a                	push   $0xa
f0101332:	e8 24 f3 ff ff       	call   f010065b <cputchar>
f0101337:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010133a:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101341:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101346:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101349:	5b                   	pop    %ebx
f010134a:	5e                   	pop    %esi
f010134b:	5f                   	pop    %edi
f010134c:	5d                   	pop    %ebp
f010134d:	c3                   	ret    

f010134e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010134e:	55                   	push   %ebp
f010134f:	89 e5                	mov    %esp,%ebp
f0101351:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101354:	b8 00 00 00 00       	mov    $0x0,%eax
f0101359:	eb 03                	jmp    f010135e <strlen+0x10>
		n++;
f010135b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010135e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101362:	75 f7                	jne    f010135b <strlen+0xd>
		n++;
	return n;
}
f0101364:	5d                   	pop    %ebp
f0101365:	c3                   	ret    

f0101366 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101366:	55                   	push   %ebp
f0101367:	89 e5                	mov    %esp,%ebp
f0101369:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010136c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010136f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101374:	eb 03                	jmp    f0101379 <strnlen+0x13>
		n++;
f0101376:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101379:	39 c2                	cmp    %eax,%edx
f010137b:	74 08                	je     f0101385 <strnlen+0x1f>
f010137d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101381:	75 f3                	jne    f0101376 <strnlen+0x10>
f0101383:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101385:	5d                   	pop    %ebp
f0101386:	c3                   	ret    

f0101387 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101387:	55                   	push   %ebp
f0101388:	89 e5                	mov    %esp,%ebp
f010138a:	53                   	push   %ebx
f010138b:	8b 45 08             	mov    0x8(%ebp),%eax
f010138e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101391:	89 c2                	mov    %eax,%edx
f0101393:	83 c2 01             	add    $0x1,%edx
f0101396:	83 c1 01             	add    $0x1,%ecx
f0101399:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010139d:	88 5a ff             	mov    %bl,-0x1(%edx)
f01013a0:	84 db                	test   %bl,%bl
f01013a2:	75 ef                	jne    f0101393 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01013a4:	5b                   	pop    %ebx
f01013a5:	5d                   	pop    %ebp
f01013a6:	c3                   	ret    

f01013a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01013a7:	55                   	push   %ebp
f01013a8:	89 e5                	mov    %esp,%ebp
f01013aa:	53                   	push   %ebx
f01013ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013ae:	53                   	push   %ebx
f01013af:	e8 9a ff ff ff       	call   f010134e <strlen>
f01013b4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01013b7:	ff 75 0c             	pushl  0xc(%ebp)
f01013ba:	01 d8                	add    %ebx,%eax
f01013bc:	50                   	push   %eax
f01013bd:	e8 c5 ff ff ff       	call   f0101387 <strcpy>
	return dst;
}
f01013c2:	89 d8                	mov    %ebx,%eax
f01013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013c7:	c9                   	leave  
f01013c8:	c3                   	ret    

f01013c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013c9:	55                   	push   %ebp
f01013ca:	89 e5                	mov    %esp,%ebp
f01013cc:	56                   	push   %esi
f01013cd:	53                   	push   %ebx
f01013ce:	8b 75 08             	mov    0x8(%ebp),%esi
f01013d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013d4:	89 f3                	mov    %esi,%ebx
f01013d6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013d9:	89 f2                	mov    %esi,%edx
f01013db:	eb 0f                	jmp    f01013ec <strncpy+0x23>
		*dst++ = *src;
f01013dd:	83 c2 01             	add    $0x1,%edx
f01013e0:	0f b6 01             	movzbl (%ecx),%eax
f01013e3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013e6:	80 39 01             	cmpb   $0x1,(%ecx)
f01013e9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013ec:	39 da                	cmp    %ebx,%edx
f01013ee:	75 ed                	jne    f01013dd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01013f0:	89 f0                	mov    %esi,%eax
f01013f2:	5b                   	pop    %ebx
f01013f3:	5e                   	pop    %esi
f01013f4:	5d                   	pop    %ebp
f01013f5:	c3                   	ret    

f01013f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013f6:	55                   	push   %ebp
f01013f7:	89 e5                	mov    %esp,%ebp
f01013f9:	56                   	push   %esi
f01013fa:	53                   	push   %ebx
f01013fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01013fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101401:	8b 55 10             	mov    0x10(%ebp),%edx
f0101404:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101406:	85 d2                	test   %edx,%edx
f0101408:	74 21                	je     f010142b <strlcpy+0x35>
f010140a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010140e:	89 f2                	mov    %esi,%edx
f0101410:	eb 09                	jmp    f010141b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101412:	83 c2 01             	add    $0x1,%edx
f0101415:	83 c1 01             	add    $0x1,%ecx
f0101418:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010141b:	39 c2                	cmp    %eax,%edx
f010141d:	74 09                	je     f0101428 <strlcpy+0x32>
f010141f:	0f b6 19             	movzbl (%ecx),%ebx
f0101422:	84 db                	test   %bl,%bl
f0101424:	75 ec                	jne    f0101412 <strlcpy+0x1c>
f0101426:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101428:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010142b:	29 f0                	sub    %esi,%eax
}
f010142d:	5b                   	pop    %ebx
f010142e:	5e                   	pop    %esi
f010142f:	5d                   	pop    %ebp
f0101430:	c3                   	ret    

f0101431 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101431:	55                   	push   %ebp
f0101432:	89 e5                	mov    %esp,%ebp
f0101434:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101437:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010143a:	eb 06                	jmp    f0101442 <strcmp+0x11>
		p++, q++;
f010143c:	83 c1 01             	add    $0x1,%ecx
f010143f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101442:	0f b6 01             	movzbl (%ecx),%eax
f0101445:	84 c0                	test   %al,%al
f0101447:	74 04                	je     f010144d <strcmp+0x1c>
f0101449:	3a 02                	cmp    (%edx),%al
f010144b:	74 ef                	je     f010143c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010144d:	0f b6 c0             	movzbl %al,%eax
f0101450:	0f b6 12             	movzbl (%edx),%edx
f0101453:	29 d0                	sub    %edx,%eax
}
f0101455:	5d                   	pop    %ebp
f0101456:	c3                   	ret    

f0101457 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101457:	55                   	push   %ebp
f0101458:	89 e5                	mov    %esp,%ebp
f010145a:	53                   	push   %ebx
f010145b:	8b 45 08             	mov    0x8(%ebp),%eax
f010145e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101461:	89 c3                	mov    %eax,%ebx
f0101463:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101466:	eb 06                	jmp    f010146e <strncmp+0x17>
		n--, p++, q++;
f0101468:	83 c0 01             	add    $0x1,%eax
f010146b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010146e:	39 d8                	cmp    %ebx,%eax
f0101470:	74 15                	je     f0101487 <strncmp+0x30>
f0101472:	0f b6 08             	movzbl (%eax),%ecx
f0101475:	84 c9                	test   %cl,%cl
f0101477:	74 04                	je     f010147d <strncmp+0x26>
f0101479:	3a 0a                	cmp    (%edx),%cl
f010147b:	74 eb                	je     f0101468 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010147d:	0f b6 00             	movzbl (%eax),%eax
f0101480:	0f b6 12             	movzbl (%edx),%edx
f0101483:	29 d0                	sub    %edx,%eax
f0101485:	eb 05                	jmp    f010148c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101487:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010148c:	5b                   	pop    %ebx
f010148d:	5d                   	pop    %ebp
f010148e:	c3                   	ret    

f010148f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010148f:	55                   	push   %ebp
f0101490:	89 e5                	mov    %esp,%ebp
f0101492:	8b 45 08             	mov    0x8(%ebp),%eax
f0101495:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101499:	eb 07                	jmp    f01014a2 <strchr+0x13>
		if (*s == c)
f010149b:	38 ca                	cmp    %cl,%dl
f010149d:	74 0f                	je     f01014ae <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010149f:	83 c0 01             	add    $0x1,%eax
f01014a2:	0f b6 10             	movzbl (%eax),%edx
f01014a5:	84 d2                	test   %dl,%dl
f01014a7:	75 f2                	jne    f010149b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01014a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014ae:	5d                   	pop    %ebp
f01014af:	c3                   	ret    

f01014b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01014b0:	55                   	push   %ebp
f01014b1:	89 e5                	mov    %esp,%ebp
f01014b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01014ba:	eb 03                	jmp    f01014bf <strfind+0xf>
f01014bc:	83 c0 01             	add    $0x1,%eax
f01014bf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01014c2:	38 ca                	cmp    %cl,%dl
f01014c4:	74 04                	je     f01014ca <strfind+0x1a>
f01014c6:	84 d2                	test   %dl,%dl
f01014c8:	75 f2                	jne    f01014bc <strfind+0xc>
			break;
	return (char *) s;
}
f01014ca:	5d                   	pop    %ebp
f01014cb:	c3                   	ret    

f01014cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014cc:	55                   	push   %ebp
f01014cd:	89 e5                	mov    %esp,%ebp
f01014cf:	57                   	push   %edi
f01014d0:	56                   	push   %esi
f01014d1:	53                   	push   %ebx
f01014d2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014d8:	85 c9                	test   %ecx,%ecx
f01014da:	74 36                	je     f0101512 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014e2:	75 28                	jne    f010150c <memset+0x40>
f01014e4:	f6 c1 03             	test   $0x3,%cl
f01014e7:	75 23                	jne    f010150c <memset+0x40>
		c &= 0xFF;
f01014e9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014ed:	89 d3                	mov    %edx,%ebx
f01014ef:	c1 e3 08             	shl    $0x8,%ebx
f01014f2:	89 d6                	mov    %edx,%esi
f01014f4:	c1 e6 18             	shl    $0x18,%esi
f01014f7:	89 d0                	mov    %edx,%eax
f01014f9:	c1 e0 10             	shl    $0x10,%eax
f01014fc:	09 f0                	or     %esi,%eax
f01014fe:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101500:	89 d8                	mov    %ebx,%eax
f0101502:	09 d0                	or     %edx,%eax
f0101504:	c1 e9 02             	shr    $0x2,%ecx
f0101507:	fc                   	cld    
f0101508:	f3 ab                	rep stos %eax,%es:(%edi)
f010150a:	eb 06                	jmp    f0101512 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010150c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010150f:	fc                   	cld    
f0101510:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101512:	89 f8                	mov    %edi,%eax
f0101514:	5b                   	pop    %ebx
f0101515:	5e                   	pop    %esi
f0101516:	5f                   	pop    %edi
f0101517:	5d                   	pop    %ebp
f0101518:	c3                   	ret    

f0101519 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101519:	55                   	push   %ebp
f010151a:	89 e5                	mov    %esp,%ebp
f010151c:	57                   	push   %edi
f010151d:	56                   	push   %esi
f010151e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101521:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101524:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101527:	39 c6                	cmp    %eax,%esi
f0101529:	73 35                	jae    f0101560 <memmove+0x47>
f010152b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010152e:	39 d0                	cmp    %edx,%eax
f0101530:	73 2e                	jae    f0101560 <memmove+0x47>
		s += n;
		d += n;
f0101532:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101535:	89 d6                	mov    %edx,%esi
f0101537:	09 fe                	or     %edi,%esi
f0101539:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010153f:	75 13                	jne    f0101554 <memmove+0x3b>
f0101541:	f6 c1 03             	test   $0x3,%cl
f0101544:	75 0e                	jne    f0101554 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101546:	83 ef 04             	sub    $0x4,%edi
f0101549:	8d 72 fc             	lea    -0x4(%edx),%esi
f010154c:	c1 e9 02             	shr    $0x2,%ecx
f010154f:	fd                   	std    
f0101550:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101552:	eb 09                	jmp    f010155d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101554:	83 ef 01             	sub    $0x1,%edi
f0101557:	8d 72 ff             	lea    -0x1(%edx),%esi
f010155a:	fd                   	std    
f010155b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010155d:	fc                   	cld    
f010155e:	eb 1d                	jmp    f010157d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101560:	89 f2                	mov    %esi,%edx
f0101562:	09 c2                	or     %eax,%edx
f0101564:	f6 c2 03             	test   $0x3,%dl
f0101567:	75 0f                	jne    f0101578 <memmove+0x5f>
f0101569:	f6 c1 03             	test   $0x3,%cl
f010156c:	75 0a                	jne    f0101578 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010156e:	c1 e9 02             	shr    $0x2,%ecx
f0101571:	89 c7                	mov    %eax,%edi
f0101573:	fc                   	cld    
f0101574:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101576:	eb 05                	jmp    f010157d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101578:	89 c7                	mov    %eax,%edi
f010157a:	fc                   	cld    
f010157b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010157d:	5e                   	pop    %esi
f010157e:	5f                   	pop    %edi
f010157f:	5d                   	pop    %ebp
f0101580:	c3                   	ret    

f0101581 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101581:	55                   	push   %ebp
f0101582:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101584:	ff 75 10             	pushl  0x10(%ebp)
f0101587:	ff 75 0c             	pushl  0xc(%ebp)
f010158a:	ff 75 08             	pushl  0x8(%ebp)
f010158d:	e8 87 ff ff ff       	call   f0101519 <memmove>
}
f0101592:	c9                   	leave  
f0101593:	c3                   	ret    

f0101594 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101594:	55                   	push   %ebp
f0101595:	89 e5                	mov    %esp,%ebp
f0101597:	56                   	push   %esi
f0101598:	53                   	push   %ebx
f0101599:	8b 45 08             	mov    0x8(%ebp),%eax
f010159c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010159f:	89 c6                	mov    %eax,%esi
f01015a1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015a4:	eb 1a                	jmp    f01015c0 <memcmp+0x2c>
		if (*s1 != *s2)
f01015a6:	0f b6 08             	movzbl (%eax),%ecx
f01015a9:	0f b6 1a             	movzbl (%edx),%ebx
f01015ac:	38 d9                	cmp    %bl,%cl
f01015ae:	74 0a                	je     f01015ba <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01015b0:	0f b6 c1             	movzbl %cl,%eax
f01015b3:	0f b6 db             	movzbl %bl,%ebx
f01015b6:	29 d8                	sub    %ebx,%eax
f01015b8:	eb 0f                	jmp    f01015c9 <memcmp+0x35>
		s1++, s2++;
f01015ba:	83 c0 01             	add    $0x1,%eax
f01015bd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015c0:	39 f0                	cmp    %esi,%eax
f01015c2:	75 e2                	jne    f01015a6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015c9:	5b                   	pop    %ebx
f01015ca:	5e                   	pop    %esi
f01015cb:	5d                   	pop    %ebp
f01015cc:	c3                   	ret    

f01015cd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015cd:	55                   	push   %ebp
f01015ce:	89 e5                	mov    %esp,%ebp
f01015d0:	53                   	push   %ebx
f01015d1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01015d4:	89 c1                	mov    %eax,%ecx
f01015d6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01015d9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015dd:	eb 0a                	jmp    f01015e9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015df:	0f b6 10             	movzbl (%eax),%edx
f01015e2:	39 da                	cmp    %ebx,%edx
f01015e4:	74 07                	je     f01015ed <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015e6:	83 c0 01             	add    $0x1,%eax
f01015e9:	39 c8                	cmp    %ecx,%eax
f01015eb:	72 f2                	jb     f01015df <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01015ed:	5b                   	pop    %ebx
f01015ee:	5d                   	pop    %ebp
f01015ef:	c3                   	ret    

f01015f0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015f0:	55                   	push   %ebp
f01015f1:	89 e5                	mov    %esp,%ebp
f01015f3:	57                   	push   %edi
f01015f4:	56                   	push   %esi
f01015f5:	53                   	push   %ebx
f01015f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015fc:	eb 03                	jmp    f0101601 <strtol+0x11>
		s++;
f01015fe:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101601:	0f b6 01             	movzbl (%ecx),%eax
f0101604:	3c 20                	cmp    $0x20,%al
f0101606:	74 f6                	je     f01015fe <strtol+0xe>
f0101608:	3c 09                	cmp    $0x9,%al
f010160a:	74 f2                	je     f01015fe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010160c:	3c 2b                	cmp    $0x2b,%al
f010160e:	75 0a                	jne    f010161a <strtol+0x2a>
		s++;
f0101610:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101613:	bf 00 00 00 00       	mov    $0x0,%edi
f0101618:	eb 11                	jmp    f010162b <strtol+0x3b>
f010161a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010161f:	3c 2d                	cmp    $0x2d,%al
f0101621:	75 08                	jne    f010162b <strtol+0x3b>
		s++, neg = 1;
f0101623:	83 c1 01             	add    $0x1,%ecx
f0101626:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010162b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101631:	75 15                	jne    f0101648 <strtol+0x58>
f0101633:	80 39 30             	cmpb   $0x30,(%ecx)
f0101636:	75 10                	jne    f0101648 <strtol+0x58>
f0101638:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010163c:	75 7c                	jne    f01016ba <strtol+0xca>
		s += 2, base = 16;
f010163e:	83 c1 02             	add    $0x2,%ecx
f0101641:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101646:	eb 16                	jmp    f010165e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101648:	85 db                	test   %ebx,%ebx
f010164a:	75 12                	jne    f010165e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010164c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101651:	80 39 30             	cmpb   $0x30,(%ecx)
f0101654:	75 08                	jne    f010165e <strtol+0x6e>
		s++, base = 8;
f0101656:	83 c1 01             	add    $0x1,%ecx
f0101659:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010165e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101663:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101666:	0f b6 11             	movzbl (%ecx),%edx
f0101669:	8d 72 d0             	lea    -0x30(%edx),%esi
f010166c:	89 f3                	mov    %esi,%ebx
f010166e:	80 fb 09             	cmp    $0x9,%bl
f0101671:	77 08                	ja     f010167b <strtol+0x8b>
			dig = *s - '0';
f0101673:	0f be d2             	movsbl %dl,%edx
f0101676:	83 ea 30             	sub    $0x30,%edx
f0101679:	eb 22                	jmp    f010169d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010167b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010167e:	89 f3                	mov    %esi,%ebx
f0101680:	80 fb 19             	cmp    $0x19,%bl
f0101683:	77 08                	ja     f010168d <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101685:	0f be d2             	movsbl %dl,%edx
f0101688:	83 ea 57             	sub    $0x57,%edx
f010168b:	eb 10                	jmp    f010169d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010168d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101690:	89 f3                	mov    %esi,%ebx
f0101692:	80 fb 19             	cmp    $0x19,%bl
f0101695:	77 16                	ja     f01016ad <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101697:	0f be d2             	movsbl %dl,%edx
f010169a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010169d:	3b 55 10             	cmp    0x10(%ebp),%edx
f01016a0:	7d 0b                	jge    f01016ad <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01016a2:	83 c1 01             	add    $0x1,%ecx
f01016a5:	0f af 45 10          	imul   0x10(%ebp),%eax
f01016a9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01016ab:	eb b9                	jmp    f0101666 <strtol+0x76>

	if (endptr)
f01016ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01016b1:	74 0d                	je     f01016c0 <strtol+0xd0>
		*endptr = (char *) s;
f01016b3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016b6:	89 0e                	mov    %ecx,(%esi)
f01016b8:	eb 06                	jmp    f01016c0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01016ba:	85 db                	test   %ebx,%ebx
f01016bc:	74 98                	je     f0101656 <strtol+0x66>
f01016be:	eb 9e                	jmp    f010165e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01016c0:	89 c2                	mov    %eax,%edx
f01016c2:	f7 da                	neg    %edx
f01016c4:	85 ff                	test   %edi,%edi
f01016c6:	0f 45 c2             	cmovne %edx,%eax
}
f01016c9:	5b                   	pop    %ebx
f01016ca:	5e                   	pop    %esi
f01016cb:	5f                   	pop    %edi
f01016cc:	5d                   	pop    %ebp
f01016cd:	c3                   	ret    
f01016ce:	66 90                	xchg   %ax,%ax

f01016d0 <__udivdi3>:
f01016d0:	55                   	push   %ebp
f01016d1:	57                   	push   %edi
f01016d2:	56                   	push   %esi
f01016d3:	53                   	push   %ebx
f01016d4:	83 ec 1c             	sub    $0x1c,%esp
f01016d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01016db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01016df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01016e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016e7:	85 f6                	test   %esi,%esi
f01016e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01016ed:	89 ca                	mov    %ecx,%edx
f01016ef:	89 f8                	mov    %edi,%eax
f01016f1:	75 3d                	jne    f0101730 <__udivdi3+0x60>
f01016f3:	39 cf                	cmp    %ecx,%edi
f01016f5:	0f 87 c5 00 00 00    	ja     f01017c0 <__udivdi3+0xf0>
f01016fb:	85 ff                	test   %edi,%edi
f01016fd:	89 fd                	mov    %edi,%ebp
f01016ff:	75 0b                	jne    f010170c <__udivdi3+0x3c>
f0101701:	b8 01 00 00 00       	mov    $0x1,%eax
f0101706:	31 d2                	xor    %edx,%edx
f0101708:	f7 f7                	div    %edi
f010170a:	89 c5                	mov    %eax,%ebp
f010170c:	89 c8                	mov    %ecx,%eax
f010170e:	31 d2                	xor    %edx,%edx
f0101710:	f7 f5                	div    %ebp
f0101712:	89 c1                	mov    %eax,%ecx
f0101714:	89 d8                	mov    %ebx,%eax
f0101716:	89 cf                	mov    %ecx,%edi
f0101718:	f7 f5                	div    %ebp
f010171a:	89 c3                	mov    %eax,%ebx
f010171c:	89 d8                	mov    %ebx,%eax
f010171e:	89 fa                	mov    %edi,%edx
f0101720:	83 c4 1c             	add    $0x1c,%esp
f0101723:	5b                   	pop    %ebx
f0101724:	5e                   	pop    %esi
f0101725:	5f                   	pop    %edi
f0101726:	5d                   	pop    %ebp
f0101727:	c3                   	ret    
f0101728:	90                   	nop
f0101729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101730:	39 ce                	cmp    %ecx,%esi
f0101732:	77 74                	ja     f01017a8 <__udivdi3+0xd8>
f0101734:	0f bd fe             	bsr    %esi,%edi
f0101737:	83 f7 1f             	xor    $0x1f,%edi
f010173a:	0f 84 98 00 00 00    	je     f01017d8 <__udivdi3+0x108>
f0101740:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101745:	89 f9                	mov    %edi,%ecx
f0101747:	89 c5                	mov    %eax,%ebp
f0101749:	29 fb                	sub    %edi,%ebx
f010174b:	d3 e6                	shl    %cl,%esi
f010174d:	89 d9                	mov    %ebx,%ecx
f010174f:	d3 ed                	shr    %cl,%ebp
f0101751:	89 f9                	mov    %edi,%ecx
f0101753:	d3 e0                	shl    %cl,%eax
f0101755:	09 ee                	or     %ebp,%esi
f0101757:	89 d9                	mov    %ebx,%ecx
f0101759:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010175d:	89 d5                	mov    %edx,%ebp
f010175f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101763:	d3 ed                	shr    %cl,%ebp
f0101765:	89 f9                	mov    %edi,%ecx
f0101767:	d3 e2                	shl    %cl,%edx
f0101769:	89 d9                	mov    %ebx,%ecx
f010176b:	d3 e8                	shr    %cl,%eax
f010176d:	09 c2                	or     %eax,%edx
f010176f:	89 d0                	mov    %edx,%eax
f0101771:	89 ea                	mov    %ebp,%edx
f0101773:	f7 f6                	div    %esi
f0101775:	89 d5                	mov    %edx,%ebp
f0101777:	89 c3                	mov    %eax,%ebx
f0101779:	f7 64 24 0c          	mull   0xc(%esp)
f010177d:	39 d5                	cmp    %edx,%ebp
f010177f:	72 10                	jb     f0101791 <__udivdi3+0xc1>
f0101781:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101785:	89 f9                	mov    %edi,%ecx
f0101787:	d3 e6                	shl    %cl,%esi
f0101789:	39 c6                	cmp    %eax,%esi
f010178b:	73 07                	jae    f0101794 <__udivdi3+0xc4>
f010178d:	39 d5                	cmp    %edx,%ebp
f010178f:	75 03                	jne    f0101794 <__udivdi3+0xc4>
f0101791:	83 eb 01             	sub    $0x1,%ebx
f0101794:	31 ff                	xor    %edi,%edi
f0101796:	89 d8                	mov    %ebx,%eax
f0101798:	89 fa                	mov    %edi,%edx
f010179a:	83 c4 1c             	add    $0x1c,%esp
f010179d:	5b                   	pop    %ebx
f010179e:	5e                   	pop    %esi
f010179f:	5f                   	pop    %edi
f01017a0:	5d                   	pop    %ebp
f01017a1:	c3                   	ret    
f01017a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017a8:	31 ff                	xor    %edi,%edi
f01017aa:	31 db                	xor    %ebx,%ebx
f01017ac:	89 d8                	mov    %ebx,%eax
f01017ae:	89 fa                	mov    %edi,%edx
f01017b0:	83 c4 1c             	add    $0x1c,%esp
f01017b3:	5b                   	pop    %ebx
f01017b4:	5e                   	pop    %esi
f01017b5:	5f                   	pop    %edi
f01017b6:	5d                   	pop    %ebp
f01017b7:	c3                   	ret    
f01017b8:	90                   	nop
f01017b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017c0:	89 d8                	mov    %ebx,%eax
f01017c2:	f7 f7                	div    %edi
f01017c4:	31 ff                	xor    %edi,%edi
f01017c6:	89 c3                	mov    %eax,%ebx
f01017c8:	89 d8                	mov    %ebx,%eax
f01017ca:	89 fa                	mov    %edi,%edx
f01017cc:	83 c4 1c             	add    $0x1c,%esp
f01017cf:	5b                   	pop    %ebx
f01017d0:	5e                   	pop    %esi
f01017d1:	5f                   	pop    %edi
f01017d2:	5d                   	pop    %ebp
f01017d3:	c3                   	ret    
f01017d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017d8:	39 ce                	cmp    %ecx,%esi
f01017da:	72 0c                	jb     f01017e8 <__udivdi3+0x118>
f01017dc:	31 db                	xor    %ebx,%ebx
f01017de:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01017e2:	0f 87 34 ff ff ff    	ja     f010171c <__udivdi3+0x4c>
f01017e8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01017ed:	e9 2a ff ff ff       	jmp    f010171c <__udivdi3+0x4c>
f01017f2:	66 90                	xchg   %ax,%ax
f01017f4:	66 90                	xchg   %ax,%ax
f01017f6:	66 90                	xchg   %ax,%ax
f01017f8:	66 90                	xchg   %ax,%ax
f01017fa:	66 90                	xchg   %ax,%ax
f01017fc:	66 90                	xchg   %ax,%ax
f01017fe:	66 90                	xchg   %ax,%ax

f0101800 <__umoddi3>:
f0101800:	55                   	push   %ebp
f0101801:	57                   	push   %edi
f0101802:	56                   	push   %esi
f0101803:	53                   	push   %ebx
f0101804:	83 ec 1c             	sub    $0x1c,%esp
f0101807:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010180b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010180f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101813:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101817:	85 d2                	test   %edx,%edx
f0101819:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010181d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101821:	89 f3                	mov    %esi,%ebx
f0101823:	89 3c 24             	mov    %edi,(%esp)
f0101826:	89 74 24 04          	mov    %esi,0x4(%esp)
f010182a:	75 1c                	jne    f0101848 <__umoddi3+0x48>
f010182c:	39 f7                	cmp    %esi,%edi
f010182e:	76 50                	jbe    f0101880 <__umoddi3+0x80>
f0101830:	89 c8                	mov    %ecx,%eax
f0101832:	89 f2                	mov    %esi,%edx
f0101834:	f7 f7                	div    %edi
f0101836:	89 d0                	mov    %edx,%eax
f0101838:	31 d2                	xor    %edx,%edx
f010183a:	83 c4 1c             	add    $0x1c,%esp
f010183d:	5b                   	pop    %ebx
f010183e:	5e                   	pop    %esi
f010183f:	5f                   	pop    %edi
f0101840:	5d                   	pop    %ebp
f0101841:	c3                   	ret    
f0101842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101848:	39 f2                	cmp    %esi,%edx
f010184a:	89 d0                	mov    %edx,%eax
f010184c:	77 52                	ja     f01018a0 <__umoddi3+0xa0>
f010184e:	0f bd ea             	bsr    %edx,%ebp
f0101851:	83 f5 1f             	xor    $0x1f,%ebp
f0101854:	75 5a                	jne    f01018b0 <__umoddi3+0xb0>
f0101856:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010185a:	0f 82 e0 00 00 00    	jb     f0101940 <__umoddi3+0x140>
f0101860:	39 0c 24             	cmp    %ecx,(%esp)
f0101863:	0f 86 d7 00 00 00    	jbe    f0101940 <__umoddi3+0x140>
f0101869:	8b 44 24 08          	mov    0x8(%esp),%eax
f010186d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101871:	83 c4 1c             	add    $0x1c,%esp
f0101874:	5b                   	pop    %ebx
f0101875:	5e                   	pop    %esi
f0101876:	5f                   	pop    %edi
f0101877:	5d                   	pop    %ebp
f0101878:	c3                   	ret    
f0101879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101880:	85 ff                	test   %edi,%edi
f0101882:	89 fd                	mov    %edi,%ebp
f0101884:	75 0b                	jne    f0101891 <__umoddi3+0x91>
f0101886:	b8 01 00 00 00       	mov    $0x1,%eax
f010188b:	31 d2                	xor    %edx,%edx
f010188d:	f7 f7                	div    %edi
f010188f:	89 c5                	mov    %eax,%ebp
f0101891:	89 f0                	mov    %esi,%eax
f0101893:	31 d2                	xor    %edx,%edx
f0101895:	f7 f5                	div    %ebp
f0101897:	89 c8                	mov    %ecx,%eax
f0101899:	f7 f5                	div    %ebp
f010189b:	89 d0                	mov    %edx,%eax
f010189d:	eb 99                	jmp    f0101838 <__umoddi3+0x38>
f010189f:	90                   	nop
f01018a0:	89 c8                	mov    %ecx,%eax
f01018a2:	89 f2                	mov    %esi,%edx
f01018a4:	83 c4 1c             	add    $0x1c,%esp
f01018a7:	5b                   	pop    %ebx
f01018a8:	5e                   	pop    %esi
f01018a9:	5f                   	pop    %edi
f01018aa:	5d                   	pop    %ebp
f01018ab:	c3                   	ret    
f01018ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018b0:	8b 34 24             	mov    (%esp),%esi
f01018b3:	bf 20 00 00 00       	mov    $0x20,%edi
f01018b8:	89 e9                	mov    %ebp,%ecx
f01018ba:	29 ef                	sub    %ebp,%edi
f01018bc:	d3 e0                	shl    %cl,%eax
f01018be:	89 f9                	mov    %edi,%ecx
f01018c0:	89 f2                	mov    %esi,%edx
f01018c2:	d3 ea                	shr    %cl,%edx
f01018c4:	89 e9                	mov    %ebp,%ecx
f01018c6:	09 c2                	or     %eax,%edx
f01018c8:	89 d8                	mov    %ebx,%eax
f01018ca:	89 14 24             	mov    %edx,(%esp)
f01018cd:	89 f2                	mov    %esi,%edx
f01018cf:	d3 e2                	shl    %cl,%edx
f01018d1:	89 f9                	mov    %edi,%ecx
f01018d3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01018d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01018db:	d3 e8                	shr    %cl,%eax
f01018dd:	89 e9                	mov    %ebp,%ecx
f01018df:	89 c6                	mov    %eax,%esi
f01018e1:	d3 e3                	shl    %cl,%ebx
f01018e3:	89 f9                	mov    %edi,%ecx
f01018e5:	89 d0                	mov    %edx,%eax
f01018e7:	d3 e8                	shr    %cl,%eax
f01018e9:	89 e9                	mov    %ebp,%ecx
f01018eb:	09 d8                	or     %ebx,%eax
f01018ed:	89 d3                	mov    %edx,%ebx
f01018ef:	89 f2                	mov    %esi,%edx
f01018f1:	f7 34 24             	divl   (%esp)
f01018f4:	89 d6                	mov    %edx,%esi
f01018f6:	d3 e3                	shl    %cl,%ebx
f01018f8:	f7 64 24 04          	mull   0x4(%esp)
f01018fc:	39 d6                	cmp    %edx,%esi
f01018fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101902:	89 d1                	mov    %edx,%ecx
f0101904:	89 c3                	mov    %eax,%ebx
f0101906:	72 08                	jb     f0101910 <__umoddi3+0x110>
f0101908:	75 11                	jne    f010191b <__umoddi3+0x11b>
f010190a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010190e:	73 0b                	jae    f010191b <__umoddi3+0x11b>
f0101910:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101914:	1b 14 24             	sbb    (%esp),%edx
f0101917:	89 d1                	mov    %edx,%ecx
f0101919:	89 c3                	mov    %eax,%ebx
f010191b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010191f:	29 da                	sub    %ebx,%edx
f0101921:	19 ce                	sbb    %ecx,%esi
f0101923:	89 f9                	mov    %edi,%ecx
f0101925:	89 f0                	mov    %esi,%eax
f0101927:	d3 e0                	shl    %cl,%eax
f0101929:	89 e9                	mov    %ebp,%ecx
f010192b:	d3 ea                	shr    %cl,%edx
f010192d:	89 e9                	mov    %ebp,%ecx
f010192f:	d3 ee                	shr    %cl,%esi
f0101931:	09 d0                	or     %edx,%eax
f0101933:	89 f2                	mov    %esi,%edx
f0101935:	83 c4 1c             	add    $0x1c,%esp
f0101938:	5b                   	pop    %ebx
f0101939:	5e                   	pop    %esi
f010193a:	5f                   	pop    %edi
f010193b:	5d                   	pop    %ebp
f010193c:	c3                   	ret    
f010193d:	8d 76 00             	lea    0x0(%esi),%esi
f0101940:	29 f9                	sub    %edi,%ecx
f0101942:	19 d6                	sbb    %edx,%esi
f0101944:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101948:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010194c:	e9 18 ff ff ff       	jmp    f0101869 <__umoddi3+0x69>
