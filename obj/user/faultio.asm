
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 60 1e 80 00       	push   $0x801e60
  800048:	e8 13 01 00 00       	call   800160 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 6e 1e 80 00       	push   $0x801e6e
  800063:	e8 f8 00 00 00       	call   800160 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800078:	e8 d4 0a 00 00       	call   800b51 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x2d>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b9:	e8 8d 0e 00 00       	call   800f4b <close_all>
	sys_env_destroy(0);
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	6a 00                	push   $0x0
  8000c3:	e8 48 0a 00 00       	call   800b10 <sys_env_destroy>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d7:	8b 13                	mov    (%ebx),%edx
  8000d9:	8d 42 01             	lea    0x1(%edx),%eax
  8000dc:	89 03                	mov    %eax,(%ebx)
  8000de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ea:	75 1a                	jne    800106 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	68 ff 00 00 00       	push   $0xff
  8000f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f7:	50                   	push   %eax
  8000f8:	e8 d6 09 00 00       	call   800ad3 <sys_cputs>
		b->idx = 0;
  8000fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800103:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800106:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 cd 00 80 00       	push   $0x8000cd
  80013e:	e8 1a 01 00 00       	call   80025d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 7b 09 00 00       	call   800ad3 <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 1c             	sub    $0x1c,%esp
  80017d:	89 c7                	mov    %eax,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800198:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019b:	39 d3                	cmp    %edx,%ebx
  80019d:	72 05                	jb     8001a4 <printnum+0x30>
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 45                	ja     8001e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 18             	pushl  0x18(%ebp)
  8001aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c3:	e8 08 1a 00 00       	call   801bd0 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	89 f8                	mov    %edi,%eax
  8001d1:	e8 9e ff ff ff       	call   800174 <printnum>
  8001d6:	83 c4 20             	add    $0x20,%esp
  8001d9:	eb 18                	jmp    8001f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff d7                	call   *%edi
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 03                	jmp    8001ec <printnum+0x78>
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ec:	83 eb 01             	sub    $0x1,%ebx
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7f e8                	jg     8001db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	83 ec 04             	sub    $0x4,%esp
  8001fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800200:	ff 75 dc             	pushl  -0x24(%ebp)
  800203:	ff 75 d8             	pushl  -0x28(%ebp)
  800206:	e8 f5 1a 00 00       	call   801d00 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 92 1e 80 00 	movsbl 0x801e92(%eax),%eax
  800215:	50                   	push   %eax
  800216:	ff d7                	call   *%edi
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800229:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80022d:	8b 10                	mov    (%eax),%edx
  80022f:	3b 50 04             	cmp    0x4(%eax),%edx
  800232:	73 0a                	jae    80023e <sprintputch+0x1b>
		*b->buf++ = ch;
  800234:	8d 4a 01             	lea    0x1(%edx),%ecx
  800237:	89 08                	mov    %ecx,(%eax)
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
  80023c:	88 02                	mov    %al,(%edx)
}
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800246:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800249:	50                   	push   %eax
  80024a:	ff 75 10             	pushl  0x10(%ebp)
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	ff 75 08             	pushl  0x8(%ebp)
  800253:	e8 05 00 00 00       	call   80025d <vprintfmt>
	va_end(ap);
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 2c             	sub    $0x2c,%esp
  800266:	8b 75 08             	mov    0x8(%ebp),%esi
  800269:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80026f:	eb 12                	jmp    800283 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800271:	85 c0                	test   %eax,%eax
  800273:	0f 84 6a 04 00 00    	je     8006e3 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	53                   	push   %ebx
  80027d:	50                   	push   %eax
  80027e:	ff d6                	call   *%esi
  800280:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800283:	83 c7 01             	add    $0x1,%edi
  800286:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80028a:	83 f8 25             	cmp    $0x25,%eax
  80028d:	75 e2                	jne    800271 <vprintfmt+0x14>
  80028f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800293:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80029a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ad:	eb 07                	jmp    8002b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b6:	8d 47 01             	lea    0x1(%edi),%eax
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	0f b6 07             	movzbl (%edi),%eax
  8002bf:	0f b6 d0             	movzbl %al,%edx
  8002c2:	83 e8 23             	sub    $0x23,%eax
  8002c5:	3c 55                	cmp    $0x55,%al
  8002c7:	0f 87 fb 03 00 00    	ja     8006c8 <vprintfmt+0x46b>
  8002cd:	0f b6 c0             	movzbl %al,%eax
  8002d0:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002de:	eb d6                	jmp    8002b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ee:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f8:	83 f9 09             	cmp    $0x9,%ecx
  8002fb:	77 3f                	ja     80033c <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800300:	eb e9                	jmp    8002eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800302:	8b 45 14             	mov    0x14(%ebp),%eax
  800305:	8b 00                	mov    (%eax),%eax
  800307:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80030a:	8b 45 14             	mov    0x14(%ebp),%eax
  80030d:	8d 40 04             	lea    0x4(%eax),%eax
  800310:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800316:	eb 2a                	jmp    800342 <vprintfmt+0xe5>
  800318:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031b:	85 c0                	test   %eax,%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
  800322:	0f 49 d0             	cmovns %eax,%edx
  800325:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	eb 89                	jmp    8002b6 <vprintfmt+0x59>
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800330:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800337:	e9 7a ff ff ff       	jmp    8002b6 <vprintfmt+0x59>
  80033c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80033f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800342:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800346:	0f 89 6a ff ff ff    	jns    8002b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  80034c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800359:	e9 58 ff ff ff       	jmp    8002b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80035e:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800364:	e9 4d ff ff ff       	jmp    8002b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 78 04             	lea    0x4(%eax),%edi
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	53                   	push   %ebx
  800373:	ff 30                	pushl  (%eax)
  800375:	ff d6                	call   *%esi
			break;
  800377:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800380:	e9 fe fe ff ff       	jmp    800283 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 78 04             	lea    0x4(%eax),%edi
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	99                   	cltd   
  80038e:	31 d0                	xor    %edx,%eax
  800390:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800392:	83 f8 0f             	cmp    $0xf,%eax
  800395:	7f 0b                	jg     8003a2 <vprintfmt+0x145>
  800397:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	75 1b                	jne    8003bd <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003a2:	50                   	push   %eax
  8003a3:	68 aa 1e 80 00       	push   $0x801eaa
  8003a8:	53                   	push   %ebx
  8003a9:	56                   	push   %esi
  8003aa:	e8 91 fe ff ff       	call   800240 <printfmt>
  8003af:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003b8:	e9 c6 fe ff ff       	jmp    800283 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003bd:	52                   	push   %edx
  8003be:	68 9a 22 80 00       	push   $0x80229a
  8003c3:	53                   	push   %ebx
  8003c4:	56                   	push   %esi
  8003c5:	e8 76 fe ff ff       	call   800240 <printfmt>
  8003ca:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d3:	e9 ab fe ff ff       	jmp    800283 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	83 c0 04             	add    $0x4,%eax
  8003de:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003e6:	85 ff                	test   %edi,%edi
  8003e8:	b8 a3 1e 80 00       	mov    $0x801ea3,%eax
  8003ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f4:	0f 8e 94 00 00 00    	jle    80048e <vprintfmt+0x231>
  8003fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003fe:	0f 84 98 00 00 00    	je     80049c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	ff 75 d0             	pushl  -0x30(%ebp)
  80040a:	57                   	push   %edi
  80040b:	e8 5b 03 00 00       	call   80076b <strnlen>
  800410:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800413:	29 c1                	sub    %eax,%ecx
  800415:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800418:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80041b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80041f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800422:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800425:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	eb 0f                	jmp    800438 <vprintfmt+0x1db>
					putch(padc, putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	53                   	push   %ebx
  80042d:	ff 75 e0             	pushl  -0x20(%ebp)
  800430:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800432:	83 ef 01             	sub    $0x1,%edi
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	85 ff                	test   %edi,%edi
  80043a:	7f ed                	jg     800429 <vprintfmt+0x1cc>
  80043c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80043f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800442:	85 c9                	test   %ecx,%ecx
  800444:	b8 00 00 00 00       	mov    $0x0,%eax
  800449:	0f 49 c1             	cmovns %ecx,%eax
  80044c:	29 c1                	sub    %eax,%ecx
  80044e:	89 75 08             	mov    %esi,0x8(%ebp)
  800451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800454:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800457:	89 cb                	mov    %ecx,%ebx
  800459:	eb 4d                	jmp    8004a8 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80045b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045f:	74 1b                	je     80047c <vprintfmt+0x21f>
  800461:	0f be c0             	movsbl %al,%eax
  800464:	83 e8 20             	sub    $0x20,%eax
  800467:	83 f8 5e             	cmp    $0x5e,%eax
  80046a:	76 10                	jbe    80047c <vprintfmt+0x21f>
					putch('?', putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	ff 75 0c             	pushl  0xc(%ebp)
  800472:	6a 3f                	push   $0x3f
  800474:	ff 55 08             	call   *0x8(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	eb 0d                	jmp    800489 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	ff 75 0c             	pushl  0xc(%ebp)
  800482:	52                   	push   %edx
  800483:	ff 55 08             	call   *0x8(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	eb 1a                	jmp    8004a8 <vprintfmt+0x24b>
  80048e:	89 75 08             	mov    %esi,0x8(%ebp)
  800491:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800494:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800497:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049a:	eb 0c                	jmp    8004a8 <vprintfmt+0x24b>
  80049c:	89 75 08             	mov    %esi,0x8(%ebp)
  80049f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a8:	83 c7 01             	add    $0x1,%edi
  8004ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004af:	0f be d0             	movsbl %al,%edx
  8004b2:	85 d2                	test   %edx,%edx
  8004b4:	74 23                	je     8004d9 <vprintfmt+0x27c>
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	78 a1                	js     80045b <vprintfmt+0x1fe>
  8004ba:	83 ee 01             	sub    $0x1,%esi
  8004bd:	79 9c                	jns    80045b <vprintfmt+0x1fe>
  8004bf:	89 df                	mov    %ebx,%edi
  8004c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c7:	eb 18                	jmp    8004e1 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	6a 20                	push   $0x20
  8004cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d1:	83 ef 01             	sub    $0x1,%edi
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	eb 08                	jmp    8004e1 <vprintfmt+0x284>
  8004d9:	89 df                	mov    %ebx,%edi
  8004db:	8b 75 08             	mov    0x8(%ebp),%esi
  8004de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f e4                	jg     8004c9 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	e9 90 fd ff ff       	jmp    800283 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f3:	83 f9 01             	cmp    $0x1,%ecx
  8004f6:	7e 19                	jle    800511 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8b 50 04             	mov    0x4(%eax),%edx
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800503:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 40 08             	lea    0x8(%eax),%eax
  80050c:	89 45 14             	mov    %eax,0x14(%ebp)
  80050f:	eb 38                	jmp    800549 <vprintfmt+0x2ec>
	else if (lflag)
  800511:	85 c9                	test   %ecx,%ecx
  800513:	74 1b                	je     800530 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8b 00                	mov    (%eax),%eax
  80051a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051d:	89 c1                	mov    %eax,%ecx
  80051f:	c1 f9 1f             	sar    $0x1f,%ecx
  800522:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 40 04             	lea    0x4(%eax),%eax
  80052b:	89 45 14             	mov    %eax,0x14(%ebp)
  80052e:	eb 19                	jmp    800549 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8b 00                	mov    (%eax),%eax
  800535:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800538:	89 c1                	mov    %eax,%ecx
  80053a:	c1 f9 1f             	sar    $0x1f,%ecx
  80053d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 40 04             	lea    0x4(%eax),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800549:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800554:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800558:	0f 89 36 01 00 00    	jns    800694 <vprintfmt+0x437>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056c:	f7 da                	neg    %edx
  80056e:	83 d1 00             	adc    $0x0,%ecx
  800571:	f7 d9                	neg    %ecx
  800573:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 14 01 00 00       	jmp    800694 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 18                	jle    80059d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8b 48 04             	mov    0x4(%eax),%ecx
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
  800598:	e9 f7 00 00 00       	jmp    800694 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80059d:	85 c9                	test   %ecx,%ecx
  80059f:	74 1a                	je     8005bb <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ab:	8d 40 04             	lea    0x4(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b6:	e9 d9 00 00 00       	jmp    800694 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c5:	8d 40 04             	lea    0x4(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d0:	e9 bf 00 00 00       	jmp    800694 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d5:	83 f9 01             	cmp    $0x1,%ecx
  8005d8:	7e 13                	jle    8005ed <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 50 04             	mov    0x4(%eax),%edx
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005e5:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005eb:	eb 28                	jmp    800615 <vprintfmt+0x3b8>
	else if (lflag)
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	74 13                	je     800604 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	89 d0                	mov    %edx,%eax
  8005f8:	99                   	cltd   
  8005f9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005fc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800602:	eb 11                	jmp    800615 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	89 d0                	mov    %edx,%eax
  80060b:	99                   	cltd   
  80060c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80060f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800612:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800615:	89 d1                	mov    %edx,%ecx
  800617:	89 c2                	mov    %eax,%edx
			base = 8;
  800619:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80061e:	eb 74                	jmp    800694 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 30                	push   $0x30
  800626:	ff d6                	call   *%esi
			putch('x', putdat);
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 78                	push   $0x78
  80062e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80063a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800643:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800648:	eb 4a                	jmp    800694 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064a:	83 f9 01             	cmp    $0x1,%ecx
  80064d:	7e 15                	jle    800664 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 10                	mov    (%eax),%edx
  800654:	8b 48 04             	mov    0x4(%eax),%ecx
  800657:	8d 40 08             	lea    0x8(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80065d:	b8 10 00 00 00       	mov    $0x10,%eax
  800662:	eb 30                	jmp    800694 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800664:	85 c9                	test   %ecx,%ecx
  800666:	74 17                	je     80067f <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800678:	b8 10 00 00 00       	mov    $0x10,%eax
  80067d:	eb 15                	jmp    800694 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800694:	83 ec 0c             	sub    $0xc,%esp
  800697:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069b:	57                   	push   %edi
  80069c:	ff 75 e0             	pushl  -0x20(%ebp)
  80069f:	50                   	push   %eax
  8006a0:	51                   	push   %ecx
  8006a1:	52                   	push   %edx
  8006a2:	89 da                	mov    %ebx,%edx
  8006a4:	89 f0                	mov    %esi,%eax
  8006a6:	e8 c9 fa ff ff       	call   800174 <printnum>
			break;
  8006ab:	83 c4 20             	add    $0x20,%esp
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b1:	e9 cd fb ff ff       	jmp    800283 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	52                   	push   %edx
  8006bb:	ff d6                	call   *%esi
			break;
  8006bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c3:	e9 bb fb ff ff       	jmp    800283 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	53                   	push   %ebx
  8006cc:	6a 25                	push   $0x25
  8006ce:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	eb 03                	jmp    8006d8 <vprintfmt+0x47b>
  8006d5:	83 ef 01             	sub    $0x1,%edi
  8006d8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006dc:	75 f7                	jne    8006d5 <vprintfmt+0x478>
  8006de:	e9 a0 fb ff ff       	jmp    800283 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e6:	5b                   	pop    %ebx
  8006e7:	5e                   	pop    %esi
  8006e8:	5f                   	pop    %edi
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	83 ec 18             	sub    $0x18,%esp
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 26                	je     800732 <vsnprintf+0x47>
  80070c:	85 d2                	test   %edx,%edx
  80070e:	7e 22                	jle    800732 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800710:	ff 75 14             	pushl  0x14(%ebp)
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	68 23 02 80 00       	push   $0x800223
  80071f:	e8 39 fb ff ff       	call   80025d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800727:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 05                	jmp    800737 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800732:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800742:	50                   	push   %eax
  800743:	ff 75 10             	pushl  0x10(%ebp)
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	ff 75 08             	pushl  0x8(%ebp)
  80074c:	e8 9a ff ff ff       	call   8006eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	eb 03                	jmp    800763 <strlen+0x10>
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800767:	75 f7                	jne    800760 <strlen+0xd>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	ba 00 00 00 00       	mov    $0x0,%edx
  800779:	eb 03                	jmp    80077e <strnlen+0x13>
		n++;
  80077b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	39 c2                	cmp    %eax,%edx
  800780:	74 08                	je     80078a <strnlen+0x1f>
  800782:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800786:	75 f3                	jne    80077b <strnlen+0x10>
  800788:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800796:	89 c2                	mov    %eax,%edx
  800798:	83 c2 01             	add    $0x1,%edx
  80079b:	83 c1 01             	add    $0x1,%ecx
  80079e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a5:	84 db                	test   %bl,%bl
  8007a7:	75 ef                	jne    800798 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a9:	5b                   	pop    %ebx
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b3:	53                   	push   %ebx
  8007b4:	e8 9a ff ff ff       	call   800753 <strlen>
  8007b9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	01 d8                	add    %ebx,%eax
  8007c1:	50                   	push   %eax
  8007c2:	e8 c5 ff ff ff       	call   80078c <strcpy>
	return dst;
}
  8007c7:	89 d8                	mov    %ebx,%eax
  8007c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d9:	89 f3                	mov    %esi,%ebx
  8007db:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007de:	89 f2                	mov    %esi,%edx
  8007e0:	eb 0f                	jmp    8007f1 <strncpy+0x23>
		*dst++ = *src;
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	0f b6 01             	movzbl (%ecx),%eax
  8007e8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007eb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ee:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	39 da                	cmp    %ebx,%edx
  8007f3:	75 ed                	jne    8007e2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800806:	8b 55 10             	mov    0x10(%ebp),%edx
  800809:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080b:	85 d2                	test   %edx,%edx
  80080d:	74 21                	je     800830 <strlcpy+0x35>
  80080f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800813:	89 f2                	mov    %esi,%edx
  800815:	eb 09                	jmp    800820 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800817:	83 c2 01             	add    $0x1,%edx
  80081a:	83 c1 01             	add    $0x1,%ecx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800820:	39 c2                	cmp    %eax,%edx
  800822:	74 09                	je     80082d <strlcpy+0x32>
  800824:	0f b6 19             	movzbl (%ecx),%ebx
  800827:	84 db                	test   %bl,%bl
  800829:	75 ec                	jne    800817 <strlcpy+0x1c>
  80082b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80082d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800830:	29 f0                	sub    %esi,%eax
}
  800832:	5b                   	pop    %ebx
  800833:	5e                   	pop    %esi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083f:	eb 06                	jmp    800847 <strcmp+0x11>
		p++, q++;
  800841:	83 c1 01             	add    $0x1,%ecx
  800844:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800847:	0f b6 01             	movzbl (%ecx),%eax
  80084a:	84 c0                	test   %al,%al
  80084c:	74 04                	je     800852 <strcmp+0x1c>
  80084e:	3a 02                	cmp    (%edx),%al
  800850:	74 ef                	je     800841 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800852:	0f b6 c0             	movzbl %al,%eax
  800855:	0f b6 12             	movzbl (%edx),%edx
  800858:	29 d0                	sub    %edx,%eax
}
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	53                   	push   %ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	89 c3                	mov    %eax,%ebx
  800868:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086b:	eb 06                	jmp    800873 <strncmp+0x17>
		n--, p++, q++;
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800873:	39 d8                	cmp    %ebx,%eax
  800875:	74 15                	je     80088c <strncmp+0x30>
  800877:	0f b6 08             	movzbl (%eax),%ecx
  80087a:	84 c9                	test   %cl,%cl
  80087c:	74 04                	je     800882 <strncmp+0x26>
  80087e:	3a 0a                	cmp    (%edx),%cl
  800880:	74 eb                	je     80086d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800882:	0f b6 00             	movzbl (%eax),%eax
  800885:	0f b6 12             	movzbl (%edx),%edx
  800888:	29 d0                	sub    %edx,%eax
  80088a:	eb 05                	jmp    800891 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800891:	5b                   	pop    %ebx
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089e:	eb 07                	jmp    8008a7 <strchr+0x13>
		if (*s == c)
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	74 0f                	je     8008b3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	0f b6 10             	movzbl (%eax),%edx
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	75 f2                	jne    8008a0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bf:	eb 03                	jmp    8008c4 <strfind+0xf>
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c7:	38 ca                	cmp    %cl,%dl
  8008c9:	74 04                	je     8008cf <strfind+0x1a>
  8008cb:	84 d2                	test   %dl,%dl
  8008cd:	75 f2                	jne    8008c1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008dd:	85 c9                	test   %ecx,%ecx
  8008df:	74 36                	je     800917 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e7:	75 28                	jne    800911 <memset+0x40>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 23                	jne    800911 <memset+0x40>
		c &= 0xFF;
  8008ee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f2:	89 d3                	mov    %edx,%ebx
  8008f4:	c1 e3 08             	shl    $0x8,%ebx
  8008f7:	89 d6                	mov    %edx,%esi
  8008f9:	c1 e6 18             	shl    $0x18,%esi
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	c1 e0 10             	shl    $0x10,%eax
  800901:	09 f0                	or     %esi,%eax
  800903:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800905:	89 d8                	mov    %ebx,%eax
  800907:	09 d0                	or     %edx,%eax
  800909:	c1 e9 02             	shr    $0x2,%ecx
  80090c:	fc                   	cld    
  80090d:	f3 ab                	rep stos %eax,%es:(%edi)
  80090f:	eb 06                	jmp    800917 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800911:	8b 45 0c             	mov    0xc(%ebp),%eax
  800914:	fc                   	cld    
  800915:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800917:	89 f8                	mov    %edi,%eax
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 75 0c             	mov    0xc(%ebp),%esi
  800929:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092c:	39 c6                	cmp    %eax,%esi
  80092e:	73 35                	jae    800965 <memmove+0x47>
  800930:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800933:	39 d0                	cmp    %edx,%eax
  800935:	73 2e                	jae    800965 <memmove+0x47>
		s += n;
		d += n;
  800937:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	09 fe                	or     %edi,%esi
  80093e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800944:	75 13                	jne    800959 <memmove+0x3b>
  800946:	f6 c1 03             	test   $0x3,%cl
  800949:	75 0e                	jne    800959 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80094b:	83 ef 04             	sub    $0x4,%edi
  80094e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800951:	c1 e9 02             	shr    $0x2,%ecx
  800954:	fd                   	std    
  800955:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800957:	eb 09                	jmp    800962 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800959:	83 ef 01             	sub    $0x1,%edi
  80095c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80095f:	fd                   	std    
  800960:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800962:	fc                   	cld    
  800963:	eb 1d                	jmp    800982 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800965:	89 f2                	mov    %esi,%edx
  800967:	09 c2                	or     %eax,%edx
  800969:	f6 c2 03             	test   $0x3,%dl
  80096c:	75 0f                	jne    80097d <memmove+0x5f>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 0a                	jne    80097d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800973:	c1 e9 02             	shr    $0x2,%ecx
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097b:	eb 05                	jmp    800982 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	fc                   	cld    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 87 ff ff ff       	call   80091e <memmove>
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a4:	89 c6                	mov    %eax,%esi
  8009a6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a9:	eb 1a                	jmp    8009c5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	0f b6 1a             	movzbl (%edx),%ebx
  8009b1:	38 d9                	cmp    %bl,%cl
  8009b3:	74 0a                	je     8009bf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b5:	0f b6 c1             	movzbl %cl,%eax
  8009b8:	0f b6 db             	movzbl %bl,%ebx
  8009bb:	29 d8                	sub    %ebx,%eax
  8009bd:	eb 0f                	jmp    8009ce <memcmp+0x35>
		s1++, s2++;
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c5:	39 f0                	cmp    %esi,%eax
  8009c7:	75 e2                	jne    8009ab <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d9:	89 c1                	mov    %eax,%ecx
  8009db:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009de:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e2:	eb 0a                	jmp    8009ee <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e4:	0f b6 10             	movzbl (%eax),%edx
  8009e7:	39 da                	cmp    %ebx,%edx
  8009e9:	74 07                	je     8009f2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	39 c8                	cmp    %ecx,%eax
  8009f0:	72 f2                	jb     8009e4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a01:	eb 03                	jmp    800a06 <strtol+0x11>
		s++;
  800a03:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	0f b6 01             	movzbl (%ecx),%eax
  800a09:	3c 20                	cmp    $0x20,%al
  800a0b:	74 f6                	je     800a03 <strtol+0xe>
  800a0d:	3c 09                	cmp    $0x9,%al
  800a0f:	74 f2                	je     800a03 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a11:	3c 2b                	cmp    $0x2b,%al
  800a13:	75 0a                	jne    800a1f <strtol+0x2a>
		s++;
  800a15:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1d:	eb 11                	jmp    800a30 <strtol+0x3b>
  800a1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a24:	3c 2d                	cmp    $0x2d,%al
  800a26:	75 08                	jne    800a30 <strtol+0x3b>
		s++, neg = 1;
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a36:	75 15                	jne    800a4d <strtol+0x58>
  800a38:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3b:	75 10                	jne    800a4d <strtol+0x58>
  800a3d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a41:	75 7c                	jne    800abf <strtol+0xca>
		s += 2, base = 16;
  800a43:	83 c1 02             	add    $0x2,%ecx
  800a46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4b:	eb 16                	jmp    800a63 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	75 12                	jne    800a63 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a51:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a56:	80 39 30             	cmpb   $0x30,(%ecx)
  800a59:	75 08                	jne    800a63 <strtol+0x6e>
		s++, base = 8;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6b:	0f b6 11             	movzbl (%ecx),%edx
  800a6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 09             	cmp    $0x9,%bl
  800a76:	77 08                	ja     800a80 <strtol+0x8b>
			dig = *s - '0';
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 30             	sub    $0x30,%edx
  800a7e:	eb 22                	jmp    800aa2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a80:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 57             	sub    $0x57,%edx
  800a90:	eb 10                	jmp    800aa2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a95:	89 f3                	mov    %esi,%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 16                	ja     800ab2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a9c:	0f be d2             	movsbl %dl,%edx
  800a9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa5:	7d 0b                	jge    800ab2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aae:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab0:	eb b9                	jmp    800a6b <strtol+0x76>

	if (endptr)
  800ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab6:	74 0d                	je     800ac5 <strtol+0xd0>
		*endptr = (char *) s;
  800ab8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abb:	89 0e                	mov    %ecx,(%esi)
  800abd:	eb 06                	jmp    800ac5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	74 98                	je     800a5b <strtol+0x66>
  800ac3:	eb 9e                	jmp    800a63 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ac5:	89 c2                	mov    %eax,%edx
  800ac7:	f7 da                	neg    %edx
  800ac9:	85 ff                	test   %edi,%edi
  800acb:	0f 45 c2             	cmovne %edx,%eax
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae4:	89 c3                	mov    %eax,%ebx
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	89 c6                	mov    %eax,%esi
  800aea:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af7:	ba 00 00 00 00       	mov    $0x0,%edx
  800afc:	b8 01 00 00 00       	mov    $0x1,%eax
  800b01:	89 d1                	mov    %edx,%ecx
  800b03:	89 d3                	mov    %edx,%ebx
  800b05:	89 d7                	mov    %edx,%edi
  800b07:	89 d6                	mov    %edx,%esi
  800b09:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	89 cb                	mov    %ecx,%ebx
  800b28:	89 cf                	mov    %ecx,%edi
  800b2a:	89 ce                	mov    %ecx,%esi
  800b2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	7e 17                	jle    800b49 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	50                   	push   %eax
  800b36:	6a 03                	push   $0x3
  800b38:	68 9f 21 80 00       	push   $0x80219f
  800b3d:	6a 23                	push   $0x23
  800b3f:	68 bc 21 80 00       	push   $0x8021bc
  800b44:	e8 f5 0e 00 00       	call   801a3e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b61:	89 d1                	mov    %edx,%ecx
  800b63:	89 d3                	mov    %edx,%ebx
  800b65:	89 d7                	mov    %edx,%edi
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_yield>:

void
sys_yield(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	be 00 00 00 00       	mov    $0x0,%esi
  800b9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bab:	89 f7                	mov    %esi,%edi
  800bad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7e 17                	jle    800bca <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 04                	push   $0x4
  800bb9:	68 9f 21 80 00       	push   $0x80219f
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 bc 21 80 00       	push   $0x8021bc
  800bc5:	e8 74 0e 00 00       	call   801a3e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	b8 05 00 00 00       	mov    $0x5,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bec:	8b 75 18             	mov    0x18(%ebp),%esi
  800bef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7e 17                	jle    800c0c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	50                   	push   %eax
  800bf9:	6a 05                	push   $0x5
  800bfb:	68 9f 21 80 00       	push   $0x80219f
  800c00:	6a 23                	push   $0x23
  800c02:	68 bc 21 80 00       	push   $0x8021bc
  800c07:	e8 32 0e 00 00       	call   801a3e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	b8 06 00 00 00       	mov    $0x6,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 06                	push   $0x6
  800c3d:	68 9f 21 80 00       	push   $0x80219f
  800c42:	6a 23                	push   $0x23
  800c44:	68 bc 21 80 00       	push   $0x8021bc
  800c49:	e8 f0 0d 00 00       	call   801a3e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c64:	b8 08 00 00 00       	mov    $0x8,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	89 df                	mov    %ebx,%edi
  800c71:	89 de                	mov    %ebx,%esi
  800c73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 17                	jle    800c90 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	50                   	push   %eax
  800c7d:	6a 08                	push   $0x8
  800c7f:	68 9f 21 80 00       	push   $0x80219f
  800c84:	6a 23                	push   $0x23
  800c86:	68 bc 21 80 00       	push   $0x8021bc
  800c8b:	e8 ae 0d 00 00       	call   801a3e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca6:	b8 09 00 00 00       	mov    $0x9,%eax
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	89 df                	mov    %ebx,%edi
  800cb3:	89 de                	mov    %ebx,%esi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 09                	push   $0x9
  800cc1:	68 9f 21 80 00       	push   $0x80219f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 bc 21 80 00       	push   $0x8021bc
  800ccd:	e8 6c 0d 00 00       	call   801a3e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 0a                	push   $0xa
  800d03:	68 9f 21 80 00       	push   $0x80219f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 bc 21 80 00       	push   $0x8021bc
  800d0f:	e8 2a 0d 00 00       	call   801a3e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	be 00 00 00 00       	mov    $0x0,%esi
  800d27:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d38:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	89 cb                	mov    %ecx,%ebx
  800d57:	89 cf                	mov    %ecx,%edi
  800d59:	89 ce                	mov    %ecx,%esi
  800d5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	7e 17                	jle    800d78 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	50                   	push   %eax
  800d65:	6a 0d                	push   $0xd
  800d67:	68 9f 21 80 00       	push   $0x80219f
  800d6c:	6a 23                	push   $0x23
  800d6e:	68 bc 21 80 00       	push   $0x8021bc
  800d73:	e8 c6 0c 00 00       	call   801a3e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	05 00 00 00 30       	add    $0x30000000,%eax
  800d9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dad:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db2:	89 c2                	mov    %eax,%edx
  800db4:	c1 ea 16             	shr    $0x16,%edx
  800db7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dbe:	f6 c2 01             	test   $0x1,%dl
  800dc1:	74 11                	je     800dd4 <fd_alloc+0x2d>
  800dc3:	89 c2                	mov    %eax,%edx
  800dc5:	c1 ea 0c             	shr    $0xc,%edx
  800dc8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcf:	f6 c2 01             	test   $0x1,%dl
  800dd2:	75 09                	jne    800ddd <fd_alloc+0x36>
			*fd_store = fd;
  800dd4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddb:	eb 17                	jmp    800df4 <fd_alloc+0x4d>
  800ddd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800de7:	75 c9                	jne    800db2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800de9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800def:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dfc:	83 f8 1f             	cmp    $0x1f,%eax
  800dff:	77 36                	ja     800e37 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e01:	c1 e0 0c             	shl    $0xc,%eax
  800e04:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e09:	89 c2                	mov    %eax,%edx
  800e0b:	c1 ea 16             	shr    $0x16,%edx
  800e0e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e15:	f6 c2 01             	test   $0x1,%dl
  800e18:	74 24                	je     800e3e <fd_lookup+0x48>
  800e1a:	89 c2                	mov    %eax,%edx
  800e1c:	c1 ea 0c             	shr    $0xc,%edx
  800e1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e26:	f6 c2 01             	test   $0x1,%dl
  800e29:	74 1a                	je     800e45 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
  800e35:	eb 13                	jmp    800e4a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3c:	eb 0c                	jmp    800e4a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e43:	eb 05                	jmp    800e4a <fd_lookup+0x54>
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e55:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e5a:	eb 13                	jmp    800e6f <dev_lookup+0x23>
  800e5c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e5f:	39 08                	cmp    %ecx,(%eax)
  800e61:	75 0c                	jne    800e6f <dev_lookup+0x23>
			*dev = devtab[i];
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6d:	eb 2e                	jmp    800e9d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e6f:	8b 02                	mov    (%edx),%eax
  800e71:	85 c0                	test   %eax,%eax
  800e73:	75 e7                	jne    800e5c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e75:	a1 04 40 80 00       	mov    0x804004,%eax
  800e7a:	8b 40 48             	mov    0x48(%eax),%eax
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	51                   	push   %ecx
  800e81:	50                   	push   %eax
  800e82:	68 cc 21 80 00       	push   $0x8021cc
  800e87:	e8 d4 f2 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 10             	sub    $0x10,%esp
  800ea7:	8b 75 08             	mov    0x8(%ebp),%esi
  800eaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ead:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb0:	50                   	push   %eax
  800eb1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb7:	c1 e8 0c             	shr    $0xc,%eax
  800eba:	50                   	push   %eax
  800ebb:	e8 36 ff ff ff       	call   800df6 <fd_lookup>
  800ec0:	83 c4 08             	add    $0x8,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 05                	js     800ecc <fd_close+0x2d>
	    || fd != fd2)
  800ec7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eca:	74 0c                	je     800ed8 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ecc:	84 db                	test   %bl,%bl
  800ece:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed3:	0f 44 c2             	cmove  %edx,%eax
  800ed6:	eb 41                	jmp    800f19 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed8:	83 ec 08             	sub    $0x8,%esp
  800edb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ede:	50                   	push   %eax
  800edf:	ff 36                	pushl  (%esi)
  800ee1:	e8 66 ff ff ff       	call   800e4c <dev_lookup>
  800ee6:	89 c3                	mov    %eax,%ebx
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 1a                	js     800f09 <fd_close+0x6a>
		if (dev->dev_close)
  800eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800efa:	85 c0                	test   %eax,%eax
  800efc:	74 0b                	je     800f09 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	56                   	push   %esi
  800f02:	ff d0                	call   *%eax
  800f04:	89 c3                	mov    %eax,%ebx
  800f06:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f09:	83 ec 08             	sub    $0x8,%esp
  800f0c:	56                   	push   %esi
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 00 fd ff ff       	call   800c14 <sys_page_unmap>
	return r;
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	89 d8                	mov    %ebx,%eax
}
  800f19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f29:	50                   	push   %eax
  800f2a:	ff 75 08             	pushl  0x8(%ebp)
  800f2d:	e8 c4 fe ff ff       	call   800df6 <fd_lookup>
  800f32:	83 c4 08             	add    $0x8,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 10                	js     800f49 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f39:	83 ec 08             	sub    $0x8,%esp
  800f3c:	6a 01                	push   $0x1
  800f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f41:	e8 59 ff ff ff       	call   800e9f <fd_close>
  800f46:	83 c4 10             	add    $0x10,%esp
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <close_all>:

void
close_all(void)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	53                   	push   %ebx
  800f5b:	e8 c0 ff ff ff       	call   800f20 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f60:	83 c3 01             	add    $0x1,%ebx
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	83 fb 20             	cmp    $0x20,%ebx
  800f69:	75 ec                	jne    800f57 <close_all+0xc>
		close(i);
}
  800f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 2c             	sub    $0x2c,%esp
  800f79:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f7c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	ff 75 08             	pushl  0x8(%ebp)
  800f83:	e8 6e fe ff ff       	call   800df6 <fd_lookup>
  800f88:	83 c4 08             	add    $0x8,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	0f 88 c1 00 00 00    	js     801054 <dup+0xe4>
		return r;
	close(newfdnum);
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	56                   	push   %esi
  800f97:	e8 84 ff ff ff       	call   800f20 <close>

	newfd = INDEX2FD(newfdnum);
  800f9c:	89 f3                	mov    %esi,%ebx
  800f9e:	c1 e3 0c             	shl    $0xc,%ebx
  800fa1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fa7:	83 c4 04             	add    $0x4,%esp
  800faa:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fad:	e8 de fd ff ff       	call   800d90 <fd2data>
  800fb2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fb4:	89 1c 24             	mov    %ebx,(%esp)
  800fb7:	e8 d4 fd ff ff       	call   800d90 <fd2data>
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc2:	89 f8                	mov    %edi,%eax
  800fc4:	c1 e8 16             	shr    $0x16,%eax
  800fc7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fce:	a8 01                	test   $0x1,%al
  800fd0:	74 37                	je     801009 <dup+0x99>
  800fd2:	89 f8                	mov    %edi,%eax
  800fd4:	c1 e8 0c             	shr    $0xc,%eax
  800fd7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fde:	f6 c2 01             	test   $0x1,%dl
  800fe1:	74 26                	je     801009 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff2:	50                   	push   %eax
  800ff3:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ff6:	6a 00                	push   $0x0
  800ff8:	57                   	push   %edi
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 d2 fb ff ff       	call   800bd2 <sys_page_map>
  801000:	89 c7                	mov    %eax,%edi
  801002:	83 c4 20             	add    $0x20,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	78 2e                	js     801037 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801009:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80100c:	89 d0                	mov    %edx,%eax
  80100e:	c1 e8 0c             	shr    $0xc,%eax
  801011:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	25 07 0e 00 00       	and    $0xe07,%eax
  801020:	50                   	push   %eax
  801021:	53                   	push   %ebx
  801022:	6a 00                	push   $0x0
  801024:	52                   	push   %edx
  801025:	6a 00                	push   $0x0
  801027:	e8 a6 fb ff ff       	call   800bd2 <sys_page_map>
  80102c:	89 c7                	mov    %eax,%edi
  80102e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801031:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801033:	85 ff                	test   %edi,%edi
  801035:	79 1d                	jns    801054 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	53                   	push   %ebx
  80103b:	6a 00                	push   $0x0
  80103d:	e8 d2 fb ff ff       	call   800c14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801042:	83 c4 08             	add    $0x8,%esp
  801045:	ff 75 d4             	pushl  -0x2c(%ebp)
  801048:	6a 00                	push   $0x0
  80104a:	e8 c5 fb ff ff       	call   800c14 <sys_page_unmap>
	return r;
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	89 f8                	mov    %edi,%eax
}
  801054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 14             	sub    $0x14,%esp
  801063:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801066:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801069:	50                   	push   %eax
  80106a:	53                   	push   %ebx
  80106b:	e8 86 fd ff ff       	call   800df6 <fd_lookup>
  801070:	83 c4 08             	add    $0x8,%esp
  801073:	89 c2                	mov    %eax,%edx
  801075:	85 c0                	test   %eax,%eax
  801077:	78 6d                	js     8010e6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801079:	83 ec 08             	sub    $0x8,%esp
  80107c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107f:	50                   	push   %eax
  801080:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801083:	ff 30                	pushl  (%eax)
  801085:	e8 c2 fd ff ff       	call   800e4c <dev_lookup>
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	78 4c                	js     8010dd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801091:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801094:	8b 42 08             	mov    0x8(%edx),%eax
  801097:	83 e0 03             	and    $0x3,%eax
  80109a:	83 f8 01             	cmp    $0x1,%eax
  80109d:	75 21                	jne    8010c0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80109f:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a4:	8b 40 48             	mov    0x48(%eax),%eax
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	53                   	push   %ebx
  8010ab:	50                   	push   %eax
  8010ac:	68 0d 22 80 00       	push   $0x80220d
  8010b1:	e8 aa f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010be:	eb 26                	jmp    8010e6 <read+0x8a>
	}
	if (!dev->dev_read)
  8010c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c3:	8b 40 08             	mov    0x8(%eax),%eax
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	74 17                	je     8010e1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010ca:	83 ec 04             	sub    $0x4,%esp
  8010cd:	ff 75 10             	pushl  0x10(%ebp)
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	52                   	push   %edx
  8010d4:	ff d0                	call   *%eax
  8010d6:	89 c2                	mov    %eax,%edx
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	eb 09                	jmp    8010e6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	eb 05                	jmp    8010e6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010e6:	89 d0                	mov    %edx,%eax
  8010e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801101:	eb 21                	jmp    801124 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801103:	83 ec 04             	sub    $0x4,%esp
  801106:	89 f0                	mov    %esi,%eax
  801108:	29 d8                	sub    %ebx,%eax
  80110a:	50                   	push   %eax
  80110b:	89 d8                	mov    %ebx,%eax
  80110d:	03 45 0c             	add    0xc(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	57                   	push   %edi
  801112:	e8 45 ff ff ff       	call   80105c <read>
		if (m < 0)
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 10                	js     80112e <readn+0x41>
			return m;
		if (m == 0)
  80111e:	85 c0                	test   %eax,%eax
  801120:	74 0a                	je     80112c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801122:	01 c3                	add    %eax,%ebx
  801124:	39 f3                	cmp    %esi,%ebx
  801126:	72 db                	jb     801103 <readn+0x16>
  801128:	89 d8                	mov    %ebx,%eax
  80112a:	eb 02                	jmp    80112e <readn+0x41>
  80112c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	83 ec 14             	sub    $0x14,%esp
  80113d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801140:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801143:	50                   	push   %eax
  801144:	53                   	push   %ebx
  801145:	e8 ac fc ff ff       	call   800df6 <fd_lookup>
  80114a:	83 c4 08             	add    $0x8,%esp
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 68                	js     8011bb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115d:	ff 30                	pushl  (%eax)
  80115f:	e8 e8 fc ff ff       	call   800e4c <dev_lookup>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 47                	js     8011b2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801172:	75 21                	jne    801195 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801174:	a1 04 40 80 00       	mov    0x804004,%eax
  801179:	8b 40 48             	mov    0x48(%eax),%eax
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	53                   	push   %ebx
  801180:	50                   	push   %eax
  801181:	68 29 22 80 00       	push   $0x802229
  801186:	e8 d5 ef ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801193:	eb 26                	jmp    8011bb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801195:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801198:	8b 52 0c             	mov    0xc(%edx),%edx
  80119b:	85 d2                	test   %edx,%edx
  80119d:	74 17                	je     8011b6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80119f:	83 ec 04             	sub    $0x4,%esp
  8011a2:	ff 75 10             	pushl  0x10(%ebp)
  8011a5:	ff 75 0c             	pushl  0xc(%ebp)
  8011a8:	50                   	push   %eax
  8011a9:	ff d2                	call   *%edx
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	eb 09                	jmp    8011bb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	eb 05                	jmp    8011bb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011bb:	89 d0                	mov    %edx,%eax
  8011bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	ff 75 08             	pushl  0x8(%ebp)
  8011cf:	e8 22 fc ff ff       	call   800df6 <fd_lookup>
  8011d4:	83 c4 08             	add    $0x8,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 0e                	js     8011e9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 14             	sub    $0x14,%esp
  8011f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	53                   	push   %ebx
  8011fa:	e8 f7 fb ff ff       	call   800df6 <fd_lookup>
  8011ff:	83 c4 08             	add    $0x8,%esp
  801202:	89 c2                	mov    %eax,%edx
  801204:	85 c0                	test   %eax,%eax
  801206:	78 65                	js     80126d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801208:	83 ec 08             	sub    $0x8,%esp
  80120b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120e:	50                   	push   %eax
  80120f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801212:	ff 30                	pushl  (%eax)
  801214:	e8 33 fc ff ff       	call   800e4c <dev_lookup>
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 44                	js     801264 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801223:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801227:	75 21                	jne    80124a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801229:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80122e:	8b 40 48             	mov    0x48(%eax),%eax
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	53                   	push   %ebx
  801235:	50                   	push   %eax
  801236:	68 ec 21 80 00       	push   $0x8021ec
  80123b:	e8 20 ef ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801248:	eb 23                	jmp    80126d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80124a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124d:	8b 52 18             	mov    0x18(%edx),%edx
  801250:	85 d2                	test   %edx,%edx
  801252:	74 14                	je     801268 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	ff 75 0c             	pushl  0xc(%ebp)
  80125a:	50                   	push   %eax
  80125b:	ff d2                	call   *%edx
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	eb 09                	jmp    80126d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801264:	89 c2                	mov    %eax,%edx
  801266:	eb 05                	jmp    80126d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801268:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80126d:	89 d0                	mov    %edx,%eax
  80126f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	53                   	push   %ebx
  801278:	83 ec 14             	sub    $0x14,%esp
  80127b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801281:	50                   	push   %eax
  801282:	ff 75 08             	pushl  0x8(%ebp)
  801285:	e8 6c fb ff ff       	call   800df6 <fd_lookup>
  80128a:	83 c4 08             	add    $0x8,%esp
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 58                	js     8012eb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801293:	83 ec 08             	sub    $0x8,%esp
  801296:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801299:	50                   	push   %eax
  80129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129d:	ff 30                	pushl  (%eax)
  80129f:	e8 a8 fb ff ff       	call   800e4c <dev_lookup>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 37                	js     8012e2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ae:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b2:	74 32                	je     8012e6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012b4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012b7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012be:	00 00 00 
	stat->st_isdir = 0;
  8012c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012c8:	00 00 00 
	stat->st_dev = dev;
  8012cb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d1:	83 ec 08             	sub    $0x8,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d8:	ff 50 14             	call   *0x14(%eax)
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	eb 09                	jmp    8012eb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	eb 05                	jmp    8012eb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	56                   	push   %esi
  8012f6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	6a 00                	push   $0x0
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	e8 b7 01 00 00       	call   8014bb <open>
  801304:	89 c3                	mov    %eax,%ebx
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 1b                	js     801328 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	ff 75 0c             	pushl  0xc(%ebp)
  801313:	50                   	push   %eax
  801314:	e8 5b ff ff ff       	call   801274 <fstat>
  801319:	89 c6                	mov    %eax,%esi
	close(fd);
  80131b:	89 1c 24             	mov    %ebx,(%esp)
  80131e:	e8 fd fb ff ff       	call   800f20 <close>
	return r;
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	89 f0                	mov    %esi,%eax
}
  801328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	89 c6                	mov    %eax,%esi
  801336:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801338:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80133f:	75 12                	jne    801353 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	6a 01                	push   $0x1
  801346:	e8 02 08 00 00       	call   801b4d <ipc_find_env>
  80134b:	a3 00 40 80 00       	mov    %eax,0x804000
  801350:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801353:	6a 07                	push   $0x7
  801355:	68 00 50 80 00       	push   $0x805000
  80135a:	56                   	push   %esi
  80135b:	ff 35 00 40 80 00    	pushl  0x804000
  801361:	e8 93 07 00 00       	call   801af9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801366:	83 c4 0c             	add    $0xc,%esp
  801369:	6a 00                	push   $0x0
  80136b:	53                   	push   %ebx
  80136c:	6a 00                	push   $0x0
  80136e:	e8 11 07 00 00       	call   801a84 <ipc_recv>
}
  801373:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801376:	5b                   	pop    %ebx
  801377:	5e                   	pop    %esi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801380:	8b 45 08             	mov    0x8(%ebp),%eax
  801383:	8b 40 0c             	mov    0xc(%eax),%eax
  801386:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80138b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801393:	ba 00 00 00 00       	mov    $0x0,%edx
  801398:	b8 02 00 00 00       	mov    $0x2,%eax
  80139d:	e8 8d ff ff ff       	call   80132f <fsipc>
}
  8013a2:	c9                   	leave  
  8013a3:	c3                   	ret    

