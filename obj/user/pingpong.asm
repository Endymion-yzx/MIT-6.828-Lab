
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 3d 0f 00 00       	call   800f7e <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 53 0b 00 00       	call   800ba2 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 22 80 00       	push   $0x802220
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 e4 10 00 00       	call   801150 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 5c 10 00 00       	call   8010db <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 19 0b 00 00       	call   800ba2 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 22 80 00       	push   $0x802236
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 a2 10 00 00       	call   801150 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000c9:	e8 d4 0a 00 00       	call   800ba2 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 99 12 00 00       	call   8013a8 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 48 0a 00 00       	call   800b61 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 d6 09 00 00       	call   800b24 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 1a 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 7b 09 00 00       	call   800b24 <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 77 1d 00 00       	call   801f90 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 64 1e 00 00       	call   8020c0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 53 22 80 00 	movsbl 0x802253(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1b>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	eb 12                	jmp    8002d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 84 6a 04 00 00    	je     800734 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	ff d6                	call   *%esi
  8002d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d4:	83 c7 01             	add    $0x1,%edi
  8002d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002db:	83 f8 25             	cmp    $0x25,%eax
  8002de:	75 e2                	jne    8002c2 <vprintfmt+0x14>
  8002e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fe:	eb 07                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 07             	movzbl (%edi),%eax
  800310:	0f b6 d0             	movzbl %al,%edx
  800313:	83 e8 23             	sub    $0x23,%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 fb 03 00 00    	ja     800719 <vprintfmt+0x46b>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032f:	eb d6                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800349:	83 f9 09             	cmp    $0x9,%ecx
  80034c:	77 3f                	ja     80038d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800351:	eb e9                	jmp    80033c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800367:	eb 2a                	jmp    800393 <vprintfmt+0xe5>
  800369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036c:	85 c0                	test   %eax,%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	0f 49 d0             	cmovns %eax,%edx
  800376:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037c:	eb 89                	jmp    800307 <vprintfmt+0x59>
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800381:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800388:	e9 7a ff ff ff       	jmp    800307 <vprintfmt+0x59>
  80038d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800397:	0f 89 6a ff ff ff    	jns    800307 <vprintfmt+0x59>
				width = precision, precision = -1;
  80039d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003aa:	e9 58 ff ff ff       	jmp    800307 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b5:	e9 4d ff ff ff       	jmp    800307 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	ff 30                	pushl  (%eax)
  8003c6:	ff d6                	call   *%esi
			break;
  8003c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 fe fe ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 78 04             	lea    0x4(%eax),%edi
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	99                   	cltd   
  8003df:	31 d0                	xor    %edx,%eax
  8003e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 0b                	jg     8003f3 <vprintfmt+0x145>
  8003e8:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	75 1b                	jne    80040e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	50                   	push   %eax
  8003f4:	68 6b 22 80 00       	push   $0x80226b
  8003f9:	53                   	push   %ebx
  8003fa:	56                   	push   %esi
  8003fb:	e8 91 fe ff ff       	call   800291 <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800403:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800409:	e9 c6 fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80040e:	52                   	push   %edx
  80040f:	68 52 27 80 00       	push   $0x802752
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 76 fe ff ff       	call   800291 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	e9 ab fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	83 c0 04             	add    $0x4,%eax
  80042f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800437:	85 ff                	test   %edi,%edi
  800439:	b8 64 22 80 00       	mov    $0x802264,%eax
  80043e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800445:	0f 8e 94 00 00 00    	jle    8004df <vprintfmt+0x231>
  80044b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044f:	0f 84 98 00 00 00    	je     8004ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 d0             	pushl  -0x30(%ebp)
  80045b:	57                   	push   %edi
  80045c:	e8 5b 03 00 00       	call   8007bc <strnlen>
  800461:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800469:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800470:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800473:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800476:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	eb 0f                	jmp    800489 <vprintfmt+0x1db>
					putch(padc, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ed                	jg     80047a <vprintfmt+0x1cc>
  80048d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800490:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800493:	85 c9                	test   %ecx,%ecx
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 49 c1             	cmovns %ecx,%eax
  80049d:	29 c1                	sub    %eax,%ecx
  80049f:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a8:	89 cb                	mov    %ecx,%ebx
  8004aa:	eb 4d                	jmp    8004f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	74 1b                	je     8004cd <vprintfmt+0x21f>
  8004b2:	0f be c0             	movsbl %al,%eax
  8004b5:	83 e8 20             	sub    $0x20,%eax
  8004b8:	83 f8 5e             	cmp    $0x5e,%eax
  8004bb:	76 10                	jbe    8004cd <vprintfmt+0x21f>
					putch('?', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	6a 3f                	push   $0x3f
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	52                   	push   %edx
  8004d4:	ff 55 08             	call   *0x8(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 eb 01             	sub    $0x1,%ebx
  8004dd:	eb 1a                	jmp    8004f9 <vprintfmt+0x24b>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	eb 0c                	jmp    8004f9 <vprintfmt+0x24b>
  8004ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800500:	0f be d0             	movsbl %al,%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	74 23                	je     80052a <vprintfmt+0x27c>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 a1                	js     8004ac <vprintfmt+0x1fe>
  80050b:	83 ee 01             	sub    $0x1,%esi
  80050e:	79 9c                	jns    8004ac <vprintfmt+0x1fe>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb 18                	jmp    800532 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	6a 20                	push   $0x20
  800520:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800522:	83 ef 01             	sub    $0x1,%edi
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	eb 08                	jmp    800532 <vprintfmt+0x284>
  80052a:	89 df                	mov    %ebx,%edi
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	85 ff                	test   %edi,%edi
  800534:	7f e4                	jg     80051a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800536:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053f:	e9 90 fd ff ff       	jmp    8002d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800544:	83 f9 01             	cmp    $0x1,%ecx
  800547:	7e 19                	jle    800562 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 50 04             	mov    0x4(%eax),%edx
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 40 08             	lea    0x8(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
  800560:	eb 38                	jmp    80059a <vprintfmt+0x2ec>
	else if (lflag)
  800562:	85 c9                	test   %ecx,%ecx
  800564:	74 1b                	je     800581 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056e:	89 c1                	mov    %eax,%ecx
  800570:	c1 f9 1f             	sar    $0x1f,%ecx
  800573:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	eb 19                	jmp    80059a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	c1 f9 1f             	sar    $0x1f,%ecx
  80058e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a9:	0f 89 36 01 00 00    	jns    8006e5 <vprintfmt+0x437>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bd:	f7 da                	neg    %edx
  8005bf:	83 d1 00             	adc    $0x0,%ecx
  8005c2:	f7 d9                	neg    %ecx
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 14 01 00 00       	jmp    8006e5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d1:	83 f9 01             	cmp    $0x1,%ecx
  8005d4:	7e 18                	jle    8005ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	8b 48 04             	mov    0x4(%eax),%ecx
  8005de:	8d 40 08             	lea    0x8(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e9:	e9 f7 00 00 00       	jmp    8006e5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	74 1a                	je     80060c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 d9 00 00 00       	jmp    8006e5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800621:	e9 bf 00 00 00       	jmp    8006e5 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800626:	83 f9 01             	cmp    $0x1,%ecx
  800629:	7e 13                	jle    80063e <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 50 04             	mov    0x4(%eax),%edx
  800631:	8b 00                	mov    (%eax),%eax
  800633:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800636:	8d 49 08             	lea    0x8(%ecx),%ecx
  800639:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063c:	eb 28                	jmp    800666 <vprintfmt+0x3b8>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	74 13                	je     800655 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	89 d0                	mov    %edx,%eax
  800649:	99                   	cltd   
  80064a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80064d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800650:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800653:	eb 11                	jmp    800666 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	89 d0                	mov    %edx,%eax
  80065c:	99                   	cltd   
  80065d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800660:	8d 49 04             	lea    0x4(%ecx),%ecx
  800663:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800666:	89 d1                	mov    %edx,%ecx
  800668:	89 c2                	mov    %eax,%edx
			base = 8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80066f:	eb 74                	jmp    8006e5 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 30                	push   $0x30
  800677:	ff d6                	call   *%esi
			putch('x', putdat);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 78                	push   $0x78
  80067f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800699:	eb 4a                	jmp    8006e5 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069b:	83 f9 01             	cmp    $0x1,%ecx
  80069e:	7e 15                	jle    8006b5 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a8:	8d 40 08             	lea    0x8(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b3:	eb 30                	jmp    8006e5 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	74 17                	je     8006d0 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ce:	eb 15                	jmp    8006e5 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ec:	57                   	push   %edi
  8006ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f0:	50                   	push   %eax
  8006f1:	51                   	push   %ecx
  8006f2:	52                   	push   %edx
  8006f3:	89 da                	mov    %ebx,%edx
  8006f5:	89 f0                	mov    %esi,%eax
  8006f7:	e8 c9 fa ff ff       	call   8001c5 <printnum>
			break;
  8006fc:	83 c4 20             	add    $0x20,%esp
  8006ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800702:	e9 cd fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	52                   	push   %edx
  80070c:	ff d6                	call   *%esi
			break;
  80070e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800714:	e9 bb fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	53                   	push   %ebx
  80071d:	6a 25                	push   $0x25
  80071f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 03                	jmp    800729 <vprintfmt+0x47b>
  800726:	83 ef 01             	sub    $0x1,%edi
  800729:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072d:	75 f7                	jne    800726 <vprintfmt+0x478>
  80072f:	e9 a0 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 18             	sub    $0x18,%esp
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800752:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 26                	je     800783 <vsnprintf+0x47>
  80075d:	85 d2                	test   %edx,%edx
  80075f:	7e 22                	jle    800783 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800761:	ff 75 14             	pushl  0x14(%ebp)
  800764:	ff 75 10             	pushl  0x10(%ebp)
  800767:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	68 74 02 80 00       	push   $0x800274
  800770:	e8 39 fb ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800778:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	eb 05                	jmp    800788 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800793:	50                   	push   %eax
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	ff 75 08             	pushl  0x8(%ebp)
  80079d:	e8 9a ff ff ff       	call   80073c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007af:	eb 03                	jmp    8007b4 <strlen+0x10>
		n++;
  8007b1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b8:	75 f7                	jne    8007b1 <strlen+0xd>
		n++;
	return n;
}
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ca:	eb 03                	jmp    8007cf <strnlen+0x13>
		n++;
  8007cc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	39 c2                	cmp    %eax,%edx
  8007d1:	74 08                	je     8007db <strnlen+0x1f>
  8007d3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d7:	75 f3                	jne    8007cc <strnlen+0x10>
  8007d9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	83 c2 01             	add    $0x1,%edx
  8007ec:	83 c1 01             	add    $0x1,%ecx
  8007ef:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f6:	84 db                	test   %bl,%bl
  8007f8:	75 ef                	jne    8007e9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800804:	53                   	push   %ebx
  800805:	e8 9a ff ff ff       	call   8007a4 <strlen>
  80080a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080d:	ff 75 0c             	pushl  0xc(%ebp)
  800810:	01 d8                	add    %ebx,%eax
  800812:	50                   	push   %eax
  800813:	e8 c5 ff ff ff       	call   8007dd <strcpy>
	return dst;
}
  800818:	89 d8                	mov    %ebx,%eax
  80081a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	8b 75 08             	mov    0x8(%ebp),%esi
  800827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082a:	89 f3                	mov    %esi,%ebx
  80082c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082f:	89 f2                	mov    %esi,%edx
  800831:	eb 0f                	jmp    800842 <strncpy+0x23>
		*dst++ = *src;
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	0f b6 01             	movzbl (%ecx),%eax
  800839:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083c:	80 39 01             	cmpb   $0x1,(%ecx)
  80083f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	39 da                	cmp    %ebx,%edx
  800844:	75 ed                	jne    800833 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800846:	89 f0                	mov    %esi,%eax
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 55 10             	mov    0x10(%ebp),%edx
  80085a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085c:	85 d2                	test   %edx,%edx
  80085e:	74 21                	je     800881 <strlcpy+0x35>
  800860:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800864:	89 f2                	mov    %esi,%edx
  800866:	eb 09                	jmp    800871 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800868:	83 c2 01             	add    $0x1,%edx
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800871:	39 c2                	cmp    %eax,%edx
  800873:	74 09                	je     80087e <strlcpy+0x32>
  800875:	0f b6 19             	movzbl (%ecx),%ebx
  800878:	84 db                	test   %bl,%bl
  80087a:	75 ec                	jne    800868 <strlcpy+0x1c>
  80087c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800881:	29 f0                	sub    %esi,%eax
}
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800890:	eb 06                	jmp    800898 <strcmp+0x11>
		p++, q++;
  800892:	83 c1 01             	add    $0x1,%ecx
  800895:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800898:	0f b6 01             	movzbl (%ecx),%eax
  80089b:	84 c0                	test   %al,%al
  80089d:	74 04                	je     8008a3 <strcmp+0x1c>
  80089f:	3a 02                	cmp    (%edx),%al
  8008a1:	74 ef                	je     800892 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a3:	0f b6 c0             	movzbl %al,%eax
  8008a6:	0f b6 12             	movzbl (%edx),%edx
  8008a9:	29 d0                	sub    %edx,%eax
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	53                   	push   %ebx
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b7:	89 c3                	mov    %eax,%ebx
  8008b9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bc:	eb 06                	jmp    8008c4 <strncmp+0x17>
		n--, p++, q++;
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c4:	39 d8                	cmp    %ebx,%eax
  8008c6:	74 15                	je     8008dd <strncmp+0x30>
  8008c8:	0f b6 08             	movzbl (%eax),%ecx
  8008cb:	84 c9                	test   %cl,%cl
  8008cd:	74 04                	je     8008d3 <strncmp+0x26>
  8008cf:	3a 0a                	cmp    (%edx),%cl
  8008d1:	74 eb                	je     8008be <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d3:	0f b6 00             	movzbl (%eax),%eax
  8008d6:	0f b6 12             	movzbl (%edx),%edx
  8008d9:	29 d0                	sub    %edx,%eax
  8008db:	eb 05                	jmp    8008e2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ef:	eb 07                	jmp    8008f8 <strchr+0x13>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 0f                	je     800904 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	0f b6 10             	movzbl (%eax),%edx
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f2                	jne    8008f1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800910:	eb 03                	jmp    800915 <strfind+0xf>
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 04                	je     800920 <strfind+0x1a>
  80091c:	84 d2                	test   %dl,%dl
  80091e:	75 f2                	jne    800912 <strfind+0xc>
			break;
	return (char *) s;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092e:	85 c9                	test   %ecx,%ecx
  800930:	74 36                	je     800968 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800932:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800938:	75 28                	jne    800962 <memset+0x40>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 23                	jne    800962 <memset+0x40>
		c &= 0xFF;
  80093f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800943:	89 d3                	mov    %edx,%ebx
  800945:	c1 e3 08             	shl    $0x8,%ebx
  800948:	89 d6                	mov    %edx,%esi
  80094a:	c1 e6 18             	shl    $0x18,%esi
  80094d:	89 d0                	mov    %edx,%eax
  80094f:	c1 e0 10             	shl    $0x10,%eax
  800952:	09 f0                	or     %esi,%eax
  800954:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800956:	89 d8                	mov    %ebx,%eax
  800958:	09 d0                	or     %edx,%eax
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	fc                   	cld    
  80095e:	f3 ab                	rep stos %eax,%es:(%edi)
  800960:	eb 06                	jmp    800968 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	fc                   	cld    
  800966:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800968:	89 f8                	mov    %edi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097d:	39 c6                	cmp    %eax,%esi
  80097f:	73 35                	jae    8009b6 <memmove+0x47>
  800981:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800984:	39 d0                	cmp    %edx,%eax
  800986:	73 2e                	jae    8009b6 <memmove+0x47>
		s += n;
		d += n;
  800988:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	89 d6                	mov    %edx,%esi
  80098d:	09 fe                	or     %edi,%esi
  80098f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800995:	75 13                	jne    8009aa <memmove+0x3b>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 0e                	jne    8009aa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099c:	83 ef 04             	sub    $0x4,%edi
  80099f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
  8009a5:	fd                   	std    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb 09                	jmp    8009b3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009aa:	83 ef 01             	sub    $0x1,%edi
  8009ad:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b0:	fd                   	std    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b3:	fc                   	cld    
  8009b4:	eb 1d                	jmp    8009d3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	89 f2                	mov    %esi,%edx
  8009b8:	09 c2                	or     %eax,%edx
  8009ba:	f6 c2 03             	test   $0x3,%dl
  8009bd:	75 0f                	jne    8009ce <memmove+0x5f>
  8009bf:	f6 c1 03             	test   $0x3,%cl
  8009c2:	75 0a                	jne    8009ce <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
  8009c7:	89 c7                	mov    %eax,%edi
  8009c9:	fc                   	cld    
  8009ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cc:	eb 05                	jmp    8009d3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009da:	ff 75 10             	pushl  0x10(%ebp)
  8009dd:	ff 75 0c             	pushl  0xc(%ebp)
  8009e0:	ff 75 08             	pushl  0x8(%ebp)
  8009e3:	e8 87 ff ff ff       	call   80096f <memmove>
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f5:	89 c6                	mov    %eax,%esi
  8009f7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fa:	eb 1a                	jmp    800a16 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fc:	0f b6 08             	movzbl (%eax),%ecx
  8009ff:	0f b6 1a             	movzbl (%edx),%ebx
  800a02:	38 d9                	cmp    %bl,%cl
  800a04:	74 0a                	je     800a10 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a06:	0f b6 c1             	movzbl %cl,%eax
  800a09:	0f b6 db             	movzbl %bl,%ebx
  800a0c:	29 d8                	sub    %ebx,%eax
  800a0e:	eb 0f                	jmp    800a1f <memcmp+0x35>
		s1++, s2++;
  800a10:	83 c0 01             	add    $0x1,%eax
  800a13:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a16:	39 f0                	cmp    %esi,%eax
  800a18:	75 e2                	jne    8009fc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a2a:	89 c1                	mov    %eax,%ecx
  800a2c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a33:	eb 0a                	jmp    800a3f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	39 da                	cmp    %ebx,%edx
  800a3a:	74 07                	je     800a43 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	39 c8                	cmp    %ecx,%eax
  800a41:	72 f2                	jb     800a35 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	eb 03                	jmp    800a57 <strtol+0x11>
		s++;
  800a54:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a57:	0f b6 01             	movzbl (%ecx),%eax
  800a5a:	3c 20                	cmp    $0x20,%al
  800a5c:	74 f6                	je     800a54 <strtol+0xe>
  800a5e:	3c 09                	cmp    $0x9,%al
  800a60:	74 f2                	je     800a54 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a62:	3c 2b                	cmp    $0x2b,%al
  800a64:	75 0a                	jne    800a70 <strtol+0x2a>
		s++;
  800a66:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6e:	eb 11                	jmp    800a81 <strtol+0x3b>
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a75:	3c 2d                	cmp    $0x2d,%al
  800a77:	75 08                	jne    800a81 <strtol+0x3b>
		s++, neg = 1;
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a87:	75 15                	jne    800a9e <strtol+0x58>
  800a89:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8c:	75 10                	jne    800a9e <strtol+0x58>
  800a8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a92:	75 7c                	jne    800b10 <strtol+0xca>
		s += 2, base = 16;
  800a94:	83 c1 02             	add    $0x2,%ecx
  800a97:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9c:	eb 16                	jmp    800ab4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9e:	85 db                	test   %ebx,%ebx
  800aa0:	75 12                	jne    800ab4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaa:	75 08                	jne    800ab4 <strtol+0x6e>
		s++, base = 8;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abc:	0f b6 11             	movzbl (%ecx),%edx
  800abf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 09             	cmp    $0x9,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0x8b>
			dig = *s - '0';
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 30             	sub    $0x30,%edx
  800acf:	eb 22                	jmp    800af3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 19             	cmp    $0x19,%bl
  800ad9:	77 08                	ja     800ae3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800adb:	0f be d2             	movsbl %dl,%edx
  800ade:	83 ea 57             	sub    $0x57,%edx
  800ae1:	eb 10                	jmp    800af3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	80 fb 19             	cmp    $0x19,%bl
  800aeb:	77 16                	ja     800b03 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aed:	0f be d2             	movsbl %dl,%edx
  800af0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af6:	7d 0b                	jge    800b03 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af8:	83 c1 01             	add    $0x1,%ecx
  800afb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aff:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b01:	eb b9                	jmp    800abc <strtol+0x76>

	if (endptr)
  800b03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b07:	74 0d                	je     800b16 <strtol+0xd0>
		*endptr = (char *) s;
  800b09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0c:	89 0e                	mov    %ecx,(%esi)
  800b0e:	eb 06                	jmp    800b16 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b10:	85 db                	test   %ebx,%ebx
  800b12:	74 98                	je     800aac <strtol+0x66>
  800b14:	eb 9e                	jmp    800ab4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b16:	89 c2                	mov    %eax,%edx
  800b18:	f7 da                	neg    %edx
  800b1a:	85 ff                	test   %edi,%edi
  800b1c:	0f 45 c2             	cmovne %edx,%eax
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	89 c3                	mov    %eax,%ebx
  800b37:	89 c7                	mov    %eax,%edi
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 cb                	mov    %ecx,%ebx
  800b79:	89 cf                	mov    %ecx,%edi
  800b7b:	89 ce                	mov    %ecx,%esi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 03                	push   $0x3
  800b89:	68 5f 25 80 00       	push   $0x80255f
  800b8e:	6a 23                	push   $0x23
  800b90:	68 7c 25 80 00       	push   $0x80257c
  800b95:	e8 01 13 00 00       	call   801e9b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_yield>:

void
sys_yield(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	be 00 00 00 00       	mov    $0x0,%esi
  800bee:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfc:	89 f7                	mov    %esi,%edi
  800bfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 04                	push   $0x4
  800c0a:	68 5f 25 80 00       	push   $0x80255f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 7c 25 80 00       	push   $0x80257c
  800c16:	e8 80 12 00 00       	call   801e9b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 05                	push   $0x5
  800c4c:	68 5f 25 80 00       	push   $0x80255f
  800c51:	6a 23                	push   $0x23
  800c53:	68 7c 25 80 00       	push   $0x80257c
  800c58:	e8 3e 12 00 00       	call   801e9b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 06 00 00 00       	mov    $0x6,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 06                	push   $0x6
  800c8e:	68 5f 25 80 00       	push   $0x80255f
  800c93:	6a 23                	push   $0x23
  800c95:	68 7c 25 80 00       	push   $0x80257c
  800c9a:	e8 fc 11 00 00       	call   801e9b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 08                	push   $0x8
  800cd0:	68 5f 25 80 00       	push   $0x80255f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 7c 25 80 00       	push   $0x80257c
  800cdc:	e8 ba 11 00 00       	call   801e9b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 df                	mov    %ebx,%edi
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 17                	jle    800d23 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	83 ec 0c             	sub    $0xc,%esp
  800d0f:	50                   	push   %eax
  800d10:	6a 09                	push   $0x9
  800d12:	68 5f 25 80 00       	push   $0x80255f
  800d17:	6a 23                	push   $0x23
  800d19:	68 7c 25 80 00       	push   $0x80257c
  800d1e:	e8 78 11 00 00       	call   801e9b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 df                	mov    %ebx,%edi
  800d46:	89 de                	mov    %ebx,%esi
  800d48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 0a                	push   $0xa
  800d54:	68 5f 25 80 00       	push   $0x80255f
  800d59:	6a 23                	push   $0x23
  800d5b:	68 7c 25 80 00       	push   $0x80257c
  800d60:	e8 36 11 00 00       	call   801e9b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	be 00 00 00 00       	mov    $0x0,%esi
  800d78:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d89:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 cb                	mov    %ecx,%ebx
  800da8:	89 cf                	mov    %ecx,%edi
  800daa:	89 ce                	mov    %ecx,%esi
  800dac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dae:	85 c0                	test   %eax,%eax
  800db0:	7e 17                	jle    800dc9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	50                   	push   %eax
  800db6:	6a 0d                	push   $0xd
  800db8:	68 5f 25 80 00       	push   $0x80255f
  800dbd:	6a 23                	push   $0x23
  800dbf:	68 7c 25 80 00       	push   $0x80257c
  800dc4:	e8 d2 10 00 00       	call   801e9b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ddb:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800ddd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de1:	0f 84 48 01 00 00    	je     800f2f <pgfault+0x15e>
  800de7:	89 d8                	mov    %ebx,%eax
  800de9:	c1 e8 16             	shr    $0x16,%eax
  800dec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800df3:	a8 01                	test   $0x1,%al
  800df5:	0f 84 5f 01 00 00    	je     800f5a <pgfault+0x189>
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	c1 e8 0c             	shr    $0xc,%eax
  800e00:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e07:	f6 c2 01             	test   $0x1,%dl
  800e0a:	0f 84 4a 01 00 00    	je     800f5a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e10:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e17:	f6 c4 08             	test   $0x8,%ah
  800e1a:	75 79                	jne    800e95 <pgfault+0xc4>
  800e1c:	e9 39 01 00 00       	jmp    800f5a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800e21:	89 d8                	mov    %ebx,%eax
  800e23:	c1 e8 16             	shr    $0x16,%eax
  800e26:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e2d:	a8 01                	test   $0x1,%al
  800e2f:	75 10                	jne    800e41 <pgfault+0x70>
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	68 8a 25 80 00       	push   $0x80258a
  800e39:	e8 73 f3 ff ff       	call   8001b1 <cprintf>
  800e3e:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800e41:	c1 eb 0c             	shr    $0xc,%ebx
  800e44:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800e4a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e51:	a8 01                	test   $0x1,%al
  800e53:	75 10                	jne    800e65 <pgfault+0x94>
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	68 9b 25 80 00       	push   $0x80259b
  800e5d:	e8 4f f3 ff ff       	call   8001b1 <cprintf>
  800e62:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800e65:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e6c:	f6 c4 08             	test   $0x8,%ah
  800e6f:	75 10                	jne    800e81 <pgfault+0xb0>
  800e71:	83 ec 0c             	sub    $0xc,%esp
  800e74:	68 ac 25 80 00       	push   $0x8025ac
  800e79:	e8 33 f3 ff ff       	call   8001b1 <cprintf>
  800e7e:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	68 bf 25 80 00       	push   $0x8025bf
  800e89:	6a 23                	push   $0x23
  800e8b:	68 cf 25 80 00       	push   $0x8025cf
  800e90:	e8 06 10 00 00       	call   801e9b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	6a 07                	push   $0x7
  800e9a:	68 00 f0 7f 00       	push   $0x7ff000
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 3a fd ff ff       	call   800be0 <sys_page_alloc>
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	79 12                	jns    800ebf <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800ead:	50                   	push   %eax
  800eae:	68 da 25 80 00       	push   $0x8025da
  800eb3:	6a 2f                	push   $0x2f
  800eb5:	68 cf 25 80 00       	push   $0x8025cf
  800eba:	e8 dc 0f 00 00       	call   801e9b <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ebf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	68 00 10 00 00       	push   $0x1000
  800ecd:	53                   	push   %ebx
  800ece:	68 00 f0 7f 00       	push   $0x7ff000
  800ed3:	e8 ff fa ff ff       	call   8009d7 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800ed8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800edf:	53                   	push   %ebx
  800ee0:	6a 00                	push   $0x0
  800ee2:	68 00 f0 7f 00       	push   $0x7ff000
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 35 fd ff ff       	call   800c23 <sys_page_map>
  800eee:	83 c4 20             	add    $0x20,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	79 12                	jns    800f07 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800ef5:	50                   	push   %eax
  800ef6:	68 f4 25 80 00       	push   $0x8025f4
  800efb:	6a 33                	push   $0x33
  800efd:	68 cf 25 80 00       	push   $0x8025cf
  800f02:	e8 94 0f 00 00       	call   801e9b <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	68 00 f0 7f 00       	push   $0x7ff000
  800f0f:	6a 00                	push   $0x0
  800f11:	e8 4f fd ff ff       	call   800c65 <sys_page_unmap>
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	79 5c                	jns    800f79 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  800f1d:	50                   	push   %eax
  800f1e:	68 0c 26 80 00       	push   $0x80260c
  800f23:	6a 35                	push   $0x35
  800f25:	68 cf 25 80 00       	push   $0x8025cf
  800f2a:	e8 6c 0f 00 00       	call   801e9b <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f2f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f34:	8b 40 48             	mov    0x48(%eax),%eax
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	50                   	push   %eax
  800f3b:	53                   	push   %ebx
  800f3c:	68 48 26 80 00       	push   $0x802648
  800f41:	e8 6b f2 ff ff       	call   8001b1 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  800f46:	c7 04 24 26 26 80 00 	movl   $0x802626,(%esp)
  800f4d:	e8 5f f2 ff ff       	call   8001b1 <cprintf>
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	e9 c7 fe ff ff       	jmp    800e21 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f5a:	a1 04 40 80 00       	mov    0x804004,%eax
  800f5f:	8b 40 48             	mov    0x48(%eax),%eax
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	50                   	push   %eax
  800f66:	53                   	push   %ebx
  800f67:	68 48 26 80 00       	push   $0x802648
  800f6c:	e8 40 f2 ff ff       	call   8001b1 <cprintf>
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	e9 a8 fe ff ff       	jmp    800e21 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  800f79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  800f87:	68 d1 0d 80 00       	push   $0x800dd1
  800f8c:	e8 50 0f 00 00       	call   801ee1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f91:	b8 07 00 00 00       	mov    $0x7,%eax
  800f96:	cd 30                	int    $0x30
  800f98:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	0f 88 0d 01 00 00    	js     8010b6 <fork+0x138>
  800fa9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fae:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	75 2f                	jne    800fe6 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb7:	e8 e6 fb ff ff       	call   800ba2 <sys_getenvid>
  800fbc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc9:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  800fce:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd3:	e9 e1 00 00 00       	jmp    8010b9 <fork+0x13b>
  800fd8:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  800fde:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fe4:	74 77                	je     80105d <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  800fe6:	89 f0                	mov    %esi,%eax
  800fe8:	c1 e8 0a             	shr    $0xa,%eax
  800feb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  800ff2:	a8 01                	test   $0x1,%al
  800ff4:	74 0b                	je     801001 <fork+0x83>
	pte_t pte = uvpt[pn];
  800ff6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  800ffd:	a8 01                	test   $0x1,%al
  800fff:	75 08                	jne    801009 <fork+0x8b>
  801001:	8d 5e 01             	lea    0x1(%esi),%ebx
  801004:	c1 e3 0c             	shl    $0xc,%ebx
  801007:	eb 56                	jmp    80105f <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801009:	25 02 08 00 00       	and    $0x802,%eax
  80100e:	83 f8 01             	cmp    $0x1,%eax
  801011:	19 ff                	sbb    %edi,%edi
  801013:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801019:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80101f:	a1 04 40 80 00       	mov    0x804004,%eax
  801024:	8b 40 48             	mov    0x48(%eax),%eax
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	57                   	push   %edi
  80102b:	53                   	push   %ebx
  80102c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102f:	53                   	push   %ebx
  801030:	50                   	push   %eax
  801031:	e8 ed fb ff ff       	call   800c23 <sys_page_map>
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 7c                	js     8010b9 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  80103d:	a1 04 40 80 00       	mov    0x804004,%eax
  801042:	8b 40 48             	mov    0x48(%eax),%eax
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	57                   	push   %edi
  801049:	53                   	push   %ebx
  80104a:	50                   	push   %eax
  80104b:	53                   	push   %ebx
  80104c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104f:	e8 cf fb ff ff       	call   800c23 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	79 a6                	jns    801001 <fork+0x83>
  80105b:	eb 5c                	jmp    8010b9 <fork+0x13b>
  80105d:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  80105f:	83 c6 01             	add    $0x1,%esi
  801062:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801068:	0f 86 6a ff ff ff    	jbe    800fd8 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	6a 07                	push   $0x7
  801073:	68 00 f0 bf ee       	push   $0xeebff000
  801078:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80107b:	57                   	push   %edi
  80107c:	e8 5f fb ff ff       	call   800be0 <sys_page_alloc>
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 31                	js     8010b9 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  801088:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  80108d:	8b 40 64             	mov    0x64(%eax),%eax
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	50                   	push   %eax
  801094:	57                   	push   %edi
  801095:	e8 91 fc ff ff       	call   800d2b <sys_env_set_pgfault_upcall>
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	78 18                	js     8010b9 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010a1:	83 ec 08             	sub    $0x8,%esp
  8010a4:	6a 02                	push   $0x2
  8010a6:	57                   	push   %edi
  8010a7:	e8 fb fb ff ff       	call   800ca7 <sys_env_set_status>
  8010ac:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	0f 49 c7             	cmovns %edi,%eax
  8010b4:	eb 03                	jmp    8010b9 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8010b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c7:	68 31 26 80 00       	push   $0x802631
  8010cc:	68 9f 00 00 00       	push   $0x9f
  8010d1:	68 cf 25 80 00       	push   $0x8025cf
  8010d6:	e8 c0 0d 00 00       	call   801e9b <_panic>

008010db <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	74 0e                	je     8010fb <ipc_recv+0x20>
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	50                   	push   %eax
  8010f1:	e8 9a fc ff ff       	call   800d90 <sys_ipc_recv>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	eb 10                	jmp    80110b <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	68 00 00 c0 ee       	push   $0xeec00000
  801103:	e8 88 fc ff ff       	call   800d90 <sys_ipc_recv>
  801108:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  80110b:	85 c0                	test   %eax,%eax
  80110d:	74 16                	je     801125 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  80110f:	85 f6                	test   %esi,%esi
  801111:	74 06                	je     801119 <ipc_recv+0x3e>
  801113:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801119:	85 db                	test   %ebx,%ebx
  80111b:	74 2c                	je     801149 <ipc_recv+0x6e>
  80111d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801123:	eb 24                	jmp    801149 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801125:	85 f6                	test   %esi,%esi
  801127:	74 0a                	je     801133 <ipc_recv+0x58>
  801129:	a1 04 40 80 00       	mov    0x804004,%eax
  80112e:	8b 40 74             	mov    0x74(%eax),%eax
  801131:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801133:	85 db                	test   %ebx,%ebx
  801135:	74 0a                	je     801141 <ipc_recv+0x66>
  801137:	a1 04 40 80 00       	mov    0x804004,%eax
  80113c:	8b 40 78             	mov    0x78(%eax),%eax
  80113f:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801141:	a1 04 40 80 00       	mov    0x804004,%eax
  801146:	8b 40 70             	mov    0x70(%eax),%eax
}
  801149:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115f:	8b 45 10             	mov    0x10(%ebp),%eax
  801162:	85 c0                	test   %eax,%eax
  801164:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801169:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  80116c:	ff 75 14             	pushl  0x14(%ebp)
  80116f:	53                   	push   %ebx
  801170:	56                   	push   %esi
  801171:	57                   	push   %edi
  801172:	e8 f6 fb ff ff       	call   800d6d <sys_ipc_try_send>
		if (ret == 0) break;
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	74 1e                	je     80119c <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  80117e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801181:	74 12                	je     801195 <ipc_send+0x45>
  801183:	50                   	push   %eax
  801184:	68 6c 26 80 00       	push   $0x80266c
  801189:	6a 39                	push   $0x39
  80118b:	68 79 26 80 00       	push   $0x802679
  801190:	e8 06 0d 00 00       	call   801e9b <_panic>
		sys_yield();
  801195:	e8 27 fa ff ff       	call   800bc1 <sys_yield>
	}
  80119a:	eb d0                	jmp    80116c <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  80119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011af:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011b2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b8:	8b 52 50             	mov    0x50(%edx),%edx
  8011bb:	39 ca                	cmp    %ecx,%edx
  8011bd:	75 0d                	jne    8011cc <ipc_find_env+0x28>
			return envs[i].env_id;
  8011bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ca:	eb 0f                	jmp    8011db <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011cc:	83 c0 01             	add    $0x1,%eax
  8011cf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d4:	75 d9                	jne    8011af <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e8:	c1 e8 0c             	shr    $0xc,%eax
}
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120f:	89 c2                	mov    %eax,%edx
  801211:	c1 ea 16             	shr    $0x16,%edx
  801214:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121b:	f6 c2 01             	test   $0x1,%dl
  80121e:	74 11                	je     801231 <fd_alloc+0x2d>
  801220:	89 c2                	mov    %eax,%edx
  801222:	c1 ea 0c             	shr    $0xc,%edx
  801225:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122c:	f6 c2 01             	test   $0x1,%dl
  80122f:	75 09                	jne    80123a <fd_alloc+0x36>
			*fd_store = fd;
  801231:	89 01                	mov    %eax,(%ecx)
			return 0;
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	eb 17                	jmp    801251 <fd_alloc+0x4d>
  80123a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801244:	75 c9                	jne    80120f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801246:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80124c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801259:	83 f8 1f             	cmp    $0x1f,%eax
  80125c:	77 36                	ja     801294 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125e:	c1 e0 0c             	shl    $0xc,%eax
  801261:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801266:	89 c2                	mov    %eax,%edx
  801268:	c1 ea 16             	shr    $0x16,%edx
  80126b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801272:	f6 c2 01             	test   $0x1,%dl
  801275:	74 24                	je     80129b <fd_lookup+0x48>
  801277:	89 c2                	mov    %eax,%edx
  801279:	c1 ea 0c             	shr    $0xc,%edx
  80127c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801283:	f6 c2 01             	test   $0x1,%dl
  801286:	74 1a                	je     8012a2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801288:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128b:	89 02                	mov    %eax,(%edx)
	return 0;
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	eb 13                	jmp    8012a7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801294:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801299:	eb 0c                	jmp    8012a7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a0:	eb 05                	jmp    8012a7 <fd_lookup+0x54>
  8012a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b2:	ba 00 27 80 00       	mov    $0x802700,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b7:	eb 13                	jmp    8012cc <dev_lookup+0x23>
  8012b9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012bc:	39 08                	cmp    %ecx,(%eax)
  8012be:	75 0c                	jne    8012cc <dev_lookup+0x23>
			*dev = devtab[i];
  8012c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ca:	eb 2e                	jmp    8012fa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012cc:	8b 02                	mov    (%edx),%eax
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	75 e7                	jne    8012b9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d7:	8b 40 48             	mov    0x48(%eax),%eax
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	51                   	push   %ecx
  8012de:	50                   	push   %eax
  8012df:	68 84 26 80 00       	push   $0x802684
  8012e4:	e8 c8 ee ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8012e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	83 ec 10             	sub    $0x10,%esp
  801304:	8b 75 08             	mov    0x8(%ebp),%esi
  801307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801314:	c1 e8 0c             	shr    $0xc,%eax
  801317:	50                   	push   %eax
  801318:	e8 36 ff ff ff       	call   801253 <fd_lookup>
  80131d:	83 c4 08             	add    $0x8,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 05                	js     801329 <fd_close+0x2d>
	    || fd != fd2)
  801324:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801327:	74 0c                	je     801335 <fd_close+0x39>
		return (must_exist ? r : 0);
  801329:	84 db                	test   %bl,%bl
  80132b:	ba 00 00 00 00       	mov    $0x0,%edx
  801330:	0f 44 c2             	cmove  %edx,%eax
  801333:	eb 41                	jmp    801376 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 36                	pushl  (%esi)
  80133e:	e8 66 ff ff ff       	call   8012a9 <dev_lookup>
  801343:	89 c3                	mov    %eax,%ebx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 1a                	js     801366 <fd_close+0x6a>
		if (dev->dev_close)
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801352:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801357:	85 c0                	test   %eax,%eax
  801359:	74 0b                	je     801366 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	56                   	push   %esi
  80135f:	ff d0                	call   *%eax
  801361:	89 c3                	mov    %eax,%ebx
  801363:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	56                   	push   %esi
  80136a:	6a 00                	push   $0x0
  80136c:	e8 f4 f8 ff ff       	call   800c65 <sys_page_unmap>
	return r;
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	89 d8                	mov    %ebx,%eax
}
  801376:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801379:	5b                   	pop    %ebx
  80137a:	5e                   	pop    %esi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801383:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	ff 75 08             	pushl  0x8(%ebp)
  80138a:	e8 c4 fe ff ff       	call   801253 <fd_lookup>
  80138f:	83 c4 08             	add    $0x8,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 10                	js     8013a6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	6a 01                	push   $0x1
  80139b:	ff 75 f4             	pushl  -0xc(%ebp)
  80139e:	e8 59 ff ff ff       	call   8012fc <fd_close>
  8013a3:	83 c4 10             	add    $0x10,%esp
}
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <close_all>:

void
close_all(void)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013af:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	53                   	push   %ebx
  8013b8:	e8 c0 ff ff ff       	call   80137d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bd:	83 c3 01             	add    $0x1,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	83 fb 20             	cmp    $0x20,%ebx
  8013c6:	75 ec                	jne    8013b4 <close_all+0xc>
		close(i);
}
  8013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	57                   	push   %edi
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 2c             	sub    $0x2c,%esp
  8013d6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013dc:	50                   	push   %eax
  8013dd:	ff 75 08             	pushl  0x8(%ebp)
  8013e0:	e8 6e fe ff ff       	call   801253 <fd_lookup>
  8013e5:	83 c4 08             	add    $0x8,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	0f 88 c1 00 00 00    	js     8014b1 <dup+0xe4>
		return r;
	close(newfdnum);
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	56                   	push   %esi
  8013f4:	e8 84 ff ff ff       	call   80137d <close>

	newfd = INDEX2FD(newfdnum);
  8013f9:	89 f3                	mov    %esi,%ebx
  8013fb:	c1 e3 0c             	shl    $0xc,%ebx
  8013fe:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801404:	83 c4 04             	add    $0x4,%esp
  801407:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140a:	e8 de fd ff ff       	call   8011ed <fd2data>
  80140f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801411:	89 1c 24             	mov    %ebx,(%esp)
  801414:	e8 d4 fd ff ff       	call   8011ed <fd2data>
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141f:	89 f8                	mov    %edi,%eax
  801421:	c1 e8 16             	shr    $0x16,%eax
  801424:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142b:	a8 01                	test   $0x1,%al
  80142d:	74 37                	je     801466 <dup+0x99>
  80142f:	89 f8                	mov    %edi,%eax
  801431:	c1 e8 0c             	shr    $0xc,%eax
  801434:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143b:	f6 c2 01             	test   $0x1,%dl
  80143e:	74 26                	je     801466 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801440:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801447:	83 ec 0c             	sub    $0xc,%esp
  80144a:	25 07 0e 00 00       	and    $0xe07,%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 d4             	pushl  -0x2c(%ebp)
  801453:	6a 00                	push   $0x0
  801455:	57                   	push   %edi
  801456:	6a 00                	push   $0x0
  801458:	e8 c6 f7 ff ff       	call   800c23 <sys_page_map>
  80145d:	89 c7                	mov    %eax,%edi
  80145f:	83 c4 20             	add    $0x20,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 2e                	js     801494 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801466:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801469:	89 d0                	mov    %edx,%eax
  80146b:	c1 e8 0c             	shr    $0xc,%eax
  80146e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	25 07 0e 00 00       	and    $0xe07,%eax
  80147d:	50                   	push   %eax
  80147e:	53                   	push   %ebx
  80147f:	6a 00                	push   $0x0
  801481:	52                   	push   %edx
  801482:	6a 00                	push   $0x0
  801484:	e8 9a f7 ff ff       	call   800c23 <sys_page_map>
  801489:	89 c7                	mov    %eax,%edi
  80148b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801490:	85 ff                	test   %edi,%edi
  801492:	79 1d                	jns    8014b1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	53                   	push   %ebx
  801498:	6a 00                	push   $0x0
  80149a:	e8 c6 f7 ff ff       	call   800c65 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 b9 f7 ff ff       	call   800c65 <sys_page_unmap>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 f8                	mov    %edi,%eax
}
  8014b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 14             	sub    $0x14,%esp
  8014c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	53                   	push   %ebx
  8014c8:	e8 86 fd ff ff       	call   801253 <fd_lookup>
  8014cd:	83 c4 08             	add    $0x8,%esp
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 6d                	js     801543 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e0:	ff 30                	pushl  (%eax)
  8014e2:	e8 c2 fd ff ff       	call   8012a9 <dev_lookup>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 4c                	js     80153a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f1:	8b 42 08             	mov    0x8(%edx),%eax
  8014f4:	83 e0 03             	and    $0x3,%eax
  8014f7:	83 f8 01             	cmp    $0x1,%eax
  8014fa:	75 21                	jne    80151d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801501:	8b 40 48             	mov    0x48(%eax),%eax
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	53                   	push   %ebx
  801508:	50                   	push   %eax
  801509:	68 c5 26 80 00       	push   $0x8026c5
  80150e:	e8 9e ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151b:	eb 26                	jmp    801543 <read+0x8a>
	}
	if (!dev->dev_read)
  80151d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801520:	8b 40 08             	mov    0x8(%eax),%eax
  801523:	85 c0                	test   %eax,%eax
  801525:	74 17                	je     80153e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	ff 75 10             	pushl  0x10(%ebp)
  80152d:	ff 75 0c             	pushl  0xc(%ebp)
  801530:	52                   	push   %edx
  801531:	ff d0                	call   *%eax
  801533:	89 c2                	mov    %eax,%edx
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	eb 09                	jmp    801543 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	eb 05                	jmp    801543 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801543:	89 d0                	mov    %edx,%eax
  801545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	8b 7d 08             	mov    0x8(%ebp),%edi
  801556:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801559:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155e:	eb 21                	jmp    801581 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	89 f0                	mov    %esi,%eax
  801565:	29 d8                	sub    %ebx,%eax
  801567:	50                   	push   %eax
  801568:	89 d8                	mov    %ebx,%eax
  80156a:	03 45 0c             	add    0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	57                   	push   %edi
  80156f:	e8 45 ff ff ff       	call   8014b9 <read>
		if (m < 0)
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 10                	js     80158b <readn+0x41>
			return m;
		if (m == 0)
  80157b:	85 c0                	test   %eax,%eax
  80157d:	74 0a                	je     801589 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157f:	01 c3                	add    %eax,%ebx
  801581:	39 f3                	cmp    %esi,%ebx
  801583:	72 db                	jb     801560 <readn+0x16>
  801585:	89 d8                	mov    %ebx,%eax
  801587:	eb 02                	jmp    80158b <readn+0x41>
  801589:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80158b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 14             	sub    $0x14,%esp
  80159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	53                   	push   %ebx
  8015a2:	e8 ac fc ff ff       	call   801253 <fd_lookup>
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 68                	js     801618 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ba:	ff 30                	pushl  (%eax)
  8015bc:	e8 e8 fc ff ff       	call   8012a9 <dev_lookup>
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 47                	js     80160f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cf:	75 21                	jne    8015f2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d6:	8b 40 48             	mov    0x48(%eax),%eax
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	50                   	push   %eax
  8015de:	68 e1 26 80 00       	push   $0x8026e1
  8015e3:	e8 c9 eb ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f0:	eb 26                	jmp    801618 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f8:	85 d2                	test   %edx,%edx
  8015fa:	74 17                	je     801613 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	ff 75 10             	pushl  0x10(%ebp)
  801602:	ff 75 0c             	pushl  0xc(%ebp)
  801605:	50                   	push   %eax
  801606:	ff d2                	call   *%edx
  801608:	89 c2                	mov    %eax,%edx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	eb 09                	jmp    801618 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	89 c2                	mov    %eax,%edx
  801611:	eb 05                	jmp    801618 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801613:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801618:	89 d0                	mov    %edx,%eax
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <seek>:

int
seek(int fdnum, off_t offset)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801625:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	ff 75 08             	pushl  0x8(%ebp)
  80162c:	e8 22 fc ff ff       	call   801253 <fd_lookup>
  801631:	83 c4 08             	add    $0x8,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 0e                	js     801646 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801638:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 14             	sub    $0x14,%esp
  80164f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	53                   	push   %ebx
  801657:	e8 f7 fb ff ff       	call   801253 <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 65                	js     8016ca <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	ff 30                	pushl  (%eax)
  801671:	e8 33 fc ff ff       	call   8012a9 <dev_lookup>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 44                	js     8016c1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801684:	75 21                	jne    8016a7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801686:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168b:	8b 40 48             	mov    0x48(%eax),%eax
  80168e:	83 ec 04             	sub    $0x4,%esp
  801691:	53                   	push   %ebx
  801692:	50                   	push   %eax
  801693:	68 a4 26 80 00       	push   $0x8026a4
  801698:	e8 14 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a5:	eb 23                	jmp    8016ca <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016aa:	8b 52 18             	mov    0x18(%edx),%edx
  8016ad:	85 d2                	test   %edx,%edx
  8016af:	74 14                	je     8016c5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	ff 75 0c             	pushl  0xc(%ebp)
  8016b7:	50                   	push   %eax
  8016b8:	ff d2                	call   *%edx
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb 09                	jmp    8016ca <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c1:	89 c2                	mov    %eax,%edx
  8016c3:	eb 05                	jmp    8016ca <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ca:	89 d0                	mov    %edx,%eax
  8016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 14             	sub    $0x14,%esp
  8016d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	ff 75 08             	pushl  0x8(%ebp)
  8016e2:	e8 6c fb ff ff       	call   801253 <fd_lookup>
  8016e7:	83 c4 08             	add    $0x8,%esp
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 58                	js     801748 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f6:	50                   	push   %eax
  8016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fa:	ff 30                	pushl  (%eax)
  8016fc:	e8 a8 fb ff ff       	call   8012a9 <dev_lookup>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	85 c0                	test   %eax,%eax
  801706:	78 37                	js     80173f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170f:	74 32                	je     801743 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801711:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801714:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171b:	00 00 00 
	stat->st_isdir = 0;
  80171e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801725:	00 00 00 
	stat->st_dev = dev;
  801728:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	53                   	push   %ebx
  801732:	ff 75 f0             	pushl  -0x10(%ebp)
  801735:	ff 50 14             	call   *0x14(%eax)
  801738:	89 c2                	mov    %eax,%edx
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	eb 09                	jmp    801748 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173f:	89 c2                	mov    %eax,%edx
  801741:	eb 05                	jmp    801748 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801743:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801748:	89 d0                	mov    %edx,%eax
  80174a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	6a 00                	push   $0x0
  801759:	ff 75 08             	pushl  0x8(%ebp)
  80175c:	e8 b7 01 00 00       	call   801918 <open>
  801761:	89 c3                	mov    %eax,%ebx
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 1b                	js     801785 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	ff 75 0c             	pushl  0xc(%ebp)
  801770:	50                   	push   %eax
  801771:	e8 5b ff ff ff       	call   8016d1 <fstat>
  801776:	89 c6                	mov    %eax,%esi
	close(fd);
  801778:	89 1c 24             	mov    %ebx,(%esp)
  80177b:	e8 fd fb ff ff       	call   80137d <close>
	return r;
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	89 f0                	mov    %esi,%eax
}
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	89 c6                	mov    %eax,%esi
  801793:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801795:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179c:	75 12                	jne    8017b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	6a 01                	push   $0x1
  8017a3:	e8 fc f9 ff ff       	call   8011a4 <ipc_find_env>
  8017a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b0:	6a 07                	push   $0x7
  8017b2:	68 00 50 80 00       	push   $0x805000
  8017b7:	56                   	push   %esi
  8017b8:	ff 35 00 40 80 00    	pushl  0x804000
  8017be:	e8 8d f9 ff ff       	call   801150 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c3:	83 c4 0c             	add    $0xc,%esp
  8017c6:	6a 00                	push   $0x0
  8017c8:	53                   	push   %ebx
  8017c9:	6a 00                	push   $0x0
  8017cb:	e8 0b f9 ff ff       	call   8010db <ipc_recv>
}
  8017d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5e                   	pop    %esi
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017eb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fa:	e8 8d ff ff ff       	call   80178c <fsipc>
}
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 40 0c             	mov    0xc(%eax),%eax
  80180d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801812:	ba 00 00 00 00       	mov    $0x0,%edx
  801817:	b8 06 00 00 00       	mov    $0x6,%eax
  80181c:	e8 6b ff ff ff       	call   80178c <fsipc>
}
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	83 ec 04             	sub    $0x4,%esp
  80182a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 40 0c             	mov    0xc(%eax),%eax
  801833:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801838:	ba 00 00 00 00       	mov    $0x0,%edx
  80183d:	b8 05 00 00 00       	mov    $0x5,%eax
  801842:	e8 45 ff ff ff       	call   80178c <fsipc>
  801847:	85 c0                	test   %eax,%eax
  801849:	78 2c                	js     801877 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	68 00 50 80 00       	push   $0x805000
  801853:	53                   	push   %ebx
  801854:	e8 84 ef ff ff       	call   8007dd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801859:	a1 80 50 80 00       	mov    0x805080,%eax
  80185e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801864:	a1 84 50 80 00       	mov    0x805084,%eax
  801869:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801882:	68 10 27 80 00       	push   $0x802710
  801887:	68 90 00 00 00       	push   $0x90
  80188c:	68 2e 27 80 00       	push   $0x80272e
  801891:	e8 05 06 00 00       	call   801e9b <_panic>

