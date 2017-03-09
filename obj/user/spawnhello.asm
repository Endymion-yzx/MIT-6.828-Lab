
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 a0 23 80 00       	push   $0x8023a0
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 be 23 80 00       	push   $0x8023be
  800056:	68 be 23 80 00       	push   $0x8023be
  80005b:	e8 20 1a 00 00       	call   801a80 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 c4 23 80 00       	push   $0x8023c4
  80006d:	6a 09                	push   $0x9
  80006f:	68 dc 23 80 00       	push   $0x8023dc
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800086:	e8 1a 0b 00 00       	call   800ba5 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 d3 0e 00 00       	call   800f9f <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 8e 0a 00 00       	call   800b64 <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 b7 0a 00 00       	call   800ba5 <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 f8 23 80 00       	push   $0x8023f8
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 e0 28 80 00 	movl   $0x8028e0,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 d6 09 00 00       	call   800b27 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 1a 01 00 00       	call   8002b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 7b 09 00 00       	call   800b27 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 f4 1e 00 00       	call   802110 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 e1 1f 00 00       	call   802240 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800281:	8b 10                	mov    (%eax),%edx
  800283:	3b 50 04             	cmp    0x4(%eax),%edx
  800286:	73 0a                	jae    800292 <sprintputch+0x1b>
		*b->buf++ = ch;
  800288:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	88 02                	mov    %al,(%edx)
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 10             	pushl  0x10(%ebp)
  8002a1:	ff 75 0c             	pushl  0xc(%ebp)
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 05 00 00 00       	call   8002b1 <vprintfmt>
	va_end(ap);
}
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 2c             	sub    $0x2c,%esp
  8002ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c3:	eb 12                	jmp    8002d7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c5:	85 c0                	test   %eax,%eax
  8002c7:	0f 84 6a 04 00 00    	je     800737 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	53                   	push   %ebx
  8002d1:	50                   	push   %eax
  8002d2:	ff d6                	call   *%esi
  8002d4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d7:	83 c7 01             	add    $0x1,%edi
  8002da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002de:	83 f8 25             	cmp    $0x25,%eax
  8002e1:	75 e2                	jne    8002c5 <vprintfmt+0x14>
  8002e3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800301:	eb 07                	jmp    80030a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800306:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 07             	movzbl (%edi),%eax
  800313:	0f b6 d0             	movzbl %al,%edx
  800316:	83 e8 23             	sub    $0x23,%eax
  800319:	3c 55                	cmp    $0x55,%al
  80031b:	0f 87 fb 03 00 00    	ja     80071c <vprintfmt+0x46b>
  800321:	0f b6 c0             	movzbl %al,%eax
  800324:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800332:	eb d6                	jmp    80030a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800337:	b8 00 00 00 00       	mov    $0x0,%eax
  80033c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034c:	83 f9 09             	cmp    $0x9,%ecx
  80034f:	77 3f                	ja     800390 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800354:	eb e9                	jmp    80033f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 40 04             	lea    0x4(%eax),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036a:	eb 2a                	jmp    800396 <vprintfmt+0xe5>
  80036c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036f:	85 c0                	test   %eax,%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	0f 49 d0             	cmovns %eax,%edx
  800379:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037f:	eb 89                	jmp    80030a <vprintfmt+0x59>
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800384:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038b:	e9 7a ff ff ff       	jmp    80030a <vprintfmt+0x59>
  800390:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800393:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800396:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039a:	0f 89 6a ff ff ff    	jns    80030a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	e9 58 ff ff ff       	jmp    80030a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b8:	e9 4d ff ff ff       	jmp    80030a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 78 04             	lea    0x4(%eax),%edi
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	53                   	push   %ebx
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff d6                	call   *%esi
			break;
  8003cb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d4:	e9 fe fe ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 78 04             	lea    0x4(%eax),%edi
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	99                   	cltd   
  8003e2:	31 d0                	xor    %edx,%eax
  8003e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 0f             	cmp    $0xf,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x145>
  8003eb:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	75 1b                	jne    800411 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	50                   	push   %eax
  8003f7:	68 33 24 80 00       	push   $0x802433
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 91 fe ff ff       	call   800294 <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800406:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 c6 fe ff ff       	jmp    8002d7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800411:	52                   	push   %edx
  800412:	68 1a 28 80 00       	push   $0x80281a
  800417:	53                   	push   %ebx
  800418:	56                   	push   %esi
  800419:	e8 76 fe ff ff       	call   800294 <printfmt>
  80041e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800421:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800427:	e9 ab fe ff ff       	jmp    8002d7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	83 c0 04             	add    $0x4,%eax
  800432:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80043a:	85 ff                	test   %edi,%edi
  80043c:	b8 2c 24 80 00       	mov    $0x80242c,%eax
  800441:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800444:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800448:	0f 8e 94 00 00 00    	jle    8004e2 <vprintfmt+0x231>
  80044e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800452:	0f 84 98 00 00 00    	je     8004f0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 d0             	pushl  -0x30(%ebp)
  80045e:	57                   	push   %edi
  80045f:	e8 5b 03 00 00       	call   8007bf <strnlen>
  800464:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800467:	29 c1                	sub    %eax,%ecx
  800469:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80046c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800479:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	eb 0f                	jmp    80048c <vprintfmt+0x1db>
					putch(padc, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	ff 75 e0             	pushl  -0x20(%ebp)
  800484:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ef 01             	sub    $0x1,%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	85 ff                	test   %edi,%edi
  80048e:	7f ed                	jg     80047d <vprintfmt+0x1cc>
  800490:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800493:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800496:	85 c9                	test   %ecx,%ecx
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	0f 49 c1             	cmovns %ecx,%eax
  8004a0:	29 c1                	sub    %eax,%ecx
  8004a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ab:	89 cb                	mov    %ecx,%ebx
  8004ad:	eb 4d                	jmp    8004fc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b3:	74 1b                	je     8004d0 <vprintfmt+0x21f>
  8004b5:	0f be c0             	movsbl %al,%eax
  8004b8:	83 e8 20             	sub    $0x20,%eax
  8004bb:	83 f8 5e             	cmp    $0x5e,%eax
  8004be:	76 10                	jbe    8004d0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 0c             	pushl  0xc(%ebp)
  8004c6:	6a 3f                	push   $0x3f
  8004c8:	ff 55 08             	call   *0x8(%ebp)
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	eb 0d                	jmp    8004dd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	52                   	push   %edx
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dd:	83 eb 01             	sub    $0x1,%ebx
  8004e0:	eb 1a                	jmp    8004fc <vprintfmt+0x24b>
  8004e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ee:	eb 0c                	jmp    8004fc <vprintfmt+0x24b>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	83 c7 01             	add    $0x1,%edi
  8004ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800503:	0f be d0             	movsbl %al,%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	74 23                	je     80052d <vprintfmt+0x27c>
  80050a:	85 f6                	test   %esi,%esi
  80050c:	78 a1                	js     8004af <vprintfmt+0x1fe>
  80050e:	83 ee 01             	sub    $0x1,%esi
  800511:	79 9c                	jns    8004af <vprintfmt+0x1fe>
  800513:	89 df                	mov    %ebx,%edi
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051b:	eb 18                	jmp    800535 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	6a 20                	push   $0x20
  800523:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800525:	83 ef 01             	sub    $0x1,%edi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb 08                	jmp    800535 <vprintfmt+0x284>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	85 ff                	test   %edi,%edi
  800537:	7f e4                	jg     80051d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80053c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	e9 90 fd ff ff       	jmp    8002d7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 f9 01             	cmp    $0x1,%ecx
  80054a:	7e 19                	jle    800565 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8b 50 04             	mov    0x4(%eax),%edx
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 40 08             	lea    0x8(%eax),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
  800563:	eb 38                	jmp    80059d <vprintfmt+0x2ec>
	else if (lflag)
  800565:	85 c9                	test   %ecx,%ecx
  800567:	74 1b                	je     800584 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 c1                	mov    %eax,%ecx
  800573:	c1 f9 1f             	sar    $0x1f,%ecx
  800576:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	eb 19                	jmp    80059d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ac:	0f 89 36 01 00 00    	jns    8006e8 <vprintfmt+0x437>
				putch('-', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 2d                	push   $0x2d
  8005b8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 d1 00             	adc    $0x0,%ecx
  8005c5:	f7 d9                	neg    %ecx
  8005c7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 14 01 00 00       	jmp    8006e8 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d4:	83 f9 01             	cmp    $0x1,%ecx
  8005d7:	7e 18                	jle    8005f1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e1:	8d 40 08             	lea    0x8(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	e9 f7 00 00 00       	jmp    8006e8 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	74 1a                	je     80060f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060a:	e9 d9 00 00 00       	jmp    8006e8 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800624:	e9 bf 00 00 00       	jmp    8006e8 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800629:	83 f9 01             	cmp    $0x1,%ecx
  80062c:	7e 13                	jle    800641 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 50 04             	mov    0x4(%eax),%edx
  800634:	8b 00                	mov    (%eax),%eax
  800636:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800639:	8d 49 08             	lea    0x8(%ecx),%ecx
  80063c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063f:	eb 28                	jmp    800669 <vprintfmt+0x3b8>
	else if (lflag)
  800641:	85 c9                	test   %ecx,%ecx
  800643:	74 13                	je     800658 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	89 d0                	mov    %edx,%eax
  80064c:	99                   	cltd   
  80064d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800650:	8d 49 04             	lea    0x4(%ecx),%ecx
  800653:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800656:	eb 11                	jmp    800669 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	89 d0                	mov    %edx,%eax
  80065f:	99                   	cltd   
  800660:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800663:	8d 49 04             	lea    0x4(%ecx),%ecx
  800666:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800669:	89 d1                	mov    %edx,%ecx
  80066b:	89 c2                	mov    %eax,%edx
			base = 8;
  80066d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800672:	eb 74                	jmp    8006e8 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 30                	push   $0x30
  80067a:	ff d6                	call   *%esi
			putch('x', putdat);
  80067c:	83 c4 08             	add    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 78                	push   $0x78
  800682:	ff d6                	call   *%esi
			num = (unsigned long long)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069c:	eb 4a                	jmp    8006e8 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069e:	83 f9 01             	cmp    $0x1,%ecx
  8006a1:	7e 15                	jle    8006b8 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ab:	8d 40 08             	lea    0x8(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006b1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b6:	eb 30                	jmp    8006e8 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006b8:	85 c9                	test   %ecx,%ecx
  8006ba:	74 17                	je     8006d3 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006cc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d1:	eb 15                	jmp    8006e8 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ef:	57                   	push   %edi
  8006f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f3:	50                   	push   %eax
  8006f4:	51                   	push   %ecx
  8006f5:	52                   	push   %edx
  8006f6:	89 da                	mov    %ebx,%edx
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	e8 c9 fa ff ff       	call   8001c8 <printnum>
			break;
  8006ff:	83 c4 20             	add    $0x20,%esp
  800702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800705:	e9 cd fb ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	52                   	push   %edx
  80070f:	ff d6                	call   *%esi
			break;
  800711:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800717:	e9 bb fb ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 25                	push   $0x25
  800722:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 03                	jmp    80072c <vprintfmt+0x47b>
  800729:	83 ef 01             	sub    $0x1,%edi
  80072c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800730:	75 f7                	jne    800729 <vprintfmt+0x478>
  800732:	e9 a0 fb ff ff       	jmp    8002d7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800737:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	5f                   	pop    %edi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	83 ec 18             	sub    $0x18,%esp
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  800748:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800752:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800755:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075c:	85 c0                	test   %eax,%eax
  80075e:	74 26                	je     800786 <vsnprintf+0x47>
  800760:	85 d2                	test   %edx,%edx
  800762:	7e 22                	jle    800786 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800764:	ff 75 14             	pushl  0x14(%ebp)
  800767:	ff 75 10             	pushl  0x10(%ebp)
  80076a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076d:	50                   	push   %eax
  80076e:	68 77 02 80 00       	push   $0x800277
  800773:	e8 39 fb ff ff       	call   8002b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800778:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 05                	jmp    80078b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800796:	50                   	push   %eax
  800797:	ff 75 10             	pushl  0x10(%ebp)
  80079a:	ff 75 0c             	pushl  0xc(%ebp)
  80079d:	ff 75 08             	pushl  0x8(%ebp)
  8007a0:	e8 9a ff ff ff       	call   80073f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b2:	eb 03                	jmp    8007b7 <strlen+0x10>
		n++;
  8007b4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bb:	75 f7                	jne    8007b4 <strlen+0xd>
		n++;
	return n;
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cd:	eb 03                	jmp    8007d2 <strnlen+0x13>
		n++;
  8007cf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d2:	39 c2                	cmp    %eax,%edx
  8007d4:	74 08                	je     8007de <strnlen+0x1f>
  8007d6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007da:	75 f3                	jne    8007cf <strnlen+0x10>
  8007dc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	83 c1 01             	add    $0x1,%ecx
  8007f2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f9:	84 db                	test   %bl,%bl
  8007fb:	75 ef                	jne    8007ec <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800807:	53                   	push   %ebx
  800808:	e8 9a ff ff ff       	call   8007a7 <strlen>
  80080d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800810:	ff 75 0c             	pushl  0xc(%ebp)
  800813:	01 d8                	add    %ebx,%eax
  800815:	50                   	push   %eax
  800816:	e8 c5 ff ff ff       	call   8007e0 <strcpy>
	return dst;
}
  80081b:	89 d8                	mov    %ebx,%eax
  80081d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 75 08             	mov    0x8(%ebp),%esi
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	89 f3                	mov    %esi,%ebx
  80082f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 0f                	jmp    800845 <strncpy+0x23>
		*dst++ = *src;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	0f b6 01             	movzbl (%ecx),%eax
  80083c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083f:	80 39 01             	cmpb   $0x1,(%ecx)
  800842:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	39 da                	cmp    %ebx,%edx
  800847:	75 ed                	jne    800836 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800849:	89 f0                	mov    %esi,%eax
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 75 08             	mov    0x8(%ebp),%esi
  800857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085a:	8b 55 10             	mov    0x10(%ebp),%edx
  80085d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085f:	85 d2                	test   %edx,%edx
  800861:	74 21                	je     800884 <strlcpy+0x35>
  800863:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800867:	89 f2                	mov    %esi,%edx
  800869:	eb 09                	jmp    800874 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086b:	83 c2 01             	add    $0x1,%edx
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800874:	39 c2                	cmp    %eax,%edx
  800876:	74 09                	je     800881 <strlcpy+0x32>
  800878:	0f b6 19             	movzbl (%ecx),%ebx
  80087b:	84 db                	test   %bl,%bl
  80087d:	75 ec                	jne    80086b <strlcpy+0x1c>
  80087f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800881:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800884:	29 f0                	sub    %esi,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800893:	eb 06                	jmp    80089b <strcmp+0x11>
		p++, q++;
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089b:	0f b6 01             	movzbl (%ecx),%eax
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 04                	je     8008a6 <strcmp+0x1c>
  8008a2:	3a 02                	cmp    (%edx),%al
  8008a4:	74 ef                	je     800895 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a6:	0f b6 c0             	movzbl %al,%eax
  8008a9:	0f b6 12             	movzbl (%edx),%edx
  8008ac:	29 d0                	sub    %edx,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	89 c3                	mov    %eax,%ebx
  8008bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bf:	eb 06                	jmp    8008c7 <strncmp+0x17>
		n--, p++, q++;
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c7:	39 d8                	cmp    %ebx,%eax
  8008c9:	74 15                	je     8008e0 <strncmp+0x30>
  8008cb:	0f b6 08             	movzbl (%eax),%ecx
  8008ce:	84 c9                	test   %cl,%cl
  8008d0:	74 04                	je     8008d6 <strncmp+0x26>
  8008d2:	3a 0a                	cmp    (%edx),%cl
  8008d4:	74 eb                	je     8008c1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 00             	movzbl (%eax),%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
  8008de:	eb 05                	jmp    8008e5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f2:	eb 07                	jmp    8008fb <strchr+0x13>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 0f                	je     800907 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f8:	83 c0 01             	add    $0x1,%eax
  8008fb:	0f b6 10             	movzbl (%eax),%edx
  8008fe:	84 d2                	test   %dl,%dl
  800900:	75 f2                	jne    8008f4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	eb 03                	jmp    800918 <strfind+0xf>
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 04                	je     800923 <strfind+0x1a>
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f2                	jne    800915 <strfind+0xc>
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 36                	je     80096b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800935:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093b:	75 28                	jne    800965 <memset+0x40>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 23                	jne    800965 <memset+0x40>
		c &= 0xFF;
  800942:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800946:	89 d3                	mov    %edx,%ebx
  800948:	c1 e3 08             	shl    $0x8,%ebx
  80094b:	89 d6                	mov    %edx,%esi
  80094d:	c1 e6 18             	shl    $0x18,%esi
  800950:	89 d0                	mov    %edx,%eax
  800952:	c1 e0 10             	shl    $0x10,%eax
  800955:	09 f0                	or     %esi,%eax
  800957:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800959:	89 d8                	mov    %ebx,%eax
  80095b:	09 d0                	or     %edx,%eax
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	fc                   	cld    
  800961:	f3 ab                	rep stos %eax,%es:(%edi)
  800963:	eb 06                	jmp    80096b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	fc                   	cld    
  800969:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096b:	89 f8                	mov    %edi,%eax
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	57                   	push   %edi
  800976:	56                   	push   %esi
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800980:	39 c6                	cmp    %eax,%esi
  800982:	73 35                	jae    8009b9 <memmove+0x47>
  800984:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800987:	39 d0                	cmp    %edx,%eax
  800989:	73 2e                	jae    8009b9 <memmove+0x47>
		s += n;
		d += n;
  80098b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 d6                	mov    %edx,%esi
  800990:	09 fe                	or     %edi,%esi
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	75 13                	jne    8009ad <memmove+0x3b>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0e                	jne    8009ad <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099f:	83 ef 04             	sub    $0x4,%edi
  8009a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
  8009a8:	fd                   	std    
  8009a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ab:	eb 09                	jmp    8009b6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ad:	83 ef 01             	sub    $0x1,%edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 1d                	jmp    8009d6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	89 f2                	mov    %esi,%edx
  8009bb:	09 c2                	or     %eax,%edx
  8009bd:	f6 c2 03             	test   $0x3,%dl
  8009c0:	75 0f                	jne    8009d1 <memmove+0x5f>
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 0a                	jne    8009d1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
  8009ca:	89 c7                	mov    %eax,%edi
  8009cc:	fc                   	cld    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 05                	jmp    8009d6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009dd:	ff 75 10             	pushl  0x10(%ebp)
  8009e0:	ff 75 0c             	pushl  0xc(%ebp)
  8009e3:	ff 75 08             	pushl  0x8(%ebp)
  8009e6:	e8 87 ff ff ff       	call   800972 <memmove>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f8:	89 c6                	mov    %eax,%esi
  8009fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	eb 1a                	jmp    800a19 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ff:	0f b6 08             	movzbl (%eax),%ecx
  800a02:	0f b6 1a             	movzbl (%edx),%ebx
  800a05:	38 d9                	cmp    %bl,%cl
  800a07:	74 0a                	je     800a13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c1             	movzbl %cl,%eax
  800a0c:	0f b6 db             	movzbl %bl,%ebx
  800a0f:	29 d8                	sub    %ebx,%eax
  800a11:	eb 0f                	jmp    800a22 <memcmp+0x35>
		s1++, s2++;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a19:	39 f0                	cmp    %esi,%eax
  800a1b:	75 e2                	jne    8009ff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a2d:	89 c1                	mov    %eax,%ecx
  800a2f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a32:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a36:	eb 0a                	jmp    800a42 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	39 da                	cmp    %ebx,%edx
  800a3d:	74 07                	je     800a46 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	39 c8                	cmp    %ecx,%eax
  800a44:	72 f2                	jb     800a38 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a55:	eb 03                	jmp    800a5a <strtol+0x11>
		s++;
  800a57:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	0f b6 01             	movzbl (%ecx),%eax
  800a5d:	3c 20                	cmp    $0x20,%al
  800a5f:	74 f6                	je     800a57 <strtol+0xe>
  800a61:	3c 09                	cmp    $0x9,%al
  800a63:	74 f2                	je     800a57 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a65:	3c 2b                	cmp    $0x2b,%al
  800a67:	75 0a                	jne    800a73 <strtol+0x2a>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a71:	eb 11                	jmp    800a84 <strtol+0x3b>
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a78:	3c 2d                	cmp    $0x2d,%al
  800a7a:	75 08                	jne    800a84 <strtol+0x3b>
		s++, neg = 1;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8a:	75 15                	jne    800aa1 <strtol+0x58>
  800a8c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8f:	75 10                	jne    800aa1 <strtol+0x58>
  800a91:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a95:	75 7c                	jne    800b13 <strtol+0xca>
		s += 2, base = 16;
  800a97:	83 c1 02             	add    $0x2,%ecx
  800a9a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9f:	eb 16                	jmp    800ab7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa1:	85 db                	test   %ebx,%ebx
  800aa3:	75 12                	jne    800ab7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaa:	80 39 30             	cmpb   $0x30,(%ecx)
  800aad:	75 08                	jne    800ab7 <strtol+0x6e>
		s++, base = 8;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abf:	0f b6 11             	movzbl (%ecx),%edx
  800ac2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac5:	89 f3                	mov    %esi,%ebx
  800ac7:	80 fb 09             	cmp    $0x9,%bl
  800aca:	77 08                	ja     800ad4 <strtol+0x8b>
			dig = *s - '0';
  800acc:	0f be d2             	movsbl %dl,%edx
  800acf:	83 ea 30             	sub    $0x30,%edx
  800ad2:	eb 22                	jmp    800af6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 57             	sub    $0x57,%edx
  800ae4:	eb 10                	jmp    800af6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 16                	ja     800b06 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af9:	7d 0b                	jge    800b06 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800afb:	83 c1 01             	add    $0x1,%ecx
  800afe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b02:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b04:	eb b9                	jmp    800abf <strtol+0x76>

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 0d                	je     800b19 <strtol+0xd0>
		*endptr = (char *) s;
  800b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0f:	89 0e                	mov    %ecx,(%esi)
  800b11:	eb 06                	jmp    800b19 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	74 98                	je     800aaf <strtol+0x66>
  800b17:	eb 9e                	jmp    800ab7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	f7 da                	neg    %edx
  800b1d:	85 ff                	test   %edi,%edi
  800b1f:	0f 45 c2             	cmovne %edx,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	89 c3                	mov    %eax,%ebx
  800b3a:	89 c7                	mov    %eax,%edi
  800b3c:	89 c6                	mov    %eax,%esi
  800b3e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 01 00 00 00       	mov    $0x1,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b72:	b8 03 00 00 00       	mov    $0x3,%eax
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	89 cb                	mov    %ecx,%ebx
  800b7c:	89 cf                	mov    %ecx,%edi
  800b7e:	89 ce                	mov    %ecx,%esi
  800b80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 03                	push   $0x3
  800b8c:	68 1f 27 80 00       	push   $0x80271f
  800b91:	6a 23                	push   $0x23
  800b93:	68 3c 27 80 00       	push   $0x80273c
  800b98:	e8 3e f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb5:	89 d1                	mov    %edx,%ecx
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	89 d7                	mov    %edx,%edi
  800bbb:	89 d6                	mov    %edx,%esi
  800bbd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_yield>:

void
sys_yield(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd4:	89 d1                	mov    %edx,%ecx
  800bd6:	89 d3                	mov    %edx,%ebx
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	be 00 00 00 00       	mov    $0x0,%esi
  800bf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bff:	89 f7                	mov    %esi,%edi
  800c01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 04                	push   $0x4
  800c0d:	68 1f 27 80 00       	push   $0x80271f
  800c12:	6a 23                	push   $0x23
  800c14:	68 3c 27 80 00       	push   $0x80273c
  800c19:	e8 bd f4 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c40:	8b 75 18             	mov    0x18(%ebp),%esi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 05                	push   $0x5
  800c4f:	68 1f 27 80 00       	push   $0x80271f
  800c54:	6a 23                	push   $0x23
  800c56:	68 3c 27 80 00       	push   $0x80273c
  800c5b:	e8 7b f4 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c76:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 df                	mov    %ebx,%edi
  800c83:	89 de                	mov    %ebx,%esi
  800c85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 17                	jle    800ca2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 06                	push   $0x6
  800c91:	68 1f 27 80 00       	push   $0x80271f
  800c96:	6a 23                	push   $0x23
  800c98:	68 3c 27 80 00       	push   $0x80273c
  800c9d:	e8 39 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 08                	push   $0x8
  800cd3:	68 1f 27 80 00       	push   $0x80271f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 3c 27 80 00       	push   $0x80273c
  800cdf:	e8 f7 f3 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	b8 09 00 00 00       	mov    $0x9,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 df                	mov    %ebx,%edi
  800d07:	89 de                	mov    %ebx,%esi
  800d09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7e 17                	jle    800d26 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	6a 09                	push   $0x9
  800d15:	68 1f 27 80 00       	push   $0x80271f
  800d1a:	6a 23                	push   $0x23
  800d1c:	68 3c 27 80 00       	push   $0x80273c
  800d21:	e8 b5 f3 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 17                	jle    800d68 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 0a                	push   $0xa
  800d57:	68 1f 27 80 00       	push   $0x80271f
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 3c 27 80 00       	push   $0x80273c
  800d63:	e8 73 f3 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	be 00 00 00 00       	mov    $0x0,%esi
  800d7b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	89 cb                	mov    %ecx,%ebx
  800dab:	89 cf                	mov    %ecx,%edi
  800dad:	89 ce                	mov    %ecx,%esi
  800daf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 17                	jle    800dcc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	50                   	push   %eax
  800db9:	6a 0d                	push   $0xd
  800dbb:	68 1f 27 80 00       	push   $0x80271f
  800dc0:	6a 23                	push   $0x23
  800dc2:	68 3c 27 80 00       	push   $0x80273c
  800dc7:	e8 0f f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	05 00 00 00 30       	add    $0x30000000,%eax
  800ddf:	c1 e8 0c             	shr    $0xc,%eax
}
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	05 00 00 00 30       	add    $0x30000000,%eax
  800def:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e01:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	c1 ea 16             	shr    $0x16,%edx
  800e0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e12:	f6 c2 01             	test   $0x1,%dl
  800e15:	74 11                	je     800e28 <fd_alloc+0x2d>
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	c1 ea 0c             	shr    $0xc,%edx
  800e1c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e23:	f6 c2 01             	test   $0x1,%dl
  800e26:	75 09                	jne    800e31 <fd_alloc+0x36>
			*fd_store = fd;
  800e28:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2f:	eb 17                	jmp    800e48 <fd_alloc+0x4d>
  800e31:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e36:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3b:	75 c9                	jne    800e06 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e3d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e43:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e50:	83 f8 1f             	cmp    $0x1f,%eax
  800e53:	77 36                	ja     800e8b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e55:	c1 e0 0c             	shl    $0xc,%eax
  800e58:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5d:	89 c2                	mov    %eax,%edx
  800e5f:	c1 ea 16             	shr    $0x16,%edx
  800e62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e69:	f6 c2 01             	test   $0x1,%dl
  800e6c:	74 24                	je     800e92 <fd_lookup+0x48>
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	c1 ea 0c             	shr    $0xc,%edx
  800e73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	74 1a                	je     800e99 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e82:	89 02                	mov    %eax,(%edx)
	return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	eb 13                	jmp    800e9e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e90:	eb 0c                	jmp    800e9e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e97:	eb 05                	jmp    800e9e <fd_lookup+0x54>
  800e99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea9:	ba c8 27 80 00       	mov    $0x8027c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eae:	eb 13                	jmp    800ec3 <dev_lookup+0x23>
  800eb0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eb3:	39 08                	cmp    %ecx,(%eax)
  800eb5:	75 0c                	jne    800ec3 <dev_lookup+0x23>
			*dev = devtab[i];
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec1:	eb 2e                	jmp    800ef1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec3:	8b 02                	mov    (%edx),%eax
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	75 e7                	jne    800eb0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec9:	a1 04 40 80 00       	mov    0x804004,%eax
  800ece:	8b 40 48             	mov    0x48(%eax),%eax
  800ed1:	83 ec 04             	sub    $0x4,%esp
  800ed4:	51                   	push   %ecx
  800ed5:	50                   	push   %eax
  800ed6:	68 4c 27 80 00       	push   $0x80274c
  800edb:	e8 d4 f2 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 10             	sub    $0x10,%esp
  800efb:	8b 75 08             	mov    0x8(%ebp),%esi
  800efe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f04:	50                   	push   %eax
  800f05:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f0b:	c1 e8 0c             	shr    $0xc,%eax
  800f0e:	50                   	push   %eax
  800f0f:	e8 36 ff ff ff       	call   800e4a <fd_lookup>
  800f14:	83 c4 08             	add    $0x8,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 05                	js     800f20 <fd_close+0x2d>
	    || fd != fd2)
  800f1b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f1e:	74 0c                	je     800f2c <fd_close+0x39>
		return (must_exist ? r : 0);
  800f20:	84 db                	test   %bl,%bl
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
  800f27:	0f 44 c2             	cmove  %edx,%eax
  800f2a:	eb 41                	jmp    800f6d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f2c:	83 ec 08             	sub    $0x8,%esp
  800f2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f32:	50                   	push   %eax
  800f33:	ff 36                	pushl  (%esi)
  800f35:	e8 66 ff ff ff       	call   800ea0 <dev_lookup>
  800f3a:	89 c3                	mov    %eax,%ebx
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 1a                	js     800f5d <fd_close+0x6a>
		if (dev->dev_close)
  800f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f46:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	74 0b                	je     800f5d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	56                   	push   %esi
  800f56:	ff d0                	call   *%eax
  800f58:	89 c3                	mov    %eax,%ebx
  800f5a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f5d:	83 ec 08             	sub    $0x8,%esp
  800f60:	56                   	push   %esi
  800f61:	6a 00                	push   $0x0
  800f63:	e8 00 fd ff ff       	call   800c68 <sys_page_unmap>
	return r;
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	89 d8                	mov    %ebx,%eax
}
  800f6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7d:	50                   	push   %eax
  800f7e:	ff 75 08             	pushl  0x8(%ebp)
  800f81:	e8 c4 fe ff ff       	call   800e4a <fd_lookup>
  800f86:	83 c4 08             	add    $0x8,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 10                	js     800f9d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	6a 01                	push   $0x1
  800f92:	ff 75 f4             	pushl  -0xc(%ebp)
  800f95:	e8 59 ff ff ff       	call   800ef3 <fd_close>
  800f9a:	83 c4 10             	add    $0x10,%esp
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <close_all>:

void
close_all(void)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	53                   	push   %ebx
  800faf:	e8 c0 ff ff ff       	call   800f74 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb4:	83 c3 01             	add    $0x1,%ebx
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	83 fb 20             	cmp    $0x20,%ebx
  800fbd:	75 ec                	jne    800fab <close_all+0xc>
		close(i);
}
  800fbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 2c             	sub    $0x2c,%esp
  800fcd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	ff 75 08             	pushl  0x8(%ebp)
  800fd7:	e8 6e fe ff ff       	call   800e4a <fd_lookup>
  800fdc:	83 c4 08             	add    $0x8,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	0f 88 c1 00 00 00    	js     8010a8 <dup+0xe4>
		return r;
	close(newfdnum);
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	56                   	push   %esi
  800feb:	e8 84 ff ff ff       	call   800f74 <close>

	newfd = INDEX2FD(newfdnum);
  800ff0:	89 f3                	mov    %esi,%ebx
  800ff2:	c1 e3 0c             	shl    $0xc,%ebx
  800ff5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ffb:	83 c4 04             	add    $0x4,%esp
  800ffe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801001:	e8 de fd ff ff       	call   800de4 <fd2data>
  801006:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801008:	89 1c 24             	mov    %ebx,(%esp)
  80100b:	e8 d4 fd ff ff       	call   800de4 <fd2data>
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801016:	89 f8                	mov    %edi,%eax
  801018:	c1 e8 16             	shr    $0x16,%eax
  80101b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801022:	a8 01                	test   $0x1,%al
  801024:	74 37                	je     80105d <dup+0x99>
  801026:	89 f8                	mov    %edi,%eax
  801028:	c1 e8 0c             	shr    $0xc,%eax
  80102b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801032:	f6 c2 01             	test   $0x1,%dl
  801035:	74 26                	je     80105d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801037:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103e:	83 ec 0c             	sub    $0xc,%esp
  801041:	25 07 0e 00 00       	and    $0xe07,%eax
  801046:	50                   	push   %eax
  801047:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104a:	6a 00                	push   $0x0
  80104c:	57                   	push   %edi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 d2 fb ff ff       	call   800c26 <sys_page_map>
  801054:	89 c7                	mov    %eax,%edi
  801056:	83 c4 20             	add    $0x20,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 2e                	js     80108b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801060:	89 d0                	mov    %edx,%eax
  801062:	c1 e8 0c             	shr    $0xc,%eax
  801065:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	25 07 0e 00 00       	and    $0xe07,%eax
  801074:	50                   	push   %eax
  801075:	53                   	push   %ebx
  801076:	6a 00                	push   $0x0
  801078:	52                   	push   %edx
  801079:	6a 00                	push   $0x0
  80107b:	e8 a6 fb ff ff       	call   800c26 <sys_page_map>
  801080:	89 c7                	mov    %eax,%edi
  801082:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801085:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801087:	85 ff                	test   %edi,%edi
  801089:	79 1d                	jns    8010a8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	53                   	push   %ebx
  80108f:	6a 00                	push   $0x0
  801091:	e8 d2 fb ff ff       	call   800c68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801096:	83 c4 08             	add    $0x8,%esp
  801099:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109c:	6a 00                	push   $0x0
  80109e:	e8 c5 fb ff ff       	call   800c68 <sys_page_unmap>
	return r;
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	89 f8                	mov    %edi,%eax
}
  8010a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 14             	sub    $0x14,%esp
  8010b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bd:	50                   	push   %eax
  8010be:	53                   	push   %ebx
  8010bf:	e8 86 fd ff ff       	call   800e4a <fd_lookup>
  8010c4:	83 c4 08             	add    $0x8,%esp
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	78 6d                	js     80113a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d3:	50                   	push   %eax
  8010d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d7:	ff 30                	pushl  (%eax)
  8010d9:	e8 c2 fd ff ff       	call   800ea0 <dev_lookup>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	78 4c                	js     801131 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010e8:	8b 42 08             	mov    0x8(%edx),%eax
  8010eb:	83 e0 03             	and    $0x3,%eax
  8010ee:	83 f8 01             	cmp    $0x1,%eax
  8010f1:	75 21                	jne    801114 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f8:	8b 40 48             	mov    0x48(%eax),%eax
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	53                   	push   %ebx
  8010ff:	50                   	push   %eax
  801100:	68 8d 27 80 00       	push   $0x80278d
  801105:	e8 aa f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801112:	eb 26                	jmp    80113a <read+0x8a>
	}
	if (!dev->dev_read)
  801114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801117:	8b 40 08             	mov    0x8(%eax),%eax
  80111a:	85 c0                	test   %eax,%eax
  80111c:	74 17                	je     801135 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	ff 75 10             	pushl  0x10(%ebp)
  801124:	ff 75 0c             	pushl  0xc(%ebp)
  801127:	52                   	push   %edx
  801128:	ff d0                	call   *%eax
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	eb 09                	jmp    80113a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801131:	89 c2                	mov    %eax,%edx
  801133:	eb 05                	jmp    80113a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801135:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80113a:	89 d0                	mov    %edx,%eax
  80113c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	57                   	push   %edi
  801145:	56                   	push   %esi
  801146:	53                   	push   %ebx
  801147:	83 ec 0c             	sub    $0xc,%esp
  80114a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801150:	bb 00 00 00 00       	mov    $0x0,%ebx
  801155:	eb 21                	jmp    801178 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	89 f0                	mov    %esi,%eax
  80115c:	29 d8                	sub    %ebx,%eax
  80115e:	50                   	push   %eax
  80115f:	89 d8                	mov    %ebx,%eax
  801161:	03 45 0c             	add    0xc(%ebp),%eax
  801164:	50                   	push   %eax
  801165:	57                   	push   %edi
  801166:	e8 45 ff ff ff       	call   8010b0 <read>
		if (m < 0)
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 10                	js     801182 <readn+0x41>
			return m;
		if (m == 0)
  801172:	85 c0                	test   %eax,%eax
  801174:	74 0a                	je     801180 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801176:	01 c3                	add    %eax,%ebx
  801178:	39 f3                	cmp    %esi,%ebx
  80117a:	72 db                	jb     801157 <readn+0x16>
  80117c:	89 d8                	mov    %ebx,%eax
  80117e:	eb 02                	jmp    801182 <readn+0x41>
  801180:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	53                   	push   %ebx
  80118e:	83 ec 14             	sub    $0x14,%esp
  801191:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801194:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	53                   	push   %ebx
  801199:	e8 ac fc ff ff       	call   800e4a <fd_lookup>
  80119e:	83 c4 08             	add    $0x8,%esp
  8011a1:	89 c2                	mov    %eax,%edx
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 68                	js     80120f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b1:	ff 30                	pushl  (%eax)
  8011b3:	e8 e8 fc ff ff       	call   800ea0 <dev_lookup>
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 47                	js     801206 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c6:	75 21                	jne    8011e9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cd:	8b 40 48             	mov    0x48(%eax),%eax
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	53                   	push   %ebx
  8011d4:	50                   	push   %eax
  8011d5:	68 a9 27 80 00       	push   $0x8027a9
  8011da:	e8 d5 ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e7:	eb 26                	jmp    80120f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8011ef:	85 d2                	test   %edx,%edx
  8011f1:	74 17                	je     80120a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f3:	83 ec 04             	sub    $0x4,%esp
  8011f6:	ff 75 10             	pushl  0x10(%ebp)
  8011f9:	ff 75 0c             	pushl  0xc(%ebp)
  8011fc:	50                   	push   %eax
  8011fd:	ff d2                	call   *%edx
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	eb 09                	jmp    80120f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801206:	89 c2                	mov    %eax,%edx
  801208:	eb 05                	jmp    80120f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80120a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80120f:	89 d0                	mov    %edx,%eax
  801211:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801214:	c9                   	leave  
  801215:	c3                   	ret    

