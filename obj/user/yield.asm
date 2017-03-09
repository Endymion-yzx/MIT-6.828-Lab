
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 80 1e 80 00       	push   $0x801e80
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 43 0b 00 00       	call   800b9d <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 a0 1e 80 00       	push   $0x801ea0
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 cc 1e 80 00       	push   $0x801ecc
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000a5:	e8 d4 0a 00 00       	call   800b7e <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 8d 0e 00 00       	call   800f78 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 48 0a 00 00       	call   800b3d <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 d6 09 00 00       	call   800b00 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 1a 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 7b 09 00 00       	call   800b00 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 fb 19 00 00       	call   801bf0 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 e8 1a 00 00       	call   801d20 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 f5 1e 80 00 	movsbl 0x801ef5(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 6a 04 00 00    	je     800710 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	eb 07                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	0f b6 07             	movzbl (%edi),%eax
  8002ec:	0f b6 d0             	movzbl %al,%edx
  8002ef:	83 e8 23             	sub    $0x23,%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 fb 03 00 00    	ja     8006f5 <vprintfmt+0x46b>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030b:	eb d6                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80031f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800322:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800325:	83 f9 09             	cmp    $0x9,%ecx
  800328:	77 3f                	ja     800369 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8b 00                	mov    (%eax),%eax
  800334:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 40 04             	lea    0x4(%eax),%eax
  80033d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800343:	eb 2a                	jmp    80036f <vprintfmt+0xe5>
  800345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800348:	85 c0                	test   %eax,%eax
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	0f 49 d0             	cmovns %eax,%edx
  800352:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	eb 89                	jmp    8002e3 <vprintfmt+0x59>
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800364:	e9 7a ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
  800369:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80036f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800373:	0f 89 6a ff ff ff    	jns    8002e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800379:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	e9 58 ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800391:	e9 4d ff ff ff       	jmp    8002e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8d 78 04             	lea    0x4(%eax),%edi
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	ff 30                	pushl  (%eax)
  8003a2:	ff d6                	call   *%esi
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ad:	e9 fe fe ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 78 04             	lea    0x4(%eax),%edi
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	99                   	cltd   
  8003bb:	31 d0                	xor    %edx,%eax
  8003bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bf:	83 f8 0f             	cmp    $0xf,%eax
  8003c2:	7f 0b                	jg     8003cf <vprintfmt+0x145>
  8003c4:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	75 1b                	jne    8003ea <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003cf:	50                   	push   %eax
  8003d0:	68 0d 1f 80 00       	push   $0x801f0d
  8003d5:	53                   	push   %ebx
  8003d6:	56                   	push   %esi
  8003d7:	e8 91 fe ff ff       	call   80026d <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003df:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e5:	e9 c6 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ea:	52                   	push   %edx
  8003eb:	68 fa 22 80 00       	push   $0x8022fa
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 76 fe ff ff       	call   80026d <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800400:	e9 ab fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	83 c0 04             	add    $0x4,%eax
  80040b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800413:	85 ff                	test   %edi,%edi
  800415:	b8 06 1f 80 00       	mov    $0x801f06,%eax
  80041a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800421:	0f 8e 94 00 00 00    	jle    8004bb <vprintfmt+0x231>
  800427:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042b:	0f 84 98 00 00 00    	je     8004c9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 d0             	pushl  -0x30(%ebp)
  800437:	57                   	push   %edi
  800438:	e8 5b 03 00 00       	call   800798 <strnlen>
  80043d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800440:	29 c1                	sub    %eax,%ecx
  800442:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800445:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800448:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800452:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800454:	eb 0f                	jmp    800465 <vprintfmt+0x1db>
					putch(padc, putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	53                   	push   %ebx
  80045a:	ff 75 e0             	pushl  -0x20(%ebp)
  80045d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ef 01             	sub    $0x1,%edi
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	85 ff                	test   %edi,%edi
  800467:	7f ed                	jg     800456 <vprintfmt+0x1cc>
  800469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046f:	85 c9                	test   %ecx,%ecx
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	0f 49 c1             	cmovns %ecx,%eax
  800479:	29 c1                	sub    %eax,%ecx
  80047b:	89 75 08             	mov    %esi,0x8(%ebp)
  80047e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800481:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800484:	89 cb                	mov    %ecx,%ebx
  800486:	eb 4d                	jmp    8004d5 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800488:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048c:	74 1b                	je     8004a9 <vprintfmt+0x21f>
  80048e:	0f be c0             	movsbl %al,%eax
  800491:	83 e8 20             	sub    $0x20,%eax
  800494:	83 f8 5e             	cmp    $0x5e,%eax
  800497:	76 10                	jbe    8004a9 <vprintfmt+0x21f>
					putch('?', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 0c             	pushl  0xc(%ebp)
  80049f:	6a 3f                	push   $0x3f
  8004a1:	ff 55 08             	call   *0x8(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	eb 0d                	jmp    8004b6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 0c             	pushl  0xc(%ebp)
  8004af:	52                   	push   %edx
  8004b0:	ff 55 08             	call   *0x8(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b6:	83 eb 01             	sub    $0x1,%ebx
  8004b9:	eb 1a                	jmp    8004d5 <vprintfmt+0x24b>
  8004bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c7:	eb 0c                	jmp    8004d5 <vprintfmt+0x24b>
  8004c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d5:	83 c7 01             	add    $0x1,%edi
  8004d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dc:	0f be d0             	movsbl %al,%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 23                	je     800506 <vprintfmt+0x27c>
  8004e3:	85 f6                	test   %esi,%esi
  8004e5:	78 a1                	js     800488 <vprintfmt+0x1fe>
  8004e7:	83 ee 01             	sub    $0x1,%esi
  8004ea:	79 9c                	jns    800488 <vprintfmt+0x1fe>
  8004ec:	89 df                	mov    %ebx,%edi
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	eb 18                	jmp    80050e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	53                   	push   %ebx
  8004fa:	6a 20                	push   $0x20
  8004fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fe:	83 ef 01             	sub    $0x1,%edi
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	eb 08                	jmp    80050e <vprintfmt+0x284>
  800506:	89 df                	mov    %ebx,%edi
  800508:	8b 75 08             	mov    0x8(%ebp),%esi
  80050b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050e:	85 ff                	test   %edi,%edi
  800510:	7f e4                	jg     8004f6 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800512:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051b:	e9 90 fd ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800520:	83 f9 01             	cmp    $0x1,%ecx
  800523:	7e 19                	jle    80053e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 50 04             	mov    0x4(%eax),%edx
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800530:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 40 08             	lea    0x8(%eax),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
  80053c:	eb 38                	jmp    800576 <vprintfmt+0x2ec>
	else if (lflag)
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	74 1b                	je     80055d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 00                	mov    (%eax),%eax
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 c1                	mov    %eax,%ecx
  80054c:	c1 f9 1f             	sar    $0x1f,%ecx
  80054f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb 19                	jmp    800576 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800576:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800579:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800581:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800585:	0f 89 36 01 00 00    	jns    8006c1 <vprintfmt+0x437>
				putch('-', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 2d                	push   $0x2d
  800591:	ff d6                	call   *%esi
				num = -(long long) num;
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800599:	f7 da                	neg    %edx
  80059b:	83 d1 00             	adc    $0x0,%ecx
  80059e:	f7 d9                	neg    %ecx
  8005a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a8:	e9 14 01 00 00       	jmp    8006c1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ad:	83 f9 01             	cmp    $0x1,%ecx
  8005b0:	7e 18                	jle    8005ca <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ba:	8d 40 08             	lea    0x8(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c5:	e9 f7 00 00 00       	jmp    8006c1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	74 1a                	je     8005e8 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
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
  8005e3:	e9 d9 00 00 00       	jmp    8006c1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fd:	e9 bf 00 00 00       	jmp    8006c1 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800602:	83 f9 01             	cmp    $0x1,%ecx
  800605:	7e 13                	jle    80061a <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 50 04             	mov    0x4(%eax),%edx
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800612:	8d 49 08             	lea    0x8(%ecx),%ecx
  800615:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800618:	eb 28                	jmp    800642 <vprintfmt+0x3b8>
	else if (lflag)
  80061a:	85 c9                	test   %ecx,%ecx
  80061c:	74 13                	je     800631 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8b 10                	mov    (%eax),%edx
  800623:	89 d0                	mov    %edx,%eax
  800625:	99                   	cltd   
  800626:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800629:	8d 49 04             	lea    0x4(%ecx),%ecx
  80062c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062f:	eb 11                	jmp    800642 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	89 d0                	mov    %edx,%eax
  800638:	99                   	cltd   
  800639:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80063c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80063f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800642:	89 d1                	mov    %edx,%ecx
  800644:	89 c2                	mov    %eax,%edx
			base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80064b:	eb 74                	jmp    8006c1 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 30                	push   $0x30
  800653:	ff d6                	call   *%esi
			putch('x', putdat);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 78                	push   $0x78
  80065b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800675:	eb 4a                	jmp    8006c1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 15                	jle    800691 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8b 48 04             	mov    0x4(%eax),%ecx
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80068a:	b8 10 00 00 00       	mov    $0x10,%eax
  80068f:	eb 30                	jmp    8006c1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800691:	85 c9                	test   %ecx,%ecx
  800693:	74 17                	je     8006ac <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006aa:	eb 15                	jmp    8006c1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c8:	57                   	push   %edi
  8006c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cc:	50                   	push   %eax
  8006cd:	51                   	push   %ecx
  8006ce:	52                   	push   %edx
  8006cf:	89 da                	mov    %ebx,%edx
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	e8 c9 fa ff ff       	call   8001a1 <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006de:	e9 cd fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	52                   	push   %edx
  8006e8:	ff d6                	call   *%esi
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f0:	e9 bb fb ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 03                	jmp    800705 <vprintfmt+0x47b>
  800702:	83 ef 01             	sub    $0x1,%edi
  800705:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800709:	75 f7                	jne    800702 <vprintfmt+0x478>
  80070b:	e9 a0 fb ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 18             	sub    $0x18,%esp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800724:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800727:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 26                	je     80075f <vsnprintf+0x47>
  800739:	85 d2                	test   %edx,%edx
  80073b:	7e 22                	jle    80075f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	ff 75 14             	pushl  0x14(%ebp)
  800740:	ff 75 10             	pushl  0x10(%ebp)
  800743:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	68 50 02 80 00       	push   $0x800250
  80074c:	e8 39 fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800754:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 05                	jmp    800764 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	50                   	push   %eax
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	ff 75 08             	pushl  0x8(%ebp)
  800779:	e8 9a ff ff ff       	call   800718 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 03                	jmp    800790 <strlen+0x10>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800794:	75 f7                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a6:	eb 03                	jmp    8007ab <strnlen+0x13>
		n++;
  8007a8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 c2                	cmp    %eax,%edx
  8007ad:	74 08                	je     8007b7 <strnlen+0x1f>
  8007af:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b3:	75 f3                	jne    8007a8 <strnlen+0x10>
  8007b5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	83 c1 01             	add    $0x1,%ecx
  8007cb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ef                	jne    8007c5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e0:	53                   	push   %ebx
  8007e1:	e8 9a ff ff ff       	call   800780 <strlen>
  8007e6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	01 d8                	add    %ebx,%eax
  8007ee:	50                   	push   %eax
  8007ef:	e8 c5 ff ff ff       	call   8007b9 <strcpy>
	return dst;
}
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800806:	89 f3                	mov    %esi,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	89 f2                	mov    %esi,%edx
  80080d:	eb 0f                	jmp    80081e <strncpy+0x23>
		*dst++ = *src;
  80080f:	83 c2 01             	add    $0x1,%edx
  800812:	0f b6 01             	movzbl (%ecx),%eax
  800815:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800818:	80 39 01             	cmpb   $0x1,(%ecx)
  80081b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	39 da                	cmp    %ebx,%edx
  800820:	75 ed                	jne    80080f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800822:	89 f0                	mov    %esi,%eax
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
  800836:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 21                	je     80085d <strlcpy+0x35>
  80083c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800840:	89 f2                	mov    %esi,%edx
  800842:	eb 09                	jmp    80084d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084d:	39 c2                	cmp    %eax,%edx
  80084f:	74 09                	je     80085a <strlcpy+0x32>
  800851:	0f b6 19             	movzbl (%ecx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	75 ec                	jne    800844 <strlcpy+0x1c>
  800858:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	eb 06                	jmp    800874 <strcmp+0x11>
		p++, q++;
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	84 c0                	test   %al,%al
  800879:	74 04                	je     80087f <strcmp+0x1c>
  80087b:	3a 02                	cmp    (%edx),%al
  80087d:	74 ef                	je     80086e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 c0             	movzbl %al,%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 c3                	mov    %eax,%ebx
  800895:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strncmp+0x17>
		n--, p++, q++;
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a0:	39 d8                	cmp    %ebx,%eax
  8008a2:	74 15                	je     8008b9 <strncmp+0x30>
  8008a4:	0f b6 08             	movzbl (%eax),%ecx
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	74 04                	je     8008af <strncmp+0x26>
  8008ab:	3a 0a                	cmp    (%edx),%cl
  8008ad:	74 eb                	je     80089a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
  8008b7:	eb 05                	jmp    8008be <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 07                	jmp    8008d4 <strchr+0x13>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 0f                	je     8008e0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	0f b6 10             	movzbl (%eax),%edx
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ec:	eb 03                	jmp    8008f1 <strfind+0xf>
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 04                	je     8008fc <strfind+0x1a>
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f2                	jne    8008ee <strfind+0xc>
			break;
	return (char *) s;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090a:	85 c9                	test   %ecx,%ecx
  80090c:	74 36                	je     800944 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800914:	75 28                	jne    80093e <memset+0x40>
  800916:	f6 c1 03             	test   $0x3,%cl
  800919:	75 23                	jne    80093e <memset+0x40>
		c &= 0xFF;
  80091b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	c1 e3 08             	shl    $0x8,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 18             	shl    $0x18,%esi
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 10             	shl    $0x10,%eax
  80092e:	09 f0                	or     %esi,%eax
  800930:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800932:	89 d8                	mov    %ebx,%eax
  800934:	09 d0                	or     %edx,%eax
  800936:	c1 e9 02             	shr    $0x2,%ecx
  800939:	fc                   	cld    
  80093a:	f3 ab                	rep stos %eax,%es:(%edi)
  80093c:	eb 06                	jmp    800944 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	fc                   	cld    
  800942:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800944:	89 f8                	mov    %edi,%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 35                	jae    800992 <memmove+0x47>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 d0                	cmp    %edx,%eax
  800962:	73 2e                	jae    800992 <memmove+0x47>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 d6                	mov    %edx,%esi
  800969:	09 fe                	or     %edi,%esi
  80096b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800971:	75 13                	jne    800986 <memmove+0x3b>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0e                	jne    800986 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800978:	83 ef 04             	sub    $0x4,%edi
  80097b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	fd                   	std    
  800982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800984:	eb 09                	jmp    80098f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800986:	83 ef 01             	sub    $0x1,%edi
  800989:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098c:	fd                   	std    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098f:	fc                   	cld    
  800990:	eb 1d                	jmp    8009af <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	89 f2                	mov    %esi,%edx
  800994:	09 c2                	or     %eax,%edx
  800996:	f6 c2 03             	test   $0x3,%dl
  800999:	75 0f                	jne    8009aa <memmove+0x5f>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	75 0a                	jne    8009aa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
  8009a3:	89 c7                	mov    %eax,%edi
  8009a5:	fc                   	cld    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb 05                	jmp    8009af <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	ff 75 0c             	pushl  0xc(%ebp)
  8009bc:	ff 75 08             	pushl  0x8(%ebp)
  8009bf:	e8 87 ff ff ff       	call   80094b <memmove>
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d1:	89 c6                	mov    %eax,%esi
  8009d3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	eb 1a                	jmp    8009f2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d8:	0f b6 08             	movzbl (%eax),%ecx
  8009db:	0f b6 1a             	movzbl (%edx),%ebx
  8009de:	38 d9                	cmp    %bl,%cl
  8009e0:	74 0a                	je     8009ec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e2:	0f b6 c1             	movzbl %cl,%eax
  8009e5:	0f b6 db             	movzbl %bl,%ebx
  8009e8:	29 d8                	sub    %ebx,%eax
  8009ea:	eb 0f                	jmp    8009fb <memcmp+0x35>
		s1++, s2++;
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f2:	39 f0                	cmp    %esi,%eax
  8009f4:	75 e2                	jne    8009d8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a06:	89 c1                	mov    %eax,%ecx
  800a08:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0f:	eb 0a                	jmp    800a1b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	39 da                	cmp    %ebx,%edx
  800a16:	74 07                	je     800a1f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	39 c8                	cmp    %ecx,%eax
  800a1d:	72 f2                	jb     800a11 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2e:	eb 03                	jmp    800a33 <strtol+0x11>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	0f b6 01             	movzbl (%ecx),%eax
  800a36:	3c 20                	cmp    $0x20,%al
  800a38:	74 f6                	je     800a30 <strtol+0xe>
  800a3a:	3c 09                	cmp    $0x9,%al
  800a3c:	74 f2                	je     800a30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3e:	3c 2b                	cmp    $0x2b,%al
  800a40:	75 0a                	jne    800a4c <strtol+0x2a>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4a:	eb 11                	jmp    800a5d <strtol+0x3b>
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a51:	3c 2d                	cmp    $0x2d,%al
  800a53:	75 08                	jne    800a5d <strtol+0x3b>
		s++, neg = 1;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a63:	75 15                	jne    800a7a <strtol+0x58>
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	75 10                	jne    800a7a <strtol+0x58>
  800a6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6e:	75 7c                	jne    800aec <strtol+0xca>
		s += 2, base = 16;
  800a70:	83 c1 02             	add    $0x2,%ecx
  800a73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a78:	eb 16                	jmp    800a90 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	75 12                	jne    800a90 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a83:	80 39 30             	cmpb   $0x30,(%ecx)
  800a86:	75 08                	jne    800a90 <strtol+0x6e>
		s++, base = 8;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
  800a95:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a98:	0f b6 11             	movzbl (%ecx),%edx
  800a9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 09             	cmp    $0x9,%bl
  800aa3:	77 08                	ja     800aad <strtol+0x8b>
			dig = *s - '0';
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 30             	sub    $0x30,%edx
  800aab:	eb 22                	jmp    800acf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 08                	ja     800abf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 57             	sub    $0x57,%edx
  800abd:	eb 10                	jmp    800acf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 16                	ja     800adf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad2:	7d 0b                	jge    800adf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800add:	eb b9                	jmp    800a98 <strtol+0x76>

	if (endptr)
  800adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae3:	74 0d                	je     800af2 <strtol+0xd0>
		*endptr = (char *) s;
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae8:	89 0e                	mov    %ecx,(%esi)
  800aea:	eb 06                	jmp    800af2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	74 98                	je     800a88 <strtol+0x66>
  800af0:	eb 9e                	jmp    800a90 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	f7 da                	neg    %edx
  800af6:	85 ff                	test   %edi,%edi
  800af8:	0f 45 c2             	cmovne %edx,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	89 c6                	mov    %eax,%esi
  800b17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	89 cb                	mov    %ecx,%ebx
  800b55:	89 cf                	mov    %ecx,%edi
  800b57:	89 ce                	mov    %ecx,%esi
  800b59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 17                	jle    800b76 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	6a 03                	push   $0x3
  800b65:	68 ff 21 80 00       	push   $0x8021ff
  800b6a:	6a 23                	push   $0x23
  800b6c:	68 1c 22 80 00       	push   $0x80221c
  800b71:	e8 f5 0e 00 00       	call   801a6b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_yield>:

void
sys_yield(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	be 00 00 00 00       	mov    $0x0,%esi
  800bca:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd8:	89 f7                	mov    %esi,%edi
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 04                	push   $0x4
  800be6:	68 ff 21 80 00       	push   $0x8021ff
  800beb:	6a 23                	push   $0x23
  800bed:	68 1c 22 80 00       	push   $0x80221c
  800bf2:	e8 74 0e 00 00       	call   801a6b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c19:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 05                	push   $0x5
  800c28:	68 ff 21 80 00       	push   $0x8021ff
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 1c 22 80 00       	push   $0x80221c
  800c34:	e8 32 0e 00 00       	call   801a6b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 06                	push   $0x6
  800c6a:	68 ff 21 80 00       	push   $0x8021ff
  800c6f:	6a 23                	push   $0x23
  800c71:	68 1c 22 80 00       	push   $0x80221c
  800c76:	e8 f0 0d 00 00       	call   801a6b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 08 00 00 00       	mov    $0x8,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 08                	push   $0x8
  800cac:	68 ff 21 80 00       	push   $0x8021ff
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 1c 22 80 00       	push   $0x80221c
  800cb8:	e8 ae 0d 00 00       	call   801a6b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	89 de                	mov    %ebx,%esi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 09                	push   $0x9
  800cee:	68 ff 21 80 00       	push   $0x8021ff
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 1c 22 80 00       	push   $0x80221c
  800cfa:	e8 6c 0d 00 00       	call   801a6b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 0a                	push   $0xa
  800d30:	68 ff 21 80 00       	push   $0x8021ff
  800d35:	6a 23                	push   $0x23
  800d37:	68 1c 22 80 00       	push   $0x80221c
  800d3c:	e8 2a 0d 00 00       	call   801a6b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	be 00 00 00 00       	mov    $0x0,%esi
  800d54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d65:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 cb                	mov    %ecx,%ebx
  800d84:	89 cf                	mov    %ecx,%edi
  800d86:	89 ce                	mov    %ecx,%esi
  800d88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	7e 17                	jle    800da5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	50                   	push   %eax
  800d92:	6a 0d                	push   $0xd
  800d94:	68 ff 21 80 00       	push   $0x8021ff
  800d99:	6a 23                	push   $0x23
  800d9b:	68 1c 22 80 00       	push   $0x80221c
  800da0:	e8 c6 0c 00 00       	call   801a6b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	05 00 00 00 30       	add    $0x30000000,%eax
  800db8:	c1 e8 0c             	shr    $0xc,%eax
}
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dda:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ddf:	89 c2                	mov    %eax,%edx
  800de1:	c1 ea 16             	shr    $0x16,%edx
  800de4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800deb:	f6 c2 01             	test   $0x1,%dl
  800dee:	74 11                	je     800e01 <fd_alloc+0x2d>
  800df0:	89 c2                	mov    %eax,%edx
  800df2:	c1 ea 0c             	shr    $0xc,%edx
  800df5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfc:	f6 c2 01             	test   $0x1,%dl
  800dff:	75 09                	jne    800e0a <fd_alloc+0x36>
			*fd_store = fd;
  800e01:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
  800e08:	eb 17                	jmp    800e21 <fd_alloc+0x4d>
  800e0a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e0f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e14:	75 c9                	jne    800ddf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e16:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e1c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e29:	83 f8 1f             	cmp    $0x1f,%eax
  800e2c:	77 36                	ja     800e64 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e2e:	c1 e0 0c             	shl    $0xc,%eax
  800e31:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	c1 ea 16             	shr    $0x16,%edx
  800e3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e42:	f6 c2 01             	test   $0x1,%dl
  800e45:	74 24                	je     800e6b <fd_lookup+0x48>
  800e47:	89 c2                	mov    %eax,%edx
  800e49:	c1 ea 0c             	shr    $0xc,%edx
  800e4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e53:	f6 c2 01             	test   $0x1,%dl
  800e56:	74 1a                	je     800e72 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	eb 13                	jmp    800e77 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e69:	eb 0c                	jmp    800e77 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e70:	eb 05                	jmp    800e77 <fd_lookup+0x54>
  800e72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 08             	sub    $0x8,%esp
  800e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e82:	ba a8 22 80 00       	mov    $0x8022a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e87:	eb 13                	jmp    800e9c <dev_lookup+0x23>
  800e89:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e8c:	39 08                	cmp    %ecx,(%eax)
  800e8e:	75 0c                	jne    800e9c <dev_lookup+0x23>
			*dev = devtab[i];
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	eb 2e                	jmp    800eca <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e9c:	8b 02                	mov    (%edx),%eax
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	75 e7                	jne    800e89 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea2:	a1 04 40 80 00       	mov    0x804004,%eax
  800ea7:	8b 40 48             	mov    0x48(%eax),%eax
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	51                   	push   %ecx
  800eae:	50                   	push   %eax
  800eaf:	68 2c 22 80 00       	push   $0x80222c
  800eb4:	e8 d4 f2 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 10             	sub    $0x10,%esp
  800ed4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edd:	50                   	push   %eax
  800ede:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ee4:	c1 e8 0c             	shr    $0xc,%eax
  800ee7:	50                   	push   %eax
  800ee8:	e8 36 ff ff ff       	call   800e23 <fd_lookup>
  800eed:	83 c4 08             	add    $0x8,%esp
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	78 05                	js     800ef9 <fd_close+0x2d>
	    || fd != fd2)
  800ef4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef7:	74 0c                	je     800f05 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ef9:	84 db                	test   %bl,%bl
  800efb:	ba 00 00 00 00       	mov    $0x0,%edx
  800f00:	0f 44 c2             	cmove  %edx,%eax
  800f03:	eb 41                	jmp    800f46 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f0b:	50                   	push   %eax
  800f0c:	ff 36                	pushl  (%esi)
  800f0e:	e8 66 ff ff ff       	call   800e79 <dev_lookup>
  800f13:	89 c3                	mov    %eax,%ebx
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 1a                	js     800f36 <fd_close+0x6a>
		if (dev->dev_close)
  800f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	74 0b                	je     800f36 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	56                   	push   %esi
  800f2f:	ff d0                	call   *%eax
  800f31:	89 c3                	mov    %eax,%ebx
  800f33:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	56                   	push   %esi
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 00 fd ff ff       	call   800c41 <sys_page_unmap>
	return r;
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	89 d8                	mov    %ebx,%eax
}
  800f46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	ff 75 08             	pushl  0x8(%ebp)
  800f5a:	e8 c4 fe ff ff       	call   800e23 <fd_lookup>
  800f5f:	83 c4 08             	add    $0x8,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 10                	js     800f76 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f66:	83 ec 08             	sub    $0x8,%esp
  800f69:	6a 01                	push   $0x1
  800f6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6e:	e8 59 ff ff ff       	call   800ecc <fd_close>
  800f73:	83 c4 10             	add    $0x10,%esp
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <close_all>:

void
close_all(void)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	53                   	push   %ebx
  800f88:	e8 c0 ff ff ff       	call   800f4d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8d:	83 c3 01             	add    $0x1,%ebx
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	83 fb 20             	cmp    $0x20,%ebx
  800f96:	75 ec                	jne    800f84 <close_all+0xc>
		close(i);
}
  800f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 2c             	sub    $0x2c,%esp
  800fa6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fa9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	ff 75 08             	pushl  0x8(%ebp)
  800fb0:	e8 6e fe ff ff       	call   800e23 <fd_lookup>
  800fb5:	83 c4 08             	add    $0x8,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	0f 88 c1 00 00 00    	js     801081 <dup+0xe4>
		return r;
	close(newfdnum);
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	56                   	push   %esi
  800fc4:	e8 84 ff ff ff       	call   800f4d <close>

	newfd = INDEX2FD(newfdnum);
  800fc9:	89 f3                	mov    %esi,%ebx
  800fcb:	c1 e3 0c             	shl    $0xc,%ebx
  800fce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fd4:	83 c4 04             	add    $0x4,%esp
  800fd7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fda:	e8 de fd ff ff       	call   800dbd <fd2data>
  800fdf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fe1:	89 1c 24             	mov    %ebx,(%esp)
  800fe4:	e8 d4 fd ff ff       	call   800dbd <fd2data>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fef:	89 f8                	mov    %edi,%eax
  800ff1:	c1 e8 16             	shr    $0x16,%eax
  800ff4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffb:	a8 01                	test   $0x1,%al
  800ffd:	74 37                	je     801036 <dup+0x99>
  800fff:	89 f8                	mov    %edi,%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
  801004:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100b:	f6 c2 01             	test   $0x1,%dl
  80100e:	74 26                	je     801036 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	25 07 0e 00 00       	and    $0xe07,%eax
  80101f:	50                   	push   %eax
  801020:	ff 75 d4             	pushl  -0x2c(%ebp)
  801023:	6a 00                	push   $0x0
  801025:	57                   	push   %edi
  801026:	6a 00                	push   $0x0
  801028:	e8 d2 fb ff ff       	call   800bff <sys_page_map>
  80102d:	89 c7                	mov    %eax,%edi
  80102f:	83 c4 20             	add    $0x20,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	78 2e                	js     801064 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801036:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801039:	89 d0                	mov    %edx,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
  80103e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	25 07 0e 00 00       	and    $0xe07,%eax
  80104d:	50                   	push   %eax
  80104e:	53                   	push   %ebx
  80104f:	6a 00                	push   $0x0
  801051:	52                   	push   %edx
  801052:	6a 00                	push   $0x0
  801054:	e8 a6 fb ff ff       	call   800bff <sys_page_map>
  801059:	89 c7                	mov    %eax,%edi
  80105b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80105e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801060:	85 ff                	test   %edi,%edi
  801062:	79 1d                	jns    801081 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	53                   	push   %ebx
  801068:	6a 00                	push   $0x0
  80106a:	e8 d2 fb ff ff       	call   800c41 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	ff 75 d4             	pushl  -0x2c(%ebp)
  801075:	6a 00                	push   $0x0
  801077:	e8 c5 fb ff ff       	call   800c41 <sys_page_unmap>
	return r;
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	89 f8                	mov    %edi,%eax
}
  801081:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	53                   	push   %ebx
  80108d:	83 ec 14             	sub    $0x14,%esp
  801090:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801093:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801096:	50                   	push   %eax
  801097:	53                   	push   %ebx
  801098:	e8 86 fd ff ff       	call   800e23 <fd_lookup>
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	78 6d                	js     801113 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b0:	ff 30                	pushl  (%eax)
  8010b2:	e8 c2 fd ff ff       	call   800e79 <dev_lookup>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 4c                	js     80110a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010c1:	8b 42 08             	mov    0x8(%edx),%eax
  8010c4:	83 e0 03             	and    $0x3,%eax
  8010c7:	83 f8 01             	cmp    $0x1,%eax
  8010ca:	75 21                	jne    8010ed <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d1:	8b 40 48             	mov    0x48(%eax),%eax
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	53                   	push   %ebx
  8010d8:	50                   	push   %eax
  8010d9:	68 6d 22 80 00       	push   $0x80226d
  8010de:	e8 aa f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010eb:	eb 26                	jmp    801113 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f0:	8b 40 08             	mov    0x8(%eax),%eax
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 17                	je     80110e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	ff 75 10             	pushl  0x10(%ebp)
  8010fd:	ff 75 0c             	pushl  0xc(%ebp)
  801100:	52                   	push   %edx
  801101:	ff d0                	call   *%eax
  801103:	89 c2                	mov    %eax,%edx
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	eb 09                	jmp    801113 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110a:	89 c2                	mov    %eax,%edx
  80110c:	eb 05                	jmp    801113 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80110e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801113:	89 d0                	mov    %edx,%eax
  801115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	8b 7d 08             	mov    0x8(%ebp),%edi
  801126:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801129:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112e:	eb 21                	jmp    801151 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	89 f0                	mov    %esi,%eax
  801135:	29 d8                	sub    %ebx,%eax
  801137:	50                   	push   %eax
  801138:	89 d8                	mov    %ebx,%eax
  80113a:	03 45 0c             	add    0xc(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	57                   	push   %edi
  80113f:	e8 45 ff ff ff       	call   801089 <read>
		if (m < 0)
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 10                	js     80115b <readn+0x41>
			return m;
		if (m == 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	74 0a                	je     801159 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114f:	01 c3                	add    %eax,%ebx
  801151:	39 f3                	cmp    %esi,%ebx
  801153:	72 db                	jb     801130 <readn+0x16>
  801155:	89 d8                	mov    %ebx,%eax
  801157:	eb 02                	jmp    80115b <readn+0x41>
  801159:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5f                   	pop    %edi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	53                   	push   %ebx
  801167:	83 ec 14             	sub    $0x14,%esp
  80116a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	53                   	push   %ebx
  801172:	e8 ac fc ff ff       	call   800e23 <fd_lookup>
  801177:	83 c4 08             	add    $0x8,%esp
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 68                	js     8011e8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801186:	50                   	push   %eax
  801187:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118a:	ff 30                	pushl  (%eax)
  80118c:	e8 e8 fc ff ff       	call   800e79 <dev_lookup>
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	78 47                	js     8011df <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119f:	75 21                	jne    8011c2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a6:	8b 40 48             	mov    0x48(%eax),%eax
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	53                   	push   %ebx
  8011ad:	50                   	push   %eax
  8011ae:	68 89 22 80 00       	push   $0x802289
  8011b3:	e8 d5 ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c0:	eb 26                	jmp    8011e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c8:	85 d2                	test   %edx,%edx
  8011ca:	74 17                	je     8011e3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 10             	pushl  0x10(%ebp)
  8011d2:	ff 75 0c             	pushl  0xc(%ebp)
  8011d5:	50                   	push   %eax
  8011d6:	ff d2                	call   *%edx
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	eb 09                	jmp    8011e8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	eb 05                	jmp    8011e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011e8:	89 d0                	mov    %edx,%eax
  8011ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 22 fc ff ff       	call   800e23 <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 0e                	js     801216 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801208:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	53                   	push   %ebx
  80121c:	83 ec 14             	sub    $0x14,%esp
  80121f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	53                   	push   %ebx
  801227:	e8 f7 fb ff ff       	call   800e23 <fd_lookup>
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	89 c2                	mov    %eax,%edx
  801231:	85 c0                	test   %eax,%eax
  801233:	78 65                	js     80129a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	ff 30                	pushl  (%eax)
  801241:	e8 33 fc ff ff       	call   800e79 <dev_lookup>
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 44                	js     801291 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801254:	75 21                	jne    801277 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801256:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	53                   	push   %ebx
  801262:	50                   	push   %eax
  801263:	68 4c 22 80 00       	push   $0x80224c
  801268:	e8 20 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801275:	eb 23                	jmp    80129a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127a:	8b 52 18             	mov    0x18(%edx),%edx
  80127d:	85 d2                	test   %edx,%edx
  80127f:	74 14                	je     801295 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	ff 75 0c             	pushl  0xc(%ebp)
  801287:	50                   	push   %eax
  801288:	ff d2                	call   *%edx
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	eb 09                	jmp    80129a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801291:	89 c2                	mov    %eax,%edx
  801293:	eb 05                	jmp    80129a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801295:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80129a:	89 d0                	mov    %edx,%eax
  80129c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 14             	sub    $0x14,%esp
  8012a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 75 08             	pushl  0x8(%ebp)
  8012b2:	e8 6c fb ff ff       	call   800e23 <fd_lookup>
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 58                	js     801318 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	ff 30                	pushl  (%eax)
  8012cc:	e8 a8 fb ff ff       	call   800e79 <dev_lookup>
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 37                	js     80130f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012db:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012df:	74 32                	je     801313 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012eb:	00 00 00 
	stat->st_isdir = 0;
  8012ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f5:	00 00 00 
	stat->st_dev = dev;
  8012f8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	53                   	push   %ebx
  801302:	ff 75 f0             	pushl  -0x10(%ebp)
  801305:	ff 50 14             	call   *0x14(%eax)
  801308:	89 c2                	mov    %eax,%edx
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	eb 09                	jmp    801318 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	89 c2                	mov    %eax,%edx
  801311:	eb 05                	jmp    801318 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801313:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801318:	89 d0                	mov    %edx,%eax
  80131a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	6a 00                	push   $0x0
  801329:	ff 75 08             	pushl  0x8(%ebp)
  80132c:	e8 b7 01 00 00       	call   8014e8 <open>
  801331:	89 c3                	mov    %eax,%ebx
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 1b                	js     801355 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	ff 75 0c             	pushl  0xc(%ebp)
  801340:	50                   	push   %eax
  801341:	e8 5b ff ff ff       	call   8012a1 <fstat>
  801346:	89 c6                	mov    %eax,%esi
	close(fd);
  801348:	89 1c 24             	mov    %ebx,(%esp)
  80134b:	e8 fd fb ff ff       	call   800f4d <close>
	return r;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	89 f0                	mov    %esi,%eax
}
  801355:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801358:	5b                   	pop    %ebx
  801359:	5e                   	pop    %esi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	89 c6                	mov    %eax,%esi
  801363:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801365:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80136c:	75 12                	jne    801380 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	6a 01                	push   $0x1
  801373:	e8 02 08 00 00       	call   801b7a <ipc_find_env>
  801378:	a3 00 40 80 00       	mov    %eax,0x804000
  80137d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801380:	6a 07                	push   $0x7
  801382:	68 00 50 80 00       	push   $0x805000
  801387:	56                   	push   %esi
  801388:	ff 35 00 40 80 00    	pushl  0x804000
  80138e:	e8 93 07 00 00       	call   801b26 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801393:	83 c4 0c             	add    $0xc,%esp
  801396:	6a 00                	push   $0x0
  801398:	53                   	push   %ebx
  801399:	6a 00                	push   $0x0
  80139b:	e8 11 07 00 00       	call   801ab1 <ipc_recv>
}
  8013a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c5:	b8 02 00 00 00       	mov    $0x2,%eax
  8013ca:	e8 8d ff ff ff       	call   80135c <fsipc>
}
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ec:	e8 6b ff ff ff       	call   80135c <fsipc>
}
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    

008013f3 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 04             	sub    $0x4,%esp
  8013fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801400:	8b 40 0c             	mov    0xc(%eax),%eax
  801403:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801408:	ba 00 00 00 00       	mov    $0x0,%edx
  80140d:	b8 05 00 00 00       	mov    $0x5,%eax
  801412:	e8 45 ff ff ff       	call   80135c <fsipc>
  801417:	85 c0                	test   %eax,%eax
  801419:	78 2c                	js     801447 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	68 00 50 80 00       	push   $0x805000
  801423:	53                   	push   %ebx
  801424:	e8 90 f3 ff ff       	call   8007b9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801429:	a1 80 50 80 00       	mov    0x805080,%eax
  80142e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801434:	a1 84 50 80 00       	mov    0x805084,%eax
  801439:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801447:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801452:	68 b8 22 80 00       	push   $0x8022b8
  801457:	68 90 00 00 00       	push   $0x90
  80145c:	68 d6 22 80 00       	push   $0x8022d6
  801461:	e8 05 06 00 00       	call   801a6b <_panic>

00801466 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80146e:	8b 45 08             	mov    0x8(%ebp),%eax
  801471:	8b 40 0c             	mov    0xc(%eax),%eax
  801474:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801479:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80147f:	ba 00 00 00 00       	mov    $0x0,%edx
  801484:	b8 03 00 00 00       	mov    $0x3,%eax
  801489:	e8 ce fe ff ff       	call   80135c <fsipc>
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	85 c0                	test   %eax,%eax
  801492:	78 4b                	js     8014df <devfile_read+0x79>
		return r;
	assert(r <= n);
  801494:	39 c6                	cmp    %eax,%esi
  801496:	73 16                	jae    8014ae <devfile_read+0x48>
  801498:	68 e1 22 80 00       	push   $0x8022e1
  80149d:	68 e8 22 80 00       	push   $0x8022e8
  8014a2:	6a 7c                	push   $0x7c
  8014a4:	68 d6 22 80 00       	push   $0x8022d6
  8014a9:	e8 bd 05 00 00       	call   801a6b <_panic>
	assert(r <= PGSIZE);
  8014ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014b3:	7e 16                	jle    8014cb <devfile_read+0x65>
  8014b5:	68 fd 22 80 00       	push   $0x8022fd
  8014ba:	68 e8 22 80 00       	push   $0x8022e8
  8014bf:	6a 7d                	push   $0x7d
  8014c1:	68 d6 22 80 00       	push   $0x8022d6
  8014c6:	e8 a0 05 00 00       	call   801a6b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	50                   	push   %eax
  8014cf:	68 00 50 80 00       	push   $0x805000
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	e8 6f f4 ff ff       	call   80094b <memmove>
	return r;
  8014dc:	83 c4 10             	add    $0x10,%esp
}
  8014df:	89 d8                	mov    %ebx,%eax
  8014e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	53                   	push   %ebx
  8014ec:	83 ec 20             	sub    $0x20,%esp
  8014ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014f2:	53                   	push   %ebx
  8014f3:	e8 88 f2 ff ff       	call   800780 <strlen>
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801500:	7f 67                	jg     801569 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	e8 c6 f8 ff ff       	call   800dd4 <fd_alloc>
  80150e:	83 c4 10             	add    $0x10,%esp
		return r;
  801511:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	78 57                	js     80156e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	53                   	push   %ebx
  80151b:	68 00 50 80 00       	push   $0x805000
  801520:	e8 94 f2 ff ff       	call   8007b9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801525:	8b 45 0c             	mov    0xc(%ebp),%eax
  801528:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80152d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801530:	b8 01 00 00 00       	mov    $0x1,%eax
  801535:	e8 22 fe ff ff       	call   80135c <fsipc>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	79 14                	jns    801557 <open+0x6f>
		fd_close(fd, 0);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	6a 00                	push   $0x0
  801548:	ff 75 f4             	pushl  -0xc(%ebp)
  80154b:	e8 7c f9 ff ff       	call   800ecc <fd_close>
		return r;
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	89 da                	mov    %ebx,%edx
  801555:	eb 17                	jmp    80156e <open+0x86>
	}

	return fd2num(fd);
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	ff 75 f4             	pushl  -0xc(%ebp)
  80155d:	e8 4b f8 ff ff       	call   800dad <fd2num>
  801562:	89 c2                	mov    %eax,%edx
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	eb 05                	jmp    80156e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801569:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80156e:	89 d0                	mov    %edx,%eax
  801570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80157b:	ba 00 00 00 00       	mov    $0x0,%edx
  801580:	b8 08 00 00 00       	mov    $0x8,%eax
  801585:	e8 d2 fd ff ff       	call   80135c <fsipc>
}
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	ff 75 08             	pushl  0x8(%ebp)
  80159a:	e8 1e f8 ff ff       	call   800dbd <fd2data>
  80159f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	68 09 23 80 00       	push   $0x802309
  8015a9:	53                   	push   %ebx
  8015aa:	e8 0a f2 ff ff       	call   8007b9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015af:	8b 46 04             	mov    0x4(%esi),%eax
  8015b2:	2b 06                	sub    (%esi),%eax
  8015b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015ba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c1:	00 00 00 
	stat->st_dev = &devpipe;
  8015c4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015cb:	30 80 00 
	return 0;
}
  8015ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015e4:	53                   	push   %ebx
  8015e5:	6a 00                	push   $0x0
  8015e7:	e8 55 f6 ff ff       	call   800c41 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015ec:	89 1c 24             	mov    %ebx,(%esp)
  8015ef:	e8 c9 f7 ff ff       	call   800dbd <fd2data>
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	50                   	push   %eax
  8015f8:	6a 00                	push   $0x0
  8015fa:	e8 42 f6 ff ff       	call   800c41 <sys_page_unmap>
}
  8015ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	57                   	push   %edi
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
  80160a:	83 ec 1c             	sub    $0x1c,%esp
  80160d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801610:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801612:	a1 04 40 80 00       	mov    0x804004,%eax
  801617:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	ff 75 e0             	pushl  -0x20(%ebp)
  801620:	e8 8e 05 00 00       	call   801bb3 <pageref>
  801625:	89 c3                	mov    %eax,%ebx
  801627:	89 3c 24             	mov    %edi,(%esp)
  80162a:	e8 84 05 00 00       	call   801bb3 <pageref>
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	39 c3                	cmp    %eax,%ebx
  801634:	0f 94 c1             	sete   %cl
  801637:	0f b6 c9             	movzbl %cl,%ecx
  80163a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80163d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801643:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801646:	39 ce                	cmp    %ecx,%esi
  801648:	74 1b                	je     801665 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80164a:	39 c3                	cmp    %eax,%ebx
  80164c:	75 c4                	jne    801612 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80164e:	8b 42 58             	mov    0x58(%edx),%eax
  801651:	ff 75 e4             	pushl  -0x1c(%ebp)
  801654:	50                   	push   %eax
  801655:	56                   	push   %esi
  801656:	68 10 23 80 00       	push   $0x802310
  80165b:	e8 2d eb ff ff       	call   80018d <cprintf>
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	eb ad                	jmp    801612 <_pipeisclosed+0xe>
	}
}
  801665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5f                   	pop    %edi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	57                   	push   %edi
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	83 ec 28             	sub    $0x28,%esp
  801679:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80167c:	56                   	push   %esi
  80167d:	e8 3b f7 ff ff       	call   800dbd <fd2data>
  801682:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	bf 00 00 00 00       	mov    $0x0,%edi
  80168c:	eb 4b                	jmp    8016d9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80168e:	89 da                	mov    %ebx,%edx
  801690:	89 f0                	mov    %esi,%eax
  801692:	e8 6d ff ff ff       	call   801604 <_pipeisclosed>
  801697:	85 c0                	test   %eax,%eax
  801699:	75 48                	jne    8016e3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80169b:	e8 fd f4 ff ff       	call   800b9d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8016a3:	8b 0b                	mov    (%ebx),%ecx
  8016a5:	8d 51 20             	lea    0x20(%ecx),%edx
  8016a8:	39 d0                	cmp    %edx,%eax
  8016aa:	73 e2                	jae    80168e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016af:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016b3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	c1 fa 1f             	sar    $0x1f,%edx
  8016bb:	89 d1                	mov    %edx,%ecx
  8016bd:	c1 e9 1b             	shr    $0x1b,%ecx
  8016c0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016c3:	83 e2 1f             	and    $0x1f,%edx
  8016c6:	29 ca                	sub    %ecx,%edx
  8016c8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016d0:	83 c0 01             	add    $0x1,%eax
  8016d3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d6:	83 c7 01             	add    $0x1,%edi
  8016d9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016dc:	75 c2                	jne    8016a0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016de:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e1:	eb 05                	jmp    8016e8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5f                   	pop    %edi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	57                   	push   %edi
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 18             	sub    $0x18,%esp
  8016f9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016fc:	57                   	push   %edi
  8016fd:	e8 bb f6 ff ff       	call   800dbd <fd2data>
  801702:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170c:	eb 3d                	jmp    80174b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80170e:	85 db                	test   %ebx,%ebx
  801710:	74 04                	je     801716 <devpipe_read+0x26>
				return i;
  801712:	89 d8                	mov    %ebx,%eax
  801714:	eb 44                	jmp    80175a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801716:	89 f2                	mov    %esi,%edx
  801718:	89 f8                	mov    %edi,%eax
  80171a:	e8 e5 fe ff ff       	call   801604 <_pipeisclosed>
  80171f:	85 c0                	test   %eax,%eax
  801721:	75 32                	jne    801755 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801723:	e8 75 f4 ff ff       	call   800b9d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801728:	8b 06                	mov    (%esi),%eax
  80172a:	3b 46 04             	cmp    0x4(%esi),%eax
  80172d:	74 df                	je     80170e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80172f:	99                   	cltd   
  801730:	c1 ea 1b             	shr    $0x1b,%edx
  801733:	01 d0                	add    %edx,%eax
  801735:	83 e0 1f             	and    $0x1f,%eax
  801738:	29 d0                	sub    %edx,%eax
  80173a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80173f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801742:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801745:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801748:	83 c3 01             	add    $0x1,%ebx
  80174b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80174e:	75 d8                	jne    801728 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801750:	8b 45 10             	mov    0x10(%ebp),%eax
  801753:	eb 05                	jmp    80175a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801755:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80175a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80176a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176d:	50                   	push   %eax
  80176e:	e8 61 f6 ff ff       	call   800dd4 <fd_alloc>
  801773:	83 c4 10             	add    $0x10,%esp
  801776:	89 c2                	mov    %eax,%edx
  801778:	85 c0                	test   %eax,%eax
  80177a:	0f 88 2c 01 00 00    	js     8018ac <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	68 07 04 00 00       	push   $0x407
  801788:	ff 75 f4             	pushl  -0xc(%ebp)
  80178b:	6a 00                	push   $0x0
  80178d:	e8 2a f4 ff ff       	call   800bbc <sys_page_alloc>
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	89 c2                	mov    %eax,%edx
  801797:	85 c0                	test   %eax,%eax
  801799:	0f 88 0d 01 00 00    	js     8018ac <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80179f:	83 ec 0c             	sub    $0xc,%esp
  8017a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a5:	50                   	push   %eax
  8017a6:	e8 29 f6 ff ff       	call   800dd4 <fd_alloc>
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	0f 88 e2 00 00 00    	js     80189a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b8:	83 ec 04             	sub    $0x4,%esp
  8017bb:	68 07 04 00 00       	push   $0x407
  8017c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c3:	6a 00                	push   $0x0
  8017c5:	e8 f2 f3 ff ff       	call   800bbc <sys_page_alloc>
  8017ca:	89 c3                	mov    %eax,%ebx
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	0f 88 c3 00 00 00    	js     80189a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	ff 75 f4             	pushl  -0xc(%ebp)
  8017dd:	e8 db f5 ff ff       	call   800dbd <fd2data>
  8017e2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e4:	83 c4 0c             	add    $0xc,%esp
  8017e7:	68 07 04 00 00       	push   $0x407
  8017ec:	50                   	push   %eax
  8017ed:	6a 00                	push   $0x0
  8017ef:	e8 c8 f3 ff ff       	call   800bbc <sys_page_alloc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	0f 88 89 00 00 00    	js     80188a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	ff 75 f0             	pushl  -0x10(%ebp)
  801807:	e8 b1 f5 ff ff       	call   800dbd <fd2data>
  80180c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801813:	50                   	push   %eax
  801814:	6a 00                	push   $0x0
  801816:	56                   	push   %esi
  801817:	6a 00                	push   $0x0
  801819:	e8 e1 f3 ff ff       	call   800bff <sys_page_map>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	83 c4 20             	add    $0x20,%esp
  801823:	85 c0                	test   %eax,%eax
  801825:	78 55                	js     80187c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801827:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80182d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801830:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801835:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80183c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801842:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801845:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	ff 75 f4             	pushl  -0xc(%ebp)
  801857:	e8 51 f5 ff ff       	call   800dad <fd2num>
  80185c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801861:	83 c4 04             	add    $0x4,%esp
  801864:	ff 75 f0             	pushl  -0x10(%ebp)
  801867:	e8 41 f5 ff ff       	call   800dad <fd2num>
  80186c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	eb 30                	jmp    8018ac <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80187c:	83 ec 08             	sub    $0x8,%esp
  80187f:	56                   	push   %esi
  801880:	6a 00                	push   $0x0
  801882:	e8 ba f3 ff ff       	call   800c41 <sys_page_unmap>
  801887:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	ff 75 f0             	pushl  -0x10(%ebp)
  801890:	6a 00                	push   $0x0
  801892:	e8 aa f3 ff ff       	call   800c41 <sys_page_unmap>
  801897:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80189a:	83 ec 08             	sub    $0x8,%esp
  80189d:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a0:	6a 00                	push   $0x0
  8018a2:	e8 9a f3 ff ff       	call   800c41 <sys_page_unmap>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018ac:	89 d0                	mov    %edx,%eax
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018be:	50                   	push   %eax
  8018bf:	ff 75 08             	pushl  0x8(%ebp)
  8018c2:	e8 5c f5 ff ff       	call   800e23 <fd_lookup>
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 18                	js     8018e6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018ce:	83 ec 0c             	sub    $0xc,%esp
  8018d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d4:	e8 e4 f4 ff ff       	call   800dbd <fd2data>
	return _pipeisclosed(fd, p);
  8018d9:	89 c2                	mov    %eax,%edx
  8018db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018de:	e8 21 fd ff ff       	call   801604 <_pipeisclosed>
  8018e3:	83 c4 10             	add    $0x10,%esp
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018f8:	68 28 23 80 00       	push   $0x802328
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	e8 b4 ee ff ff       	call   8007b9 <strcpy>
	return 0;
}
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801918:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80191d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801923:	eb 2d                	jmp    801952 <devcons_write+0x46>
		m = n - tot;
  801925:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801928:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80192a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80192d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801932:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801935:	83 ec 04             	sub    $0x4,%esp
  801938:	53                   	push   %ebx
  801939:	03 45 0c             	add    0xc(%ebp),%eax
  80193c:	50                   	push   %eax
  80193d:	57                   	push   %edi
  80193e:	e8 08 f0 ff ff       	call   80094b <memmove>
		sys_cputs(buf, m);
  801943:	83 c4 08             	add    $0x8,%esp
  801946:	53                   	push   %ebx
  801947:	57                   	push   %edi
  801948:	e8 b3 f1 ff ff       	call   800b00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80194d:	01 de                	add    %ebx,%esi
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	89 f0                	mov    %esi,%eax
  801954:	3b 75 10             	cmp    0x10(%ebp),%esi
  801957:	72 cc                	jb     801925 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801959:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195c:	5b                   	pop    %ebx
  80195d:	5e                   	pop    %esi
  80195e:	5f                   	pop    %edi
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80196c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801970:	74 2a                	je     80199c <devcons_read+0x3b>
  801972:	eb 05                	jmp    801979 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801974:	e8 24 f2 ff ff       	call   800b9d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801979:	e8 a0 f1 ff ff       	call   800b1e <sys_cgetc>
  80197e:	85 c0                	test   %eax,%eax
  801980:	74 f2                	je     801974 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801982:	85 c0                	test   %eax,%eax
  801984:	78 16                	js     80199c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801986:	83 f8 04             	cmp    $0x4,%eax
  801989:	74 0c                	je     801997 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80198b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80198e:	88 02                	mov    %al,(%edx)
	return 1;
  801990:	b8 01 00 00 00       	mov    $0x1,%eax
  801995:	eb 05                	jmp    80199c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019aa:	6a 01                	push   $0x1
  8019ac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019af:	50                   	push   %eax
  8019b0:	e8 4b f1 ff ff       	call   800b00 <sys_cputs>
}
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <getchar>:

int
getchar(void)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019c0:	6a 01                	push   $0x1
  8019c2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019c5:	50                   	push   %eax
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 bc f6 ff ff       	call   801089 <read>
	if (r < 0)
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 0f                	js     8019e3 <getchar+0x29>
		return r;
	if (r < 1)
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	7e 06                	jle    8019de <getchar+0x24>
		return -E_EOF;
	return c;
  8019d8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019dc:	eb 05                	jmp    8019e3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019de:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ee:	50                   	push   %eax
  8019ef:	ff 75 08             	pushl  0x8(%ebp)
  8019f2:	e8 2c f4 ff ff       	call   800e23 <fd_lookup>
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 11                	js     801a0f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a07:	39 10                	cmp    %edx,(%eax)
  801a09:	0f 94 c0             	sete   %al
  801a0c:	0f b6 c0             	movzbl %al,%eax
}
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <opencons>:

int
opencons(void)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	e8 b4 f3 ff ff       	call   800dd4 <fd_alloc>
  801a20:	83 c4 10             	add    $0x10,%esp
		return r;
  801a23:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 3e                	js     801a67 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a29:	83 ec 04             	sub    $0x4,%esp
  801a2c:	68 07 04 00 00       	push   $0x407
  801a31:	ff 75 f4             	pushl  -0xc(%ebp)
  801a34:	6a 00                	push   $0x0
  801a36:	e8 81 f1 ff ff       	call   800bbc <sys_page_alloc>
  801a3b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a3e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 23                	js     801a67 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a44:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a52:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a59:	83 ec 0c             	sub    $0xc,%esp
  801a5c:	50                   	push   %eax
  801a5d:	e8 4b f3 ff ff       	call   800dad <fd2num>
  801a62:	89 c2                	mov    %eax,%edx
  801a64:	83 c4 10             	add    $0x10,%esp
}
  801a67:	89 d0                	mov    %edx,%eax
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a70:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a73:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a79:	e8 00 f1 ff ff       	call   800b7e <sys_getenvid>
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	ff 75 0c             	pushl  0xc(%ebp)
  801a84:	ff 75 08             	pushl  0x8(%ebp)
  801a87:	56                   	push   %esi
  801a88:	50                   	push   %eax
  801a89:	68 34 23 80 00       	push   $0x802334
  801a8e:	e8 fa e6 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a93:	83 c4 18             	add    $0x18,%esp
  801a96:	53                   	push   %ebx
  801a97:	ff 75 10             	pushl  0x10(%ebp)
  801a9a:	e8 9d e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801a9f:	c7 04 24 21 23 80 00 	movl   $0x802321,(%esp)
  801aa6:	e8 e2 e6 ff ff       	call   80018d <cprintf>
  801aab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aae:	cc                   	int3   
  801aaf:	eb fd                	jmp    801aae <_panic+0x43>

