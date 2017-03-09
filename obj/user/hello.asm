
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 60 1e 80 00       	push   $0x801e60
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 1e 80 00       	push   $0x801e6e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800069:	e8 d4 0a 00 00       	call   800b42 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 8d 0e 00 00       	call   800f3c <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 48 0a 00 00       	call   800b01 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 d6 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 1a 01 00 00       	call   80024e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 7b 09 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 07 1a 00 00       	call   801bc0 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 f4 1a 00 00       	call   801cf0 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 8f 1e 80 00 	movsbl 0x801e8f(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	3b 50 04             	cmp    0x4(%eax),%edx
  800223:	73 0a                	jae    80022f <sprintputch+0x1b>
		*b->buf++ = ch;
  800225:	8d 4a 01             	lea    0x1(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	88 02                	mov    %al,(%edx)
}
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800237:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 10             	pushl  0x10(%ebp)
  80023e:	ff 75 0c             	pushl  0xc(%ebp)
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	e8 05 00 00 00       	call   80024e <vprintfmt>
	va_end(ap);
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 2c             	sub    $0x2c,%esp
  800257:	8b 75 08             	mov    0x8(%ebp),%esi
  80025a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800260:	eb 12                	jmp    800274 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800262:	85 c0                	test   %eax,%eax
  800264:	0f 84 6a 04 00 00    	je     8006d4 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	53                   	push   %ebx
  80026e:	50                   	push   %eax
  80026f:	ff d6                	call   *%esi
  800271:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800274:	83 c7 01             	add    $0x1,%edi
  800277:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80027b:	83 f8 25             	cmp    $0x25,%eax
  80027e:	75 e2                	jne    800262 <vprintfmt+0x14>
  800280:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800284:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80028b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800292:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800299:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029e:	eb 07                	jmp    8002a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	8d 47 01             	lea    0x1(%edi),%eax
  8002aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ad:	0f b6 07             	movzbl (%edi),%eax
  8002b0:	0f b6 d0             	movzbl %al,%edx
  8002b3:	83 e8 23             	sub    $0x23,%eax
  8002b6:	3c 55                	cmp    $0x55,%al
  8002b8:	0f 87 fb 03 00 00    	ja     8006b9 <vprintfmt+0x46b>
  8002be:	0f b6 c0             	movzbl %al,%eax
  8002c1:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8002c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002cf:	eb d6                	jmp    8002a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e9:	83 f9 09             	cmp    $0x9,%ecx
  8002ec:	77 3f                	ja     80032d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002f1:	eb e9                	jmp    8002dc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8b 00                	mov    (%eax),%eax
  8002f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 40 04             	lea    0x4(%eax),%eax
  800301:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800307:	eb 2a                	jmp    800333 <vprintfmt+0xe5>
  800309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030c:	85 c0                	test   %eax,%eax
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
  800313:	0f 49 d0             	cmovns %eax,%edx
  800316:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031c:	eb 89                	jmp    8002a7 <vprintfmt+0x59>
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800321:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800328:	e9 7a ff ff ff       	jmp    8002a7 <vprintfmt+0x59>
  80032d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800330:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800333:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800337:	0f 89 6a ff ff ff    	jns    8002a7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80033d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034a:	e9 58 ff ff ff       	jmp    8002a7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80034f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800355:	e9 4d ff ff ff       	jmp    8002a7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 78 04             	lea    0x4(%eax),%edi
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	53                   	push   %ebx
  800364:	ff 30                	pushl  (%eax)
  800366:	ff d6                	call   *%esi
			break;
  800368:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80036b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800371:	e9 fe fe ff ff       	jmp    800274 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 78 04             	lea    0x4(%eax),%edi
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	99                   	cltd   
  80037f:	31 d0                	xor    %edx,%eax
  800381:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800383:	83 f8 0f             	cmp    $0xf,%eax
  800386:	7f 0b                	jg     800393 <vprintfmt+0x145>
  800388:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80038f:	85 d2                	test   %edx,%edx
  800391:	75 1b                	jne    8003ae <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800393:	50                   	push   %eax
  800394:	68 a7 1e 80 00       	push   $0x801ea7
  800399:	53                   	push   %ebx
  80039a:	56                   	push   %esi
  80039b:	e8 91 fe ff ff       	call   800231 <printfmt>
  8003a0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003a9:	e9 c6 fe ff ff       	jmp    800274 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ae:	52                   	push   %edx
  8003af:	68 9a 22 80 00       	push   $0x80229a
  8003b4:	53                   	push   %ebx
  8003b5:	56                   	push   %esi
  8003b6:	e8 76 fe ff ff       	call   800231 <printfmt>
  8003bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c4:	e9 ab fe ff ff       	jmp    800274 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	83 c0 04             	add    $0x4,%eax
  8003cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d7:	85 ff                	test   %edi,%edi
  8003d9:	b8 a0 1e 80 00       	mov    $0x801ea0,%eax
  8003de:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e5:	0f 8e 94 00 00 00    	jle    80047f <vprintfmt+0x231>
  8003eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ef:	0f 84 98 00 00 00    	je     80048d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fb:	57                   	push   %edi
  8003fc:	e8 5b 03 00 00       	call   80075c <strnlen>
  800401:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800404:	29 c1                	sub    %eax,%ecx
  800406:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800409:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80040c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800410:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800413:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800416:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800418:	eb 0f                	jmp    800429 <vprintfmt+0x1db>
					putch(padc, putdat);
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 75 e0             	pushl  -0x20(%ebp)
  800421:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800423:	83 ef 01             	sub    $0x1,%edi
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	85 ff                	test   %edi,%edi
  80042b:	7f ed                	jg     80041a <vprintfmt+0x1cc>
  80042d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800430:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800433:	85 c9                	test   %ecx,%ecx
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	0f 49 c1             	cmovns %ecx,%eax
  80043d:	29 c1                	sub    %eax,%ecx
  80043f:	89 75 08             	mov    %esi,0x8(%ebp)
  800442:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800445:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800448:	89 cb                	mov    %ecx,%ebx
  80044a:	eb 4d                	jmp    800499 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80044c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800450:	74 1b                	je     80046d <vprintfmt+0x21f>
  800452:	0f be c0             	movsbl %al,%eax
  800455:	83 e8 20             	sub    $0x20,%eax
  800458:	83 f8 5e             	cmp    $0x5e,%eax
  80045b:	76 10                	jbe    80046d <vprintfmt+0x21f>
					putch('?', putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 0c             	pushl  0xc(%ebp)
  800463:	6a 3f                	push   $0x3f
  800465:	ff 55 08             	call   *0x8(%ebp)
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	eb 0d                	jmp    80047a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	ff 75 0c             	pushl  0xc(%ebp)
  800473:	52                   	push   %edx
  800474:	ff 55 08             	call   *0x8(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047a:	83 eb 01             	sub    $0x1,%ebx
  80047d:	eb 1a                	jmp    800499 <vprintfmt+0x24b>
  80047f:	89 75 08             	mov    %esi,0x8(%ebp)
  800482:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800488:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048b:	eb 0c                	jmp    800499 <vprintfmt+0x24b>
  80048d:	89 75 08             	mov    %esi,0x8(%ebp)
  800490:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800493:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800496:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800499:	83 c7 01             	add    $0x1,%edi
  80049c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a0:	0f be d0             	movsbl %al,%edx
  8004a3:	85 d2                	test   %edx,%edx
  8004a5:	74 23                	je     8004ca <vprintfmt+0x27c>
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	78 a1                	js     80044c <vprintfmt+0x1fe>
  8004ab:	83 ee 01             	sub    $0x1,%esi
  8004ae:	79 9c                	jns    80044c <vprintfmt+0x1fe>
  8004b0:	89 df                	mov    %ebx,%edi
  8004b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b8:	eb 18                	jmp    8004d2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	6a 20                	push   $0x20
  8004c0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c2:	83 ef 01             	sub    $0x1,%edi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb 08                	jmp    8004d2 <vprintfmt+0x284>
  8004ca:	89 df                	mov    %ebx,%edi
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f e4                	jg     8004ba <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 90 fd ff ff       	jmp    800274 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e4:	83 f9 01             	cmp    $0x1,%ecx
  8004e7:	7e 19                	jle    800502 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8b 50 04             	mov    0x4(%eax),%edx
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 40 08             	lea    0x8(%eax),%eax
  8004fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800500:	eb 38                	jmp    80053a <vprintfmt+0x2ec>
	else if (lflag)
  800502:	85 c9                	test   %ecx,%ecx
  800504:	74 1b                	je     800521 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050e:	89 c1                	mov    %eax,%ecx
  800510:	c1 f9 1f             	sar    $0x1f,%ecx
  800513:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 40 04             	lea    0x4(%eax),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
  80051f:	eb 19                	jmp    80053a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 04             	lea    0x4(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800540:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800545:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800549:	0f 89 36 01 00 00    	jns    800685 <vprintfmt+0x437>
				putch('-', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 2d                	push   $0x2d
  800555:	ff d6                	call   *%esi
				num = -(long long) num;
  800557:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055d:	f7 da                	neg    %edx
  80055f:	83 d1 00             	adc    $0x0,%ecx
  800562:	f7 d9                	neg    %ecx
  800564:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056c:	e9 14 01 00 00       	jmp    800685 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800571:	83 f9 01             	cmp    $0x1,%ecx
  800574:	7e 18                	jle    80058e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 10                	mov    (%eax),%edx
  80057b:	8b 48 04             	mov    0x4(%eax),%ecx
  80057e:	8d 40 08             	lea    0x8(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800584:	b8 0a 00 00 00       	mov    $0xa,%eax
  800589:	e9 f7 00 00 00       	jmp    800685 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	74 1a                	je     8005ac <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a7:	e9 d9 00 00 00       	jmp    800685 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c1:	e9 bf 00 00 00       	jmp    800685 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c6:	83 f9 01             	cmp    $0x1,%ecx
  8005c9:	7e 13                	jle    8005de <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 50 04             	mov    0x4(%eax),%edx
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005d6:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005dc:	eb 28                	jmp    800606 <vprintfmt+0x3b8>
	else if (lflag)
  8005de:	85 c9                	test   %ecx,%ecx
  8005e0:	74 13                	je     8005f5 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	99                   	cltd   
  8005ea:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ed:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f3:	eb 11                	jmp    800606 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	89 d0                	mov    %edx,%eax
  8005fc:	99                   	cltd   
  8005fd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800600:	8d 49 04             	lea    0x4(%ecx),%ecx
  800603:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800606:	89 d1                	mov    %edx,%ecx
  800608:	89 c2                	mov    %eax,%edx
			base = 8;
  80060a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80060f:	eb 74                	jmp    800685 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 30                	push   $0x30
  800617:	ff d6                	call   *%esi
			putch('x', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 78                	push   $0x78
  80061f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800634:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800639:	eb 4a                	jmp    800685 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063b:	83 f9 01             	cmp    $0x1,%ecx
  80063e:	7e 15                	jle    800655 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	8b 48 04             	mov    0x4(%eax),%ecx
  800648:	8d 40 08             	lea    0x8(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80064e:	b8 10 00 00 00       	mov    $0x10,%eax
  800653:	eb 30                	jmp    800685 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800655:	85 c9                	test   %ecx,%ecx
  800657:	74 17                	je     800670 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800669:	b8 10 00 00 00       	mov    $0x10,%eax
  80066e:	eb 15                	jmp    800685 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800680:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800685:	83 ec 0c             	sub    $0xc,%esp
  800688:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068c:	57                   	push   %edi
  80068d:	ff 75 e0             	pushl  -0x20(%ebp)
  800690:	50                   	push   %eax
  800691:	51                   	push   %ecx
  800692:	52                   	push   %edx
  800693:	89 da                	mov    %ebx,%edx
  800695:	89 f0                	mov    %esi,%eax
  800697:	e8 c9 fa ff ff       	call   800165 <printnum>
			break;
  80069c:	83 c4 20             	add    $0x20,%esp
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 cd fb ff ff       	jmp    800274 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	52                   	push   %edx
  8006ac:	ff d6                	call   *%esi
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b4:	e9 bb fb ff ff       	jmp    800274 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 25                	push   $0x25
  8006bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 03                	jmp    8006c9 <vprintfmt+0x47b>
  8006c6:	83 ef 01             	sub    $0x1,%edi
  8006c9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cd:	75 f7                	jne    8006c6 <vprintfmt+0x478>
  8006cf:	e9 a0 fb ff ff       	jmp    800274 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 18             	sub    $0x18,%esp
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006eb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 26                	je     800723 <vsnprintf+0x47>
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	7e 22                	jle    800723 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800701:	ff 75 14             	pushl  0x14(%ebp)
  800704:	ff 75 10             	pushl  0x10(%ebp)
  800707:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	68 14 02 80 00       	push   $0x800214
  800710:	e8 39 fb ff ff       	call   80024e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800715:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800718:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 05                	jmp    800728 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800733:	50                   	push   %eax
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	ff 75 08             	pushl  0x8(%ebp)
  80073d:	e8 9a ff ff ff       	call   8006dc <vsnprintf>
	va_end(ap);

	return rc;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	eb 03                	jmp    800754 <strlen+0x10>
		n++;
  800751:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800754:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800758:	75 f7                	jne    800751 <strlen+0xd>
		n++;
	return n;
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
  80076a:	eb 03                	jmp    80076f <strnlen+0x13>
		n++;
  80076c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	39 c2                	cmp    %eax,%edx
  800771:	74 08                	je     80077b <strnlen+0x1f>
  800773:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800777:	75 f3                	jne    80076c <strnlen+0x10>
  800779:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	53                   	push   %ebx
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800787:	89 c2                	mov    %eax,%edx
  800789:	83 c2 01             	add    $0x1,%edx
  80078c:	83 c1 01             	add    $0x1,%ecx
  80078f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800793:	88 5a ff             	mov    %bl,-0x1(%edx)
  800796:	84 db                	test   %bl,%bl
  800798:	75 ef                	jne    800789 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079a:	5b                   	pop    %ebx
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a4:	53                   	push   %ebx
  8007a5:	e8 9a ff ff ff       	call   800744 <strlen>
  8007aa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	50                   	push   %eax
  8007b3:	e8 c5 ff ff ff       	call   80077d <strcpy>
	return dst;
}
  8007b8:	89 d8                	mov    %ebx,%eax
  8007ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ca:	89 f3                	mov    %esi,%ebx
  8007cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cf:	89 f2                	mov    %esi,%edx
  8007d1:	eb 0f                	jmp    8007e2 <strncpy+0x23>
		*dst++ = *src;
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	0f b6 01             	movzbl (%ecx),%eax
  8007d9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007df:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e2:	39 da                	cmp    %ebx,%edx
  8007e4:	75 ed                	jne    8007d3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	85 d2                	test   %edx,%edx
  8007fe:	74 21                	je     800821 <strlcpy+0x35>
  800800:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800804:	89 f2                	mov    %esi,%edx
  800806:	eb 09                	jmp    800811 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800811:	39 c2                	cmp    %eax,%edx
  800813:	74 09                	je     80081e <strlcpy+0x32>
  800815:	0f b6 19             	movzbl (%ecx),%ebx
  800818:	84 db                	test   %bl,%bl
  80081a:	75 ec                	jne    800808 <strlcpy+0x1c>
  80081c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800821:	29 f0                	sub    %esi,%eax
}
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800830:	eb 06                	jmp    800838 <strcmp+0x11>
		p++, q++;
  800832:	83 c1 01             	add    $0x1,%ecx
  800835:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800838:	0f b6 01             	movzbl (%ecx),%eax
  80083b:	84 c0                	test   %al,%al
  80083d:	74 04                	je     800843 <strcmp+0x1c>
  80083f:	3a 02                	cmp    (%edx),%al
  800841:	74 ef                	je     800832 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 c0             	movzbl %al,%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
  800857:	89 c3                	mov    %eax,%ebx
  800859:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085c:	eb 06                	jmp    800864 <strncmp+0x17>
		n--, p++, q++;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	74 15                	je     80087d <strncmp+0x30>
  800868:	0f b6 08             	movzbl (%eax),%ecx
  80086b:	84 c9                	test   %cl,%cl
  80086d:	74 04                	je     800873 <strncmp+0x26>
  80086f:	3a 0a                	cmp    (%edx),%cl
  800871:	74 eb                	je     80085e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 00             	movzbl (%eax),%eax
  800876:	0f b6 12             	movzbl (%edx),%edx
  800879:	29 d0                	sub    %edx,%eax
  80087b:	eb 05                	jmp    800882 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	eb 07                	jmp    800898 <strchr+0x13>
		if (*s == c)
  800891:	38 ca                	cmp    %cl,%dl
  800893:	74 0f                	je     8008a4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	0f b6 10             	movzbl (%eax),%edx
  80089b:	84 d2                	test   %dl,%dl
  80089d:	75 f2                	jne    800891 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b0:	eb 03                	jmp    8008b5 <strfind+0xf>
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 04                	je     8008c0 <strfind+0x1a>
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	75 f2                	jne    8008b2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ce:	85 c9                	test   %ecx,%ecx
  8008d0:	74 36                	je     800908 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d8:	75 28                	jne    800902 <memset+0x40>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 23                	jne    800902 <memset+0x40>
		c &= 0xFF;
  8008df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e3:	89 d3                	mov    %edx,%ebx
  8008e5:	c1 e3 08             	shl    $0x8,%ebx
  8008e8:	89 d6                	mov    %edx,%esi
  8008ea:	c1 e6 18             	shl    $0x18,%esi
  8008ed:	89 d0                	mov    %edx,%eax
  8008ef:	c1 e0 10             	shl    $0x10,%eax
  8008f2:	09 f0                	or     %esi,%eax
  8008f4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f6:	89 d8                	mov    %ebx,%eax
  8008f8:	09 d0                	or     %edx,%eax
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
  8008fd:	fc                   	cld    
  8008fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800900:	eb 06                	jmp    800908 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
  800905:	fc                   	cld    
  800906:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800908:	89 f8                	mov    %edi,%eax
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091d:	39 c6                	cmp    %eax,%esi
  80091f:	73 35                	jae    800956 <memmove+0x47>
  800921:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800924:	39 d0                	cmp    %edx,%eax
  800926:	73 2e                	jae    800956 <memmove+0x47>
		s += n;
		d += n;
  800928:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	09 fe                	or     %edi,%esi
  80092f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800935:	75 13                	jne    80094a <memmove+0x3b>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 0e                	jne    80094a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093c:	83 ef 04             	sub    $0x4,%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 09                	jmp    800953 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 1d                	jmp    800973 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 f2                	mov    %esi,%edx
  800958:	09 c2                	or     %eax,%edx
  80095a:	f6 c2 03             	test   $0x3,%dl
  80095d:	75 0f                	jne    80096e <memmove+0x5f>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 0a                	jne    80096e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800964:	c1 e9 02             	shr    $0x2,%ecx
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 05                	jmp    800973 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097a:	ff 75 10             	pushl  0x10(%ebp)
  80097d:	ff 75 0c             	pushl  0xc(%ebp)
  800980:	ff 75 08             	pushl  0x8(%ebp)
  800983:	e8 87 ff ff ff       	call   80090f <memmove>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 c6                	mov    %eax,%esi
  800997:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099a:	eb 1a                	jmp    8009b6 <memcmp+0x2c>
		if (*s1 != *s2)
  80099c:	0f b6 08             	movzbl (%eax),%ecx
  80099f:	0f b6 1a             	movzbl (%edx),%ebx
  8009a2:	38 d9                	cmp    %bl,%cl
  8009a4:	74 0a                	je     8009b0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a6:	0f b6 c1             	movzbl %cl,%eax
  8009a9:	0f b6 db             	movzbl %bl,%ebx
  8009ac:	29 d8                	sub    %ebx,%eax
  8009ae:	eb 0f                	jmp    8009bf <memcmp+0x35>
		s1++, s2++;
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	39 f0                	cmp    %esi,%eax
  8009b8:	75 e2                	jne    80099c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ca:	89 c1                	mov    %eax,%ecx
  8009cc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d3:	eb 0a                	jmp    8009df <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	39 da                	cmp    %ebx,%edx
  8009da:	74 07                	je     8009e3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	39 c8                	cmp    %ecx,%eax
  8009e1:	72 f2                	jb     8009d5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	eb 03                	jmp    8009f7 <strtol+0x11>
		s++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	0f b6 01             	movzbl (%ecx),%eax
  8009fa:	3c 20                	cmp    $0x20,%al
  8009fc:	74 f6                	je     8009f4 <strtol+0xe>
  8009fe:	3c 09                	cmp    $0x9,%al
  800a00:	74 f2                	je     8009f4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a02:	3c 2b                	cmp    $0x2b,%al
  800a04:	75 0a                	jne    800a10 <strtol+0x2a>
		s++;
  800a06:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0e:	eb 11                	jmp    800a21 <strtol+0x3b>
  800a10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a15:	3c 2d                	cmp    $0x2d,%al
  800a17:	75 08                	jne    800a21 <strtol+0x3b>
		s++, neg = 1;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a21:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a27:	75 15                	jne    800a3e <strtol+0x58>
  800a29:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2c:	75 10                	jne    800a3e <strtol+0x58>
  800a2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a32:	75 7c                	jne    800ab0 <strtol+0xca>
		s += 2, base = 16;
  800a34:	83 c1 02             	add    $0x2,%ecx
  800a37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3c:	eb 16                	jmp    800a54 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	75 12                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a47:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4a:	75 08                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5c:	0f b6 11             	movzbl (%ecx),%edx
  800a5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 09             	cmp    $0x9,%bl
  800a67:	77 08                	ja     800a71 <strtol+0x8b>
			dig = *s - '0';
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 30             	sub    $0x30,%edx
  800a6f:	eb 22                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a71:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 19             	cmp    $0x19,%bl
  800a79:	77 08                	ja     800a83 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7b:	0f be d2             	movsbl %dl,%edx
  800a7e:	83 ea 57             	sub    $0x57,%edx
  800a81:	eb 10                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a83:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 19             	cmp    $0x19,%bl
  800a8b:	77 16                	ja     800aa3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a96:	7d 0b                	jge    800aa3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa1:	eb b9                	jmp    800a5c <strtol+0x76>

	if (endptr)
  800aa3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa7:	74 0d                	je     800ab6 <strtol+0xd0>
		*endptr = (char *) s;
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aac:	89 0e                	mov    %ecx,(%esi)
  800aae:	eb 06                	jmp    800ab6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	74 98                	je     800a4c <strtol+0x66>
  800ab4:	eb 9e                	jmp    800a54 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	f7 da                	neg    %edx
  800aba:	85 ff                	test   %edi,%edi
  800abc:	0f 45 c2             	cmovne %edx,%eax
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7e 17                	jle    800b3a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 03                	push   $0x3
  800b29:	68 9f 21 80 00       	push   $0x80219f
  800b2e:	6a 23                	push   $0x23
  800b30:	68 bc 21 80 00       	push   $0x8021bc
  800b35:	e8 f5 0e 00 00       	call   801a2f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_yield>:

void
sys_yield(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	be 00 00 00 00       	mov    $0x0,%esi
  800b8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	89 f7                	mov    %esi,%edi
  800b9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 17                	jle    800bbb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 04                	push   $0x4
  800baa:	68 9f 21 80 00       	push   $0x80219f
  800baf:	6a 23                	push   $0x23
  800bb1:	68 bc 21 80 00       	push   $0x8021bc
  800bb6:	e8 74 0e 00 00       	call   801a2f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 75 18             	mov    0x18(%ebp),%esi
  800be0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 05                	push   $0x5
  800bec:	68 9f 21 80 00       	push   $0x80219f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 bc 21 80 00       	push   $0x8021bc
  800bf8:	e8 32 0e 00 00       	call   801a2f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c13:	b8 06 00 00 00       	mov    $0x6,%eax
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	89 df                	mov    %ebx,%edi
  800c20:	89 de                	mov    %ebx,%esi
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 06                	push   $0x6
  800c2e:	68 9f 21 80 00       	push   $0x80219f
  800c33:	6a 23                	push   $0x23
  800c35:	68 bc 21 80 00       	push   $0x8021bc
  800c3a:	e8 f0 0d 00 00       	call   801a2f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 08                	push   $0x8
  800c70:	68 9f 21 80 00       	push   $0x80219f
  800c75:	6a 23                	push   $0x23
  800c77:	68 bc 21 80 00       	push   $0x8021bc
  800c7c:	e8 ae 0d 00 00       	call   801a2f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 09                	push   $0x9
  800cb2:	68 9f 21 80 00       	push   $0x80219f
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 bc 21 80 00       	push   $0x8021bc
  800cbe:	e8 6c 0d 00 00       	call   801a2f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0a                	push   $0xa
  800cf4:	68 9f 21 80 00       	push   $0x80219f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 bc 21 80 00       	push   $0x8021bc
  800d00:	e8 2a 0d 00 00       	call   801a2f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	be 00 00 00 00       	mov    $0x0,%esi
  800d18:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 cb                	mov    %ecx,%ebx
  800d48:	89 cf                	mov    %ecx,%edi
  800d4a:	89 ce                	mov    %ecx,%esi
  800d4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	7e 17                	jle    800d69 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 0d                	push   $0xd
  800d58:	68 9f 21 80 00       	push   $0x80219f
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 bc 21 80 00       	push   $0x8021bc
  800d64:	e8 c6 0c 00 00       	call   801a2f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7c:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d91:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da3:	89 c2                	mov    %eax,%edx
  800da5:	c1 ea 16             	shr    $0x16,%edx
  800da8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800daf:	f6 c2 01             	test   $0x1,%dl
  800db2:	74 11                	je     800dc5 <fd_alloc+0x2d>
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	c1 ea 0c             	shr    $0xc,%edx
  800db9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc0:	f6 c2 01             	test   $0x1,%dl
  800dc3:	75 09                	jne    800dce <fd_alloc+0x36>
			*fd_store = fd;
  800dc5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcc:	eb 17                	jmp    800de5 <fd_alloc+0x4d>
  800dce:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd8:	75 c9                	jne    800da3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dda:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ded:	83 f8 1f             	cmp    $0x1f,%eax
  800df0:	77 36                	ja     800e28 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df2:	c1 e0 0c             	shl    $0xc,%eax
  800df5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dfa:	89 c2                	mov    %eax,%edx
  800dfc:	c1 ea 16             	shr    $0x16,%edx
  800dff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e06:	f6 c2 01             	test   $0x1,%dl
  800e09:	74 24                	je     800e2f <fd_lookup+0x48>
  800e0b:	89 c2                	mov    %eax,%edx
  800e0d:	c1 ea 0c             	shr    $0xc,%edx
  800e10:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e17:	f6 c2 01             	test   $0x1,%dl
  800e1a:	74 1a                	je     800e36 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1f:	89 02                	mov    %eax,(%edx)
	return 0;
  800e21:	b8 00 00 00 00       	mov    $0x0,%eax
  800e26:	eb 13                	jmp    800e3b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2d:	eb 0c                	jmp    800e3b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e34:	eb 05                	jmp    800e3b <fd_lookup+0x54>
  800e36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e46:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4b:	eb 13                	jmp    800e60 <dev_lookup+0x23>
  800e4d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e50:	39 08                	cmp    %ecx,(%eax)
  800e52:	75 0c                	jne    800e60 <dev_lookup+0x23>
			*dev = devtab[i];
  800e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e57:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5e:	eb 2e                	jmp    800e8e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e60:	8b 02                	mov    (%edx),%eax
  800e62:	85 c0                	test   %eax,%eax
  800e64:	75 e7                	jne    800e4d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e66:	a1 04 40 80 00       	mov    0x804004,%eax
  800e6b:	8b 40 48             	mov    0x48(%eax),%eax
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	51                   	push   %ecx
  800e72:	50                   	push   %eax
  800e73:	68 cc 21 80 00       	push   $0x8021cc
  800e78:	e8 d4 f2 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	83 ec 10             	sub    $0x10,%esp
  800e98:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea1:	50                   	push   %eax
  800ea2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea8:	c1 e8 0c             	shr    $0xc,%eax
  800eab:	50                   	push   %eax
  800eac:	e8 36 ff ff ff       	call   800de7 <fd_lookup>
  800eb1:	83 c4 08             	add    $0x8,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	78 05                	js     800ebd <fd_close+0x2d>
	    || fd != fd2)
  800eb8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ebb:	74 0c                	je     800ec9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ebd:	84 db                	test   %bl,%bl
  800ebf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec4:	0f 44 c2             	cmove  %edx,%eax
  800ec7:	eb 41                	jmp    800f0a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec9:	83 ec 08             	sub    $0x8,%esp
  800ecc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ecf:	50                   	push   %eax
  800ed0:	ff 36                	pushl  (%esi)
  800ed2:	e8 66 ff ff ff       	call   800e3d <dev_lookup>
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 1a                	js     800efa <fd_close+0x6a>
		if (dev->dev_close)
  800ee0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	74 0b                	je     800efa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	56                   	push   %esi
  800ef3:	ff d0                	call   *%eax
  800ef5:	89 c3                	mov    %eax,%ebx
  800ef7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800efa:	83 ec 08             	sub    $0x8,%esp
  800efd:	56                   	push   %esi
  800efe:	6a 00                	push   $0x0
  800f00:	e8 00 fd ff ff       	call   800c05 <sys_page_unmap>
	return r;
  800f05:	83 c4 10             	add    $0x10,%esp
  800f08:	89 d8                	mov    %ebx,%eax
}
  800f0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1a:	50                   	push   %eax
  800f1b:	ff 75 08             	pushl  0x8(%ebp)
  800f1e:	e8 c4 fe ff ff       	call   800de7 <fd_lookup>
  800f23:	83 c4 08             	add    $0x8,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	78 10                	js     800f3a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	6a 01                	push   $0x1
  800f2f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f32:	e8 59 ff ff ff       	call   800e90 <fd_close>
  800f37:	83 c4 10             	add    $0x10,%esp
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <close_all>:

void
close_all(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f43:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	53                   	push   %ebx
  800f4c:	e8 c0 ff ff ff       	call   800f11 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f51:	83 c3 01             	add    $0x1,%ebx
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	83 fb 20             	cmp    $0x20,%ebx
  800f5a:	75 ec                	jne    800f48 <close_all+0xc>
		close(i);
}
  800f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 2c             	sub    $0x2c,%esp
  800f6a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f70:	50                   	push   %eax
  800f71:	ff 75 08             	pushl  0x8(%ebp)
  800f74:	e8 6e fe ff ff       	call   800de7 <fd_lookup>
  800f79:	83 c4 08             	add    $0x8,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	0f 88 c1 00 00 00    	js     801045 <dup+0xe4>
		return r;
	close(newfdnum);
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	56                   	push   %esi
  800f88:	e8 84 ff ff ff       	call   800f11 <close>

	newfd = INDEX2FD(newfdnum);
  800f8d:	89 f3                	mov    %esi,%ebx
  800f8f:	c1 e3 0c             	shl    $0xc,%ebx
  800f92:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f98:	83 c4 04             	add    $0x4,%esp
  800f9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9e:	e8 de fd ff ff       	call   800d81 <fd2data>
  800fa3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fa5:	89 1c 24             	mov    %ebx,(%esp)
  800fa8:	e8 d4 fd ff ff       	call   800d81 <fd2data>
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb3:	89 f8                	mov    %edi,%eax
  800fb5:	c1 e8 16             	shr    $0x16,%eax
  800fb8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbf:	a8 01                	test   $0x1,%al
  800fc1:	74 37                	je     800ffa <dup+0x99>
  800fc3:	89 f8                	mov    %edi,%eax
  800fc5:	c1 e8 0c             	shr    $0xc,%eax
  800fc8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcf:	f6 c2 01             	test   $0x1,%dl
  800fd2:	74 26                	je     800ffa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fd4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe3:	50                   	push   %eax
  800fe4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe7:	6a 00                	push   $0x0
  800fe9:	57                   	push   %edi
  800fea:	6a 00                	push   $0x0
  800fec:	e8 d2 fb ff ff       	call   800bc3 <sys_page_map>
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	83 c4 20             	add    $0x20,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 2e                	js     801028 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ffd:	89 d0                	mov    %edx,%eax
  800fff:	c1 e8 0c             	shr    $0xc,%eax
  801002:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	25 07 0e 00 00       	and    $0xe07,%eax
  801011:	50                   	push   %eax
  801012:	53                   	push   %ebx
  801013:	6a 00                	push   $0x0
  801015:	52                   	push   %edx
  801016:	6a 00                	push   $0x0
  801018:	e8 a6 fb ff ff       	call   800bc3 <sys_page_map>
  80101d:	89 c7                	mov    %eax,%edi
  80101f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801022:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801024:	85 ff                	test   %edi,%edi
  801026:	79 1d                	jns    801045 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801028:	83 ec 08             	sub    $0x8,%esp
  80102b:	53                   	push   %ebx
  80102c:	6a 00                	push   $0x0
  80102e:	e8 d2 fb ff ff       	call   800c05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801033:	83 c4 08             	add    $0x8,%esp
  801036:	ff 75 d4             	pushl  -0x2c(%ebp)
  801039:	6a 00                	push   $0x0
  80103b:	e8 c5 fb ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	89 f8                	mov    %edi,%eax
}
  801045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	53                   	push   %ebx
  801051:	83 ec 14             	sub    $0x14,%esp
  801054:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801057:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80105a:	50                   	push   %eax
  80105b:	53                   	push   %ebx
  80105c:	e8 86 fd ff ff       	call   800de7 <fd_lookup>
  801061:	83 c4 08             	add    $0x8,%esp
  801064:	89 c2                	mov    %eax,%edx
  801066:	85 c0                	test   %eax,%eax
  801068:	78 6d                	js     8010d7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801070:	50                   	push   %eax
  801071:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801074:	ff 30                	pushl  (%eax)
  801076:	e8 c2 fd ff ff       	call   800e3d <dev_lookup>
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 4c                	js     8010ce <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801082:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801085:	8b 42 08             	mov    0x8(%edx),%eax
  801088:	83 e0 03             	and    $0x3,%eax
  80108b:	83 f8 01             	cmp    $0x1,%eax
  80108e:	75 21                	jne    8010b1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801090:	a1 04 40 80 00       	mov    0x804004,%eax
  801095:	8b 40 48             	mov    0x48(%eax),%eax
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	53                   	push   %ebx
  80109c:	50                   	push   %eax
  80109d:	68 0d 22 80 00       	push   $0x80220d
  8010a2:	e8 aa f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010af:	eb 26                	jmp    8010d7 <read+0x8a>
	}
	if (!dev->dev_read)
  8010b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b4:	8b 40 08             	mov    0x8(%eax),%eax
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	74 17                	je     8010d2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	ff 75 10             	pushl  0x10(%ebp)
  8010c1:	ff 75 0c             	pushl  0xc(%ebp)
  8010c4:	52                   	push   %edx
  8010c5:	ff d0                	call   *%eax
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	eb 09                	jmp    8010d7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ce:	89 c2                	mov    %eax,%edx
  8010d0:	eb 05                	jmp    8010d7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010d7:	89 d0                	mov    %edx,%eax
  8010d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f2:	eb 21                	jmp    801115 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f4:	83 ec 04             	sub    $0x4,%esp
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	29 d8                	sub    %ebx,%eax
  8010fb:	50                   	push   %eax
  8010fc:	89 d8                	mov    %ebx,%eax
  8010fe:	03 45 0c             	add    0xc(%ebp),%eax
  801101:	50                   	push   %eax
  801102:	57                   	push   %edi
  801103:	e8 45 ff ff ff       	call   80104d <read>
		if (m < 0)
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	78 10                	js     80111f <readn+0x41>
			return m;
		if (m == 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	74 0a                	je     80111d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801113:	01 c3                	add    %eax,%ebx
  801115:	39 f3                	cmp    %esi,%ebx
  801117:	72 db                	jb     8010f4 <readn+0x16>
  801119:	89 d8                	mov    %ebx,%eax
  80111b:	eb 02                	jmp    80111f <readn+0x41>
  80111d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80111f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5f                   	pop    %edi
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	53                   	push   %ebx
  80112b:	83 ec 14             	sub    $0x14,%esp
  80112e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801131:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	53                   	push   %ebx
  801136:	e8 ac fc ff ff       	call   800de7 <fd_lookup>
  80113b:	83 c4 08             	add    $0x8,%esp
  80113e:	89 c2                	mov    %eax,%edx
  801140:	85 c0                	test   %eax,%eax
  801142:	78 68                	js     8011ac <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114a:	50                   	push   %eax
  80114b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114e:	ff 30                	pushl  (%eax)
  801150:	e8 e8 fc ff ff       	call   800e3d <dev_lookup>
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 47                	js     8011a3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801163:	75 21                	jne    801186 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801165:	a1 04 40 80 00       	mov    0x804004,%eax
  80116a:	8b 40 48             	mov    0x48(%eax),%eax
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	53                   	push   %ebx
  801171:	50                   	push   %eax
  801172:	68 29 22 80 00       	push   $0x802229
  801177:	e8 d5 ef ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801184:	eb 26                	jmp    8011ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801186:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801189:	8b 52 0c             	mov    0xc(%edx),%edx
  80118c:	85 d2                	test   %edx,%edx
  80118e:	74 17                	je     8011a7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	ff 75 10             	pushl  0x10(%ebp)
  801196:	ff 75 0c             	pushl  0xc(%ebp)
  801199:	50                   	push   %eax
  80119a:	ff d2                	call   *%edx
  80119c:	89 c2                	mov    %eax,%edx
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	eb 09                	jmp    8011ac <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	eb 05                	jmp    8011ac <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011ac:	89 d0                	mov    %edx,%eax
  8011ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	ff 75 08             	pushl  0x8(%ebp)
  8011c0:	e8 22 fc ff ff       	call   800de7 <fd_lookup>
  8011c5:	83 c4 08             	add    $0x8,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 0e                	js     8011da <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 14             	sub    $0x14,%esp
  8011e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	53                   	push   %ebx
  8011eb:	e8 f7 fb ff ff       	call   800de7 <fd_lookup>
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 65                	js     80125e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801203:	ff 30                	pushl  (%eax)
  801205:	e8 33 fc ff ff       	call   800e3d <dev_lookup>
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 44                	js     801255 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801218:	75 21                	jne    80123b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80121a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80121f:	8b 40 48             	mov    0x48(%eax),%eax
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	53                   	push   %ebx
  801226:	50                   	push   %eax
  801227:	68 ec 21 80 00       	push   $0x8021ec
  80122c:	e8 20 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801239:	eb 23                	jmp    80125e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80123b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123e:	8b 52 18             	mov    0x18(%edx),%edx
  801241:	85 d2                	test   %edx,%edx
  801243:	74 14                	je     801259 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	ff 75 0c             	pushl  0xc(%ebp)
  80124b:	50                   	push   %eax
  80124c:	ff d2                	call   *%edx
  80124e:	89 c2                	mov    %eax,%edx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	eb 09                	jmp    80125e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801255:	89 c2                	mov    %eax,%edx
  801257:	eb 05                	jmp    80125e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801259:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80125e:	89 d0                	mov    %edx,%eax
  801260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801263:	c9                   	leave  
  801264:	c3                   	ret    

00801265 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	53                   	push   %ebx
  801269:	83 ec 14             	sub    $0x14,%esp
  80126c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	ff 75 08             	pushl  0x8(%ebp)
  801276:	e8 6c fb ff ff       	call   800de7 <fd_lookup>
  80127b:	83 c4 08             	add    $0x8,%esp
  80127e:	89 c2                	mov    %eax,%edx
  801280:	85 c0                	test   %eax,%eax
  801282:	78 58                	js     8012dc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128a:	50                   	push   %eax
  80128b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128e:	ff 30                	pushl  (%eax)
  801290:	e8 a8 fb ff ff       	call   800e3d <dev_lookup>
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 37                	js     8012d3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a3:	74 32                	je     8012d7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012af:	00 00 00 
	stat->st_isdir = 0;
  8012b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b9:	00 00 00 
	stat->st_dev = dev;
  8012bc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	53                   	push   %ebx
  8012c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c9:	ff 50 14             	call   *0x14(%eax)
  8012cc:	89 c2                	mov    %eax,%edx
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	eb 09                	jmp    8012dc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	eb 05                	jmp    8012dc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012dc:	89 d0                	mov    %edx,%eax
  8012de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    

008012e3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	6a 00                	push   $0x0
  8012ed:	ff 75 08             	pushl  0x8(%ebp)
  8012f0:	e8 b7 01 00 00       	call   8014ac <open>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 1b                	js     801319 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	ff 75 0c             	pushl  0xc(%ebp)
  801304:	50                   	push   %eax
  801305:	e8 5b ff ff ff       	call   801265 <fstat>
  80130a:	89 c6                	mov    %eax,%esi
	close(fd);
  80130c:	89 1c 24             	mov    %ebx,(%esp)
  80130f:	e8 fd fb ff ff       	call   800f11 <close>
	return r;
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	89 f0                	mov    %esi,%eax
}
  801319:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131c:	5b                   	pop    %ebx
  80131d:	5e                   	pop    %esi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	89 c6                	mov    %eax,%esi
  801327:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801329:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801330:	75 12                	jne    801344 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801332:	83 ec 0c             	sub    $0xc,%esp
  801335:	6a 01                	push   $0x1
  801337:	e8 02 08 00 00       	call   801b3e <ipc_find_env>
  80133c:	a3 00 40 80 00       	mov    %eax,0x804000
  801341:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801344:	6a 07                	push   $0x7
  801346:	68 00 50 80 00       	push   $0x805000
  80134b:	56                   	push   %esi
  80134c:	ff 35 00 40 80 00    	pushl  0x804000
  801352:	e8 93 07 00 00       	call   801aea <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801357:	83 c4 0c             	add    $0xc,%esp
  80135a:	6a 00                	push   $0x0
  80135c:	53                   	push   %ebx
  80135d:	6a 00                	push   $0x0
  80135f:	e8 11 07 00 00       	call   801a75 <ipc_recv>
}
  801364:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801371:	8b 45 08             	mov    0x8(%ebp),%eax
  801374:	8b 40 0c             	mov    0xc(%eax),%eax
  801377:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80137c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801384:	ba 00 00 00 00       	mov    $0x0,%edx
  801389:	b8 02 00 00 00       	mov    $0x2,%eax
  80138e:	e8 8d ff ff ff       	call   801320 <fsipc>
}
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80139b:	8b 45 08             	mov    0x8(%ebp),%eax
  80139e:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ab:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b0:	e8 6b ff ff ff       	call   801320 <fsipc>
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 04             	sub    $0x4,%esp
  8013be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d1:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d6:	e8 45 ff ff ff       	call   801320 <fsipc>
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 2c                	js     80140b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	68 00 50 80 00       	push   $0x805000
  8013e7:	53                   	push   %ebx
  8013e8:	e8 90 f3 ff ff       	call   80077d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013ed:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f8:	a1 84 50 80 00       	mov    0x805084,%eax
  8013fd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801416:	68 58 22 80 00       	push   $0x802258
  80141b:	68 90 00 00 00       	push   $0x90
  801420:	68 76 22 80 00       	push   $0x802276
  801425:	e8 05 06 00 00       	call   801a2f <_panic>

0080142a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	8b 40 0c             	mov    0xc(%eax),%eax
  801438:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80143d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 03 00 00 00       	mov    $0x3,%eax
  80144d:	e8 ce fe ff ff       	call   801320 <fsipc>
  801452:	89 c3                	mov    %eax,%ebx
  801454:	85 c0                	test   %eax,%eax
  801456:	78 4b                	js     8014a3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801458:	39 c6                	cmp    %eax,%esi
  80145a:	73 16                	jae    801472 <devfile_read+0x48>
  80145c:	68 81 22 80 00       	push   $0x802281
  801461:	68 88 22 80 00       	push   $0x802288
  801466:	6a 7c                	push   $0x7c
  801468:	68 76 22 80 00       	push   $0x802276
  80146d:	e8 bd 05 00 00       	call   801a2f <_panic>
	assert(r <= PGSIZE);
  801472:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801477:	7e 16                	jle    80148f <devfile_read+0x65>
  801479:	68 9d 22 80 00       	push   $0x80229d
  80147e:	68 88 22 80 00       	push   $0x802288
  801483:	6a 7d                	push   $0x7d
  801485:	68 76 22 80 00       	push   $0x802276
  80148a:	e8 a0 05 00 00       	call   801a2f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80148f:	83 ec 04             	sub    $0x4,%esp
  801492:	50                   	push   %eax
  801493:	68 00 50 80 00       	push   $0x805000
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	e8 6f f4 ff ff       	call   80090f <memmove>
	return r;
  8014a0:	83 c4 10             	add    $0x10,%esp
}
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    

