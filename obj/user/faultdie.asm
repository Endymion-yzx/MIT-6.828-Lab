
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 e0 1e 80 00       	push   $0x801ee0
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 10 0b 00 00       	call   800b64 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 c7 0a 00 00       	call   800b23 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 22 0d 00 00       	call   800d93 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  80008b:	e8 d4 0a 00 00       	call   800b64 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 fd 0e 00 00       	call   800fce <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 48 0a 00 00       	call   800b23 <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 d6 09 00 00       	call   800ae6 <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 1a 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 7b 09 00 00       	call   800ae6 <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 75 1a 00 00       	call   801c50 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 62 1b 00 00       	call   801d80 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 06 1f 80 00 	movsbl 0x801f06(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	eb 12                	jmp    800296 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800284:	85 c0                	test   %eax,%eax
  800286:	0f 84 6a 04 00 00    	je     8006f6 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	ff d6                	call   *%esi
  800293:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800296:	83 c7 01             	add    $0x1,%edi
  800299:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029d:	83 f8 25             	cmp    $0x25,%eax
  8002a0:	75 e2                	jne    800284 <vprintfmt+0x14>
  8002a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c0:	eb 07                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cf:	0f b6 07             	movzbl (%edi),%eax
  8002d2:	0f b6 d0             	movzbl %al,%edx
  8002d5:	83 e8 23             	sub    $0x23,%eax
  8002d8:	3c 55                	cmp    $0x55,%al
  8002da:	0f 87 fb 03 00 00    	ja     8006db <vprintfmt+0x46b>
  8002e0:	0f b6 c0             	movzbl %al,%eax
  8002e3:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f1:	eb d6                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800308:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030b:	83 f9 09             	cmp    $0x9,%ecx
  80030e:	77 3f                	ja     80034f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8b 00                	mov    (%eax),%eax
  80031a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 40 04             	lea    0x4(%eax),%eax
  800323:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800329:	eb 2a                	jmp    800355 <vprintfmt+0xe5>
  80032b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032e:	85 c0                	test   %eax,%eax
  800330:	ba 00 00 00 00       	mov    $0x0,%edx
  800335:	0f 49 d0             	cmovns %eax,%edx
  800338:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033e:	eb 89                	jmp    8002c9 <vprintfmt+0x59>
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800343:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034a:	e9 7a ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
  80034f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800352:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800355:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800359:	0f 89 6a ff ff ff    	jns    8002c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  80035f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	e9 58 ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800371:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800377:	e9 4d ff ff ff       	jmp    8002c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 78 04             	lea    0x4(%eax),%edi
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	53                   	push   %ebx
  800386:	ff 30                	pushl  (%eax)
  800388:	ff d6                	call   *%esi
			break;
  80038a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800393:	e9 fe fe ff ff       	jmp    800296 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 78 04             	lea    0x4(%eax),%edi
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	99                   	cltd   
  8003a1:	31 d0                	xor    %edx,%eax
  8003a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a5:	83 f8 0f             	cmp    $0xf,%eax
  8003a8:	7f 0b                	jg     8003b5 <vprintfmt+0x145>
  8003aa:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	75 1b                	jne    8003d0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003b5:	50                   	push   %eax
  8003b6:	68 1e 1f 80 00       	push   $0x801f1e
  8003bb:	53                   	push   %ebx
  8003bc:	56                   	push   %esi
  8003bd:	e8 91 fe ff ff       	call   800253 <printfmt>
  8003c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cb:	e9 c6 fe ff ff       	jmp    800296 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d0:	52                   	push   %edx
  8003d1:	68 fa 22 80 00       	push   $0x8022fa
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 76 fe ff ff       	call   800253 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	e9 ab fe ff ff       	jmp    800296 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	83 c0 04             	add    $0x4,%eax
  8003f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f9:	85 ff                	test   %edi,%edi
  8003fb:	b8 17 1f 80 00       	mov    $0x801f17,%eax
  800400:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800403:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800407:	0f 8e 94 00 00 00    	jle    8004a1 <vprintfmt+0x231>
  80040d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800411:	0f 84 98 00 00 00    	je     8004af <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d0             	pushl  -0x30(%ebp)
  80041d:	57                   	push   %edi
  80041e:	e8 5b 03 00 00       	call   80077e <strnlen>
  800423:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800426:	29 c1                	sub    %eax,%ecx
  800428:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80042b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800438:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	eb 0f                	jmp    80044b <vprintfmt+0x1db>
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ef 01             	sub    $0x1,%edi
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	85 ff                	test   %edi,%edi
  80044d:	7f ed                	jg     80043c <vprintfmt+0x1cc>
  80044f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800452:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800455:	85 c9                	test   %ecx,%ecx
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	0f 49 c1             	cmovns %ecx,%eax
  80045f:	29 c1                	sub    %eax,%ecx
  800461:	89 75 08             	mov    %esi,0x8(%ebp)
  800464:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800467:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046a:	89 cb                	mov    %ecx,%ebx
  80046c:	eb 4d                	jmp    8004bb <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800472:	74 1b                	je     80048f <vprintfmt+0x21f>
  800474:	0f be c0             	movsbl %al,%eax
  800477:	83 e8 20             	sub    $0x20,%eax
  80047a:	83 f8 5e             	cmp    $0x5e,%eax
  80047d:	76 10                	jbe    80048f <vprintfmt+0x21f>
					putch('?', putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	ff 75 0c             	pushl  0xc(%ebp)
  800485:	6a 3f                	push   $0x3f
  800487:	ff 55 08             	call   *0x8(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb 0d                	jmp    80049c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	52                   	push   %edx
  800496:	ff 55 08             	call   *0x8(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	eb 1a                	jmp    8004bb <vprintfmt+0x24b>
  8004a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ad:	eb 0c                	jmp    8004bb <vprintfmt+0x24b>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	83 c7 01             	add    $0x1,%edi
  8004be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c2:	0f be d0             	movsbl %al,%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	74 23                	je     8004ec <vprintfmt+0x27c>
  8004c9:	85 f6                	test   %esi,%esi
  8004cb:	78 a1                	js     80046e <vprintfmt+0x1fe>
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	79 9c                	jns    80046e <vprintfmt+0x1fe>
  8004d2:	89 df                	mov    %ebx,%edi
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	eb 18                	jmp    8004f4 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	6a 20                	push   $0x20
  8004e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e4:	83 ef 01             	sub    $0x1,%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	eb 08                	jmp    8004f4 <vprintfmt+0x284>
  8004ec:	89 df                	mov    %ebx,%edi
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f e4                	jg     8004dc <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 90 fd ff ff       	jmp    800296 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 f9 01             	cmp    $0x1,%ecx
  800509:	7e 19                	jle    800524 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 08             	lea    0x8(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
  800522:	eb 38                	jmp    80055c <vprintfmt+0x2ec>
	else if (lflag)
  800524:	85 c9                	test   %ecx,%ecx
  800526:	74 1b                	je     800543 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800530:	89 c1                	mov    %eax,%ecx
  800532:	c1 f9 1f             	sar    $0x1f,%ecx
  800535:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 40 04             	lea    0x4(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	eb 19                	jmp    80055c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 40 04             	lea    0x4(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800567:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056b:	0f 89 36 01 00 00    	jns    8006a7 <vprintfmt+0x437>
				putch('-', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	53                   	push   %ebx
  800575:	6a 2d                	push   $0x2d
  800577:	ff d6                	call   *%esi
				num = -(long long) num;
  800579:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057f:	f7 da                	neg    %edx
  800581:	83 d1 00             	adc    $0x0,%ecx
  800584:	f7 d9                	neg    %ecx
  800586:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	e9 14 01 00 00       	jmp    8006a7 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7e 18                	jle    8005b0 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a0:	8d 40 08             	lea    0x8(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 f7 00 00 00       	jmp    8006a7 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005b0:	85 c9                	test   %ecx,%ecx
  8005b2:	74 1a                	je     8005ce <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	e9 d9 00 00 00       	jmp    8006a7 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 bf 00 00 00       	jmp    8006a7 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e8:	83 f9 01             	cmp    $0x1,%ecx
  8005eb:	7e 13                	jle    800600 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 50 04             	mov    0x4(%eax),%edx
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8005f8:	8d 49 08             	lea    0x8(%ecx),%ecx
  8005fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fe:	eb 28                	jmp    800628 <vprintfmt+0x3b8>
	else if (lflag)
  800600:	85 c9                	test   %ecx,%ecx
  800602:	74 13                	je     800617 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	89 d0                	mov    %edx,%eax
  80060b:	99                   	cltd   
  80060c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80060f:	8d 49 04             	lea    0x4(%ecx),%ecx
  800612:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800615:	eb 11                	jmp    800628 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	89 d0                	mov    %edx,%eax
  80061e:	99                   	cltd   
  80061f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800622:	8d 49 04             	lea    0x4(%ecx),%ecx
  800625:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800628:	89 d1                	mov    %edx,%ecx
  80062a:	89 c2                	mov    %eax,%edx
			base = 8;
  80062c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800631:	eb 74                	jmp    8006a7 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 30                	push   $0x30
  800639:	ff d6                	call   *%esi
			putch('x', putdat);
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	6a 78                	push   $0x78
  800641:	ff d6                	call   *%esi
			num = (unsigned long long)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800656:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065b:	eb 4a                	jmp    8006a7 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065d:	83 f9 01             	cmp    $0x1,%ecx
  800660:	7e 15                	jle    800677 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 10                	mov    (%eax),%edx
  800667:	8b 48 04             	mov    0x4(%eax),%ecx
  80066a:	8d 40 08             	lea    0x8(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
  800675:	eb 30                	jmp    8006a7 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800677:	85 c9                	test   %ecx,%ecx
  800679:	74 17                	je     800692 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	b9 00 00 00 00       	mov    $0x0,%ecx
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
  800690:	eb 15                	jmp    8006a7 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a7:	83 ec 0c             	sub    $0xc,%esp
  8006aa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ae:	57                   	push   %edi
  8006af:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b2:	50                   	push   %eax
  8006b3:	51                   	push   %ecx
  8006b4:	52                   	push   %edx
  8006b5:	89 da                	mov    %ebx,%edx
  8006b7:	89 f0                	mov    %esi,%eax
  8006b9:	e8 c9 fa ff ff       	call   800187 <printnum>
			break;
  8006be:	83 c4 20             	add    $0x20,%esp
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c4:	e9 cd fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	52                   	push   %edx
  8006ce:	ff d6                	call   *%esi
			break;
  8006d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d6:	e9 bb fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	6a 25                	push   $0x25
  8006e1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	eb 03                	jmp    8006eb <vprintfmt+0x47b>
  8006e8:	83 ef 01             	sub    $0x1,%edi
  8006eb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ef:	75 f7                	jne    8006e8 <vprintfmt+0x478>
  8006f1:	e9 a0 fb ff ff       	jmp    800296 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f9:	5b                   	pop    %ebx
  8006fa:	5e                   	pop    %esi
  8006fb:	5f                   	pop    %edi
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	83 ec 18             	sub    $0x18,%esp
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800711:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	74 26                	je     800745 <vsnprintf+0x47>
  80071f:	85 d2                	test   %edx,%edx
  800721:	7e 22                	jle    800745 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800723:	ff 75 14             	pushl  0x14(%ebp)
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072c:	50                   	push   %eax
  80072d:	68 36 02 80 00       	push   $0x800236
  800732:	e8 39 fb ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800737:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb 05                	jmp    80074a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800755:	50                   	push   %eax
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	ff 75 08             	pushl  0x8(%ebp)
  80075f:	e8 9a ff ff ff       	call   8006fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076c:	b8 00 00 00 00       	mov    $0x0,%eax
  800771:	eb 03                	jmp    800776 <strlen+0x10>
		n++;
  800773:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077a:	75 f7                	jne    800773 <strlen+0xd>
		n++;
	return n;
}
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800784:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800787:	ba 00 00 00 00       	mov    $0x0,%edx
  80078c:	eb 03                	jmp    800791 <strnlen+0x13>
		n++;
  80078e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	39 c2                	cmp    %eax,%edx
  800793:	74 08                	je     80079d <strnlen+0x1f>
  800795:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800799:	75 f3                	jne    80078e <strnlen+0x10>
  80079b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a9:	89 c2                	mov    %eax,%edx
  8007ab:	83 c2 01             	add    $0x1,%edx
  8007ae:	83 c1 01             	add    $0x1,%ecx
  8007b1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b8:	84 db                	test   %bl,%bl
  8007ba:	75 ef                	jne    8007ab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007bc:	5b                   	pop    %ebx
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c6:	53                   	push   %ebx
  8007c7:	e8 9a ff ff ff       	call   800766 <strlen>
  8007cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	01 d8                	add    %ebx,%eax
  8007d4:	50                   	push   %eax
  8007d5:	e8 c5 ff ff ff       	call   80079f <strcpy>
	return dst;
}
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ec:	89 f3                	mov    %esi,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	89 f2                	mov    %esi,%edx
  8007f3:	eb 0f                	jmp    800804 <strncpy+0x23>
		*dst++ = *src;
  8007f5:	83 c2 01             	add    $0x1,%edx
  8007f8:	0f b6 01             	movzbl (%ecx),%eax
  8007fb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fe:	80 39 01             	cmpb   $0x1,(%ecx)
  800801:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800804:	39 da                	cmp    %ebx,%edx
  800806:	75 ed                	jne    8007f5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800808:	89 f0                	mov    %esi,%eax
  80080a:	5b                   	pop    %ebx
  80080b:	5e                   	pop    %esi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 75 08             	mov    0x8(%ebp),%esi
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800819:	8b 55 10             	mov    0x10(%ebp),%edx
  80081c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081e:	85 d2                	test   %edx,%edx
  800820:	74 21                	je     800843 <strlcpy+0x35>
  800822:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800826:	89 f2                	mov    %esi,%edx
  800828:	eb 09                	jmp    800833 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082a:	83 c2 01             	add    $0x1,%edx
  80082d:	83 c1 01             	add    $0x1,%ecx
  800830:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800833:	39 c2                	cmp    %eax,%edx
  800835:	74 09                	je     800840 <strlcpy+0x32>
  800837:	0f b6 19             	movzbl (%ecx),%ebx
  80083a:	84 db                	test   %bl,%bl
  80083c:	75 ec                	jne    80082a <strlcpy+0x1c>
  80083e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800840:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800843:	29 f0                	sub    %esi,%eax
}
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800852:	eb 06                	jmp    80085a <strcmp+0x11>
		p++, q++;
  800854:	83 c1 01             	add    $0x1,%ecx
  800857:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085a:	0f b6 01             	movzbl (%ecx),%eax
  80085d:	84 c0                	test   %al,%al
  80085f:	74 04                	je     800865 <strcmp+0x1c>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	74 ef                	je     800854 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 c0             	movzbl %al,%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	89 c3                	mov    %eax,%ebx
  80087b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087e:	eb 06                	jmp    800886 <strncmp+0x17>
		n--, p++, q++;
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800886:	39 d8                	cmp    %ebx,%eax
  800888:	74 15                	je     80089f <strncmp+0x30>
  80088a:	0f b6 08             	movzbl (%eax),%ecx
  80088d:	84 c9                	test   %cl,%cl
  80088f:	74 04                	je     800895 <strncmp+0x26>
  800891:	3a 0a                	cmp    (%edx),%cl
  800893:	74 eb                	je     800880 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800895:	0f b6 00             	movzbl (%eax),%eax
  800898:	0f b6 12             	movzbl (%edx),%edx
  80089b:	29 d0                	sub    %edx,%eax
  80089d:	eb 05                	jmp    8008a4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a4:	5b                   	pop    %ebx
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b1:	eb 07                	jmp    8008ba <strchr+0x13>
		if (*s == c)
  8008b3:	38 ca                	cmp    %cl,%dl
  8008b5:	74 0f                	je     8008c6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	0f b6 10             	movzbl (%eax),%edx
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	75 f2                	jne    8008b3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	eb 03                	jmp    8008d7 <strfind+0xf>
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008da:	38 ca                	cmp    %cl,%dl
  8008dc:	74 04                	je     8008e2 <strfind+0x1a>
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	75 f2                	jne    8008d4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f0:	85 c9                	test   %ecx,%ecx
  8008f2:	74 36                	je     80092a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fa:	75 28                	jne    800924 <memset+0x40>
  8008fc:	f6 c1 03             	test   $0x3,%cl
  8008ff:	75 23                	jne    800924 <memset+0x40>
		c &= 0xFF;
  800901:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800905:	89 d3                	mov    %edx,%ebx
  800907:	c1 e3 08             	shl    $0x8,%ebx
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	c1 e6 18             	shl    $0x18,%esi
  80090f:	89 d0                	mov    %edx,%eax
  800911:	c1 e0 10             	shl    $0x10,%eax
  800914:	09 f0                	or     %esi,%eax
  800916:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800918:	89 d8                	mov    %ebx,%eax
  80091a:	09 d0                	or     %edx,%eax
  80091c:	c1 e9 02             	shr    $0x2,%ecx
  80091f:	fc                   	cld    
  800920:	f3 ab                	rep stos %eax,%es:(%edi)
  800922:	eb 06                	jmp    80092a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	fc                   	cld    
  800928:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092a:	89 f8                	mov    %edi,%eax
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093f:	39 c6                	cmp    %eax,%esi
  800941:	73 35                	jae    800978 <memmove+0x47>
  800943:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800946:	39 d0                	cmp    %edx,%eax
  800948:	73 2e                	jae    800978 <memmove+0x47>
		s += n;
		d += n;
  80094a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	09 fe                	or     %edi,%esi
  800951:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800957:	75 13                	jne    80096c <memmove+0x3b>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0e                	jne    80096c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80095e:	83 ef 04             	sub    $0x4,%edi
  800961:	8d 72 fc             	lea    -0x4(%edx),%esi
  800964:	c1 e9 02             	shr    $0x2,%ecx
  800967:	fd                   	std    
  800968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096a:	eb 09                	jmp    800975 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096c:	83 ef 01             	sub    $0x1,%edi
  80096f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800972:	fd                   	std    
  800973:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800975:	fc                   	cld    
  800976:	eb 1d                	jmp    800995 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800978:	89 f2                	mov    %esi,%edx
  80097a:	09 c2                	or     %eax,%edx
  80097c:	f6 c2 03             	test   $0x3,%dl
  80097f:	75 0f                	jne    800990 <memmove+0x5f>
  800981:	f6 c1 03             	test   $0x3,%cl
  800984:	75 0a                	jne    800990 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800986:	c1 e9 02             	shr    $0x2,%ecx
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 05                	jmp    800995 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800990:	89 c7                	mov    %eax,%edi
  800992:	fc                   	cld    
  800993:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099c:	ff 75 10             	pushl  0x10(%ebp)
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	ff 75 08             	pushl  0x8(%ebp)
  8009a5:	e8 87 ff ff ff       	call   800931 <memmove>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	89 c6                	mov    %eax,%esi
  8009b9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bc:	eb 1a                	jmp    8009d8 <memcmp+0x2c>
		if (*s1 != *s2)
  8009be:	0f b6 08             	movzbl (%eax),%ecx
  8009c1:	0f b6 1a             	movzbl (%edx),%ebx
  8009c4:	38 d9                	cmp    %bl,%cl
  8009c6:	74 0a                	je     8009d2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c8:	0f b6 c1             	movzbl %cl,%eax
  8009cb:	0f b6 db             	movzbl %bl,%ebx
  8009ce:	29 d8                	sub    %ebx,%eax
  8009d0:	eb 0f                	jmp    8009e1 <memcmp+0x35>
		s1++, s2++;
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d8:	39 f0                	cmp    %esi,%eax
  8009da:	75 e2                	jne    8009be <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ec:	89 c1                	mov    %eax,%ecx
  8009ee:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f5:	eb 0a                	jmp    800a01 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f7:	0f b6 10             	movzbl (%eax),%edx
  8009fa:	39 da                	cmp    %ebx,%edx
  8009fc:	74 07                	je     800a05 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	39 c8                	cmp    %ecx,%eax
  800a03:	72 f2                	jb     8009f7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a05:	5b                   	pop    %ebx
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a14:	eb 03                	jmp    800a19 <strtol+0x11>
		s++;
  800a16:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a19:	0f b6 01             	movzbl (%ecx),%eax
  800a1c:	3c 20                	cmp    $0x20,%al
  800a1e:	74 f6                	je     800a16 <strtol+0xe>
  800a20:	3c 09                	cmp    $0x9,%al
  800a22:	74 f2                	je     800a16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a24:	3c 2b                	cmp    $0x2b,%al
  800a26:	75 0a                	jne    800a32 <strtol+0x2a>
		s++;
  800a28:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a30:	eb 11                	jmp    800a43 <strtol+0x3b>
  800a32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a37:	3c 2d                	cmp    $0x2d,%al
  800a39:	75 08                	jne    800a43 <strtol+0x3b>
		s++, neg = 1;
  800a3b:	83 c1 01             	add    $0x1,%ecx
  800a3e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a43:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a49:	75 15                	jne    800a60 <strtol+0x58>
  800a4b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4e:	75 10                	jne    800a60 <strtol+0x58>
  800a50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a54:	75 7c                	jne    800ad2 <strtol+0xca>
		s += 2, base = 16;
  800a56:	83 c1 02             	add    $0x2,%ecx
  800a59:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5e:	eb 16                	jmp    800a76 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	75 12                	jne    800a76 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a64:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6c:	75 08                	jne    800a76 <strtol+0x6e>
		s++, base = 8;
  800a6e:	83 c1 01             	add    $0x1,%ecx
  800a71:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7e:	0f b6 11             	movzbl (%ecx),%edx
  800a81:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a84:	89 f3                	mov    %esi,%ebx
  800a86:	80 fb 09             	cmp    $0x9,%bl
  800a89:	77 08                	ja     800a93 <strtol+0x8b>
			dig = *s - '0';
  800a8b:	0f be d2             	movsbl %dl,%edx
  800a8e:	83 ea 30             	sub    $0x30,%edx
  800a91:	eb 22                	jmp    800ab5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a93:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a96:	89 f3                	mov    %esi,%ebx
  800a98:	80 fb 19             	cmp    $0x19,%bl
  800a9b:	77 08                	ja     800aa5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a9d:	0f be d2             	movsbl %dl,%edx
  800aa0:	83 ea 57             	sub    $0x57,%edx
  800aa3:	eb 10                	jmp    800ab5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 19             	cmp    $0x19,%bl
  800aad:	77 16                	ja     800ac5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aaf:	0f be d2             	movsbl %dl,%edx
  800ab2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab8:	7d 0b                	jge    800ac5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac3:	eb b9                	jmp    800a7e <strtol+0x76>

	if (endptr)
  800ac5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac9:	74 0d                	je     800ad8 <strtol+0xd0>
		*endptr = (char *) s;
  800acb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ace:	89 0e                	mov    %ecx,(%esi)
  800ad0:	eb 06                	jmp    800ad8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	74 98                	je     800a6e <strtol+0x66>
  800ad6:	eb 9e                	jmp    800a76 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	f7 da                	neg    %edx
  800adc:	85 ff                	test   %edi,%edi
  800ade:	0f 45 c2             	cmovne %edx,%eax
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	89 c7                	mov    %eax,%edi
  800afb:	89 c6                	mov    %eax,%esi
  800afd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b31:	b8 03 00 00 00       	mov    $0x3,%eax
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 cb                	mov    %ecx,%ebx
  800b3b:	89 cf                	mov    %ecx,%edi
  800b3d:	89 ce                	mov    %ecx,%esi
  800b3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 17                	jle    800b5c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	50                   	push   %eax
  800b49:	6a 03                	push   $0x3
  800b4b:	68 ff 21 80 00       	push   $0x8021ff
  800b50:	6a 23                	push   $0x23
  800b52:	68 1c 22 80 00       	push   $0x80221c
  800b57:	e8 65 0f 00 00       	call   801ac1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_yield>:

void
sys_yield(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b93:	89 d1                	mov    %edx,%ecx
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	be 00 00 00 00       	mov    $0x0,%esi
  800bb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbe:	89 f7                	mov    %esi,%edi
  800bc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	7e 17                	jle    800bdd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	50                   	push   %eax
  800bca:	6a 04                	push   $0x4
  800bcc:	68 ff 21 80 00       	push   $0x8021ff
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 1c 22 80 00       	push   $0x80221c
  800bd8:	e8 e4 0e 00 00       	call   801ac1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bff:	8b 75 18             	mov    0x18(%ebp),%esi
  800c02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	7e 17                	jle    800c1f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	50                   	push   %eax
  800c0c:	6a 05                	push   $0x5
  800c0e:	68 ff 21 80 00       	push   $0x8021ff
  800c13:	6a 23                	push   $0x23
  800c15:	68 1c 22 80 00       	push   $0x80221c
  800c1a:	e8 a2 0e 00 00       	call   801ac1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c35:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	89 df                	mov    %ebx,%edi
  800c42:	89 de                	mov    %ebx,%esi
  800c44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 17                	jle    800c61 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 06                	push   $0x6
  800c50:	68 ff 21 80 00       	push   $0x8021ff
  800c55:	6a 23                	push   $0x23
  800c57:	68 1c 22 80 00       	push   $0x80221c
  800c5c:	e8 60 0e 00 00       	call   801ac1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c77:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	89 df                	mov    %ebx,%edi
  800c84:	89 de                	mov    %ebx,%esi
  800c86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 17                	jle    800ca3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 08                	push   $0x8
  800c92:	68 ff 21 80 00       	push   $0x8021ff
  800c97:	6a 23                	push   $0x23
  800c99:	68 1c 22 80 00       	push   $0x80221c
  800c9e:	e8 1e 0e 00 00       	call   801ac1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	89 df                	mov    %ebx,%edi
  800cc6:	89 de                	mov    %ebx,%esi
  800cc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	7e 17                	jle    800ce5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	6a 09                	push   $0x9
  800cd4:	68 ff 21 80 00       	push   $0x8021ff
  800cd9:	6a 23                	push   $0x23
  800cdb:	68 1c 22 80 00       	push   $0x80221c
  800ce0:	e8 dc 0d 00 00       	call   801ac1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	89 df                	mov    %ebx,%edi
  800d08:	89 de                	mov    %ebx,%esi
  800d0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7e 17                	jle    800d27 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 0a                	push   $0xa
  800d16:	68 ff 21 80 00       	push   $0x8021ff
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 1c 22 80 00       	push   $0x80221c
  800d22:	e8 9a 0d 00 00       	call   801ac1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	be 00 00 00 00       	mov    $0x0,%esi
  800d3a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d48:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d60:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 cb                	mov    %ecx,%ebx
  800d6a:	89 cf                	mov    %ecx,%edi
  800d6c:	89 ce                	mov    %ecx,%esi
  800d6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	7e 17                	jle    800d8b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	50                   	push   %eax
  800d78:	6a 0d                	push   $0xd
  800d7a:	68 ff 21 80 00       	push   $0x8021ff
  800d7f:	6a 23                	push   $0x23
  800d81:	68 1c 22 80 00       	push   $0x80221c
  800d86:	e8 36 0d 00 00       	call   801ac1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d99:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800da0:	75 31                	jne    800dd3 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  800da2:	a1 04 40 80 00       	mov    0x804004,%eax
  800da7:	8b 40 48             	mov    0x48(%eax),%eax
  800daa:	83 ec 04             	sub    $0x4,%esp
  800dad:	6a 07                	push   $0x7
  800daf:	68 00 f0 bf ee       	push   $0xeebff000
  800db4:	50                   	push   %eax
  800db5:	e8 e8 fd ff ff       	call   800ba2 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  800dba:	a1 04 40 80 00       	mov    0x804004,%eax
  800dbf:	8b 40 48             	mov    0x48(%eax),%eax
  800dc2:	83 c4 08             	add    $0x8,%esp
  800dc5:	68 dd 0d 80 00       	push   $0x800ddd
  800dca:	50                   	push   %eax
  800dcb:	e8 1d ff ff ff       	call   800ced <sys_env_set_pgfault_upcall>
  800dd0:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800ddb:	c9                   	leave  
  800ddc:	c3                   	ret    

00800ddd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ddd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dde:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800de3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800de5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  800de8:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  800deb:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  800def:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  800df3:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  800df6:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  800df8:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800dfc:	61                   	popa   
	addl $4, %esp        // skip eip
  800dfd:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  800e00:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800e01:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e02:	c3                   	ret    

00800e03 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e23:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e30:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	c1 ea 16             	shr    $0x16,%edx
  800e3a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e41:	f6 c2 01             	test   $0x1,%dl
  800e44:	74 11                	je     800e57 <fd_alloc+0x2d>
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	c1 ea 0c             	shr    $0xc,%edx
  800e4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e52:	f6 c2 01             	test   $0x1,%dl
  800e55:	75 09                	jne    800e60 <fd_alloc+0x36>
			*fd_store = fd;
  800e57:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5e:	eb 17                	jmp    800e77 <fd_alloc+0x4d>
  800e60:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e65:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e6a:	75 c9                	jne    800e35 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e72:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e7f:	83 f8 1f             	cmp    $0x1f,%eax
  800e82:	77 36                	ja     800eba <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e84:	c1 e0 0c             	shl    $0xc,%eax
  800e87:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8c:	89 c2                	mov    %eax,%edx
  800e8e:	c1 ea 16             	shr    $0x16,%edx
  800e91:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e98:	f6 c2 01             	test   $0x1,%dl
  800e9b:	74 24                	je     800ec1 <fd_lookup+0x48>
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	c1 ea 0c             	shr    $0xc,%edx
  800ea2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea9:	f6 c2 01             	test   $0x1,%dl
  800eac:	74 1a                	je     800ec8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb1:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	eb 13                	jmp    800ecd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebf:	eb 0c                	jmp    800ecd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec6:	eb 05                	jmp    800ecd <fd_lookup+0x54>
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed8:	ba a8 22 80 00       	mov    $0x8022a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edd:	eb 13                	jmp    800ef2 <dev_lookup+0x23>
  800edf:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee2:	39 08                	cmp    %ecx,(%eax)
  800ee4:	75 0c                	jne    800ef2 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef0:	eb 2e                	jmp    800f20 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef2:	8b 02                	mov    (%edx),%eax
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	75 e7                	jne    800edf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef8:	a1 04 40 80 00       	mov    0x804004,%eax
  800efd:	8b 40 48             	mov    0x48(%eax),%eax
  800f00:	83 ec 04             	sub    $0x4,%esp
  800f03:	51                   	push   %ecx
  800f04:	50                   	push   %eax
  800f05:	68 2c 22 80 00       	push   $0x80222c
  800f0a:	e8 64 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	83 ec 10             	sub    $0x10,%esp
  800f2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f33:	50                   	push   %eax
  800f34:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f3a:	c1 e8 0c             	shr    $0xc,%eax
  800f3d:	50                   	push   %eax
  800f3e:	e8 36 ff ff ff       	call   800e79 <fd_lookup>
  800f43:	83 c4 08             	add    $0x8,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 05                	js     800f4f <fd_close+0x2d>
	    || fd != fd2)
  800f4a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4d:	74 0c                	je     800f5b <fd_close+0x39>
		return (must_exist ? r : 0);
  800f4f:	84 db                	test   %bl,%bl
  800f51:	ba 00 00 00 00       	mov    $0x0,%edx
  800f56:	0f 44 c2             	cmove  %edx,%eax
  800f59:	eb 41                	jmp    800f9c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	ff 36                	pushl  (%esi)
  800f64:	e8 66 ff ff ff       	call   800ecf <dev_lookup>
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 1a                	js     800f8c <fd_close+0x6a>
		if (dev->dev_close)
  800f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f75:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f78:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	74 0b                	je     800f8c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	56                   	push   %esi
  800f85:	ff d0                	call   *%eax
  800f87:	89 c3                	mov    %eax,%ebx
  800f89:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8c:	83 ec 08             	sub    $0x8,%esp
  800f8f:	56                   	push   %esi
  800f90:	6a 00                	push   $0x0
  800f92:	e8 90 fc ff ff       	call   800c27 <sys_page_unmap>
	return r;
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	89 d8                	mov    %ebx,%eax
}
  800f9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	ff 75 08             	pushl  0x8(%ebp)
  800fb0:	e8 c4 fe ff ff       	call   800e79 <fd_lookup>
  800fb5:	83 c4 08             	add    $0x8,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 10                	js     800fcc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	6a 01                	push   $0x1
  800fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc4:	e8 59 ff ff ff       	call   800f22 <fd_close>
  800fc9:	83 c4 10             	add    $0x10,%esp
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <close_all>:

void
close_all(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	53                   	push   %ebx
  800fde:	e8 c0 ff ff ff       	call   800fa3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe3:	83 c3 01             	add    $0x1,%ebx
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	83 fb 20             	cmp    $0x20,%ebx
  800fec:	75 ec                	jne    800fda <close_all+0xc>
		close(i);
}
  800fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 2c             	sub    $0x2c,%esp
  800ffc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 75 08             	pushl  0x8(%ebp)
  801006:	e8 6e fe ff ff       	call   800e79 <fd_lookup>
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	0f 88 c1 00 00 00    	js     8010d7 <dup+0xe4>
		return r;
	close(newfdnum);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	56                   	push   %esi
  80101a:	e8 84 ff ff ff       	call   800fa3 <close>

	newfd = INDEX2FD(newfdnum);
  80101f:	89 f3                	mov    %esi,%ebx
  801021:	c1 e3 0c             	shl    $0xc,%ebx
  801024:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80102a:	83 c4 04             	add    $0x4,%esp
  80102d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801030:	e8 de fd ff ff       	call   800e13 <fd2data>
  801035:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801037:	89 1c 24             	mov    %ebx,(%esp)
  80103a:	e8 d4 fd ff ff       	call   800e13 <fd2data>
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801045:	89 f8                	mov    %edi,%eax
  801047:	c1 e8 16             	shr    $0x16,%eax
  80104a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801051:	a8 01                	test   $0x1,%al
  801053:	74 37                	je     80108c <dup+0x99>
  801055:	89 f8                	mov    %edi,%eax
  801057:	c1 e8 0c             	shr    $0xc,%eax
  80105a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801061:	f6 c2 01             	test   $0x1,%dl
  801064:	74 26                	je     80108c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801066:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	25 07 0e 00 00       	and    $0xe07,%eax
  801075:	50                   	push   %eax
  801076:	ff 75 d4             	pushl  -0x2c(%ebp)
  801079:	6a 00                	push   $0x0
  80107b:	57                   	push   %edi
  80107c:	6a 00                	push   $0x0
  80107e:	e8 62 fb ff ff       	call   800be5 <sys_page_map>
  801083:	89 c7                	mov    %eax,%edi
  801085:	83 c4 20             	add    $0x20,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 2e                	js     8010ba <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80108f:	89 d0                	mov    %edx,%eax
  801091:	c1 e8 0c             	shr    $0xc,%eax
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	53                   	push   %ebx
  8010a5:	6a 00                	push   $0x0
  8010a7:	52                   	push   %edx
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 36 fb ff ff       	call   800be5 <sys_page_map>
  8010af:	89 c7                	mov    %eax,%edi
  8010b1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b6:	85 ff                	test   %edi,%edi
  8010b8:	79 1d                	jns    8010d7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	53                   	push   %ebx
  8010be:	6a 00                	push   $0x0
  8010c0:	e8 62 fb ff ff       	call   800c27 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c5:	83 c4 08             	add    $0x8,%esp
  8010c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 55 fb ff ff       	call   800c27 <sys_page_unmap>
	return r;
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	89 f8                	mov    %edi,%eax
}
  8010d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 14             	sub    $0x14,%esp
  8010e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	53                   	push   %ebx
  8010ee:	e8 86 fd ff ff       	call   800e79 <fd_lookup>
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 6d                	js     801169 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801102:	50                   	push   %eax
  801103:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801106:	ff 30                	pushl  (%eax)
  801108:	e8 c2 fd ff ff       	call   800ecf <dev_lookup>
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	78 4c                	js     801160 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801114:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801117:	8b 42 08             	mov    0x8(%edx),%eax
  80111a:	83 e0 03             	and    $0x3,%eax
  80111d:	83 f8 01             	cmp    $0x1,%eax
  801120:	75 21                	jne    801143 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801122:	a1 04 40 80 00       	mov    0x804004,%eax
  801127:	8b 40 48             	mov    0x48(%eax),%eax
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	53                   	push   %ebx
  80112e:	50                   	push   %eax
  80112f:	68 6d 22 80 00       	push   $0x80226d
  801134:	e8 3a f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801141:	eb 26                	jmp    801169 <read+0x8a>
	}
	if (!dev->dev_read)
  801143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801146:	8b 40 08             	mov    0x8(%eax),%eax
  801149:	85 c0                	test   %eax,%eax
  80114b:	74 17                	je     801164 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	ff 75 10             	pushl  0x10(%ebp)
  801153:	ff 75 0c             	pushl  0xc(%ebp)
  801156:	52                   	push   %edx
  801157:	ff d0                	call   *%eax
  801159:	89 c2                	mov    %eax,%edx
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	eb 09                	jmp    801169 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801160:	89 c2                	mov    %eax,%edx
  801162:	eb 05                	jmp    801169 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801164:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801169:	89 d0                	mov    %edx,%eax
  80116b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801184:	eb 21                	jmp    8011a7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	89 f0                	mov    %esi,%eax
  80118b:	29 d8                	sub    %ebx,%eax
  80118d:	50                   	push   %eax
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	03 45 0c             	add    0xc(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	57                   	push   %edi
  801195:	e8 45 ff ff ff       	call   8010df <read>
		if (m < 0)
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 10                	js     8011b1 <readn+0x41>
			return m;
		if (m == 0)
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	74 0a                	je     8011af <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a5:	01 c3                	add    %eax,%ebx
  8011a7:	39 f3                	cmp    %esi,%ebx
  8011a9:	72 db                	jb     801186 <readn+0x16>
  8011ab:	89 d8                	mov    %ebx,%eax
  8011ad:	eb 02                	jmp    8011b1 <readn+0x41>
  8011af:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 14             	sub    $0x14,%esp
  8011c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c6:	50                   	push   %eax
  8011c7:	53                   	push   %ebx
  8011c8:	e8 ac fc ff ff       	call   800e79 <fd_lookup>
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 68                	js     80123e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	ff 30                	pushl  (%eax)
  8011e2:	e8 e8 fc ff ff       	call   800ecf <dev_lookup>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 47                	js     801235 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f5:	75 21                	jne    801218 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fc:	8b 40 48             	mov    0x48(%eax),%eax
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	53                   	push   %ebx
  801203:	50                   	push   %eax
  801204:	68 89 22 80 00       	push   $0x802289
  801209:	e8 65 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801216:	eb 26                	jmp    80123e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801218:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121b:	8b 52 0c             	mov    0xc(%edx),%edx
  80121e:	85 d2                	test   %edx,%edx
  801220:	74 17                	je     801239 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	ff 75 10             	pushl  0x10(%ebp)
  801228:	ff 75 0c             	pushl  0xc(%ebp)
  80122b:	50                   	push   %eax
  80122c:	ff d2                	call   *%edx
  80122e:	89 c2                	mov    %eax,%edx
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	eb 09                	jmp    80123e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	89 c2                	mov    %eax,%edx
  801237:	eb 05                	jmp    80123e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801239:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123e:	89 d0                	mov    %edx,%eax
  801240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <seek>:

int
seek(int fdnum, off_t offset)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	ff 75 08             	pushl  0x8(%ebp)
  801252:	e8 22 fc ff ff       	call   800e79 <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 0e                	js     80126c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801261:	8b 55 0c             	mov    0xc(%ebp),%edx
  801264:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	53                   	push   %ebx
  801272:	83 ec 14             	sub    $0x14,%esp
  801275:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801278:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	53                   	push   %ebx
  80127d:	e8 f7 fb ff ff       	call   800e79 <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	89 c2                	mov    %eax,%edx
  801287:	85 c0                	test   %eax,%eax
  801289:	78 65                	js     8012f0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	ff 30                	pushl  (%eax)
  801297:	e8 33 fc ff ff       	call   800ecf <dev_lookup>
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 44                	js     8012e7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012aa:	75 21                	jne    8012cd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ac:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b1:	8b 40 48             	mov    0x48(%eax),%eax
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	53                   	push   %ebx
  8012b8:	50                   	push   %eax
  8012b9:	68 4c 22 80 00       	push   $0x80224c
  8012be:	e8 b0 ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012cb:	eb 23                	jmp    8012f0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d0:	8b 52 18             	mov    0x18(%edx),%edx
  8012d3:	85 d2                	test   %edx,%edx
  8012d5:	74 14                	je     8012eb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	ff 75 0c             	pushl  0xc(%ebp)
  8012dd:	50                   	push   %eax
  8012de:	ff d2                	call   *%edx
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	eb 09                	jmp    8012f0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	eb 05                	jmp    8012f0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f0:	89 d0                	mov    %edx,%eax
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 14             	sub    $0x14,%esp
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801301:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	ff 75 08             	pushl  0x8(%ebp)
  801308:	e8 6c fb ff ff       	call   800e79 <fd_lookup>
  80130d:	83 c4 08             	add    $0x8,%esp
  801310:	89 c2                	mov    %eax,%edx
  801312:	85 c0                	test   %eax,%eax
  801314:	78 58                	js     80136e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801320:	ff 30                	pushl  (%eax)
  801322:	e8 a8 fb ff ff       	call   800ecf <dev_lookup>
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 37                	js     801365 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801331:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801335:	74 32                	je     801369 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801337:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801341:	00 00 00 
	stat->st_isdir = 0;
  801344:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134b:	00 00 00 
	stat->st_dev = dev;
  80134e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	53                   	push   %ebx
  801358:	ff 75 f0             	pushl  -0x10(%ebp)
  80135b:	ff 50 14             	call   *0x14(%eax)
  80135e:	89 c2                	mov    %eax,%edx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	eb 09                	jmp    80136e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801365:	89 c2                	mov    %eax,%edx
  801367:	eb 05                	jmp    80136e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801369:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136e:	89 d0                	mov    %edx,%eax
  801370:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	56                   	push   %esi
  801379:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	6a 00                	push   $0x0
  80137f:	ff 75 08             	pushl  0x8(%ebp)
  801382:	e8 b7 01 00 00       	call   80153e <open>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 1b                	js     8013ab <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	ff 75 0c             	pushl  0xc(%ebp)
  801396:	50                   	push   %eax
  801397:	e8 5b ff ff ff       	call   8012f7 <fstat>
  80139c:	89 c6                	mov    %eax,%esi
	close(fd);
  80139e:	89 1c 24             	mov    %ebx,(%esp)
  8013a1:	e8 fd fb ff ff       	call   800fa3 <close>
	return r;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	89 f0                	mov    %esi,%eax
}
  8013ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
  8013b7:	89 c6                	mov    %eax,%esi
  8013b9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c2:	75 12                	jne    8013d6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c4:	83 ec 0c             	sub    $0xc,%esp
  8013c7:	6a 01                	push   $0x1
  8013c9:	e8 02 08 00 00       	call   801bd0 <ipc_find_env>
  8013ce:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d6:	6a 07                	push   $0x7
  8013d8:	68 00 50 80 00       	push   $0x805000
  8013dd:	56                   	push   %esi
  8013de:	ff 35 00 40 80 00    	pushl  0x804000
  8013e4:	e8 93 07 00 00       	call   801b7c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e9:	83 c4 0c             	add    $0xc,%esp
  8013ec:	6a 00                	push   $0x0
  8013ee:	53                   	push   %ebx
  8013ef:	6a 00                	push   $0x0
  8013f1:	e8 11 07 00 00       	call   801b07 <ipc_recv>
}
  8013f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	8b 40 0c             	mov    0xc(%eax),%eax
  801409:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801411:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801416:	ba 00 00 00 00       	mov    $0x0,%edx
  80141b:	b8 02 00 00 00       	mov    $0x2,%eax
  801420:	e8 8d ff ff ff       	call   8013b2 <fsipc>
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	8b 40 0c             	mov    0xc(%eax),%eax
  801433:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 06 00 00 00       	mov    $0x6,%eax
  801442:	e8 6b ff ff ff       	call   8013b2 <fsipc>
}
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	53                   	push   %ebx
  80144d:	83 ec 04             	sub    $0x4,%esp
  801450:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	8b 40 0c             	mov    0xc(%eax),%eax
  801459:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145e:	ba 00 00 00 00       	mov    $0x0,%edx
  801463:	b8 05 00 00 00       	mov    $0x5,%eax
  801468:	e8 45 ff ff ff       	call   8013b2 <fsipc>
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 2c                	js     80149d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	68 00 50 80 00       	push   $0x805000
  801479:	53                   	push   %ebx
  80147a:	e8 20 f3 ff ff       	call   80079f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80147f:	a1 80 50 80 00       	mov    0x805080,%eax
  801484:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148a:	a1 84 50 80 00       	mov    0x805084,%eax
  80148f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8014a8:	68 b8 22 80 00       	push   $0x8022b8
  8014ad:	68 90 00 00 00       	push   $0x90
  8014b2:	68 d6 22 80 00       	push   $0x8022d6
  8014b7:	e8 05 06 00 00       	call   801ac1 <_panic>

008014bc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014cf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014da:	b8 03 00 00 00       	mov    $0x3,%eax
  8014df:	e8 ce fe ff ff       	call   8013b2 <fsipc>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 4b                	js     801535 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014ea:	39 c6                	cmp    %eax,%esi
  8014ec:	73 16                	jae    801504 <devfile_read+0x48>
  8014ee:	68 e1 22 80 00       	push   $0x8022e1
  8014f3:	68 e8 22 80 00       	push   $0x8022e8
  8014f8:	6a 7c                	push   $0x7c
  8014fa:	68 d6 22 80 00       	push   $0x8022d6
  8014ff:	e8 bd 05 00 00       	call   801ac1 <_panic>
	assert(r <= PGSIZE);
  801504:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801509:	7e 16                	jle    801521 <devfile_read+0x65>
  80150b:	68 fd 22 80 00       	push   $0x8022fd
  801510:	68 e8 22 80 00       	push   $0x8022e8
  801515:	6a 7d                	push   $0x7d
  801517:	68 d6 22 80 00       	push   $0x8022d6
  80151c:	e8 a0 05 00 00       	call   801ac1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	50                   	push   %eax
  801525:	68 00 50 80 00       	push   $0x805000
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	e8 ff f3 ff ff       	call   800931 <memmove>
	return r;
  801532:	83 c4 10             	add    $0x10,%esp
}
  801535:	89 d8                	mov    %ebx,%eax
  801537:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153a:	5b                   	pop    %ebx
  80153b:	5e                   	pop    %esi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 20             	sub    $0x20,%esp
  801545:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801548:	53                   	push   %ebx
  801549:	e8 18 f2 ff ff       	call   800766 <strlen>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801556:	7f 67                	jg     8015bf <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	e8 c6 f8 ff ff       	call   800e2a <fd_alloc>
  801564:	83 c4 10             	add    $0x10,%esp
		return r;
  801567:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 57                	js     8015c4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	53                   	push   %ebx
  801571:	68 00 50 80 00       	push   $0x805000
  801576:	e8 24 f2 ff ff       	call   80079f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801583:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801586:	b8 01 00 00 00       	mov    $0x1,%eax
  80158b:	e8 22 fe ff ff       	call   8013b2 <fsipc>
  801590:	89 c3                	mov    %eax,%ebx
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	79 14                	jns    8015ad <open+0x6f>
		fd_close(fd, 0);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	6a 00                	push   $0x0
  80159e:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a1:	e8 7c f9 ff ff       	call   800f22 <fd_close>
		return r;
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	89 da                	mov    %ebx,%edx
  8015ab:	eb 17                	jmp    8015c4 <open+0x86>
	}

	return fd2num(fd);
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b3:	e8 4b f8 ff ff       	call   800e03 <fd2num>
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	eb 05                	jmp    8015c4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015bf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c4:	89 d0                	mov    %edx,%eax
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8015db:	e8 d2 fd ff ff       	call   8013b2 <fsipc>
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	ff 75 08             	pushl  0x8(%ebp)
  8015f0:	e8 1e f8 ff ff       	call   800e13 <fd2data>
  8015f5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015f7:	83 c4 08             	add    $0x8,%esp
  8015fa:	68 09 23 80 00       	push   $0x802309
  8015ff:	53                   	push   %ebx
  801600:	e8 9a f1 ff ff       	call   80079f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801605:	8b 46 04             	mov    0x4(%esi),%eax
  801608:	2b 06                	sub    (%esi),%eax
  80160a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801610:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801617:	00 00 00 
	stat->st_dev = &devpipe;
  80161a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801621:	30 80 00 
	return 0;
}
  801624:	b8 00 00 00 00       	mov    $0x0,%eax
  801629:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 0c             	sub    $0xc,%esp
  801637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80163a:	53                   	push   %ebx
  80163b:	6a 00                	push   $0x0
  80163d:	e8 e5 f5 ff ff       	call   800c27 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801642:	89 1c 24             	mov    %ebx,(%esp)
  801645:	e8 c9 f7 ff ff       	call   800e13 <fd2data>
  80164a:	83 c4 08             	add    $0x8,%esp
  80164d:	50                   	push   %eax
  80164e:	6a 00                	push   $0x0
  801650:	e8 d2 f5 ff ff       	call   800c27 <sys_page_unmap>
}
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	57                   	push   %edi
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
  801660:	83 ec 1c             	sub    $0x1c,%esp
  801663:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801666:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801668:	a1 04 40 80 00       	mov    0x804004,%eax
  80166d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801670:	83 ec 0c             	sub    $0xc,%esp
  801673:	ff 75 e0             	pushl  -0x20(%ebp)
  801676:	e8 8e 05 00 00       	call   801c09 <pageref>
  80167b:	89 c3                	mov    %eax,%ebx
  80167d:	89 3c 24             	mov    %edi,(%esp)
  801680:	e8 84 05 00 00       	call   801c09 <pageref>
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	39 c3                	cmp    %eax,%ebx
  80168a:	0f 94 c1             	sete   %cl
  80168d:	0f b6 c9             	movzbl %cl,%ecx
  801690:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801693:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801699:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80169c:	39 ce                	cmp    %ecx,%esi
  80169e:	74 1b                	je     8016bb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016a0:	39 c3                	cmp    %eax,%ebx
  8016a2:	75 c4                	jne    801668 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016a4:	8b 42 58             	mov    0x58(%edx),%eax
  8016a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016aa:	50                   	push   %eax
  8016ab:	56                   	push   %esi
  8016ac:	68 10 23 80 00       	push   $0x802310
  8016b1:	e8 bd ea ff ff       	call   800173 <cprintf>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	eb ad                	jmp    801668 <_pipeisclosed+0xe>
	}
}
  8016bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5f                   	pop    %edi
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	57                   	push   %edi
  8016ca:	56                   	push   %esi
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 28             	sub    $0x28,%esp
  8016cf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016d2:	56                   	push   %esi
  8016d3:	e8 3b f7 ff ff       	call   800e13 <fd2data>
  8016d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e2:	eb 4b                	jmp    80172f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016e4:	89 da                	mov    %ebx,%edx
  8016e6:	89 f0                	mov    %esi,%eax
  8016e8:	e8 6d ff ff ff       	call   80165a <_pipeisclosed>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	75 48                	jne    801739 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016f1:	e8 8d f4 ff ff       	call   800b83 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f6:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f9:	8b 0b                	mov    (%ebx),%ecx
  8016fb:	8d 51 20             	lea    0x20(%ecx),%edx
  8016fe:	39 d0                	cmp    %edx,%eax
  801700:	73 e2                	jae    8016e4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801705:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801709:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	c1 fa 1f             	sar    $0x1f,%edx
  801711:	89 d1                	mov    %edx,%ecx
  801713:	c1 e9 1b             	shr    $0x1b,%ecx
  801716:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801719:	83 e2 1f             	and    $0x1f,%edx
  80171c:	29 ca                	sub    %ecx,%edx
  80171e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801722:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801726:	83 c0 01             	add    $0x1,%eax
  801729:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172c:	83 c7 01             	add    $0x1,%edi
  80172f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801732:	75 c2                	jne    8016f6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801734:	8b 45 10             	mov    0x10(%ebp),%eax
  801737:	eb 05                	jmp    80173e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80173e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5f                   	pop    %edi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	57                   	push   %edi
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	83 ec 18             	sub    $0x18,%esp
  80174f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801752:	57                   	push   %edi
  801753:	e8 bb f6 ff ff       	call   800e13 <fd2data>
  801758:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801762:	eb 3d                	jmp    8017a1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801764:	85 db                	test   %ebx,%ebx
  801766:	74 04                	je     80176c <devpipe_read+0x26>
				return i;
  801768:	89 d8                	mov    %ebx,%eax
  80176a:	eb 44                	jmp    8017b0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80176c:	89 f2                	mov    %esi,%edx
  80176e:	89 f8                	mov    %edi,%eax
  801770:	e8 e5 fe ff ff       	call   80165a <_pipeisclosed>
  801775:	85 c0                	test   %eax,%eax
  801777:	75 32                	jne    8017ab <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801779:	e8 05 f4 ff ff       	call   800b83 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80177e:	8b 06                	mov    (%esi),%eax
  801780:	3b 46 04             	cmp    0x4(%esi),%eax
  801783:	74 df                	je     801764 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801785:	99                   	cltd   
  801786:	c1 ea 1b             	shr    $0x1b,%edx
  801789:	01 d0                	add    %edx,%eax
  80178b:	83 e0 1f             	and    $0x1f,%eax
  80178e:	29 d0                	sub    %edx,%eax
  801790:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801798:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80179b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179e:	83 c3 01             	add    $0x1,%ebx
  8017a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017a4:	75 d8                	jne    80177e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a9:	eb 05                	jmp    8017b0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5f                   	pop    %edi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	56                   	push   %esi
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c3:	50                   	push   %eax
  8017c4:	e8 61 f6 ff ff       	call   800e2a <fd_alloc>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	89 c2                	mov    %eax,%edx
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	0f 88 2c 01 00 00    	js     801902 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	68 07 04 00 00       	push   $0x407
  8017de:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 ba f3 ff ff       	call   800ba2 <sys_page_alloc>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	0f 88 0d 01 00 00    	js     801902 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fb:	50                   	push   %eax
  8017fc:	e8 29 f6 ff ff       	call   800e2a <fd_alloc>
  801801:	89 c3                	mov    %eax,%ebx
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	0f 88 e2 00 00 00    	js     8018f0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180e:	83 ec 04             	sub    $0x4,%esp
  801811:	68 07 04 00 00       	push   $0x407
  801816:	ff 75 f0             	pushl  -0x10(%ebp)
  801819:	6a 00                	push   $0x0
  80181b:	e8 82 f3 ff ff       	call   800ba2 <sys_page_alloc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	0f 88 c3 00 00 00    	js     8018f0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80182d:	83 ec 0c             	sub    $0xc,%esp
  801830:	ff 75 f4             	pushl  -0xc(%ebp)
  801833:	e8 db f5 ff ff       	call   800e13 <fd2data>
  801838:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183a:	83 c4 0c             	add    $0xc,%esp
  80183d:	68 07 04 00 00       	push   $0x407
  801842:	50                   	push   %eax
  801843:	6a 00                	push   $0x0
  801845:	e8 58 f3 ff ff       	call   800ba2 <sys_page_alloc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	0f 88 89 00 00 00    	js     8018e0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	ff 75 f0             	pushl  -0x10(%ebp)
  80185d:	e8 b1 f5 ff ff       	call   800e13 <fd2data>
  801862:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801869:	50                   	push   %eax
  80186a:	6a 00                	push   $0x0
  80186c:	56                   	push   %esi
  80186d:	6a 00                	push   $0x0
  80186f:	e8 71 f3 ff ff       	call   800be5 <sys_page_map>
  801874:	89 c3                	mov    %eax,%ebx
  801876:	83 c4 20             	add    $0x20,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 55                	js     8018d2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80187d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801886:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801892:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ad:	e8 51 f5 ff ff       	call   800e03 <fd2num>
  8018b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018b7:	83 c4 04             	add    $0x4,%esp
  8018ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bd:	e8 41 f5 ff ff       	call   800e03 <fd2num>
  8018c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	eb 30                	jmp    801902 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	56                   	push   %esi
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 4a f3 ff ff       	call   800c27 <sys_page_unmap>
  8018dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e6:	6a 00                	push   $0x0
  8018e8:	e8 3a f3 ff ff       	call   800c27 <sys_page_unmap>
  8018ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 2a f3 ff ff       	call   800c27 <sys_page_unmap>
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801902:	89 d0                	mov    %edx,%eax
  801904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801907:	5b                   	pop    %ebx
  801908:	5e                   	pop    %esi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	ff 75 08             	pushl  0x8(%ebp)
  801918:	e8 5c f5 ff ff       	call   800e79 <fd_lookup>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 18                	js     80193c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	ff 75 f4             	pushl  -0xc(%ebp)
  80192a:	e8 e4 f4 ff ff       	call   800e13 <fd2data>
	return _pipeisclosed(fd, p);
  80192f:	89 c2                	mov    %eax,%edx
  801931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801934:	e8 21 fd ff ff       	call   80165a <_pipeisclosed>
  801939:	83 c4 10             	add    $0x10,%esp
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801941:	b8 00 00 00 00       	mov    $0x0,%eax
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80194e:	68 28 23 80 00       	push   $0x802328
  801953:	ff 75 0c             	pushl  0xc(%ebp)
  801956:	e8 44 ee ff ff       	call   80079f <strcpy>
	return 0;
}
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	57                   	push   %edi
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80196e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801973:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801979:	eb 2d                	jmp    8019a8 <devcons_write+0x46>
		m = n - tot;
  80197b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80197e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801980:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801983:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801988:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198b:	83 ec 04             	sub    $0x4,%esp
  80198e:	53                   	push   %ebx
  80198f:	03 45 0c             	add    0xc(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	57                   	push   %edi
  801994:	e8 98 ef ff ff       	call   800931 <memmove>
		sys_cputs(buf, m);
  801999:	83 c4 08             	add    $0x8,%esp
  80199c:	53                   	push   %ebx
  80199d:	57                   	push   %edi
  80199e:	e8 43 f1 ff ff       	call   800ae6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a3:	01 de                	add    %ebx,%esi
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	89 f0                	mov    %esi,%eax
  8019aa:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ad:	72 cc                	jb     80197b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b2:	5b                   	pop    %ebx
  8019b3:	5e                   	pop    %esi
  8019b4:	5f                   	pop    %edi
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	83 ec 08             	sub    $0x8,%esp
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c6:	74 2a                	je     8019f2 <devcons_read+0x3b>
  8019c8:	eb 05                	jmp    8019cf <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019ca:	e8 b4 f1 ff ff       	call   800b83 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019cf:	e8 30 f1 ff ff       	call   800b04 <sys_cgetc>
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	74 f2                	je     8019ca <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 16                	js     8019f2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019dc:	83 f8 04             	cmp    $0x4,%eax
  8019df:	74 0c                	je     8019ed <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e4:	88 02                	mov    %al,(%edx)
	return 1;
  8019e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019eb:	eb 05                	jmp    8019f2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a00:	6a 01                	push   $0x1
  801a02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a05:	50                   	push   %eax
  801a06:	e8 db f0 ff ff       	call   800ae6 <sys_cputs>
}
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <getchar>:

int
getchar(void)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a16:	6a 01                	push   $0x1
  801a18:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a1b:	50                   	push   %eax
  801a1c:	6a 00                	push   $0x0
  801a1e:	e8 bc f6 ff ff       	call   8010df <read>
	if (r < 0)
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 0f                	js     801a39 <getchar+0x29>
		return r;
	if (r < 1)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	7e 06                	jle    801a34 <getchar+0x24>
		return -E_EOF;
	return c;
  801a2e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a32:	eb 05                	jmp    801a39 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a34:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	ff 75 08             	pushl  0x8(%ebp)
  801a48:	e8 2c f4 ff ff       	call   800e79 <fd_lookup>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 11                	js     801a65 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a5d:	39 10                	cmp    %edx,(%eax)
  801a5f:	0f 94 c0             	sete   %al
  801a62:	0f b6 c0             	movzbl %al,%eax
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <opencons>:

int
opencons(void)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 b4 f3 ff ff       	call   800e2a <fd_alloc>
  801a76:	83 c4 10             	add    $0x10,%esp
		return r;
  801a79:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 3e                	js     801abd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a7f:	83 ec 04             	sub    $0x4,%esp
  801a82:	68 07 04 00 00       	push   $0x407
  801a87:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 11 f1 ff ff       	call   800ba2 <sys_page_alloc>
  801a91:	83 c4 10             	add    $0x10,%esp
		return r;
  801a94:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 23                	js     801abd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	50                   	push   %eax
  801ab3:	e8 4b f3 ff ff       	call   800e03 <fd2num>
  801ab8:	89 c2                	mov    %eax,%edx
  801aba:	83 c4 10             	add    $0x10,%esp
}
  801abd:	89 d0                	mov    %edx,%eax
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ac6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ac9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801acf:	e8 90 f0 ff ff       	call   800b64 <sys_getenvid>
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	ff 75 0c             	pushl  0xc(%ebp)
  801ada:	ff 75 08             	pushl  0x8(%ebp)
  801add:	56                   	push   %esi
  801ade:	50                   	push   %eax
  801adf:	68 34 23 80 00       	push   $0x802334
  801ae4:	e8 8a e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ae9:	83 c4 18             	add    $0x18,%esp
  801aec:	53                   	push   %ebx
  801aed:	ff 75 10             	pushl  0x10(%ebp)
  801af0:	e8 2d e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801af5:	c7 04 24 21 23 80 00 	movl   $0x802321,(%esp)
  801afc:	e8 72 e6 ff ff       	call   800173 <cprintf>
  801b01:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b04:	cc                   	int3   
  801b05:	eb fd                	jmp    801b04 <_panic+0x43>

