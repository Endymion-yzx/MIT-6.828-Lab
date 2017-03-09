
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 c0 10 00 00       	call   801101 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 8f 0b 00 00       	call   800be2 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 60 22 80 00       	push   $0x802260
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 78 0b 00 00       	call   800be2 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 7a 22 80 00       	push   $0x80227a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 09 11 00 00       	call   801190 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 81 10 00 00       	call   80111b <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 2f 0b 00 00       	call   800be2 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 90 22 80 00       	push   $0x802290
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 a6 10 00 00       	call   801190 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800109:	e8 d4 0a 00 00       	call   800be2 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 99 12 00 00       	call   8013e8 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 48 0a 00 00       	call   800ba1 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 d6 09 00 00       	call   800b64 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 1a 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 7b 09 00 00       	call   800b64 <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 77 1d 00 00       	call   801fd0 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 64 1e 00 00       	call   802100 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 c0 22 80 00 	movsbl 0x8022c0(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800300:	eb 12                	jmp    800314 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800302:	85 c0                	test   %eax,%eax
  800304:	0f 84 6a 04 00 00    	je     800774 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	53                   	push   %ebx
  80030e:	50                   	push   %eax
  80030f:	ff d6                	call   *%esi
  800311:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800314:	83 c7 01             	add    $0x1,%edi
  800317:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031b:	83 f8 25             	cmp    $0x25,%eax
  80031e:	75 e2                	jne    800302 <vprintfmt+0x14>
  800320:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800324:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800332:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	eb 07                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8d 47 01             	lea    0x1(%edi),%eax
  80034a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034d:	0f b6 07             	movzbl (%edi),%eax
  800350:	0f b6 d0             	movzbl %al,%edx
  800353:	83 e8 23             	sub    $0x23,%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 fb 03 00 00    	ja     800759 <vprintfmt+0x46b>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036f:	eb d6                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800383:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800386:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800389:	83 f9 09             	cmp    $0x9,%ecx
  80038c:	77 3f                	ja     8003cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800391:	eb e9                	jmp    80037c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 40 04             	lea    0x4(%eax),%eax
  8003a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a7:	eb 2a                	jmp    8003d3 <vprintfmt+0xe5>
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	0f 49 d0             	cmovns %eax,%edx
  8003b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bc:	eb 89                	jmp    800347 <vprintfmt+0x59>
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c8:	e9 7a ff ff ff       	jmp    800347 <vprintfmt+0x59>
  8003cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d7:	0f 89 6a ff ff ff    	jns    800347 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ea:	e9 58 ff ff ff       	jmp    800347 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f5:	e9 4d ff ff ff       	jmp    800347 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	53                   	push   %ebx
  800404:	ff 30                	pushl  (%eax)
  800406:	ff d6                	call   *%esi
			break;
  800408:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800411:	e9 fe fe ff ff       	jmp    800314 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 78 04             	lea    0x4(%eax),%edi
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	99                   	cltd   
  80041f:	31 d0                	xor    %edx,%eax
  800421:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 0f             	cmp    $0xf,%eax
  800426:	7f 0b                	jg     800433 <vprintfmt+0x145>
  800428:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 1b                	jne    80044e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800433:	50                   	push   %eax
  800434:	68 d8 22 80 00       	push   $0x8022d8
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 91 fe ff ff       	call   8002d1 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800449:	e9 c6 fe ff ff       	jmp    800314 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044e:	52                   	push   %edx
  80044f:	68 b2 27 80 00       	push   $0x8027b2
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 76 fe ff ff       	call   8002d1 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800464:	e9 ab fe ff ff       	jmp    800314 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	83 c0 04             	add    $0x4,%eax
  80046f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800477:	85 ff                	test   %edi,%edi
  800479:	b8 d1 22 80 00       	mov    $0x8022d1,%eax
  80047e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800481:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800485:	0f 8e 94 00 00 00    	jle    80051f <vprintfmt+0x231>
  80048b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048f:	0f 84 98 00 00 00    	je     80052d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 d0             	pushl  -0x30(%ebp)
  80049b:	57                   	push   %edi
  80049c:	e8 5b 03 00 00       	call   8007fc <strnlen>
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	29 c1                	sub    %eax,%ecx
  8004a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	eb 0f                	jmp    8004c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ef 01             	sub    $0x1,%edi
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	7f ed                	jg     8004ba <vprintfmt+0x1cc>
  8004cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	0f 49 c1             	cmovns %ecx,%eax
  8004dd:	29 c1                	sub    %eax,%ecx
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	89 cb                	mov    %ecx,%ebx
  8004ea:	eb 4d                	jmp    800539 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	74 1b                	je     80050d <vprintfmt+0x21f>
  8004f2:	0f be c0             	movsbl %al,%eax
  8004f5:	83 e8 20             	sub    $0x20,%eax
  8004f8:	83 f8 5e             	cmp    $0x5e,%eax
  8004fb:	76 10                	jbe    80050d <vprintfmt+0x21f>
					putch('?', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	6a 3f                	push   $0x3f
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 0d                	jmp    80051a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	52                   	push   %edx
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 eb 01             	sub    $0x1,%ebx
  80051d:	eb 1a                	jmp    800539 <vprintfmt+0x24b>
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052b:	eb 0c                	jmp    800539 <vprintfmt+0x24b>
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800539:	83 c7 01             	add    $0x1,%edi
  80053c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800540:	0f be d0             	movsbl %al,%edx
  800543:	85 d2                	test   %edx,%edx
  800545:	74 23                	je     80056a <vprintfmt+0x27c>
  800547:	85 f6                	test   %esi,%esi
  800549:	78 a1                	js     8004ec <vprintfmt+0x1fe>
  80054b:	83 ee 01             	sub    $0x1,%esi
  80054e:	79 9c                	jns    8004ec <vprintfmt+0x1fe>
  800550:	89 df                	mov    %ebx,%edi
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800558:	eb 18                	jmp    800572 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	6a 20                	push   $0x20
  800560:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800562:	83 ef 01             	sub    $0x1,%edi
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	eb 08                	jmp    800572 <vprintfmt+0x284>
  80056a:	89 df                	mov    %ebx,%edi
  80056c:	8b 75 08             	mov    0x8(%ebp),%esi
  80056f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800572:	85 ff                	test   %edi,%edi
  800574:	7f e4                	jg     80055a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057f:	e9 90 fd ff ff       	jmp    800314 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800584:	83 f9 01             	cmp    $0x1,%ecx
  800587:	7e 19                	jle    8005a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 50 04             	mov    0x4(%eax),%edx
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a0:	eb 38                	jmp    8005da <vprintfmt+0x2ec>
	else if (lflag)
  8005a2:	85 c9                	test   %ecx,%ecx
  8005a4:	74 1b                	je     8005c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 c1                	mov    %eax,%ecx
  8005b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	eb 19                	jmp    8005da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 c1                	mov    %eax,%ecx
  8005cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e9:	0f 89 36 01 00 00    	jns    800725 <vprintfmt+0x437>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	f7 da                	neg    %edx
  8005ff:	83 d1 00             	adc    $0x0,%ecx
  800602:	f7 d9                	neg    %ecx
  800604:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 14 01 00 00       	jmp    800725 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800611:	83 f9 01             	cmp    $0x1,%ecx
  800614:	7e 18                	jle    80062e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	8b 48 04             	mov    0x4(%eax),%ecx
  80061e:	8d 40 08             	lea    0x8(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
  800629:	e9 f7 00 00 00       	jmp    800725 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	74 1a                	je     80064c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 d9 00 00 00       	jmp    800725 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 bf 00 00 00       	jmp    800725 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800666:	83 f9 01             	cmp    $0x1,%ecx
  800669:	7e 13                	jle    80067e <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 50 04             	mov    0x4(%eax),%edx
  800671:	8b 00                	mov    (%eax),%eax
  800673:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800676:	8d 49 08             	lea    0x8(%ecx),%ecx
  800679:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80067c:	eb 28                	jmp    8006a6 <vprintfmt+0x3b8>
	else if (lflag)
  80067e:	85 c9                	test   %ecx,%ecx
  800680:	74 13                	je     800695 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
  800687:	89 d0                	mov    %edx,%eax
  800689:	99                   	cltd   
  80068a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80068d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800690:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800693:	eb 11                	jmp    8006a6 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	89 d0                	mov    %edx,%eax
  80069c:	99                   	cltd   
  80069d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006a0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8006a6:	89 d1                	mov    %edx,%ecx
  8006a8:	89 c2                	mov    %eax,%edx
			base = 8;
  8006aa:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006af:	eb 74                	jmp    800725 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 30                	push   $0x30
  8006b7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b9:	83 c4 08             	add    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 78                	push   $0x78
  8006bf:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cb:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d9:	eb 4a                	jmp    800725 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006db:	83 f9 01             	cmp    $0x1,%ecx
  8006de:	7e 15                	jle    8006f5 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e8:	8d 40 08             	lea    0x8(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ee:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f3:	eb 30                	jmp    800725 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006f5:	85 c9                	test   %ecx,%ecx
  8006f7:	74 17                	je     800710 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800709:	b8 10 00 00 00       	mov    $0x10,%eax
  80070e:	eb 15                	jmp    800725 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071a:	8d 40 04             	lea    0x4(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800720:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800725:	83 ec 0c             	sub    $0xc,%esp
  800728:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80072c:	57                   	push   %edi
  80072d:	ff 75 e0             	pushl  -0x20(%ebp)
  800730:	50                   	push   %eax
  800731:	51                   	push   %ecx
  800732:	52                   	push   %edx
  800733:	89 da                	mov    %ebx,%edx
  800735:	89 f0                	mov    %esi,%eax
  800737:	e8 c9 fa ff ff       	call   800205 <printnum>
			break;
  80073c:	83 c4 20             	add    $0x20,%esp
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800742:	e9 cd fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	52                   	push   %edx
  80074c:	ff d6                	call   *%esi
			break;
  80074e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800754:	e9 bb fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 25                	push   $0x25
  80075f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 03                	jmp    800769 <vprintfmt+0x47b>
  800766:	83 ef 01             	sub    $0x1,%edi
  800769:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80076d:	75 f7                	jne    800766 <vprintfmt+0x478>
  80076f:	e9 a0 fb ff ff       	jmp    800314 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800774:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5f                   	pop    %edi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 18             	sub    $0x18,%esp
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800788:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800792:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800799:	85 c0                	test   %eax,%eax
  80079b:	74 26                	je     8007c3 <vsnprintf+0x47>
  80079d:	85 d2                	test   %edx,%edx
  80079f:	7e 22                	jle    8007c3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a1:	ff 75 14             	pushl  0x14(%ebp)
  8007a4:	ff 75 10             	pushl  0x10(%ebp)
  8007a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007aa:	50                   	push   %eax
  8007ab:	68 b4 02 80 00       	push   $0x8002b4
  8007b0:	e8 39 fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 05                	jmp    8007c8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d3:	50                   	push   %eax
  8007d4:	ff 75 10             	pushl  0x10(%ebp)
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	ff 75 08             	pushl  0x8(%ebp)
  8007dd:	e8 9a ff ff ff       	call   80077c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	eb 03                	jmp    8007f4 <strlen+0x10>
		n++;
  8007f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f8:	75 f7                	jne    8007f1 <strlen+0xd>
		n++;
	return n;
}
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	eb 03                	jmp    80080f <strnlen+0x13>
		n++;
  80080c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 c2                	cmp    %eax,%edx
  800811:	74 08                	je     80081b <strnlen+0x1f>
  800813:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800817:	75 f3                	jne    80080c <strnlen+0x10>
  800819:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800827:	89 c2                	mov    %eax,%edx
  800829:	83 c2 01             	add    $0x1,%edx
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800833:	88 5a ff             	mov    %bl,-0x1(%edx)
  800836:	84 db                	test   %bl,%bl
  800838:	75 ef                	jne    800829 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083a:	5b                   	pop    %ebx
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	53                   	push   %ebx
  800841:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800844:	53                   	push   %ebx
  800845:	e8 9a ff ff ff       	call   8007e4 <strlen>
  80084a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	01 d8                	add    %ebx,%eax
  800852:	50                   	push   %eax
  800853:	e8 c5 ff ff ff       	call   80081d <strcpy>
	return dst;
}
  800858:	89 d8                	mov    %ebx,%eax
  80085a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086a:	89 f3                	mov    %esi,%ebx
  80086c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086f:	89 f2                	mov    %esi,%edx
  800871:	eb 0f                	jmp    800882 <strncpy+0x23>
		*dst++ = *src;
  800873:	83 c2 01             	add    $0x1,%edx
  800876:	0f b6 01             	movzbl (%ecx),%eax
  800879:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087c:	80 39 01             	cmpb   $0x1,(%ecx)
  80087f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800882:	39 da                	cmp    %ebx,%edx
  800884:	75 ed                	jne    800873 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800886:	89 f0                	mov    %esi,%eax
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
  80089a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089c:	85 d2                	test   %edx,%edx
  80089e:	74 21                	je     8008c1 <strlcpy+0x35>
  8008a0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a4:	89 f2                	mov    %esi,%edx
  8008a6:	eb 09                	jmp    8008b1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	83 c1 01             	add    $0x1,%ecx
  8008ae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b1:	39 c2                	cmp    %eax,%edx
  8008b3:	74 09                	je     8008be <strlcpy+0x32>
  8008b5:	0f b6 19             	movzbl (%ecx),%ebx
  8008b8:	84 db                	test   %bl,%bl
  8008ba:	75 ec                	jne    8008a8 <strlcpy+0x1c>
  8008bc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008be:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c1:	29 f0                	sub    %esi,%eax
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d0:	eb 06                	jmp    8008d8 <strcmp+0x11>
		p++, q++;
  8008d2:	83 c1 01             	add    $0x1,%ecx
  8008d5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d8:	0f b6 01             	movzbl (%ecx),%eax
  8008db:	84 c0                	test   %al,%al
  8008dd:	74 04                	je     8008e3 <strcmp+0x1c>
  8008df:	3a 02                	cmp    (%edx),%al
  8008e1:	74 ef                	je     8008d2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 c0             	movzbl %al,%eax
  8008e6:	0f b6 12             	movzbl (%edx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	53                   	push   %ebx
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f7:	89 c3                	mov    %eax,%ebx
  8008f9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fc:	eb 06                	jmp    800904 <strncmp+0x17>
		n--, p++, q++;
  8008fe:	83 c0 01             	add    $0x1,%eax
  800901:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800904:	39 d8                	cmp    %ebx,%eax
  800906:	74 15                	je     80091d <strncmp+0x30>
  800908:	0f b6 08             	movzbl (%eax),%ecx
  80090b:	84 c9                	test   %cl,%cl
  80090d:	74 04                	je     800913 <strncmp+0x26>
  80090f:	3a 0a                	cmp    (%edx),%cl
  800911:	74 eb                	je     8008fe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 00             	movzbl (%eax),%eax
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	29 d0                	sub    %edx,%eax
  80091b:	eb 05                	jmp    800922 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092f:	eb 07                	jmp    800938 <strchr+0x13>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 0f                	je     800944 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	0f b6 10             	movzbl (%eax),%edx
  80093b:	84 d2                	test   %dl,%dl
  80093d:	75 f2                	jne    800931 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800950:	eb 03                	jmp    800955 <strfind+0xf>
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 04                	je     800960 <strfind+0x1a>
  80095c:	84 d2                	test   %dl,%dl
  80095e:	75 f2                	jne    800952 <strfind+0xc>
			break;
	return (char *) s;
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096e:	85 c9                	test   %ecx,%ecx
  800970:	74 36                	je     8009a8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800972:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800978:	75 28                	jne    8009a2 <memset+0x40>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 23                	jne    8009a2 <memset+0x40>
		c &= 0xFF;
  80097f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800983:	89 d3                	mov    %edx,%ebx
  800985:	c1 e3 08             	shl    $0x8,%ebx
  800988:	89 d6                	mov    %edx,%esi
  80098a:	c1 e6 18             	shl    $0x18,%esi
  80098d:	89 d0                	mov    %edx,%eax
  80098f:	c1 e0 10             	shl    $0x10,%eax
  800992:	09 f0                	or     %esi,%eax
  800994:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800996:	89 d8                	mov    %ebx,%eax
  800998:	09 d0                	or     %edx,%eax
  80099a:	c1 e9 02             	shr    $0x2,%ecx
  80099d:	fc                   	cld    
  80099e:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a0:	eb 06                	jmp    8009a8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	fc                   	cld    
  8009a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a8:	89 f8                	mov    %edi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bd:	39 c6                	cmp    %eax,%esi
  8009bf:	73 35                	jae    8009f6 <memmove+0x47>
  8009c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c4:	39 d0                	cmp    %edx,%eax
  8009c6:	73 2e                	jae    8009f6 <memmove+0x47>
		s += n;
		d += n;
  8009c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 d6                	mov    %edx,%esi
  8009cd:	09 fe                	or     %edi,%esi
  8009cf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d5:	75 13                	jne    8009ea <memmove+0x3b>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 0e                	jne    8009ea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009dc:	83 ef 04             	sub    $0x4,%edi
  8009df:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
  8009e5:	fd                   	std    
  8009e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e8:	eb 09                	jmp    8009f3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ea:	83 ef 01             	sub    $0x1,%edi
  8009ed:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f0:	fd                   	std    
  8009f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f3:	fc                   	cld    
  8009f4:	eb 1d                	jmp    800a13 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f6:	89 f2                	mov    %esi,%edx
  8009f8:	09 c2                	or     %eax,%edx
  8009fa:	f6 c2 03             	test   $0x3,%dl
  8009fd:	75 0f                	jne    800a0e <memmove+0x5f>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 0a                	jne    800a0e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a04:	c1 e9 02             	shr    $0x2,%ecx
  800a07:	89 c7                	mov    %eax,%edi
  800a09:	fc                   	cld    
  800a0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0c:	eb 05                	jmp    800a13 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0e:	89 c7                	mov    %eax,%edi
  800a10:	fc                   	cld    
  800a11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1a:	ff 75 10             	pushl  0x10(%ebp)
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	ff 75 08             	pushl  0x8(%ebp)
  800a23:	e8 87 ff ff ff       	call   8009af <memmove>
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a35:	89 c6                	mov    %eax,%esi
  800a37:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3a:	eb 1a                	jmp    800a56 <memcmp+0x2c>
		if (*s1 != *s2)
  800a3c:	0f b6 08             	movzbl (%eax),%ecx
  800a3f:	0f b6 1a             	movzbl (%edx),%ebx
  800a42:	38 d9                	cmp    %bl,%cl
  800a44:	74 0a                	je     800a50 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a46:	0f b6 c1             	movzbl %cl,%eax
  800a49:	0f b6 db             	movzbl %bl,%ebx
  800a4c:	29 d8                	sub    %ebx,%eax
  800a4e:	eb 0f                	jmp    800a5f <memcmp+0x35>
		s1++, s2++;
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a56:	39 f0                	cmp    %esi,%eax
  800a58:	75 e2                	jne    800a3c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	53                   	push   %ebx
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a6a:	89 c1                	mov    %eax,%ecx
  800a6c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a73:	eb 0a                	jmp    800a7f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	39 da                	cmp    %ebx,%edx
  800a7a:	74 07                	je     800a83 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	39 c8                	cmp    %ecx,%eax
  800a81:	72 f2                	jb     800a75 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a83:	5b                   	pop    %ebx
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a92:	eb 03                	jmp    800a97 <strtol+0x11>
		s++;
  800a94:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a97:	0f b6 01             	movzbl (%ecx),%eax
  800a9a:	3c 20                	cmp    $0x20,%al
  800a9c:	74 f6                	je     800a94 <strtol+0xe>
  800a9e:	3c 09                	cmp    $0x9,%al
  800aa0:	74 f2                	je     800a94 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa2:	3c 2b                	cmp    $0x2b,%al
  800aa4:	75 0a                	jne    800ab0 <strtol+0x2a>
		s++;
  800aa6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aae:	eb 11                	jmp    800ac1 <strtol+0x3b>
  800ab0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab5:	3c 2d                	cmp    $0x2d,%al
  800ab7:	75 08                	jne    800ac1 <strtol+0x3b>
		s++, neg = 1;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac7:	75 15                	jne    800ade <strtol+0x58>
  800ac9:	80 39 30             	cmpb   $0x30,(%ecx)
  800acc:	75 10                	jne    800ade <strtol+0x58>
  800ace:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad2:	75 7c                	jne    800b50 <strtol+0xca>
		s += 2, base = 16;
  800ad4:	83 c1 02             	add    $0x2,%ecx
  800ad7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adc:	eb 16                	jmp    800af4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	75 12                	jne    800af4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aea:	75 08                	jne    800af4 <strtol+0x6e>
		s++, base = 8;
  800aec:	83 c1 01             	add    $0x1,%ecx
  800aef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afc:	0f b6 11             	movzbl (%ecx),%edx
  800aff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b02:	89 f3                	mov    %esi,%ebx
  800b04:	80 fb 09             	cmp    $0x9,%bl
  800b07:	77 08                	ja     800b11 <strtol+0x8b>
			dig = *s - '0';
  800b09:	0f be d2             	movsbl %dl,%edx
  800b0c:	83 ea 30             	sub    $0x30,%edx
  800b0f:	eb 22                	jmp    800b33 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 19             	cmp    $0x19,%bl
  800b19:	77 08                	ja     800b23 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 57             	sub    $0x57,%edx
  800b21:	eb 10                	jmp    800b33 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b26:	89 f3                	mov    %esi,%ebx
  800b28:	80 fb 19             	cmp    $0x19,%bl
  800b2b:	77 16                	ja     800b43 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b2d:	0f be d2             	movsbl %dl,%edx
  800b30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b36:	7d 0b                	jge    800b43 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b38:	83 c1 01             	add    $0x1,%ecx
  800b3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b41:	eb b9                	jmp    800afc <strtol+0x76>

	if (endptr)
  800b43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b47:	74 0d                	je     800b56 <strtol+0xd0>
		*endptr = (char *) s;
  800b49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4c:	89 0e                	mov    %ecx,(%esi)
  800b4e:	eb 06                	jmp    800b56 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b50:	85 db                	test   %ebx,%ebx
  800b52:	74 98                	je     800aec <strtol+0x66>
  800b54:	eb 9e                	jmp    800af4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	f7 da                	neg    %edx
  800b5a:	85 ff                	test   %edi,%edi
  800b5c:	0f 45 c2             	cmovne %edx,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	89 c3                	mov    %eax,%ebx
  800b77:	89 c7                	mov    %eax,%edi
  800b79:	89 c6                	mov    %eax,%esi
  800b7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800baf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 cb                	mov    %ecx,%ebx
  800bb9:	89 cf                	mov    %ecx,%edi
  800bbb:	89 ce                	mov    %ecx,%esi
  800bbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 03                	push   $0x3
  800bc9:	68 bf 25 80 00       	push   $0x8025bf
  800bce:	6a 23                	push   $0x23
  800bd0:	68 dc 25 80 00       	push   $0x8025dc
  800bd5:	e8 01 13 00 00       	call   801edb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf2:	89 d1                	mov    %edx,%ecx
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	89 d7                	mov    %edx,%edi
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_yield>:

void
sys_yield(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c11:	89 d1                	mov    %edx,%ecx
  800c13:	89 d3                	mov    %edx,%ebx
  800c15:	89 d7                	mov    %edx,%edi
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	be 00 00 00 00       	mov    $0x0,%esi
  800c2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3c:	89 f7                	mov    %esi,%edi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 04                	push   $0x4
  800c4a:	68 bf 25 80 00       	push   $0x8025bf
  800c4f:	6a 23                	push   $0x23
  800c51:	68 dc 25 80 00       	push   $0x8025dc
  800c56:	e8 80 12 00 00       	call   801edb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 05                	push   $0x5
  800c8c:	68 bf 25 80 00       	push   $0x8025bf
  800c91:	6a 23                	push   $0x23
  800c93:	68 dc 25 80 00       	push   $0x8025dc
  800c98:	e8 3e 12 00 00       	call   801edb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 06                	push   $0x6
  800cce:	68 bf 25 80 00       	push   $0x8025bf
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 dc 25 80 00       	push   $0x8025dc
  800cda:	e8 fc 11 00 00       	call   801edb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 08                	push   $0x8
  800d10:	68 bf 25 80 00       	push   $0x8025bf
  800d15:	6a 23                	push   $0x23
  800d17:	68 dc 25 80 00       	push   $0x8025dc
  800d1c:	e8 ba 11 00 00       	call   801edb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d37:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 df                	mov    %ebx,%edi
  800d44:	89 de                	mov    %ebx,%esi
  800d46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 09                	push   $0x9
  800d52:	68 bf 25 80 00       	push   $0x8025bf
  800d57:	6a 23                	push   $0x23
  800d59:	68 dc 25 80 00       	push   $0x8025dc
  800d5e:	e8 78 11 00 00       	call   801edb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	89 de                	mov    %ebx,%esi
  800d88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	7e 17                	jle    800da5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	50                   	push   %eax
  800d92:	6a 0a                	push   $0xa
  800d94:	68 bf 25 80 00       	push   $0x8025bf
  800d99:	6a 23                	push   $0x23
  800d9b:	68 dc 25 80 00       	push   $0x8025dc
  800da0:	e8 36 11 00 00       	call   801edb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	be 00 00 00 00       	mov    $0x0,%esi
  800db8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dde:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 cb                	mov    %ecx,%ebx
  800de8:	89 cf                	mov    %ecx,%edi
  800dea:	89 ce                	mov    %ecx,%esi
  800dec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7e 17                	jle    800e09 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	50                   	push   %eax
  800df6:	6a 0d                	push   $0xd
  800df8:	68 bf 25 80 00       	push   $0x8025bf
  800dfd:	6a 23                	push   $0x23
  800dff:	68 dc 25 80 00       	push   $0x8025dc
  800e04:	e8 d2 10 00 00       	call   801edb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	53                   	push   %ebx
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e1b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e1d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e21:	0f 84 48 01 00 00    	je     800f6f <pgfault+0x15e>
  800e27:	89 d8                	mov    %ebx,%eax
  800e29:	c1 e8 16             	shr    $0x16,%eax
  800e2c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e33:	a8 01                	test   $0x1,%al
  800e35:	0f 84 5f 01 00 00    	je     800f9a <pgfault+0x189>
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	c1 e8 0c             	shr    $0xc,%eax
  800e40:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e47:	f6 c2 01             	test   $0x1,%dl
  800e4a:	0f 84 4a 01 00 00    	je     800f9a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e57:	f6 c4 08             	test   $0x8,%ah
  800e5a:	75 79                	jne    800ed5 <pgfault+0xc4>
  800e5c:	e9 39 01 00 00       	jmp    800f9a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800e61:	89 d8                	mov    %ebx,%eax
  800e63:	c1 e8 16             	shr    $0x16,%eax
  800e66:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e6d:	a8 01                	test   $0x1,%al
  800e6f:	75 10                	jne    800e81 <pgfault+0x70>
  800e71:	83 ec 0c             	sub    $0xc,%esp
  800e74:	68 ea 25 80 00       	push   $0x8025ea
  800e79:	e8 73 f3 ff ff       	call   8001f1 <cprintf>
  800e7e:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800e81:	c1 eb 0c             	shr    $0xc,%ebx
  800e84:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800e8a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e91:	a8 01                	test   $0x1,%al
  800e93:	75 10                	jne    800ea5 <pgfault+0x94>
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	68 fb 25 80 00       	push   $0x8025fb
  800e9d:	e8 4f f3 ff ff       	call   8001f1 <cprintf>
  800ea2:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800ea5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800eac:	f6 c4 08             	test   $0x8,%ah
  800eaf:	75 10                	jne    800ec1 <pgfault+0xb0>
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	68 0c 26 80 00       	push   $0x80260c
  800eb9:	e8 33 f3 ff ff       	call   8001f1 <cprintf>
  800ebe:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	68 1f 26 80 00       	push   $0x80261f
  800ec9:	6a 23                	push   $0x23
  800ecb:	68 2f 26 80 00       	push   $0x80262f
  800ed0:	e8 06 10 00 00       	call   801edb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	6a 07                	push   $0x7
  800eda:	68 00 f0 7f 00       	push   $0x7ff000
  800edf:	6a 00                	push   $0x0
  800ee1:	e8 3a fd ff ff       	call   800c20 <sys_page_alloc>
  800ee6:	83 c4 10             	add    $0x10,%esp
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	79 12                	jns    800eff <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800eed:	50                   	push   %eax
  800eee:	68 3a 26 80 00       	push   $0x80263a
  800ef3:	6a 2f                	push   $0x2f
  800ef5:	68 2f 26 80 00       	push   $0x80262f
  800efa:	e8 dc 0f 00 00       	call   801edb <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800eff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	68 00 10 00 00       	push   $0x1000
  800f0d:	53                   	push   %ebx
  800f0e:	68 00 f0 7f 00       	push   $0x7ff000
  800f13:	e8 ff fa ff ff       	call   800a17 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800f18:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1f:	53                   	push   %ebx
  800f20:	6a 00                	push   $0x0
  800f22:	68 00 f0 7f 00       	push   $0x7ff000
  800f27:	6a 00                	push   $0x0
  800f29:	e8 35 fd ff ff       	call   800c63 <sys_page_map>
  800f2e:	83 c4 20             	add    $0x20,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	79 12                	jns    800f47 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800f35:	50                   	push   %eax
  800f36:	68 54 26 80 00       	push   $0x802654
  800f3b:	6a 33                	push   $0x33
  800f3d:	68 2f 26 80 00       	push   $0x80262f
  800f42:	e8 94 0f 00 00       	call   801edb <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  800f47:	83 ec 08             	sub    $0x8,%esp
  800f4a:	68 00 f0 7f 00       	push   $0x7ff000
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 4f fd ff ff       	call   800ca5 <sys_page_unmap>
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	79 5c                	jns    800fb9 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  800f5d:	50                   	push   %eax
  800f5e:	68 6c 26 80 00       	push   $0x80266c
  800f63:	6a 35                	push   $0x35
  800f65:	68 2f 26 80 00       	push   $0x80262f
  800f6a:	e8 6c 0f 00 00       	call   801edb <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f6f:	a1 08 40 80 00       	mov    0x804008,%eax
  800f74:	8b 40 48             	mov    0x48(%eax),%eax
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	50                   	push   %eax
  800f7b:	53                   	push   %ebx
  800f7c:	68 a8 26 80 00       	push   $0x8026a8
  800f81:	e8 6b f2 ff ff       	call   8001f1 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  800f86:	c7 04 24 86 26 80 00 	movl   $0x802686,(%esp)
  800f8d:	e8 5f f2 ff ff       	call   8001f1 <cprintf>
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	e9 c7 fe ff ff       	jmp    800e61 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f9a:	a1 08 40 80 00       	mov    0x804008,%eax
  800f9f:	8b 40 48             	mov    0x48(%eax),%eax
  800fa2:	83 ec 04             	sub    $0x4,%esp
  800fa5:	50                   	push   %eax
  800fa6:	53                   	push   %ebx
  800fa7:	68 a8 26 80 00       	push   $0x8026a8
  800fac:	e8 40 f2 ff ff       	call   8001f1 <cprintf>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	e9 a8 fe ff ff       	jmp    800e61 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  800fb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  800fc7:	68 11 0e 80 00       	push   $0x800e11
  800fcc:	e8 50 0f 00 00       	call   801f21 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd6:	cd 30                	int    $0x30
  800fd8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	0f 88 0d 01 00 00    	js     8010f6 <fork+0x138>
  800fe9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fee:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	75 2f                	jne    801026 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff7:	e8 e6 fb ff ff       	call   800be2 <sys_getenvid>
  800ffc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801001:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801004:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801009:	a3 08 40 80 00       	mov    %eax,0x804008
		// set_pgfault_handler(pgfault);
		return 0;
  80100e:	b8 00 00 00 00       	mov    $0x0,%eax
  801013:	e9 e1 00 00 00       	jmp    8010f9 <fork+0x13b>
  801018:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  80101e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801024:	74 77                	je     80109d <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  801026:	89 f0                	mov    %esi,%eax
  801028:	c1 e8 0a             	shr    $0xa,%eax
  80102b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  801032:	a8 01                	test   $0x1,%al
  801034:	74 0b                	je     801041 <fork+0x83>
	pte_t pte = uvpt[pn];
  801036:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  80103d:	a8 01                	test   $0x1,%al
  80103f:	75 08                	jne    801049 <fork+0x8b>
  801041:	8d 5e 01             	lea    0x1(%esi),%ebx
  801044:	c1 e3 0c             	shl    $0xc,%ebx
  801047:	eb 56                	jmp    80109f <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801049:	25 02 08 00 00       	and    $0x802,%eax
  80104e:	83 f8 01             	cmp    $0x1,%eax
  801051:	19 ff                	sbb    %edi,%edi
  801053:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801059:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80105f:	a1 08 40 80 00       	mov    0x804008,%eax
  801064:	8b 40 48             	mov    0x48(%eax),%eax
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	57                   	push   %edi
  80106b:	53                   	push   %ebx
  80106c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106f:	53                   	push   %ebx
  801070:	50                   	push   %eax
  801071:	e8 ed fb ff ff       	call   800c63 <sys_page_map>
  801076:	83 c4 20             	add    $0x20,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 7c                	js     8010f9 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  80107d:	a1 08 40 80 00       	mov    0x804008,%eax
  801082:	8b 40 48             	mov    0x48(%eax),%eax
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	57                   	push   %edi
  801089:	53                   	push   %ebx
  80108a:	50                   	push   %eax
  80108b:	53                   	push   %ebx
  80108c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108f:	e8 cf fb ff ff       	call   800c63 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801094:	83 c4 20             	add    $0x20,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	79 a6                	jns    801041 <fork+0x83>
  80109b:	eb 5c                	jmp    8010f9 <fork+0x13b>
  80109d:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  80109f:	83 c6 01             	add    $0x1,%esi
  8010a2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8010a8:	0f 86 6a ff ff ff    	jbe    801018 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	6a 07                	push   $0x7
  8010b3:	68 00 f0 bf ee       	push   $0xeebff000
  8010b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010bb:	57                   	push   %edi
  8010bc:	e8 5f fb ff ff       	call   800c20 <sys_page_alloc>
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 31                	js     8010f9 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  8010c8:	a1 08 40 80 00       	mov    0x804008,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  8010cd:	8b 40 64             	mov    0x64(%eax),%eax
  8010d0:	83 ec 08             	sub    $0x8,%esp
  8010d3:	50                   	push   %eax
  8010d4:	57                   	push   %edi
  8010d5:	e8 91 fc ff ff       	call   800d6b <sys_env_set_pgfault_upcall>
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 18                	js     8010f9 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010e1:	83 ec 08             	sub    $0x8,%esp
  8010e4:	6a 02                	push   $0x2
  8010e6:	57                   	push   %edi
  8010e7:	e8 fb fb ff ff       	call   800ce7 <sys_env_set_status>
  8010ec:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	0f 49 c7             	cmovns %edi,%eax
  8010f4:	eb 03                	jmp    8010f9 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8010f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sfork>:

// Challenge!
int
sfork(void)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801107:	68 91 26 80 00       	push   $0x802691
  80110c:	68 9f 00 00 00       	push   $0x9f
  801111:	68 2f 26 80 00       	push   $0x80262f
  801116:	e8 c0 0d 00 00       	call   801edb <_panic>

0080111b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	8b 75 08             	mov    0x8(%ebp),%esi
  801123:	8b 45 0c             	mov    0xc(%ebp),%eax
  801126:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801129:	85 c0                	test   %eax,%eax
  80112b:	74 0e                	je     80113b <ipc_recv+0x20>
  80112d:	83 ec 0c             	sub    $0xc,%esp
  801130:	50                   	push   %eax
  801131:	e8 9a fc ff ff       	call   800dd0 <sys_ipc_recv>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	eb 10                	jmp    80114b <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	68 00 00 c0 ee       	push   $0xeec00000
  801143:	e8 88 fc ff ff       	call   800dd0 <sys_ipc_recv>
  801148:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  80114b:	85 c0                	test   %eax,%eax
  80114d:	74 16                	je     801165 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  80114f:	85 f6                	test   %esi,%esi
  801151:	74 06                	je     801159 <ipc_recv+0x3e>
  801153:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801159:	85 db                	test   %ebx,%ebx
  80115b:	74 2c                	je     801189 <ipc_recv+0x6e>
  80115d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801163:	eb 24                	jmp    801189 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801165:	85 f6                	test   %esi,%esi
  801167:	74 0a                	je     801173 <ipc_recv+0x58>
  801169:	a1 08 40 80 00       	mov    0x804008,%eax
  80116e:	8b 40 74             	mov    0x74(%eax),%eax
  801171:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801173:	85 db                	test   %ebx,%ebx
  801175:	74 0a                	je     801181 <ipc_recv+0x66>
  801177:	a1 08 40 80 00       	mov    0x804008,%eax
  80117c:	8b 40 78             	mov    0x78(%eax),%eax
  80117f:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801181:	a1 08 40 80 00       	mov    0x804008,%eax
  801186:	8b 40 70             	mov    0x70(%eax),%eax
}
  801189:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80119f:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8011a9:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  8011ac:	ff 75 14             	pushl  0x14(%ebp)
  8011af:	53                   	push   %ebx
  8011b0:	56                   	push   %esi
  8011b1:	57                   	push   %edi
  8011b2:	e8 f6 fb ff ff       	call   800dad <sys_ipc_try_send>
		if (ret == 0) break;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	74 1e                	je     8011dc <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  8011be:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011c1:	74 12                	je     8011d5 <ipc_send+0x45>
  8011c3:	50                   	push   %eax
  8011c4:	68 cc 26 80 00       	push   $0x8026cc
  8011c9:	6a 39                	push   $0x39
  8011cb:	68 d9 26 80 00       	push   $0x8026d9
  8011d0:	e8 06 0d 00 00       	call   801edb <_panic>
		sys_yield();
  8011d5:	e8 27 fa ff ff       	call   800c01 <sys_yield>
	}
  8011da:	eb d0                	jmp    8011ac <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011ef:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011f2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f8:	8b 52 50             	mov    0x50(%edx),%edx
  8011fb:	39 ca                	cmp    %ecx,%edx
  8011fd:	75 0d                	jne    80120c <ipc_find_env+0x28>
			return envs[i].env_id;
  8011ff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801202:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801207:	8b 40 48             	mov    0x48(%eax),%eax
  80120a:	eb 0f                	jmp    80121b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80120c:	83 c0 01             	add    $0x1,%eax
  80120f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801214:	75 d9                	jne    8011ef <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801216:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	05 00 00 00 30       	add    $0x30000000,%eax
  801228:	c1 e8 0c             	shr    $0xc,%eax
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801230:	8b 45 08             	mov    0x8(%ebp),%eax
  801233:	05 00 00 00 30       	add    $0x30000000,%eax
  801238:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124f:	89 c2                	mov    %eax,%edx
  801251:	c1 ea 16             	shr    $0x16,%edx
  801254:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125b:	f6 c2 01             	test   $0x1,%dl
  80125e:	74 11                	je     801271 <fd_alloc+0x2d>
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 0c             	shr    $0xc,%edx
  801265:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126c:	f6 c2 01             	test   $0x1,%dl
  80126f:	75 09                	jne    80127a <fd_alloc+0x36>
			*fd_store = fd;
  801271:	89 01                	mov    %eax,(%ecx)
			return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	eb 17                	jmp    801291 <fd_alloc+0x4d>
  80127a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801284:	75 c9                	jne    80124f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801286:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80128c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801299:	83 f8 1f             	cmp    $0x1f,%eax
  80129c:	77 36                	ja     8012d4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129e:	c1 e0 0c             	shl    $0xc,%eax
  8012a1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	c1 ea 16             	shr    $0x16,%edx
  8012ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 24                	je     8012db <fd_lookup+0x48>
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	c1 ea 0c             	shr    $0xc,%edx
  8012bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c3:	f6 c2 01             	test   $0x1,%dl
  8012c6:	74 1a                	je     8012e2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	eb 13                	jmp    8012e7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb 0c                	jmp    8012e7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb 05                	jmp    8012e7 <fd_lookup+0x54>
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f2:	ba 60 27 80 00       	mov    $0x802760,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f7:	eb 13                	jmp    80130c <dev_lookup+0x23>
  8012f9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012fc:	39 08                	cmp    %ecx,(%eax)
  8012fe:	75 0c                	jne    80130c <dev_lookup+0x23>
			*dev = devtab[i];
  801300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801303:	89 01                	mov    %eax,(%ecx)
			return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
  80130a:	eb 2e                	jmp    80133a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80130c:	8b 02                	mov    (%edx),%eax
  80130e:	85 c0                	test   %eax,%eax
  801310:	75 e7                	jne    8012f9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801312:	a1 08 40 80 00       	mov    0x804008,%eax
  801317:	8b 40 48             	mov    0x48(%eax),%eax
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	51                   	push   %ecx
  80131e:	50                   	push   %eax
  80131f:	68 e4 26 80 00       	push   $0x8026e4
  801324:	e8 c8 ee ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  801329:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	83 ec 10             	sub    $0x10,%esp
  801344:	8b 75 08             	mov    0x8(%ebp),%esi
  801347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801354:	c1 e8 0c             	shr    $0xc,%eax
  801357:	50                   	push   %eax
  801358:	e8 36 ff ff ff       	call   801293 <fd_lookup>
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	78 05                	js     801369 <fd_close+0x2d>
	    || fd != fd2)
  801364:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801367:	74 0c                	je     801375 <fd_close+0x39>
		return (must_exist ? r : 0);
  801369:	84 db                	test   %bl,%bl
  80136b:	ba 00 00 00 00       	mov    $0x0,%edx
  801370:	0f 44 c2             	cmove  %edx,%eax
  801373:	eb 41                	jmp    8013b6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	ff 36                	pushl  (%esi)
  80137e:	e8 66 ff ff ff       	call   8012e9 <dev_lookup>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 1a                	js     8013a6 <fd_close+0x6a>
		if (dev->dev_close)
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801392:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801397:	85 c0                	test   %eax,%eax
  801399:	74 0b                	je     8013a6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	56                   	push   %esi
  80139f:	ff d0                	call   *%eax
  8013a1:	89 c3                	mov    %eax,%ebx
  8013a3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	56                   	push   %esi
  8013aa:	6a 00                	push   $0x0
  8013ac:	e8 f4 f8 ff ff       	call   800ca5 <sys_page_unmap>
	return r;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	89 d8                	mov    %ebx,%eax
}
  8013b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c6:	50                   	push   %eax
  8013c7:	ff 75 08             	pushl  0x8(%ebp)
  8013ca:	e8 c4 fe ff ff       	call   801293 <fd_lookup>
  8013cf:	83 c4 08             	add    $0x8,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 10                	js     8013e6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d6:	83 ec 08             	sub    $0x8,%esp
  8013d9:	6a 01                	push   $0x1
  8013db:	ff 75 f4             	pushl  -0xc(%ebp)
  8013de:	e8 59 ff ff ff       	call   80133c <fd_close>
  8013e3:	83 c4 10             	add    $0x10,%esp
}
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <close_all>:

void
close_all(void)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	e8 c0 ff ff ff       	call   8013bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fd:	83 c3 01             	add    $0x1,%ebx
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	83 fb 20             	cmp    $0x20,%ebx
  801406:	75 ec                	jne    8013f4 <close_all+0xc>
		close(i);
}
  801408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	57                   	push   %edi
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
  801413:	83 ec 2c             	sub    $0x2c,%esp
  801416:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801419:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	ff 75 08             	pushl  0x8(%ebp)
  801420:	e8 6e fe ff ff       	call   801293 <fd_lookup>
  801425:	83 c4 08             	add    $0x8,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	0f 88 c1 00 00 00    	js     8014f1 <dup+0xe4>
		return r;
	close(newfdnum);
  801430:	83 ec 0c             	sub    $0xc,%esp
  801433:	56                   	push   %esi
  801434:	e8 84 ff ff ff       	call   8013bd <close>

	newfd = INDEX2FD(newfdnum);
  801439:	89 f3                	mov    %esi,%ebx
  80143b:	c1 e3 0c             	shl    $0xc,%ebx
  80143e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801444:	83 c4 04             	add    $0x4,%esp
  801447:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144a:	e8 de fd ff ff       	call   80122d <fd2data>
  80144f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801451:	89 1c 24             	mov    %ebx,(%esp)
  801454:	e8 d4 fd ff ff       	call   80122d <fd2data>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145f:	89 f8                	mov    %edi,%eax
  801461:	c1 e8 16             	shr    $0x16,%eax
  801464:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146b:	a8 01                	test   $0x1,%al
  80146d:	74 37                	je     8014a6 <dup+0x99>
  80146f:	89 f8                	mov    %edi,%eax
  801471:	c1 e8 0c             	shr    $0xc,%eax
  801474:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147b:	f6 c2 01             	test   $0x1,%dl
  80147e:	74 26                	je     8014a6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801480:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	25 07 0e 00 00       	and    $0xe07,%eax
  80148f:	50                   	push   %eax
  801490:	ff 75 d4             	pushl  -0x2c(%ebp)
  801493:	6a 00                	push   $0x0
  801495:	57                   	push   %edi
  801496:	6a 00                	push   $0x0
  801498:	e8 c6 f7 ff ff       	call   800c63 <sys_page_map>
  80149d:	89 c7                	mov    %eax,%edi
  80149f:	83 c4 20             	add    $0x20,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 2e                	js     8014d4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a9:	89 d0                	mov    %edx,%eax
  8014ab:	c1 e8 0c             	shr    $0xc,%eax
  8014ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014bd:	50                   	push   %eax
  8014be:	53                   	push   %ebx
  8014bf:	6a 00                	push   $0x0
  8014c1:	52                   	push   %edx
  8014c2:	6a 00                	push   $0x0
  8014c4:	e8 9a f7 ff ff       	call   800c63 <sys_page_map>
  8014c9:	89 c7                	mov    %eax,%edi
  8014cb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ce:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d0:	85 ff                	test   %edi,%edi
  8014d2:	79 1d                	jns    8014f1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	53                   	push   %ebx
  8014d8:	6a 00                	push   $0x0
  8014da:	e8 c6 f7 ff ff       	call   800ca5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014df:	83 c4 08             	add    $0x8,%esp
  8014e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e5:	6a 00                	push   $0x0
  8014e7:	e8 b9 f7 ff ff       	call   800ca5 <sys_page_unmap>
	return r;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	89 f8                	mov    %edi,%eax
}
  8014f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5f                   	pop    %edi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    

