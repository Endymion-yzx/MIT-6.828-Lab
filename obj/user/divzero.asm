
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 60 1e 80 00       	push   $0x801e60
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  80006b:	e8 d4 0a 00 00       	call   800b44 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 8d 0e 00 00       	call   800f3e <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 48 0a 00 00       	call   800b03 <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 d6 09 00 00       	call   800ac6 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 1a 01 00 00       	call   800250 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 7b 09 00 00       	call   800ac6 <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 45                	ja     8001dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 05 1a 00 00       	call   801bc0 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 18                	jmp    8001e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb 03                	jmp    8001df <printnum+0x78>
  8001dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	85 db                	test   %ebx,%ebx
  8001e4:	7f e8                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 f2 1a 00 00       	call   801cf0 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 78 1e 80 00 	movsbl 0x801e78(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff d7                	call   *%edi
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800220:	8b 10                	mov    (%eax),%edx
  800222:	3b 50 04             	cmp    0x4(%eax),%edx
  800225:	73 0a                	jae    800231 <sprintputch+0x1b>
		*b->buf++ = ch;
  800227:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022a:	89 08                	mov    %ecx,(%eax)
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	88 02                	mov    %al,(%edx)
}
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800239:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 10             	pushl  0x10(%ebp)
  800240:	ff 75 0c             	pushl  0xc(%ebp)
  800243:	ff 75 08             	pushl  0x8(%ebp)
  800246:	e8 05 00 00 00       	call   800250 <vprintfmt>
	va_end(ap);
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 2c             	sub    $0x2c,%esp
  800259:	8b 75 08             	mov    0x8(%ebp),%esi
  80025c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800262:	eb 12                	jmp    800276 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800264:	85 c0                	test   %eax,%eax
  800266:	0f 84 6a 04 00 00    	je     8006d6 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	53                   	push   %ebx
  800270:	50                   	push   %eax
  800271:	ff d6                	call   *%esi
  800273:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800276:	83 c7 01             	add    $0x1,%edi
  800279:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80027d:	83 f8 25             	cmp    $0x25,%eax
  800280:	75 e2                	jne    800264 <vprintfmt+0x14>
  800282:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800286:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80028d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800294:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80029b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a0:	eb 07                	jmp    8002a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a9:	8d 47 01             	lea    0x1(%edi),%eax
  8002ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002af:	0f b6 07             	movzbl (%edi),%eax
  8002b2:	0f b6 d0             	movzbl %al,%edx
  8002b5:	83 e8 23             	sub    $0x23,%eax
  8002b8:	3c 55                	cmp    $0x55,%al
  8002ba:	0f 87 fb 03 00 00    	ja     8006bb <vprintfmt+0x46b>
  8002c0:	0f b6 c0             	movzbl %al,%eax
  8002c3:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002d1:	eb d6                	jmp    8002a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002eb:	83 f9 09             	cmp    $0x9,%ecx
  8002ee:	77 3f                	ja     80032f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002f3:	eb e9                	jmp    8002de <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f8:	8b 00                	mov    (%eax),%eax
  8002fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8d 40 04             	lea    0x4(%eax),%eax
  800303:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800309:	eb 2a                	jmp    800335 <vprintfmt+0xe5>
  80030b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030e:	85 c0                	test   %eax,%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	0f 49 d0             	cmovns %eax,%edx
  800318:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031e:	eb 89                	jmp    8002a9 <vprintfmt+0x59>
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800323:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80032a:	e9 7a ff ff ff       	jmp    8002a9 <vprintfmt+0x59>
  80032f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800332:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800335:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800339:	0f 89 6a ff ff ff    	jns    8002a9 <vprintfmt+0x59>
				width = precision, precision = -1;
  80033f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800342:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800345:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034c:	e9 58 ff ff ff       	jmp    8002a9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800351:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800357:	e9 4d ff ff ff       	jmp    8002a9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8d 78 04             	lea    0x4(%eax),%edi
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	53                   	push   %ebx
  800366:	ff 30                	pushl  (%eax)
  800368:	ff d6                	call   *%esi
			break;
  80036a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80036d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800373:	e9 fe fe ff ff       	jmp    800276 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 78 04             	lea    0x4(%eax),%edi
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	99                   	cltd   
  800381:	31 d0                	xor    %edx,%eax
  800383:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800385:	83 f8 0f             	cmp    $0xf,%eax
  800388:	7f 0b                	jg     800395 <vprintfmt+0x145>
  80038a:	8b 14 85 20 21 80 00 	mov    0x802120(,%eax,4),%edx
  800391:	85 d2                	test   %edx,%edx
  800393:	75 1b                	jne    8003b0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800395:	50                   	push   %eax
  800396:	68 90 1e 80 00       	push   $0x801e90
  80039b:	53                   	push   %ebx
  80039c:	56                   	push   %esi
  80039d:	e8 91 fe ff ff       	call   800233 <printfmt>
  8003a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ab:	e9 c6 fe ff ff       	jmp    800276 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003b0:	52                   	push   %edx
  8003b1:	68 7a 22 80 00       	push   $0x80227a
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	e8 76 fe ff ff       	call   800233 <printfmt>
  8003bd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c6:	e9 ab fe ff ff       	jmp    800276 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	83 c0 04             	add    $0x4,%eax
  8003d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d9:	85 ff                	test   %edi,%edi
  8003db:	b8 89 1e 80 00       	mov    $0x801e89,%eax
  8003e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e7:	0f 8e 94 00 00 00    	jle    800481 <vprintfmt+0x231>
  8003ed:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003f1:	0f 84 98 00 00 00    	je     80048f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fd:	57                   	push   %edi
  8003fe:	e8 5b 03 00 00       	call   80075e <strnlen>
  800403:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800406:	29 c1                	sub    %eax,%ecx
  800408:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80040b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80040e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800415:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800418:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80041a:	eb 0f                	jmp    80042b <vprintfmt+0x1db>
					putch(padc, putdat);
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	53                   	push   %ebx
  800420:	ff 75 e0             	pushl  -0x20(%ebp)
  800423:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ef 01             	sub    $0x1,%edi
  800428:	83 c4 10             	add    $0x10,%esp
  80042b:	85 ff                	test   %edi,%edi
  80042d:	7f ed                	jg     80041c <vprintfmt+0x1cc>
  80042f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800432:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800435:	85 c9                	test   %ecx,%ecx
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	0f 49 c1             	cmovns %ecx,%eax
  80043f:	29 c1                	sub    %eax,%ecx
  800441:	89 75 08             	mov    %esi,0x8(%ebp)
  800444:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800447:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80044a:	89 cb                	mov    %ecx,%ebx
  80044c:	eb 4d                	jmp    80049b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80044e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800452:	74 1b                	je     80046f <vprintfmt+0x21f>
  800454:	0f be c0             	movsbl %al,%eax
  800457:	83 e8 20             	sub    $0x20,%eax
  80045a:	83 f8 5e             	cmp    $0x5e,%eax
  80045d:	76 10                	jbe    80046f <vprintfmt+0x21f>
					putch('?', putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 0c             	pushl  0xc(%ebp)
  800465:	6a 3f                	push   $0x3f
  800467:	ff 55 08             	call   *0x8(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	eb 0d                	jmp    80047c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	ff 75 0c             	pushl  0xc(%ebp)
  800475:	52                   	push   %edx
  800476:	ff 55 08             	call   *0x8(%ebp)
  800479:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047c:	83 eb 01             	sub    $0x1,%ebx
  80047f:	eb 1a                	jmp    80049b <vprintfmt+0x24b>
  800481:	89 75 08             	mov    %esi,0x8(%ebp)
  800484:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800487:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048d:	eb 0c                	jmp    80049b <vprintfmt+0x24b>
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049b:	83 c7 01             	add    $0x1,%edi
  80049e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a2:	0f be d0             	movsbl %al,%edx
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	74 23                	je     8004cc <vprintfmt+0x27c>
  8004a9:	85 f6                	test   %esi,%esi
  8004ab:	78 a1                	js     80044e <vprintfmt+0x1fe>
  8004ad:	83 ee 01             	sub    $0x1,%esi
  8004b0:	79 9c                	jns    80044e <vprintfmt+0x1fe>
  8004b2:	89 df                	mov    %ebx,%edi
  8004b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ba:	eb 18                	jmp    8004d4 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	6a 20                	push   $0x20
  8004c2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c4:	83 ef 01             	sub    $0x1,%edi
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	eb 08                	jmp    8004d4 <vprintfmt+0x284>
  8004cc:	89 df                	mov    %ebx,%edi
  8004ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d4:	85 ff                	test   %edi,%edi
  8004d6:	7f e4                	jg     8004bc <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004db:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e1:	e9 90 fd ff ff       	jmp    800276 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e6:	83 f9 01             	cmp    $0x1,%ecx
  8004e9:	7e 19                	jle    800504 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8b 50 04             	mov    0x4(%eax),%edx
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 40 08             	lea    0x8(%eax),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	eb 38                	jmp    80053c <vprintfmt+0x2ec>
	else if (lflag)
  800504:	85 c9                	test   %ecx,%ecx
  800506:	74 1b                	je     800523 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	89 c1                	mov    %eax,%ecx
  800512:	c1 f9 1f             	sar    $0x1f,%ecx
  800515:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 40 04             	lea    0x4(%eax),%eax
  80051e:	89 45 14             	mov    %eax,0x14(%ebp)
  800521:	eb 19                	jmp    80053c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 c1                	mov    %eax,%ecx
  80052d:	c1 f9 1f             	sar    $0x1f,%ecx
  800530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 40 04             	lea    0x4(%eax),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80053c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800542:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800547:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054b:	0f 89 36 01 00 00    	jns    800687 <vprintfmt+0x437>
				putch('-', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	53                   	push   %ebx
  800555:	6a 2d                	push   $0x2d
  800557:	ff d6                	call   *%esi
				num = -(long long) num;
  800559:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055f:	f7 da                	neg    %edx
  800561:	83 d1 00             	adc    $0x0,%ecx
  800564:	f7 d9                	neg    %ecx
  800566:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	e9 14 01 00 00       	jmp    800687 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800573:	83 f9 01             	cmp    $0x1,%ecx
  800576:	7e 18                	jle    800590 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 10                	mov    (%eax),%edx
  80057d:	8b 48 04             	mov    0x4(%eax),%ecx
  800580:	8d 40 08             	lea    0x8(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058b:	e9 f7 00 00 00       	jmp    800687 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800590:	85 c9                	test   %ecx,%ecx
  800592:	74 1a                	je     8005ae <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 10                	mov    (%eax),%edx
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a9:	e9 d9 00 00 00       	jmp    800687 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 bf 00 00 00       	jmp    800687 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7e 13                	jle    8005e0 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 50 04             	mov    0x4(%eax),%edx
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005d8:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005db:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005de:	eb 28                	jmp    800608 <vprintfmt+0x3b8>
	else if (lflag)
  8005e0:	85 c9                	test   %ecx,%ecx
  8005e2:	74 13                	je     8005f7 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	89 d0                	mov    %edx,%eax
  8005eb:	99                   	cltd   
  8005ec:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005ef:	8d 49 04             	lea    0x4(%ecx),%ecx
  8005f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f5:	eb 11                	jmp    800608 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	89 d0                	mov    %edx,%eax
  8005fe:	99                   	cltd   
  8005ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800602:	8d 49 04             	lea    0x4(%ecx),%ecx
  800605:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800608:	89 d1                	mov    %edx,%ecx
  80060a:	89 c2                	mov    %eax,%edx
			base = 8;
  80060c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800611:	eb 74                	jmp    800687 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 30                	push   $0x30
  800619:	ff d6                	call   *%esi
			putch('x', putdat);
  80061b:	83 c4 08             	add    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 78                	push   $0x78
  800621:	ff d6                	call   *%esi
			num = (unsigned long long)
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800630:	8d 40 04             	lea    0x4(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800636:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063b:	eb 4a                	jmp    800687 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063d:	83 f9 01             	cmp    $0x1,%ecx
  800640:	7e 15                	jle    800657 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	8b 48 04             	mov    0x4(%eax),%ecx
  80064a:	8d 40 08             	lea    0x8(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800650:	b8 10 00 00 00       	mov    $0x10,%eax
  800655:	eb 30                	jmp    800687 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800657:	85 c9                	test   %ecx,%ecx
  800659:	74 17                	je     800672 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80066b:	b8 10 00 00 00       	mov    $0x10,%eax
  800670:	eb 15                	jmp    800687 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800682:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800687:	83 ec 0c             	sub    $0xc,%esp
  80068a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068e:	57                   	push   %edi
  80068f:	ff 75 e0             	pushl  -0x20(%ebp)
  800692:	50                   	push   %eax
  800693:	51                   	push   %ecx
  800694:	52                   	push   %edx
  800695:	89 da                	mov    %ebx,%edx
  800697:	89 f0                	mov    %esi,%eax
  800699:	e8 c9 fa ff ff       	call   800167 <printnum>
			break;
  80069e:	83 c4 20             	add    $0x20,%esp
  8006a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a4:	e9 cd fb ff ff       	jmp    800276 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	52                   	push   %edx
  8006ae:	ff d6                	call   *%esi
			break;
  8006b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b6:	e9 bb fb ff ff       	jmp    800276 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 25                	push   $0x25
  8006c1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	eb 03                	jmp    8006cb <vprintfmt+0x47b>
  8006c8:	83 ef 01             	sub    $0x1,%edi
  8006cb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cf:	75 f7                	jne    8006c8 <vprintfmt+0x478>
  8006d1:	e9 a0 fb ff ff       	jmp    800276 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d9:	5b                   	pop    %ebx
  8006da:	5e                   	pop    %esi
  8006db:	5f                   	pop    %edi
  8006dc:	5d                   	pop    %ebp
  8006dd:	c3                   	ret    

008006de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	83 ec 18             	sub    $0x18,%esp
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	74 26                	je     800725 <vsnprintf+0x47>
  8006ff:	85 d2                	test   %edx,%edx
  800701:	7e 22                	jle    800725 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800703:	ff 75 14             	pushl  0x14(%ebp)
  800706:	ff 75 10             	pushl  0x10(%ebp)
  800709:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070c:	50                   	push   %eax
  80070d:	68 16 02 80 00       	push   $0x800216
  800712:	e8 39 fb ff ff       	call   800250 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800717:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	eb 05                	jmp    80072a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800725:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800735:	50                   	push   %eax
  800736:	ff 75 10             	pushl  0x10(%ebp)
  800739:	ff 75 0c             	pushl  0xc(%ebp)
  80073c:	ff 75 08             	pushl  0x8(%ebp)
  80073f:	e8 9a ff ff ff       	call   8006de <vsnprintf>
	va_end(ap);

	return rc;
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074c:	b8 00 00 00 00       	mov    $0x0,%eax
  800751:	eb 03                	jmp    800756 <strlen+0x10>
		n++;
  800753:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075a:	75 f7                	jne    800753 <strlen+0xd>
		n++;
	return n;
}
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800764:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	ba 00 00 00 00       	mov    $0x0,%edx
  80076c:	eb 03                	jmp    800771 <strnlen+0x13>
		n++;
  80076e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800771:	39 c2                	cmp    %eax,%edx
  800773:	74 08                	je     80077d <strnlen+0x1f>
  800775:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800779:	75 f3                	jne    80076e <strnlen+0x10>
  80077b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	53                   	push   %ebx
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800789:	89 c2                	mov    %eax,%edx
  80078b:	83 c2 01             	add    $0x1,%edx
  80078e:	83 c1 01             	add    $0x1,%ecx
  800791:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800795:	88 5a ff             	mov    %bl,-0x1(%edx)
  800798:	84 db                	test   %bl,%bl
  80079a:	75 ef                	jne    80078b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079c:	5b                   	pop    %ebx
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a6:	53                   	push   %ebx
  8007a7:	e8 9a ff ff ff       	call   800746 <strlen>
  8007ac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	01 d8                	add    %ebx,%eax
  8007b4:	50                   	push   %eax
  8007b5:	e8 c5 ff ff ff       	call   80077f <strcpy>
	return dst;
}
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	56                   	push   %esi
  8007c5:	53                   	push   %ebx
  8007c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cc:	89 f3                	mov    %esi,%ebx
  8007ce:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d1:	89 f2                	mov    %esi,%edx
  8007d3:	eb 0f                	jmp    8007e4 <strncpy+0x23>
		*dst++ = *src;
  8007d5:	83 c2 01             	add    $0x1,%edx
  8007d8:	0f b6 01             	movzbl (%ecx),%eax
  8007db:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007de:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e4:	39 da                	cmp    %ebx,%edx
  8007e6:	75 ed                	jne    8007d5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e8:	89 f0                	mov    %esi,%eax
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fe:	85 d2                	test   %edx,%edx
  800800:	74 21                	je     800823 <strlcpy+0x35>
  800802:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800806:	89 f2                	mov    %esi,%edx
  800808:	eb 09                	jmp    800813 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080a:	83 c2 01             	add    $0x1,%edx
  80080d:	83 c1 01             	add    $0x1,%ecx
  800810:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800813:	39 c2                	cmp    %eax,%edx
  800815:	74 09                	je     800820 <strlcpy+0x32>
  800817:	0f b6 19             	movzbl (%ecx),%ebx
  80081a:	84 db                	test   %bl,%bl
  80081c:	75 ec                	jne    80080a <strlcpy+0x1c>
  80081e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800820:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800823:	29 f0                	sub    %esi,%eax
}
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800832:	eb 06                	jmp    80083a <strcmp+0x11>
		p++, q++;
  800834:	83 c1 01             	add    $0x1,%ecx
  800837:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083a:	0f b6 01             	movzbl (%ecx),%eax
  80083d:	84 c0                	test   %al,%al
  80083f:	74 04                	je     800845 <strcmp+0x1c>
  800841:	3a 02                	cmp    (%edx),%al
  800843:	74 ef                	je     800834 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800845:	0f b6 c0             	movzbl %al,%eax
  800848:	0f b6 12             	movzbl (%edx),%edx
  80084b:	29 d0                	sub    %edx,%eax
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 c3                	mov    %eax,%ebx
  80085b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strncmp+0x17>
		n--, p++, q++;
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 15                	je     80087f <strncmp+0x30>
  80086a:	0f b6 08             	movzbl (%eax),%ecx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	74 04                	je     800875 <strncmp+0x26>
  800871:	3a 0a                	cmp    (%edx),%cl
  800873:	74 eb                	je     800860 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800875:	0f b6 00             	movzbl (%eax),%eax
  800878:	0f b6 12             	movzbl (%edx),%edx
  80087b:	29 d0                	sub    %edx,%eax
  80087d:	eb 05                	jmp    800884 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800891:	eb 07                	jmp    80089a <strchr+0x13>
		if (*s == c)
  800893:	38 ca                	cmp    %cl,%dl
  800895:	74 0f                	je     8008a6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	0f b6 10             	movzbl (%eax),%edx
  80089d:	84 d2                	test   %dl,%dl
  80089f:	75 f2                	jne    800893 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b2:	eb 03                	jmp    8008b7 <strfind+0xf>
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ba:	38 ca                	cmp    %cl,%dl
  8008bc:	74 04                	je     8008c2 <strfind+0x1a>
  8008be:	84 d2                	test   %dl,%dl
  8008c0:	75 f2                	jne    8008b4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	57                   	push   %edi
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d0:	85 c9                	test   %ecx,%ecx
  8008d2:	74 36                	je     80090a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008da:	75 28                	jne    800904 <memset+0x40>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	75 23                	jne    800904 <memset+0x40>
		c &= 0xFF;
  8008e1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e5:	89 d3                	mov    %edx,%ebx
  8008e7:	c1 e3 08             	shl    $0x8,%ebx
  8008ea:	89 d6                	mov    %edx,%esi
  8008ec:	c1 e6 18             	shl    $0x18,%esi
  8008ef:	89 d0                	mov    %edx,%eax
  8008f1:	c1 e0 10             	shl    $0x10,%eax
  8008f4:	09 f0                	or     %esi,%eax
  8008f6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f8:	89 d8                	mov    %ebx,%eax
  8008fa:	09 d0                	or     %edx,%eax
  8008fc:	c1 e9 02             	shr    $0x2,%ecx
  8008ff:	fc                   	cld    
  800900:	f3 ab                	rep stos %eax,%es:(%edi)
  800902:	eb 06                	jmp    80090a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800904:	8b 45 0c             	mov    0xc(%ebp),%eax
  800907:	fc                   	cld    
  800908:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090a:	89 f8                	mov    %edi,%eax
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5f                   	pop    %edi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091f:	39 c6                	cmp    %eax,%esi
  800921:	73 35                	jae    800958 <memmove+0x47>
  800923:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800926:	39 d0                	cmp    %edx,%eax
  800928:	73 2e                	jae    800958 <memmove+0x47>
		s += n;
		d += n;
  80092a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	89 d6                	mov    %edx,%esi
  80092f:	09 fe                	or     %edi,%esi
  800931:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800937:	75 13                	jne    80094c <memmove+0x3b>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 0e                	jne    80094c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093e:	83 ef 04             	sub    $0x4,%edi
  800941:	8d 72 fc             	lea    -0x4(%edx),%esi
  800944:	c1 e9 02             	shr    $0x2,%ecx
  800947:	fd                   	std    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 09                	jmp    800955 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094c:	83 ef 01             	sub    $0x1,%edi
  80094f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800952:	fd                   	std    
  800953:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800955:	fc                   	cld    
  800956:	eb 1d                	jmp    800975 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800958:	89 f2                	mov    %esi,%edx
  80095a:	09 c2                	or     %eax,%edx
  80095c:	f6 c2 03             	test   $0x3,%dl
  80095f:	75 0f                	jne    800970 <memmove+0x5f>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 0a                	jne    800970 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800966:	c1 e9 02             	shr    $0x2,%ecx
  800969:	89 c7                	mov    %eax,%edi
  80096b:	fc                   	cld    
  80096c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096e:	eb 05                	jmp    800975 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800970:	89 c7                	mov    %eax,%edi
  800972:	fc                   	cld    
  800973:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097c:	ff 75 10             	pushl  0x10(%ebp)
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	ff 75 08             	pushl  0x8(%ebp)
  800985:	e8 87 ff ff ff       	call   800911 <memmove>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	89 c6                	mov    %eax,%esi
  800999:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099c:	eb 1a                	jmp    8009b8 <memcmp+0x2c>
		if (*s1 != *s2)
  80099e:	0f b6 08             	movzbl (%eax),%ecx
  8009a1:	0f b6 1a             	movzbl (%edx),%ebx
  8009a4:	38 d9                	cmp    %bl,%cl
  8009a6:	74 0a                	je     8009b2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a8:	0f b6 c1             	movzbl %cl,%eax
  8009ab:	0f b6 db             	movzbl %bl,%ebx
  8009ae:	29 d8                	sub    %ebx,%eax
  8009b0:	eb 0f                	jmp    8009c1 <memcmp+0x35>
		s1++, s2++;
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b8:	39 f0                	cmp    %esi,%eax
  8009ba:	75 e2                	jne    80099e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009cc:	89 c1                	mov    %eax,%ecx
  8009ce:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d5:	eb 0a                	jmp    8009e1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d7:	0f b6 10             	movzbl (%eax),%edx
  8009da:	39 da                	cmp    %ebx,%edx
  8009dc:	74 07                	je     8009e5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	39 c8                	cmp    %ecx,%eax
  8009e3:	72 f2                	jb     8009d7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f4:	eb 03                	jmp    8009f9 <strtol+0x11>
		s++;
  8009f6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	3c 20                	cmp    $0x20,%al
  8009fe:	74 f6                	je     8009f6 <strtol+0xe>
  800a00:	3c 09                	cmp    $0x9,%al
  800a02:	74 f2                	je     8009f6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a04:	3c 2b                	cmp    $0x2b,%al
  800a06:	75 0a                	jne    800a12 <strtol+0x2a>
		s++;
  800a08:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a10:	eb 11                	jmp    800a23 <strtol+0x3b>
  800a12:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a17:	3c 2d                	cmp    $0x2d,%al
  800a19:	75 08                	jne    800a23 <strtol+0x3b>
		s++, neg = 1;
  800a1b:	83 c1 01             	add    $0x1,%ecx
  800a1e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a29:	75 15                	jne    800a40 <strtol+0x58>
  800a2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2e:	75 10                	jne    800a40 <strtol+0x58>
  800a30:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a34:	75 7c                	jne    800ab2 <strtol+0xca>
		s += 2, base = 16;
  800a36:	83 c1 02             	add    $0x2,%ecx
  800a39:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3e:	eb 16                	jmp    800a56 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	75 12                	jne    800a56 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a44:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a49:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4c:	75 08                	jne    800a56 <strtol+0x6e>
		s++, base = 8;
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5e:	0f b6 11             	movzbl (%ecx),%edx
  800a61:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a64:	89 f3                	mov    %esi,%ebx
  800a66:	80 fb 09             	cmp    $0x9,%bl
  800a69:	77 08                	ja     800a73 <strtol+0x8b>
			dig = *s - '0';
  800a6b:	0f be d2             	movsbl %dl,%edx
  800a6e:	83 ea 30             	sub    $0x30,%edx
  800a71:	eb 22                	jmp    800a95 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 19             	cmp    $0x19,%bl
  800a7b:	77 08                	ja     800a85 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 57             	sub    $0x57,%edx
  800a83:	eb 10                	jmp    800a95 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a85:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 16                	ja     800aa5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a95:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a98:	7d 0b                	jge    800aa5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa3:	eb b9                	jmp    800a5e <strtol+0x76>

	if (endptr)
  800aa5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa9:	74 0d                	je     800ab8 <strtol+0xd0>
		*endptr = (char *) s;
  800aab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aae:	89 0e                	mov    %ecx,(%esi)
  800ab0:	eb 06                	jmp    800ab8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	74 98                	je     800a4e <strtol+0x66>
  800ab6:	eb 9e                	jmp    800a56 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab8:	89 c2                	mov    %eax,%edx
  800aba:	f7 da                	neg    %edx
  800abc:	85 ff                	test   %edi,%edi
  800abe:	0f 45 c2             	cmovne %edx,%eax
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	89 c3                	mov    %eax,%ebx
  800ad9:	89 c7                	mov    %eax,%edi
  800adb:	89 c6                	mov    %eax,%esi
  800add:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	b8 01 00 00 00       	mov    $0x1,%eax
  800af4:	89 d1                	mov    %edx,%ecx
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	89 d7                	mov    %edx,%edi
  800afa:	89 d6                	mov    %edx,%esi
  800afc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b11:	b8 03 00 00 00       	mov    $0x3,%eax
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	89 cb                	mov    %ecx,%ebx
  800b1b:	89 cf                	mov    %ecx,%edi
  800b1d:	89 ce                	mov    %ecx,%esi
  800b1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	7e 17                	jle    800b3c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b25:	83 ec 0c             	sub    $0xc,%esp
  800b28:	50                   	push   %eax
  800b29:	6a 03                	push   $0x3
  800b2b:	68 7f 21 80 00       	push   $0x80217f
  800b30:	6a 23                	push   $0x23
  800b32:	68 9c 21 80 00       	push   $0x80219c
  800b37:	e8 f5 0e 00 00       	call   801a31 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b54:	89 d1                	mov    %edx,%ecx
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	89 d7                	mov    %edx,%edi
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_yield>:

void
sys_yield(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b73:	89 d1                	mov    %edx,%ecx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	89 d7                	mov    %edx,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	be 00 00 00 00       	mov    $0x0,%esi
  800b90:	b8 04 00 00 00       	mov    $0x4,%eax
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9e:	89 f7                	mov    %esi,%edi
  800ba0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 04                	push   $0x4
  800bac:	68 7f 21 80 00       	push   $0x80217f
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 9c 21 80 00       	push   $0x80219c
  800bb8:	e8 74 0e 00 00       	call   801a31 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdf:	8b 75 18             	mov    0x18(%ebp),%esi
  800be2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	7e 17                	jle    800bff <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	50                   	push   %eax
  800bec:	6a 05                	push   $0x5
  800bee:	68 7f 21 80 00       	push   $0x80217f
  800bf3:	6a 23                	push   $0x23
  800bf5:	68 9c 21 80 00       	push   $0x80219c
  800bfa:	e8 32 0e 00 00       	call   801a31 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 17                	jle    800c41 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	50                   	push   %eax
  800c2e:	6a 06                	push   $0x6
  800c30:	68 7f 21 80 00       	push   $0x80217f
  800c35:	6a 23                	push   $0x23
  800c37:	68 9c 21 80 00       	push   $0x80219c
  800c3c:	e8 f0 0d 00 00       	call   801a31 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c62:	89 df                	mov    %ebx,%edi
  800c64:	89 de                	mov    %ebx,%esi
  800c66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	7e 17                	jle    800c83 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	50                   	push   %eax
  800c70:	6a 08                	push   $0x8
  800c72:	68 7f 21 80 00       	push   $0x80217f
  800c77:	6a 23                	push   $0x23
  800c79:	68 9c 21 80 00       	push   $0x80219c
  800c7e:	e8 ae 0d 00 00       	call   801a31 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7e 17                	jle    800cc5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	50                   	push   %eax
  800cb2:	6a 09                	push   $0x9
  800cb4:	68 7f 21 80 00       	push   $0x80217f
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 9c 21 80 00       	push   $0x80219c
  800cc0:	e8 6c 0d 00 00       	call   801a31 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 df                	mov    %ebx,%edi
  800ce8:	89 de                	mov    %ebx,%esi
  800cea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 17                	jle    800d07 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	83 ec 0c             	sub    $0xc,%esp
  800cf3:	50                   	push   %eax
  800cf4:	6a 0a                	push   $0xa
  800cf6:	68 7f 21 80 00       	push   $0x80217f
  800cfb:	6a 23                	push   $0x23
  800cfd:	68 9c 21 80 00       	push   $0x80219c
  800d02:	e8 2a 0d 00 00       	call   801a31 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	be 00 00 00 00       	mov    $0x0,%esi
  800d1a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d40:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	89 cb                	mov    %ecx,%ebx
  800d4a:	89 cf                	mov    %ecx,%edi
  800d4c:	89 ce                	mov    %ecx,%esi
  800d4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7e 17                	jle    800d6b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	50                   	push   %eax
  800d58:	6a 0d                	push   $0xd
  800d5a:	68 7f 21 80 00       	push   $0x80217f
  800d5f:	6a 23                	push   $0x23
  800d61:	68 9c 21 80 00       	push   $0x80219c
  800d66:	e8 c6 0c 00 00       	call   801a31 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7e:	c1 e8 0c             	shr    $0xc,%eax
}
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d93:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da5:	89 c2                	mov    %eax,%edx
  800da7:	c1 ea 16             	shr    $0x16,%edx
  800daa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db1:	f6 c2 01             	test   $0x1,%dl
  800db4:	74 11                	je     800dc7 <fd_alloc+0x2d>
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 0c             	shr    $0xc,%edx
  800dbb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	75 09                	jne    800dd0 <fd_alloc+0x36>
			*fd_store = fd;
  800dc7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	eb 17                	jmp    800de7 <fd_alloc+0x4d>
  800dd0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dda:	75 c9                	jne    800da5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ddc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800def:	83 f8 1f             	cmp    $0x1f,%eax
  800df2:	77 36                	ja     800e2a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df4:	c1 e0 0c             	shl    $0xc,%eax
  800df7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	c1 ea 16             	shr    $0x16,%edx
  800e01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e08:	f6 c2 01             	test   $0x1,%dl
  800e0b:	74 24                	je     800e31 <fd_lookup+0x48>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 0c             	shr    $0xc,%edx
  800e12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	74 1a                	je     800e38 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e21:	89 02                	mov    %eax,(%edx)
	return 0;
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
  800e28:	eb 13                	jmp    800e3d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2f:	eb 0c                	jmp    800e3d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e36:	eb 05                	jmp    800e3d <fd_lookup+0x54>
  800e38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e48:	ba 28 22 80 00       	mov    $0x802228,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4d:	eb 13                	jmp    800e62 <dev_lookup+0x23>
  800e4f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e52:	39 08                	cmp    %ecx,(%eax)
  800e54:	75 0c                	jne    800e62 <dev_lookup+0x23>
			*dev = devtab[i];
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	eb 2e                	jmp    800e90 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e62:	8b 02                	mov    (%edx),%eax
  800e64:	85 c0                	test   %eax,%eax
  800e66:	75 e7                	jne    800e4f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e68:	a1 08 40 80 00       	mov    0x804008,%eax
  800e6d:	8b 40 48             	mov    0x48(%eax),%eax
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	51                   	push   %ecx
  800e74:	50                   	push   %eax
  800e75:	68 ac 21 80 00       	push   $0x8021ac
  800e7a:	e8 d4 f2 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 10             	sub    $0x10,%esp
  800e9a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea3:	50                   	push   %eax
  800ea4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eaa:	c1 e8 0c             	shr    $0xc,%eax
  800ead:	50                   	push   %eax
  800eae:	e8 36 ff ff ff       	call   800de9 <fd_lookup>
  800eb3:	83 c4 08             	add    $0x8,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 05                	js     800ebf <fd_close+0x2d>
	    || fd != fd2)
  800eba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ebd:	74 0c                	je     800ecb <fd_close+0x39>
		return (must_exist ? r : 0);
  800ebf:	84 db                	test   %bl,%bl
  800ec1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec6:	0f 44 c2             	cmove  %edx,%eax
  800ec9:	eb 41                	jmp    800f0c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed1:	50                   	push   %eax
  800ed2:	ff 36                	pushl  (%esi)
  800ed4:	e8 66 ff ff ff       	call   800e3f <dev_lookup>
  800ed9:	89 c3                	mov    %eax,%ebx
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	78 1a                	js     800efc <fd_close+0x6a>
		if (dev->dev_close)
  800ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ee8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	74 0b                	je     800efc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	56                   	push   %esi
  800ef5:	ff d0                	call   *%eax
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800efc:	83 ec 08             	sub    $0x8,%esp
  800eff:	56                   	push   %esi
  800f00:	6a 00                	push   $0x0
  800f02:	e8 00 fd ff ff       	call   800c07 <sys_page_unmap>
	return r;
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	89 d8                	mov    %ebx,%eax
}
  800f0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1c:	50                   	push   %eax
  800f1d:	ff 75 08             	pushl  0x8(%ebp)
  800f20:	e8 c4 fe ff ff       	call   800de9 <fd_lookup>
  800f25:	83 c4 08             	add    $0x8,%esp
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	78 10                	js     800f3c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f2c:	83 ec 08             	sub    $0x8,%esp
  800f2f:	6a 01                	push   $0x1
  800f31:	ff 75 f4             	pushl  -0xc(%ebp)
  800f34:	e8 59 ff ff ff       	call   800e92 <fd_close>
  800f39:	83 c4 10             	add    $0x10,%esp
}
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <close_all>:

void
close_all(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	53                   	push   %ebx
  800f42:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f45:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	53                   	push   %ebx
  800f4e:	e8 c0 ff ff ff       	call   800f13 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f53:	83 c3 01             	add    $0x1,%ebx
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	83 fb 20             	cmp    $0x20,%ebx
  800f5c:	75 ec                	jne    800f4a <close_all+0xc>
		close(i);
}
  800f5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 2c             	sub    $0x2c,%esp
  800f6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f6f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	ff 75 08             	pushl  0x8(%ebp)
  800f76:	e8 6e fe ff ff       	call   800de9 <fd_lookup>
  800f7b:	83 c4 08             	add    $0x8,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	0f 88 c1 00 00 00    	js     801047 <dup+0xe4>
		return r;
	close(newfdnum);
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	56                   	push   %esi
  800f8a:	e8 84 ff ff ff       	call   800f13 <close>

	newfd = INDEX2FD(newfdnum);
  800f8f:	89 f3                	mov    %esi,%ebx
  800f91:	c1 e3 0c             	shl    $0xc,%ebx
  800f94:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f9a:	83 c4 04             	add    $0x4,%esp
  800f9d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa0:	e8 de fd ff ff       	call   800d83 <fd2data>
  800fa5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fa7:	89 1c 24             	mov    %ebx,(%esp)
  800faa:	e8 d4 fd ff ff       	call   800d83 <fd2data>
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb5:	89 f8                	mov    %edi,%eax
  800fb7:	c1 e8 16             	shr    $0x16,%eax
  800fba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc1:	a8 01                	test   $0x1,%al
  800fc3:	74 37                	je     800ffc <dup+0x99>
  800fc5:	89 f8                	mov    %edi,%eax
  800fc7:	c1 e8 0c             	shr    $0xc,%eax
  800fca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd1:	f6 c2 01             	test   $0x1,%dl
  800fd4:	74 26                	je     800ffc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe5:	50                   	push   %eax
  800fe6:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe9:	6a 00                	push   $0x0
  800feb:	57                   	push   %edi
  800fec:	6a 00                	push   $0x0
  800fee:	e8 d2 fb ff ff       	call   800bc5 <sys_page_map>
  800ff3:	89 c7                	mov    %eax,%edi
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 2e                	js     80102a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fff:	89 d0                	mov    %edx,%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
  801004:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	25 07 0e 00 00       	and    $0xe07,%eax
  801013:	50                   	push   %eax
  801014:	53                   	push   %ebx
  801015:	6a 00                	push   $0x0
  801017:	52                   	push   %edx
  801018:	6a 00                	push   $0x0
  80101a:	e8 a6 fb ff ff       	call   800bc5 <sys_page_map>
  80101f:	89 c7                	mov    %eax,%edi
  801021:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801024:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801026:	85 ff                	test   %edi,%edi
  801028:	79 1d                	jns    801047 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	53                   	push   %ebx
  80102e:	6a 00                	push   $0x0
  801030:	e8 d2 fb ff ff       	call   800c07 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801035:	83 c4 08             	add    $0x8,%esp
  801038:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103b:	6a 00                	push   $0x0
  80103d:	e8 c5 fb ff ff       	call   800c07 <sys_page_unmap>
	return r;
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	89 f8                	mov    %edi,%eax
}
  801047:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 14             	sub    $0x14,%esp
  801056:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801059:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80105c:	50                   	push   %eax
  80105d:	53                   	push   %ebx
  80105e:	e8 86 fd ff ff       	call   800de9 <fd_lookup>
  801063:	83 c4 08             	add    $0x8,%esp
  801066:	89 c2                	mov    %eax,%edx
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 6d                	js     8010d9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106c:	83 ec 08             	sub    $0x8,%esp
  80106f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801072:	50                   	push   %eax
  801073:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801076:	ff 30                	pushl  (%eax)
  801078:	e8 c2 fd ff ff       	call   800e3f <dev_lookup>
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	78 4c                	js     8010d0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801084:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801087:	8b 42 08             	mov    0x8(%edx),%eax
  80108a:	83 e0 03             	and    $0x3,%eax
  80108d:	83 f8 01             	cmp    $0x1,%eax
  801090:	75 21                	jne    8010b3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801092:	a1 08 40 80 00       	mov    0x804008,%eax
  801097:	8b 40 48             	mov    0x48(%eax),%eax
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	53                   	push   %ebx
  80109e:	50                   	push   %eax
  80109f:	68 ed 21 80 00       	push   $0x8021ed
  8010a4:	e8 aa f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010b1:	eb 26                	jmp    8010d9 <read+0x8a>
	}
	if (!dev->dev_read)
  8010b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b6:	8b 40 08             	mov    0x8(%eax),%eax
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	74 17                	je     8010d4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010bd:	83 ec 04             	sub    $0x4,%esp
  8010c0:	ff 75 10             	pushl  0x10(%ebp)
  8010c3:	ff 75 0c             	pushl  0xc(%ebp)
  8010c6:	52                   	push   %edx
  8010c7:	ff d0                	call   *%eax
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	eb 09                	jmp    8010d9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	eb 05                	jmp    8010d9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010d9:	89 d0                	mov    %edx,%eax
  8010db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f4:	eb 21                	jmp    801117 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	89 f0                	mov    %esi,%eax
  8010fb:	29 d8                	sub    %ebx,%eax
  8010fd:	50                   	push   %eax
  8010fe:	89 d8                	mov    %ebx,%eax
  801100:	03 45 0c             	add    0xc(%ebp),%eax
  801103:	50                   	push   %eax
  801104:	57                   	push   %edi
  801105:	e8 45 ff ff ff       	call   80104f <read>
		if (m < 0)
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 10                	js     801121 <readn+0x41>
			return m;
		if (m == 0)
  801111:	85 c0                	test   %eax,%eax
  801113:	74 0a                	je     80111f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801115:	01 c3                	add    %eax,%ebx
  801117:	39 f3                	cmp    %esi,%ebx
  801119:	72 db                	jb     8010f6 <readn+0x16>
  80111b:	89 d8                	mov    %ebx,%eax
  80111d:	eb 02                	jmp    801121 <readn+0x41>
  80111f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	53                   	push   %ebx
  80112d:	83 ec 14             	sub    $0x14,%esp
  801130:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801133:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	53                   	push   %ebx
  801138:	e8 ac fc ff ff       	call   800de9 <fd_lookup>
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	89 c2                	mov    %eax,%edx
  801142:	85 c0                	test   %eax,%eax
  801144:	78 68                	js     8011ae <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801150:	ff 30                	pushl  (%eax)
  801152:	e8 e8 fc ff ff       	call   800e3f <dev_lookup>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 47                	js     8011a5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801161:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801165:	75 21                	jne    801188 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801167:	a1 08 40 80 00       	mov    0x804008,%eax
  80116c:	8b 40 48             	mov    0x48(%eax),%eax
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	53                   	push   %ebx
  801173:	50                   	push   %eax
  801174:	68 09 22 80 00       	push   $0x802209
  801179:	e8 d5 ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801186:	eb 26                	jmp    8011ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801188:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118b:	8b 52 0c             	mov    0xc(%edx),%edx
  80118e:	85 d2                	test   %edx,%edx
  801190:	74 17                	je     8011a9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	ff 75 10             	pushl  0x10(%ebp)
  801198:	ff 75 0c             	pushl  0xc(%ebp)
  80119b:	50                   	push   %eax
  80119c:	ff d2                	call   *%edx
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	eb 09                	jmp    8011ae <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	eb 05                	jmp    8011ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011ae:	89 d0                	mov    %edx,%eax
  8011b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    

