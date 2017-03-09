
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 20 22 80 00       	push   $0x802220
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 2c 0f 00 00       	call   800f75 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 98 22 80 00       	push   $0x802298
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 48 22 80 00       	push   $0x802248
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 42 0b 00 00       	call   800bb8 <sys_yield>
	sys_yield();
  800076:	e8 3d 0b 00 00       	call   800bb8 <sys_yield>
	sys_yield();
  80007b:	e8 38 0b 00 00       	call   800bb8 <sys_yield>
	sys_yield();
  800080:	e8 33 0b 00 00       	call   800bb8 <sys_yield>
	sys_yield();
  800085:	e8 2e 0b 00 00       	call   800bb8 <sys_yield>
	sys_yield();
  80008a:	e8 29 0b 00 00       	call   800bb8 <sys_yield>
	sys_yield();
  80008f:	e8 24 0b 00 00       	call   800bb8 <sys_yield>
	sys_yield();
  800094:	e8 1f 0b 00 00       	call   800bb8 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 70 22 80 00 	movl   $0x802270,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 ab 0a 00 00       	call   800b58 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000c0:	e8 d4 0a 00 00       	call   800b99 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 97 11 00 00       	call   80129d <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 48 0a 00 00       	call   800b58 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 d6 09 00 00       	call   800b1b <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 1a 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 7b 09 00 00       	call   800b1b <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 80 1d 00 00       	call   801f90 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 6d 1e 00 00       	call   8020c0 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 c0 22 80 00 	movsbl 0x8022c0(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800271:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800275:	8b 10                	mov    (%eax),%edx
  800277:	3b 50 04             	cmp    0x4(%eax),%edx
  80027a:	73 0a                	jae    800286 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	88 02                	mov    %al,(%edx)
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
	va_end(ap);
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 2c             	sub    $0x2c,%esp
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b7:	eb 12                	jmp    8002cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	0f 84 6a 04 00 00    	je     80072b <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	ff d6                	call   *%esi
  8002c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	83 c7 01             	add    $0x1,%edi
  8002ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	75 e2                	jne    8002b9 <vprintfmt+0x14>
  8002d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	eb 07                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8d 47 01             	lea    0x1(%edi),%eax
  800301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800304:	0f b6 07             	movzbl (%edi),%eax
  800307:	0f b6 d0             	movzbl %al,%edx
  80030a:	83 e8 23             	sub    $0x23,%eax
  80030d:	3c 55                	cmp    $0x55,%al
  80030f:	0f 87 fb 03 00 00    	ja     800710 <vprintfmt+0x46b>
  800315:	0f b6 c0             	movzbl %al,%eax
  800318:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800322:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800326:	eb d6                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
  800330:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800336:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800340:	83 f9 09             	cmp    $0x9,%ecx
  800343:	77 3f                	ja     800384 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800348:	eb e9                	jmp    800333 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8d 40 04             	lea    0x4(%eax),%eax
  800358:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035e:	eb 2a                	jmp    80038a <vprintfmt+0xe5>
  800360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800363:	85 c0                	test   %eax,%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	0f 49 d0             	cmovns %eax,%edx
  80036d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800373:	eb 89                	jmp    8002fe <vprintfmt+0x59>
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800378:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037f:	e9 7a ff ff ff       	jmp    8002fe <vprintfmt+0x59>
  800384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038e:	0f 89 6a ff ff ff    	jns    8002fe <vprintfmt+0x59>
				width = precision, precision = -1;
  800394:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800397:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	e9 58 ff ff ff       	jmp    8002fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ac:	e9 4d ff ff ff       	jmp    8002fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 78 04             	lea    0x4(%eax),%edi
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	53                   	push   %ebx
  8003bb:	ff 30                	pushl  (%eax)
  8003bd:	ff d6                	call   *%esi
			break;
  8003bf:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c8:	e9 fe fe ff ff       	jmp    8002cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 78 04             	lea    0x4(%eax),%edi
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	99                   	cltd   
  8003d6:	31 d0                	xor    %edx,%eax
  8003d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003da:	83 f8 0f             	cmp    $0xf,%eax
  8003dd:	7f 0b                	jg     8003ea <vprintfmt+0x145>
  8003df:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	75 1b                	jne    800405 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003ea:	50                   	push   %eax
  8003eb:	68 d8 22 80 00       	push   $0x8022d8
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 91 fe ff ff       	call   800288 <printfmt>
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
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 c6 fe ff ff       	jmp    8002cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800405:	52                   	push   %edx
  800406:	68 9a 27 80 00       	push   $0x80279a
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 76 fe ff ff       	call   800288 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800415:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	e9 ab fe ff ff       	jmp    8002cb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	83 c0 04             	add    $0x4,%eax
  800426:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042e:	85 ff                	test   %edi,%edi
  800430:	b8 d1 22 80 00       	mov    $0x8022d1,%eax
  800435:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 8e 94 00 00 00    	jle    8004d6 <vprintfmt+0x231>
  800442:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800446:	0f 84 98 00 00 00    	je     8004e4 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 d0             	pushl  -0x30(%ebp)
  800452:	57                   	push   %edi
  800453:	e8 5b 03 00 00       	call   8007b3 <strnlen>
  800458:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800460:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800463:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	eb 0f                	jmp    800480 <vprintfmt+0x1db>
					putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	ff 75 e0             	pushl  -0x20(%ebp)
  800478:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ef 01             	sub    $0x1,%edi
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	85 ff                	test   %edi,%edi
  800482:	7f ed                	jg     800471 <vprintfmt+0x1cc>
  800484:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800487:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80048a:	85 c9                	test   %ecx,%ecx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c1             	cmovns %ecx,%eax
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 75 08             	mov    %esi,0x8(%ebp)
  800499:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049f:	89 cb                	mov    %ecx,%ebx
  8004a1:	eb 4d                	jmp    8004f0 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a7:	74 1b                	je     8004c4 <vprintfmt+0x21f>
  8004a9:	0f be c0             	movsbl %al,%eax
  8004ac:	83 e8 20             	sub    $0x20,%eax
  8004af:	83 f8 5e             	cmp    $0x5e,%eax
  8004b2:	76 10                	jbe    8004c4 <vprintfmt+0x21f>
					putch('?', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	6a 3f                	push   $0x3f
  8004bc:	ff 55 08             	call   *0x8(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	eb 0d                	jmp    8004d1 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	52                   	push   %edx
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	eb 1a                	jmp    8004f0 <vprintfmt+0x24b>
  8004d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e2:	eb 0c                	jmp    8004f0 <vprintfmt+0x24b>
  8004e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f0:	83 c7 01             	add    $0x1,%edi
  8004f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f7:	0f be d0             	movsbl %al,%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 23                	je     800521 <vprintfmt+0x27c>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	78 a1                	js     8004a3 <vprintfmt+0x1fe>
  800502:	83 ee 01             	sub    $0x1,%esi
  800505:	79 9c                	jns    8004a3 <vprintfmt+0x1fe>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	eb 18                	jmp    800529 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	6a 20                	push   $0x20
  800517:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800519:	83 ef 01             	sub    $0x1,%edi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 08                	jmp    800529 <vprintfmt+0x284>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f e4                	jg     800511 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800536:	e9 90 fd ff ff       	jmp    8002cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053b:	83 f9 01             	cmp    $0x1,%ecx
  80053e:	7e 19                	jle    800559 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8b 50 04             	mov    0x4(%eax),%edx
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 40 08             	lea    0x8(%eax),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
  800557:	eb 38                	jmp    800591 <vprintfmt+0x2ec>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 1b                	je     800578 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 19                	jmp    800591 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	89 c1                	mov    %eax,%ecx
  800582:	c1 f9 1f             	sar    $0x1f,%ecx
  800585:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 40 04             	lea    0x4(%eax),%eax
  80058e:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a0:	0f 89 36 01 00 00    	jns    8006dc <vprintfmt+0x437>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b4:	f7 da                	neg    %edx
  8005b6:	83 d1 00             	adc    $0x0,%ecx
  8005b9:	f7 d9                	neg    %ecx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 14 01 00 00       	jmp    8006dc <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7e 18                	jle    8005e5 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d5:	8d 40 08             	lea    0x8(%eax),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e0:	e9 f7 00 00 00       	jmp    8006dc <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	74 1a                	je     800603 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fe:	e9 d9 00 00 00       	jmp    8006dc <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 bf 00 00 00       	jmp    8006dc <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061d:	83 f9 01             	cmp    $0x1,%ecx
  800620:	7e 13                	jle    800635 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 50 04             	mov    0x4(%eax),%edx
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80062d:	8d 49 08             	lea    0x8(%ecx),%ecx
  800630:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800633:	eb 28                	jmp    80065d <vprintfmt+0x3b8>
	else if (lflag)
  800635:	85 c9                	test   %ecx,%ecx
  800637:	74 13                	je     80064c <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	89 d0                	mov    %edx,%eax
  800640:	99                   	cltd   
  800641:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800644:	8d 49 04             	lea    0x4(%ecx),%ecx
  800647:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80064a:	eb 11                	jmp    80065d <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	89 d0                	mov    %edx,%eax
  800653:	99                   	cltd   
  800654:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800657:	8d 49 04             	lea    0x4(%ecx),%ecx
  80065a:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  80065d:	89 d1                	mov    %edx,%ecx
  80065f:	89 c2                	mov    %eax,%edx
			base = 8;
  800661:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800666:	eb 74                	jmp    8006dc <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 30                	push   $0x30
  80066e:	ff d6                	call   *%esi
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 78                	push   $0x78
  800676:	ff d6                	call   *%esi
			num = (unsigned long long)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800690:	eb 4a                	jmp    8006dc <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800692:	83 f9 01             	cmp    $0x1,%ecx
  800695:	7e 15                	jle    8006ac <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8b 48 04             	mov    0x4(%eax),%ecx
  80069f:	8d 40 08             	lea    0x8(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006aa:	eb 30                	jmp    8006dc <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ac:	85 c9                	test   %ecx,%ecx
  8006ae:	74 17                	je     8006c7 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c5:	eb 15                	jmp    8006dc <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	8d 40 04             	lea    0x4(%eax),%eax
  8006d4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e3:	57                   	push   %edi
  8006e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e7:	50                   	push   %eax
  8006e8:	51                   	push   %ecx
  8006e9:	52                   	push   %edx
  8006ea:	89 da                	mov    %ebx,%edx
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	e8 c9 fa ff ff       	call   8001bc <printnum>
			break;
  8006f3:	83 c4 20             	add    $0x20,%esp
  8006f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f9:	e9 cd fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	52                   	push   %edx
  800703:	ff d6                	call   *%esi
			break;
  800705:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070b:	e9 bb fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 25                	push   $0x25
  800716:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 03                	jmp    800720 <vprintfmt+0x47b>
  80071d:	83 ef 01             	sub    $0x1,%edi
  800720:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800724:	75 f7                	jne    80071d <vprintfmt+0x478>
  800726:	e9 a0 fb ff ff       	jmp    8002cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072e:	5b                   	pop    %ebx
  80072f:	5e                   	pop    %esi
  800730:	5f                   	pop    %edi
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	83 ec 18             	sub    $0x18,%esp
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800742:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800746:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800749:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800750:	85 c0                	test   %eax,%eax
  800752:	74 26                	je     80077a <vsnprintf+0x47>
  800754:	85 d2                	test   %edx,%edx
  800756:	7e 22                	jle    80077a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800758:	ff 75 14             	pushl  0x14(%ebp)
  80075b:	ff 75 10             	pushl  0x10(%ebp)
  80075e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800761:	50                   	push   %eax
  800762:	68 6b 02 80 00       	push   $0x80026b
  800767:	e8 39 fb ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	eb 05                	jmp    80077f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078a:	50                   	push   %eax
  80078b:	ff 75 10             	pushl  0x10(%ebp)
  80078e:	ff 75 0c             	pushl  0xc(%ebp)
  800791:	ff 75 08             	pushl  0x8(%ebp)
  800794:	e8 9a ff ff ff       	call   800733 <vsnprintf>
	va_end(ap);

	return rc;
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb 03                	jmp    8007ab <strlen+0x10>
		n++;
  8007a8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007af:	75 f7                	jne    8007a8 <strlen+0xd>
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c1:	eb 03                	jmp    8007c6 <strnlen+0x13>
		n++;
  8007c3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c6:	39 c2                	cmp    %eax,%edx
  8007c8:	74 08                	je     8007d2 <strnlen+0x1f>
  8007ca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ce:	75 f3                	jne    8007c3 <strnlen+0x10>
  8007d0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007de:	89 c2                	mov    %eax,%edx
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	83 c1 01             	add    $0x1,%ecx
  8007e6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ed:	84 db                	test   %bl,%bl
  8007ef:	75 ef                	jne    8007e0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fb:	53                   	push   %ebx
  8007fc:	e8 9a ff ff ff       	call   80079b <strlen>
  800801:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	01 d8                	add    %ebx,%eax
  800809:	50                   	push   %eax
  80080a:	e8 c5 ff ff ff       	call   8007d4 <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	89 f3                	mov    %esi,%ebx
  800823:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	89 f2                	mov    %esi,%edx
  800828:	eb 0f                	jmp    800839 <strncpy+0x23>
		*dst++ = *src;
  80082a:	83 c2 01             	add    $0x1,%edx
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800833:	80 39 01             	cmpb   $0x1,(%ecx)
  800836:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800839:	39 da                	cmp    %ebx,%edx
  80083b:	75 ed                	jne    80082a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084e:	8b 55 10             	mov    0x10(%ebp),%edx
  800851:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800853:	85 d2                	test   %edx,%edx
  800855:	74 21                	je     800878 <strlcpy+0x35>
  800857:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085b:	89 f2                	mov    %esi,%edx
  80085d:	eb 09                	jmp    800868 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	83 c1 01             	add    $0x1,%ecx
  800865:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 09                	je     800875 <strlcpy+0x32>
  80086c:	0f b6 19             	movzbl (%ecx),%ebx
  80086f:	84 db                	test   %bl,%bl
  800871:	75 ec                	jne    80085f <strlcpy+0x1c>
  800873:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800875:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800878:	29 f0                	sub    %esi,%eax
}
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800887:	eb 06                	jmp    80088f <strcmp+0x11>
		p++, q++;
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	84 c0                	test   %al,%al
  800894:	74 04                	je     80089a <strcmp+0x1c>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	74 ef                	je     800889 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 c3                	mov    %eax,%ebx
  8008b0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b3:	eb 06                	jmp    8008bb <strncmp+0x17>
		n--, p++, q++;
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bb:	39 d8                	cmp    %ebx,%eax
  8008bd:	74 15                	je     8008d4 <strncmp+0x30>
  8008bf:	0f b6 08             	movzbl (%eax),%ecx
  8008c2:	84 c9                	test   %cl,%cl
  8008c4:	74 04                	je     8008ca <strncmp+0x26>
  8008c6:	3a 0a                	cmp    (%edx),%cl
  8008c8:	74 eb                	je     8008b5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ca:	0f b6 00             	movzbl (%eax),%eax
  8008cd:	0f b6 12             	movzbl (%edx),%edx
  8008d0:	29 d0                	sub    %edx,%eax
  8008d2:	eb 05                	jmp    8008d9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d9:	5b                   	pop    %ebx
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e6:	eb 07                	jmp    8008ef <strchr+0x13>
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	74 0f                	je     8008fb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	0f b6 10             	movzbl (%eax),%edx
  8008f2:	84 d2                	test   %dl,%dl
  8008f4:	75 f2                	jne    8008e8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	eb 03                	jmp    80090c <strfind+0xf>
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090f:	38 ca                	cmp    %cl,%dl
  800911:	74 04                	je     800917 <strfind+0x1a>
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strfind+0xc>
			break;
	return (char *) s;
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 36                	je     80095f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800929:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092f:	75 28                	jne    800959 <memset+0x40>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 23                	jne    800959 <memset+0x40>
		c &= 0xFF;
  800936:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093a:	89 d3                	mov    %edx,%ebx
  80093c:	c1 e3 08             	shl    $0x8,%ebx
  80093f:	89 d6                	mov    %edx,%esi
  800941:	c1 e6 18             	shl    $0x18,%esi
  800944:	89 d0                	mov    %edx,%eax
  800946:	c1 e0 10             	shl    $0x10,%eax
  800949:	09 f0                	or     %esi,%eax
  80094b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80094d:	89 d8                	mov    %ebx,%eax
  80094f:	09 d0                	or     %edx,%eax
  800951:	c1 e9 02             	shr    $0x2,%ecx
  800954:	fc                   	cld    
  800955:	f3 ab                	rep stos %eax,%es:(%edi)
  800957:	eb 06                	jmp    80095f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800959:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095c:	fc                   	cld    
  80095d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095f:	89 f8                	mov    %edi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5f                   	pop    %edi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	57                   	push   %edi
  80096a:	56                   	push   %esi
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800971:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800974:	39 c6                	cmp    %eax,%esi
  800976:	73 35                	jae    8009ad <memmove+0x47>
  800978:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097b:	39 d0                	cmp    %edx,%eax
  80097d:	73 2e                	jae    8009ad <memmove+0x47>
		s += n;
		d += n;
  80097f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800982:	89 d6                	mov    %edx,%esi
  800984:	09 fe                	or     %edi,%esi
  800986:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098c:	75 13                	jne    8009a1 <memmove+0x3b>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0e                	jne    8009a1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800993:	83 ef 04             	sub    $0x4,%edi
  800996:	8d 72 fc             	lea    -0x4(%edx),%esi
  800999:	c1 e9 02             	shr    $0x2,%ecx
  80099c:	fd                   	std    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 09                	jmp    8009aa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a1:	83 ef 01             	sub    $0x1,%edi
  8009a4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a7:	fd                   	std    
  8009a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009aa:	fc                   	cld    
  8009ab:	eb 1d                	jmp    8009ca <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	89 f2                	mov    %esi,%edx
  8009af:	09 c2                	or     %eax,%edx
  8009b1:	f6 c2 03             	test   $0x3,%dl
  8009b4:	75 0f                	jne    8009c5 <memmove+0x5f>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 0a                	jne    8009c5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
  8009be:	89 c7                	mov    %eax,%edi
  8009c0:	fc                   	cld    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c3:	eb 05                	jmp    8009ca <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ca:	5e                   	pop    %esi
  8009cb:	5f                   	pop    %edi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d1:	ff 75 10             	pushl  0x10(%ebp)
  8009d4:	ff 75 0c             	pushl  0xc(%ebp)
  8009d7:	ff 75 08             	pushl  0x8(%ebp)
  8009da:	e8 87 ff ff ff       	call   800966 <memmove>
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ec:	89 c6                	mov    %eax,%esi
  8009ee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	eb 1a                	jmp    800a0d <memcmp+0x2c>
		if (*s1 != *s2)
  8009f3:	0f b6 08             	movzbl (%eax),%ecx
  8009f6:	0f b6 1a             	movzbl (%edx),%ebx
  8009f9:	38 d9                	cmp    %bl,%cl
  8009fb:	74 0a                	je     800a07 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009fd:	0f b6 c1             	movzbl %cl,%eax
  800a00:	0f b6 db             	movzbl %bl,%ebx
  800a03:	29 d8                	sub    %ebx,%eax
  800a05:	eb 0f                	jmp    800a16 <memcmp+0x35>
		s1++, s2++;
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0d:	39 f0                	cmp    %esi,%eax
  800a0f:	75 e2                	jne    8009f3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a21:	89 c1                	mov    %eax,%ecx
  800a23:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a26:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2a:	eb 0a                	jmp    800a36 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2c:	0f b6 10             	movzbl (%eax),%edx
  800a2f:	39 da                	cmp    %ebx,%edx
  800a31:	74 07                	je     800a3a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	39 c8                	cmp    %ecx,%eax
  800a38:	72 f2                	jb     800a2c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a49:	eb 03                	jmp    800a4e <strtol+0x11>
		s++;
  800a4b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4e:	0f b6 01             	movzbl (%ecx),%eax
  800a51:	3c 20                	cmp    $0x20,%al
  800a53:	74 f6                	je     800a4b <strtol+0xe>
  800a55:	3c 09                	cmp    $0x9,%al
  800a57:	74 f2                	je     800a4b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a59:	3c 2b                	cmp    $0x2b,%al
  800a5b:	75 0a                	jne    800a67 <strtol+0x2a>
		s++;
  800a5d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
  800a65:	eb 11                	jmp    800a78 <strtol+0x3b>
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6c:	3c 2d                	cmp    $0x2d,%al
  800a6e:	75 08                	jne    800a78 <strtol+0x3b>
		s++, neg = 1;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7e:	75 15                	jne    800a95 <strtol+0x58>
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 10                	jne    800a95 <strtol+0x58>
  800a85:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a89:	75 7c                	jne    800b07 <strtol+0xca>
		s += 2, base = 16;
  800a8b:	83 c1 02             	add    $0x2,%ecx
  800a8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a93:	eb 16                	jmp    800aab <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	75 12                	jne    800aab <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a99:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 08                	jne    800aab <strtol+0x6e>
		s++, base = 8;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab3:	0f b6 11             	movzbl (%ecx),%edx
  800ab6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab9:	89 f3                	mov    %esi,%ebx
  800abb:	80 fb 09             	cmp    $0x9,%bl
  800abe:	77 08                	ja     800ac8 <strtol+0x8b>
			dig = *s - '0';
  800ac0:	0f be d2             	movsbl %dl,%edx
  800ac3:	83 ea 30             	sub    $0x30,%edx
  800ac6:	eb 22                	jmp    800aea <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acb:	89 f3                	mov    %esi,%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad2:	0f be d2             	movsbl %dl,%edx
  800ad5:	83 ea 57             	sub    $0x57,%edx
  800ad8:	eb 10                	jmp    800aea <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 72 bf             	lea    -0x41(%edx),%esi
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	80 fb 19             	cmp    $0x19,%bl
  800ae2:	77 16                	ja     800afa <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae4:	0f be d2             	movsbl %dl,%edx
  800ae7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aea:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aed:	7d 0b                	jge    800afa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aef:	83 c1 01             	add    $0x1,%ecx
  800af2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af8:	eb b9                	jmp    800ab3 <strtol+0x76>

	if (endptr)
  800afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afe:	74 0d                	je     800b0d <strtol+0xd0>
		*endptr = (char *) s;
  800b00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b03:	89 0e                	mov    %ecx,(%esi)
  800b05:	eb 06                	jmp    800b0d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b07:	85 db                	test   %ebx,%ebx
  800b09:	74 98                	je     800aa3 <strtol+0x66>
  800b0b:	eb 9e                	jmp    800aab <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b0d:	89 c2                	mov    %eax,%edx
  800b0f:	f7 da                	neg    %edx
  800b11:	85 ff                	test   %edi,%edi
  800b13:	0f 45 c2             	cmovne %edx,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	89 c6                	mov    %eax,%esi
  800b32:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 01 00 00 00       	mov    $0x1,%eax
  800b49:	89 d1                	mov    %edx,%ecx
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	89 d7                	mov    %edx,%edi
  800b4f:	89 d6                	mov    %edx,%esi
  800b51:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b66:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	89 cb                	mov    %ecx,%ebx
  800b70:	89 cf                	mov    %ecx,%edi
  800b72:	89 ce                	mov    %ecx,%esi
  800b74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b76:	85 c0                	test   %eax,%eax
  800b78:	7e 17                	jle    800b91 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	50                   	push   %eax
  800b7e:	6a 03                	push   $0x3
  800b80:	68 bf 25 80 00       	push   $0x8025bf
  800b85:	6a 23                	push   $0x23
  800b87:	68 dc 25 80 00       	push   $0x8025dc
  800b8c:	e8 ff 11 00 00       	call   801d90 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba9:	89 d1                	mov    %edx,%ecx
  800bab:	89 d3                	mov    %edx,%ebx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_yield>:

void
sys_yield(void)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be0:	be 00 00 00 00       	mov    $0x0,%esi
  800be5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf3:	89 f7                	mov    %esi,%edi
  800bf5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 17                	jle    800c12 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 04                	push   $0x4
  800c01:	68 bf 25 80 00       	push   $0x8025bf
  800c06:	6a 23                	push   $0x23
  800c08:	68 dc 25 80 00       	push   $0x8025dc
  800c0d:	e8 7e 11 00 00       	call   801d90 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	b8 05 00 00 00       	mov    $0x5,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c34:	8b 75 18             	mov    0x18(%ebp),%esi
  800c37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 05                	push   $0x5
  800c43:	68 bf 25 80 00       	push   $0x8025bf
  800c48:	6a 23                	push   $0x23
  800c4a:	68 dc 25 80 00       	push   $0x8025dc
  800c4f:	e8 3c 11 00 00       	call   801d90 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	89 df                	mov    %ebx,%edi
  800c77:	89 de                	mov    %ebx,%esi
  800c79:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7e 17                	jle    800c96 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 06                	push   $0x6
  800c85:	68 bf 25 80 00       	push   $0x8025bf
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 dc 25 80 00       	push   $0x8025dc
  800c91:	e8 fa 10 00 00       	call   801d90 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cac:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 df                	mov    %ebx,%edi
  800cb9:	89 de                	mov    %ebx,%esi
  800cbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 08                	push   $0x8
  800cc7:	68 bf 25 80 00       	push   $0x8025bf
  800ccc:	6a 23                	push   $0x23
  800cce:	68 dc 25 80 00       	push   $0x8025dc
  800cd3:	e8 b8 10 00 00       	call   801d90 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 09                	push   $0x9
  800d09:	68 bf 25 80 00       	push   $0x8025bf
  800d0e:	6a 23                	push   $0x23
  800d10:	68 dc 25 80 00       	push   $0x8025dc
  800d15:	e8 76 10 00 00       	call   801d90 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 0a                	push   $0xa
  800d4b:	68 bf 25 80 00       	push   $0x8025bf
  800d50:	6a 23                	push   $0x23
  800d52:	68 dc 25 80 00       	push   $0x8025dc
  800d57:	e8 34 10 00 00       	call   801d90 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	be 00 00 00 00       	mov    $0x0,%esi
  800d6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d80:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 0d                	push   $0xd
  800daf:	68 bf 25 80 00       	push   $0x8025bf
  800db4:	6a 23                	push   $0x23
  800db6:	68 dc 25 80 00       	push   $0x8025dc
  800dbb:	e8 d0 0f 00 00       	call   801d90 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800dd4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd8:	0f 84 48 01 00 00    	je     800f26 <pgfault+0x15e>
  800dde:	89 d8                	mov    %ebx,%eax
  800de0:	c1 e8 16             	shr    $0x16,%eax
  800de3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dea:	a8 01                	test   $0x1,%al
  800dec:	0f 84 5f 01 00 00    	je     800f51 <pgfault+0x189>
  800df2:	89 d8                	mov    %ebx,%eax
  800df4:	c1 e8 0c             	shr    $0xc,%eax
  800df7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800dfe:	f6 c2 01             	test   $0x1,%dl
  800e01:	0f 84 4a 01 00 00    	je     800f51 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e07:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800e0e:	f6 c4 08             	test   $0x8,%ah
  800e11:	75 79                	jne    800e8c <pgfault+0xc4>
  800e13:	e9 39 01 00 00       	jmp    800f51 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	c1 e8 16             	shr    $0x16,%eax
  800e1d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e24:	a8 01                	test   $0x1,%al
  800e26:	75 10                	jne    800e38 <pgfault+0x70>
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	68 ea 25 80 00       	push   $0x8025ea
  800e30:	e8 73 f3 ff ff       	call   8001a8 <cprintf>
  800e35:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800e38:	c1 eb 0c             	shr    $0xc,%ebx
  800e3b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800e41:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e48:	a8 01                	test   $0x1,%al
  800e4a:	75 10                	jne    800e5c <pgfault+0x94>
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	68 fb 25 80 00       	push   $0x8025fb
  800e54:	e8 4f f3 ff ff       	call   8001a8 <cprintf>
  800e59:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800e5c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e63:	f6 c4 08             	test   $0x8,%ah
  800e66:	75 10                	jne    800e78 <pgfault+0xb0>
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	68 0c 26 80 00       	push   $0x80260c
  800e70:	e8 33 f3 ff ff       	call   8001a8 <cprintf>
  800e75:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	68 1f 26 80 00       	push   $0x80261f
  800e80:	6a 23                	push   $0x23
  800e82:	68 2f 26 80 00       	push   $0x80262f
  800e87:	e8 04 0f 00 00       	call   801d90 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	6a 07                	push   $0x7
  800e91:	68 00 f0 7f 00       	push   $0x7ff000
  800e96:	6a 00                	push   $0x0
  800e98:	e8 3a fd ff ff       	call   800bd7 <sys_page_alloc>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	79 12                	jns    800eb6 <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800ea4:	50                   	push   %eax
  800ea5:	68 3a 26 80 00       	push   $0x80263a
  800eaa:	6a 2f                	push   $0x2f
  800eac:	68 2f 26 80 00       	push   $0x80262f
  800eb1:	e8 da 0e 00 00       	call   801d90 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800eb6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	68 00 10 00 00       	push   $0x1000
  800ec4:	53                   	push   %ebx
  800ec5:	68 00 f0 7f 00       	push   $0x7ff000
  800eca:	e8 ff fa ff ff       	call   8009ce <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  800ecf:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed6:	53                   	push   %ebx
  800ed7:	6a 00                	push   $0x0
  800ed9:	68 00 f0 7f 00       	push   $0x7ff000
  800ede:	6a 00                	push   $0x0
  800ee0:	e8 35 fd ff ff       	call   800c1a <sys_page_map>
  800ee5:	83 c4 20             	add    $0x20,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	79 12                	jns    800efe <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  800eec:	50                   	push   %eax
  800eed:	68 54 26 80 00       	push   $0x802654
  800ef2:	6a 33                	push   $0x33
  800ef4:	68 2f 26 80 00       	push   $0x80262f
  800ef9:	e8 92 0e 00 00       	call   801d90 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	68 00 f0 7f 00       	push   $0x7ff000
  800f06:	6a 00                	push   $0x0
  800f08:	e8 4f fd ff ff       	call   800c5c <sys_page_unmap>
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 5c                	jns    800f70 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  800f14:	50                   	push   %eax
  800f15:	68 6c 26 80 00       	push   $0x80266c
  800f1a:	6a 35                	push   $0x35
  800f1c:	68 2f 26 80 00       	push   $0x80262f
  800f21:	e8 6a 0e 00 00       	call   801d90 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f26:	a1 04 40 80 00       	mov    0x804004,%eax
  800f2b:	8b 40 48             	mov    0x48(%eax),%eax
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	50                   	push   %eax
  800f32:	53                   	push   %ebx
  800f33:	68 a8 26 80 00       	push   $0x8026a8
  800f38:	e8 6b f2 ff ff       	call   8001a8 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  800f3d:	c7 04 24 86 26 80 00 	movl   $0x802686,(%esp)
  800f44:	e8 5f f2 ff ff       	call   8001a8 <cprintf>
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	e9 c7 fe ff ff       	jmp    800e18 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  800f51:	a1 04 40 80 00       	mov    0x804004,%eax
  800f56:	8b 40 48             	mov    0x48(%eax),%eax
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	50                   	push   %eax
  800f5d:	53                   	push   %ebx
  800f5e:	68 a8 26 80 00       	push   $0x8026a8
  800f63:	e8 40 f2 ff ff       	call   8001a8 <cprintf>
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	e9 a8 fe ff ff       	jmp    800e18 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  800f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  800f7e:	68 c8 0d 80 00       	push   $0x800dc8
  800f83:	e8 4e 0e 00 00       	call   801dd6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f88:	b8 07 00 00 00       	mov    $0x7,%eax
  800f8d:	cd 30                	int    $0x30
  800f8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f92:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	0f 88 0d 01 00 00    	js     8010ad <fork+0x138>
  800fa0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa5:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  800faa:	85 c0                	test   %eax,%eax
  800fac:	75 2f                	jne    800fdd <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  800fae:	e8 e6 fb ff ff       	call   800b99 <sys_getenvid>
  800fb3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fbb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc0:	a3 04 40 80 00       	mov    %eax,0x804004
		// set_pgfault_handler(pgfault);
		return 0;
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	e9 e1 00 00 00       	jmp    8010b0 <fork+0x13b>
  800fcf:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  800fd5:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fdb:	74 77                	je     801054 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  800fdd:	89 f0                	mov    %esi,%eax
  800fdf:	c1 e8 0a             	shr    $0xa,%eax
  800fe2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  800fe9:	a8 01                	test   $0x1,%al
  800feb:	74 0b                	je     800ff8 <fork+0x83>
	pte_t pte = uvpt[pn];
  800fed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  800ff4:	a8 01                	test   $0x1,%al
  800ff6:	75 08                	jne    801000 <fork+0x8b>
  800ff8:	8d 5e 01             	lea    0x1(%esi),%ebx
  800ffb:	c1 e3 0c             	shl    $0xc,%ebx
  800ffe:	eb 56                	jmp    801056 <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801000:	25 02 08 00 00       	and    $0x802,%eax
  801005:	83 f8 01             	cmp    $0x1,%eax
  801008:	19 ff                	sbb    %edi,%edi
  80100a:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801010:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  801016:	a1 04 40 80 00       	mov    0x804004,%eax
  80101b:	8b 40 48             	mov    0x48(%eax),%eax
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	57                   	push   %edi
  801022:	53                   	push   %ebx
  801023:	ff 75 e4             	pushl  -0x1c(%ebp)
  801026:	53                   	push   %ebx
  801027:	50                   	push   %eax
  801028:	e8 ed fb ff ff       	call   800c1a <sys_page_map>
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 7c                	js     8010b0 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  801034:	a1 04 40 80 00       	mov    0x804004,%eax
  801039:	8b 40 48             	mov    0x48(%eax),%eax
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	57                   	push   %edi
  801040:	53                   	push   %ebx
  801041:	50                   	push   %eax
  801042:	53                   	push   %ebx
  801043:	ff 75 e4             	pushl  -0x1c(%ebp)
  801046:	e8 cf fb ff ff       	call   800c1a <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  80104b:	83 c4 20             	add    $0x20,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	79 a6                	jns    800ff8 <fork+0x83>
  801052:	eb 5c                	jmp    8010b0 <fork+0x13b>
  801054:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  801056:	83 c6 01             	add    $0x1,%esi
  801059:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80105f:	0f 86 6a ff ff ff    	jbe    800fcf <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  801065:	83 ec 04             	sub    $0x4,%esp
  801068:	6a 07                	push   $0x7
  80106a:	68 00 f0 bf ee       	push   $0xeebff000
  80106f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801072:	57                   	push   %edi
  801073:	e8 5f fb ff ff       	call   800bd7 <sys_page_alloc>
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	78 31                	js     8010b0 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  80107f:	a1 04 40 80 00       	mov    0x804004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  801084:	8b 40 64             	mov    0x64(%eax),%eax
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	50                   	push   %eax
  80108b:	57                   	push   %edi
  80108c:	e8 91 fc ff ff       	call   800d22 <sys_env_set_pgfault_upcall>
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	78 18                	js     8010b0 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801098:	83 ec 08             	sub    $0x8,%esp
  80109b:	6a 02                	push   $0x2
  80109d:	57                   	push   %edi
  80109e:	e8 fb fb ff ff       	call   800c9e <sys_env_set_status>
  8010a3:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 49 c7             	cmovns %edi,%eax
  8010ab:	eb 03                	jmp    8010b0 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8010ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8010b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010be:	68 91 26 80 00       	push   $0x802691
  8010c3:	68 9f 00 00 00       	push   $0x9f
  8010c8:	68 2f 26 80 00       	push   $0x80262f
  8010cd:	e8 be 0c 00 00       	call   801d90 <_panic>

008010d2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010dd:	c1 e8 0c             	shr    $0xc,%eax
}
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801104:	89 c2                	mov    %eax,%edx
  801106:	c1 ea 16             	shr    $0x16,%edx
  801109:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801110:	f6 c2 01             	test   $0x1,%dl
  801113:	74 11                	je     801126 <fd_alloc+0x2d>
  801115:	89 c2                	mov    %eax,%edx
  801117:	c1 ea 0c             	shr    $0xc,%edx
  80111a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801121:	f6 c2 01             	test   $0x1,%dl
  801124:	75 09                	jne    80112f <fd_alloc+0x36>
			*fd_store = fd;
  801126:	89 01                	mov    %eax,(%ecx)
			return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	eb 17                	jmp    801146 <fd_alloc+0x4d>
  80112f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801134:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801139:	75 c9                	jne    801104 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80113b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801141:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114e:	83 f8 1f             	cmp    $0x1f,%eax
  801151:	77 36                	ja     801189 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801153:	c1 e0 0c             	shl    $0xc,%eax
  801156:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	c1 ea 16             	shr    $0x16,%edx
  801160:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801167:	f6 c2 01             	test   $0x1,%dl
  80116a:	74 24                	je     801190 <fd_lookup+0x48>
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	c1 ea 0c             	shr    $0xc,%edx
  801171:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801178:	f6 c2 01             	test   $0x1,%dl
  80117b:	74 1a                	je     801197 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801180:	89 02                	mov    %eax,(%edx)
	return 0;
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
  801187:	eb 13                	jmp    80119c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801189:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118e:	eb 0c                	jmp    80119c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801195:	eb 05                	jmp    80119c <fd_lookup+0x54>
  801197:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a7:	ba 48 27 80 00       	mov    $0x802748,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ac:	eb 13                	jmp    8011c1 <dev_lookup+0x23>
  8011ae:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011b1:	39 08                	cmp    %ecx,(%eax)
  8011b3:	75 0c                	jne    8011c1 <dev_lookup+0x23>
			*dev = devtab[i];
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bf:	eb 2e                	jmp    8011ef <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c1:	8b 02                	mov    (%edx),%eax
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	75 e7                	jne    8011ae <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cc:	8b 40 48             	mov    0x48(%eax),%eax
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	51                   	push   %ecx
  8011d3:	50                   	push   %eax
  8011d4:	68 cc 26 80 00       	push   $0x8026cc
  8011d9:	e8 ca ef ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  8011de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ef:	c9                   	leave  
  8011f0:	c3                   	ret    

008011f1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	56                   	push   %esi
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 10             	sub    $0x10,%esp
  8011f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801209:	c1 e8 0c             	shr    $0xc,%eax
  80120c:	50                   	push   %eax
  80120d:	e8 36 ff ff ff       	call   801148 <fd_lookup>
  801212:	83 c4 08             	add    $0x8,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 05                	js     80121e <fd_close+0x2d>
	    || fd != fd2)
  801219:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80121c:	74 0c                	je     80122a <fd_close+0x39>
		return (must_exist ? r : 0);
  80121e:	84 db                	test   %bl,%bl
  801220:	ba 00 00 00 00       	mov    $0x0,%edx
  801225:	0f 44 c2             	cmove  %edx,%eax
  801228:	eb 41                	jmp    80126b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	ff 36                	pushl  (%esi)
  801233:	e8 66 ff ff ff       	call   80119e <dev_lookup>
  801238:	89 c3                	mov    %eax,%ebx
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 1a                	js     80125b <fd_close+0x6a>
		if (dev->dev_close)
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801247:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80124c:	85 c0                	test   %eax,%eax
  80124e:	74 0b                	je     80125b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801250:	83 ec 0c             	sub    $0xc,%esp
  801253:	56                   	push   %esi
  801254:	ff d0                	call   *%eax
  801256:	89 c3                	mov    %eax,%ebx
  801258:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80125b:	83 ec 08             	sub    $0x8,%esp
  80125e:	56                   	push   %esi
  80125f:	6a 00                	push   $0x0
  801261:	e8 f6 f9 ff ff       	call   800c5c <sys_page_unmap>
	return r;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	89 d8                	mov    %ebx,%eax
}
  80126b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 c4 fe ff ff       	call   801148 <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 10                	js     80129b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	6a 01                	push   $0x1
  801290:	ff 75 f4             	pushl  -0xc(%ebp)
  801293:	e8 59 ff ff ff       	call   8011f1 <fd_close>
  801298:	83 c4 10             	add    $0x10,%esp
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <close_all>:

void
close_all(void)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	e8 c0 ff ff ff       	call   801272 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b2:	83 c3 01             	add    $0x1,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	83 fb 20             	cmp    $0x20,%ebx
  8012bb:	75 ec                	jne    8012a9 <close_all+0xc>
		close(i);
}
  8012bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	57                   	push   %edi
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 2c             	sub    $0x2c,%esp
  8012cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	ff 75 08             	pushl  0x8(%ebp)
  8012d5:	e8 6e fe ff ff       	call   801148 <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	0f 88 c1 00 00 00    	js     8013a6 <dup+0xe4>
		return r;
	close(newfdnum);
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	56                   	push   %esi
  8012e9:	e8 84 ff ff ff       	call   801272 <close>

	newfd = INDEX2FD(newfdnum);
  8012ee:	89 f3                	mov    %esi,%ebx
  8012f0:	c1 e3 0c             	shl    $0xc,%ebx
  8012f3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012f9:	83 c4 04             	add    $0x4,%esp
  8012fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ff:	e8 de fd ff ff       	call   8010e2 <fd2data>
  801304:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801306:	89 1c 24             	mov    %ebx,(%esp)
  801309:	e8 d4 fd ff ff       	call   8010e2 <fd2data>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801314:	89 f8                	mov    %edi,%eax
  801316:	c1 e8 16             	shr    $0x16,%eax
  801319:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801320:	a8 01                	test   $0x1,%al
  801322:	74 37                	je     80135b <dup+0x99>
  801324:	89 f8                	mov    %edi,%eax
  801326:	c1 e8 0c             	shr    $0xc,%eax
  801329:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801330:	f6 c2 01             	test   $0x1,%dl
  801333:	74 26                	je     80135b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801335:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	25 07 0e 00 00       	and    $0xe07,%eax
  801344:	50                   	push   %eax
  801345:	ff 75 d4             	pushl  -0x2c(%ebp)
  801348:	6a 00                	push   $0x0
  80134a:	57                   	push   %edi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 c8 f8 ff ff       	call   800c1a <sys_page_map>
  801352:	89 c7                	mov    %eax,%edi
  801354:	83 c4 20             	add    $0x20,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 2e                	js     801389 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80135b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135e:	89 d0                	mov    %edx,%eax
  801360:	c1 e8 0c             	shr    $0xc,%eax
  801363:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	25 07 0e 00 00       	and    $0xe07,%eax
  801372:	50                   	push   %eax
  801373:	53                   	push   %ebx
  801374:	6a 00                	push   $0x0
  801376:	52                   	push   %edx
  801377:	6a 00                	push   $0x0
  801379:	e8 9c f8 ff ff       	call   800c1a <sys_page_map>
  80137e:	89 c7                	mov    %eax,%edi
  801380:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801383:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801385:	85 ff                	test   %edi,%edi
  801387:	79 1d                	jns    8013a6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	53                   	push   %ebx
  80138d:	6a 00                	push   $0x0
  80138f:	e8 c8 f8 ff ff       	call   800c5c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139a:	6a 00                	push   $0x0
  80139c:	e8 bb f8 ff ff       	call   800c5c <sys_page_unmap>
	return r;
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	89 f8                	mov    %edi,%eax
}
  8013a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a9:	5b                   	pop    %ebx
  8013aa:	5e                   	pop    %esi
  8013ab:	5f                   	pop    %edi
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 14             	sub    $0x14,%esp
  8013b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	53                   	push   %ebx
  8013bd:	e8 86 fd ff ff       	call   801148 <fd_lookup>
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 6d                	js     801438 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d5:	ff 30                	pushl  (%eax)
  8013d7:	e8 c2 fd ff ff       	call   80119e <dev_lookup>
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 4c                	js     80142f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e6:	8b 42 08             	mov    0x8(%edx),%eax
  8013e9:	83 e0 03             	and    $0x3,%eax
  8013ec:	83 f8 01             	cmp    $0x1,%eax
  8013ef:	75 21                	jne    801412 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f6:	8b 40 48             	mov    0x48(%eax),%eax
  8013f9:	83 ec 04             	sub    $0x4,%esp
  8013fc:	53                   	push   %ebx
  8013fd:	50                   	push   %eax
  8013fe:	68 0d 27 80 00       	push   $0x80270d
  801403:	e8 a0 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801410:	eb 26                	jmp    801438 <read+0x8a>
	}
	if (!dev->dev_read)
  801412:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801415:	8b 40 08             	mov    0x8(%eax),%eax
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 17                	je     801433 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80141c:	83 ec 04             	sub    $0x4,%esp
  80141f:	ff 75 10             	pushl  0x10(%ebp)
  801422:	ff 75 0c             	pushl  0xc(%ebp)
  801425:	52                   	push   %edx
  801426:	ff d0                	call   *%eax
  801428:	89 c2                	mov    %eax,%edx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	eb 09                	jmp    801438 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	89 c2                	mov    %eax,%edx
  801431:	eb 05                	jmp    801438 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801433:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801438:	89 d0                	mov    %edx,%eax
  80143a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	57                   	push   %edi
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801453:	eb 21                	jmp    801476 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	89 f0                	mov    %esi,%eax
  80145a:	29 d8                	sub    %ebx,%eax
  80145c:	50                   	push   %eax
  80145d:	89 d8                	mov    %ebx,%eax
  80145f:	03 45 0c             	add    0xc(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	57                   	push   %edi
  801464:	e8 45 ff ff ff       	call   8013ae <read>
		if (m < 0)
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 10                	js     801480 <readn+0x41>
			return m;
		if (m == 0)
  801470:	85 c0                	test   %eax,%eax
  801472:	74 0a                	je     80147e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801474:	01 c3                	add    %eax,%ebx
  801476:	39 f3                	cmp    %esi,%ebx
  801478:	72 db                	jb     801455 <readn+0x16>
  80147a:	89 d8                	mov    %ebx,%eax
  80147c:	eb 02                	jmp    801480 <readn+0x41>
  80147e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801480:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 14             	sub    $0x14,%esp
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	53                   	push   %ebx
  801497:	e8 ac fc ff ff       	call   801148 <fd_lookup>
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 68                	js     80150d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	ff 30                	pushl  (%eax)
  8014b1:	e8 e8 fc ff ff       	call   80119e <dev_lookup>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 47                	js     801504 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c4:	75 21                	jne    8014e7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014cb:	8b 40 48             	mov    0x48(%eax),%eax
  8014ce:	83 ec 04             	sub    $0x4,%esp
  8014d1:	53                   	push   %ebx
  8014d2:	50                   	push   %eax
  8014d3:	68 29 27 80 00       	push   $0x802729
  8014d8:	e8 cb ec ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e5:	eb 26                	jmp    80150d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ed:	85 d2                	test   %edx,%edx
  8014ef:	74 17                	je     801508 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014f1:	83 ec 04             	sub    $0x4,%esp
  8014f4:	ff 75 10             	pushl  0x10(%ebp)
  8014f7:	ff 75 0c             	pushl  0xc(%ebp)
  8014fa:	50                   	push   %eax
  8014fb:	ff d2                	call   *%edx
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	eb 09                	jmp    80150d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801504:	89 c2                	mov    %eax,%edx
  801506:	eb 05                	jmp    80150d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801508:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80150d:	89 d0                	mov    %edx,%eax
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <seek>:

int
seek(int fdnum, off_t offset)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	ff 75 08             	pushl  0x8(%ebp)
  801521:	e8 22 fc ff ff       	call   801148 <fd_lookup>
  801526:	83 c4 08             	add    $0x8,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 0e                	js     80153b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80152d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801530:	8b 55 0c             	mov    0xc(%ebp),%edx
  801533:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801536:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 14             	sub    $0x14,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801547:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	53                   	push   %ebx
  80154c:	e8 f7 fb ff ff       	call   801148 <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	89 c2                	mov    %eax,%edx
  801556:	85 c0                	test   %eax,%eax
  801558:	78 65                	js     8015bf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	ff 30                	pushl  (%eax)
  801566:	e8 33 fc ff ff       	call   80119e <dev_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 44                	js     8015b6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801572:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801575:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801579:	75 21                	jne    80159c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80157b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801580:	8b 40 48             	mov    0x48(%eax),%eax
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	53                   	push   %ebx
  801587:	50                   	push   %eax
  801588:	68 ec 26 80 00       	push   $0x8026ec
  80158d:	e8 16 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159a:	eb 23                	jmp    8015bf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159f:	8b 52 18             	mov    0x18(%edx),%edx
  8015a2:	85 d2                	test   %edx,%edx
  8015a4:	74 14                	je     8015ba <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	50                   	push   %eax
  8015ad:	ff d2                	call   *%edx
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	eb 09                	jmp    8015bf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	eb 05                	jmp    8015bf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015bf:	89 d0                	mov    %edx,%eax
  8015c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 14             	sub    $0x14,%esp
  8015cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	ff 75 08             	pushl  0x8(%ebp)
  8015d7:	e8 6c fb ff ff       	call   801148 <fd_lookup>
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 58                	js     80163d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ef:	ff 30                	pushl  (%eax)
  8015f1:	e8 a8 fb ff ff       	call   80119e <dev_lookup>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 37                	js     801634 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801604:	74 32                	je     801638 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801606:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801609:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801610:	00 00 00 
	stat->st_isdir = 0;
  801613:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80161a:	00 00 00 
	stat->st_dev = dev;
  80161d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	53                   	push   %ebx
  801627:	ff 75 f0             	pushl  -0x10(%ebp)
  80162a:	ff 50 14             	call   *0x14(%eax)
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 09                	jmp    80163d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	89 c2                	mov    %eax,%edx
  801636:	eb 05                	jmp    80163d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801638:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163d:	89 d0                	mov    %edx,%eax
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	6a 00                	push   $0x0
  80164e:	ff 75 08             	pushl  0x8(%ebp)
  801651:	e8 b7 01 00 00       	call   80180d <open>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1b                	js     80167a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	ff 75 0c             	pushl  0xc(%ebp)
  801665:	50                   	push   %eax
  801666:	e8 5b ff ff ff       	call   8015c6 <fstat>
  80166b:	89 c6                	mov    %eax,%esi
	close(fd);
  80166d:	89 1c 24             	mov    %ebx,(%esp)
  801670:	e8 fd fb ff ff       	call   801272 <close>
	return r;
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	89 f0                	mov    %esi,%eax
}
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	89 c6                	mov    %eax,%esi
  801688:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80168a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801691:	75 12                	jne    8016a5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	6a 01                	push   $0x1
  801698:	e8 72 08 00 00       	call   801f0f <ipc_find_env>
  80169d:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a5:	6a 07                	push   $0x7
  8016a7:	68 00 50 80 00       	push   $0x805000
  8016ac:	56                   	push   %esi
  8016ad:	ff 35 00 40 80 00    	pushl  0x804000
  8016b3:	e8 03 08 00 00       	call   801ebb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016b8:	83 c4 0c             	add    $0xc,%esp
  8016bb:	6a 00                	push   $0x0
  8016bd:	53                   	push   %ebx
  8016be:	6a 00                	push   $0x0
  8016c0:	e8 81 07 00 00       	call   801e46 <ipc_recv>
}
  8016c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c8:	5b                   	pop    %ebx
  8016c9:	5e                   	pop    %esi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ef:	e8 8d ff ff ff       	call   801681 <fsipc>
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801702:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801707:	ba 00 00 00 00       	mov    $0x0,%edx
  80170c:	b8 06 00 00 00       	mov    $0x6,%eax
  801711:	e8 6b ff ff ff       	call   801681 <fsipc>
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 40 0c             	mov    0xc(%eax),%eax
  801728:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	b8 05 00 00 00       	mov    $0x5,%eax
  801737:	e8 45 ff ff ff       	call   801681 <fsipc>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 2c                	js     80176c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	68 00 50 80 00       	push   $0x805000
  801748:	53                   	push   %ebx
  801749:	e8 86 f0 ff ff       	call   8007d4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174e:	a1 80 50 80 00       	mov    0x805080,%eax
  801753:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801759:	a1 84 50 80 00       	mov    0x805084,%eax
  80175e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801777:	68 58 27 80 00       	push   $0x802758
  80177c:	68 90 00 00 00       	push   $0x90
  801781:	68 76 27 80 00       	push   $0x802776
  801786:	e8 05 06 00 00       	call   801d90 <_panic>