008014f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	53                   	push   %ebx
  8014fd:	83 ec 14             	sub    $0x14,%esp
  801500:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801503:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	53                   	push   %ebx
  801508:	e8 86 fd ff ff       	call   801293 <fd_lookup>
  80150d:	83 c4 08             	add    $0x8,%esp
  801510:	89 c2                	mov    %eax,%edx
  801512:	85 c0                	test   %eax,%eax
  801514:	78 6d                	js     801583 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801520:	ff 30                	pushl  (%eax)
  801522:	e8 c2 fd ff ff       	call   8012e9 <dev_lookup>
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 4c                	js     80157a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801531:	8b 42 08             	mov    0x8(%edx),%eax
  801534:	83 e0 03             	and    $0x3,%eax
  801537:	83 f8 01             	cmp    $0x1,%eax
  80153a:	75 21                	jne    80155d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80153c:	a1 08 40 80 00       	mov    0x804008,%eax
  801541:	8b 40 48             	mov    0x48(%eax),%eax
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	53                   	push   %ebx
  801548:	50                   	push   %eax
  801549:	68 25 27 80 00       	push   $0x802725
  80154e:	e8 9e ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155b:	eb 26                	jmp    801583 <read+0x8a>
	}
	if (!dev->dev_read)
  80155d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801560:	8b 40 08             	mov    0x8(%eax),%eax
  801563:	85 c0                	test   %eax,%eax
  801565:	74 17                	je     80157e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	ff 75 10             	pushl  0x10(%ebp)
  80156d:	ff 75 0c             	pushl  0xc(%ebp)
  801570:	52                   	push   %edx
  801571:	ff d0                	call   *%eax
  801573:	89 c2                	mov    %eax,%edx
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	eb 09                	jmp    801583 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	eb 05                	jmp    801583 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801583:	89 d0                	mov    %edx,%eax
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	57                   	push   %edi
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	8b 7d 08             	mov    0x8(%ebp),%edi
  801596:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801599:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159e:	eb 21                	jmp    8015c1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	89 f0                	mov    %esi,%eax
  8015a5:	29 d8                	sub    %ebx,%eax
  8015a7:	50                   	push   %eax
  8015a8:	89 d8                	mov    %ebx,%eax
  8015aa:	03 45 0c             	add    0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	57                   	push   %edi
  8015af:	e8 45 ff ff ff       	call   8014f9 <read>
		if (m < 0)
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 10                	js     8015cb <readn+0x41>
			return m;
		if (m == 0)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	74 0a                	je     8015c9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bf:	01 c3                	add    %eax,%ebx
  8015c1:	39 f3                	cmp    %esi,%ebx
  8015c3:	72 db                	jb     8015a0 <readn+0x16>
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	eb 02                	jmp    8015cb <readn+0x41>
  8015c9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	5f                   	pop    %edi
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 14             	sub    $0x14,%esp
  8015da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	53                   	push   %ebx
  8015e2:	e8 ac fc ff ff       	call   801293 <fd_lookup>
  8015e7:	83 c4 08             	add    $0x8,%esp
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 68                	js     801658 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	ff 30                	pushl  (%eax)
  8015fc:	e8 e8 fc ff ff       	call   8012e9 <dev_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 47                	js     80164f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160f:	75 21                	jne    801632 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801611:	a1 08 40 80 00       	mov    0x804008,%eax
  801616:	8b 40 48             	mov    0x48(%eax),%eax
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	53                   	push   %ebx
  80161d:	50                   	push   %eax
  80161e:	68 41 27 80 00       	push   $0x802741
  801623:	e8 c9 eb ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801630:	eb 26                	jmp    801658 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801632:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801635:	8b 52 0c             	mov    0xc(%edx),%edx
  801638:	85 d2                	test   %edx,%edx
  80163a:	74 17                	je     801653 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	ff d2                	call   *%edx
  801648:	89 c2                	mov    %eax,%edx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	eb 09                	jmp    801658 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164f:	89 c2                	mov    %eax,%edx
  801651:	eb 05                	jmp    801658 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801653:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801658:	89 d0                	mov    %edx,%eax
  80165a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <seek>:

int
seek(int fdnum, off_t offset)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801665:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 22 fc ff ff       	call   801293 <fd_lookup>
  801671:	83 c4 08             	add    $0x8,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 0e                	js     801686 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801678:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80167b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 14             	sub    $0x14,%esp
  80168f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801692:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	53                   	push   %ebx
  801697:	e8 f7 fb ff ff       	call   801293 <fd_lookup>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 65                	js     80170a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016af:	ff 30                	pushl  (%eax)
  8016b1:	e8 33 fc ff ff       	call   8012e9 <dev_lookup>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 44                	js     801701 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c4:	75 21                	jne    8016e7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016cb:	8b 40 48             	mov    0x48(%eax),%eax
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	50                   	push   %eax
  8016d3:	68 04 27 80 00       	push   $0x802704
  8016d8:	e8 14 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e5:	eb 23                	jmp    80170a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ea:	8b 52 18             	mov    0x18(%edx),%edx
  8016ed:	85 d2                	test   %edx,%edx
  8016ef:	74 14                	je     801705 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	50                   	push   %eax
  8016f8:	ff d2                	call   *%edx
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	eb 09                	jmp    80170a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801701:	89 c2                	mov    %eax,%edx
  801703:	eb 05                	jmp    80170a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801705:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80170a:	89 d0                	mov    %edx,%eax
  80170c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 14             	sub    $0x14,%esp
  801718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	ff 75 08             	pushl  0x8(%ebp)
  801722:	e8 6c fb ff ff       	call   801293 <fd_lookup>
  801727:	83 c4 08             	add    $0x8,%esp
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 58                	js     801788 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173a:	ff 30                	pushl  (%eax)
  80173c:	e8 a8 fb ff ff       	call   8012e9 <dev_lookup>
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	85 c0                	test   %eax,%eax
  801746:	78 37                	js     80177f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174f:	74 32                	je     801783 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801751:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801754:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80175b:	00 00 00 
	stat->st_isdir = 0;
  80175e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801765:	00 00 00 
	stat->st_dev = dev;
  801768:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	53                   	push   %ebx
  801772:	ff 75 f0             	pushl  -0x10(%ebp)
  801775:	ff 50 14             	call   *0x14(%eax)
  801778:	89 c2                	mov    %eax,%edx
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	eb 09                	jmp    801788 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177f:	89 c2                	mov    %eax,%edx
  801781:	eb 05                	jmp    801788 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801783:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801788:	89 d0                	mov    %edx,%eax
  80178a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    

