
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 40 1e 80 00       	push   $0x801e40
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800059:	e8 d4 0a 00 00       	call   800b32 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 8d 0e 00 00       	call   800f2c <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 48 0a 00 00       	call   800af1 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 d6 09 00 00       	call   800ab4 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 1a 01 00 00       	call   80023e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 7b 09 00 00       	call   800ab4 <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 07 1a 00 00       	call   801bb0 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 f4 1a 00 00       	call   801ce0 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 68 1e 80 00 	movsbl 0x801e68(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80020a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80020e:	8b 10                	mov    (%eax),%edx
  800210:	3b 50 04             	cmp    0x4(%eax),%edx
  800213:	73 0a                	jae    80021f <sprintputch+0x1b>
		*b->buf++ = ch;
  800215:	8d 4a 01             	lea    0x1(%edx),%ecx
  800218:	89 08                	mov    %ecx,(%eax)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	88 02                	mov    %al,(%edx)
}
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800227:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80022a:	50                   	push   %eax
  80022b:	ff 75 10             	pushl  0x10(%ebp)
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	e8 05 00 00 00       	call   80023e <vprintfmt>
	va_end(ap);
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	57                   	push   %edi
  800242:	56                   	push   %esi
  800243:	53                   	push   %ebx
  800244:	83 ec 2c             	sub    $0x2c,%esp
  800247:	8b 75 08             	mov    0x8(%ebp),%esi
  80024a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80024d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800250:	eb 12                	jmp    800264 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800252:	85 c0                	test   %eax,%eax
  800254:	0f 84 6a 04 00 00    	je     8006c4 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	53                   	push   %ebx
  80025e:	50                   	push   %eax
  80025f:	ff d6                	call   *%esi
  800261:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800264:	83 c7 01             	add    $0x1,%edi
  800267:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80026b:	83 f8 25             	cmp    $0x25,%eax
  80026e:	75 e2                	jne    800252 <vprintfmt+0x14>
  800270:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800274:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80027b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800282:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800289:	b9 00 00 00 00       	mov    $0x0,%ecx
  80028e:	eb 07                	jmp    800297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800290:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800293:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800297:	8d 47 01             	lea    0x1(%edi),%eax
  80029a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029d:	0f b6 07             	movzbl (%edi),%eax
  8002a0:	0f b6 d0             	movzbl %al,%edx
  8002a3:	83 e8 23             	sub    $0x23,%eax
  8002a6:	3c 55                	cmp    $0x55,%al
  8002a8:	0f 87 fb 03 00 00    	ja     8006a9 <vprintfmt+0x46b>
  8002ae:	0f b6 c0             	movzbl %al,%eax
  8002b1:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  8002b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002bf:	eb d6                	jmp    800297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002cf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d9:	83 f9 09             	cmp    $0x9,%ecx
  8002dc:	77 3f                	ja     80031d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002e1:	eb e9                	jmp    8002cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e6:	8b 00                	mov    (%eax),%eax
  8002e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8d 40 04             	lea    0x4(%eax),%eax
  8002f1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8002f7:	eb 2a                	jmp    800323 <vprintfmt+0xe5>
  8002f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800303:	0f 49 d0             	cmovns %eax,%edx
  800306:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030c:	eb 89                	jmp    800297 <vprintfmt+0x59>
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800311:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800318:	e9 7a ff ff ff       	jmp    800297 <vprintfmt+0x59>
  80031d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800320:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800323:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800327:	0f 89 6a ff ff ff    	jns    800297 <vprintfmt+0x59>
				width = precision, precision = -1;
  80032d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033a:	e9 58 ff ff ff       	jmp    800297 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80033f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800345:	e9 4d ff ff ff       	jmp    800297 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 78 04             	lea    0x4(%eax),%edi
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	53                   	push   %ebx
  800354:	ff 30                	pushl  (%eax)
  800356:	ff d6                	call   *%esi
			break;
  800358:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800361:	e9 fe fe ff ff       	jmp    800264 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8d 78 04             	lea    0x4(%eax),%edi
  80036c:	8b 00                	mov    (%eax),%eax
  80036e:	99                   	cltd   
  80036f:	31 d0                	xor    %edx,%eax
  800371:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800373:	83 f8 0f             	cmp    $0xf,%eax
  800376:	7f 0b                	jg     800383 <vprintfmt+0x145>
  800378:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  80037f:	85 d2                	test   %edx,%edx
  800381:	75 1b                	jne    80039e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800383:	50                   	push   %eax
  800384:	68 80 1e 80 00       	push   $0x801e80
  800389:	53                   	push   %ebx
  80038a:	56                   	push   %esi
  80038b:	e8 91 fe ff ff       	call   800221 <printfmt>
  800390:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800393:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800399:	e9 c6 fe ff ff       	jmp    800264 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80039e:	52                   	push   %edx
  80039f:	68 5a 22 80 00       	push   $0x80225a
  8003a4:	53                   	push   %ebx
  8003a5:	56                   	push   %esi
  8003a6:	e8 76 fe ff ff       	call   800221 <printfmt>
  8003ab:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	e9 ab fe ff ff       	jmp    800264 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	83 c0 04             	add    $0x4,%eax
  8003bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003c7:	85 ff                	test   %edi,%edi
  8003c9:	b8 79 1e 80 00       	mov    $0x801e79,%eax
  8003ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d5:	0f 8e 94 00 00 00    	jle    80046f <vprintfmt+0x231>
  8003db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003df:	0f 84 98 00 00 00    	je     80047d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	ff 75 d0             	pushl  -0x30(%ebp)
  8003eb:	57                   	push   %edi
  8003ec:	e8 5b 03 00 00       	call   80074c <strnlen>
  8003f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f4:	29 c1                	sub    %eax,%ecx
  8003f6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003fc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800400:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800403:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800406:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800408:	eb 0f                	jmp    800419 <vprintfmt+0x1db>
					putch(padc, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	53                   	push   %ebx
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	83 ef 01             	sub    $0x1,%edi
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	85 ff                	test   %edi,%edi
  80041b:	7f ed                	jg     80040a <vprintfmt+0x1cc>
  80041d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800420:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800423:	85 c9                	test   %ecx,%ecx
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	0f 49 c1             	cmovns %ecx,%eax
  80042d:	29 c1                	sub    %eax,%ecx
  80042f:	89 75 08             	mov    %esi,0x8(%ebp)
  800432:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800435:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800438:	89 cb                	mov    %ecx,%ebx
  80043a:	eb 4d                	jmp    800489 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80043c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800440:	74 1b                	je     80045d <vprintfmt+0x21f>
  800442:	0f be c0             	movsbl %al,%eax
  800445:	83 e8 20             	sub    $0x20,%eax
  800448:	83 f8 5e             	cmp    $0x5e,%eax
  80044b:	76 10                	jbe    80045d <vprintfmt+0x21f>
					putch('?', putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	ff 75 0c             	pushl  0xc(%ebp)
  800453:	6a 3f                	push   $0x3f
  800455:	ff 55 08             	call   *0x8(%ebp)
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	eb 0d                	jmp    80046a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 0c             	pushl  0xc(%ebp)
  800463:	52                   	push   %edx
  800464:	ff 55 08             	call   *0x8(%ebp)
  800467:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	eb 1a                	jmp    800489 <vprintfmt+0x24b>
  80046f:	89 75 08             	mov    %esi,0x8(%ebp)
  800472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80047b:	eb 0c                	jmp    800489 <vprintfmt+0x24b>
  80047d:	89 75 08             	mov    %esi,0x8(%ebp)
  800480:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800489:	83 c7 01             	add    $0x1,%edi
  80048c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800490:	0f be d0             	movsbl %al,%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	74 23                	je     8004ba <vprintfmt+0x27c>
  800497:	85 f6                	test   %esi,%esi
  800499:	78 a1                	js     80043c <vprintfmt+0x1fe>
  80049b:	83 ee 01             	sub    $0x1,%esi
  80049e:	79 9c                	jns    80043c <vprintfmt+0x1fe>
  8004a0:	89 df                	mov    %ebx,%edi
  8004a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a8:	eb 18                	jmp    8004c2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	6a 20                	push   $0x20
  8004b0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	eb 08                	jmp    8004c2 <vprintfmt+0x284>
  8004ba:	89 df                	mov    %ebx,%edi
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f e4                	jg     8004aa <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cf:	e9 90 fd ff ff       	jmp    800264 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004d4:	83 f9 01             	cmp    $0x1,%ecx
  8004d7:	7e 19                	jle    8004f2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8b 50 04             	mov    0x4(%eax),%edx
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 40 08             	lea    0x8(%eax),%eax
  8004ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f0:	eb 38                	jmp    80052a <vprintfmt+0x2ec>
	else if (lflag)
  8004f2:	85 c9                	test   %ecx,%ecx
  8004f4:	74 1b                	je     800511 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fe:	89 c1                	mov    %eax,%ecx
  800500:	c1 f9 1f             	sar    $0x1f,%ecx
  800503:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 40 04             	lea    0x4(%eax),%eax
  80050c:	89 45 14             	mov    %eax,0x14(%ebp)
  80050f:	eb 19                	jmp    80052a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8b 00                	mov    (%eax),%eax
  800516:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800519:	89 c1                	mov    %eax,%ecx
  80051b:	c1 f9 1f             	sar    $0x1f,%ecx
  80051e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 04             	lea    0x4(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80052a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800530:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800535:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800539:	0f 89 36 01 00 00    	jns    800675 <vprintfmt+0x437>
				putch('-', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 2d                	push   $0x2d
  800545:	ff d6                	call   *%esi
				num = -(long long) num;
  800547:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054d:	f7 da                	neg    %edx
  80054f:	83 d1 00             	adc    $0x0,%ecx
  800552:	f7 d9                	neg    %ecx
  800554:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800557:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055c:	e9 14 01 00 00       	jmp    800675 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800561:	83 f9 01             	cmp    $0x1,%ecx
  800564:	7e 18                	jle    80057e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 10                	mov    (%eax),%edx
  80056b:	8b 48 04             	mov    0x4(%eax),%ecx
  80056e:	8d 40 08             	lea    0x8(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800574:	b8 0a 00 00 00       	mov    $0xa,%eax
  800579:	e9 f7 00 00 00       	jmp    800675 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	74 1a                	je     80059c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 10                	mov    (%eax),%edx
  800587:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058c:	8d 40 04             	lea    0x4(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 d9 00 00 00       	jmp    800675 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 bf 00 00 00       	jmp    800675 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b6:	83 f9 01             	cmp    $0x1,%ecx
  8005b9:	7e 13                	jle    8005ce <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 50 04             	mov    0x4(%eax),%edx
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005c6:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cc:	eb 28                	jmp    8005f6 <vprintfmt+0x3b8>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 13                	je     8005e5 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	99                   	cltd   
  8005da:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005dd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005e0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e3:	eb 11                	jmp    8005f6 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	89 d0                	mov    %edx,%eax
  8005ec:	99                   	cltd   
  8005ed:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8005f6:	89 d1                	mov    %edx,%ecx
  8005f8:	89 c2                	mov    %eax,%edx
			base = 8;
  8005fa:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005ff:	eb 74                	jmp    800675 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 30                	push   $0x30
  800607:	ff d6                	call   *%esi
			putch('x', putdat);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 78                	push   $0x78
  80060f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800624:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800629:	eb 4a                	jmp    800675 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062b:	83 f9 01             	cmp    $0x1,%ecx
  80062e:	7e 15                	jle    800645 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	8b 48 04             	mov    0x4(%eax),%ecx
  800638:	8d 40 08             	lea    0x8(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80063e:	b8 10 00 00 00       	mov    $0x10,%eax
  800643:	eb 30                	jmp    800675 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800645:	85 c9                	test   %ecx,%ecx
  800647:	74 17                	je     800660 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800659:	b8 10 00 00 00       	mov    $0x10,%eax
  80065e:	eb 15                	jmp    800675 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800675:	83 ec 0c             	sub    $0xc,%esp
  800678:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067c:	57                   	push   %edi
  80067d:	ff 75 e0             	pushl  -0x20(%ebp)
  800680:	50                   	push   %eax
  800681:	51                   	push   %ecx
  800682:	52                   	push   %edx
  800683:	89 da                	mov    %ebx,%edx
  800685:	89 f0                	mov    %esi,%eax
  800687:	e8 c9 fa ff ff       	call   800155 <printnum>
			break;
  80068c:	83 c4 20             	add    $0x20,%esp
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800692:	e9 cd fb ff ff       	jmp    800264 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	52                   	push   %edx
  80069c:	ff d6                	call   *%esi
			break;
  80069e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a4:	e9 bb fb ff ff       	jmp    800264 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 25                	push   $0x25
  8006af:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 03                	jmp    8006b9 <vprintfmt+0x47b>
  8006b6:	83 ef 01             	sub    $0x1,%edi
  8006b9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006bd:	75 f7                	jne    8006b6 <vprintfmt+0x478>
  8006bf:	e9 a0 fb ff ff       	jmp    800264 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5f                   	pop    %edi
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 18             	sub    $0x18,%esp
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006db:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006df:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 26                	je     800713 <vsnprintf+0x47>
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	7e 22                	jle    800713 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f1:	ff 75 14             	pushl  0x14(%ebp)
  8006f4:	ff 75 10             	pushl  0x10(%ebp)
  8006f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fa:	50                   	push   %eax
  8006fb:	68 04 02 80 00       	push   $0x800204
  800700:	e8 39 fb ff ff       	call   80023e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800705:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800708:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 05                	jmp    800718 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800720:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800723:	50                   	push   %eax
  800724:	ff 75 10             	pushl  0x10(%ebp)
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	ff 75 08             	pushl  0x8(%ebp)
  80072d:	e8 9a ff ff ff       	call   8006cc <vsnprintf>
	va_end(ap);

	return rc;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	eb 03                	jmp    800744 <strlen+0x10>
		n++;
  800741:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800748:	75 f7                	jne    800741 <strlen+0xd>
		n++;
	return n;
}
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800752:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800755:	ba 00 00 00 00       	mov    $0x0,%edx
  80075a:	eb 03                	jmp    80075f <strnlen+0x13>
		n++;
  80075c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	39 c2                	cmp    %eax,%edx
  800761:	74 08                	je     80076b <strnlen+0x1f>
  800763:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800767:	75 f3                	jne    80075c <strnlen+0x10>
  800769:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	53                   	push   %ebx
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800777:	89 c2                	mov    %eax,%edx
  800779:	83 c2 01             	add    $0x1,%edx
  80077c:	83 c1 01             	add    $0x1,%ecx
  80077f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800783:	88 5a ff             	mov    %bl,-0x1(%edx)
  800786:	84 db                	test   %bl,%bl
  800788:	75 ef                	jne    800779 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078a:	5b                   	pop    %ebx
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	53                   	push   %ebx
  800791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800794:	53                   	push   %ebx
  800795:	e8 9a ff ff ff       	call   800734 <strlen>
  80079a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079d:	ff 75 0c             	pushl  0xc(%ebp)
  8007a0:	01 d8                	add    %ebx,%eax
  8007a2:	50                   	push   %eax
  8007a3:	e8 c5 ff ff ff       	call   80076d <strcpy>
	return dst;
}
  8007a8:	89 d8                	mov    %ebx,%eax
  8007aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ba:	89 f3                	mov    %esi,%ebx
  8007bc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bf:	89 f2                	mov    %esi,%edx
  8007c1:	eb 0f                	jmp    8007d2 <strncpy+0x23>
		*dst++ = *src;
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	0f b6 01             	movzbl (%ecx),%eax
  8007c9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007cf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d2:	39 da                	cmp    %ebx,%edx
  8007d4:	75 ed                	jne    8007c3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ec:	85 d2                	test   %edx,%edx
  8007ee:	74 21                	je     800811 <strlcpy+0x35>
  8007f0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f4:	89 f2                	mov    %esi,%edx
  8007f6:	eb 09                	jmp    800801 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f8:	83 c2 01             	add    $0x1,%edx
  8007fb:	83 c1 01             	add    $0x1,%ecx
  8007fe:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800801:	39 c2                	cmp    %eax,%edx
  800803:	74 09                	je     80080e <strlcpy+0x32>
  800805:	0f b6 19             	movzbl (%ecx),%ebx
  800808:	84 db                	test   %bl,%bl
  80080a:	75 ec                	jne    8007f8 <strlcpy+0x1c>
  80080c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80080e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800811:	29 f0                	sub    %esi,%eax
}
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800820:	eb 06                	jmp    800828 <strcmp+0x11>
		p++, q++;
  800822:	83 c1 01             	add    $0x1,%ecx
  800825:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800828:	0f b6 01             	movzbl (%ecx),%eax
  80082b:	84 c0                	test   %al,%al
  80082d:	74 04                	je     800833 <strcmp+0x1c>
  80082f:	3a 02                	cmp    (%edx),%al
  800831:	74 ef                	je     800822 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 c0             	movzbl %al,%eax
  800836:	0f b6 12             	movzbl (%edx),%edx
  800839:	29 d0                	sub    %edx,%eax
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	53                   	push   %ebx
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
  800847:	89 c3                	mov    %eax,%ebx
  800849:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084c:	eb 06                	jmp    800854 <strncmp+0x17>
		n--, p++, q++;
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800854:	39 d8                	cmp    %ebx,%eax
  800856:	74 15                	je     80086d <strncmp+0x30>
  800858:	0f b6 08             	movzbl (%eax),%ecx
  80085b:	84 c9                	test   %cl,%cl
  80085d:	74 04                	je     800863 <strncmp+0x26>
  80085f:	3a 0a                	cmp    (%edx),%cl
  800861:	74 eb                	je     80084e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 00             	movzbl (%eax),%eax
  800866:	0f b6 12             	movzbl (%edx),%edx
  800869:	29 d0                	sub    %edx,%eax
  80086b:	eb 05                	jmp    800872 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087f:	eb 07                	jmp    800888 <strchr+0x13>
		if (*s == c)
  800881:	38 ca                	cmp    %cl,%dl
  800883:	74 0f                	je     800894 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800885:	83 c0 01             	add    $0x1,%eax
  800888:	0f b6 10             	movzbl (%eax),%edx
  80088b:	84 d2                	test   %dl,%dl
  80088d:	75 f2                	jne    800881 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a0:	eb 03                	jmp    8008a5 <strfind+0xf>
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 04                	je     8008b0 <strfind+0x1a>
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	75 f2                	jne    8008a2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	57                   	push   %edi
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008be:	85 c9                	test   %ecx,%ecx
  8008c0:	74 36                	je     8008f8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c8:	75 28                	jne    8008f2 <memset+0x40>
  8008ca:	f6 c1 03             	test   $0x3,%cl
  8008cd:	75 23                	jne    8008f2 <memset+0x40>
		c &= 0xFF;
  8008cf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d3:	89 d3                	mov    %edx,%ebx
  8008d5:	c1 e3 08             	shl    $0x8,%ebx
  8008d8:	89 d6                	mov    %edx,%esi
  8008da:	c1 e6 18             	shl    $0x18,%esi
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	c1 e0 10             	shl    $0x10,%eax
  8008e2:	09 f0                	or     %esi,%eax
  8008e4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e6:	89 d8                	mov    %ebx,%eax
  8008e8:	09 d0                	or     %edx,%eax
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
  8008ed:	fc                   	cld    
  8008ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f0:	eb 06                	jmp    8008f8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f5:	fc                   	cld    
  8008f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090d:	39 c6                	cmp    %eax,%esi
  80090f:	73 35                	jae    800946 <memmove+0x47>
  800911:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800914:	39 d0                	cmp    %edx,%eax
  800916:	73 2e                	jae    800946 <memmove+0x47>
		s += n;
		d += n;
  800918:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091b:	89 d6                	mov    %edx,%esi
  80091d:	09 fe                	or     %edi,%esi
  80091f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800925:	75 13                	jne    80093a <memmove+0x3b>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0e                	jne    80093a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80092c:	83 ef 04             	sub    $0x4,%edi
  80092f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	fd                   	std    
  800936:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800938:	eb 09                	jmp    800943 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093a:	83 ef 01             	sub    $0x1,%edi
  80093d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800940:	fd                   	std    
  800941:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800943:	fc                   	cld    
  800944:	eb 1d                	jmp    800963 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	89 f2                	mov    %esi,%edx
  800948:	09 c2                	or     %eax,%edx
  80094a:	f6 c2 03             	test   $0x3,%dl
  80094d:	75 0f                	jne    80095e <memmove+0x5f>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 0a                	jne    80095e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800954:	c1 e9 02             	shr    $0x2,%ecx
  800957:	89 c7                	mov    %eax,%edi
  800959:	fc                   	cld    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 05                	jmp    800963 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095e:	89 c7                	mov    %eax,%edi
  800960:	fc                   	cld    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800963:	5e                   	pop    %esi
  800964:	5f                   	pop    %edi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096a:	ff 75 10             	pushl  0x10(%ebp)
  80096d:	ff 75 0c             	pushl  0xc(%ebp)
  800970:	ff 75 08             	pushl  0x8(%ebp)
  800973:	e8 87 ff ff ff       	call   8008ff <memmove>
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 c6                	mov    %eax,%esi
  800987:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098a:	eb 1a                	jmp    8009a6 <memcmp+0x2c>
		if (*s1 != *s2)
  80098c:	0f b6 08             	movzbl (%eax),%ecx
  80098f:	0f b6 1a             	movzbl (%edx),%ebx
  800992:	38 d9                	cmp    %bl,%cl
  800994:	74 0a                	je     8009a0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800996:	0f b6 c1             	movzbl %cl,%eax
  800999:	0f b6 db             	movzbl %bl,%ebx
  80099c:	29 d8                	sub    %ebx,%eax
  80099e:	eb 0f                	jmp    8009af <memcmp+0x35>
		s1++, s2++;
  8009a0:	83 c0 01             	add    $0x1,%eax
  8009a3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a6:	39 f0                	cmp    %esi,%eax
  8009a8:	75 e2                	jne    80098c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	53                   	push   %ebx
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ba:	89 c1                	mov    %eax,%ecx
  8009bc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c3:	eb 0a                	jmp    8009cf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	39 da                	cmp    %ebx,%edx
  8009ca:	74 07                	je     8009d3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	39 c8                	cmp    %ecx,%eax
  8009d1:	72 f2                	jb     8009c5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e2:	eb 03                	jmp    8009e7 <strtol+0x11>
		s++;
  8009e4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e7:	0f b6 01             	movzbl (%ecx),%eax
  8009ea:	3c 20                	cmp    $0x20,%al
  8009ec:	74 f6                	je     8009e4 <strtol+0xe>
  8009ee:	3c 09                	cmp    $0x9,%al
  8009f0:	74 f2                	je     8009e4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f2:	3c 2b                	cmp    $0x2b,%al
  8009f4:	75 0a                	jne    800a00 <strtol+0x2a>
		s++;
  8009f6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fe:	eb 11                	jmp    800a11 <strtol+0x3b>
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a05:	3c 2d                	cmp    $0x2d,%al
  800a07:	75 08                	jne    800a11 <strtol+0x3b>
		s++, neg = 1;
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a11:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a17:	75 15                	jne    800a2e <strtol+0x58>
  800a19:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1c:	75 10                	jne    800a2e <strtol+0x58>
  800a1e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a22:	75 7c                	jne    800aa0 <strtol+0xca>
		s += 2, base = 16;
  800a24:	83 c1 02             	add    $0x2,%ecx
  800a27:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2c:	eb 16                	jmp    800a44 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a2e:	85 db                	test   %ebx,%ebx
  800a30:	75 12                	jne    800a44 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a32:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a37:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3a:	75 08                	jne    800a44 <strtol+0x6e>
		s++, base = 8;
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4c:	0f b6 11             	movzbl (%ecx),%edx
  800a4f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a52:	89 f3                	mov    %esi,%ebx
  800a54:	80 fb 09             	cmp    $0x9,%bl
  800a57:	77 08                	ja     800a61 <strtol+0x8b>
			dig = *s - '0';
  800a59:	0f be d2             	movsbl %dl,%edx
  800a5c:	83 ea 30             	sub    $0x30,%edx
  800a5f:	eb 22                	jmp    800a83 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a61:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a64:	89 f3                	mov    %esi,%ebx
  800a66:	80 fb 19             	cmp    $0x19,%bl
  800a69:	77 08                	ja     800a73 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a6b:	0f be d2             	movsbl %dl,%edx
  800a6e:	83 ea 57             	sub    $0x57,%edx
  800a71:	eb 10                	jmp    800a83 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a73:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 19             	cmp    $0x19,%bl
  800a7b:	77 16                	ja     800a93 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a83:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a86:	7d 0b                	jge    800a93 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a91:	eb b9                	jmp    800a4c <strtol+0x76>

	if (endptr)
  800a93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a97:	74 0d                	je     800aa6 <strtol+0xd0>
		*endptr = (char *) s;
  800a99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9c:	89 0e                	mov    %ecx,(%esi)
  800a9e:	eb 06                	jmp    800aa6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	74 98                	je     800a3c <strtol+0x66>
  800aa4:	eb 9e                	jmp    800a44 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	f7 da                	neg    %edx
  800aaa:	85 ff                	test   %edi,%edi
  800aac:	0f 45 c2             	cmovne %edx,%eax
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	89 c3                	mov    %eax,%ebx
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	89 c6                	mov    %eax,%esi
  800acb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  800add:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae2:	89 d1                	mov    %edx,%ecx
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	89 d7                	mov    %edx,%edi
  800ae8:	89 d6                	mov    %edx,%esi
  800aea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aff:	b8 03 00 00 00       	mov    $0x3,%eax
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	89 cb                	mov    %ecx,%ebx
  800b09:	89 cf                	mov    %ecx,%edi
  800b0b:	89 ce                	mov    %ecx,%esi
  800b0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	7e 17                	jle    800b2a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b13:	83 ec 0c             	sub    $0xc,%esp
  800b16:	50                   	push   %eax
  800b17:	6a 03                	push   $0x3
  800b19:	68 5f 21 80 00       	push   $0x80215f
  800b1e:	6a 23                	push   $0x23
  800b20:	68 7c 21 80 00       	push   $0x80217c
  800b25:	e8 f5 0e 00 00       	call   801a1f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_yield>:

void
sys_yield(void)
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
  800b5c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b61:	89 d1                	mov    %edx,%ecx
  800b63:	89 d3                	mov    %edx,%ebx
  800b65:	89 d7                	mov    %edx,%edi
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	be 00 00 00 00       	mov    $0x0,%esi
  800b7e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8c:	89 f7                	mov    %esi,%edi
  800b8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b90:	85 c0                	test   %eax,%eax
  800b92:	7e 17                	jle    800bab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	50                   	push   %eax
  800b98:	6a 04                	push   $0x4
  800b9a:	68 5f 21 80 00       	push   $0x80215f
  800b9f:	6a 23                	push   $0x23
  800ba1:	68 7c 21 80 00       	push   $0x80217c
  800ba6:	e8 74 0e 00 00       	call   801a1f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcd:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	7e 17                	jle    800bed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd6:	83 ec 0c             	sub    $0xc,%esp
  800bd9:	50                   	push   %eax
  800bda:	6a 05                	push   $0x5
  800bdc:	68 5f 21 80 00       	push   $0x80215f
  800be1:	6a 23                	push   $0x23
  800be3:	68 7c 21 80 00       	push   $0x80217c
  800be8:	e8 32 0e 00 00       	call   801a1f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c03:	b8 06 00 00 00       	mov    $0x6,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	89 df                	mov    %ebx,%edi
  800c10:	89 de                	mov    %ebx,%esi
  800c12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 17                	jle    800c2f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 06                	push   $0x6
  800c1e:	68 5f 21 80 00       	push   $0x80215f
  800c23:	6a 23                	push   $0x23
  800c25:	68 7c 21 80 00       	push   $0x80217c
  800c2a:	e8 f0 0d 00 00       	call   801a1f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c45:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	89 df                	mov    %ebx,%edi
  800c52:	89 de                	mov    %ebx,%esi
  800c54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 17                	jle    800c71 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 08                	push   $0x8
  800c60:	68 5f 21 80 00       	push   $0x80215f
  800c65:	6a 23                	push   $0x23
  800c67:	68 7c 21 80 00       	push   $0x80217c
  800c6c:	e8 ae 0d 00 00       	call   801a1f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c87:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	89 df                	mov    %ebx,%edi
  800c94:	89 de                	mov    %ebx,%esi
  800c96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 09                	push   $0x9
  800ca2:	68 5f 21 80 00       	push   $0x80215f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 7c 21 80 00       	push   $0x80217c
  800cae:	e8 6c 0d 00 00       	call   801a1f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 17                	jle    800cf5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 0a                	push   $0xa
  800ce4:	68 5f 21 80 00       	push   $0x80215f
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 7c 21 80 00       	push   $0x80217c
  800cf0:	e8 2a 0d 00 00       	call   801a1f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	be 00 00 00 00       	mov    $0x0,%esi
  800d08:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d19:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 cb                	mov    %ecx,%ebx
  800d38:	89 cf                	mov    %ecx,%edi
  800d3a:	89 ce                	mov    %ecx,%esi
  800d3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7e 17                	jle    800d59 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 0d                	push   $0xd
  800d48:	68 5f 21 80 00       	push   $0x80215f
  800d4d:	6a 23                	push   $0x23
  800d4f:	68 7c 21 80 00       	push   $0x80217c
  800d54:	e8 c6 0c 00 00       	call   801a1f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	05 00 00 00 30       	add    $0x30000000,%eax
  800d6c:	c1 e8 0c             	shr    $0xc,%eax
}
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d81:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	c1 ea 16             	shr    $0x16,%edx
  800d98:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d9f:	f6 c2 01             	test   $0x1,%dl
  800da2:	74 11                	je     800db5 <fd_alloc+0x2d>
  800da4:	89 c2                	mov    %eax,%edx
  800da6:	c1 ea 0c             	shr    $0xc,%edx
  800da9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db0:	f6 c2 01             	test   $0x1,%dl
  800db3:	75 09                	jne    800dbe <fd_alloc+0x36>
			*fd_store = fd;
  800db5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800db7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbc:	eb 17                	jmp    800dd5 <fd_alloc+0x4d>
  800dbe:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dc3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc8:	75 c9                	jne    800d93 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dca:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dd0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ddd:	83 f8 1f             	cmp    $0x1f,%eax
  800de0:	77 36                	ja     800e18 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800de2:	c1 e0 0c             	shl    $0xc,%eax
  800de5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	c1 ea 16             	shr    $0x16,%edx
  800def:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df6:	f6 c2 01             	test   $0x1,%dl
  800df9:	74 24                	je     800e1f <fd_lookup+0x48>
  800dfb:	89 c2                	mov    %eax,%edx
  800dfd:	c1 ea 0c             	shr    $0xc,%edx
  800e00:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e07:	f6 c2 01             	test   $0x1,%dl
  800e0a:	74 1a                	je     800e26 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0f:	89 02                	mov    %eax,(%edx)
	return 0;
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
  800e16:	eb 13                	jmp    800e2b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1d:	eb 0c                	jmp    800e2b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e24:	eb 05                	jmp    800e2b <fd_lookup+0x54>
  800e26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	83 ec 08             	sub    $0x8,%esp
  800e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e36:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e3b:	eb 13                	jmp    800e50 <dev_lookup+0x23>
  800e3d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e40:	39 08                	cmp    %ecx,(%eax)
  800e42:	75 0c                	jne    800e50 <dev_lookup+0x23>
			*dev = devtab[i];
  800e44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e47:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e49:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4e:	eb 2e                	jmp    800e7e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e50:	8b 02                	mov    (%edx),%eax
  800e52:	85 c0                	test   %eax,%eax
  800e54:	75 e7                	jne    800e3d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e56:	a1 04 40 80 00       	mov    0x804004,%eax
  800e5b:	8b 40 48             	mov    0x48(%eax),%eax
  800e5e:	83 ec 04             	sub    $0x4,%esp
  800e61:	51                   	push   %ecx
  800e62:	50                   	push   %eax
  800e63:	68 8c 21 80 00       	push   $0x80218c
  800e68:	e8 d4 f2 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	83 ec 10             	sub    $0x10,%esp
  800e88:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e98:	c1 e8 0c             	shr    $0xc,%eax
  800e9b:	50                   	push   %eax
  800e9c:	e8 36 ff ff ff       	call   800dd7 <fd_lookup>
  800ea1:	83 c4 08             	add    $0x8,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 05                	js     800ead <fd_close+0x2d>
	    || fd != fd2)
  800ea8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eab:	74 0c                	je     800eb9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ead:	84 db                	test   %bl,%bl
  800eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb4:	0f 44 c2             	cmove  %edx,%eax
  800eb7:	eb 41                	jmp    800efa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ebf:	50                   	push   %eax
  800ec0:	ff 36                	pushl  (%esi)
  800ec2:	e8 66 ff ff ff       	call   800e2d <dev_lookup>
  800ec7:	89 c3                	mov    %eax,%ebx
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	78 1a                	js     800eea <fd_close+0x6a>
		if (dev->dev_close)
  800ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800edb:	85 c0                	test   %eax,%eax
  800edd:	74 0b                	je     800eea <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	56                   	push   %esi
  800ee3:	ff d0                	call   *%eax
  800ee5:	89 c3                	mov    %eax,%ebx
  800ee7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eea:	83 ec 08             	sub    $0x8,%esp
  800eed:	56                   	push   %esi
  800eee:	6a 00                	push   $0x0
  800ef0:	e8 00 fd ff ff       	call   800bf5 <sys_page_unmap>
	return r;
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	89 d8                	mov    %ebx,%eax
}
  800efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 75 08             	pushl  0x8(%ebp)
  800f0e:	e8 c4 fe ff ff       	call   800dd7 <fd_lookup>
  800f13:	83 c4 08             	add    $0x8,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 10                	js     800f2a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f1a:	83 ec 08             	sub    $0x8,%esp
  800f1d:	6a 01                	push   $0x1
  800f1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f22:	e8 59 ff ff ff       	call   800e80 <fd_close>
  800f27:	83 c4 10             	add    $0x10,%esp
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <close_all>:

void
close_all(void)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f33:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	53                   	push   %ebx
  800f3c:	e8 c0 ff ff ff       	call   800f01 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f41:	83 c3 01             	add    $0x1,%ebx
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	83 fb 20             	cmp    $0x20,%ebx
  800f4a:	75 ec                	jne    800f38 <close_all+0xc>
		close(i);
}
  800f4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	83 ec 2c             	sub    $0x2c,%esp
  800f5a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	ff 75 08             	pushl  0x8(%ebp)
  800f64:	e8 6e fe ff ff       	call   800dd7 <fd_lookup>
  800f69:	83 c4 08             	add    $0x8,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	0f 88 c1 00 00 00    	js     801035 <dup+0xe4>
		return r;
	close(newfdnum);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	56                   	push   %esi
  800f78:	e8 84 ff ff ff       	call   800f01 <close>

	newfd = INDEX2FD(newfdnum);
  800f7d:	89 f3                	mov    %esi,%ebx
  800f7f:	c1 e3 0c             	shl    $0xc,%ebx
  800f82:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f88:	83 c4 04             	add    $0x4,%esp
  800f8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8e:	e8 de fd ff ff       	call   800d71 <fd2data>
  800f93:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f95:	89 1c 24             	mov    %ebx,(%esp)
  800f98:	e8 d4 fd ff ff       	call   800d71 <fd2data>
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fa3:	89 f8                	mov    %edi,%eax
  800fa5:	c1 e8 16             	shr    $0x16,%eax
  800fa8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800faf:	a8 01                	test   $0x1,%al
  800fb1:	74 37                	je     800fea <dup+0x99>
  800fb3:	89 f8                	mov    %edi,%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
  800fb8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbf:	f6 c2 01             	test   $0x1,%dl
  800fc2:	74 26                	je     800fea <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd3:	50                   	push   %eax
  800fd4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd7:	6a 00                	push   $0x0
  800fd9:	57                   	push   %edi
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 d2 fb ff ff       	call   800bb3 <sys_page_map>
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	83 c4 20             	add    $0x20,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 2e                	js     801018 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fed:	89 d0                	mov    %edx,%eax
  800fef:	c1 e8 0c             	shr    $0xc,%eax
  800ff2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	25 07 0e 00 00       	and    $0xe07,%eax
  801001:	50                   	push   %eax
  801002:	53                   	push   %ebx
  801003:	6a 00                	push   $0x0
  801005:	52                   	push   %edx
  801006:	6a 00                	push   $0x0
  801008:	e8 a6 fb ff ff       	call   800bb3 <sys_page_map>
  80100d:	89 c7                	mov    %eax,%edi
  80100f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801012:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801014:	85 ff                	test   %edi,%edi
  801016:	79 1d                	jns    801035 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801018:	83 ec 08             	sub    $0x8,%esp
  80101b:	53                   	push   %ebx
  80101c:	6a 00                	push   $0x0
  80101e:	e8 d2 fb ff ff       	call   800bf5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801023:	83 c4 08             	add    $0x8,%esp
  801026:	ff 75 d4             	pushl  -0x2c(%ebp)
  801029:	6a 00                	push   $0x0
  80102b:	e8 c5 fb ff ff       	call   800bf5 <sys_page_unmap>
	return r;
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	89 f8                	mov    %edi,%eax
}
  801035:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	53                   	push   %ebx
  801041:	83 ec 14             	sub    $0x14,%esp
  801044:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801047:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104a:	50                   	push   %eax
  80104b:	53                   	push   %ebx
  80104c:	e8 86 fd ff ff       	call   800dd7 <fd_lookup>
  801051:	83 c4 08             	add    $0x8,%esp
  801054:	89 c2                	mov    %eax,%edx
  801056:	85 c0                	test   %eax,%eax
  801058:	78 6d                	js     8010c7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801064:	ff 30                	pushl  (%eax)
  801066:	e8 c2 fd ff ff       	call   800e2d <dev_lookup>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 4c                	js     8010be <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801072:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801075:	8b 42 08             	mov    0x8(%edx),%eax
  801078:	83 e0 03             	and    $0x3,%eax
  80107b:	83 f8 01             	cmp    $0x1,%eax
  80107e:	75 21                	jne    8010a1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801080:	a1 04 40 80 00       	mov    0x804004,%eax
  801085:	8b 40 48             	mov    0x48(%eax),%eax
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	53                   	push   %ebx
  80108c:	50                   	push   %eax
  80108d:	68 cd 21 80 00       	push   $0x8021cd
  801092:	e8 aa f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80109f:	eb 26                	jmp    8010c7 <read+0x8a>
	}
	if (!dev->dev_read)
  8010a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a4:	8b 40 08             	mov    0x8(%eax),%eax
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	74 17                	je     8010c2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	ff 75 10             	pushl  0x10(%ebp)
  8010b1:	ff 75 0c             	pushl  0xc(%ebp)
  8010b4:	52                   	push   %edx
  8010b5:	ff d0                	call   *%eax
  8010b7:	89 c2                	mov    %eax,%edx
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	eb 09                	jmp    8010c7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	eb 05                	jmp    8010c7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010c7:	89 d0                	mov    %edx,%eax
  8010c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    