0080178b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	8b 40 0c             	mov    0xc(%eax),%eax
  801799:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ae:	e8 ce fe ff ff       	call   801681 <fsipc>
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 4b                	js     801804 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b9:	39 c6                	cmp    %eax,%esi
  8017bb:	73 16                	jae    8017d3 <devfile_read+0x48>
  8017bd:	68 81 27 80 00       	push   $0x802781
  8017c2:	68 88 27 80 00       	push   $0x802788
  8017c7:	6a 7c                	push   $0x7c
  8017c9:	68 76 27 80 00       	push   $0x802776
  8017ce:	e8 bd 05 00 00       	call   801d90 <_panic>
	assert(r <= PGSIZE);
  8017d3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d8:	7e 16                	jle    8017f0 <devfile_read+0x65>
  8017da:	68 9d 27 80 00       	push   $0x80279d
  8017df:	68 88 27 80 00       	push   $0x802788
  8017e4:	6a 7d                	push   $0x7d
  8017e6:	68 76 27 80 00       	push   $0x802776
  8017eb:	e8 a0 05 00 00       	call   801d90 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	50                   	push   %eax
  8017f4:	68 00 50 80 00       	push   $0x805000
  8017f9:	ff 75 0c             	pushl  0xc(%ebp)
  8017fc:	e8 65 f1 ff ff       	call   800966 <memmove>
	return r;
  801801:	83 c4 10             	add    $0x10,%esp
}
  801804:	89 d8                	mov    %ebx,%eax
  801806:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	53                   	push   %ebx
  801811:	83 ec 20             	sub    $0x20,%esp
  801814:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801817:	53                   	push   %ebx
  801818:	e8 7e ef ff ff       	call   80079b <strlen>
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801825:	7f 67                	jg     80188e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	e8 c6 f8 ff ff       	call   8010f9 <fd_alloc>
  801833:	83 c4 10             	add    $0x10,%esp
		return r;
  801836:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 57                	js     801893 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	53                   	push   %ebx
  801840:	68 00 50 80 00       	push   $0x805000
  801845:	e8 8a ef ff ff       	call   8007d4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80184a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801852:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801855:	b8 01 00 00 00       	mov    $0x1,%eax
  80185a:	e8 22 fe ff ff       	call   801681 <fsipc>
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	79 14                	jns    80187c <open+0x6f>
		fd_close(fd, 0);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	6a 00                	push   $0x0
  80186d:	ff 75 f4             	pushl  -0xc(%ebp)
  801870:	e8 7c f9 ff ff       	call   8011f1 <fd_close>
		return r;
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	89 da                	mov    %ebx,%edx
  80187a:	eb 17                	jmp    801893 <open+0x86>
	}

	return fd2num(fd);
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	ff 75 f4             	pushl  -0xc(%ebp)
  801882:	e8 4b f8 ff ff       	call   8010d2 <fd2num>
  801887:	89 c2                	mov    %eax,%edx
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	eb 05                	jmp    801893 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801893:	89 d0                	mov    %edx,%eax
  801895:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8018aa:	e8 d2 fd ff ff       	call   801681 <fsipc>
}
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	56                   	push   %esi
  8018b5:	53                   	push   %ebx
  8018b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	ff 75 08             	pushl  0x8(%ebp)
  8018bf:	e8 1e f8 ff ff       	call   8010e2 <fd2data>
  8018c4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c6:	83 c4 08             	add    $0x8,%esp
  8018c9:	68 a9 27 80 00       	push   $0x8027a9
  8018ce:	53                   	push   %ebx
  8018cf:	e8 00 ef ff ff       	call   8007d4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d4:	8b 46 04             	mov    0x4(%esi),%eax
  8018d7:	2b 06                	sub    (%esi),%eax
  8018d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018df:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e6:	00 00 00 
	stat->st_dev = &devpipe;
  8018e9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018f0:	30 80 00 
	return 0;
}
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5e                   	pop    %esi
  8018fd:	5d                   	pop    %ebp
  8018fe:	c3                   	ret    