00801896 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b9:	e8 ce fe ff ff       	call   80178c <fsipc>
  8018be:	89 c3                	mov    %eax,%ebx
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 4b                	js     80190f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018c4:	39 c6                	cmp    %eax,%esi
  8018c6:	73 16                	jae    8018de <devfile_read+0x48>
  8018c8:	68 39 27 80 00       	push   $0x802739
  8018cd:	68 40 27 80 00       	push   $0x802740
  8018d2:	6a 7c                	push   $0x7c
  8018d4:	68 2e 27 80 00       	push   $0x80272e
  8018d9:	e8 bd 05 00 00       	call   801e9b <_panic>
	assert(r <= PGSIZE);
  8018de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e3:	7e 16                	jle    8018fb <devfile_read+0x65>
  8018e5:	68 55 27 80 00       	push   $0x802755
  8018ea:	68 40 27 80 00       	push   $0x802740
  8018ef:	6a 7d                	push   $0x7d
  8018f1:	68 2e 27 80 00       	push   $0x80272e
  8018f6:	e8 a0 05 00 00       	call   801e9b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018fb:	83 ec 04             	sub    $0x4,%esp
  8018fe:	50                   	push   %eax
  8018ff:	68 00 50 80 00       	push   $0x805000
  801904:	ff 75 0c             	pushl  0xc(%ebp)
  801907:	e8 63 f0 ff ff       	call   80096f <memmove>
	return r;
  80190c:	83 c4 10             	add    $0x10,%esp
}
  80190f:	89 d8                	mov    %ebx,%eax
  801911:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	53                   	push   %ebx
  80191c:	83 ec 20             	sub    $0x20,%esp
  80191f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801922:	53                   	push   %ebx
  801923:	e8 7c ee ff ff       	call   8007a4 <strlen>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801930:	7f 67                	jg     801999 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801938:	50                   	push   %eax
  801939:	e8 c6 f8 ff ff       	call   801204 <fd_alloc>
  80193e:	83 c4 10             	add    $0x10,%esp
		return r;
  801941:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801943:	85 c0                	test   %eax,%eax
  801945:	78 57                	js     80199e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	53                   	push   %ebx
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	e8 88 ee ff ff       	call   8007dd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801955:	8b 45 0c             	mov    0xc(%ebp),%eax
  801958:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80195d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801960:	b8 01 00 00 00       	mov    $0x1,%eax
  801965:	e8 22 fe ff ff       	call   80178c <fsipc>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	79 14                	jns    801987 <open+0x6f>
		fd_close(fd, 0);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	6a 00                	push   $0x0
  801978:	ff 75 f4             	pushl  -0xc(%ebp)
  80197b:	e8 7c f9 ff ff       	call   8012fc <fd_close>
		return r;
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	89 da                	mov    %ebx,%edx
  801985:	eb 17                	jmp    80199e <open+0x86>
	}

	return fd2num(fd);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	e8 4b f8 ff ff       	call   8011dd <fd2num>
  801992:	89 c2                	mov    %eax,%edx
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	eb 05                	jmp    80199e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801999:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80199e:	89 d0                	mov    %edx,%eax
  8019a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b5:	e8 d2 fd ff ff       	call   80178c <fsipc>
}
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c4:	83 ec 0c             	sub    $0xc,%esp
  8019c7:	ff 75 08             	pushl  0x8(%ebp)
  8019ca:	e8 1e f8 ff ff       	call   8011ed <fd2data>
  8019cf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d1:	83 c4 08             	add    $0x8,%esp
  8019d4:	68 61 27 80 00       	push   $0x802761
  8019d9:	53                   	push   %ebx
  8019da:	e8 fe ed ff ff       	call   8007dd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019df:	8b 46 04             	mov    0x4(%esi),%eax
  8019e2:	2b 06                	sub    (%esi),%eax
  8019e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f1:	00 00 00 
	stat->st_dev = &devpipe;
  8019f4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019fb:	30 80 00 
	return 0;
}
  8019fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801a03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a14:	53                   	push   %ebx
  801a15:	6a 00                	push   $0x0
  801a17:	e8 49 f2 ff ff       	call   800c65 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a1c:	89 1c 24             	mov    %ebx,(%esp)
  801a1f:	e8 c9 f7 ff ff       	call   8011ed <fd2data>
  801a24:	83 c4 08             	add    $0x8,%esp
  801a27:	50                   	push   %eax
  801a28:	6a 00                	push   $0x0
  801a2a:	e8 36 f2 ff ff       	call   800c65 <sys_page_unmap>
}
  801a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	57                   	push   %edi
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 1c             	sub    $0x1c,%esp
  801a3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a40:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a50:	e8 fc 04 00 00       	call   801f51 <pageref>
  801a55:	89 c3                	mov    %eax,%ebx
  801a57:	89 3c 24             	mov    %edi,(%esp)
  801a5a:	e8 f2 04 00 00       	call   801f51 <pageref>
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	39 c3                	cmp    %eax,%ebx
  801a64:	0f 94 c1             	sete   %cl
  801a67:	0f b6 c9             	movzbl %cl,%ecx
  801a6a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a6d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a73:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a76:	39 ce                	cmp    %ecx,%esi
  801a78:	74 1b                	je     801a95 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a7a:	39 c3                	cmp    %eax,%ebx
  801a7c:	75 c4                	jne    801a42 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a7e:	8b 42 58             	mov    0x58(%edx),%eax
  801a81:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a84:	50                   	push   %eax
  801a85:	56                   	push   %esi
  801a86:	68 68 27 80 00       	push   $0x802768
  801a8b:	e8 21 e7 ff ff       	call   8001b1 <cprintf>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	eb ad                	jmp    801a42 <_pipeisclosed+0xe>
	}
}
  801a95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5f                   	pop    %edi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 28             	sub    $0x28,%esp
  801aa9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aac:	56                   	push   %esi
  801aad:	e8 3b f7 ff ff       	call   8011ed <fd2data>
  801ab2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	bf 00 00 00 00       	mov    $0x0,%edi
  801abc:	eb 4b                	jmp    801b09 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801abe:	89 da                	mov    %ebx,%edx
  801ac0:	89 f0                	mov    %esi,%eax
  801ac2:	e8 6d ff ff ff       	call   801a34 <_pipeisclosed>
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	75 48                	jne    801b13 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801acb:	e8 f1 f0 ff ff       	call   800bc1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad3:	8b 0b                	mov    (%ebx),%ecx
  801ad5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ad8:	39 d0                	cmp    %edx,%eax
  801ada:	73 e2                	jae    801abe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801adf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ae6:	89 c2                	mov    %eax,%edx
  801ae8:	c1 fa 1f             	sar    $0x1f,%edx
  801aeb:	89 d1                	mov    %edx,%ecx
  801aed:	c1 e9 1b             	shr    $0x1b,%ecx
  801af0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af3:	83 e2 1f             	and    $0x1f,%edx
  801af6:	29 ca                	sub    %ecx,%edx
  801af8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801afc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b00:	83 c0 01             	add    $0x1,%eax
  801b03:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b06:	83 c7 01             	add    $0x1,%edi
  801b09:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b0c:	75 c2                	jne    801ad0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b11:	eb 05                	jmp    801b18 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	57                   	push   %edi
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 18             	sub    $0x18,%esp
  801b29:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b2c:	57                   	push   %edi
  801b2d:	e8 bb f6 ff ff       	call   8011ed <fd2data>
  801b32:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b3c:	eb 3d                	jmp    801b7b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b3e:	85 db                	test   %ebx,%ebx
  801b40:	74 04                	je     801b46 <devpipe_read+0x26>
				return i;
  801b42:	89 d8                	mov    %ebx,%eax
  801b44:	eb 44                	jmp    801b8a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b46:	89 f2                	mov    %esi,%edx
  801b48:	89 f8                	mov    %edi,%eax
  801b4a:	e8 e5 fe ff ff       	call   801a34 <_pipeisclosed>
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	75 32                	jne    801b85 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b53:	e8 69 f0 ff ff       	call   800bc1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b58:	8b 06                	mov    (%esi),%eax
  801b5a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b5d:	74 df                	je     801b3e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b5f:	99                   	cltd   
  801b60:	c1 ea 1b             	shr    $0x1b,%edx
  801b63:	01 d0                	add    %edx,%eax
  801b65:	83 e0 1f             	and    $0x1f,%eax
  801b68:	29 d0                	sub    %edx,%eax
  801b6a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b72:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b75:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b78:	83 c3 01             	add    $0x1,%ebx
  801b7b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b7e:	75 d8                	jne    801b58 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b80:	8b 45 10             	mov    0x10(%ebp),%eax
  801b83:	eb 05                	jmp    801b8a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b85:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5e                   	pop    %esi
  801b8f:	5f                   	pop    %edi
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    