00801216 <seek>:

int
seek(int fdnum, off_t offset)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	ff 75 08             	pushl  0x8(%ebp)
  801223:	e8 22 fc ff ff       	call   800e4a <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 0e                	js     80123d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80122f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801232:	8b 55 0c             	mov    0xc(%ebp),%edx
  801235:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	53                   	push   %ebx
  801243:	83 ec 14             	sub    $0x14,%esp
  801246:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	53                   	push   %ebx
  80124e:	e8 f7 fb ff ff       	call   800e4a <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	89 c2                	mov    %eax,%edx
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 65                	js     8012c1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801266:	ff 30                	pushl  (%eax)
  801268:	e8 33 fc ff ff       	call   800ea0 <dev_lookup>
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	78 44                	js     8012b8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127b:	75 21                	jne    80129e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80127d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801282:	8b 40 48             	mov    0x48(%eax),%eax
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	53                   	push   %ebx
  801289:	50                   	push   %eax
  80128a:	68 6c 27 80 00       	push   $0x80276c
  80128f:	e8 20 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129c:	eb 23                	jmp    8012c1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80129e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a1:	8b 52 18             	mov    0x18(%edx),%edx
  8012a4:	85 d2                	test   %edx,%edx
  8012a6:	74 14                	je     8012bc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	ff 75 0c             	pushl  0xc(%ebp)
  8012ae:	50                   	push   %eax
  8012af:	ff d2                	call   *%edx
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	eb 09                	jmp    8012c1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	eb 05                	jmp    8012c1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c1:	89 d0                	mov    %edx,%eax
  8012c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c6:	c9                   	leave  
  8012c7:	c3                   	ret    