008018ff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	53                   	push   %ebx
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801909:	53                   	push   %ebx
  80190a:	6a 00                	push   $0x0
  80190c:	e8 4b f3 ff ff       	call   800c5c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801911:	89 1c 24             	mov    %ebx,(%esp)
  801914:	e8 c9 f7 ff ff       	call   8010e2 <fd2data>
  801919:	83 c4 08             	add    $0x8,%esp
  80191c:	50                   	push   %eax
  80191d:	6a 00                	push   $0x0
  80191f:	e8 38 f3 ff ff       	call   800c5c <sys_page_unmap>
}
  801924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	57                   	push   %edi
  80192d:	56                   	push   %esi
  80192e:	53                   	push   %ebx
  80192f:	83 ec 1c             	sub    $0x1c,%esp
  801932:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801935:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801937:	a1 04 40 80 00       	mov    0x804004,%eax
  80193c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	ff 75 e0             	pushl  -0x20(%ebp)
  801945:	e8 fe 05 00 00       	call   801f48 <pageref>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	89 3c 24             	mov    %edi,(%esp)
  80194f:	e8 f4 05 00 00       	call   801f48 <pageref>
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	39 c3                	cmp    %eax,%ebx
  801959:	0f 94 c1             	sete   %cl
  80195c:	0f b6 c9             	movzbl %cl,%ecx
  80195f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801962:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801968:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80196b:	39 ce                	cmp    %ecx,%esi
  80196d:	74 1b                	je     80198a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80196f:	39 c3                	cmp    %eax,%ebx
  801971:	75 c4                	jne    801937 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801973:	8b 42 58             	mov    0x58(%edx),%eax
  801976:	ff 75 e4             	pushl  -0x1c(%ebp)
  801979:	50                   	push   %eax
  80197a:	56                   	push   %esi
  80197b:	68 b0 27 80 00       	push   $0x8027b0
  801980:	e8 23 e8 ff ff       	call   8001a8 <cprintf>
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	eb ad                	jmp    801937 <_pipeisclosed+0xe>
	}
}
  80198a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80198d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5f                   	pop    %edi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	57                   	push   %edi
  801999:	56                   	push   %esi
  80199a:	53                   	push   %ebx
  80199b:	83 ec 28             	sub    $0x28,%esp
  80199e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019a1:	56                   	push   %esi
  8019a2:	e8 3b f7 ff ff       	call   8010e2 <fd2data>
  8019a7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b1:	eb 4b                	jmp    8019fe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b3:	89 da                	mov    %ebx,%edx
  8019b5:	89 f0                	mov    %esi,%eax
  8019b7:	e8 6d ff ff ff       	call   801929 <_pipeisclosed>
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	75 48                	jne    801a08 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019c0:	e8 f3 f1 ff ff       	call   800bb8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c5:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c8:	8b 0b                	mov    (%ebx),%ecx
  8019ca:	8d 51 20             	lea    0x20(%ecx),%edx
  8019cd:	39 d0                	cmp    %edx,%eax
  8019cf:	73 e2                	jae    8019b3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019d8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019db:	89 c2                	mov    %eax,%edx
  8019dd:	c1 fa 1f             	sar    $0x1f,%edx
  8019e0:	89 d1                	mov    %edx,%ecx
  8019e2:	c1 e9 1b             	shr    $0x1b,%ecx
  8019e5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019e8:	83 e2 1f             	and    $0x1f,%edx
  8019eb:	29 ca                	sub    %ecx,%edx
  8019ed:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019f1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019f5:	83 c0 01             	add    $0x1,%eax
  8019f8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019fb:	83 c7 01             	add    $0x1,%edi
  8019fe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a01:	75 c2                	jne    8019c5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a03:	8b 45 10             	mov    0x10(%ebp),%eax
  801a06:	eb 05                	jmp    801a0d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5f                   	pop    %edi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	57                   	push   %edi
  801a19:	56                   	push   %esi
  801a1a:	53                   	push   %ebx
  801a1b:	83 ec 18             	sub    $0x18,%esp
  801a1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a21:	57                   	push   %edi
  801a22:	e8 bb f6 ff ff       	call   8010e2 <fd2data>
  801a27:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a31:	eb 3d                	jmp    801a70 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a33:	85 db                	test   %ebx,%ebx
  801a35:	74 04                	je     801a3b <devpipe_read+0x26>
				return i;
  801a37:	89 d8                	mov    %ebx,%eax
  801a39:	eb 44                	jmp    801a7f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a3b:	89 f2                	mov    %esi,%edx
  801a3d:	89 f8                	mov    %edi,%eax
  801a3f:	e8 e5 fe ff ff       	call   801929 <_pipeisclosed>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	75 32                	jne    801a7a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a48:	e8 6b f1 ff ff       	call   800bb8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a4d:	8b 06                	mov    (%esi),%eax
  801a4f:	3b 46 04             	cmp    0x4(%esi),%eax
  801a52:	74 df                	je     801a33 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a54:	99                   	cltd   
  801a55:	c1 ea 1b             	shr    $0x1b,%edx
  801a58:	01 d0                	add    %edx,%eax
  801a5a:	83 e0 1f             	and    $0x1f,%eax
  801a5d:	29 d0                	sub    %edx,%eax
  801a5f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a67:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a6a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6d:	83 c3 01             	add    $0x1,%ebx
  801a70:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a73:	75 d8                	jne    801a4d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a75:	8b 45 10             	mov    0x10(%ebp),%eax
  801a78:	eb 05                	jmp    801a7f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5f                   	pop    %edi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	e8 61 f6 ff ff       	call   8010f9 <fd_alloc>
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	89 c2                	mov    %eax,%edx
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	0f 88 2c 01 00 00    	js     801bd1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa5:	83 ec 04             	sub    $0x4,%esp
  801aa8:	68 07 04 00 00       	push   $0x407
  801aad:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab0:	6a 00                	push   $0x0
  801ab2:	e8 20 f1 ff ff       	call   800bd7 <sys_page_alloc>
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	89 c2                	mov    %eax,%edx
  801abc:	85 c0                	test   %eax,%eax
  801abe:	0f 88 0d 01 00 00    	js     801bd1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aca:	50                   	push   %eax
  801acb:	e8 29 f6 ff ff       	call   8010f9 <fd_alloc>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	0f 88 e2 00 00 00    	js     801bbf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801add:	83 ec 04             	sub    $0x4,%esp
  801ae0:	68 07 04 00 00       	push   $0x407
  801ae5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 e8 f0 ff ff       	call   800bd7 <sys_page_alloc>
  801aef:	89 c3                	mov    %eax,%ebx
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	0f 88 c3 00 00 00    	js     801bbf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	ff 75 f4             	pushl  -0xc(%ebp)
  801b02:	e8 db f5 ff ff       	call   8010e2 <fd2data>
  801b07:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b09:	83 c4 0c             	add    $0xc,%esp
  801b0c:	68 07 04 00 00       	push   $0x407
  801b11:	50                   	push   %eax
  801b12:	6a 00                	push   $0x0
  801b14:	e8 be f0 ff ff       	call   800bd7 <sys_page_alloc>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	0f 88 89 00 00 00    	js     801baf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	ff 75 f0             	pushl  -0x10(%ebp)
  801b2c:	e8 b1 f5 ff ff       	call   8010e2 <fd2data>
  801b31:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b38:	50                   	push   %eax
  801b39:	6a 00                	push   $0x0
  801b3b:	56                   	push   %esi
  801b3c:	6a 00                	push   $0x0
  801b3e:	e8 d7 f0 ff ff       	call   800c1a <sys_page_map>
  801b43:	89 c3                	mov    %eax,%ebx
  801b45:	83 c4 20             	add    $0x20,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 55                	js     801ba1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b4c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b55:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7c:	e8 51 f5 ff ff       	call   8010d2 <fd2num>
  801b81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b84:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b86:	83 c4 04             	add    $0x4,%esp
  801b89:	ff 75 f0             	pushl  -0x10(%ebp)
  801b8c:	e8 41 f5 ff ff       	call   8010d2 <fd2num>
  801b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b94:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9f:	eb 30                	jmp    801bd1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	56                   	push   %esi
  801ba5:	6a 00                	push   $0x0
  801ba7:	e8 b0 f0 ff ff       	call   800c5c <sys_page_unmap>
  801bac:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801baf:	83 ec 08             	sub    $0x8,%esp
  801bb2:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 a0 f0 ff ff       	call   800c5c <sys_page_unmap>
  801bbc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 90 f0 ff ff       	call   800c5c <sys_page_unmap>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bd1:	89 d0                	mov    %edx,%eax
  801bd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be3:	50                   	push   %eax
  801be4:	ff 75 08             	pushl  0x8(%ebp)
  801be7:	e8 5c f5 ff ff       	call   801148 <fd_lookup>
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	78 18                	js     801c0b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bf3:	83 ec 0c             	sub    $0xc,%esp
  801bf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf9:	e8 e4 f4 ff ff       	call   8010e2 <fd2data>
	return _pipeisclosed(fd, p);
  801bfe:	89 c2                	mov    %eax,%edx
  801c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c03:	e8 21 fd ff ff       	call   801929 <_pipeisclosed>
  801c08:	83 c4 10             	add    $0x10,%esp
}
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c10:	b8 00 00 00 00       	mov    $0x0,%eax
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c1d:	68 c8 27 80 00       	push   $0x8027c8
  801c22:	ff 75 0c             	pushl  0xc(%ebp)
  801c25:	e8 aa eb ff ff       	call   8007d4 <strcpy>
	return 0;
}
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2f:	c9                   	leave  
  801c30:	c3                   	ret    