0080178f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	56                   	push   %esi
  801793:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	6a 00                	push   $0x0
  801799:	ff 75 08             	pushl  0x8(%ebp)
  80179c:	e8 b7 01 00 00       	call   801958 <open>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 1b                	js     8017c5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	50                   	push   %eax
  8017b1:	e8 5b ff ff ff       	call   801711 <fstat>
  8017b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b8:	89 1c 24             	mov    %ebx,(%esp)
  8017bb:	e8 fd fb ff ff       	call   8013bd <close>
	return r;
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	89 f0                	mov    %esi,%eax
}
  8017c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	89 c6                	mov    %eax,%esi
  8017d3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017dc:	75 12                	jne    8017f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	6a 01                	push   $0x1
  8017e3:	e8 fc f9 ff ff       	call   8011e4 <ipc_find_env>
  8017e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ed:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f0:	6a 07                	push   $0x7
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	56                   	push   %esi
  8017f8:	ff 35 00 40 80 00    	pushl  0x804000
  8017fe:	e8 8d f9 ff ff       	call   801190 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801803:	83 c4 0c             	add    $0xc,%esp
  801806:	6a 00                	push   $0x0
  801808:	53                   	push   %ebx
  801809:	6a 00                	push   $0x0
  80180b:	e8 0b f9 ff ff       	call   80111b <ipc_recv>
}
  801810:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801813:	5b                   	pop    %ebx
  801814:	5e                   	pop    %esi
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	8b 40 0c             	mov    0xc(%eax),%eax
  801823:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801830:	ba 00 00 00 00       	mov    $0x0,%edx
  801835:	b8 02 00 00 00       	mov    $0x2,%eax
  80183a:	e8 8d ff ff ff       	call   8017cc <fsipc>
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	8b 40 0c             	mov    0xc(%eax),%eax
  80184d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 06 00 00 00       	mov    $0x6,%eax
  80185c:	e8 6b ff ff ff       	call   8017cc <fsipc>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	83 ec 04             	sub    $0x4,%esp
  80186a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	8b 40 0c             	mov    0xc(%eax),%eax
  801873:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 05 00 00 00       	mov    $0x5,%eax
  801882:	e8 45 ff ff ff       	call   8017cc <fsipc>
  801887:	85 c0                	test   %eax,%eax
  801889:	78 2c                	js     8018b7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	68 00 50 80 00       	push   $0x805000
  801893:	53                   	push   %ebx
  801894:	e8 84 ef ff ff       	call   80081d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801899:	a1 80 50 80 00       	mov    0x805080,%eax
  80189e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a4:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018c2:	68 70 27 80 00       	push   $0x802770
  8018c7:	68 90 00 00 00       	push   $0x90
  8018cc:	68 8e 27 80 00       	push   $0x80278e
  8018d1:	e8 05 06 00 00       	call   801edb <_panic>