00801b07 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801b15:	85 c0                	test   %eax,%eax
  801b17:	74 0e                	je     801b27 <ipc_recv+0x20>
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	50                   	push   %eax
  801b1d:	e8 30 f2 ff ff       	call   800d52 <sys_ipc_recv>
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	eb 10                	jmp    801b37 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	68 00 00 c0 ee       	push   $0xeec00000
  801b2f:	e8 1e f2 ff ff       	call   800d52 <sys_ipc_recv>
  801b34:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801b37:	85 c0                	test   %eax,%eax
  801b39:	74 16                	je     801b51 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801b3b:	85 f6                	test   %esi,%esi
  801b3d:	74 06                	je     801b45 <ipc_recv+0x3e>
  801b3f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801b45:	85 db                	test   %ebx,%ebx
  801b47:	74 2c                	je     801b75 <ipc_recv+0x6e>
  801b49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b4f:	eb 24                	jmp    801b75 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b51:	85 f6                	test   %esi,%esi
  801b53:	74 0a                	je     801b5f <ipc_recv+0x58>
  801b55:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5a:	8b 40 74             	mov    0x74(%eax),%eax
  801b5d:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801b5f:	85 db                	test   %ebx,%ebx
  801b61:	74 0a                	je     801b6d <ipc_recv+0x66>
  801b63:	a1 04 40 80 00       	mov    0x804004,%eax
  801b68:	8b 40 78             	mov    0x78(%eax),%eax
  801b6b:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b72:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b78:	5b                   	pop    %ebx
  801b79:	5e                   	pop    %esi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b95:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b98:	ff 75 14             	pushl  0x14(%ebp)
  801b9b:	53                   	push   %ebx
  801b9c:	56                   	push   %esi
  801b9d:	57                   	push   %edi
  801b9e:	e8 8c f1 ff ff       	call   800d2f <sys_ipc_try_send>
		if (ret == 0) break;
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	74 1e                	je     801bc8 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801baa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bad:	74 12                	je     801bc1 <ipc_send+0x45>
  801baf:	50                   	push   %eax
  801bb0:	68 58 23 80 00       	push   $0x802358
  801bb5:	6a 39                	push   $0x39
  801bb7:	68 65 23 80 00       	push   $0x802365
  801bbc:	e8 00 ff ff ff       	call   801ac1 <_panic>
		sys_yield();
  801bc1:	e8 bd ef ff ff       	call   800b83 <sys_yield>
	}
  801bc6:	eb d0                	jmp    801b98 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bdb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bde:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be4:	8b 52 50             	mov    0x50(%edx),%edx
  801be7:	39 ca                	cmp    %ecx,%edx
  801be9:	75 0d                	jne    801bf8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801beb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf3:	8b 40 48             	mov    0x48(%eax),%eax
  801bf6:	eb 0f                	jmp    801c07 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bf8:	83 c0 01             	add    $0x1,%eax
  801bfb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c00:	75 d9                	jne    801bdb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0f:	89 d0                	mov    %edx,%eax
  801c11:	c1 e8 16             	shr    $0x16,%eax
  801c14:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c1b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c20:	f6 c1 01             	test   $0x1,%cl
  801c23:	74 1d                	je     801c42 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c25:	c1 ea 0c             	shr    $0xc,%edx
  801c28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c2f:	f6 c2 01             	test   $0x1,%dl
  801c32:	74 0e                	je     801c42 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c34:	c1 ea 0c             	shr    $0xc,%edx
  801c37:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c3e:	ef 
  801c3f:	0f b7 c0             	movzwl %ax,%eax
}
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	66 90                	xchg   %ax,%ax
  801c46:	66 90                	xchg   %ax,%ax
  801c48:	66 90                	xchg   %ax,%ax
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__udivdi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 1c             	sub    $0x1c,%esp
  801c57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c67:	85 f6                	test   %esi,%esi
  801c69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6d:	89 ca                	mov    %ecx,%edx
  801c6f:	89 f8                	mov    %edi,%eax
  801c71:	75 3d                	jne    801cb0 <__udivdi3+0x60>
  801c73:	39 cf                	cmp    %ecx,%edi
  801c75:	0f 87 c5 00 00 00    	ja     801d40 <__udivdi3+0xf0>
  801c7b:	85 ff                	test   %edi,%edi
  801c7d:	89 fd                	mov    %edi,%ebp
  801c7f:	75 0b                	jne    801c8c <__udivdi3+0x3c>
  801c81:	b8 01 00 00 00       	mov    $0x1,%eax
  801c86:	31 d2                	xor    %edx,%edx
  801c88:	f7 f7                	div    %edi
  801c8a:	89 c5                	mov    %eax,%ebp
  801c8c:	89 c8                	mov    %ecx,%eax
  801c8e:	31 d2                	xor    %edx,%edx
  801c90:	f7 f5                	div    %ebp
  801c92:	89 c1                	mov    %eax,%ecx
  801c94:	89 d8                	mov    %ebx,%eax
  801c96:	89 cf                	mov    %ecx,%edi
  801c98:	f7 f5                	div    %ebp
  801c9a:	89 c3                	mov    %eax,%ebx
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
  801cb0:	39 ce                	cmp    %ecx,%esi
  801cb2:	77 74                	ja     801d28 <__udivdi3+0xd8>
  801cb4:	0f bd fe             	bsr    %esi,%edi
  801cb7:	83 f7 1f             	xor    $0x1f,%edi
  801cba:	0f 84 98 00 00 00    	je     801d58 <__udivdi3+0x108>
  801cc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	89 c5                	mov    %eax,%ebp
  801cc9:	29 fb                	sub    %edi,%ebx
  801ccb:	d3 e6                	shl    %cl,%esi
  801ccd:	89 d9                	mov    %ebx,%ecx
  801ccf:	d3 ed                	shr    %cl,%ebp
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 e0                	shl    %cl,%eax
  801cd5:	09 ee                	or     %ebp,%esi
  801cd7:	89 d9                	mov    %ebx,%ecx
  801cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cdd:	89 d5                	mov    %edx,%ebp
  801cdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ce3:	d3 ed                	shr    %cl,%ebp
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e2                	shl    %cl,%edx
  801ce9:	89 d9                	mov    %ebx,%ecx
  801ceb:	d3 e8                	shr    %cl,%eax
  801ced:	09 c2                	or     %eax,%edx
  801cef:	89 d0                	mov    %edx,%eax
  801cf1:	89 ea                	mov    %ebp,%edx
  801cf3:	f7 f6                	div    %esi
  801cf5:	89 d5                	mov    %edx,%ebp
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	f7 64 24 0c          	mull   0xc(%esp)
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	72 10                	jb     801d11 <__udivdi3+0xc1>
  801d01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	d3 e6                	shl    %cl,%esi
  801d09:	39 c6                	cmp    %eax,%esi
  801d0b:	73 07                	jae    801d14 <__udivdi3+0xc4>
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	75 03                	jne    801d14 <__udivdi3+0xc4>
  801d11:	83 eb 01             	sub    $0x1,%ebx
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 d8                	mov    %ebx,%eax
  801d18:	89 fa                	mov    %edi,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	31 ff                	xor    %edi,%edi
  801d2a:	31 db                	xor    %ebx,%ebx
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
  801d38:	90                   	nop
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 d8                	mov    %ebx,%eax
  801d42:	f7 f7                	div    %edi
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 c3                	mov    %eax,%ebx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 fa                	mov    %edi,%edx
  801d4c:	83 c4 1c             	add    $0x1c,%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    
  801d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d58:	39 ce                	cmp    %ecx,%esi
  801d5a:	72 0c                	jb     801d68 <__udivdi3+0x118>
  801d5c:	31 db                	xor    %ebx,%ebx
  801d5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d62:	0f 87 34 ff ff ff    	ja     801c9c <__udivdi3+0x4c>
  801d68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d6d:	e9 2a ff ff ff       	jmp    801c9c <__udivdi3+0x4c>
  801d72:	66 90                	xchg   %ax,%ax
  801d74:	66 90                	xchg   %ax,%ax
  801d76:	66 90                	xchg   %ax,%ax
  801d78:	66 90                	xchg   %ax,%ax
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__umoddi3>:
  801d80:	55                   	push   %ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	83 ec 1c             	sub    $0x1c,%esp
  801d87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d97:	85 d2                	test   %edx,%edx
  801d99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da1:	89 f3                	mov    %esi,%ebx
  801da3:	89 3c 24             	mov    %edi,(%esp)
  801da6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801daa:	75 1c                	jne    801dc8 <__umoddi3+0x48>
  801dac:	39 f7                	cmp    %esi,%edi
  801dae:	76 50                	jbe    801e00 <__umoddi3+0x80>
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	f7 f7                	div    %edi
  801db6:	89 d0                	mov    %edx,%eax
  801db8:	31 d2                	xor    %edx,%edx
  801dba:	83 c4 1c             	add    $0x1c,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    
  801dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc8:	39 f2                	cmp    %esi,%edx
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	77 52                	ja     801e20 <__umoddi3+0xa0>
  801dce:	0f bd ea             	bsr    %edx,%ebp
  801dd1:	83 f5 1f             	xor    $0x1f,%ebp
  801dd4:	75 5a                	jne    801e30 <__umoddi3+0xb0>
  801dd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dda:	0f 82 e0 00 00 00    	jb     801ec0 <__umoddi3+0x140>
  801de0:	39 0c 24             	cmp    %ecx,(%esp)
  801de3:	0f 86 d7 00 00 00    	jbe    801ec0 <__umoddi3+0x140>
  801de9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ded:	8b 54 24 04          	mov    0x4(%esp),%edx
  801df1:	83 c4 1c             	add    $0x1c,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	85 ff                	test   %edi,%edi
  801e02:	89 fd                	mov    %edi,%ebp
  801e04:	75 0b                	jne    801e11 <__umoddi3+0x91>
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f7                	div    %edi
  801e0f:	89 c5                	mov    %eax,%ebp
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f5                	div    %ebp
  801e17:	89 c8                	mov    %ecx,%eax
  801e19:	f7 f5                	div    %ebp
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	eb 99                	jmp    801db8 <__umoddi3+0x38>
  801e1f:	90                   	nop
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	83 c4 1c             	add    $0x1c,%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	8b 34 24             	mov    (%esp),%esi
  801e33:	bf 20 00 00 00       	mov    $0x20,%edi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	29 ef                	sub    %ebp,%edi
  801e3c:	d3 e0                	shl    %cl,%eax
  801e3e:	89 f9                	mov    %edi,%ecx
  801e40:	89 f2                	mov    %esi,%edx
  801e42:	d3 ea                	shr    %cl,%edx
  801e44:	89 e9                	mov    %ebp,%ecx
  801e46:	09 c2                	or     %eax,%edx
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	89 14 24             	mov    %edx,(%esp)
  801e4d:	89 f2                	mov    %esi,%edx
  801e4f:	d3 e2                	shl    %cl,%edx
  801e51:	89 f9                	mov    %edi,%ecx
  801e53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	89 c6                	mov    %eax,%esi
  801e61:	d3 e3                	shl    %cl,%ebx
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	09 d8                	or     %ebx,%eax
  801e6d:	89 d3                	mov    %edx,%ebx
  801e6f:	89 f2                	mov    %esi,%edx
  801e71:	f7 34 24             	divl   (%esp)
  801e74:	89 d6                	mov    %edx,%esi
  801e76:	d3 e3                	shl    %cl,%ebx
  801e78:	f7 64 24 04          	mull   0x4(%esp)
  801e7c:	39 d6                	cmp    %edx,%esi
  801e7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e82:	89 d1                	mov    %edx,%ecx
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	72 08                	jb     801e90 <__umoddi3+0x110>
  801e88:	75 11                	jne    801e9b <__umoddi3+0x11b>
  801e8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e8e:	73 0b                	jae    801e9b <__umoddi3+0x11b>
  801e90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e94:	1b 14 24             	sbb    (%esp),%edx
  801e97:	89 d1                	mov    %edx,%ecx
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e9f:	29 da                	sub    %ebx,%edx
  801ea1:	19 ce                	sbb    %ecx,%esi
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 f0                	mov    %esi,%eax
  801ea7:	d3 e0                	shl    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	d3 ea                	shr    %cl,%edx
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	d3 ee                	shr    %cl,%esi
  801eb1:	09 d0                	or     %edx,%eax
  801eb3:	89 f2                	mov    %esi,%edx
  801eb5:	83 c4 1c             	add    $0x1c,%esp
  801eb8:	5b                   	pop    %ebx
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	29 f9                	sub    %edi,%ecx
  801ec2:	19 d6                	sbb    %edx,%esi
  801ec4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ecc:	e9 18 ff ff ff       	jmp    801de9 <__umoddi3+0x69>