008014ac <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 20             	sub    $0x20,%esp
  8014b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014b6:	53                   	push   %ebx
  8014b7:	e8 88 f2 ff ff       	call   800744 <strlen>
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c4:	7f 67                	jg     80152d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c6:	83 ec 0c             	sub    $0xc,%esp
  8014c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	e8 c6 f8 ff ff       	call   800d98 <fd_alloc>
  8014d2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014d5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 57                	js     801532 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	53                   	push   %ebx
  8014df:	68 00 50 80 00       	push   $0x805000
  8014e4:	e8 94 f2 ff ff       	call   80077d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ec:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	e8 22 fe ff ff       	call   801320 <fsipc>
  8014fe:	89 c3                	mov    %eax,%ebx
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	79 14                	jns    80151b <open+0x6f>
		fd_close(fd, 0);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	6a 00                	push   $0x0
  80150c:	ff 75 f4             	pushl  -0xc(%ebp)
  80150f:	e8 7c f9 ff ff       	call   800e90 <fd_close>
		return r;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	89 da                	mov    %ebx,%edx
  801519:	eb 17                	jmp    801532 <open+0x86>
	}

	return fd2num(fd);
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	ff 75 f4             	pushl  -0xc(%ebp)
  801521:	e8 4b f8 ff ff       	call   800d71 <fd2num>
  801526:	89 c2                	mov    %eax,%edx
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	eb 05                	jmp    801532 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80152d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801532:	89 d0                	mov    %edx,%eax
  801534:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801537:	c9                   	leave  
  801538:	c3                   	ret    