008018d6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f9:	e8 ce fe ff ff       	call   8017cc <fsipc>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	85 c0                	test   %eax,%eax
  801902:	78 4b                	js     80194f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801904:	39 c6                	cmp    %eax,%esi
  801906:	73 16                	jae    80191e <devfile_read+0x48>
  801908:	68 99 27 80 00       	push   $0x802799
  80190d:	68 a0 27 80 00       	push   $0x8027a0
  801912:	6a 7c                	push   $0x7c
  801914:	68 8e 27 80 00       	push   $0x80278e
  801919:	e8 bd 05 00 00       	call   801edb <_panic>
	assert(r <= PGSIZE);
  80191e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801923:	7e 16                	jle    80193b <devfile_read+0x65>
  801925:	68 b5 27 80 00       	push   $0x8027b5
  80192a:	68 a0 27 80 00       	push   $0x8027a0
  80192f:	6a 7d                	push   $0x7d
  801931:	68 8e 27 80 00       	push   $0x80278e
  801936:	e8 a0 05 00 00       	call   801edb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	50                   	push   %eax
  80193f:	68 00 50 80 00       	push   $0x805000
  801944:	ff 75 0c             	pushl  0xc(%ebp)
  801947:	e8 63 f0 ff ff       	call   8009af <memmove>
	return r;
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	89 d8                	mov    %ebx,%eax
  801951:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801954:	5b                   	pop    %ebx
  801955:	5e                   	pop    %esi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    