008010ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e2:	eb 21                	jmp    801105 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	29 d8                	sub    %ebx,%eax
  8010eb:	50                   	push   %eax
  8010ec:	89 d8                	mov    %ebx,%eax
  8010ee:	03 45 0c             	add    0xc(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	57                   	push   %edi
  8010f3:	e8 45 ff ff ff       	call   80103d <read>
		if (m < 0)
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 10                	js     80110f <readn+0x41>
			return m;
		if (m == 0)
  8010ff:	85 c0                	test   %eax,%eax
  801101:	74 0a                	je     80110d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801103:	01 c3                	add    %eax,%ebx
  801105:	39 f3                	cmp    %esi,%ebx
  801107:	72 db                	jb     8010e4 <readn+0x16>
  801109:	89 d8                	mov    %ebx,%eax
  80110b:	eb 02                	jmp    80110f <readn+0x41>
  80110d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	53                   	push   %ebx
  80111b:	83 ec 14             	sub    $0x14,%esp
  80111e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801121:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	53                   	push   %ebx
  801126:	e8 ac fc ff ff       	call   800dd7 <fd_lookup>
  80112b:	83 c4 08             	add    $0x8,%esp
  80112e:	89 c2                	mov    %eax,%edx
  801130:	85 c0                	test   %eax,%eax
  801132:	78 68                	js     80119c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801134:	83 ec 08             	sub    $0x8,%esp
  801137:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113e:	ff 30                	pushl  (%eax)
  801140:	e8 e8 fc ff ff       	call   800e2d <dev_lookup>
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 47                	js     801193 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80114c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801153:	75 21                	jne    801176 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801155:	a1 04 40 80 00       	mov    0x804004,%eax
  80115a:	8b 40 48             	mov    0x48(%eax),%eax
  80115d:	83 ec 04             	sub    $0x4,%esp
  801160:	53                   	push   %ebx
  801161:	50                   	push   %eax
  801162:	68 e9 21 80 00       	push   $0x8021e9
  801167:	e8 d5 ef ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801174:	eb 26                	jmp    80119c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801176:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801179:	8b 52 0c             	mov    0xc(%edx),%edx
  80117c:	85 d2                	test   %edx,%edx
  80117e:	74 17                	je     801197 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	ff 75 10             	pushl  0x10(%ebp)
  801186:	ff 75 0c             	pushl  0xc(%ebp)
  801189:	50                   	push   %eax
  80118a:	ff d2                	call   *%edx
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	eb 09                	jmp    80119c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801193:	89 c2                	mov    %eax,%edx
  801195:	eb 05                	jmp    80119c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801197:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80119c:	89 d0                	mov    %edx,%eax
  80119e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011a9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	ff 75 08             	pushl  0x8(%ebp)
  8011b0:	e8 22 fc ff ff       	call   800dd7 <fd_lookup>
  8011b5:	83 c4 08             	add    $0x8,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 0e                	js     8011ca <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 14             	sub    $0x14,%esp
  8011d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	53                   	push   %ebx
  8011db:	e8 f7 fb ff ff       	call   800dd7 <fd_lookup>
  8011e0:	83 c4 08             	add    $0x8,%esp
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 65                	js     80124e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e9:	83 ec 08             	sub    $0x8,%esp
  8011ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f3:	ff 30                	pushl  (%eax)
  8011f5:	e8 33 fc ff ff       	call   800e2d <dev_lookup>
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 44                	js     801245 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801201:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801204:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801208:	75 21                	jne    80122b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80120a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80120f:	8b 40 48             	mov    0x48(%eax),%eax
  801212:	83 ec 04             	sub    $0x4,%esp
  801215:	53                   	push   %ebx
  801216:	50                   	push   %eax
  801217:	68 ac 21 80 00       	push   $0x8021ac
  80121c:	e8 20 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801229:	eb 23                	jmp    80124e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80122b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122e:	8b 52 18             	mov    0x18(%edx),%edx
  801231:	85 d2                	test   %edx,%edx
  801233:	74 14                	je     801249 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	ff 75 0c             	pushl  0xc(%ebp)
  80123b:	50                   	push   %eax
  80123c:	ff d2                	call   *%edx
  80123e:	89 c2                	mov    %eax,%edx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	eb 09                	jmp    80124e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801245:	89 c2                	mov    %eax,%edx
  801247:	eb 05                	jmp    80124e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801249:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80124e:	89 d0                	mov    %edx,%eax
  801250:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 14             	sub    $0x14,%esp
  80125c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	ff 75 08             	pushl  0x8(%ebp)
  801266:	e8 6c fb ff ff       	call   800dd7 <fd_lookup>
  80126b:	83 c4 08             	add    $0x8,%esp
  80126e:	89 c2                	mov    %eax,%edx
  801270:	85 c0                	test   %eax,%eax
  801272:	78 58                	js     8012cc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801274:	83 ec 08             	sub    $0x8,%esp
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127e:	ff 30                	pushl  (%eax)
  801280:	e8 a8 fb ff ff       	call   800e2d <dev_lookup>
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 37                	js     8012c3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801293:	74 32                	je     8012c7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801295:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801298:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80129f:	00 00 00 
	stat->st_isdir = 0;
  8012a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a9:	00 00 00 
	stat->st_dev = dev;
  8012ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b9:	ff 50 14             	call   *0x14(%eax)
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	eb 09                	jmp    8012cc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	eb 05                	jmp    8012cc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012cc:	89 d0                	mov    %edx,%eax
  8012ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    

008012d3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	6a 00                	push   $0x0
  8012dd:	ff 75 08             	pushl  0x8(%ebp)
  8012e0:	e8 b7 01 00 00       	call   80149c <open>
  8012e5:	89 c3                	mov    %eax,%ebx
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 1b                	js     801309 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	ff 75 0c             	pushl  0xc(%ebp)
  8012f4:	50                   	push   %eax
  8012f5:	e8 5b ff ff ff       	call   801255 <fstat>
  8012fa:	89 c6                	mov    %eax,%esi
	close(fd);
  8012fc:	89 1c 24             	mov    %ebx,(%esp)
  8012ff:	e8 fd fb ff ff       	call   800f01 <close>
	return r;
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	89 f0                	mov    %esi,%eax
}
  801309:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	56                   	push   %esi
  801314:	53                   	push   %ebx
  801315:	89 c6                	mov    %eax,%esi
  801317:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801319:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801320:	75 12                	jne    801334 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	6a 01                	push   $0x1
  801327:	e8 02 08 00 00       	call   801b2e <ipc_find_env>
  80132c:	a3 00 40 80 00       	mov    %eax,0x804000
  801331:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801334:	6a 07                	push   $0x7
  801336:	68 00 50 80 00       	push   $0x805000
  80133b:	56                   	push   %esi
  80133c:	ff 35 00 40 80 00    	pushl  0x804000
  801342:	e8 93 07 00 00       	call   801ada <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801347:	83 c4 0c             	add    $0xc,%esp
  80134a:	6a 00                	push   $0x0
  80134c:	53                   	push   %ebx
  80134d:	6a 00                	push   $0x0
  80134f:	e8 11 07 00 00       	call   801a65 <ipc_recv>
}
  801354:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    