00801b92 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9d:	50                   	push   %eax
  801b9e:	e8 61 f6 ff ff       	call   801204 <fd_alloc>
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	89 c2                	mov    %eax,%edx
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	0f 88 2c 01 00 00    	js     801cdc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 1e f0 ff ff       	call   800be0 <sys_page_alloc>
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	89 c2                	mov    %eax,%edx
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	0f 88 0d 01 00 00    	js     801cdc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	e8 29 f6 ff ff       	call   801204 <fd_alloc>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 e2 00 00 00    	js     801cca <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 e6 ef ff ff       	call   800be0 <sys_page_alloc>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	0f 88 c3 00 00 00    	js     801cca <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c07:	83 ec 0c             	sub    $0xc,%esp
  801c0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0d:	e8 db f5 ff ff       	call   8011ed <fd2data>
  801c12:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c14:	83 c4 0c             	add    $0xc,%esp
  801c17:	68 07 04 00 00       	push   $0x407
  801c1c:	50                   	push   %eax
  801c1d:	6a 00                	push   $0x0
  801c1f:	e8 bc ef ff ff       	call   800be0 <sys_page_alloc>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	0f 88 89 00 00 00    	js     801cba <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	ff 75 f0             	pushl  -0x10(%ebp)
  801c37:	e8 b1 f5 ff ff       	call   8011ed <fd2data>
  801c3c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c43:	50                   	push   %eax
  801c44:	6a 00                	push   $0x0
  801c46:	56                   	push   %esi
  801c47:	6a 00                	push   $0x0
  801c49:	e8 d5 ef ff ff       	call   800c23 <sys_page_map>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	83 c4 20             	add    $0x20,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 55                	js     801cac <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c57:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c60:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c6c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c75:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	ff 75 f4             	pushl  -0xc(%ebp)
  801c87:	e8 51 f5 ff ff       	call   8011dd <fd2num>
  801c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c91:	83 c4 04             	add    $0x4,%esp
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	e8 41 f5 ff ff       	call   8011dd <fd2num>
  801c9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca2:	83 c4 10             	add    $0x10,%esp
  801ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  801caa:	eb 30                	jmp    801cdc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cac:	83 ec 08             	sub    $0x8,%esp
  801caf:	56                   	push   %esi
  801cb0:	6a 00                	push   $0x0
  801cb2:	e8 ae ef ff ff       	call   800c65 <sys_page_unmap>
  801cb7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 9e ef ff ff       	call   800c65 <sys_page_unmap>
  801cc7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 8e ef ff ff       	call   800c65 <sys_page_unmap>
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cdc:	89 d0                	mov    %edx,%eax
  801cde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cee:	50                   	push   %eax
  801cef:	ff 75 08             	pushl  0x8(%ebp)
  801cf2:	e8 5c f5 ff ff       	call   801253 <fd_lookup>
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 18                	js     801d16 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f4             	pushl  -0xc(%ebp)
  801d04:	e8 e4 f4 ff ff       	call   8011ed <fd2data>
	return _pipeisclosed(fd, p);
  801d09:	89 c2                	mov    %eax,%edx
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	e8 21 fd ff ff       	call   801a34 <_pipeisclosed>
  801d13:	83 c4 10             	add    $0x10,%esp
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d28:	68 80 27 80 00       	push   $0x802780
  801d2d:	ff 75 0c             	pushl  0xc(%ebp)
  801d30:	e8 a8 ea ff ff       	call   8007dd <strcpy>
	return 0;
}
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d48:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d4d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d53:	eb 2d                	jmp    801d82 <devcons_write+0x46>
		m = n - tot;
  801d55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d58:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d5a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d5d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d62:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d65:	83 ec 04             	sub    $0x4,%esp
  801d68:	53                   	push   %ebx
  801d69:	03 45 0c             	add    0xc(%ebp),%eax
  801d6c:	50                   	push   %eax
  801d6d:	57                   	push   %edi
  801d6e:	e8 fc eb ff ff       	call   80096f <memmove>
		sys_cputs(buf, m);
  801d73:	83 c4 08             	add    $0x8,%esp
  801d76:	53                   	push   %ebx
  801d77:	57                   	push   %edi
  801d78:	e8 a7 ed ff ff       	call   800b24 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7d:	01 de                	add    %ebx,%esi
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	89 f0                	mov    %esi,%eax
  801d84:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d87:	72 cc                	jb     801d55 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8c:	5b                   	pop    %ebx
  801d8d:	5e                   	pop    %esi
  801d8e:	5f                   	pop    %edi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	83 ec 08             	sub    $0x8,%esp
  801d97:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da0:	74 2a                	je     801dcc <devcons_read+0x3b>
  801da2:	eb 05                	jmp    801da9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801da4:	e8 18 ee ff ff       	call   800bc1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801da9:	e8 94 ed ff ff       	call   800b42 <sys_cgetc>
  801dae:	85 c0                	test   %eax,%eax
  801db0:	74 f2                	je     801da4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 16                	js     801dcc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801db6:	83 f8 04             	cmp    $0x4,%eax
  801db9:	74 0c                	je     801dc7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbe:	88 02                	mov    %al,(%edx)
	return 1;
  801dc0:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc5:	eb 05                	jmp    801dcc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dc7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dda:	6a 01                	push   $0x1
  801ddc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	e8 3f ed ff ff       	call   800b24 <sys_cputs>
}
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <getchar>:

int
getchar(void)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df0:	6a 01                	push   $0x1
  801df2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df5:	50                   	push   %eax
  801df6:	6a 00                	push   $0x0
  801df8:	e8 bc f6 ff ff       	call   8014b9 <read>
	if (r < 0)
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 0f                	js     801e13 <getchar+0x29>
		return r;
	if (r < 1)
  801e04:	85 c0                	test   %eax,%eax
  801e06:	7e 06                	jle    801e0e <getchar+0x24>
		return -E_EOF;
	return c;
  801e08:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e0c:	eb 05                	jmp    801e13 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e0e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	ff 75 08             	pushl  0x8(%ebp)
  801e22:	e8 2c f4 ff ff       	call   801253 <fd_lookup>
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 11                	js     801e3f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e31:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e37:	39 10                	cmp    %edx,(%eax)
  801e39:	0f 94 c0             	sete   %al
  801e3c:	0f b6 c0             	movzbl %al,%eax
}
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <opencons>:

int
opencons(void)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4a:	50                   	push   %eax
  801e4b:	e8 b4 f3 ff ff       	call   801204 <fd_alloc>
  801e50:	83 c4 10             	add    $0x10,%esp
		return r;
  801e53:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e55:	85 c0                	test   %eax,%eax
  801e57:	78 3e                	js     801e97 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e59:	83 ec 04             	sub    $0x4,%esp
  801e5c:	68 07 04 00 00       	push   $0x407
  801e61:	ff 75 f4             	pushl  -0xc(%ebp)
  801e64:	6a 00                	push   $0x0
  801e66:	e8 75 ed ff ff       	call   800be0 <sys_page_alloc>
  801e6b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e6e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e70:	85 c0                	test   %eax,%eax
  801e72:	78 23                	js     801e97 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e74:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e82:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e89:	83 ec 0c             	sub    $0xc,%esp
  801e8c:	50                   	push   %eax
  801e8d:	e8 4b f3 ff ff       	call   8011dd <fd2num>
  801e92:	89 c2                	mov    %eax,%edx
  801e94:	83 c4 10             	add    $0x10,%esp
}
  801e97:	89 d0                	mov    %edx,%eax
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	56                   	push   %esi
  801e9f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ea0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ea3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ea9:	e8 f4 ec ff ff       	call   800ba2 <sys_getenvid>
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	ff 75 0c             	pushl  0xc(%ebp)
  801eb4:	ff 75 08             	pushl  0x8(%ebp)
  801eb7:	56                   	push   %esi
  801eb8:	50                   	push   %eax
  801eb9:	68 8c 27 80 00       	push   $0x80278c
  801ebe:	e8 ee e2 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ec3:	83 c4 18             	add    $0x18,%esp
  801ec6:	53                   	push   %ebx
  801ec7:	ff 75 10             	pushl  0x10(%ebp)
  801eca:	e8 91 e2 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801ecf:	c7 04 24 79 27 80 00 	movl   $0x802779,(%esp)
  801ed6:	e8 d6 e2 ff ff       	call   8001b1 <cprintf>
  801edb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ede:	cc                   	int3   
  801edf:	eb fd                	jmp    801ede <_panic+0x43>