008012c8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 14             	sub    $0x14,%esp
  8012cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	ff 75 08             	pushl  0x8(%ebp)
  8012d9:	e8 6c fb ff ff       	call   800e4a <fd_lookup>
  8012de:	83 c4 08             	add    $0x8,%esp
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 58                	js     80133f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f1:	ff 30                	pushl  (%eax)
  8012f3:	e8 a8 fb ff ff       	call   800ea0 <dev_lookup>
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 37                	js     801336 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801302:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801306:	74 32                	je     80133a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801308:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80130b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801312:	00 00 00 
	stat->st_isdir = 0;
  801315:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80131c:	00 00 00 
	stat->st_dev = dev;
  80131f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	53                   	push   %ebx
  801329:	ff 75 f0             	pushl  -0x10(%ebp)
  80132c:	ff 50 14             	call   *0x14(%eax)
  80132f:	89 c2                	mov    %eax,%edx
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	eb 09                	jmp    80133f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801336:	89 c2                	mov    %eax,%edx
  801338:	eb 05                	jmp    80133f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80133a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80133f:	89 d0                	mov    %edx,%eax
  801341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	6a 00                	push   $0x0
  801350:	ff 75 08             	pushl  0x8(%ebp)
  801353:	e8 b7 01 00 00       	call   80150f <open>
  801358:	89 c3                	mov    %eax,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 1b                	js     80137c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 0c             	pushl  0xc(%ebp)
  801367:	50                   	push   %eax
  801368:	e8 5b ff ff ff       	call   8012c8 <fstat>
  80136d:	89 c6                	mov    %eax,%esi
	close(fd);
  80136f:	89 1c 24             	mov    %ebx,(%esp)
  801372:	e8 fd fb ff ff       	call   800f74 <close>
	return r;
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	89 f0                	mov    %esi,%eax
}
  80137c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137f:	5b                   	pop    %ebx
  801380:	5e                   	pop    %esi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    