008011b5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	ff 75 08             	pushl  0x8(%ebp)
  8011c2:	e8 22 fc ff ff       	call   800de9 <fd_lookup>
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 0e                	js     8011dc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011dc:	c9                   	leave  
  8011dd:	c3                   	ret    

008011de <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 14             	sub    $0x14,%esp
  8011e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011eb:	50                   	push   %eax
  8011ec:	53                   	push   %ebx
  8011ed:	e8 f7 fb ff ff       	call   800de9 <fd_lookup>
  8011f2:	83 c4 08             	add    $0x8,%esp
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 65                	js     801260 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fb:	83 ec 08             	sub    $0x8,%esp
  8011fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	ff 30                	pushl  (%eax)
  801207:	e8 33 fc ff ff       	call   800e3f <dev_lookup>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 44                	js     801257 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121a:	75 21                	jne    80123d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80121c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801221:	8b 40 48             	mov    0x48(%eax),%eax
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	53                   	push   %ebx
  801228:	50                   	push   %eax
  801229:	68 cc 21 80 00       	push   $0x8021cc
  80122e:	e8 20 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80123b:	eb 23                	jmp    801260 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80123d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801240:	8b 52 18             	mov    0x18(%edx),%edx
  801243:	85 d2                	test   %edx,%edx
  801245:	74 14                	je     80125b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801247:	83 ec 08             	sub    $0x8,%esp
  80124a:	ff 75 0c             	pushl  0xc(%ebp)
  80124d:	50                   	push   %eax
  80124e:	ff d2                	call   *%edx
  801250:	89 c2                	mov    %eax,%edx
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	eb 09                	jmp    801260 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801257:	89 c2                	mov    %eax,%edx
  801259:	eb 05                	jmp    801260 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80125b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801260:	89 d0                	mov    %edx,%eax
  801262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	53                   	push   %ebx
  80126b:	83 ec 14             	sub    $0x14,%esp
  80126e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801271:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	ff 75 08             	pushl  0x8(%ebp)
  801278:	e8 6c fb ff ff       	call   800de9 <fd_lookup>
  80127d:	83 c4 08             	add    $0x8,%esp
  801280:	89 c2                	mov    %eax,%edx
  801282:	85 c0                	test   %eax,%eax
  801284:	78 58                	js     8012de <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128c:	50                   	push   %eax
  80128d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801290:	ff 30                	pushl  (%eax)
  801292:	e8 a8 fb ff ff       	call   800e3f <dev_lookup>
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 37                	js     8012d5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80129e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a5:	74 32                	je     8012d9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b1:	00 00 00 
	stat->st_isdir = 0;
  8012b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012bb:	00 00 00 
	stat->st_dev = dev;
  8012be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	53                   	push   %ebx
  8012c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8012cb:	ff 50 14             	call   *0x14(%eax)
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	eb 09                	jmp    8012de <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	eb 05                	jmp    8012de <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012de:	89 d0                	mov    %edx,%eax
  8012e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	6a 00                	push   $0x0
  8012ef:	ff 75 08             	pushl  0x8(%ebp)
  8012f2:	e8 b7 01 00 00       	call   8014ae <open>
  8012f7:	89 c3                	mov    %eax,%ebx
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 1b                	js     80131b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	ff 75 0c             	pushl  0xc(%ebp)
  801306:	50                   	push   %eax
  801307:	e8 5b ff ff ff       	call   801267 <fstat>
  80130c:	89 c6                	mov    %eax,%esi
	close(fd);
  80130e:	89 1c 24             	mov    %ebx,(%esp)
  801311:	e8 fd fb ff ff       	call   800f13 <close>
	return r;
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	89 f0                	mov    %esi,%eax
}
  80131b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
  801327:	89 c6                	mov    %eax,%esi
  801329:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80132b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801332:	75 12                	jne    801346 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	6a 01                	push   $0x1
  801339:	e8 02 08 00 00       	call   801b40 <ipc_find_env>
  80133e:	a3 00 40 80 00       	mov    %eax,0x804000
  801343:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801346:	6a 07                	push   $0x7
  801348:	68 00 50 80 00       	push   $0x805000
  80134d:	56                   	push   %esi
  80134e:	ff 35 00 40 80 00    	pushl  0x804000
  801354:	e8 93 07 00 00       	call   801aec <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801359:	83 c4 0c             	add    $0xc,%esp
  80135c:	6a 00                	push   $0x0
  80135e:	53                   	push   %ebx
  80135f:	6a 00                	push   $0x0
  801361:	e8 11 07 00 00       	call   801a77 <ipc_recv>
}
  801366:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801369:	5b                   	pop    %ebx
  80136a:	5e                   	pop    %esi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801373:	8b 45 08             	mov    0x8(%ebp),%eax
  801376:	8b 40 0c             	mov    0xc(%eax),%eax
  801379:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80137e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801381:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801386:	ba 00 00 00 00       	mov    $0x0,%edx
  80138b:	b8 02 00 00 00       	mov    $0x2,%eax
  801390:	e8 8d ff ff ff       	call   801322 <fsipc>
}
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80139d:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b2:	e8 6b ff ff ff       	call   801322 <fsipc>
}
  8013b7:	c9                   	leave  
  8013b8:	c3                   	ret    