00801ab1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	74 0e                	je     801ad1 <ipc_recv+0x20>
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	50                   	push   %eax
  801ac7:	e8 a0 f2 ff ff       	call   800d6c <sys_ipc_recv>
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	eb 10                	jmp    801ae1 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	68 00 00 c0 ee       	push   $0xeec00000
  801ad9:	e8 8e f2 ff ff       	call   800d6c <sys_ipc_recv>
  801ade:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	74 16                	je     801afb <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801ae5:	85 f6                	test   %esi,%esi
  801ae7:	74 06                	je     801aef <ipc_recv+0x3e>
  801ae9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801aef:	85 db                	test   %ebx,%ebx
  801af1:	74 2c                	je     801b1f <ipc_recv+0x6e>
  801af3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801af9:	eb 24                	jmp    801b1f <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801afb:	85 f6                	test   %esi,%esi
  801afd:	74 0a                	je     801b09 <ipc_recv+0x58>
  801aff:	a1 04 40 80 00       	mov    0x804004,%eax
  801b04:	8b 40 74             	mov    0x74(%eax),%eax
  801b07:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801b09:	85 db                	test   %ebx,%ebx
  801b0b:	74 0a                	je     801b17 <ipc_recv+0x66>
  801b0d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b12:	8b 40 78             	mov    0x78(%eax),%eax
  801b15:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b17:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	57                   	push   %edi
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b32:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b35:	8b 45 10             	mov    0x10(%ebp),%eax
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b3f:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b42:	ff 75 14             	pushl  0x14(%ebp)
  801b45:	53                   	push   %ebx
  801b46:	56                   	push   %esi
  801b47:	57                   	push   %edi
  801b48:	e8 fc f1 ff ff       	call   800d49 <sys_ipc_try_send>
		if (ret == 0) break;
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	85 c0                	test   %eax,%eax
  801b52:	74 1e                	je     801b72 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b54:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b57:	74 12                	je     801b6b <ipc_send+0x45>
  801b59:	50                   	push   %eax
  801b5a:	68 58 23 80 00       	push   $0x802358
  801b5f:	6a 39                	push   $0x39
  801b61:	68 65 23 80 00       	push   $0x802365
  801b66:	e8 00 ff ff ff       	call   801a6b <_panic>
		sys_yield();
  801b6b:	e8 2d f0 ff ff       	call   800b9d <sys_yield>
	}
  801b70:	eb d0                	jmp    801b42 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5f                   	pop    %edi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b85:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b88:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b8e:	8b 52 50             	mov    0x50(%edx),%edx
  801b91:	39 ca                	cmp    %ecx,%edx
  801b93:	75 0d                	jne    801ba2 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b95:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b98:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b9d:	8b 40 48             	mov    0x48(%eax),%eax
  801ba0:	eb 0f                	jmp    801bb1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ba2:	83 c0 01             	add    $0x1,%eax
  801ba5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801baa:	75 d9                	jne    801b85 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb9:	89 d0                	mov    %edx,%eax
  801bbb:	c1 e8 16             	shr    $0x16,%eax
  801bbe:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bca:	f6 c1 01             	test   $0x1,%cl
  801bcd:	74 1d                	je     801bec <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bcf:	c1 ea 0c             	shr    $0xc,%edx
  801bd2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bd9:	f6 c2 01             	test   $0x1,%dl
  801bdc:	74 0e                	je     801bec <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bde:	c1 ea 0c             	shr    $0xc,%edx
  801be1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801be8:	ef 
  801be9:	0f b7 c0             	movzwl %ax,%eax
}
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    
  801bee:	66 90                	xchg   %ax,%ax