00801c31 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	57                   	push   %edi
  801c35:	56                   	push   %esi
  801c36:	53                   	push   %ebx
  801c37:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c3d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c42:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c48:	eb 2d                	jmp    801c77 <devcons_write+0x46>
		m = n - tot;
  801c4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c4d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c4f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c52:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c57:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c5a:	83 ec 04             	sub    $0x4,%esp
  801c5d:	53                   	push   %ebx
  801c5e:	03 45 0c             	add    0xc(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	57                   	push   %edi
  801c63:	e8 fe ec ff ff       	call   800966 <memmove>
		sys_cputs(buf, m);
  801c68:	83 c4 08             	add    $0x8,%esp
  801c6b:	53                   	push   %ebx
  801c6c:	57                   	push   %edi
  801c6d:	e8 a9 ee ff ff       	call   800b1b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c72:	01 de                	add    %ebx,%esi
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	89 f0                	mov    %esi,%eax
  801c79:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c7c:	72 cc                	jb     801c4a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c81:	5b                   	pop    %ebx
  801c82:	5e                   	pop    %esi
  801c83:	5f                   	pop    %edi
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 08             	sub    $0x8,%esp
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c95:	74 2a                	je     801cc1 <devcons_read+0x3b>
  801c97:	eb 05                	jmp    801c9e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c99:	e8 1a ef ff ff       	call   800bb8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c9e:	e8 96 ee ff ff       	call   800b39 <sys_cgetc>
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	74 f2                	je     801c99 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	78 16                	js     801cc1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cab:	83 f8 04             	cmp    $0x4,%eax
  801cae:	74 0c                	je     801cbc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb3:	88 02                	mov    %al,(%edx)
	return 1;
  801cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cba:	eb 05                	jmp    801cc1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cc1:	c9                   	leave  
  801cc2:	c3                   	ret    

00801cc3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ccf:	6a 01                	push   $0x1
  801cd1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd4:	50                   	push   %eax
  801cd5:	e8 41 ee ff ff       	call   800b1b <sys_cputs>
}
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <getchar>:

int
getchar(void)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ce5:	6a 01                	push   $0x1
  801ce7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cea:	50                   	push   %eax
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 bc f6 ff ff       	call   8013ae <read>
	if (r < 0)
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	78 0f                	js     801d08 <getchar+0x29>
		return r;
	if (r < 1)
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	7e 06                	jle    801d03 <getchar+0x24>
		return -E_EOF;
	return c;
  801cfd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d01:	eb 05                	jmp    801d08 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d03:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d13:	50                   	push   %eax
  801d14:	ff 75 08             	pushl  0x8(%ebp)
  801d17:	e8 2c f4 ff ff       	call   801148 <fd_lookup>
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	78 11                	js     801d34 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2c:	39 10                	cmp    %edx,(%eax)
  801d2e:	0f 94 c0             	sete   %al
  801d31:	0f b6 c0             	movzbl %al,%eax
}
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    

00801d36 <opencons>:

int
opencons(void)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3f:	50                   	push   %eax
  801d40:	e8 b4 f3 ff ff       	call   8010f9 <fd_alloc>
  801d45:	83 c4 10             	add    $0x10,%esp
		return r;
  801d48:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 3e                	js     801d8c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d4e:	83 ec 04             	sub    $0x4,%esp
  801d51:	68 07 04 00 00       	push   $0x407
  801d56:	ff 75 f4             	pushl  -0xc(%ebp)
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 77 ee ff ff       	call   800bd7 <sys_page_alloc>
  801d60:	83 c4 10             	add    $0x10,%esp
		return r;
  801d63:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 23                	js     801d8c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d77:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	50                   	push   %eax
  801d82:	e8 4b f3 ff ff       	call   8010d2 <fd2num>
  801d87:	89 c2                	mov    %eax,%edx
  801d89:	83 c4 10             	add    $0x10,%esp
}
  801d8c:	89 d0                	mov    %edx,%eax
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d95:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d98:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d9e:	e8 f6 ed ff ff       	call   800b99 <sys_getenvid>
  801da3:	83 ec 0c             	sub    $0xc,%esp
  801da6:	ff 75 0c             	pushl  0xc(%ebp)
  801da9:	ff 75 08             	pushl  0x8(%ebp)
  801dac:	56                   	push   %esi
  801dad:	50                   	push   %eax
  801dae:	68 d4 27 80 00       	push   $0x8027d4
  801db3:	e8 f0 e3 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801db8:	83 c4 18             	add    $0x18,%esp
  801dbb:	53                   	push   %ebx
  801dbc:	ff 75 10             	pushl  0x10(%ebp)
  801dbf:	e8 93 e3 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801dc4:	c7 04 24 b4 22 80 00 	movl   $0x8022b4,(%esp)
  801dcb:	e8 d8 e3 ff ff       	call   8001a8 <cprintf>
  801dd0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dd3:	cc                   	int3   
  801dd4:	eb fd                	jmp    801dd3 <_panic+0x43>