008013b9 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d8:	e8 45 ff ff ff       	call   801322 <fsipc>
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 2c                	js     80140d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	68 00 50 80 00       	push   $0x805000
  8013e9:	53                   	push   %ebx
  8013ea:	e8 90 f3 ff ff       	call   80077f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8013ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801418:	68 38 22 80 00       	push   $0x802238
  80141d:	68 90 00 00 00       	push   $0x90
  801422:	68 56 22 80 00       	push   $0x802256
  801427:	e8 05 06 00 00       	call   801a31 <_panic>

0080142c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80143f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801445:	ba 00 00 00 00       	mov    $0x0,%edx
  80144a:	b8 03 00 00 00       	mov    $0x3,%eax
  80144f:	e8 ce fe ff ff       	call   801322 <fsipc>
  801454:	89 c3                	mov    %eax,%ebx
  801456:	85 c0                	test   %eax,%eax
  801458:	78 4b                	js     8014a5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80145a:	39 c6                	cmp    %eax,%esi
  80145c:	73 16                	jae    801474 <devfile_read+0x48>
  80145e:	68 61 22 80 00       	push   $0x802261
  801463:	68 68 22 80 00       	push   $0x802268
  801468:	6a 7c                	push   $0x7c
  80146a:	68 56 22 80 00       	push   $0x802256
  80146f:	e8 bd 05 00 00       	call   801a31 <_panic>
	assert(r <= PGSIZE);
  801474:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801479:	7e 16                	jle    801491 <devfile_read+0x65>
  80147b:	68 7d 22 80 00       	push   $0x80227d
  801480:	68 68 22 80 00       	push   $0x802268
  801485:	6a 7d                	push   $0x7d
  801487:	68 56 22 80 00       	push   $0x802256
  80148c:	e8 a0 05 00 00       	call   801a31 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	50                   	push   %eax
  801495:	68 00 50 80 00       	push   $0x805000
  80149a:	ff 75 0c             	pushl  0xc(%ebp)
  80149d:	e8 6f f4 ff ff       	call   800911 <memmove>
	return r;
  8014a2:	83 c4 10             	add    $0x10,%esp
}
  8014a5:	89 d8                	mov    %ebx,%eax
  8014a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5d                   	pop    %ebp
  8014ad:	c3                   	ret    