00801ee1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ee7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eee:	75 31                	jne    801f21 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801ef0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef5:	8b 40 48             	mov    0x48(%eax),%eax
  801ef8:	83 ec 04             	sub    $0x4,%esp
  801efb:	6a 07                	push   $0x7
  801efd:	68 00 f0 bf ee       	push   $0xeebff000
  801f02:	50                   	push   %eax
  801f03:	e8 d8 ec ff ff       	call   800be0 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801f08:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0d:	8b 40 48             	mov    0x48(%eax),%eax
  801f10:	83 c4 08             	add    $0x8,%esp
  801f13:	68 2b 1f 80 00       	push   $0x801f2b
  801f18:	50                   	push   %eax
  801f19:	e8 0d ee ff ff       	call   800d2b <sys_env_set_pgfault_upcall>
  801f1e:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f21:	8b 45 08             	mov    0x8(%ebp),%eax
  801f24:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f2b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f2c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f31:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f33:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801f36:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801f39:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801f3d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801f41:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801f44:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801f46:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f4a:	61                   	popa   
	addl $4, %esp        // skip eip
  801f4b:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801f4e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801f4f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f50:	c3                   	ret    

00801f51 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f57:	89 d0                	mov    %edx,%eax
  801f59:	c1 e8 16             	shr    $0x16,%eax
  801f5c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f68:	f6 c1 01             	test   $0x1,%cl
  801f6b:	74 1d                	je     801f8a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6d:	c1 ea 0c             	shr    $0xc,%edx
  801f70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f77:	f6 c2 01             	test   $0x1,%dl
  801f7a:	74 0e                	je     801f8a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7c:	c1 ea 0c             	shr    $0xc,%edx
  801f7f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f86:	ef 
  801f87:	0f b7 c0             	movzwl %ax,%eax
}
  801f8a:	5d                   	pop    %ebp
  801f8b:	c3                   	ret    
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