00801383 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	89 c6                	mov    %eax,%esi
  80138a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80138c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801393:	75 12                	jne    8013a7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	6a 01                	push   $0x1
  80139a:	e8 fc 0c 00 00       	call   80209b <ipc_find_env>
  80139f:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a7:	6a 07                	push   $0x7
  8013a9:	68 00 50 80 00       	push   $0x805000
  8013ae:	56                   	push   %esi
  8013af:	ff 35 00 40 80 00    	pushl  0x804000
  8013b5:	e8 8d 0c 00 00       	call   802047 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ba:	83 c4 0c             	add    $0xc,%esp
  8013bd:	6a 00                	push   $0x0
  8013bf:	53                   	push   %ebx
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 0b 0c 00 00       	call   801fd2 <ipc_recv>
}
  8013c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f1:	e8 8d ff ff ff       	call   801383 <fsipc>
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	8b 40 0c             	mov    0xc(%eax),%eax
  801404:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
  80140e:	b8 06 00 00 00       	mov    $0x6,%eax
  801413:	e8 6b ff ff ff       	call   801383 <fsipc>
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	53                   	push   %ebx
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	8b 40 0c             	mov    0xc(%eax),%eax
  80142a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 05 00 00 00       	mov    $0x5,%eax
  801439:	e8 45 ff ff ff       	call   801383 <fsipc>
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 2c                	js     80146e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	68 00 50 80 00       	push   $0x805000
  80144a:	53                   	push   %ebx
  80144b:	e8 90 f3 ff ff       	call   8007e0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801450:	a1 80 50 80 00       	mov    0x805080,%eax
  801455:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145b:	a1 84 50 80 00       	mov    0x805084,%eax
  801460:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801479:	68 d8 27 80 00       	push   $0x8027d8
  80147e:	68 90 00 00 00       	push   $0x90
  801483:	68 f6 27 80 00       	push   $0x8027f6
  801488:	e8 4e ec ff ff       	call   8000db <_panic>