008014ae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 20             	sub    $0x20,%esp
  8014b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014b8:	53                   	push   %ebx
  8014b9:	e8 88 f2 ff ff       	call   800746 <strlen>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c6:	7f 67                	jg     80152f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	e8 c6 f8 ff ff       	call   800d9a <fd_alloc>
  8014d4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014d7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 57                	js     801534 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	68 00 50 80 00       	push   $0x805000
  8014e6:	e8 94 f2 ff ff       	call   80077f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ee:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fb:	e8 22 fe ff ff       	call   801322 <fsipc>
  801500:	89 c3                	mov    %eax,%ebx
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	85 c0                	test   %eax,%eax
  801507:	79 14                	jns    80151d <open+0x6f>
		fd_close(fd, 0);
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	6a 00                	push   $0x0
  80150e:	ff 75 f4             	pushl  -0xc(%ebp)
  801511:	e8 7c f9 ff ff       	call   800e92 <fd_close>
		return r;
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	89 da                	mov    %ebx,%edx
  80151b:	eb 17                	jmp    801534 <open+0x86>
	}

	return fd2num(fd);
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	ff 75 f4             	pushl  -0xc(%ebp)
  801523:	e8 4b f8 ff ff       	call   800d73 <fd2num>
  801528:	89 c2                	mov    %eax,%edx
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	eb 05                	jmp    801534 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80152f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801534:	89 d0                	mov    %edx,%eax
  801536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 08 00 00 00       	mov    $0x8,%eax
  80154b:	e8 d2 fd ff ff       	call   801322 <fsipc>
}
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	56                   	push   %esi
  801556:	53                   	push   %ebx
  801557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	ff 75 08             	pushl  0x8(%ebp)
  801560:	e8 1e f8 ff ff       	call   800d83 <fd2data>
  801565:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	68 89 22 80 00       	push   $0x802289
  80156f:	53                   	push   %ebx
  801570:	e8 0a f2 ff ff       	call   80077f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801575:	8b 46 04             	mov    0x4(%esi),%eax
  801578:	2b 06                	sub    (%esi),%eax
  80157a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801580:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801587:	00 00 00 
	stat->st_dev = &devpipe;
  80158a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801591:	30 80 00 
	return 0;
}
  801594:	b8 00 00 00 00       	mov    $0x0,%eax
  801599:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159c:	5b                   	pop    %ebx
  80159d:	5e                   	pop    %esi
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    