0080135b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801361:	8b 45 08             	mov    0x8(%ebp),%eax
  801364:	8b 40 0c             	mov    0xc(%eax),%eax
  801367:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80136c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801374:	ba 00 00 00 00       	mov    $0x0,%edx
  801379:	b8 02 00 00 00       	mov    $0x2,%eax
  80137e:	e8 8d ff ff ff       	call   801310 <fsipc>
}
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
  80138e:	8b 40 0c             	mov    0xc(%eax),%eax
  801391:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801396:	ba 00 00 00 00       	mov    $0x0,%edx
  80139b:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a0:	e8 6b ff ff ff       	call   801310 <fsipc>
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 04             	sub    $0x4,%esp
  8013ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c6:	e8 45 ff ff ff       	call   801310 <fsipc>
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 2c                	js     8013fb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	68 00 50 80 00       	push   $0x805000
  8013d7:	53                   	push   %ebx
  8013d8:	e8 90 f3 ff ff       	call   80076d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8013e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8013ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801406:	68 18 22 80 00       	push   $0x802218
  80140b:	68 90 00 00 00       	push   $0x90
  801410:	68 36 22 80 00       	push   $0x802236
  801415:	e8 05 06 00 00       	call   801a1f <_panic>

0080141a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
  80141f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	8b 40 0c             	mov    0xc(%eax),%eax
  801428:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80142d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801433:	ba 00 00 00 00       	mov    $0x0,%edx
  801438:	b8 03 00 00 00       	mov    $0x3,%eax
  80143d:	e8 ce fe ff ff       	call   801310 <fsipc>
  801442:	89 c3                	mov    %eax,%ebx
  801444:	85 c0                	test   %eax,%eax
  801446:	78 4b                	js     801493 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801448:	39 c6                	cmp    %eax,%esi
  80144a:	73 16                	jae    801462 <devfile_read+0x48>
  80144c:	68 41 22 80 00       	push   $0x802241
  801451:	68 48 22 80 00       	push   $0x802248
  801456:	6a 7c                	push   $0x7c
  801458:	68 36 22 80 00       	push   $0x802236
  80145d:	e8 bd 05 00 00       	call   801a1f <_panic>
	assert(r <= PGSIZE);
  801462:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801467:	7e 16                	jle    80147f <devfile_read+0x65>
  801469:	68 5d 22 80 00       	push   $0x80225d
  80146e:	68 48 22 80 00       	push   $0x802248
  801473:	6a 7d                	push   $0x7d
  801475:	68 36 22 80 00       	push   $0x802236
  80147a:	e8 a0 05 00 00       	call   801a1f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	50                   	push   %eax
  801483:	68 00 50 80 00       	push   $0x805000
  801488:	ff 75 0c             	pushl  0xc(%ebp)
  80148b:	e8 6f f4 ff ff       	call   8008ff <memmove>
	return r;
  801490:	83 c4 10             	add    $0x10,%esp
}
  801493:	89 d8                	mov    %ebx,%eax
  801495:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801498:	5b                   	pop    %ebx
  801499:	5e                   	pop    %esi
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 20             	sub    $0x20,%esp
  8014a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014a6:	53                   	push   %ebx
  8014a7:	e8 88 f2 ff ff       	call   800734 <strlen>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b4:	7f 67                	jg     80151d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	e8 c6 f8 ff ff       	call   800d88 <fd_alloc>
  8014c2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 57                	js     801522 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	53                   	push   %ebx
  8014cf:	68 00 50 80 00       	push   $0x805000
  8014d4:	e8 94 f2 ff ff       	call   80076d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014dc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e9:	e8 22 fe ff ff       	call   801310 <fsipc>
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	79 14                	jns    80150b <open+0x6f>
		fd_close(fd, 0);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	6a 00                	push   $0x0
  8014fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ff:	e8 7c f9 ff ff       	call   800e80 <fd_close>
		return r;
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	89 da                	mov    %ebx,%edx
  801509:	eb 17                	jmp    801522 <open+0x86>
	}

	return fd2num(fd);
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	ff 75 f4             	pushl  -0xc(%ebp)
  801511:	e8 4b f8 ff ff       	call   800d61 <fd2num>
  801516:	89 c2                	mov    %eax,%edx
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	eb 05                	jmp    801522 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80151d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801522:	89 d0                	mov    %edx,%eax
  801524:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801527:	c9                   	leave  
  801528:	c3                   	ret    