008013a4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8013bf:	e8 6b ff ff ff       	call   80132f <fsipc>
}
  8013c4:	c9                   	leave  
  8013c5:	c3                   	ret    

008013c6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 04             	sub    $0x4,%esp
  8013cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013db:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8013e5:	e8 45 ff ff ff       	call   80132f <fsipc>
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 2c                	js     80141a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	68 00 50 80 00       	push   $0x805000
  8013f6:	53                   	push   %ebx
  8013f7:	e8 90 f3 ff ff       	call   80078c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013fc:	a1 80 50 80 00       	mov    0x805080,%eax
  801401:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801407:	a1 84 50 80 00       	mov    0x805084,%eax
  80140c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801425:	68 58 22 80 00       	push   $0x802258
  80142a:	68 90 00 00 00       	push   $0x90
  80142f:	68 76 22 80 00       	push   $0x802276
  801434:	e8 05 06 00 00       	call   801a3e <_panic>

00801439 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
  801444:	8b 40 0c             	mov    0xc(%eax),%eax
  801447:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80144c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801452:	ba 00 00 00 00       	mov    $0x0,%edx
  801457:	b8 03 00 00 00       	mov    $0x3,%eax
  80145c:	e8 ce fe ff ff       	call   80132f <fsipc>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	85 c0                	test   %eax,%eax
  801465:	78 4b                	js     8014b2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801467:	39 c6                	cmp    %eax,%esi
  801469:	73 16                	jae    801481 <devfile_read+0x48>
  80146b:	68 81 22 80 00       	push   $0x802281
  801470:	68 88 22 80 00       	push   $0x802288
  801475:	6a 7c                	push   $0x7c
  801477:	68 76 22 80 00       	push   $0x802276
  80147c:	e8 bd 05 00 00       	call   801a3e <_panic>
	assert(r <= PGSIZE);
  801481:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801486:	7e 16                	jle    80149e <devfile_read+0x65>
  801488:	68 9d 22 80 00       	push   $0x80229d
  80148d:	68 88 22 80 00       	push   $0x802288
  801492:	6a 7d                	push   $0x7d
  801494:	68 76 22 80 00       	push   $0x802276
  801499:	e8 a0 05 00 00       	call   801a3e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	50                   	push   %eax
  8014a2:	68 00 50 80 00       	push   $0x805000
  8014a7:	ff 75 0c             	pushl  0xc(%ebp)
  8014aa:	e8 6f f4 ff ff       	call   80091e <memmove>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
}
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 20             	sub    $0x20,%esp
  8014c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c5:	53                   	push   %ebx
  8014c6:	e8 88 f2 ff ff       	call   800753 <strlen>
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d3:	7f 67                	jg     80153c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	e8 c6 f8 ff ff       	call   800da7 <fd_alloc>
  8014e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 57                	js     801541 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ea:	83 ec 08             	sub    $0x8,%esp
  8014ed:	53                   	push   %ebx
  8014ee:	68 00 50 80 00       	push   $0x805000
  8014f3:	e8 94 f2 ff ff       	call   80078c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801500:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801503:	b8 01 00 00 00       	mov    $0x1,%eax
  801508:	e8 22 fe ff ff       	call   80132f <fsipc>
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	79 14                	jns    80152a <open+0x6f>
		fd_close(fd, 0);
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	6a 00                	push   $0x0
  80151b:	ff 75 f4             	pushl  -0xc(%ebp)
  80151e:	e8 7c f9 ff ff       	call   800e9f <fd_close>
		return r;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	89 da                	mov    %ebx,%edx
  801528:	eb 17                	jmp    801541 <open+0x86>
	}

	return fd2num(fd);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	ff 75 f4             	pushl  -0xc(%ebp)
  801530:	e8 4b f8 ff ff       	call   800d80 <fd2num>
  801535:	89 c2                	mov    %eax,%edx
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	eb 05                	jmp    801541 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80153c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801541:	89 d0                	mov    %edx,%eax
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80154e:	ba 00 00 00 00       	mov    $0x0,%edx
  801553:	b8 08 00 00 00       	mov    $0x8,%eax
  801558:	e8 d2 fd ff ff       	call   80132f <fsipc>
}
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	56                   	push   %esi
  801563:	53                   	push   %ebx
  801564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	ff 75 08             	pushl  0x8(%ebp)
  80156d:	e8 1e f8 ff ff       	call   800d90 <fd2data>
  801572:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801574:	83 c4 08             	add    $0x8,%esp
  801577:	68 a9 22 80 00       	push   $0x8022a9
  80157c:	53                   	push   %ebx
  80157d:	e8 0a f2 ff ff       	call   80078c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801582:	8b 46 04             	mov    0x4(%esi),%eax
  801585:	2b 06                	sub    (%esi),%eax
  801587:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80158d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801594:	00 00 00 
	stat->st_dev = &devpipe;
  801597:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80159e:	30 80 00 
	return 0;
}
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a9:	5b                   	pop    %ebx
  8015aa:	5e                   	pop    %esi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 0c             	sub    $0xc,%esp
  8015b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015b7:	53                   	push   %ebx
  8015b8:	6a 00                	push   $0x0
  8015ba:	e8 55 f6 ff ff       	call   800c14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015bf:	89 1c 24             	mov    %ebx,(%esp)
  8015c2:	e8 c9 f7 ff ff       	call   800d90 <fd2data>
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	50                   	push   %eax
  8015cb:	6a 00                	push   $0x0
  8015cd:	e8 42 f6 ff ff       	call   800c14 <sys_page_unmap>
}
  8015d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	57                   	push   %edi
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 1c             	sub    $0x1c,%esp
  8015e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015e3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f3:	e8 8e 05 00 00       	call   801b86 <pageref>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	89 3c 24             	mov    %edi,(%esp)
  8015fd:	e8 84 05 00 00       	call   801b86 <pageref>
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	39 c3                	cmp    %eax,%ebx
  801607:	0f 94 c1             	sete   %cl
  80160a:	0f b6 c9             	movzbl %cl,%ecx
  80160d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801610:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801616:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801619:	39 ce                	cmp    %ecx,%esi
  80161b:	74 1b                	je     801638 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80161d:	39 c3                	cmp    %eax,%ebx
  80161f:	75 c4                	jne    8015e5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801621:	8b 42 58             	mov    0x58(%edx),%eax
  801624:	ff 75 e4             	pushl  -0x1c(%ebp)
  801627:	50                   	push   %eax
  801628:	56                   	push   %esi
  801629:	68 b0 22 80 00       	push   $0x8022b0
  80162e:	e8 2d eb ff ff       	call   800160 <cprintf>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb ad                	jmp    8015e5 <_pipeisclosed+0xe>
	}
}
  801638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	57                   	push   %edi
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
  801649:	83 ec 28             	sub    $0x28,%esp
  80164c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80164f:	56                   	push   %esi
  801650:	e8 3b f7 ff ff       	call   800d90 <fd2data>
  801655:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	bf 00 00 00 00       	mov    $0x0,%edi
  80165f:	eb 4b                	jmp    8016ac <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801661:	89 da                	mov    %ebx,%edx
  801663:	89 f0                	mov    %esi,%eax
  801665:	e8 6d ff ff ff       	call   8015d7 <_pipeisclosed>
  80166a:	85 c0                	test   %eax,%eax
  80166c:	75 48                	jne    8016b6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80166e:	e8 fd f4 ff ff       	call   800b70 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801673:	8b 43 04             	mov    0x4(%ebx),%eax
  801676:	8b 0b                	mov    (%ebx),%ecx
  801678:	8d 51 20             	lea    0x20(%ecx),%edx
  80167b:	39 d0                	cmp    %edx,%eax
  80167d:	73 e2                	jae    801661 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80167f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801682:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801686:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801689:	89 c2                	mov    %eax,%edx
  80168b:	c1 fa 1f             	sar    $0x1f,%edx
  80168e:	89 d1                	mov    %edx,%ecx
  801690:	c1 e9 1b             	shr    $0x1b,%ecx
  801693:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801696:	83 e2 1f             	and    $0x1f,%edx
  801699:	29 ca                	sub    %ecx,%edx
  80169b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80169f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016a3:	83 c0 01             	add    $0x1,%eax
  8016a6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a9:	83 c7 01             	add    $0x1,%edi
  8016ac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016af:	75 c2                	jne    801673 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b4:	eb 05                	jmp    8016bb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016be:	5b                   	pop    %ebx
  8016bf:	5e                   	pop    %esi
  8016c0:	5f                   	pop    %edi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	57                   	push   %edi
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 18             	sub    $0x18,%esp
  8016cc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016cf:	57                   	push   %edi
  8016d0:	e8 bb f6 ff ff       	call   800d90 <fd2data>
  8016d5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016df:	eb 3d                	jmp    80171e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016e1:	85 db                	test   %ebx,%ebx
  8016e3:	74 04                	je     8016e9 <devpipe_read+0x26>
				return i;
  8016e5:	89 d8                	mov    %ebx,%eax
  8016e7:	eb 44                	jmp    80172d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016e9:	89 f2                	mov    %esi,%edx
  8016eb:	89 f8                	mov    %edi,%eax
  8016ed:	e8 e5 fe ff ff       	call   8015d7 <_pipeisclosed>
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	75 32                	jne    801728 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016f6:	e8 75 f4 ff ff       	call   800b70 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016fb:	8b 06                	mov    (%esi),%eax
  8016fd:	3b 46 04             	cmp    0x4(%esi),%eax
  801700:	74 df                	je     8016e1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801702:	99                   	cltd   
  801703:	c1 ea 1b             	shr    $0x1b,%edx
  801706:	01 d0                	add    %edx,%eax
  801708:	83 e0 1f             	and    $0x1f,%eax
  80170b:	29 d0                	sub    %edx,%eax
  80170d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801715:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801718:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171b:	83 c3 01             	add    $0x1,%ebx
  80171e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801721:	75 d8                	jne    8016fb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801723:	8b 45 10             	mov    0x10(%ebp),%eax
  801726:	eb 05                	jmp    80172d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801728:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80172d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801730:	5b                   	pop    %ebx
  801731:	5e                   	pop    %esi
  801732:	5f                   	pop    %edi
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80173d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	e8 61 f6 ff ff       	call   800da7 <fd_alloc>
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	89 c2                	mov    %eax,%edx
  80174b:	85 c0                	test   %eax,%eax
  80174d:	0f 88 2c 01 00 00    	js     80187f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801753:	83 ec 04             	sub    $0x4,%esp
  801756:	68 07 04 00 00       	push   $0x407
  80175b:	ff 75 f4             	pushl  -0xc(%ebp)
  80175e:	6a 00                	push   $0x0
  801760:	e8 2a f4 ff ff       	call   800b8f <sys_page_alloc>
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	89 c2                	mov    %eax,%edx
  80176a:	85 c0                	test   %eax,%eax
  80176c:	0f 88 0d 01 00 00    	js     80187f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801778:	50                   	push   %eax
  801779:	e8 29 f6 ff ff       	call   800da7 <fd_alloc>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	0f 88 e2 00 00 00    	js     80186d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	68 07 04 00 00       	push   $0x407
  801793:	ff 75 f0             	pushl  -0x10(%ebp)
  801796:	6a 00                	push   $0x0
  801798:	e8 f2 f3 ff ff       	call   800b8f <sys_page_alloc>
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	0f 88 c3 00 00 00    	js     80186d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b0:	e8 db f5 ff ff       	call   800d90 <fd2data>
  8017b5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b7:	83 c4 0c             	add    $0xc,%esp
  8017ba:	68 07 04 00 00       	push   $0x407
  8017bf:	50                   	push   %eax
  8017c0:	6a 00                	push   $0x0
  8017c2:	e8 c8 f3 ff ff       	call   800b8f <sys_page_alloc>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	0f 88 89 00 00 00    	js     80185d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017da:	e8 b1 f5 ff ff       	call   800d90 <fd2data>
  8017df:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017e6:	50                   	push   %eax
  8017e7:	6a 00                	push   $0x0
  8017e9:	56                   	push   %esi
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 e1 f3 ff ff       	call   800bd2 <sys_page_map>
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	83 c4 20             	add    $0x20,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 55                	js     80184f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017fa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801803:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801805:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801808:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80180f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801818:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	ff 75 f4             	pushl  -0xc(%ebp)
  80182a:	e8 51 f5 ff ff       	call   800d80 <fd2num>
  80182f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801832:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801834:	83 c4 04             	add    $0x4,%esp
  801837:	ff 75 f0             	pushl  -0x10(%ebp)
  80183a:	e8 41 f5 ff ff       	call   800d80 <fd2num>
  80183f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801842:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	ba 00 00 00 00       	mov    $0x0,%edx
  80184d:	eb 30                	jmp    80187f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	56                   	push   %esi
  801853:	6a 00                	push   $0x0
  801855:	e8 ba f3 ff ff       	call   800c14 <sys_page_unmap>
  80185a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80185d:	83 ec 08             	sub    $0x8,%esp
  801860:	ff 75 f0             	pushl  -0x10(%ebp)
  801863:	6a 00                	push   $0x0
  801865:	e8 aa f3 ff ff       	call   800c14 <sys_page_unmap>
  80186a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	ff 75 f4             	pushl  -0xc(%ebp)
  801873:	6a 00                	push   $0x0
  801875:	e8 9a f3 ff ff       	call   800c14 <sys_page_unmap>
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80187f:	89 d0                	mov    %edx,%eax
  801881:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801884:	5b                   	pop    %ebx
  801885:	5e                   	pop    %esi
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80188e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801891:	50                   	push   %eax
  801892:	ff 75 08             	pushl  0x8(%ebp)
  801895:	e8 5c f5 ff ff       	call   800df6 <fd_lookup>
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 18                	js     8018b9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018a1:	83 ec 0c             	sub    $0xc,%esp
  8018a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a7:	e8 e4 f4 ff ff       	call   800d90 <fd2data>
	return _pipeisclosed(fd, p);
  8018ac:	89 c2                	mov    %eax,%edx
  8018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b1:	e8 21 fd ff ff       	call   8015d7 <_pipeisclosed>
  8018b6:	83 c4 10             	add    $0x10,%esp
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018cb:	68 c8 22 80 00       	push   $0x8022c8
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	e8 b4 ee ff ff       	call   80078c <strcpy>
	return 0;
}
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	57                   	push   %edi
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018eb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018f0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f6:	eb 2d                	jmp    801925 <devcons_write+0x46>
		m = n - tot;
  8018f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018fb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018fd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801900:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801905:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801908:	83 ec 04             	sub    $0x4,%esp
  80190b:	53                   	push   %ebx
  80190c:	03 45 0c             	add    0xc(%ebp),%eax
  80190f:	50                   	push   %eax
  801910:	57                   	push   %edi
  801911:	e8 08 f0 ff ff       	call   80091e <memmove>
		sys_cputs(buf, m);
  801916:	83 c4 08             	add    $0x8,%esp
  801919:	53                   	push   %ebx
  80191a:	57                   	push   %edi
  80191b:	e8 b3 f1 ff ff       	call   800ad3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801920:	01 de                	add    %ebx,%esi
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	89 f0                	mov    %esi,%eax
  801927:	3b 75 10             	cmp    0x10(%ebp),%esi
  80192a:	72 cc                	jb     8018f8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80192c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5f                   	pop    %edi
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80193f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801943:	74 2a                	je     80196f <devcons_read+0x3b>
  801945:	eb 05                	jmp    80194c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801947:	e8 24 f2 ff ff       	call   800b70 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80194c:	e8 a0 f1 ff ff       	call   800af1 <sys_cgetc>
  801951:	85 c0                	test   %eax,%eax
  801953:	74 f2                	je     801947 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801955:	85 c0                	test   %eax,%eax
  801957:	78 16                	js     80196f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801959:	83 f8 04             	cmp    $0x4,%eax
  80195c:	74 0c                	je     80196a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80195e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801961:	88 02                	mov    %al,(%edx)
	return 1;
  801963:	b8 01 00 00 00       	mov    $0x1,%eax
  801968:	eb 05                	jmp    80196f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80196a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801977:	8b 45 08             	mov    0x8(%ebp),%eax
  80197a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80197d:	6a 01                	push   $0x1
  80197f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801982:	50                   	push   %eax
  801983:	e8 4b f1 ff ff       	call   800ad3 <sys_cputs>
}
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <getchar>:

int
getchar(void)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801993:	6a 01                	push   $0x1
  801995:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801998:	50                   	push   %eax
  801999:	6a 00                	push   $0x0
  80199b:	e8 bc f6 ff ff       	call   80105c <read>
	if (r < 0)
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 0f                	js     8019b6 <getchar+0x29>
		return r;
	if (r < 1)
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	7e 06                	jle    8019b1 <getchar+0x24>
		return -E_EOF;
	return c;
  8019ab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019af:	eb 05                	jmp    8019b6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019b1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c1:	50                   	push   %eax
  8019c2:	ff 75 08             	pushl  0x8(%ebp)
  8019c5:	e8 2c f4 ff ff       	call   800df6 <fd_lookup>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 11                	js     8019e2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019da:	39 10                	cmp    %edx,(%eax)
  8019dc:	0f 94 c0             	sete   %al
  8019df:	0f b6 c0             	movzbl %al,%eax
}
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <opencons>:

int
opencons(void)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ed:	50                   	push   %eax
  8019ee:	e8 b4 f3 ff ff       	call   800da7 <fd_alloc>
  8019f3:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 3e                	js     801a3a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019fc:	83 ec 04             	sub    $0x4,%esp
  8019ff:	68 07 04 00 00       	push   $0x407
  801a04:	ff 75 f4             	pushl  -0xc(%ebp)
  801a07:	6a 00                	push   $0x0
  801a09:	e8 81 f1 ff ff       	call   800b8f <sys_page_alloc>
  801a0e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a11:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 23                	js     801a3a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a17:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a20:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	50                   	push   %eax
  801a30:	e8 4b f3 ff ff       	call   800d80 <fd2num>
  801a35:	89 c2                	mov    %eax,%edx
  801a37:	83 c4 10             	add    $0x10,%esp
}
  801a3a:	89 d0                	mov    %edx,%eax
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a43:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a46:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a4c:	e8 00 f1 ff ff       	call   800b51 <sys_getenvid>
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	ff 75 0c             	pushl  0xc(%ebp)
  801a57:	ff 75 08             	pushl  0x8(%ebp)
  801a5a:	56                   	push   %esi
  801a5b:	50                   	push   %eax
  801a5c:	68 d4 22 80 00       	push   $0x8022d4
  801a61:	e8 fa e6 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a66:	83 c4 18             	add    $0x18,%esp
  801a69:	53                   	push   %ebx
  801a6a:	ff 75 10             	pushl  0x10(%ebp)
  801a6d:	e8 9d e6 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801a72:	c7 04 24 c1 22 80 00 	movl   $0x8022c1,(%esp)
  801a79:	e8 e2 e6 ff ff       	call   800160 <cprintf>
  801a7e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a81:	cc                   	int3   
  801a82:	eb fd                	jmp    801a81 <_panic+0x43>