008015a0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	53                   	push   %ebx
  8015a4:	83 ec 0c             	sub    $0xc,%esp
  8015a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015aa:	53                   	push   %ebx
  8015ab:	6a 00                	push   $0x0
  8015ad:	e8 55 f6 ff ff       	call   800c07 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b2:	89 1c 24             	mov    %ebx,(%esp)
  8015b5:	e8 c9 f7 ff ff       	call   800d83 <fd2data>
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	50                   	push   %eax
  8015be:	6a 00                	push   $0x0
  8015c0:	e8 42 f6 ff ff       	call   800c07 <sys_page_unmap>
}
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 1c             	sub    $0x1c,%esp
  8015d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015d6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015d8:	a1 08 40 80 00       	mov    0x804008,%eax
  8015dd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e6:	e8 8e 05 00 00       	call   801b79 <pageref>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	89 3c 24             	mov    %edi,(%esp)
  8015f0:	e8 84 05 00 00       	call   801b79 <pageref>
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	39 c3                	cmp    %eax,%ebx
  8015fa:	0f 94 c1             	sete   %cl
  8015fd:	0f b6 c9             	movzbl %cl,%ecx
  801600:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801603:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801609:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80160c:	39 ce                	cmp    %ecx,%esi
  80160e:	74 1b                	je     80162b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801610:	39 c3                	cmp    %eax,%ebx
  801612:	75 c4                	jne    8015d8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801614:	8b 42 58             	mov    0x58(%edx),%eax
  801617:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161a:	50                   	push   %eax
  80161b:	56                   	push   %esi
  80161c:	68 90 22 80 00       	push   $0x802290
  801621:	e8 2d eb ff ff       	call   800153 <cprintf>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	eb ad                	jmp    8015d8 <_pipeisclosed+0xe>
	}
}
  80162b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	57                   	push   %edi
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
  80163c:	83 ec 28             	sub    $0x28,%esp
  80163f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801642:	56                   	push   %esi
  801643:	e8 3b f7 ff ff       	call   800d83 <fd2data>
  801648:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	bf 00 00 00 00       	mov    $0x0,%edi
  801652:	eb 4b                	jmp    80169f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801654:	89 da                	mov    %ebx,%edx
  801656:	89 f0                	mov    %esi,%eax
  801658:	e8 6d ff ff ff       	call   8015ca <_pipeisclosed>
  80165d:	85 c0                	test   %eax,%eax
  80165f:	75 48                	jne    8016a9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801661:	e8 fd f4 ff ff       	call   800b63 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801666:	8b 43 04             	mov    0x4(%ebx),%eax
  801669:	8b 0b                	mov    (%ebx),%ecx
  80166b:	8d 51 20             	lea    0x20(%ecx),%edx
  80166e:	39 d0                	cmp    %edx,%eax
  801670:	73 e2                	jae    801654 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801672:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801675:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801679:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	c1 fa 1f             	sar    $0x1f,%edx
  801681:	89 d1                	mov    %edx,%ecx
  801683:	c1 e9 1b             	shr    $0x1b,%ecx
  801686:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801689:	83 e2 1f             	and    $0x1f,%edx
  80168c:	29 ca                	sub    %ecx,%edx
  80168e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801692:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801696:	83 c0 01             	add    $0x1,%eax
  801699:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169c:	83 c7 01             	add    $0x1,%edi
  80169f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016a2:	75 c2                	jne    801666 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016a7:	eb 05                	jmp    8016ae <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016a9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5e                   	pop    %esi
  8016b3:	5f                   	pop    %edi
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	57                   	push   %edi
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
  8016bc:	83 ec 18             	sub    $0x18,%esp
  8016bf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016c2:	57                   	push   %edi
  8016c3:	e8 bb f6 ff ff       	call   800d83 <fd2data>
  8016c8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d2:	eb 3d                	jmp    801711 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016d4:	85 db                	test   %ebx,%ebx
  8016d6:	74 04                	je     8016dc <devpipe_read+0x26>
				return i;
  8016d8:	89 d8                	mov    %ebx,%eax
  8016da:	eb 44                	jmp    801720 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016dc:	89 f2                	mov    %esi,%edx
  8016de:	89 f8                	mov    %edi,%eax
  8016e0:	e8 e5 fe ff ff       	call   8015ca <_pipeisclosed>
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	75 32                	jne    80171b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016e9:	e8 75 f4 ff ff       	call   800b63 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016ee:	8b 06                	mov    (%esi),%eax
  8016f0:	3b 46 04             	cmp    0x4(%esi),%eax
  8016f3:	74 df                	je     8016d4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016f5:	99                   	cltd   
  8016f6:	c1 ea 1b             	shr    $0x1b,%edx
  8016f9:	01 d0                	add    %edx,%eax
  8016fb:	83 e0 1f             	and    $0x1f,%eax
  8016fe:	29 d0                	sub    %edx,%eax
  801700:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801705:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801708:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80170b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170e:	83 c3 01             	add    $0x1,%ebx
  801711:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801714:	75 d8                	jne    8016ee <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801716:	8b 45 10             	mov    0x10(%ebp),%eax
  801719:	eb 05                	jmp    801720 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80171b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5f                   	pop    %edi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801730:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801733:	50                   	push   %eax
  801734:	e8 61 f6 ff ff       	call   800d9a <fd_alloc>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	85 c0                	test   %eax,%eax
  801740:	0f 88 2c 01 00 00    	js     801872 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	68 07 04 00 00       	push   $0x407
  80174e:	ff 75 f4             	pushl  -0xc(%ebp)
  801751:	6a 00                	push   $0x0
  801753:	e8 2a f4 ff ff       	call   800b82 <sys_page_alloc>
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	89 c2                	mov    %eax,%edx
  80175d:	85 c0                	test   %eax,%eax
  80175f:	0f 88 0d 01 00 00    	js     801872 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	e8 29 f6 ff ff       	call   800d9a <fd_alloc>
  801771:	89 c3                	mov    %eax,%ebx
  801773:	83 c4 10             	add    $0x10,%esp
  801776:	85 c0                	test   %eax,%eax
  801778:	0f 88 e2 00 00 00    	js     801860 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177e:	83 ec 04             	sub    $0x4,%esp
  801781:	68 07 04 00 00       	push   $0x407
  801786:	ff 75 f0             	pushl  -0x10(%ebp)
  801789:	6a 00                	push   $0x0
  80178b:	e8 f2 f3 ff ff       	call   800b82 <sys_page_alloc>
  801790:	89 c3                	mov    %eax,%ebx
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	0f 88 c3 00 00 00    	js     801860 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a3:	e8 db f5 ff ff       	call   800d83 <fd2data>
  8017a8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017aa:	83 c4 0c             	add    $0xc,%esp
  8017ad:	68 07 04 00 00       	push   $0x407
  8017b2:	50                   	push   %eax
  8017b3:	6a 00                	push   $0x0
  8017b5:	e8 c8 f3 ff ff       	call   800b82 <sys_page_alloc>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	0f 88 89 00 00 00    	js     801850 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cd:	e8 b1 f5 ff ff       	call   800d83 <fd2data>
  8017d2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017d9:	50                   	push   %eax
  8017da:	6a 00                	push   $0x0
  8017dc:	56                   	push   %esi
  8017dd:	6a 00                	push   $0x0
  8017df:	e8 e1 f3 ff ff       	call   800bc5 <sys_page_map>
  8017e4:	89 c3                	mov    %eax,%ebx
  8017e6:	83 c4 20             	add    $0x20,%esp
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 55                	js     801842 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017ed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801802:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801808:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801810:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801817:	83 ec 0c             	sub    $0xc,%esp
  80181a:	ff 75 f4             	pushl  -0xc(%ebp)
  80181d:	e8 51 f5 ff ff       	call   800d73 <fd2num>
  801822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801825:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801827:	83 c4 04             	add    $0x4,%esp
  80182a:	ff 75 f0             	pushl  -0x10(%ebp)
  80182d:	e8 41 f5 ff ff       	call   800d73 <fd2num>
  801832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801835:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	eb 30                	jmp    801872 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	56                   	push   %esi
  801846:	6a 00                	push   $0x0
  801848:	e8 ba f3 ff ff       	call   800c07 <sys_page_unmap>
  80184d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	ff 75 f0             	pushl  -0x10(%ebp)
  801856:	6a 00                	push   $0x0
  801858:	e8 aa f3 ff ff       	call   800c07 <sys_page_unmap>
  80185d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	ff 75 f4             	pushl  -0xc(%ebp)
  801866:	6a 00                	push   $0x0
  801868:	e8 9a f3 ff ff       	call   800c07 <sys_page_unmap>
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801872:	89 d0                	mov    %edx,%eax
  801874:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801881:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801884:	50                   	push   %eax
  801885:	ff 75 08             	pushl  0x8(%ebp)
  801888:	e8 5c f5 ff ff       	call   800de9 <fd_lookup>
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	78 18                	js     8018ac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	ff 75 f4             	pushl  -0xc(%ebp)
  80189a:	e8 e4 f4 ff ff       	call   800d83 <fd2data>
	return _pipeisclosed(fd, p);
  80189f:	89 c2                	mov    %eax,%edx
  8018a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a4:	e8 21 fd ff ff       	call   8015ca <_pipeisclosed>
  8018a9:	83 c4 10             	add    $0x10,%esp
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018be:	68 a8 22 80 00       	push   $0x8022a8
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	e8 b4 ee ff ff       	call   80077f <strcpy>
	return 0;
}
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	57                   	push   %edi
  8018d6:	56                   	push   %esi
  8018d7:	53                   	push   %ebx
  8018d8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018de:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e9:	eb 2d                	jmp    801918 <devcons_write+0x46>
		m = n - tot;
  8018eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018ee:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018f0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018f3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018f8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	53                   	push   %ebx
  8018ff:	03 45 0c             	add    0xc(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	57                   	push   %edi
  801904:	e8 08 f0 ff ff       	call   800911 <memmove>
		sys_cputs(buf, m);
  801909:	83 c4 08             	add    $0x8,%esp
  80190c:	53                   	push   %ebx
  80190d:	57                   	push   %edi
  80190e:	e8 b3 f1 ff ff       	call   800ac6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801913:	01 de                	add    %ebx,%esi
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	89 f0                	mov    %esi,%eax
  80191a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80191d:	72 cc                	jb     8018eb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80191f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5f                   	pop    %edi
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801932:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801936:	74 2a                	je     801962 <devcons_read+0x3b>
  801938:	eb 05                	jmp    80193f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80193a:	e8 24 f2 ff ff       	call   800b63 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80193f:	e8 a0 f1 ff ff       	call   800ae4 <sys_cgetc>
  801944:	85 c0                	test   %eax,%eax
  801946:	74 f2                	je     80193a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 16                	js     801962 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80194c:	83 f8 04             	cmp    $0x4,%eax
  80194f:	74 0c                	je     80195d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801951:	8b 55 0c             	mov    0xc(%ebp),%edx
  801954:	88 02                	mov    %al,(%edx)
	return 1;
  801956:	b8 01 00 00 00       	mov    $0x1,%eax
  80195b:	eb 05                	jmp    801962 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80196a:	8b 45 08             	mov    0x8(%ebp),%eax
  80196d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801970:	6a 01                	push   $0x1
  801972:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801975:	50                   	push   %eax
  801976:	e8 4b f1 ff ff       	call   800ac6 <sys_cputs>
}
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <getchar>:

int
getchar(void)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801986:	6a 01                	push   $0x1
  801988:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80198b:	50                   	push   %eax
  80198c:	6a 00                	push   $0x0
  80198e:	e8 bc f6 ff ff       	call   80104f <read>
	if (r < 0)
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	85 c0                	test   %eax,%eax
  801998:	78 0f                	js     8019a9 <getchar+0x29>
		return r;
	if (r < 1)
  80199a:	85 c0                	test   %eax,%eax
  80199c:	7e 06                	jle    8019a4 <getchar+0x24>
		return -E_EOF;
	return c;
  80199e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a2:	eb 05                	jmp    8019a9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b4:	50                   	push   %eax
  8019b5:	ff 75 08             	pushl  0x8(%ebp)
  8019b8:	e8 2c f4 ff ff       	call   800de9 <fd_lookup>
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 11                	js     8019d5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019cd:	39 10                	cmp    %edx,(%eax)
  8019cf:	0f 94 c0             	sete   %al
  8019d2:	0f b6 c0             	movzbl %al,%eax
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <opencons>:

int
opencons(void)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e0:	50                   	push   %eax
  8019e1:	e8 b4 f3 ff ff       	call   800d9a <fd_alloc>
  8019e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 3e                	js     801a2d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ef:	83 ec 04             	sub    $0x4,%esp
  8019f2:	68 07 04 00 00       	push   $0x407
  8019f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fa:	6a 00                	push   $0x0
  8019fc:	e8 81 f1 ff ff       	call   800b82 <sys_page_alloc>
  801a01:	83 c4 10             	add    $0x10,%esp
		return r;
  801a04:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 23                	js     801a2d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a13:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a18:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	50                   	push   %eax
  801a23:	e8 4b f3 ff ff       	call   800d73 <fd2num>
  801a28:	89 c2                	mov    %eax,%edx
  801a2a:	83 c4 10             	add    $0x10,%esp
}
  801a2d:	89 d0                	mov    %edx,%eax
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a36:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a39:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a3f:	e8 00 f1 ff ff       	call   800b44 <sys_getenvid>
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	ff 75 08             	pushl  0x8(%ebp)
  801a4d:	56                   	push   %esi
  801a4e:	50                   	push   %eax
  801a4f:	68 b4 22 80 00       	push   $0x8022b4
  801a54:	e8 fa e6 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a59:	83 c4 18             	add    $0x18,%esp
  801a5c:	53                   	push   %ebx
  801a5d:	ff 75 10             	pushl  0x10(%ebp)
  801a60:	e8 9d e6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801a65:	c7 04 24 6c 1e 80 00 	movl   $0x801e6c,(%esp)
  801a6c:	e8 e2 e6 ff ff       	call   800153 <cprintf>
  801a71:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a74:	cc                   	int3   
  801a75:	eb fd                	jmp    801a74 <_panic+0x43>