00801529 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80152f:	ba 00 00 00 00       	mov    $0x0,%edx
  801534:	b8 08 00 00 00       	mov    $0x8,%eax
  801539:	e8 d2 fd ff ff       	call   801310 <fsipc>
}
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 1e f8 ff ff       	call   800d71 <fd2data>
  801553:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801555:	83 c4 08             	add    $0x8,%esp
  801558:	68 69 22 80 00       	push   $0x802269
  80155d:	53                   	push   %ebx
  80155e:	e8 0a f2 ff ff       	call   80076d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801563:	8b 46 04             	mov    0x4(%esi),%eax
  801566:	2b 06                	sub    (%esi),%eax
  801568:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80156e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801575:	00 00 00 
	stat->st_dev = &devpipe;
  801578:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80157f:	30 80 00 
	return 0;
}
  801582:	b8 00 00 00 00       	mov    $0x0,%eax
  801587:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801598:	53                   	push   %ebx
  801599:	6a 00                	push   $0x0
  80159b:	e8 55 f6 ff ff       	call   800bf5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015a0:	89 1c 24             	mov    %ebx,(%esp)
  8015a3:	e8 c9 f7 ff ff       	call   800d71 <fd2data>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	50                   	push   %eax
  8015ac:	6a 00                	push   $0x0
  8015ae:	e8 42 f6 ff ff       	call   800bf5 <sys_page_unmap>
}
  8015b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	57                   	push   %edi
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 1c             	sub    $0x1c,%esp
  8015c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015ce:	83 ec 0c             	sub    $0xc,%esp
  8015d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d4:	e8 8e 05 00 00       	call   801b67 <pageref>
  8015d9:	89 c3                	mov    %eax,%ebx
  8015db:	89 3c 24             	mov    %edi,(%esp)
  8015de:	e8 84 05 00 00       	call   801b67 <pageref>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	39 c3                	cmp    %eax,%ebx
  8015e8:	0f 94 c1             	sete   %cl
  8015eb:	0f b6 c9             	movzbl %cl,%ecx
  8015ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015f1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015f7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015fa:	39 ce                	cmp    %ecx,%esi
  8015fc:	74 1b                	je     801619 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015fe:	39 c3                	cmp    %eax,%ebx
  801600:	75 c4                	jne    8015c6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801602:	8b 42 58             	mov    0x58(%edx),%eax
  801605:	ff 75 e4             	pushl  -0x1c(%ebp)
  801608:	50                   	push   %eax
  801609:	56                   	push   %esi
  80160a:	68 70 22 80 00       	push   $0x802270
  80160f:	e8 2d eb ff ff       	call   800141 <cprintf>
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb ad                	jmp    8015c6 <_pipeisclosed+0xe>
	}
}
  801619:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80161c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5f                   	pop    %edi
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    