00801539 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	b8 08 00 00 00       	mov    $0x8,%eax
  801549:	e8 d2 fd ff ff       	call   801320 <fsipc>
}
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	e8 1e f8 ff ff       	call   800d81 <fd2data>
  801563:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801565:	83 c4 08             	add    $0x8,%esp
  801568:	68 a9 22 80 00       	push   $0x8022a9
  80156d:	53                   	push   %ebx
  80156e:	e8 0a f2 ff ff       	call   80077d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801573:	8b 46 04             	mov    0x4(%esi),%eax
  801576:	2b 06                	sub    (%esi),%eax
  801578:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80157e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801585:	00 00 00 
	stat->st_dev = &devpipe;
  801588:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80158f:	30 80 00 
	return 0;
}
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
  801597:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5e                   	pop    %esi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	53                   	push   %ebx
  8015a2:	83 ec 0c             	sub    $0xc,%esp
  8015a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015a8:	53                   	push   %ebx
  8015a9:	6a 00                	push   $0x0
  8015ab:	e8 55 f6 ff ff       	call   800c05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b0:	89 1c 24             	mov    %ebx,(%esp)
  8015b3:	e8 c9 f7 ff ff       	call   800d81 <fd2data>
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	50                   	push   %eax
  8015bc:	6a 00                	push   $0x0
  8015be:	e8 42 f6 ff ff       	call   800c05 <sys_page_unmap>
}
  8015c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	57                   	push   %edi
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 1c             	sub    $0x1c,%esp
  8015d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015d4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015db:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e4:	e8 8e 05 00 00       	call   801b77 <pageref>
  8015e9:	89 c3                	mov    %eax,%ebx
  8015eb:	89 3c 24             	mov    %edi,(%esp)
  8015ee:	e8 84 05 00 00       	call   801b77 <pageref>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	39 c3                	cmp    %eax,%ebx
  8015f8:	0f 94 c1             	sete   %cl
  8015fb:	0f b6 c9             	movzbl %cl,%ecx
  8015fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801601:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801607:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80160a:	39 ce                	cmp    %ecx,%esi
  80160c:	74 1b                	je     801629 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80160e:	39 c3                	cmp    %eax,%ebx
  801610:	75 c4                	jne    8015d6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801612:	8b 42 58             	mov    0x58(%edx),%eax
  801615:	ff 75 e4             	pushl  -0x1c(%ebp)
  801618:	50                   	push   %eax
  801619:	56                   	push   %esi
  80161a:	68 b0 22 80 00       	push   $0x8022b0
  80161f:	e8 2d eb ff ff       	call   800151 <cprintf>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	eb ad                	jmp    8015d6 <_pipeisclosed+0xe>
	}
}
  801629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162f:	5b                   	pop    %ebx
  801630:	5e                   	pop    %esi
  801631:	5f                   	pop    %edi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    