00801a84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a92:	85 c0                	test   %eax,%eax
  801a94:	74 0e                	je     801aa4 <ipc_recv+0x20>
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	50                   	push   %eax
  801a9a:	e8 a0 f2 ff ff       	call   800d3f <sys_ipc_recv>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	eb 10                	jmp    801ab4 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	68 00 00 c0 ee       	push   $0xeec00000
  801aac:	e8 8e f2 ff ff       	call   800d3f <sys_ipc_recv>
  801ab1:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	74 16                	je     801ace <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801ab8:	85 f6                	test   %esi,%esi
  801aba:	74 06                	je     801ac2 <ipc_recv+0x3e>
  801abc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801ac2:	85 db                	test   %ebx,%ebx
  801ac4:	74 2c                	je     801af2 <ipc_recv+0x6e>
  801ac6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801acc:	eb 24                	jmp    801af2 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ace:	85 f6                	test   %esi,%esi
  801ad0:	74 0a                	je     801adc <ipc_recv+0x58>
  801ad2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad7:	8b 40 74             	mov    0x74(%eax),%eax
  801ada:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	74 0a                	je     801aea <ipc_recv+0x66>
  801ae0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae5:	8b 40 78             	mov    0x78(%eax),%eax
  801ae8:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801aea:	a1 04 40 80 00       	mov    0x804004,%eax
  801aef:	8b 40 70             	mov    0x70(%eax),%eax
}
  801af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	57                   	push   %edi
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b08:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b12:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b15:	ff 75 14             	pushl  0x14(%ebp)
  801b18:	53                   	push   %ebx
  801b19:	56                   	push   %esi
  801b1a:	57                   	push   %edi
  801b1b:	e8 fc f1 ff ff       	call   800d1c <sys_ipc_try_send>
		if (ret == 0) break;
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	85 c0                	test   %eax,%eax
  801b25:	74 1e                	je     801b45 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b27:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2a:	74 12                	je     801b3e <ipc_send+0x45>
  801b2c:	50                   	push   %eax
  801b2d:	68 f8 22 80 00       	push   $0x8022f8
  801b32:	6a 39                	push   $0x39
  801b34:	68 05 23 80 00       	push   $0x802305
  801b39:	e8 00 ff ff ff       	call   801a3e <_panic>
		sys_yield();
  801b3e:	e8 2d f0 ff ff       	call   800b70 <sys_yield>
	}
  801b43:	eb d0                	jmp    801b15 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5f                   	pop    %edi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b58:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b5b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b61:	8b 52 50             	mov    0x50(%edx),%edx
  801b64:	39 ca                	cmp    %ecx,%edx
  801b66:	75 0d                	jne    801b75 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b68:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b6b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b70:	8b 40 48             	mov    0x48(%eax),%eax
  801b73:	eb 0f                	jmp    801b84 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b75:	83 c0 01             	add    $0x1,%eax
  801b78:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b7d:	75 d9                	jne    801b58 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8c:	89 d0                	mov    %edx,%eax
  801b8e:	c1 e8 16             	shr    $0x16,%eax
  801b91:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9d:	f6 c1 01             	test   $0x1,%cl
  801ba0:	74 1d                	je     801bbf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba2:	c1 ea 0c             	shr    $0xc,%edx
  801ba5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bac:	f6 c2 01             	test   $0x1,%dl
  801baf:	74 0e                	je     801bbf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb1:	c1 ea 0c             	shr    $0xc,%edx
  801bb4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bbb:	ef 
  801bbc:	0f b7 c0             	movzwl %ax,%eax
}
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    
  801bc1:	66 90                	xchg   %ax,%ax
  801bc3:	66 90                	xchg   %ax,%ax
  801bc5:	66 90                	xchg   %ax,%ax
  801bc7:	66 90                	xchg   %ax,%ax
  801bc9:	66 90                	xchg   %ax,%ax
  801bcb:	66 90                	xchg   %ax,%ax
  801bcd:	66 90                	xchg   %ax,%ax
  801bcf:	90                   	nop

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801be7:	85 f6                	test   %esi,%esi
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	89 ca                	mov    %ecx,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	75 3d                	jne    801c30 <__udivdi3+0x60>
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	0f 87 c5 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801bfb:	85 ff                	test   %edi,%edi
  801bfd:	89 fd                	mov    %edi,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 c8                	mov    %ecx,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	89 cf                	mov    %ecx,%edi
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 74                	ja     801ca8 <__udivdi3+0xd8>
  801c34:	0f bd fe             	bsr    %esi,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0x108>
  801c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	89 c5                	mov    %eax,%ebp
  801c49:	29 fb                	sub    %edi,%ebx
  801c4b:	d3 e6                	shl    %cl,%esi
  801c4d:	89 d9                	mov    %ebx,%ecx
  801c4f:	d3 ed                	shr    %cl,%ebp
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	09 ee                	or     %ebp,%esi
  801c57:	89 d9                	mov    %ebx,%ecx
  801c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5d:	89 d5                	mov    %edx,%ebp
  801c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c63:	d3 ed                	shr    %cl,%ebp
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 d9                	mov    %ebx,%ecx
  801c6b:	d3 e8                	shr    %cl,%eax
  801c6d:	09 c2                	or     %eax,%edx
  801c6f:	89 d0                	mov    %edx,%eax
  801c71:	89 ea                	mov    %ebp,%edx
  801c73:	f7 f6                	div    %esi
  801c75:	89 d5                	mov    %edx,%ebp
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	f7 64 24 0c          	mull   0xc(%esp)
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	72 10                	jb     801c91 <__udivdi3+0xc1>
  801c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 07                	jae    801c94 <__udivdi3+0xc4>
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	75 03                	jne    801c94 <__udivdi3+0xc4>
  801c91:	83 eb 01             	sub    $0x1,%ebx
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 db                	xor    %ebx,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	72 0c                	jb     801ce8 <__udivdi3+0x118>
  801cdc:	31 db                	xor    %ebx,%ebx
  801cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce2:	0f 87 34 ff ff ff    	ja     801c1c <__udivdi3+0x4c>
  801ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ced:	e9 2a ff ff ff       	jmp    801c1c <__udivdi3+0x4c>
  801cf2:	66 90                	xchg   %ax,%ax
  801cf4:	66 90                	xchg   %ax,%ax
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 d2                	test   %edx,%edx
  801d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2a:	75 1c                	jne    801d48 <__umoddi3+0x48>
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	76 50                	jbe    801d80 <__umoddi3+0x80>
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	f7 f7                	div    %edi
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	77 52                	ja     801da0 <__umoddi3+0xa0>
  801d4e:	0f bd ea             	bsr    %edx,%ebp
  801d51:	83 f5 1f             	xor    $0x1f,%ebp
  801d54:	75 5a                	jne    801db0 <__umoddi3+0xb0>
  801d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d5a:	0f 82 e0 00 00 00    	jb     801e40 <__umoddi3+0x140>
  801d60:	39 0c 24             	cmp    %ecx,(%esp)
  801d63:	0f 86 d7 00 00 00    	jbe    801e40 <__umoddi3+0x140>
  801d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	85 ff                	test   %edi,%edi
  801d82:	89 fd                	mov    %edi,%ebp
  801d84:	75 0b                	jne    801d91 <__umoddi3+0x91>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f7                	div    %edi
  801d8f:	89 c5                	mov    %eax,%ebp
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f5                	div    %ebp
  801d97:	89 c8                	mov    %ecx,%eax
  801d99:	f7 f5                	div    %ebp
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	eb 99                	jmp    801d38 <__umoddi3+0x38>
  801d9f:	90                   	nop
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	83 c4 1c             	add    $0x1c,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	8b 34 24             	mov    (%esp),%esi
  801db3:	bf 20 00 00 00       	mov    $0x20,%edi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	29 ef                	sub    %ebp,%edi
  801dbc:	d3 e0                	shl    %cl,%eax
  801dbe:	89 f9                	mov    %edi,%ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	d3 ea                	shr    %cl,%edx
  801dc4:	89 e9                	mov    %ebp,%ecx
  801dc6:	09 c2                	or     %eax,%edx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	d3 e3                	shl    %cl,%ebx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	09 d8                	or     %ebx,%eax
  801ded:	89 d3                	mov    %edx,%ebx
  801def:	89 f2                	mov    %esi,%edx
  801df1:	f7 34 24             	divl   (%esp)
  801df4:	89 d6                	mov    %edx,%esi
  801df6:	d3 e3                	shl    %cl,%ebx
  801df8:	f7 64 24 04          	mull   0x4(%esp)
  801dfc:	39 d6                	cmp    %edx,%esi
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	72 08                	jb     801e10 <__umoddi3+0x110>
  801e08:	75 11                	jne    801e1b <__umoddi3+0x11b>
  801e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e0e:	73 0b                	jae    801e1b <__umoddi3+0x11b>
  801e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e14:	1b 14 24             	sbb    (%esp),%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e1f:	29 da                	sub    %ebx,%edx
  801e21:	19 ce                	sbb    %ecx,%esi
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e0                	shl    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 ea                	shr    %cl,%edx
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	d3 ee                	shr    %cl,%esi
  801e31:	09 d0                	or     %edx,%eax
  801e33:	89 f2                	mov    %esi,%edx
  801e35:	83 c4 1c             	add    $0x1c,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	29 f9                	sub    %edi,%ecx
  801e42:	19 d6                	sbb    %edx,%esi
  801e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	e9 18 ff ff ff       	jmp    801d69 <__umoddi3+0x69>