00801a77 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a85:	85 c0                	test   %eax,%eax
  801a87:	74 0e                	je     801a97 <ipc_recv+0x20>
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	50                   	push   %eax
  801a8d:	e8 a0 f2 ff ff       	call   800d32 <sys_ipc_recv>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb 10                	jmp    801aa7 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	68 00 00 c0 ee       	push   $0xeec00000
  801a9f:	e8 8e f2 ff ff       	call   800d32 <sys_ipc_recv>
  801aa4:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	74 16                	je     801ac1 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801aab:	85 f6                	test   %esi,%esi
  801aad:	74 06                	je     801ab5 <ipc_recv+0x3e>
  801aaf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801ab5:	85 db                	test   %ebx,%ebx
  801ab7:	74 2c                	je     801ae5 <ipc_recv+0x6e>
  801ab9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801abf:	eb 24                	jmp    801ae5 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ac1:	85 f6                	test   %esi,%esi
  801ac3:	74 0a                	je     801acf <ipc_recv+0x58>
  801ac5:	a1 08 40 80 00       	mov    0x804008,%eax
  801aca:	8b 40 74             	mov    0x74(%eax),%eax
  801acd:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	74 0a                	je     801add <ipc_recv+0x66>
  801ad3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ad8:	8b 40 78             	mov    0x78(%eax),%eax
  801adb:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801add:	a1 08 40 80 00       	mov    0x804008,%eax
  801ae2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	57                   	push   %edi
  801af0:	56                   	push   %esi
  801af1:	53                   	push   %ebx
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801afb:	8b 45 10             	mov    0x10(%ebp),%eax
  801afe:	85 c0                	test   %eax,%eax
  801b00:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b05:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b08:	ff 75 14             	pushl  0x14(%ebp)
  801b0b:	53                   	push   %ebx
  801b0c:	56                   	push   %esi
  801b0d:	57                   	push   %edi
  801b0e:	e8 fc f1 ff ff       	call   800d0f <sys_ipc_try_send>
		if (ret == 0) break;
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	74 1e                	je     801b38 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b1a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b1d:	74 12                	je     801b31 <ipc_send+0x45>
  801b1f:	50                   	push   %eax
  801b20:	68 d8 22 80 00       	push   $0x8022d8
  801b25:	6a 39                	push   $0x39
  801b27:	68 e5 22 80 00       	push   $0x8022e5
  801b2c:	e8 00 ff ff ff       	call   801a31 <_panic>
		sys_yield();
  801b31:	e8 2d f0 ff ff       	call   800b63 <sys_yield>
	}
  801b36:	eb d0                	jmp    801b08 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3b:	5b                   	pop    %ebx
  801b3c:	5e                   	pop    %esi
  801b3d:	5f                   	pop    %edi
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    

00801b40 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b4b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b4e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b54:	8b 52 50             	mov    0x50(%edx),%edx
  801b57:	39 ca                	cmp    %ecx,%edx
  801b59:	75 0d                	jne    801b68 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b5b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b5e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b63:	8b 40 48             	mov    0x48(%eax),%eax
  801b66:	eb 0f                	jmp    801b77 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b68:	83 c0 01             	add    $0x1,%eax
  801b6b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b70:	75 d9                	jne    801b4b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7f:	89 d0                	mov    %edx,%eax
  801b81:	c1 e8 16             	shr    $0x16,%eax
  801b84:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b90:	f6 c1 01             	test   $0x1,%cl
  801b93:	74 1d                	je     801bb2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b95:	c1 ea 0c             	shr    $0xc,%edx
  801b98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9f:	f6 c2 01             	test   $0x1,%dl
  801ba2:	74 0e                	je     801bb2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba4:	c1 ea 0c             	shr    $0xc,%edx
  801ba7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bae:	ef 
  801baf:	0f b7 c0             	movzwl %ax,%eax
}
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    
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