00801634 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	57                   	push   %edi
  801638:	56                   	push   %esi
  801639:	53                   	push   %ebx
  80163a:	83 ec 28             	sub    $0x28,%esp
  80163d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801640:	56                   	push   %esi
  801641:	e8 3b f7 ff ff       	call   800d81 <fd2data>
  801646:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	bf 00 00 00 00       	mov    $0x0,%edi
  801650:	eb 4b                	jmp    80169d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801652:	89 da                	mov    %ebx,%edx
  801654:	89 f0                	mov    %esi,%eax
  801656:	e8 6d ff ff ff       	call   8015c8 <_pipeisclosed>
  80165b:	85 c0                	test   %eax,%eax
  80165d:	75 48                	jne    8016a7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80165f:	e8 fd f4 ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801664:	8b 43 04             	mov    0x4(%ebx),%eax
  801667:	8b 0b                	mov    (%ebx),%ecx
  801669:	8d 51 20             	lea    0x20(%ecx),%edx
  80166c:	39 d0                	cmp    %edx,%eax
  80166e:	73 e2                	jae    801652 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801670:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801673:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801677:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	c1 fa 1f             	sar    $0x1f,%edx
  80167f:	89 d1                	mov    %edx,%ecx
  801681:	c1 e9 1b             	shr    $0x1b,%ecx
  801684:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801687:	83 e2 1f             	and    $0x1f,%edx
  80168a:	29 ca                	sub    %ecx,%edx
  80168c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801690:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801694:	83 c0 01             	add    $0x1,%eax
  801697:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169a:	83 c7 01             	add    $0x1,%edi
  80169d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016a0:	75 c2                	jne    801664 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8016a5:	eb 05                	jmp    8016ac <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	57                   	push   %edi
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 18             	sub    $0x18,%esp
  8016bd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016c0:	57                   	push   %edi
  8016c1:	e8 bb f6 ff ff       	call   800d81 <fd2data>
  8016c6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d0:	eb 3d                	jmp    80170f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016d2:	85 db                	test   %ebx,%ebx
  8016d4:	74 04                	je     8016da <devpipe_read+0x26>
				return i;
  8016d6:	89 d8                	mov    %ebx,%eax
  8016d8:	eb 44                	jmp    80171e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016da:	89 f2                	mov    %esi,%edx
  8016dc:	89 f8                	mov    %edi,%eax
  8016de:	e8 e5 fe ff ff       	call   8015c8 <_pipeisclosed>
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	75 32                	jne    801719 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016e7:	e8 75 f4 ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016ec:	8b 06                	mov    (%esi),%eax
  8016ee:	3b 46 04             	cmp    0x4(%esi),%eax
  8016f1:	74 df                	je     8016d2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016f3:	99                   	cltd   
  8016f4:	c1 ea 1b             	shr    $0x1b,%edx
  8016f7:	01 d0                	add    %edx,%eax
  8016f9:	83 e0 1f             	and    $0x1f,%eax
  8016fc:	29 d0                	sub    %edx,%eax
  8016fe:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801706:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801709:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170c:	83 c3 01             	add    $0x1,%ebx
  80170f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801712:	75 d8                	jne    8016ec <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801714:	8b 45 10             	mov    0x10(%ebp),%eax
  801717:	eb 05                	jmp    80171e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80171e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5f                   	pop    %edi
  801724:	5d                   	pop    %ebp
  801725:	c3                   	ret    