0080148d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	56                   	push   %esi
  801491:	53                   	push   %ebx
  801492:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	8b 40 0c             	mov    0xc(%eax),%eax
  80149b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b0:	e8 ce fe ff ff       	call   801383 <fsipc>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 4b                	js     801506 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014bb:	39 c6                	cmp    %eax,%esi
  8014bd:	73 16                	jae    8014d5 <devfile_read+0x48>
  8014bf:	68 01 28 80 00       	push   $0x802801
  8014c4:	68 08 28 80 00       	push   $0x802808
  8014c9:	6a 7c                	push   $0x7c
  8014cb:	68 f6 27 80 00       	push   $0x8027f6
  8014d0:	e8 06 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014d5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014da:	7e 16                	jle    8014f2 <devfile_read+0x65>
  8014dc:	68 1d 28 80 00       	push   $0x80281d
  8014e1:	68 08 28 80 00       	push   $0x802808
  8014e6:	6a 7d                	push   $0x7d
  8014e8:	68 f6 27 80 00       	push   $0x8027f6
  8014ed:	e8 e9 eb ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f2:	83 ec 04             	sub    $0x4,%esp
  8014f5:	50                   	push   %eax
  8014f6:	68 00 50 80 00       	push   $0x805000
  8014fb:	ff 75 0c             	pushl  0xc(%ebp)
  8014fe:	e8 6f f4 ff ff       	call   800972 <memmove>
	return r;
  801503:	83 c4 10             	add    $0x10,%esp
}
  801506:	89 d8                	mov    %ebx,%eax
  801508:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 20             	sub    $0x20,%esp
  801516:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801519:	53                   	push   %ebx
  80151a:	e8 88 f2 ff ff       	call   8007a7 <strlen>
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801527:	7f 67                	jg     801590 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	e8 c6 f8 ff ff       	call   800dfb <fd_alloc>
  801535:	83 c4 10             	add    $0x10,%esp
		return r;
  801538:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 57                	js     801595 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	53                   	push   %ebx
  801542:	68 00 50 80 00       	push   $0x805000
  801547:	e8 94 f2 ff ff       	call   8007e0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80154c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801554:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801557:	b8 01 00 00 00       	mov    $0x1,%eax
  80155c:	e8 22 fe ff ff       	call   801383 <fsipc>
  801561:	89 c3                	mov    %eax,%ebx
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	79 14                	jns    80157e <open+0x6f>
		fd_close(fd, 0);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	6a 00                	push   $0x0
  80156f:	ff 75 f4             	pushl  -0xc(%ebp)
  801572:	e8 7c f9 ff ff       	call   800ef3 <fd_close>
		return r;
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	89 da                	mov    %ebx,%edx
  80157c:	eb 17                	jmp    801595 <open+0x86>
	}

	return fd2num(fd);
  80157e:	83 ec 0c             	sub    $0xc,%esp
  801581:	ff 75 f4             	pushl  -0xc(%ebp)
  801584:	e8 4b f8 ff ff       	call   800dd4 <fd2num>
  801589:	89 c2                	mov    %eax,%edx
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	eb 05                	jmp    801595 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801590:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801595:	89 d0                	mov    %edx,%eax
  801597:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a7:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ac:	e8 d2 fd ff ff       	call   801383 <fsipc>
}
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	57                   	push   %edi
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015bf:	6a 00                	push   $0x0
  8015c1:	ff 75 08             	pushl  0x8(%ebp)
  8015c4:	e8 46 ff ff ff       	call   80150f <open>
  8015c9:	89 c7                	mov    %eax,%edi
  8015cb:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	0f 88 3a 04 00 00    	js     801a16 <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	68 00 02 00 00       	push   $0x200
  8015e4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	57                   	push   %edi
  8015ec:	e8 50 fb ff ff       	call   801141 <readn>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015f9:	75 0c                	jne    801607 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015fb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801602:	45 4c 46 
  801605:	74 33                	je     80163a <spawn+0x87>
		close(fd);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801610:	e8 5f f9 ff ff       	call   800f74 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801615:	83 c4 0c             	add    $0xc,%esp
  801618:	68 7f 45 4c 46       	push   $0x464c457f
  80161d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801623:	68 29 28 80 00       	push   $0x802829
  801628:	e8 87 eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801635:	e9 3c 04 00 00       	jmp    801a76 <spawn+0x4c3>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80163a:	b8 07 00 00 00       	mov    $0x7,%eax
  80163f:	cd 30                	int    $0x30
  801641:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801647:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80164d:	85 c0                	test   %eax,%eax
  80164f:	0f 88 c9 03 00 00    	js     801a1e <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801655:	89 c6                	mov    %eax,%esi
  801657:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80165d:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801660:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801666:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80166c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801671:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801673:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801679:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80167f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801684:	be 00 00 00 00       	mov    $0x0,%esi
  801689:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80168c:	eb 13                	jmp    8016a1 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	50                   	push   %eax
  801692:	e8 10 f1 ff ff       	call   8007a7 <strlen>
  801697:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80169b:	83 c3 01             	add    $0x1,%ebx
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016a8:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	75 df                	jne    80168e <spawn+0xdb>
  8016af:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016b5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016bb:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016c0:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016c2:	89 fa                	mov    %edi,%edx
  8016c4:	83 e2 fc             	and    $0xfffffffc,%edx
  8016c7:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016ce:	29 c2                	sub    %eax,%edx
  8016d0:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016d6:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016d9:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016de:	0f 86 4a 03 00 00    	jbe    801a2e <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	6a 07                	push   $0x7
  8016e9:	68 00 00 40 00       	push   $0x400000
  8016ee:	6a 00                	push   $0x0
  8016f0:	e8 ee f4 ff ff       	call   800be3 <sys_page_alloc>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	0f 88 35 03 00 00    	js     801a35 <spawn+0x482>
  801700:	be 00 00 00 00       	mov    $0x0,%esi
  801705:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80170b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170e:	eb 30                	jmp    801740 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801710:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801716:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80171c:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801725:	57                   	push   %edi
  801726:	e8 b5 f0 ff ff       	call   8007e0 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80172b:	83 c4 04             	add    $0x4,%esp
  80172e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801731:	e8 71 f0 ff ff       	call   8007a7 <strlen>
  801736:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80173a:	83 c6 01             	add    $0x1,%esi
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801746:	7f c8                	jg     801710 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801748:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80174e:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801754:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80175b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801761:	74 19                	je     80177c <spawn+0x1c9>
  801763:	68 a0 28 80 00       	push   $0x8028a0
  801768:	68 08 28 80 00       	push   $0x802808
  80176d:	68 f2 00 00 00       	push   $0xf2
  801772:	68 43 28 80 00       	push   $0x802843
  801777:	e8 5f e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80177c:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801782:	89 c8                	mov    %ecx,%eax
  801784:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801789:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  80178c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801792:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801795:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  80179b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	6a 07                	push   $0x7
  8017a6:	68 00 d0 bf ee       	push   $0xeebfd000
  8017ab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017b1:	68 00 00 40 00       	push   $0x400000
  8017b6:	6a 00                	push   $0x0
  8017b8:	e8 69 f4 ff ff       	call   800c26 <sys_page_map>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	83 c4 20             	add    $0x20,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	0f 88 9a 02 00 00    	js     801a64 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	68 00 00 40 00       	push   $0x400000
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 8f f4 ff ff       	call   800c68 <sys_page_unmap>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	0f 88 7e 02 00 00    	js     801a64 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017e6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017ec:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017f3:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017f9:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801800:	00 00 00 
  801803:	e9 86 01 00 00       	jmp    80198e <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801808:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80180e:	83 38 01             	cmpl   $0x1,(%eax)
  801811:	0f 85 69 01 00 00    	jne    801980 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801817:	89 c1                	mov    %eax,%ecx
  801819:	8b 40 18             	mov    0x18(%eax),%eax
  80181c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801822:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801825:	83 f8 01             	cmp    $0x1,%eax
  801828:	19 c0                	sbb    %eax,%eax
  80182a:	83 e0 fe             	and    $0xfffffffe,%eax
  80182d:	83 c0 07             	add    $0x7,%eax
  801830:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801836:	89 c8                	mov    %ecx,%eax
  801838:	8b 49 04             	mov    0x4(%ecx),%ecx
  80183b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801841:	8b 78 10             	mov    0x10(%eax),%edi
  801844:	8b 50 14             	mov    0x14(%eax),%edx
  801847:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80184d:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801850:	89 f0                	mov    %esi,%eax
  801852:	25 ff 0f 00 00       	and    $0xfff,%eax
  801857:	74 14                	je     80186d <spawn+0x2ba>
		va -= i;
  801859:	29 c6                	sub    %eax,%esi
		memsz += i;
  80185b:	01 c2                	add    %eax,%edx
  80185d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801863:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801865:	29 c1                	sub    %eax,%ecx
  801867:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80186d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801872:	e9 f7 00 00 00       	jmp    80196e <spawn+0x3bb>
		if (i >= filesz) {
  801877:	39 df                	cmp    %ebx,%edi
  801879:	77 27                	ja     8018a2 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801884:	56                   	push   %esi
  801885:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80188b:	e8 53 f3 ff ff       	call   800be3 <sys_page_alloc>
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 89 c7 00 00 00    	jns    801962 <spawn+0x3af>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	e9 a1 01 00 00       	jmp    801a43 <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	6a 07                	push   $0x7
  8018a7:	68 00 00 40 00       	push   $0x400000
  8018ac:	6a 00                	push   $0x0
  8018ae:	e8 30 f3 ff ff       	call   800be3 <sys_page_alloc>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	0f 88 7b 01 00 00    	js     801a39 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018c7:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018d4:	e8 3d f9 ff ff       	call   801216 <seek>
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	0f 88 59 01 00 00    	js     801a3d <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018e4:	83 ec 04             	sub    $0x4,%esp
  8018e7:	89 f8                	mov    %edi,%eax
  8018e9:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f4:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8018f9:	0f 47 c1             	cmova  %ecx,%eax
  8018fc:	50                   	push   %eax
  8018fd:	68 00 00 40 00       	push   $0x400000
  801902:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801908:	e8 34 f8 ff ff       	call   801141 <readn>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	0f 88 29 01 00 00    	js     801a41 <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801921:	56                   	push   %esi
  801922:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801928:	68 00 00 40 00       	push   $0x400000
  80192d:	6a 00                	push   $0x0
  80192f:	e8 f2 f2 ff ff       	call   800c26 <sys_page_map>
  801934:	83 c4 20             	add    $0x20,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	79 15                	jns    801950 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  80193b:	50                   	push   %eax
  80193c:	68 4f 28 80 00       	push   $0x80284f
  801941:	68 25 01 00 00       	push   $0x125
  801946:	68 43 28 80 00       	push   $0x802843
  80194b:	e8 8b e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	68 00 00 40 00       	push   $0x400000
  801958:	6a 00                	push   $0x0
  80195a:	e8 09 f3 ff ff       	call   800c68 <sys_page_unmap>
  80195f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801962:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801968:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80196e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801974:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80197a:	0f 87 f7 fe ff ff    	ja     801877 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801980:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801987:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80198e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801995:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80199b:	0f 8c 67 fe ff ff    	jl     801808 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019a1:	83 ec 0c             	sub    $0xc,%esp
  8019a4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019aa:	e8 c5 f5 ff ff       	call   800f74 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8019af:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8019b6:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019b9:	83 c4 08             	add    $0x8,%esp
  8019bc:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019c9:	e8 1e f3 ff ff       	call   800cec <sys_env_set_trapframe>
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	79 15                	jns    8019ea <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  8019d5:	50                   	push   %eax
  8019d6:	68 6c 28 80 00       	push   $0x80286c
  8019db:	68 86 00 00 00       	push   $0x86
  8019e0:	68 43 28 80 00       	push   $0x802843
  8019e5:	e8 f1 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	6a 02                	push   $0x2
  8019ef:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019f5:	e8 b0 f2 ff ff       	call   800caa <sys_env_set_status>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	79 25                	jns    801a26 <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  801a01:	50                   	push   %eax
  801a02:	68 86 28 80 00       	push   $0x802886
  801a07:	68 89 00 00 00       	push   $0x89
  801a0c:	68 43 28 80 00       	push   $0x802843
  801a11:	e8 c5 e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a16:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a1c:	eb 58                	jmp    801a76 <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a1e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a24:	eb 50                	jmp    801a76 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a26:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a2c:	eb 48                	jmp    801a76 <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a2e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a33:	eb 41                	jmp    801a76 <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a35:	89 c3                	mov    %eax,%ebx
  801a37:	eb 3d                	jmp    801a76 <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a39:	89 c3                	mov    %eax,%ebx
  801a3b:	eb 06                	jmp    801a43 <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	eb 02                	jmp    801a43 <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a41:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a4c:	e8 13 f1 ff ff       	call   800b64 <sys_env_destroy>
	close(fd);
  801a51:	83 c4 04             	add    $0x4,%esp
  801a54:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a5a:	e8 15 f5 ff ff       	call   800f74 <close>
	return r;
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	eb 12                	jmp    801a76 <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	68 00 00 40 00       	push   $0x400000
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 f5 f1 ff ff       	call   800c68 <sys_page_unmap>
  801a73:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a76:	89 d8                	mov    %ebx,%eax
  801a78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5f                   	pop    %edi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a85:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a8d:	eb 03                	jmp    801a92 <spawnl+0x12>
		argc++;
  801a8f:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a92:	83 c2 04             	add    $0x4,%edx
  801a95:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801a99:	75 f4                	jne    801a8f <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801a9b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801aa2:	83 e2 f0             	and    $0xfffffff0,%edx
  801aa5:	29 d4                	sub    %edx,%esp
  801aa7:	8d 54 24 03          	lea    0x3(%esp),%edx
  801aab:	c1 ea 02             	shr    $0x2,%edx
  801aae:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ab5:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aba:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ac1:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ac8:	00 
  801ac9:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801acb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad0:	eb 0a                	jmp    801adc <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ad2:	83 c0 01             	add    $0x1,%eax
  801ad5:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ad9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801adc:	39 d0                	cmp    %edx,%eax
  801ade:	75 f2                	jne    801ad2 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	56                   	push   %esi
  801ae4:	ff 75 08             	pushl  0x8(%ebp)
  801ae7:	e8 c7 fa ff ff       	call   8015b3 <spawn>
}
  801aec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	ff 75 08             	pushl  0x8(%ebp)
  801b01:	e8 de f2 ff ff       	call   800de4 <fd2data>
  801b06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b08:	83 c4 08             	add    $0x8,%esp
  801b0b:	68 c8 28 80 00       	push   $0x8028c8
  801b10:	53                   	push   %ebx
  801b11:	e8 ca ec ff ff       	call   8007e0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b16:	8b 46 04             	mov    0x4(%esi),%eax
  801b19:	2b 06                	sub    (%esi),%eax
  801b1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b28:	00 00 00 
	stat->st_dev = &devpipe;
  801b2b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b32:	30 80 00 
	return 0;
}
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	53                   	push   %ebx
  801b45:	83 ec 0c             	sub    $0xc,%esp
  801b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b4b:	53                   	push   %ebx
  801b4c:	6a 00                	push   $0x0
  801b4e:	e8 15 f1 ff ff       	call   800c68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b53:	89 1c 24             	mov    %ebx,(%esp)
  801b56:	e8 89 f2 ff ff       	call   800de4 <fd2data>
  801b5b:	83 c4 08             	add    $0x8,%esp
  801b5e:	50                   	push   %eax
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 02 f1 ff ff       	call   800c68 <sys_page_unmap>
}
  801b66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	57                   	push   %edi
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
  801b71:	83 ec 1c             	sub    $0x1c,%esp
  801b74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b77:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b79:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b81:	83 ec 0c             	sub    $0xc,%esp
  801b84:	ff 75 e0             	pushl  -0x20(%ebp)
  801b87:	e8 48 05 00 00       	call   8020d4 <pageref>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	89 3c 24             	mov    %edi,(%esp)
  801b91:	e8 3e 05 00 00       	call   8020d4 <pageref>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	39 c3                	cmp    %eax,%ebx
  801b9b:	0f 94 c1             	sete   %cl
  801b9e:	0f b6 c9             	movzbl %cl,%ecx
  801ba1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ba4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801baa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bad:	39 ce                	cmp    %ecx,%esi
  801baf:	74 1b                	je     801bcc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bb1:	39 c3                	cmp    %eax,%ebx
  801bb3:	75 c4                	jne    801b79 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb5:	8b 42 58             	mov    0x58(%edx),%eax
  801bb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bbb:	50                   	push   %eax
  801bbc:	56                   	push   %esi
  801bbd:	68 cf 28 80 00       	push   $0x8028cf
  801bc2:	e8 ed e5 ff ff       	call   8001b4 <cprintf>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	eb ad                	jmp    801b79 <_pipeisclosed+0xe>
	}
}
  801bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd2:	5b                   	pop    %ebx
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	57                   	push   %edi
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 28             	sub    $0x28,%esp
  801be0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801be3:	56                   	push   %esi
  801be4:	e8 fb f1 ff ff       	call   800de4 <fd2data>
  801be9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	bf 00 00 00 00       	mov    $0x0,%edi
  801bf3:	eb 4b                	jmp    801c40 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf5:	89 da                	mov    %ebx,%edx
  801bf7:	89 f0                	mov    %esi,%eax
  801bf9:	e8 6d ff ff ff       	call   801b6b <_pipeisclosed>
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	75 48                	jne    801c4a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c02:	e8 bd ef ff ff       	call   800bc4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c07:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0a:	8b 0b                	mov    (%ebx),%ecx
  801c0c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c0f:	39 d0                	cmp    %edx,%eax
  801c11:	73 e2                	jae    801bf5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c16:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c1a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c1d:	89 c2                	mov    %eax,%edx
  801c1f:	c1 fa 1f             	sar    $0x1f,%edx
  801c22:	89 d1                	mov    %edx,%ecx
  801c24:	c1 e9 1b             	shr    $0x1b,%ecx
  801c27:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c2a:	83 e2 1f             	and    $0x1f,%edx
  801c2d:	29 ca                	sub    %ecx,%edx
  801c2f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c33:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c37:	83 c0 01             	add    $0x1,%eax
  801c3a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3d:	83 c7 01             	add    $0x1,%edi
  801c40:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c43:	75 c2                	jne    801c07 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c45:	8b 45 10             	mov    0x10(%ebp),%eax
  801c48:	eb 05                	jmp    801c4f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c4a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	57                   	push   %edi
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 18             	sub    $0x18,%esp
  801c60:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c63:	57                   	push   %edi
  801c64:	e8 7b f1 ff ff       	call   800de4 <fd2data>
  801c69:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c73:	eb 3d                	jmp    801cb2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c75:	85 db                	test   %ebx,%ebx
  801c77:	74 04                	je     801c7d <devpipe_read+0x26>
				return i;
  801c79:	89 d8                	mov    %ebx,%eax
  801c7b:	eb 44                	jmp    801cc1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c7d:	89 f2                	mov    %esi,%edx
  801c7f:	89 f8                	mov    %edi,%eax
  801c81:	e8 e5 fe ff ff       	call   801b6b <_pipeisclosed>
  801c86:	85 c0                	test   %eax,%eax
  801c88:	75 32                	jne    801cbc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c8a:	e8 35 ef ff ff       	call   800bc4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c8f:	8b 06                	mov    (%esi),%eax
  801c91:	3b 46 04             	cmp    0x4(%esi),%eax
  801c94:	74 df                	je     801c75 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c96:	99                   	cltd   
  801c97:	c1 ea 1b             	shr    $0x1b,%edx
  801c9a:	01 d0                	add    %edx,%eax
  801c9c:	83 e0 1f             	and    $0x1f,%eax
  801c9f:	29 d0                	sub    %edx,%eax
  801ca1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cac:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801caf:	83 c3 01             	add    $0x1,%ebx
  801cb2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb5:	75 d8                	jne    801c8f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cba:	eb 05                	jmp    801cc1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	56                   	push   %esi
  801ccd:	53                   	push   %ebx
  801cce:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd4:	50                   	push   %eax
  801cd5:	e8 21 f1 ff ff       	call   800dfb <fd_alloc>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	89 c2                	mov    %eax,%edx
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	0f 88 2c 01 00 00    	js     801e13 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	68 07 04 00 00       	push   $0x407
  801cef:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 ea ee ff ff       	call   800be3 <sys_page_alloc>
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	89 c2                	mov    %eax,%edx
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	0f 88 0d 01 00 00    	js     801e13 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d0c:	50                   	push   %eax
  801d0d:	e8 e9 f0 ff ff       	call   800dfb <fd_alloc>
  801d12:	89 c3                	mov    %eax,%ebx
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	0f 88 e2 00 00 00    	js     801e01 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 b2 ee ff ff       	call   800be3 <sys_page_alloc>
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	0f 88 c3 00 00 00    	js     801e01 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	ff 75 f4             	pushl  -0xc(%ebp)
  801d44:	e8 9b f0 ff ff       	call   800de4 <fd2data>
  801d49:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4b:	83 c4 0c             	add    $0xc,%esp
  801d4e:	68 07 04 00 00       	push   $0x407
  801d53:	50                   	push   %eax
  801d54:	6a 00                	push   $0x0
  801d56:	e8 88 ee ff ff       	call   800be3 <sys_page_alloc>
  801d5b:	89 c3                	mov    %eax,%ebx
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	0f 88 89 00 00 00    	js     801df1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6e:	e8 71 f0 ff ff       	call   800de4 <fd2data>
  801d73:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d7a:	50                   	push   %eax
  801d7b:	6a 00                	push   $0x0
  801d7d:	56                   	push   %esi
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 a1 ee ff ff       	call   800c26 <sys_page_map>
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	83 c4 20             	add    $0x20,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 55                	js     801de3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d8e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801da3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbe:	e8 11 f0 ff ff       	call   800dd4 <fd2num>
  801dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc8:	83 c4 04             	add    $0x4,%esp
  801dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dce:	e8 01 f0 ff ff       	call   800dd4 <fd2num>
  801dd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	ba 00 00 00 00       	mov    $0x0,%edx
  801de1:	eb 30                	jmp    801e13 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	56                   	push   %esi
  801de7:	6a 00                	push   $0x0
  801de9:	e8 7a ee ff ff       	call   800c68 <sys_page_unmap>
  801dee:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	ff 75 f0             	pushl  -0x10(%ebp)
  801df7:	6a 00                	push   $0x0
  801df9:	e8 6a ee ff ff       	call   800c68 <sys_page_unmap>
  801dfe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e01:	83 ec 08             	sub    $0x8,%esp
  801e04:	ff 75 f4             	pushl  -0xc(%ebp)
  801e07:	6a 00                	push   $0x0
  801e09:	e8 5a ee ff ff       	call   800c68 <sys_page_unmap>
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e13:	89 d0                	mov    %edx,%eax
  801e15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    