00801bf0 <__udivdi3>:
  801bf0:	55                   	push   %ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c07:	85 f6                	test   %esi,%esi
  801c09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0d:	89 ca                	mov    %ecx,%edx
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	75 3d                	jne    801c50 <__udivdi3+0x60>
  801c13:	39 cf                	cmp    %ecx,%edi
  801c15:	0f 87 c5 00 00 00    	ja     801ce0 <__udivdi3+0xf0>
  801c1b:	85 ff                	test   %edi,%edi
  801c1d:	89 fd                	mov    %edi,%ebp
  801c1f:	75 0b                	jne    801c2c <__udivdi3+0x3c>
  801c21:	b8 01 00 00 00       	mov    $0x1,%eax
  801c26:	31 d2                	xor    %edx,%edx
  801c28:	f7 f7                	div    %edi
  801c2a:	89 c5                	mov    %eax,%ebp
  801c2c:	89 c8                	mov    %ecx,%eax
  801c2e:	31 d2                	xor    %edx,%edx
  801c30:	f7 f5                	div    %ebp
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	89 cf                	mov    %ecx,%edi
  801c38:	f7 f5                	div    %ebp
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	39 ce                	cmp    %ecx,%esi
  801c52:	77 74                	ja     801cc8 <__udivdi3+0xd8>
  801c54:	0f bd fe             	bsr    %esi,%edi
  801c57:	83 f7 1f             	xor    $0x1f,%edi
  801c5a:	0f 84 98 00 00 00    	je     801cf8 <__udivdi3+0x108>
  801c60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	89 c5                	mov    %eax,%ebp
  801c69:	29 fb                	sub    %edi,%ebx
  801c6b:	d3 e6                	shl    %cl,%esi
  801c6d:	89 d9                	mov    %ebx,%ecx
  801c6f:	d3 ed                	shr    %cl,%ebp
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e0                	shl    %cl,%eax
  801c75:	09 ee                	or     %ebp,%esi
  801c77:	89 d9                	mov    %ebx,%ecx
  801c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7d:	89 d5                	mov    %edx,%ebp
  801c7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c83:	d3 ed                	shr    %cl,%ebp
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e2                	shl    %cl,%edx
  801c89:	89 d9                	mov    %ebx,%ecx
  801c8b:	d3 e8                	shr    %cl,%eax
  801c8d:	09 c2                	or     %eax,%edx
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	89 ea                	mov    %ebp,%edx
  801c93:	f7 f6                	div    %esi
  801c95:	89 d5                	mov    %edx,%ebp
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	f7 64 24 0c          	mull   0xc(%esp)
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	72 10                	jb     801cb1 <__udivdi3+0xc1>
  801ca1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e6                	shl    %cl,%esi
  801ca9:	39 c6                	cmp    %eax,%esi
  801cab:	73 07                	jae    801cb4 <__udivdi3+0xc4>
  801cad:	39 d5                	cmp    %edx,%ebp
  801caf:	75 03                	jne    801cb4 <__udivdi3+0xc4>
  801cb1:	83 eb 01             	sub    $0x1,%ebx
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 d8                	mov    %ebx,%eax
  801cb8:	89 fa                	mov    %edi,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	31 ff                	xor    %edi,%edi
  801cca:	31 db                	xor    %ebx,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	f7 f7                	div    %edi
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 fa                	mov    %edi,%edx
  801cec:	83 c4 1c             	add    $0x1c,%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	39 ce                	cmp    %ecx,%esi
  801cfa:	72 0c                	jb     801d08 <__udivdi3+0x118>
  801cfc:	31 db                	xor    %ebx,%ebx
  801cfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d02:	0f 87 34 ff ff ff    	ja     801c3c <__udivdi3+0x4c>
  801d08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d0d:	e9 2a ff ff ff       	jmp    801c3c <__udivdi3+0x4c>
  801d12:	66 90                	xchg   %ax,%ax
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__umoddi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 d2                	test   %edx,%edx
  801d39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f3                	mov    %esi,%ebx
  801d43:	89 3c 24             	mov    %edi,(%esp)
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	75 1c                	jne    801d68 <__umoddi3+0x48>
  801d4c:	39 f7                	cmp    %esi,%edi
  801d4e:	76 50                	jbe    801da0 <__umoddi3+0x80>
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	f7 f7                	div    %edi
  801d56:	89 d0                	mov    %edx,%eax
  801d58:	31 d2                	xor    %edx,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	39 f2                	cmp    %esi,%edx
  801d6a:	89 d0                	mov    %edx,%eax
  801d6c:	77 52                	ja     801dc0 <__umoddi3+0xa0>
  801d6e:	0f bd ea             	bsr    %edx,%ebp
  801d71:	83 f5 1f             	xor    $0x1f,%ebp
  801d74:	75 5a                	jne    801dd0 <__umoddi3+0xb0>
  801d76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d7a:	0f 82 e0 00 00 00    	jb     801e60 <__umoddi3+0x140>
  801d80:	39 0c 24             	cmp    %ecx,(%esp)
  801d83:	0f 86 d7 00 00 00    	jbe    801e60 <__umoddi3+0x140>
  801d89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d91:	83 c4 1c             	add    $0x1c,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	85 ff                	test   %edi,%edi
  801da2:	89 fd                	mov    %edi,%ebp
  801da4:	75 0b                	jne    801db1 <__umoddi3+0x91>
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f7                	div    %edi
  801daf:	89 c5                	mov    %eax,%ebp
  801db1:	89 f0                	mov    %esi,%eax
  801db3:	31 d2                	xor    %edx,%edx
  801db5:	f7 f5                	div    %ebp
  801db7:	89 c8                	mov    %ecx,%eax
  801db9:	f7 f5                	div    %ebp
  801dbb:	89 d0                	mov    %edx,%eax
  801dbd:	eb 99                	jmp    801d58 <__umoddi3+0x38>
  801dbf:	90                   	nop
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 1c             	add    $0x1c,%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	8b 34 24             	mov    (%esp),%esi
  801dd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	29 ef                	sub    %ebp,%edi
  801ddc:	d3 e0                	shl    %cl,%eax
  801dde:	89 f9                	mov    %edi,%ecx
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	d3 ea                	shr    %cl,%edx
  801de4:	89 e9                	mov    %ebp,%ecx
  801de6:	09 c2                	or     %eax,%edx
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	89 14 24             	mov    %edx,(%esp)
  801ded:	89 f2                	mov    %esi,%edx
  801def:	d3 e2                	shl    %cl,%edx
  801df1:	89 f9                	mov    %edi,%ecx
  801df3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dfb:	d3 e8                	shr    %cl,%eax
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	89 c6                	mov    %eax,%esi
  801e01:	d3 e3                	shl    %cl,%ebx
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 d0                	mov    %edx,%eax
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	09 d8                	or     %ebx,%eax
  801e0d:	89 d3                	mov    %edx,%ebx
  801e0f:	89 f2                	mov    %esi,%edx
  801e11:	f7 34 24             	divl   (%esp)
  801e14:	89 d6                	mov    %edx,%esi
  801e16:	d3 e3                	shl    %cl,%ebx
  801e18:	f7 64 24 04          	mull   0x4(%esp)
  801e1c:	39 d6                	cmp    %edx,%esi
  801e1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e22:	89 d1                	mov    %edx,%ecx
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	72 08                	jb     801e30 <__umoddi3+0x110>
  801e28:	75 11                	jne    801e3b <__umoddi3+0x11b>
  801e2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e2e:	73 0b                	jae    801e3b <__umoddi3+0x11b>
  801e30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e34:	1b 14 24             	sbb    (%esp),%edx
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e3f:	29 da                	sub    %ebx,%edx
  801e41:	19 ce                	sbb    %ecx,%esi
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e0                	shl    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	d3 ea                	shr    %cl,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	d3 ee                	shr    %cl,%esi
  801e51:	09 d0                	or     %edx,%eax
  801e53:	89 f2                	mov    %esi,%edx
  801e55:	83 c4 1c             	add    $0x1c,%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	29 f9                	sub    %edi,%ecx
  801e62:	19 d6                	sbb    %edx,%esi
  801e64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e6c:	e9 18 ff ff ff       	jmp    801d89 <__umoddi3+0x69>