00801624 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	57                   	push   %edi
  801628:	56                   	push   %esi
  801629:	53                   	push   %ebx
  80162a:	83 ec 28             	sub    $0x28,%esp
  80162d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801630:	56                   	push   %esi
  801631:	e8 3b f7 ff ff       	call   800d71 <fd2data>
  801636:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	bf 00 00 00 00       	mov    $0x0,%edi
  801640:	eb 4b                	jmp    80168d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801642:	89 da                	mov    %ebx,%edx
  801644:	89 f0                	mov    %esi,%eax
  801646:	e8 6d ff ff ff       	call   8015b8 <_pipeisclosed>
  80164b:	85 c0                	test   %eax,%eax
  80164d:	75 48                	jne    801697 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80164f:	e8 fd f4 ff ff       	call   800b51 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801654:	8b 43 04             	mov    0x4(%ebx),%eax
  801657:	8b 0b                	mov    (%ebx),%ecx
  801659:	8d 51 20             	lea    0x20(%ecx),%edx
  80165c:	39 d0                	cmp    %edx,%eax
  80165e:	73 e2                	jae    801642 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801660:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801663:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801667:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80166a:	89 c2                	mov    %eax,%edx
  80166c:	c1 fa 1f             	sar    $0x1f,%edx
  80166f:	89 d1                	mov    %edx,%ecx
  801671:	c1 e9 1b             	shr    $0x1b,%ecx
  801674:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801677:	83 e2 1f             	and    $0x1f,%edx
  80167a:	29 ca                	sub    %ecx,%edx
  80167c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801680:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801684:	83 c0 01             	add    $0x1,%eax
  801687:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80168a:	83 c7 01             	add    $0x1,%edi
  80168d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801690:	75 c2                	jne    801654 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801692:	8b 45 10             	mov    0x10(%ebp),%eax
  801695:	eb 05                	jmp    80169c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801697:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80169c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169f:	5b                   	pop    %ebx
  8016a0:	5e                   	pop    %esi
  8016a1:	5f                   	pop    %edi
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	57                   	push   %edi
  8016a8:	56                   	push   %esi
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 18             	sub    $0x18,%esp
  8016ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016b0:	57                   	push   %edi
  8016b1:	e8 bb f6 ff ff       	call   800d71 <fd2data>
  8016b6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c0:	eb 3d                	jmp    8016ff <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016c2:	85 db                	test   %ebx,%ebx
  8016c4:	74 04                	je     8016ca <devpipe_read+0x26>
				return i;
  8016c6:	89 d8                	mov    %ebx,%eax
  8016c8:	eb 44                	jmp    80170e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016ca:	89 f2                	mov    %esi,%edx
  8016cc:	89 f8                	mov    %edi,%eax
  8016ce:	e8 e5 fe ff ff       	call   8015b8 <_pipeisclosed>
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	75 32                	jne    801709 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016d7:	e8 75 f4 ff ff       	call   800b51 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016dc:	8b 06                	mov    (%esi),%eax
  8016de:	3b 46 04             	cmp    0x4(%esi),%eax
  8016e1:	74 df                	je     8016c2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016e3:	99                   	cltd   
  8016e4:	c1 ea 1b             	shr    $0x1b,%edx
  8016e7:	01 d0                	add    %edx,%eax
  8016e9:	83 e0 1f             	and    $0x1f,%eax
  8016ec:	29 d0                	sub    %edx,%eax
  8016ee:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016f9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fc:	83 c3 01             	add    $0x1,%ebx
  8016ff:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801702:	75 d8                	jne    8016dc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801704:	8b 45 10             	mov    0x10(%ebp),%eax
  801707:	eb 05                	jmp    80170e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801709:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80170e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5f                   	pop    %edi
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
  80171b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80171e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	e8 61 f6 ff ff       	call   800d88 <fd_alloc>
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	85 c0                	test   %eax,%eax
  80172e:	0f 88 2c 01 00 00    	js     801860 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	68 07 04 00 00       	push   $0x407
  80173c:	ff 75 f4             	pushl  -0xc(%ebp)
  80173f:	6a 00                	push   $0x0
  801741:	e8 2a f4 ff ff       	call   800b70 <sys_page_alloc>
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	89 c2                	mov    %eax,%edx
  80174b:	85 c0                	test   %eax,%eax
  80174d:	0f 88 0d 01 00 00    	js     801860 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	e8 29 f6 ff ff       	call   800d88 <fd_alloc>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	0f 88 e2 00 00 00    	js     80184e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	68 07 04 00 00       	push   $0x407
  801774:	ff 75 f0             	pushl  -0x10(%ebp)
  801777:	6a 00                	push   $0x0
  801779:	e8 f2 f3 ff ff       	call   800b70 <sys_page_alloc>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	0f 88 c3 00 00 00    	js     80184e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80178b:	83 ec 0c             	sub    $0xc,%esp
  80178e:	ff 75 f4             	pushl  -0xc(%ebp)
  801791:	e8 db f5 ff ff       	call   800d71 <fd2data>
  801796:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801798:	83 c4 0c             	add    $0xc,%esp
  80179b:	68 07 04 00 00       	push   $0x407
  8017a0:	50                   	push   %eax
  8017a1:	6a 00                	push   $0x0
  8017a3:	e8 c8 f3 ff ff       	call   800b70 <sys_page_alloc>
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	0f 88 89 00 00 00    	js     80183e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b5:	83 ec 0c             	sub    $0xc,%esp
  8017b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bb:	e8 b1 f5 ff ff       	call   800d71 <fd2data>
  8017c0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017c7:	50                   	push   %eax
  8017c8:	6a 00                	push   $0x0
  8017ca:	56                   	push   %esi
  8017cb:	6a 00                	push   $0x0
  8017cd:	e8 e1 f3 ff ff       	call   800bb3 <sys_page_map>
  8017d2:	89 c3                	mov    %eax,%ebx
  8017d4:	83 c4 20             	add    $0x20,%esp
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 55                	js     801830 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017db:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017f0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801805:	83 ec 0c             	sub    $0xc,%esp
  801808:	ff 75 f4             	pushl  -0xc(%ebp)
  80180b:	e8 51 f5 ff ff       	call   800d61 <fd2num>
  801810:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801813:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801815:	83 c4 04             	add    $0x4,%esp
  801818:	ff 75 f0             	pushl  -0x10(%ebp)
  80181b:	e8 41 f5 ff ff       	call   800d61 <fd2num>
  801820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801823:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	eb 30                	jmp    801860 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	56                   	push   %esi
  801834:	6a 00                	push   $0x0
  801836:	e8 ba f3 ff ff       	call   800bf5 <sys_page_unmap>
  80183b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80183e:	83 ec 08             	sub    $0x8,%esp
  801841:	ff 75 f0             	pushl  -0x10(%ebp)
  801844:	6a 00                	push   $0x0
  801846:	e8 aa f3 ff ff       	call   800bf5 <sys_page_unmap>
  80184b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	ff 75 f4             	pushl  -0xc(%ebp)
  801854:	6a 00                	push   $0x0
  801856:	e8 9a f3 ff ff       	call   800bf5 <sys_page_unmap>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801860:	89 d0                	mov    %edx,%eax
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801872:	50                   	push   %eax
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	e8 5c f5 ff ff       	call   800dd7 <fd_lookup>
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 18                	js     80189a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	ff 75 f4             	pushl  -0xc(%ebp)
  801888:	e8 e4 f4 ff ff       	call   800d71 <fd2data>
	return _pipeisclosed(fd, p);
  80188d:	89 c2                	mov    %eax,%edx
  80188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801892:	e8 21 fd ff ff       	call   8015b8 <_pipeisclosed>
  801897:	83 c4 10             	add    $0x10,%esp
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018ac:	68 88 22 80 00       	push   $0x802288
  8018b1:	ff 75 0c             	pushl  0xc(%ebp)
  8018b4:	e8 b4 ee ff ff       	call   80076d <strcpy>
	return 0;
}
  8018b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018cc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d7:	eb 2d                	jmp    801906 <devcons_write+0x46>
		m = n - tot;
  8018d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018dc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018de:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018e1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018e6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e9:	83 ec 04             	sub    $0x4,%esp
  8018ec:	53                   	push   %ebx
  8018ed:	03 45 0c             	add    0xc(%ebp),%eax
  8018f0:	50                   	push   %eax
  8018f1:	57                   	push   %edi
  8018f2:	e8 08 f0 ff ff       	call   8008ff <memmove>
		sys_cputs(buf, m);
  8018f7:	83 c4 08             	add    $0x8,%esp
  8018fa:	53                   	push   %ebx
  8018fb:	57                   	push   %edi
  8018fc:	e8 b3 f1 ff ff       	call   800ab4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801901:	01 de                	add    %ebx,%esi
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	89 f0                	mov    %esi,%eax
  801908:	3b 75 10             	cmp    0x10(%ebp),%esi
  80190b:	72 cc                	jb     8018d9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80190d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801910:	5b                   	pop    %ebx
  801911:	5e                   	pop    %esi
  801912:	5f                   	pop    %edi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801920:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801924:	74 2a                	je     801950 <devcons_read+0x3b>
  801926:	eb 05                	jmp    80192d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801928:	e8 24 f2 ff ff       	call   800b51 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80192d:	e8 a0 f1 ff ff       	call   800ad2 <sys_cgetc>
  801932:	85 c0                	test   %eax,%eax
  801934:	74 f2                	je     801928 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801936:	85 c0                	test   %eax,%eax
  801938:	78 16                	js     801950 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80193a:	83 f8 04             	cmp    $0x4,%eax
  80193d:	74 0c                	je     80194b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80193f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801942:	88 02                	mov    %al,(%edx)
	return 1;
  801944:	b8 01 00 00 00       	mov    $0x1,%eax
  801949:	eb 05                	jmp    801950 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
  80195b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80195e:	6a 01                	push   $0x1
  801960:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801963:	50                   	push   %eax
  801964:	e8 4b f1 ff ff       	call   800ab4 <sys_cputs>
}
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <getchar>:

int
getchar(void)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801974:	6a 01                	push   $0x1
  801976:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801979:	50                   	push   %eax
  80197a:	6a 00                	push   $0x0
  80197c:	e8 bc f6 ff ff       	call   80103d <read>
	if (r < 0)
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 0f                	js     801997 <getchar+0x29>
		return r;
	if (r < 1)
  801988:	85 c0                	test   %eax,%eax
  80198a:	7e 06                	jle    801992 <getchar+0x24>
		return -E_EOF;
	return c;
  80198c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801990:	eb 05                	jmp    801997 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801992:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80199f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a2:	50                   	push   %eax
  8019a3:	ff 75 08             	pushl  0x8(%ebp)
  8019a6:	e8 2c f4 ff ff       	call   800dd7 <fd_lookup>
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 11                	js     8019c3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019bb:	39 10                	cmp    %edx,(%eax)
  8019bd:	0f 94 c0             	sete   %al
  8019c0:	0f b6 c0             	movzbl %al,%eax
}
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <opencons>:

int
opencons(void)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ce:	50                   	push   %eax
  8019cf:	e8 b4 f3 ff ff       	call   800d88 <fd_alloc>
  8019d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 3e                	js     801a1b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019dd:	83 ec 04             	sub    $0x4,%esp
  8019e0:	68 07 04 00 00       	push   $0x407
  8019e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e8:	6a 00                	push   $0x0
  8019ea:	e8 81 f1 ff ff       	call   800b70 <sys_page_alloc>
  8019ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 23                	js     801a1b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019f8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a01:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	50                   	push   %eax
  801a11:	e8 4b f3 ff ff       	call   800d61 <fd2num>
  801a16:	89 c2                	mov    %eax,%edx
  801a18:	83 c4 10             	add    $0x10,%esp
}
  801a1b:	89 d0                	mov    %edx,%eax
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	56                   	push   %esi
  801a23:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a24:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a27:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a2d:	e8 00 f1 ff ff       	call   800b32 <sys_getenvid>
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	ff 75 0c             	pushl  0xc(%ebp)
  801a38:	ff 75 08             	pushl  0x8(%ebp)
  801a3b:	56                   	push   %esi
  801a3c:	50                   	push   %eax
  801a3d:	68 94 22 80 00       	push   $0x802294
  801a42:	e8 fa e6 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a47:	83 c4 18             	add    $0x18,%esp
  801a4a:	53                   	push   %ebx
  801a4b:	ff 75 10             	pushl  0x10(%ebp)
  801a4e:	e8 9d e6 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801a53:	c7 04 24 5c 1e 80 00 	movl   $0x801e5c,(%esp)
  801a5a:	e8 e2 e6 ff ff       	call   800141 <cprintf>
  801a5f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a62:	cc                   	int3   
  801a63:	eb fd                	jmp    801a62 <_panic+0x43>