00801e1c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	ff 75 08             	pushl  0x8(%ebp)
  801e29:	e8 1c f0 ff ff       	call   800e4a <fd_lookup>
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 18                	js     801e4d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3b:	e8 a4 ef ff ff       	call   800de4 <fd2data>
	return _pipeisclosed(fd, p);
  801e40:	89 c2                	mov    %eax,%edx
  801e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e45:	e8 21 fd ff ff       	call   801b6b <_pipeisclosed>
  801e4a:	83 c4 10             	add    $0x10,%esp
}
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5f:	68 e7 28 80 00       	push   $0x8028e7
  801e64:	ff 75 0c             	pushl  0xc(%ebp)
  801e67:	e8 74 e9 ff ff       	call   8007e0 <strcpy>
	return 0;
}
  801e6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	57                   	push   %edi
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e84:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8a:	eb 2d                	jmp    801eb9 <devcons_write+0x46>
		m = n - tot;
  801e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e91:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e94:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e99:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e9c:	83 ec 04             	sub    $0x4,%esp
  801e9f:	53                   	push   %ebx
  801ea0:	03 45 0c             	add    0xc(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	57                   	push   %edi
  801ea5:	e8 c8 ea ff ff       	call   800972 <memmove>
		sys_cputs(buf, m);
  801eaa:	83 c4 08             	add    $0x8,%esp
  801ead:	53                   	push   %ebx
  801eae:	57                   	push   %edi
  801eaf:	e8 73 ec ff ff       	call   800b27 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb4:	01 de                	add    %ebx,%esi
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	89 f0                	mov    %esi,%eax
  801ebb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ebe:	72 cc                	jb     801e8c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 08             	sub    $0x8,%esp
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ed3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed7:	74 2a                	je     801f03 <devcons_read+0x3b>
  801ed9:	eb 05                	jmp    801ee0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801edb:	e8 e4 ec ff ff       	call   800bc4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ee0:	e8 60 ec ff ff       	call   800b45 <sys_cgetc>
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	74 f2                	je     801edb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 16                	js     801f03 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eed:	83 f8 04             	cmp    $0x4,%eax
  801ef0:	74 0c                	je     801efe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ef2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef5:	88 02                	mov    %al,(%edx)
	return 1;
  801ef7:	b8 01 00 00 00       	mov    $0x1,%eax
  801efc:	eb 05                	jmp    801f03 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f11:	6a 01                	push   $0x1
  801f13:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f16:	50                   	push   %eax
  801f17:	e8 0b ec ff ff       	call   800b27 <sys_cputs>
}
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <getchar>:

int
getchar(void)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f27:	6a 01                	push   $0x1
  801f29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f2c:	50                   	push   %eax
  801f2d:	6a 00                	push   $0x0
  801f2f:	e8 7c f1 ff ff       	call   8010b0 <read>
	if (r < 0)
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 0f                	js     801f4a <getchar+0x29>
		return r;
	if (r < 1)
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	7e 06                	jle    801f45 <getchar+0x24>
		return -E_EOF;
	return c;
  801f3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f43:	eb 05                	jmp    801f4a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f45:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f55:	50                   	push   %eax
  801f56:	ff 75 08             	pushl  0x8(%ebp)
  801f59:	e8 ec ee ff ff       	call   800e4a <fd_lookup>
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 11                	js     801f76 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f68:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6e:	39 10                	cmp    %edx,(%eax)
  801f70:	0f 94 c0             	sete   %al
  801f73:	0f b6 c0             	movzbl %al,%eax
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <opencons>:

int
opencons(void)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	e8 74 ee ff ff       	call   800dfb <fd_alloc>
  801f87:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 3e                	js     801fce <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f90:	83 ec 04             	sub    $0x4,%esp
  801f93:	68 07 04 00 00       	push   $0x407
  801f98:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9b:	6a 00                	push   $0x0
  801f9d:	e8 41 ec ff ff       	call   800be3 <sys_page_alloc>
  801fa2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	78 23                	js     801fce <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	50                   	push   %eax
  801fc4:	e8 0b ee ff ff       	call   800dd4 <fd2num>
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	83 c4 10             	add    $0x10,%esp
}
  801fce:	89 d0                	mov    %edx,%eax
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
  801fd7:	8b 75 08             	mov    0x8(%ebp),%esi
  801fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	74 0e                	je     801ff2 <ipc_recv+0x20>
  801fe4:	83 ec 0c             	sub    $0xc,%esp
  801fe7:	50                   	push   %eax
  801fe8:	e8 a6 ed ff ff       	call   800d93 <sys_ipc_recv>
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	eb 10                	jmp    802002 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	68 00 00 c0 ee       	push   $0xeec00000
  801ffa:	e8 94 ed ff ff       	call   800d93 <sys_ipc_recv>
  801fff:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  802002:	85 c0                	test   %eax,%eax
  802004:	74 16                	je     80201c <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  802006:	85 f6                	test   %esi,%esi
  802008:	74 06                	je     802010 <ipc_recv+0x3e>
  80200a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802010:	85 db                	test   %ebx,%ebx
  802012:	74 2c                	je     802040 <ipc_recv+0x6e>
  802014:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80201a:	eb 24                	jmp    802040 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  80201c:	85 f6                	test   %esi,%esi
  80201e:	74 0a                	je     80202a <ipc_recv+0x58>
  802020:	a1 04 40 80 00       	mov    0x804004,%eax
  802025:	8b 40 74             	mov    0x74(%eax),%eax
  802028:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  80202a:	85 db                	test   %ebx,%ebx
  80202c:	74 0a                	je     802038 <ipc_recv+0x66>
  80202e:	a1 04 40 80 00       	mov    0x804004,%eax
  802033:	8b 40 78             	mov    0x78(%eax),%eax
  802036:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802038:	a1 04 40 80 00       	mov    0x804004,%eax
  80203d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802040:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    