00801726 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80172e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	e8 61 f6 ff ff       	call   800d98 <fd_alloc>
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	85 c0                	test   %eax,%eax
  80173e:	0f 88 2c 01 00 00    	js     801870 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801744:	83 ec 04             	sub    $0x4,%esp
  801747:	68 07 04 00 00       	push   $0x407
  80174c:	ff 75 f4             	pushl  -0xc(%ebp)
  80174f:	6a 00                	push   $0x0
  801751:	e8 2a f4 ff ff       	call   800b80 <sys_page_alloc>
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	89 c2                	mov    %eax,%edx
  80175b:	85 c0                	test   %eax,%eax
  80175d:	0f 88 0d 01 00 00    	js     801870 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801763:	83 ec 0c             	sub    $0xc,%esp
  801766:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	e8 29 f6 ff ff       	call   800d98 <fd_alloc>
  80176f:	89 c3                	mov    %eax,%ebx
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	0f 88 e2 00 00 00    	js     80185e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177c:	83 ec 04             	sub    $0x4,%esp
  80177f:	68 07 04 00 00       	push   $0x407
  801784:	ff 75 f0             	pushl  -0x10(%ebp)
  801787:	6a 00                	push   $0x0
  801789:	e8 f2 f3 ff ff       	call   800b80 <sys_page_alloc>
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	85 c0                	test   %eax,%eax
  801795:	0f 88 c3 00 00 00    	js     80185e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a1:	e8 db f5 ff ff       	call   800d81 <fd2data>
  8017a6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a8:	83 c4 0c             	add    $0xc,%esp
  8017ab:	68 07 04 00 00       	push   $0x407
  8017b0:	50                   	push   %eax
  8017b1:	6a 00                	push   $0x0
  8017b3:	e8 c8 f3 ff ff       	call   800b80 <sys_page_alloc>
  8017b8:	89 c3                	mov    %eax,%ebx
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	0f 88 89 00 00 00    	js     80184e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c5:	83 ec 0c             	sub    $0xc,%esp
  8017c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cb:	e8 b1 f5 ff ff       	call   800d81 <fd2data>
  8017d0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017d7:	50                   	push   %eax
  8017d8:	6a 00                	push   $0x0
  8017da:	56                   	push   %esi
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 e1 f3 ff ff       	call   800bc3 <sys_page_map>
  8017e2:	89 c3                	mov    %eax,%ebx
  8017e4:	83 c4 20             	add    $0x20,%esp
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 55                	js     801840 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017eb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801800:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801809:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80180b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	ff 75 f4             	pushl  -0xc(%ebp)
  80181b:	e8 51 f5 ff ff       	call   800d71 <fd2num>
  801820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801823:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801825:	83 c4 04             	add    $0x4,%esp
  801828:	ff 75 f0             	pushl  -0x10(%ebp)
  80182b:	e8 41 f5 ff ff       	call   800d71 <fd2num>
  801830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801833:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	ba 00 00 00 00       	mov    $0x0,%edx
  80183e:	eb 30                	jmp    801870 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	56                   	push   %esi
  801844:	6a 00                	push   $0x0
  801846:	e8 ba f3 ff ff       	call   800c05 <sys_page_unmap>
  80184b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	ff 75 f0             	pushl  -0x10(%ebp)
  801854:	6a 00                	push   $0x0
  801856:	e8 aa f3 ff ff       	call   800c05 <sys_page_unmap>
  80185b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	ff 75 f4             	pushl  -0xc(%ebp)
  801864:	6a 00                	push   $0x0
  801866:	e8 9a f3 ff ff       	call   800c05 <sys_page_unmap>
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801870:	89 d0                	mov    %edx,%eax
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801882:	50                   	push   %eax
  801883:	ff 75 08             	pushl  0x8(%ebp)
  801886:	e8 5c f5 ff ff       	call   800de7 <fd_lookup>
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 18                	js     8018aa <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	ff 75 f4             	pushl  -0xc(%ebp)
  801898:	e8 e4 f4 ff ff       	call   800d81 <fd2data>
	return _pipeisclosed(fd, p);
  80189d:	89 c2                	mov    %eax,%edx
  80189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a2:	e8 21 fd ff ff       	call   8015c8 <_pipeisclosed>
  8018a7:	83 c4 10             	add    $0x10,%esp
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018bc:	68 c8 22 80 00       	push   $0x8022c8
  8018c1:	ff 75 0c             	pushl  0xc(%ebp)
  8018c4:	e8 b4 ee ff ff       	call   80077d <strcpy>
	return 0;
}
  8018c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018dc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e7:	eb 2d                	jmp    801916 <devcons_write+0x46>
		m = n - tot;
  8018e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018ec:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018ee:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018f1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018f6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018f9:	83 ec 04             	sub    $0x4,%esp
  8018fc:	53                   	push   %ebx
  8018fd:	03 45 0c             	add    0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	57                   	push   %edi
  801902:	e8 08 f0 ff ff       	call   80090f <memmove>
		sys_cputs(buf, m);
  801907:	83 c4 08             	add    $0x8,%esp
  80190a:	53                   	push   %ebx
  80190b:	57                   	push   %edi
  80190c:	e8 b3 f1 ff ff       	call   800ac4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801911:	01 de                	add    %ebx,%esi
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	89 f0                	mov    %esi,%eax
  801918:	3b 75 10             	cmp    0x10(%ebp),%esi
  80191b:	72 cc                	jb     8018e9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80191d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5f                   	pop    %edi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801930:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801934:	74 2a                	je     801960 <devcons_read+0x3b>
  801936:	eb 05                	jmp    80193d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801938:	e8 24 f2 ff ff       	call   800b61 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80193d:	e8 a0 f1 ff ff       	call   800ae2 <sys_cgetc>
  801942:	85 c0                	test   %eax,%eax
  801944:	74 f2                	je     801938 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801946:	85 c0                	test   %eax,%eax
  801948:	78 16                	js     801960 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80194a:	83 f8 04             	cmp    $0x4,%eax
  80194d:	74 0c                	je     80195b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80194f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801952:	88 02                	mov    %al,(%edx)
	return 1;
  801954:	b8 01 00 00 00       	mov    $0x1,%eax
  801959:	eb 05                	jmp    801960 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80196e:	6a 01                	push   $0x1
  801970:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801973:	50                   	push   %eax
  801974:	e8 4b f1 ff ff       	call   800ac4 <sys_cputs>
}
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <getchar>:

int
getchar(void)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801984:	6a 01                	push   $0x1
  801986:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	6a 00                	push   $0x0
  80198c:	e8 bc f6 ff ff       	call   80104d <read>
	if (r < 0)
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	78 0f                	js     8019a7 <getchar+0x29>
		return r;
	if (r < 1)
  801998:	85 c0                	test   %eax,%eax
  80199a:	7e 06                	jle    8019a2 <getchar+0x24>
		return -E_EOF;
	return c;
  80199c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a0:	eb 05                	jmp    8019a7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b2:	50                   	push   %eax
  8019b3:	ff 75 08             	pushl  0x8(%ebp)
  8019b6:	e8 2c f4 ff ff       	call   800de7 <fd_lookup>
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 11                	js     8019d3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019cb:	39 10                	cmp    %edx,(%eax)
  8019cd:	0f 94 c0             	sete   %al
  8019d0:	0f b6 c0             	movzbl %al,%eax
}
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <opencons>:

int
opencons(void)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	50                   	push   %eax
  8019df:	e8 b4 f3 ff ff       	call   800d98 <fd_alloc>
  8019e4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 3e                	js     801a2b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ed:	83 ec 04             	sub    $0x4,%esp
  8019f0:	68 07 04 00 00       	push   $0x407
  8019f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f8:	6a 00                	push   $0x0
  8019fa:	e8 81 f1 ff ff       	call   800b80 <sys_page_alloc>
  8019ff:	83 c4 10             	add    $0x10,%esp
		return r;
  801a02:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 23                	js     801a2b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a08:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a11:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a16:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	50                   	push   %eax
  801a21:	e8 4b f3 ff ff       	call   800d71 <fd2num>
  801a26:	89 c2                	mov    %eax,%edx
  801a28:	83 c4 10             	add    $0x10,%esp
}
  801a2b:	89 d0                	mov    %edx,%eax
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a34:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a37:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a3d:	e8 00 f1 ff ff       	call   800b42 <sys_getenvid>
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	ff 75 0c             	pushl  0xc(%ebp)
  801a48:	ff 75 08             	pushl  0x8(%ebp)
  801a4b:	56                   	push   %esi
  801a4c:	50                   	push   %eax
  801a4d:	68 d4 22 80 00       	push   $0x8022d4
  801a52:	e8 fa e6 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a57:	83 c4 18             	add    $0x18,%esp
  801a5a:	53                   	push   %ebx
  801a5b:	ff 75 10             	pushl  0x10(%ebp)
  801a5e:	e8 9d e6 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801a63:	c7 04 24 c1 22 80 00 	movl   $0x8022c1,(%esp)
  801a6a:	e8 e2 e6 ff ff       	call   800151 <cprintf>
  801a6f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a72:	cc                   	int3   
  801a73:	eb fd                	jmp    801a72 <_panic+0x43>