00801dd6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ddc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de3:	75 31                	jne    801e16 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801de5:	a1 04 40 80 00       	mov    0x804004,%eax
  801dea:	8b 40 48             	mov    0x48(%eax),%eax
  801ded:	83 ec 04             	sub    $0x4,%esp
  801df0:	6a 07                	push   $0x7
  801df2:	68 00 f0 bf ee       	push   $0xeebff000
  801df7:	50                   	push   %eax
  801df8:	e8 da ed ff ff       	call   800bd7 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801dfd:	a1 04 40 80 00       	mov    0x804004,%eax
  801e02:	8b 40 48             	mov    0x48(%eax),%eax
  801e05:	83 c4 08             	add    $0x8,%esp
  801e08:	68 20 1e 80 00       	push   $0x801e20
  801e0d:	50                   	push   %eax
  801e0e:	e8 0f ef ff ff       	call   800d22 <sys_env_set_pgfault_upcall>
  801e13:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e20:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e21:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e26:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e28:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801e2b:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801e2e:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801e32:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801e36:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801e39:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801e3b:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801e3f:	61                   	popa   
	addl $4, %esp        // skip eip
  801e40:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801e43:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801e44:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e45:	c3                   	ret    

00801e46 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	56                   	push   %esi
  801e4a:	53                   	push   %ebx
  801e4b:	8b 75 08             	mov    0x8(%ebp),%esi
  801e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801e54:	85 c0                	test   %eax,%eax
  801e56:	74 0e                	je     801e66 <ipc_recv+0x20>
  801e58:	83 ec 0c             	sub    $0xc,%esp
  801e5b:	50                   	push   %eax
  801e5c:	e8 26 ef ff ff       	call   800d87 <sys_ipc_recv>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	eb 10                	jmp    801e76 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	68 00 00 c0 ee       	push   $0xeec00000
  801e6e:	e8 14 ef ff ff       	call   800d87 <sys_ipc_recv>
  801e73:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801e76:	85 c0                	test   %eax,%eax
  801e78:	74 16                	je     801e90 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801e7a:	85 f6                	test   %esi,%esi
  801e7c:	74 06                	je     801e84 <ipc_recv+0x3e>
  801e7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801e84:	85 db                	test   %ebx,%ebx
  801e86:	74 2c                	je     801eb4 <ipc_recv+0x6e>
  801e88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e8e:	eb 24                	jmp    801eb4 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801e90:	85 f6                	test   %esi,%esi
  801e92:	74 0a                	je     801e9e <ipc_recv+0x58>
  801e94:	a1 04 40 80 00       	mov    0x804004,%eax
  801e99:	8b 40 74             	mov    0x74(%eax),%eax
  801e9c:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801e9e:	85 db                	test   %ebx,%ebx
  801ea0:	74 0a                	je     801eac <ipc_recv+0x66>
  801ea2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea7:	8b 40 78             	mov    0x78(%eax),%eax
  801eaa:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eac:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801eb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	57                   	push   %edi
  801ebf:	56                   	push   %esi
  801ec0:	53                   	push   %ebx
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eca:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ed4:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801ed7:	ff 75 14             	pushl  0x14(%ebp)
  801eda:	53                   	push   %ebx
  801edb:	56                   	push   %esi
  801edc:	57                   	push   %edi
  801edd:	e8 82 ee ff ff       	call   800d64 <sys_ipc_try_send>
		if (ret == 0) break;
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	74 1e                	je     801f07 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801ee9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eec:	74 12                	je     801f00 <ipc_send+0x45>
  801eee:	50                   	push   %eax
  801eef:	68 f8 27 80 00       	push   $0x8027f8
  801ef4:	6a 39                	push   $0x39
  801ef6:	68 05 28 80 00       	push   $0x802805
  801efb:	e8 90 fe ff ff       	call   801d90 <_panic>
		sys_yield();
  801f00:	e8 b3 ec ff ff       	call   800bb8 <sys_yield>
	}
  801f05:	eb d0                	jmp    801ed7 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5f                   	pop    %edi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f15:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f1a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f1d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f23:	8b 52 50             	mov    0x50(%edx),%edx
  801f26:	39 ca                	cmp    %ecx,%edx
  801f28:	75 0d                	jne    801f37 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f2a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f2d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f32:	8b 40 48             	mov    0x48(%eax),%eax
  801f35:	eb 0f                	jmp    801f46 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f37:	83 c0 01             	add    $0x1,%eax
  801f3a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3f:	75 d9                	jne    801f1a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    

00801f48 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4e:	89 d0                	mov    %edx,%eax
  801f50:	c1 e8 16             	shr    $0x16,%eax
  801f53:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f5a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5f:	f6 c1 01             	test   $0x1,%cl
  801f62:	74 1d                	je     801f81 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f64:	c1 ea 0c             	shr    $0xc,%edx
  801f67:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f6e:	f6 c2 01             	test   $0x1,%dl
  801f71:	74 0e                	je     801f81 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f73:	c1 ea 0c             	shr    $0xc,%edx
  801f76:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f7d:	ef 
  801f7e:	0f b7 c0             	movzwl %ax,%eax
}
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    
  801f83:	66 90                	xchg   %ax,%ax
  801f85:	66 90                	xchg   %ax,%ax
  801f87:	66 90                	xchg   %ax,%ax
  801f89:	66 90                	xchg   %ax,%ax
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

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