00802047 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	57                   	push   %edi
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	8b 7d 08             	mov    0x8(%ebp),%edi
  802053:	8b 75 0c             	mov    0xc(%ebp),%esi
  802056:	8b 45 10             	mov    0x10(%ebp),%eax
  802059:	85 c0                	test   %eax,%eax
  80205b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802060:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  802063:	ff 75 14             	pushl  0x14(%ebp)
  802066:	53                   	push   %ebx
  802067:	56                   	push   %esi
  802068:	57                   	push   %edi
  802069:	e8 02 ed ff ff       	call   800d70 <sys_ipc_try_send>
		if (ret == 0) break;
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	74 1e                	je     802093 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  802075:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802078:	74 12                	je     80208c <ipc_send+0x45>
  80207a:	50                   	push   %eax
  80207b:	68 f3 28 80 00       	push   $0x8028f3
  802080:	6a 39                	push   $0x39
  802082:	68 00 29 80 00       	push   $0x802900
  802087:	e8 4f e0 ff ff       	call   8000db <_panic>
		sys_yield();
  80208c:	e8 33 eb ff ff       	call   800bc4 <sys_yield>
	}
  802091:	eb d0                	jmp    802063 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802096:	5b                   	pop    %ebx
  802097:	5e                   	pop    %esi
  802098:	5f                   	pop    %edi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    

0080209b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020af:	8b 52 50             	mov    0x50(%edx),%edx
  8020b2:	39 ca                	cmp    %ecx,%edx
  8020b4:	75 0d                	jne    8020c3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020be:	8b 40 48             	mov    0x48(%eax),%eax
  8020c1:	eb 0f                	jmp    8020d2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c3:	83 c0 01             	add    $0x1,%eax
  8020c6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020cb:	75 d9                	jne    8020a6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	c1 e8 16             	shr    $0x16,%eax
  8020df:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020eb:	f6 c1 01             	test   $0x1,%cl
  8020ee:	74 1d                	je     80210d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020f0:	c1 ea 0c             	shr    $0xc,%edx
  8020f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020fa:	f6 c2 01             	test   $0x1,%dl
  8020fd:	74 0e                	je     80210d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ff:	c1 ea 0c             	shr    $0xc,%edx
  802102:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802109:	ef 
  80210a:	0f b7 c0             	movzwl %ax,%eax
}
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    
  80210f:	90                   	nop

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