00801a75 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a83:	85 c0                	test   %eax,%eax
  801a85:	74 0e                	je     801a95 <ipc_recv+0x20>
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	50                   	push   %eax
  801a8b:	e8 a0 f2 ff ff       	call   800d30 <sys_ipc_recv>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	eb 10                	jmp    801aa5 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	68 00 00 c0 ee       	push   $0xeec00000
  801a9d:	e8 8e f2 ff ff       	call   800d30 <sys_ipc_recv>
  801aa2:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	74 16                	je     801abf <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801aa9:	85 f6                	test   %esi,%esi
  801aab:	74 06                	je     801ab3 <ipc_recv+0x3e>
  801aad:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801ab3:	85 db                	test   %ebx,%ebx
  801ab5:	74 2c                	je     801ae3 <ipc_recv+0x6e>
  801ab7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801abd:	eb 24                	jmp    801ae3 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801abf:	85 f6                	test   %esi,%esi
  801ac1:	74 0a                	je     801acd <ipc_recv+0x58>
  801ac3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac8:	8b 40 74             	mov    0x74(%eax),%eax
  801acb:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801acd:	85 db                	test   %ebx,%ebx
  801acf:	74 0a                	je     801adb <ipc_recv+0x66>
  801ad1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad6:	8b 40 78             	mov    0x78(%eax),%eax
  801ad9:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801adb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	57                   	push   %edi
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af9:	8b 45 10             	mov    0x10(%ebp),%eax
  801afc:	85 c0                	test   %eax,%eax
  801afe:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b03:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b06:	ff 75 14             	pushl  0x14(%ebp)
  801b09:	53                   	push   %ebx
  801b0a:	56                   	push   %esi
  801b0b:	57                   	push   %edi
  801b0c:	e8 fc f1 ff ff       	call   800d0d <sys_ipc_try_send>
		if (ret == 0) break;
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	85 c0                	test   %eax,%eax
  801b16:	74 1e                	je     801b36 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b18:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b1b:	74 12                	je     801b2f <ipc_send+0x45>
  801b1d:	50                   	push   %eax
  801b1e:	68 f8 22 80 00       	push   $0x8022f8
  801b23:	6a 39                	push   $0x39
  801b25:	68 05 23 80 00       	push   $0x802305
  801b2a:	e8 00 ff ff ff       	call   801a2f <_panic>
		sys_yield();
  801b2f:	e8 2d f0 ff ff       	call   800b61 <sys_yield>
	}
  801b34:	eb d0                	jmp    801b06 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b49:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b4c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b52:	8b 52 50             	mov    0x50(%edx),%edx
  801b55:	39 ca                	cmp    %ecx,%edx
  801b57:	75 0d                	jne    801b66 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b59:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b61:	8b 40 48             	mov    0x48(%eax),%eax
  801b64:	eb 0f                	jmp    801b75 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	83 c0 01             	add    $0x1,%eax
  801b69:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b6e:	75 d9                	jne    801b49 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7d:	89 d0                	mov    %edx,%eax
  801b7f:	c1 e8 16             	shr    $0x16,%eax
  801b82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8e:	f6 c1 01             	test   $0x1,%cl
  801b91:	74 1d                	je     801bb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b93:	c1 ea 0c             	shr    $0xc,%edx
  801b96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9d:	f6 c2 01             	test   $0x1,%dl
  801ba0:	74 0e                	je     801bb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba2:	c1 ea 0c             	shr    $0xc,%edx
  801ba5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bac:	ef 
  801bad:	0f b7 c0             	movzwl %ax,%eax
}
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    
  801bb2:	66 90                	xchg   %ax,%ax
  801bb4:	66 90                	xchg   %ax,%ax
  801bb6:	66 90                	xchg   %ax,%ax
  801bb8:	66 90                	xchg   %ax,%ax
  801bba:	66 90                	xchg   %ax,%ax
  801bbc:	66 90                	xchg   %ax,%ax
  801bbe:	66 90                	xchg   %ax,%ax

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