00801a65 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a73:	85 c0                	test   %eax,%eax
  801a75:	74 0e                	je     801a85 <ipc_recv+0x20>
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	50                   	push   %eax
  801a7b:	e8 a0 f2 ff ff       	call   800d20 <sys_ipc_recv>
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	eb 10                	jmp    801a95 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	68 00 00 c0 ee       	push   $0xeec00000
  801a8d:	e8 8e f2 ff ff       	call   800d20 <sys_ipc_recv>
  801a92:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801a95:	85 c0                	test   %eax,%eax
  801a97:	74 16                	je     801aaf <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801a99:	85 f6                	test   %esi,%esi
  801a9b:	74 06                	je     801aa3 <ipc_recv+0x3e>
  801a9d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801aa3:	85 db                	test   %ebx,%ebx
  801aa5:	74 2c                	je     801ad3 <ipc_recv+0x6e>
  801aa7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aad:	eb 24                	jmp    801ad3 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801aaf:	85 f6                	test   %esi,%esi
  801ab1:	74 0a                	je     801abd <ipc_recv+0x58>
  801ab3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab8:	8b 40 74             	mov    0x74(%eax),%eax
  801abb:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801abd:	85 db                	test   %ebx,%ebx
  801abf:	74 0a                	je     801acb <ipc_recv+0x66>
  801ac1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac6:	8b 40 78             	mov    0x78(%eax),%eax
  801ac9:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801acb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ad3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	57                   	push   %edi
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aec:	85 c0                	test   %eax,%eax
  801aee:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801af3:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801af6:	ff 75 14             	pushl  0x14(%ebp)
  801af9:	53                   	push   %ebx
  801afa:	56                   	push   %esi
  801afb:	57                   	push   %edi
  801afc:	e8 fc f1 ff ff       	call   800cfd <sys_ipc_try_send>
		if (ret == 0) break;
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	74 1e                	je     801b26 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0b:	74 12                	je     801b1f <ipc_send+0x45>
  801b0d:	50                   	push   %eax
  801b0e:	68 b8 22 80 00       	push   $0x8022b8
  801b13:	6a 39                	push   $0x39
  801b15:	68 c5 22 80 00       	push   $0x8022c5
  801b1a:	e8 00 ff ff ff       	call   801a1f <_panic>
		sys_yield();
  801b1f:	e8 2d f0 ff ff       	call   800b51 <sys_yield>
	}
  801b24:	eb d0                	jmp    801af6 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b39:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b3c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b42:	8b 52 50             	mov    0x50(%edx),%edx
  801b45:	39 ca                	cmp    %ecx,%edx
  801b47:	75 0d                	jne    801b56 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
  801b54:	eb 0f                	jmp    801b65 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b56:	83 c0 01             	add    $0x1,%eax
  801b59:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b5e:	75 d9                	jne    801b39 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6d:	89 d0                	mov    %edx,%eax
  801b6f:	c1 e8 16             	shr    $0x16,%eax
  801b72:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7e:	f6 c1 01             	test   $0x1,%cl
  801b81:	74 1d                	je     801ba0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b83:	c1 ea 0c             	shr    $0xc,%edx
  801b86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b8d:	f6 c2 01             	test   $0x1,%dl
  801b90:	74 0e                	je     801ba0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b92:	c1 ea 0c             	shr    $0xc,%edx
  801b95:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b9c:	ef 
  801b9d:	0f b7 c0             	movzwl %ax,%eax
}
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    
  801ba2:	66 90                	xchg   %ax,%ax
  801ba4:	66 90                	xchg   %ax,%ax
  801ba6:	66 90                	xchg   %ax,%ax
  801ba8:	66 90                	xchg   %ax,%ax
  801baa:	66 90                	xchg   %ax,%ax
  801bac:	66 90                	xchg   %ax,%ax
  801bae:	66 90                	xchg   %ax,%ax

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bc7:	85 f6                	test   %esi,%esi
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 ca                	mov    %ecx,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	75 3d                	jne    801c10 <__udivdi3+0x60>
  801bd3:	39 cf                	cmp    %ecx,%edi
  801bd5:	0f 87 c5 00 00 00    	ja     801ca0 <__udivdi3+0xf0>
  801bdb:	85 ff                	test   %edi,%edi
  801bdd:	89 fd                	mov    %edi,%ebp
  801bdf:	75 0b                	jne    801bec <__udivdi3+0x3c>
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	31 d2                	xor    %edx,%edx
  801be8:	f7 f7                	div    %edi
  801bea:	89 c5                	mov    %eax,%ebp
  801bec:	89 c8                	mov    %ecx,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f5                	div    %ebp
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	89 cf                	mov    %ecx,%edi
  801bf8:	f7 f5                	div    %ebp
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 ce                	cmp    %ecx,%esi
  801c12:	77 74                	ja     801c88 <__udivdi3+0xd8>
  801c14:	0f bd fe             	bsr    %esi,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0x108>
  801c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 c5                	mov    %eax,%ebp
  801c29:	29 fb                	sub    %edi,%ebx
  801c2b:	d3 e6                	shl    %cl,%esi
  801c2d:	89 d9                	mov    %ebx,%ecx
  801c2f:	d3 ed                	shr    %cl,%ebp
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e0                	shl    %cl,%eax
  801c35:	09 ee                	or     %ebp,%esi
  801c37:	89 d9                	mov    %ebx,%ecx
  801c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c3d:	89 d5                	mov    %edx,%ebp
  801c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c43:	d3 ed                	shr    %cl,%ebp
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 d9                	mov    %ebx,%ecx
  801c4b:	d3 e8                	shr    %cl,%eax
  801c4d:	09 c2                	or     %eax,%edx
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	89 ea                	mov    %ebp,%edx
  801c53:	f7 f6                	div    %esi
  801c55:	89 d5                	mov    %edx,%ebp
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	f7 64 24 0c          	mull   0xc(%esp)
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	72 10                	jb     801c71 <__udivdi3+0xc1>
  801c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e6                	shl    %cl,%esi
  801c69:	39 c6                	cmp    %eax,%esi
  801c6b:	73 07                	jae    801c74 <__udivdi3+0xc4>
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	75 03                	jne    801c74 <__udivdi3+0xc4>
  801c71:	83 eb 01             	sub    $0x1,%ebx
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	31 ff                	xor    %edi,%edi
  801c8a:	31 db                	xor    %ebx,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	f7 f7                	div    %edi
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	89 fa                	mov    %edi,%edx
  801cac:	83 c4 1c             	add    $0x1c,%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 ce                	cmp    %ecx,%esi
  801cba:	72 0c                	jb     801cc8 <__udivdi3+0x118>
  801cbc:	31 db                	xor    %ebx,%ebx
  801cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cc2:	0f 87 34 ff ff ff    	ja     801bfc <__udivdi3+0x4c>
  801cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ccd:	e9 2a ff ff ff       	jmp    801bfc <__udivdi3+0x4c>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f3                	mov    %esi,%ebx
  801d03:	89 3c 24             	mov    %edi,(%esp)
  801d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0a:	75 1c                	jne    801d28 <__umoddi3+0x48>
  801d0c:	39 f7                	cmp    %esi,%edi
  801d0e:	76 50                	jbe    801d60 <__umoddi3+0x80>
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	f7 f7                	div    %edi
  801d16:	89 d0                	mov    %edx,%eax
  801d18:	31 d2                	xor    %edx,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	77 52                	ja     801d80 <__umoddi3+0xa0>
  801d2e:	0f bd ea             	bsr    %edx,%ebp
  801d31:	83 f5 1f             	xor    $0x1f,%ebp
  801d34:	75 5a                	jne    801d90 <__umoddi3+0xb0>
  801d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d3a:	0f 82 e0 00 00 00    	jb     801e20 <__umoddi3+0x140>
  801d40:	39 0c 24             	cmp    %ecx,(%esp)
  801d43:	0f 86 d7 00 00 00    	jbe    801e20 <__umoddi3+0x140>
  801d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d51:	83 c4 1c             	add    $0x1c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	85 ff                	test   %edi,%edi
  801d62:	89 fd                	mov    %edi,%ebp
  801d64:	75 0b                	jne    801d71 <__umoddi3+0x91>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f7                	div    %edi
  801d6f:	89 c5                	mov    %eax,%ebp
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f5                	div    %ebp
  801d77:	89 c8                	mov    %ecx,%eax
  801d79:	f7 f5                	div    %ebp
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	eb 99                	jmp    801d18 <__umoddi3+0x38>
  801d7f:	90                   	nop
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	8b 34 24             	mov    (%esp),%esi
  801d93:	bf 20 00 00 00       	mov    $0x20,%edi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	29 ef                	sub    %ebp,%edi
  801d9c:	d3 e0                	shl    %cl,%eax
  801d9e:	89 f9                	mov    %edi,%ecx
  801da0:	89 f2                	mov    %esi,%edx
  801da2:	d3 ea                	shr    %cl,%edx
  801da4:	89 e9                	mov    %ebp,%ecx
  801da6:	09 c2                	or     %eax,%edx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	d3 e3                	shl    %cl,%ebx
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	09 d8                	or     %ebx,%eax
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 34 24             	divl   (%esp)
  801dd4:	89 d6                	mov    %edx,%esi
  801dd6:	d3 e3                	shl    %cl,%ebx
  801dd8:	f7 64 24 04          	mull   0x4(%esp)
  801ddc:	39 d6                	cmp    %edx,%esi
  801dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	72 08                	jb     801df0 <__umoddi3+0x110>
  801de8:	75 11                	jne    801dfb <__umoddi3+0x11b>
  801dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dee:	73 0b                	jae    801dfb <__umoddi3+0x11b>
  801df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801df4:	1b 14 24             	sbb    (%esp),%edx
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dff:	29 da                	sub    %ebx,%edx
  801e01:	19 ce                	sbb    %ecx,%esi
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	d3 e0                	shl    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 ea                	shr    %cl,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 ee                	shr    %cl,%esi
  801e11:	09 d0                	or     %edx,%eax
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	29 f9                	sub    %edi,%ecx
  801e22:	19 d6                	sbb    %edx,%esi
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	e9 18 ff ff ff       	jmp    801d49 <__umoddi3+0x69>