00801958 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	53                   	push   %ebx
  80195c:	83 ec 20             	sub    $0x20,%esp
  80195f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801962:	53                   	push   %ebx
  801963:	e8 7c ee ff ff       	call   8007e4 <strlen>
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801970:	7f 67                	jg     8019d9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801978:	50                   	push   %eax
  801979:	e8 c6 f8 ff ff       	call   801244 <fd_alloc>
  80197e:	83 c4 10             	add    $0x10,%esp
		return r;
  801981:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801983:	85 c0                	test   %eax,%eax
  801985:	78 57                	js     8019de <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	53                   	push   %ebx
  80198b:	68 00 50 80 00       	push   $0x805000
  801990:	e8 88 ee ff ff       	call   80081d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801995:	8b 45 0c             	mov    0xc(%ebp),%eax
  801998:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80199d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a5:	e8 22 fe ff ff       	call   8017cc <fsipc>
  8019aa:	89 c3                	mov    %eax,%ebx
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	79 14                	jns    8019c7 <open+0x6f>
		fd_close(fd, 0);
  8019b3:	83 ec 08             	sub    $0x8,%esp
  8019b6:	6a 00                	push   $0x0
  8019b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bb:	e8 7c f9 ff ff       	call   80133c <fd_close>
		return r;
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	89 da                	mov    %ebx,%edx
  8019c5:	eb 17                	jmp    8019de <open+0x86>
	}

	return fd2num(fd);
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cd:	e8 4b f8 ff ff       	call   80121d <fd2num>
  8019d2:	89 c2                	mov    %eax,%edx
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	eb 05                	jmp    8019de <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019d9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019de:	89 d0                	mov    %edx,%eax
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f5:	e8 d2 fd ff ff       	call   8017cc <fsipc>
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	ff 75 08             	pushl  0x8(%ebp)
  801a0a:	e8 1e f8 ff ff       	call   80122d <fd2data>
  801a0f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a11:	83 c4 08             	add    $0x8,%esp
  801a14:	68 c1 27 80 00       	push   $0x8027c1
  801a19:	53                   	push   %ebx
  801a1a:	e8 fe ed ff ff       	call   80081d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a1f:	8b 46 04             	mov    0x4(%esi),%eax
  801a22:	2b 06                	sub    (%esi),%eax
  801a24:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a2a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a31:	00 00 00 
	stat->st_dev = &devpipe;
  801a34:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a3b:	30 80 00 
	return 0;
}
  801a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a54:	53                   	push   %ebx
  801a55:	6a 00                	push   $0x0
  801a57:	e8 49 f2 ff ff       	call   800ca5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5c:	89 1c 24             	mov    %ebx,(%esp)
  801a5f:	e8 c9 f7 ff ff       	call   80122d <fd2data>
  801a64:	83 c4 08             	add    $0x8,%esp
  801a67:	50                   	push   %eax
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 36 f2 ff ff       	call   800ca5 <sys_page_unmap>
}
  801a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 1c             	sub    $0x1c,%esp
  801a7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a80:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a82:	a1 08 40 80 00       	mov    0x804008,%eax
  801a87:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a90:	e8 fc 04 00 00       	call   801f91 <pageref>
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	89 3c 24             	mov    %edi,(%esp)
  801a9a:	e8 f2 04 00 00       	call   801f91 <pageref>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	39 c3                	cmp    %eax,%ebx
  801aa4:	0f 94 c1             	sete   %cl
  801aa7:	0f b6 c9             	movzbl %cl,%ecx
  801aaa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aad:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ab3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab6:	39 ce                	cmp    %ecx,%esi
  801ab8:	74 1b                	je     801ad5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aba:	39 c3                	cmp    %eax,%ebx
  801abc:	75 c4                	jne    801a82 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abe:	8b 42 58             	mov    0x58(%edx),%eax
  801ac1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac4:	50                   	push   %eax
  801ac5:	56                   	push   %esi
  801ac6:	68 c8 27 80 00       	push   $0x8027c8
  801acb:	e8 21 e7 ff ff       	call   8001f1 <cprintf>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	eb ad                	jmp    801a82 <_pipeisclosed+0xe>
	}
}
  801ad5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	57                   	push   %edi
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 28             	sub    $0x28,%esp
  801ae9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aec:	56                   	push   %esi
  801aed:	e8 3b f7 ff ff       	call   80122d <fd2data>
  801af2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	bf 00 00 00 00       	mov    $0x0,%edi
  801afc:	eb 4b                	jmp    801b49 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801afe:	89 da                	mov    %ebx,%edx
  801b00:	89 f0                	mov    %esi,%eax
  801b02:	e8 6d ff ff ff       	call   801a74 <_pipeisclosed>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	75 48                	jne    801b53 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b0b:	e8 f1 f0 ff ff       	call   800c01 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b10:	8b 43 04             	mov    0x4(%ebx),%eax
  801b13:	8b 0b                	mov    (%ebx),%ecx
  801b15:	8d 51 20             	lea    0x20(%ecx),%edx
  801b18:	39 d0                	cmp    %edx,%eax
  801b1a:	73 e2                	jae    801afe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b23:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b26:	89 c2                	mov    %eax,%edx
  801b28:	c1 fa 1f             	sar    $0x1f,%edx
  801b2b:	89 d1                	mov    %edx,%ecx
  801b2d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b30:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b33:	83 e2 1f             	and    $0x1f,%edx
  801b36:	29 ca                	sub    %ecx,%edx
  801b38:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b3c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b40:	83 c0 01             	add    $0x1,%eax
  801b43:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b46:	83 c7 01             	add    $0x1,%edi
  801b49:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4c:	75 c2                	jne    801b10 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b51:	eb 05                	jmp    801b58 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
  801b66:	83 ec 18             	sub    $0x18,%esp
  801b69:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b6c:	57                   	push   %edi
  801b6d:	e8 bb f6 ff ff       	call   80122d <fd2data>
  801b72:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7c:	eb 3d                	jmp    801bbb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7e:	85 db                	test   %ebx,%ebx
  801b80:	74 04                	je     801b86 <devpipe_read+0x26>
				return i;
  801b82:	89 d8                	mov    %ebx,%eax
  801b84:	eb 44                	jmp    801bca <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b86:	89 f2                	mov    %esi,%edx
  801b88:	89 f8                	mov    %edi,%eax
  801b8a:	e8 e5 fe ff ff       	call   801a74 <_pipeisclosed>
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	75 32                	jne    801bc5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b93:	e8 69 f0 ff ff       	call   800c01 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b98:	8b 06                	mov    (%esi),%eax
  801b9a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b9d:	74 df                	je     801b7e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b9f:	99                   	cltd   
  801ba0:	c1 ea 1b             	shr    $0x1b,%edx
  801ba3:	01 d0                	add    %edx,%eax
  801ba5:	83 e0 1f             	and    $0x1f,%eax
  801ba8:	29 d0                	sub    %edx,%eax
  801baa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bb5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb8:	83 c3 01             	add    $0x1,%ebx
  801bbb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bbe:	75 d8                	jne    801b98 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc3:	eb 05                	jmp    801bca <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	56                   	push   %esi
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	e8 61 f6 ff ff       	call   801244 <fd_alloc>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	89 c2                	mov    %eax,%edx
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 2c 01 00 00    	js     801d1c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfb:	6a 00                	push   $0x0
  801bfd:	e8 1e f0 ff ff       	call   800c20 <sys_page_alloc>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	89 c2                	mov    %eax,%edx
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 0d 01 00 00    	js     801d1c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c15:	50                   	push   %eax
  801c16:	e8 29 f6 ff ff       	call   801244 <fd_alloc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 e2 00 00 00    	js     801d0a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c28:	83 ec 04             	sub    $0x4,%esp
  801c2b:	68 07 04 00 00       	push   $0x407
  801c30:	ff 75 f0             	pushl  -0x10(%ebp)
  801c33:	6a 00                	push   $0x0
  801c35:	e8 e6 ef ff ff       	call   800c20 <sys_page_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 c3 00 00 00    	js     801d0a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4d:	e8 db f5 ff ff       	call   80122d <fd2data>
  801c52:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c54:	83 c4 0c             	add    $0xc,%esp
  801c57:	68 07 04 00 00       	push   $0x407
  801c5c:	50                   	push   %eax
  801c5d:	6a 00                	push   $0x0
  801c5f:	e8 bc ef ff ff       	call   800c20 <sys_page_alloc>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	0f 88 89 00 00 00    	js     801cfa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 f0             	pushl  -0x10(%ebp)
  801c77:	e8 b1 f5 ff ff       	call   80122d <fd2data>
  801c7c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c83:	50                   	push   %eax
  801c84:	6a 00                	push   $0x0
  801c86:	56                   	push   %esi
  801c87:	6a 00                	push   $0x0
  801c89:	e8 d5 ef ff ff       	call   800c63 <sys_page_map>
  801c8e:	89 c3                	mov    %eax,%ebx
  801c90:	83 c4 20             	add    $0x20,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	78 55                	js     801cec <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c97:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc7:	e8 51 f5 ff ff       	call   80121d <fd2num>
  801ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd1:	83 c4 04             	add    $0x4,%esp
  801cd4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd7:	e8 41 f5 ff ff       	call   80121d <fd2num>
  801cdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cea:	eb 30                	jmp    801d1c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cec:	83 ec 08             	sub    $0x8,%esp
  801cef:	56                   	push   %esi
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 ae ef ff ff       	call   800ca5 <sys_page_unmap>
  801cf7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cfa:	83 ec 08             	sub    $0x8,%esp
  801cfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801d00:	6a 00                	push   $0x0
  801d02:	e8 9e ef ff ff       	call   800ca5 <sys_page_unmap>
  801d07:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d0a:	83 ec 08             	sub    $0x8,%esp
  801d0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 8e ef ff ff       	call   800ca5 <sys_page_unmap>
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d1c:	89 d0                	mov    %edx,%eax
  801d1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	ff 75 08             	pushl  0x8(%ebp)
  801d32:	e8 5c f5 ff ff       	call   801293 <fd_lookup>
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 18                	js     801d56 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	ff 75 f4             	pushl  -0xc(%ebp)
  801d44:	e8 e4 f4 ff ff       	call   80122d <fd2data>
	return _pipeisclosed(fd, p);
  801d49:	89 c2                	mov    %eax,%edx
  801d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4e:	e8 21 fd ff ff       	call   801a74 <_pipeisclosed>
  801d53:	83 c4 10             	add    $0x10,%esp
}
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d68:	68 e0 27 80 00       	push   $0x8027e0
  801d6d:	ff 75 0c             	pushl  0xc(%ebp)
  801d70:	e8 a8 ea ff ff       	call   80081d <strcpy>
	return 0;
}
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d88:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d93:	eb 2d                	jmp    801dc2 <devcons_write+0x46>
		m = n - tot;
  801d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d98:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d9a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d9d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da5:	83 ec 04             	sub    $0x4,%esp
  801da8:	53                   	push   %ebx
  801da9:	03 45 0c             	add    0xc(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	57                   	push   %edi
  801dae:	e8 fc eb ff ff       	call   8009af <memmove>
		sys_cputs(buf, m);
  801db3:	83 c4 08             	add    $0x8,%esp
  801db6:	53                   	push   %ebx
  801db7:	57                   	push   %edi
  801db8:	e8 a7 ed ff ff       	call   800b64 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbd:	01 de                	add    %ebx,%esi
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	89 f0                	mov    %esi,%eax
  801dc4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc7:	72 cc                	jb     801d95 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcc:	5b                   	pop    %ebx
  801dcd:	5e                   	pop    %esi
  801dce:	5f                   	pop    %edi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ddc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de0:	74 2a                	je     801e0c <devcons_read+0x3b>
  801de2:	eb 05                	jmp    801de9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de4:	e8 18 ee ff ff       	call   800c01 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de9:	e8 94 ed ff ff       	call   800b82 <sys_cgetc>
  801dee:	85 c0                	test   %eax,%eax
  801df0:	74 f2                	je     801de4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 16                	js     801e0c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df6:	83 f8 04             	cmp    $0x4,%eax
  801df9:	74 0c                	je     801e07 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfe:	88 02                	mov    %al,(%edx)
	return 1;
  801e00:	b8 01 00 00 00       	mov    $0x1,%eax
  801e05:	eb 05                	jmp    801e0c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e1a:	6a 01                	push   $0x1
  801e1c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1f:	50                   	push   %eax
  801e20:	e8 3f ed ff ff       	call   800b64 <sys_cputs>
}
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <getchar>:

int
getchar(void)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e30:	6a 01                	push   $0x1
  801e32:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e35:	50                   	push   %eax
  801e36:	6a 00                	push   $0x0
  801e38:	e8 bc f6 ff ff       	call   8014f9 <read>
	if (r < 0)
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 0f                	js     801e53 <getchar+0x29>
		return r;
	if (r < 1)
  801e44:	85 c0                	test   %eax,%eax
  801e46:	7e 06                	jle    801e4e <getchar+0x24>
		return -E_EOF;
	return c;
  801e48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e4c:	eb 05                	jmp    801e53 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e4e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5e:	50                   	push   %eax
  801e5f:	ff 75 08             	pushl  0x8(%ebp)
  801e62:	e8 2c f4 ff ff       	call   801293 <fd_lookup>
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 11                	js     801e7f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e71:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e77:	39 10                	cmp    %edx,(%eax)
  801e79:	0f 94 c0             	sete   %al
  801e7c:	0f b6 c0             	movzbl %al,%eax
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <opencons>:

int
opencons(void)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8a:	50                   	push   %eax
  801e8b:	e8 b4 f3 ff ff       	call   801244 <fd_alloc>
  801e90:	83 c4 10             	add    $0x10,%esp
		return r;
  801e93:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e95:	85 c0                	test   %eax,%eax
  801e97:	78 3e                	js     801ed7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e99:	83 ec 04             	sub    $0x4,%esp
  801e9c:	68 07 04 00 00       	push   $0x407
  801ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea4:	6a 00                	push   $0x0
  801ea6:	e8 75 ed ff ff       	call   800c20 <sys_page_alloc>
  801eab:	83 c4 10             	add    $0x10,%esp
		return r;
  801eae:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 23                	js     801ed7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	50                   	push   %eax
  801ecd:	e8 4b f3 ff ff       	call   80121d <fd2num>
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	83 c4 10             	add    $0x10,%esp
}
  801ed7:	89 d0                	mov    %edx,%eax
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ee0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ee3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ee9:	e8 f4 ec ff ff       	call   800be2 <sys_getenvid>
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	ff 75 0c             	pushl  0xc(%ebp)
  801ef4:	ff 75 08             	pushl  0x8(%ebp)
  801ef7:	56                   	push   %esi
  801ef8:	50                   	push   %eax
  801ef9:	68 ec 27 80 00       	push   $0x8027ec
  801efe:	e8 ee e2 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f03:	83 c4 18             	add    $0x18,%esp
  801f06:	53                   	push   %ebx
  801f07:	ff 75 10             	pushl  0x10(%ebp)
  801f0a:	e8 91 e2 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801f0f:	c7 04 24 d9 27 80 00 	movl   $0x8027d9,(%esp)
  801f16:	e8 d6 e2 ff ff       	call   8001f1 <cprintf>
  801f1b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f1e:	cc                   	int3   
  801f1f:	eb fd                	jmp    801f1e <_panic+0x43>

00801f21 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f27:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f2e:	75 31                	jne    801f61 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801f30:	a1 08 40 80 00       	mov    0x804008,%eax
  801f35:	8b 40 48             	mov    0x48(%eax),%eax
  801f38:	83 ec 04             	sub    $0x4,%esp
  801f3b:	6a 07                	push   $0x7
  801f3d:	68 00 f0 bf ee       	push   $0xeebff000
  801f42:	50                   	push   %eax
  801f43:	e8 d8 ec ff ff       	call   800c20 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801f48:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4d:	8b 40 48             	mov    0x48(%eax),%eax
  801f50:	83 c4 08             	add    $0x8,%esp
  801f53:	68 6b 1f 80 00       	push   $0x801f6b
  801f58:	50                   	push   %eax
  801f59:	e8 0d ee ff ff       	call   800d6b <sys_env_set_pgfault_upcall>
  801f5e:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f61:	8b 45 08             	mov    0x8(%ebp),%eax
  801f64:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f69:	c9                   	leave  
  801f6a:	c3                   	ret    

00801f6b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f6b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f6c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f71:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f73:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801f76:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801f79:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801f7d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801f81:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801f84:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801f86:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f8a:	61                   	popa   
	addl $4, %esp        // skip eip
  801f8b:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801f8e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801f8f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f90:	c3                   	ret    

00801f91 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f97:	89 d0                	mov    %edx,%eax
  801f99:	c1 e8 16             	shr    $0x16,%eax
  801f9c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa8:	f6 c1 01             	test   $0x1,%cl
  801fab:	74 1d                	je     801fca <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fad:	c1 ea 0c             	shr    $0xc,%edx
  801fb0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb7:	f6 c2 01             	test   $0x1,%dl
  801fba:	74 0e                	je     801fca <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fbc:	c1 ea 0c             	shr    $0xc,%edx
  801fbf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc6:	ef 
  801fc7:	0f b7 c0             	movzwl %ax,%eax
}
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
