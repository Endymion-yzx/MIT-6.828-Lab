
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 60 21 80 00       	push   $0x802160
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 b4 0d 00 00       	call   800e20 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 ba 0d 00 00       	call   800e50 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 b6 13 00 00       	call   801468 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 74 21 80 00       	push   $0x802174
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 5c 17 00 00       	call   801836 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 74 21 80 00       	push   $0x802174
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800118:	e8 d4 0a 00 00       	call   800bf1 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 e1 0f 00 00       	call   80113f <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 48 0a 00 00       	call   800bb0 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 d6 09 00 00       	call   800b73 <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 1a 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 7b 09 00 00       	call   800b73 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 68 1c 00 00       	call   801ed0 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 55 1d 00 00       	call   802000 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 a6 21 80 00 	movsbl 0x8021a6(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 0a                	jae    8002de <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	88 02                	mov    %al,(%edx)
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 10             	pushl  0x10(%ebp)
  8002ed:	ff 75 0c             	pushl  0xc(%ebp)
  8002f0:	ff 75 08             	pushl  0x8(%ebp)
  8002f3:	e8 05 00 00 00       	call   8002fd <vprintfmt>
	va_end(ap);
}
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 2c             	sub    $0x2c,%esp
  800306:	8b 75 08             	mov    0x8(%ebp),%esi
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030f:	eb 12                	jmp    800323 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800311:	85 c0                	test   %eax,%eax
  800313:	0f 84 6a 04 00 00    	je     800783 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	53                   	push   %ebx
  80031d:	50                   	push   %eax
  80031e:	ff d6                	call   *%esi
  800320:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800323:	83 c7 01             	add    $0x1,%edi
  800326:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032a:	83 f8 25             	cmp    $0x25,%eax
  80032d:	75 e2                	jne    800311 <vprintfmt+0x14>
  80032f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800333:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800341:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800348:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034d:	eb 07                	jmp    800356 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800352:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8d 47 01             	lea    0x1(%edi),%eax
  800359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035c:	0f b6 07             	movzbl (%edi),%eax
  80035f:	0f b6 d0             	movzbl %al,%edx
  800362:	83 e8 23             	sub    $0x23,%eax
  800365:	3c 55                	cmp    $0x55,%al
  800367:	0f 87 fb 03 00 00    	ja     800768 <vprintfmt+0x46b>
  80036d:	0f b6 c0             	movzbl %al,%eax
  800370:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80037e:	eb d6                	jmp    800356 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800392:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800395:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800398:	83 f9 09             	cmp    $0x9,%ecx
  80039b:	77 3f                	ja     8003dc <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a0:	eb e9                	jmp    80038b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 40 04             	lea    0x4(%eax),%eax
  8003b0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b6:	eb 2a                	jmp    8003e2 <vprintfmt+0xe5>
  8003b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c2:	0f 49 d0             	cmovns %eax,%edx
  8003c5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cb:	eb 89                	jmp    800356 <vprintfmt+0x59>
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d7:	e9 7a ff ff ff       	jmp    800356 <vprintfmt+0x59>
  8003dc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e6:	0f 89 6a ff ff ff    	jns    800356 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f9:	e9 58 ff ff ff       	jmp    800356 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fe:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800404:	e9 4d ff ff ff       	jmp    800356 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 78 04             	lea    0x4(%eax),%edi
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	53                   	push   %ebx
  800413:	ff 30                	pushl  (%eax)
  800415:	ff d6                	call   *%esi
			break;
  800417:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800420:	e9 fe fe ff ff       	jmp    800323 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 78 04             	lea    0x4(%eax),%edi
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	99                   	cltd   
  80042e:	31 d0                	xor    %edx,%eax
  800430:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800432:	83 f8 0f             	cmp    $0xf,%eax
  800435:	7f 0b                	jg     800442 <vprintfmt+0x145>
  800437:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  80043e:	85 d2                	test   %edx,%edx
  800440:	75 1b                	jne    80045d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800442:	50                   	push   %eax
  800443:	68 be 21 80 00       	push   $0x8021be
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 91 fe ff ff       	call   8002e0 <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800452:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800458:	e9 c6 fe ff ff       	jmp    800323 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	68 9a 25 80 00       	push   $0x80259a
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 76 fe ff ff       	call   8002e0 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800473:	e9 ab fe ff ff       	jmp    800323 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	83 c0 04             	add    $0x4,%eax
  80047e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800486:	85 ff                	test   %edi,%edi
  800488:	b8 b7 21 80 00       	mov    $0x8021b7,%eax
  80048d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800490:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800494:	0f 8e 94 00 00 00    	jle    80052e <vprintfmt+0x231>
  80049a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049e:	0f 84 98 00 00 00    	je     80053c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8004aa:	57                   	push   %edi
  8004ab:	e8 5b 03 00 00       	call   80080b <strnlen>
  8004b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b3:	29 c1                	sub    %eax,%ecx
  8004b5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c5:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	eb 0f                	jmp    8004d8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ef 01             	sub    $0x1,%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f ed                	jg     8004c9 <vprintfmt+0x1cc>
  8004dc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004df:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e2:	85 c9                	test   %ecx,%ecx
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	0f 49 c1             	cmovns %ecx,%eax
  8004ec:	29 c1                	sub    %eax,%ecx
  8004ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f7:	89 cb                	mov    %ecx,%ebx
  8004f9:	eb 4d                	jmp    800548 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ff:	74 1b                	je     80051c <vprintfmt+0x21f>
  800501:	0f be c0             	movsbl %al,%eax
  800504:	83 e8 20             	sub    $0x20,%eax
  800507:	83 f8 5e             	cmp    $0x5e,%eax
  80050a:	76 10                	jbe    80051c <vprintfmt+0x21f>
					putch('?', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	ff 75 0c             	pushl  0xc(%ebp)
  800512:	6a 3f                	push   $0x3f
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	eb 0d                	jmp    800529 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	52                   	push   %edx
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800529:	83 eb 01             	sub    $0x1,%ebx
  80052c:	eb 1a                	jmp    800548 <vprintfmt+0x24b>
  80052e:	89 75 08             	mov    %esi,0x8(%ebp)
  800531:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800534:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800537:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053a:	eb 0c                	jmp    800548 <vprintfmt+0x24b>
  80053c:	89 75 08             	mov    %esi,0x8(%ebp)
  80053f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800542:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800545:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	0f be d0             	movsbl %al,%edx
  800552:	85 d2                	test   %edx,%edx
  800554:	74 23                	je     800579 <vprintfmt+0x27c>
  800556:	85 f6                	test   %esi,%esi
  800558:	78 a1                	js     8004fb <vprintfmt+0x1fe>
  80055a:	83 ee 01             	sub    $0x1,%esi
  80055d:	79 9c                	jns    8004fb <vprintfmt+0x1fe>
  80055f:	89 df                	mov    %ebx,%edi
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	eb 18                	jmp    800581 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	6a 20                	push   $0x20
  80056f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800571:	83 ef 01             	sub    $0x1,%edi
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	eb 08                	jmp    800581 <vprintfmt+0x284>
  800579:	89 df                	mov    %ebx,%edi
  80057b:	8b 75 08             	mov    0x8(%ebp),%esi
  80057e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800581:	85 ff                	test   %edi,%edi
  800583:	7f e4                	jg     800569 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800585:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058e:	e9 90 fd ff ff       	jmp    800323 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7e 19                	jle    8005b1 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 50 04             	mov    0x4(%eax),%edx
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8005af:	eb 38                	jmp    8005e9 <vprintfmt+0x2ec>
	else if (lflag)
  8005b1:	85 c9                	test   %ecx,%ecx
  8005b3:	74 1b                	je     8005d0 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	89 c1                	mov    %eax,%ecx
  8005bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ce:	eb 19                	jmp    8005e9 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f8:	0f 89 36 01 00 00    	jns    800734 <vprintfmt+0x437>
				putch('-', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 2d                	push   $0x2d
  800604:	ff d6                	call   *%esi
				num = -(long long) num;
  800606:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800609:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060c:	f7 da                	neg    %edx
  80060e:	83 d1 00             	adc    $0x0,%ecx
  800611:	f7 d9                	neg    %ecx
  800613:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061b:	e9 14 01 00 00       	jmp    800734 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 18                	jle    80063d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	8b 48 04             	mov    0x4(%eax),%ecx
  80062d:	8d 40 08             	lea    0x8(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
  800638:	e9 f7 00 00 00       	jmp    800734 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	74 1a                	je     80065b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	e9 d9 00 00 00       	jmp    800734 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800670:	e9 bf 00 00 00       	jmp    800734 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7e 13                	jle    80068d <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 50 04             	mov    0x4(%eax),%edx
  800680:	8b 00                	mov    (%eax),%eax
  800682:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800685:	8d 49 08             	lea    0x8(%ecx),%ecx
  800688:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80068b:	eb 28                	jmp    8006b5 <vprintfmt+0x3b8>
	else if (lflag)
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	74 13                	je     8006a4 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	89 d0                	mov    %edx,%eax
  800698:	99                   	cltd   
  800699:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80069c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80069f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006a2:	eb 11                	jmp    8006b5 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	89 d0                	mov    %edx,%eax
  8006ab:	99                   	cltd   
  8006ac:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006af:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8006b5:	89 d1                	mov    %edx,%ecx
  8006b7:	89 c2                	mov    %eax,%edx
			base = 8;
  8006b9:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006be:	eb 74                	jmp    800734 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	6a 30                	push   $0x30
  8006c6:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c8:	83 c4 08             	add    $0x8,%esp
  8006cb:	53                   	push   %ebx
  8006cc:	6a 78                	push   $0x78
  8006ce:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006da:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e8:	eb 4a                	jmp    800734 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ea:	83 f9 01             	cmp    $0x1,%ecx
  8006ed:	7e 15                	jle    800704 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f7:	8d 40 08             	lea    0x8(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fd:	b8 10 00 00 00       	mov    $0x10,%eax
  800702:	eb 30                	jmp    800734 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800704:	85 c9                	test   %ecx,%ecx
  800706:	74 17                	je     80071f <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800718:	b8 10 00 00 00       	mov    $0x10,%eax
  80071d:	eb 15                	jmp    800734 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	b9 00 00 00 00       	mov    $0x0,%ecx
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800734:	83 ec 0c             	sub    $0xc,%esp
  800737:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80073b:	57                   	push   %edi
  80073c:	ff 75 e0             	pushl  -0x20(%ebp)
  80073f:	50                   	push   %eax
  800740:	51                   	push   %ecx
  800741:	52                   	push   %edx
  800742:	89 da                	mov    %ebx,%edx
  800744:	89 f0                	mov    %esi,%eax
  800746:	e8 c9 fa ff ff       	call   800214 <printnum>
			break;
  80074b:	83 c4 20             	add    $0x20,%esp
  80074e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800751:	e9 cd fb ff ff       	jmp    800323 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	52                   	push   %edx
  80075b:	ff d6                	call   *%esi
			break;
  80075d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800760:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800763:	e9 bb fb ff ff       	jmp    800323 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	53                   	push   %ebx
  80076c:	6a 25                	push   $0x25
  80076e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	eb 03                	jmp    800778 <vprintfmt+0x47b>
  800775:	83 ef 01             	sub    $0x1,%edi
  800778:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80077c:	75 f7                	jne    800775 <vprintfmt+0x478>
  80077e:	e9 a0 fb ff ff       	jmp    800323 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5f                   	pop    %edi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 18             	sub    $0x18,%esp
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800797:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a8:	85 c0                	test   %eax,%eax
  8007aa:	74 26                	je     8007d2 <vsnprintf+0x47>
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	7e 22                	jle    8007d2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b0:	ff 75 14             	pushl  0x14(%ebp)
  8007b3:	ff 75 10             	pushl  0x10(%ebp)
  8007b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	68 c3 02 80 00       	push   $0x8002c3
  8007bf:	e8 39 fb ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb 05                	jmp    8007d7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e2:	50                   	push   %eax
  8007e3:	ff 75 10             	pushl  0x10(%ebp)
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	ff 75 08             	pushl  0x8(%ebp)
  8007ec:	e8 9a ff ff ff       	call   80078b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fe:	eb 03                	jmp    800803 <strlen+0x10>
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	75 f7                	jne    800800 <strlen+0xd>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800814:	ba 00 00 00 00       	mov    $0x0,%edx
  800819:	eb 03                	jmp    80081e <strnlen+0x13>
		n++;
  80081b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081e:	39 c2                	cmp    %eax,%edx
  800820:	74 08                	je     80082a <strnlen+0x1f>
  800822:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800826:	75 f3                	jne    80081b <strnlen+0x10>
  800828:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800836:	89 c2                	mov    %eax,%edx
  800838:	83 c2 01             	add    $0x1,%edx
  80083b:	83 c1 01             	add    $0x1,%ecx
  80083e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800842:	88 5a ff             	mov    %bl,-0x1(%edx)
  800845:	84 db                	test   %bl,%bl
  800847:	75 ef                	jne    800838 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800853:	53                   	push   %ebx
  800854:	e8 9a ff ff ff       	call   8007f3 <strlen>
  800859:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	01 d8                	add    %ebx,%eax
  800861:	50                   	push   %eax
  800862:	e8 c5 ff ff ff       	call   80082c <strcpy>
	return dst;
}
  800867:	89 d8                	mov    %ebx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 75 08             	mov    0x8(%ebp),%esi
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	89 f3                	mov    %esi,%ebx
  80087b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087e:	89 f2                	mov    %esi,%edx
  800880:	eb 0f                	jmp    800891 <strncpy+0x23>
		*dst++ = *src;
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	0f b6 01             	movzbl (%ecx),%eax
  800888:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088b:	80 39 01             	cmpb   $0x1,(%ecx)
  80088e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800891:	39 da                	cmp    %ebx,%edx
  800893:	75 ed                	jne    800882 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800895:	89 f0                	mov    %esi,%eax
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ab:	85 d2                	test   %edx,%edx
  8008ad:	74 21                	je     8008d0 <strlcpy+0x35>
  8008af:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b3:	89 f2                	mov    %esi,%edx
  8008b5:	eb 09                	jmp    8008c0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	83 c1 01             	add    $0x1,%ecx
  8008bd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c0:	39 c2                	cmp    %eax,%edx
  8008c2:	74 09                	je     8008cd <strlcpy+0x32>
  8008c4:	0f b6 19             	movzbl (%ecx),%ebx
  8008c7:	84 db                	test   %bl,%bl
  8008c9:	75 ec                	jne    8008b7 <strlcpy+0x1c>
  8008cb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008cd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d0:	29 f0                	sub    %esi,%eax
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008df:	eb 06                	jmp    8008e7 <strcmp+0x11>
		p++, q++;
  8008e1:	83 c1 01             	add    $0x1,%ecx
  8008e4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e7:	0f b6 01             	movzbl (%ecx),%eax
  8008ea:	84 c0                	test   %al,%al
  8008ec:	74 04                	je     8008f2 <strcmp+0x1c>
  8008ee:	3a 02                	cmp    (%edx),%al
  8008f0:	74 ef                	je     8008e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f2:	0f b6 c0             	movzbl %al,%eax
  8008f5:	0f b6 12             	movzbl (%edx),%edx
  8008f8:	29 d0                	sub    %edx,%eax
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	53                   	push   %ebx
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
  800906:	89 c3                	mov    %eax,%ebx
  800908:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80090b:	eb 06                	jmp    800913 <strncmp+0x17>
		n--, p++, q++;
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800913:	39 d8                	cmp    %ebx,%eax
  800915:	74 15                	je     80092c <strncmp+0x30>
  800917:	0f b6 08             	movzbl (%eax),%ecx
  80091a:	84 c9                	test   %cl,%cl
  80091c:	74 04                	je     800922 <strncmp+0x26>
  80091e:	3a 0a                	cmp    (%edx),%cl
  800920:	74 eb                	je     80090d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800922:	0f b6 00             	movzbl (%eax),%eax
  800925:	0f b6 12             	movzbl (%edx),%edx
  800928:	29 d0                	sub    %edx,%eax
  80092a:	eb 05                	jmp    800931 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093e:	eb 07                	jmp    800947 <strchr+0x13>
		if (*s == c)
  800940:	38 ca                	cmp    %cl,%dl
  800942:	74 0f                	je     800953 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	0f b6 10             	movzbl (%eax),%edx
  80094a:	84 d2                	test   %dl,%dl
  80094c:	75 f2                	jne    800940 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095f:	eb 03                	jmp    800964 <strfind+0xf>
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 04                	je     80096f <strfind+0x1a>
  80096b:	84 d2                	test   %dl,%dl
  80096d:	75 f2                	jne    800961 <strfind+0xc>
			break;
	return (char *) s;
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	57                   	push   %edi
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097d:	85 c9                	test   %ecx,%ecx
  80097f:	74 36                	je     8009b7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800981:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800987:	75 28                	jne    8009b1 <memset+0x40>
  800989:	f6 c1 03             	test   $0x3,%cl
  80098c:	75 23                	jne    8009b1 <memset+0x40>
		c &= 0xFF;
  80098e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800992:	89 d3                	mov    %edx,%ebx
  800994:	c1 e3 08             	shl    $0x8,%ebx
  800997:	89 d6                	mov    %edx,%esi
  800999:	c1 e6 18             	shl    $0x18,%esi
  80099c:	89 d0                	mov    %edx,%eax
  80099e:	c1 e0 10             	shl    $0x10,%eax
  8009a1:	09 f0                	or     %esi,%eax
  8009a3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a5:	89 d8                	mov    %ebx,%eax
  8009a7:	09 d0                	or     %edx,%eax
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
  8009ac:	fc                   	cld    
  8009ad:	f3 ab                	rep stos %eax,%es:(%edi)
  8009af:	eb 06                	jmp    8009b7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b4:	fc                   	cld    
  8009b5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b7:	89 f8                	mov    %edi,%eax
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cc:	39 c6                	cmp    %eax,%esi
  8009ce:	73 35                	jae    800a05 <memmove+0x47>
  8009d0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d3:	39 d0                	cmp    %edx,%eax
  8009d5:	73 2e                	jae    800a05 <memmove+0x47>
		s += n;
		d += n;
  8009d7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009da:	89 d6                	mov    %edx,%esi
  8009dc:	09 fe                	or     %edi,%esi
  8009de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e4:	75 13                	jne    8009f9 <memmove+0x3b>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 0e                	jne    8009f9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009eb:	83 ef 04             	sub    $0x4,%edi
  8009ee:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
  8009f4:	fd                   	std    
  8009f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f7:	eb 09                	jmp    800a02 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f9:	83 ef 01             	sub    $0x1,%edi
  8009fc:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ff:	fd                   	std    
  800a00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a02:	fc                   	cld    
  800a03:	eb 1d                	jmp    800a22 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a05:	89 f2                	mov    %esi,%edx
  800a07:	09 c2                	or     %eax,%edx
  800a09:	f6 c2 03             	test   $0x3,%dl
  800a0c:	75 0f                	jne    800a1d <memmove+0x5f>
  800a0e:	f6 c1 03             	test   $0x3,%cl
  800a11:	75 0a                	jne    800a1d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a13:	c1 e9 02             	shr    $0x2,%ecx
  800a16:	89 c7                	mov    %eax,%edi
  800a18:	fc                   	cld    
  800a19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1b:	eb 05                	jmp    800a22 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1d:	89 c7                	mov    %eax,%edi
  800a1f:	fc                   	cld    
  800a20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a29:	ff 75 10             	pushl  0x10(%ebp)
  800a2c:	ff 75 0c             	pushl  0xc(%ebp)
  800a2f:	ff 75 08             	pushl  0x8(%ebp)
  800a32:	e8 87 ff ff ff       	call   8009be <memmove>
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a44:	89 c6                	mov    %eax,%esi
  800a46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a49:	eb 1a                	jmp    800a65 <memcmp+0x2c>
		if (*s1 != *s2)
  800a4b:	0f b6 08             	movzbl (%eax),%ecx
  800a4e:	0f b6 1a             	movzbl (%edx),%ebx
  800a51:	38 d9                	cmp    %bl,%cl
  800a53:	74 0a                	je     800a5f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a55:	0f b6 c1             	movzbl %cl,%eax
  800a58:	0f b6 db             	movzbl %bl,%ebx
  800a5b:	29 d8                	sub    %ebx,%eax
  800a5d:	eb 0f                	jmp    800a6e <memcmp+0x35>
		s1++, s2++;
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a65:	39 f0                	cmp    %esi,%eax
  800a67:	75 e2                	jne    800a4b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	53                   	push   %ebx
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a79:	89 c1                	mov    %eax,%ecx
  800a7b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a82:	eb 0a                	jmp    800a8e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a84:	0f b6 10             	movzbl (%eax),%edx
  800a87:	39 da                	cmp    %ebx,%edx
  800a89:	74 07                	je     800a92 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	39 c8                	cmp    %ecx,%eax
  800a90:	72 f2                	jb     800a84 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a92:	5b                   	pop    %ebx
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa1:	eb 03                	jmp    800aa6 <strtol+0x11>
		s++;
  800aa3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa6:	0f b6 01             	movzbl (%ecx),%eax
  800aa9:	3c 20                	cmp    $0x20,%al
  800aab:	74 f6                	je     800aa3 <strtol+0xe>
  800aad:	3c 09                	cmp    $0x9,%al
  800aaf:	74 f2                	je     800aa3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab1:	3c 2b                	cmp    $0x2b,%al
  800ab3:	75 0a                	jne    800abf <strtol+0x2a>
		s++;
  800ab5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab8:	bf 00 00 00 00       	mov    $0x0,%edi
  800abd:	eb 11                	jmp    800ad0 <strtol+0x3b>
  800abf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac4:	3c 2d                	cmp    $0x2d,%al
  800ac6:	75 08                	jne    800ad0 <strtol+0x3b>
		s++, neg = 1;
  800ac8:	83 c1 01             	add    $0x1,%ecx
  800acb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad6:	75 15                	jne    800aed <strtol+0x58>
  800ad8:	80 39 30             	cmpb   $0x30,(%ecx)
  800adb:	75 10                	jne    800aed <strtol+0x58>
  800add:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae1:	75 7c                	jne    800b5f <strtol+0xca>
		s += 2, base = 16;
  800ae3:	83 c1 02             	add    $0x2,%ecx
  800ae6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aeb:	eb 16                	jmp    800b03 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	75 12                	jne    800b03 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af6:	80 39 30             	cmpb   $0x30,(%ecx)
  800af9:	75 08                	jne    800b03 <strtol+0x6e>
		s++, base = 8;
  800afb:	83 c1 01             	add    $0x1,%ecx
  800afe:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0b:	0f b6 11             	movzbl (%ecx),%edx
  800b0e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b11:	89 f3                	mov    %esi,%ebx
  800b13:	80 fb 09             	cmp    $0x9,%bl
  800b16:	77 08                	ja     800b20 <strtol+0x8b>
			dig = *s - '0';
  800b18:	0f be d2             	movsbl %dl,%edx
  800b1b:	83 ea 30             	sub    $0x30,%edx
  800b1e:	eb 22                	jmp    800b42 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b20:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b23:	89 f3                	mov    %esi,%ebx
  800b25:	80 fb 19             	cmp    $0x19,%bl
  800b28:	77 08                	ja     800b32 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b2a:	0f be d2             	movsbl %dl,%edx
  800b2d:	83 ea 57             	sub    $0x57,%edx
  800b30:	eb 10                	jmp    800b42 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b32:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b35:	89 f3                	mov    %esi,%ebx
  800b37:	80 fb 19             	cmp    $0x19,%bl
  800b3a:	77 16                	ja     800b52 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3c:	0f be d2             	movsbl %dl,%edx
  800b3f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b45:	7d 0b                	jge    800b52 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b47:	83 c1 01             	add    $0x1,%ecx
  800b4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b50:	eb b9                	jmp    800b0b <strtol+0x76>

	if (endptr)
  800b52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b56:	74 0d                	je     800b65 <strtol+0xd0>
		*endptr = (char *) s;
  800b58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5b:	89 0e                	mov    %ecx,(%esi)
  800b5d:	eb 06                	jmp    800b65 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5f:	85 db                	test   %ebx,%ebx
  800b61:	74 98                	je     800afb <strtol+0x66>
  800b63:	eb 9e                	jmp    800b03 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b65:	89 c2                	mov    %eax,%edx
  800b67:	f7 da                	neg    %edx
  800b69:	85 ff                	test   %edi,%edi
  800b6b:	0f 45 c2             	cmovne %edx,%eax
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b81:	8b 55 08             	mov    0x8(%ebp),%edx
  800b84:	89 c3                	mov    %eax,%ebx
  800b86:	89 c7                	mov    %eax,%edi
  800b88:	89 c6                	mov    %eax,%esi
  800b8a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba1:	89 d1                	mov    %edx,%ecx
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	89 d6                	mov    %edx,%esi
  800ba9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbe:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	89 cb                	mov    %ecx,%ebx
  800bc8:	89 cf                	mov    %ecx,%edi
  800bca:	89 ce                	mov    %ecx,%esi
  800bcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 03                	push   $0x3
  800bd8:	68 9f 24 80 00       	push   $0x80249f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 bc 24 80 00       	push   $0x8024bc
  800be4:	e8 59 11 00 00       	call   801d42 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 02 00 00 00       	mov    $0x2,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_yield>:

void
sys_yield(void)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c20:	89 d1                	mov    %edx,%ecx
  800c22:	89 d3                	mov    %edx,%ebx
  800c24:	89 d7                	mov    %edx,%edi
  800c26:	89 d6                	mov    %edx,%esi
  800c28:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	be 00 00 00 00       	mov    $0x0,%esi
  800c3d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4b:	89 f7                	mov    %esi,%edi
  800c4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 17                	jle    800c6a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 04                	push   $0x4
  800c59:	68 9f 24 80 00       	push   $0x80249f
  800c5e:	6a 23                	push   $0x23
  800c60:	68 bc 24 80 00       	push   $0x8024bc
  800c65:	e8 d8 10 00 00       	call   801d42 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 05                	push   $0x5
  800c9b:	68 9f 24 80 00       	push   $0x80249f
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 bc 24 80 00       	push   $0x8024bc
  800ca7:	e8 96 10 00 00       	call   801d42 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 17                	jle    800cee <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 06                	push   $0x6
  800cdd:	68 9f 24 80 00       	push   $0x80249f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 bc 24 80 00       	push   $0x8024bc
  800ce9:	e8 54 10 00 00       	call   801d42 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	b8 08 00 00 00       	mov    $0x8,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7e 17                	jle    800d30 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 08                	push   $0x8
  800d1f:	68 9f 24 80 00       	push   $0x80249f
  800d24:	6a 23                	push   $0x23
  800d26:	68 bc 24 80 00       	push   $0x8024bc
  800d2b:	e8 12 10 00 00       	call   801d42 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7e 17                	jle    800d72 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 09                	push   $0x9
  800d61:	68 9f 24 80 00       	push   $0x80249f
  800d66:	6a 23                	push   $0x23
  800d68:	68 bc 24 80 00       	push   $0x8024bc
  800d6d:	e8 d0 0f 00 00       	call   801d42 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d90:	8b 55 08             	mov    0x8(%ebp),%edx
  800d93:	89 df                	mov    %ebx,%edi
  800d95:	89 de                	mov    %ebx,%esi
  800d97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7e 17                	jle    800db4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	50                   	push   %eax
  800da1:	6a 0a                	push   $0xa
  800da3:	68 9f 24 80 00       	push   $0x80249f
  800da8:	6a 23                	push   $0x23
  800daa:	68 bc 24 80 00       	push   $0x8024bc
  800daf:	e8 8e 0f 00 00       	call   801d42 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc2:	be 00 00 00 00       	mov    $0x0,%esi
  800dc7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ded:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	89 cb                	mov    %ecx,%ebx
  800df7:	89 cf                	mov    %ecx,%edi
  800df9:	89 ce                	mov    %ecx,%esi
  800dfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 17                	jle    800e18 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 0d                	push   $0xd
  800e07:	68 9f 24 80 00       	push   $0x80249f
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 bc 24 80 00       	push   $0x8024bc
  800e13:	e8 2a 0f 00 00       	call   801d42 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e2c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e2e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e31:	83 3a 01             	cmpl   $0x1,(%edx)
  800e34:	7e 09                	jle    800e3f <argstart+0x1f>
  800e36:	ba 71 21 80 00       	mov    $0x802171,%edx
  800e3b:	85 c9                	test   %ecx,%ecx
  800e3d:	75 05                	jne    800e44 <argstart+0x24>
  800e3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e44:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e47:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <argnext>:

int
argnext(struct Argstate *args)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	53                   	push   %ebx
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e5a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e61:	8b 43 08             	mov    0x8(%ebx),%eax
  800e64:	85 c0                	test   %eax,%eax
  800e66:	74 6f                	je     800ed7 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e68:	80 38 00             	cmpb   $0x0,(%eax)
  800e6b:	75 4e                	jne    800ebb <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e6d:	8b 0b                	mov    (%ebx),%ecx
  800e6f:	83 39 01             	cmpl   $0x1,(%ecx)
  800e72:	74 55                	je     800ec9 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e74:	8b 53 04             	mov    0x4(%ebx),%edx
  800e77:	8b 42 04             	mov    0x4(%edx),%eax
  800e7a:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e7d:	75 4a                	jne    800ec9 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e7f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e83:	74 44                	je     800ec9 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e85:	83 c0 01             	add    $0x1,%eax
  800e88:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	8b 01                	mov    (%ecx),%eax
  800e90:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e97:	50                   	push   %eax
  800e98:	8d 42 08             	lea    0x8(%edx),%eax
  800e9b:	50                   	push   %eax
  800e9c:	83 c2 04             	add    $0x4,%edx
  800e9f:	52                   	push   %edx
  800ea0:	e8 19 fb ff ff       	call   8009be <memmove>
		(*args->argc)--;
  800ea5:	8b 03                	mov    (%ebx),%eax
  800ea7:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800eaa:	8b 43 08             	mov    0x8(%ebx),%eax
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	80 38 2d             	cmpb   $0x2d,(%eax)
  800eb3:	75 06                	jne    800ebb <argnext+0x6b>
  800eb5:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eb9:	74 0e                	je     800ec9 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ebb:	8b 53 08             	mov    0x8(%ebx),%edx
  800ebe:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800ec1:	83 c2 01             	add    $0x1,%edx
  800ec4:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800ec7:	eb 13                	jmp    800edc <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800ec9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ed0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ed5:	eb 05                	jmp    800edc <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800ed7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800edc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800eeb:	8b 43 08             	mov    0x8(%ebx),%eax
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	74 58                	je     800f4a <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800ef2:	80 38 00             	cmpb   $0x0,(%eax)
  800ef5:	74 0c                	je     800f03 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800ef7:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800efa:	c7 43 08 71 21 80 00 	movl   $0x802171,0x8(%ebx)
  800f01:	eb 42                	jmp    800f45 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800f03:	8b 13                	mov    (%ebx),%edx
  800f05:	83 3a 01             	cmpl   $0x1,(%edx)
  800f08:	7e 2d                	jle    800f37 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800f0a:	8b 43 04             	mov    0x4(%ebx),%eax
  800f0d:	8b 48 04             	mov    0x4(%eax),%ecx
  800f10:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	8b 12                	mov    (%edx),%edx
  800f18:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f1f:	52                   	push   %edx
  800f20:	8d 50 08             	lea    0x8(%eax),%edx
  800f23:	52                   	push   %edx
  800f24:	83 c0 04             	add    $0x4,%eax
  800f27:	50                   	push   %eax
  800f28:	e8 91 fa ff ff       	call   8009be <memmove>
		(*args->argc)--;
  800f2d:	8b 03                	mov    (%ebx),%eax
  800f2f:	83 28 01             	subl   $0x1,(%eax)
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	eb 0e                	jmp    800f45 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800f37:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f3e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f45:	8b 43 0c             	mov    0xc(%ebx),%eax
  800f48:	eb 05                	jmp    800f4f <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800f4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 08             	sub    $0x8,%esp
  800f5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f5d:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f60:	89 d0                	mov    %edx,%eax
  800f62:	85 d2                	test   %edx,%edx
  800f64:	75 0c                	jne    800f72 <argvalue+0x1e>
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	51                   	push   %ecx
  800f6a:	e8 72 ff ff ff       	call   800ee1 <argnextvalue>
  800f6f:	83 c4 10             	add    $0x10,%esp
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f7f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f94:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	c1 ea 16             	shr    $0x16,%edx
  800fab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb2:	f6 c2 01             	test   $0x1,%dl
  800fb5:	74 11                	je     800fc8 <fd_alloc+0x2d>
  800fb7:	89 c2                	mov    %eax,%edx
  800fb9:	c1 ea 0c             	shr    $0xc,%edx
  800fbc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc3:	f6 c2 01             	test   $0x1,%dl
  800fc6:	75 09                	jne    800fd1 <fd_alloc+0x36>
			*fd_store = fd;
  800fc8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcf:	eb 17                	jmp    800fe8 <fd_alloc+0x4d>
  800fd1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fd6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fdb:	75 c9                	jne    800fa6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fdd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fe3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ff0:	83 f8 1f             	cmp    $0x1f,%eax
  800ff3:	77 36                	ja     80102b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ff5:	c1 e0 0c             	shl    $0xc,%eax
  800ff8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	c1 ea 16             	shr    $0x16,%edx
  801002:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801009:	f6 c2 01             	test   $0x1,%dl
  80100c:	74 24                	je     801032 <fd_lookup+0x48>
  80100e:	89 c2                	mov    %eax,%edx
  801010:	c1 ea 0c             	shr    $0xc,%edx
  801013:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80101a:	f6 c2 01             	test   $0x1,%dl
  80101d:	74 1a                	je     801039 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80101f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801022:	89 02                	mov    %eax,(%edx)
	return 0;
  801024:	b8 00 00 00 00       	mov    $0x0,%eax
  801029:	eb 13                	jmp    80103e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80102b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801030:	eb 0c                	jmp    80103e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801032:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801037:	eb 05                	jmp    80103e <fd_lookup+0x54>
  801039:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801049:	ba 48 25 80 00       	mov    $0x802548,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80104e:	eb 13                	jmp    801063 <dev_lookup+0x23>
  801050:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801053:	39 08                	cmp    %ecx,(%eax)
  801055:	75 0c                	jne    801063 <dev_lookup+0x23>
			*dev = devtab[i];
  801057:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80105c:	b8 00 00 00 00       	mov    $0x0,%eax
  801061:	eb 2e                	jmp    801091 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801063:	8b 02                	mov    (%edx),%eax
  801065:	85 c0                	test   %eax,%eax
  801067:	75 e7                	jne    801050 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801069:	a1 04 40 80 00       	mov    0x804004,%eax
  80106e:	8b 40 48             	mov    0x48(%eax),%eax
  801071:	83 ec 04             	sub    $0x4,%esp
  801074:	51                   	push   %ecx
  801075:	50                   	push   %eax
  801076:	68 cc 24 80 00       	push   $0x8024cc
  80107b:	e8 80 f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801089:	83 c4 10             	add    $0x10,%esp
  80108c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 10             	sub    $0x10,%esp
  80109b:	8b 75 08             	mov    0x8(%ebp),%esi
  80109e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a4:	50                   	push   %eax
  8010a5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010ab:	c1 e8 0c             	shr    $0xc,%eax
  8010ae:	50                   	push   %eax
  8010af:	e8 36 ff ff ff       	call   800fea <fd_lookup>
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 05                	js     8010c0 <fd_close+0x2d>
	    || fd != fd2)
  8010bb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8010be:	74 0c                	je     8010cc <fd_close+0x39>
		return (must_exist ? r : 0);
  8010c0:	84 db                	test   %bl,%bl
  8010c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c7:	0f 44 c2             	cmove  %edx,%eax
  8010ca:	eb 41                	jmp    80110d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d2:	50                   	push   %eax
  8010d3:	ff 36                	pushl  (%esi)
  8010d5:	e8 66 ff ff ff       	call   801040 <dev_lookup>
  8010da:	89 c3                	mov    %eax,%ebx
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 1a                	js     8010fd <fd_close+0x6a>
		if (dev->dev_close)
  8010e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	74 0b                	je     8010fd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	56                   	push   %esi
  8010f6:	ff d0                	call   *%eax
  8010f8:	89 c3                	mov    %eax,%ebx
  8010fa:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	56                   	push   %esi
  801101:	6a 00                	push   $0x0
  801103:	e8 ac fb ff ff       	call   800cb4 <sys_page_unmap>
	return r;
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	89 d8                	mov    %ebx,%eax
}
  80110d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80111a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	ff 75 08             	pushl  0x8(%ebp)
  801121:	e8 c4 fe ff ff       	call   800fea <fd_lookup>
  801126:	83 c4 08             	add    $0x8,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 10                	js     80113d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	6a 01                	push   $0x1
  801132:	ff 75 f4             	pushl  -0xc(%ebp)
  801135:	e8 59 ff ff ff       	call   801093 <fd_close>
  80113a:	83 c4 10             	add    $0x10,%esp
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <close_all>:

void
close_all(void)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	53                   	push   %ebx
  801143:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	53                   	push   %ebx
  80114f:	e8 c0 ff ff ff       	call   801114 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801154:	83 c3 01             	add    $0x1,%ebx
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	83 fb 20             	cmp    $0x20,%ebx
  80115d:	75 ec                	jne    80114b <close_all+0xc>
		close(i);
}
  80115f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 2c             	sub    $0x2c,%esp
  80116d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801170:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801173:	50                   	push   %eax
  801174:	ff 75 08             	pushl  0x8(%ebp)
  801177:	e8 6e fe ff ff       	call   800fea <fd_lookup>
  80117c:	83 c4 08             	add    $0x8,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	0f 88 c1 00 00 00    	js     801248 <dup+0xe4>
		return r;
	close(newfdnum);
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	56                   	push   %esi
  80118b:	e8 84 ff ff ff       	call   801114 <close>

	newfd = INDEX2FD(newfdnum);
  801190:	89 f3                	mov    %esi,%ebx
  801192:	c1 e3 0c             	shl    $0xc,%ebx
  801195:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80119b:	83 c4 04             	add    $0x4,%esp
  80119e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a1:	e8 de fd ff ff       	call   800f84 <fd2data>
  8011a6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8011a8:	89 1c 24             	mov    %ebx,(%esp)
  8011ab:	e8 d4 fd ff ff       	call   800f84 <fd2data>
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011b6:	89 f8                	mov    %edi,%eax
  8011b8:	c1 e8 16             	shr    $0x16,%eax
  8011bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c2:	a8 01                	test   $0x1,%al
  8011c4:	74 37                	je     8011fd <dup+0x99>
  8011c6:	89 f8                	mov    %edi,%eax
  8011c8:	c1 e8 0c             	shr    $0xc,%eax
  8011cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011d2:	f6 c2 01             	test   $0x1,%dl
  8011d5:	74 26                	je     8011fd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011de:	83 ec 0c             	sub    $0xc,%esp
  8011e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e6:	50                   	push   %eax
  8011e7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011ea:	6a 00                	push   $0x0
  8011ec:	57                   	push   %edi
  8011ed:	6a 00                	push   $0x0
  8011ef:	e8 7e fa ff ff       	call   800c72 <sys_page_map>
  8011f4:	89 c7                	mov    %eax,%edi
  8011f6:	83 c4 20             	add    $0x20,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 2e                	js     80122b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801200:	89 d0                	mov    %edx,%eax
  801202:	c1 e8 0c             	shr    $0xc,%eax
  801205:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80120c:	83 ec 0c             	sub    $0xc,%esp
  80120f:	25 07 0e 00 00       	and    $0xe07,%eax
  801214:	50                   	push   %eax
  801215:	53                   	push   %ebx
  801216:	6a 00                	push   $0x0
  801218:	52                   	push   %edx
  801219:	6a 00                	push   $0x0
  80121b:	e8 52 fa ff ff       	call   800c72 <sys_page_map>
  801220:	89 c7                	mov    %eax,%edi
  801222:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801225:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801227:	85 ff                	test   %edi,%edi
  801229:	79 1d                	jns    801248 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	53                   	push   %ebx
  80122f:	6a 00                	push   $0x0
  801231:	e8 7e fa ff ff       	call   800cb4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801236:	83 c4 08             	add    $0x8,%esp
  801239:	ff 75 d4             	pushl  -0x2c(%ebp)
  80123c:	6a 00                	push   $0x0
  80123e:	e8 71 fa ff ff       	call   800cb4 <sys_page_unmap>
	return r;
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	89 f8                	mov    %edi,%eax
}
  801248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	53                   	push   %ebx
  801254:	83 ec 14             	sub    $0x14,%esp
  801257:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	53                   	push   %ebx
  80125f:	e8 86 fd ff ff       	call   800fea <fd_lookup>
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	89 c2                	mov    %eax,%edx
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 6d                	js     8012da <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	ff 30                	pushl  (%eax)
  801279:	e8 c2 fd ff ff       	call   801040 <dev_lookup>
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 4c                	js     8012d1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801285:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801288:	8b 42 08             	mov    0x8(%edx),%eax
  80128b:	83 e0 03             	and    $0x3,%eax
  80128e:	83 f8 01             	cmp    $0x1,%eax
  801291:	75 21                	jne    8012b4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801293:	a1 04 40 80 00       	mov    0x804004,%eax
  801298:	8b 40 48             	mov    0x48(%eax),%eax
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	53                   	push   %ebx
  80129f:	50                   	push   %eax
  8012a0:	68 0d 25 80 00       	push   $0x80250d
  8012a5:	e8 56 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b2:	eb 26                	jmp    8012da <read+0x8a>
	}
	if (!dev->dev_read)
  8012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b7:	8b 40 08             	mov    0x8(%eax),%eax
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	74 17                	je     8012d5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	ff 75 10             	pushl  0x10(%ebp)
  8012c4:	ff 75 0c             	pushl  0xc(%ebp)
  8012c7:	52                   	push   %edx
  8012c8:	ff d0                	call   *%eax
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	eb 09                	jmp    8012da <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	eb 05                	jmp    8012da <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8012da:	89 d0                	mov    %edx,%eax
  8012dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 0c             	sub    $0xc,%esp
  8012ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f5:	eb 21                	jmp    801318 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	89 f0                	mov    %esi,%eax
  8012fc:	29 d8                	sub    %ebx,%eax
  8012fe:	50                   	push   %eax
  8012ff:	89 d8                	mov    %ebx,%eax
  801301:	03 45 0c             	add    0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	57                   	push   %edi
  801306:	e8 45 ff ff ff       	call   801250 <read>
		if (m < 0)
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 10                	js     801322 <readn+0x41>
			return m;
		if (m == 0)
  801312:	85 c0                	test   %eax,%eax
  801314:	74 0a                	je     801320 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801316:	01 c3                	add    %eax,%ebx
  801318:	39 f3                	cmp    %esi,%ebx
  80131a:	72 db                	jb     8012f7 <readn+0x16>
  80131c:	89 d8                	mov    %ebx,%eax
  80131e:	eb 02                	jmp    801322 <readn+0x41>
  801320:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5f                   	pop    %edi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	53                   	push   %ebx
  80132e:	83 ec 14             	sub    $0x14,%esp
  801331:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801334:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	53                   	push   %ebx
  801339:	e8 ac fc ff ff       	call   800fea <fd_lookup>
  80133e:	83 c4 08             	add    $0x8,%esp
  801341:	89 c2                	mov    %eax,%edx
  801343:	85 c0                	test   %eax,%eax
  801345:	78 68                	js     8013af <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801351:	ff 30                	pushl  (%eax)
  801353:	e8 e8 fc ff ff       	call   801040 <dev_lookup>
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 47                	js     8013a6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801362:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801366:	75 21                	jne    801389 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801368:	a1 04 40 80 00       	mov    0x804004,%eax
  80136d:	8b 40 48             	mov    0x48(%eax),%eax
  801370:	83 ec 04             	sub    $0x4,%esp
  801373:	53                   	push   %ebx
  801374:	50                   	push   %eax
  801375:	68 29 25 80 00       	push   $0x802529
  80137a:	e8 81 ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801387:	eb 26                	jmp    8013af <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801389:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138c:	8b 52 0c             	mov    0xc(%edx),%edx
  80138f:	85 d2                	test   %edx,%edx
  801391:	74 17                	je     8013aa <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	ff 75 10             	pushl  0x10(%ebp)
  801399:	ff 75 0c             	pushl  0xc(%ebp)
  80139c:	50                   	push   %eax
  80139d:	ff d2                	call   *%edx
  80139f:	89 c2                	mov    %eax,%edx
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	eb 09                	jmp    8013af <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	eb 05                	jmp    8013af <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8013af:	89 d0                	mov    %edx,%eax
  8013b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 75 08             	pushl  0x8(%ebp)
  8013c3:	e8 22 fc ff ff       	call   800fea <fd_lookup>
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 0e                	js     8013dd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    

008013df <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 14             	sub    $0x14,%esp
  8013e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	53                   	push   %ebx
  8013ee:	e8 f7 fb ff ff       	call   800fea <fd_lookup>
  8013f3:	83 c4 08             	add    $0x8,%esp
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 65                	js     801461 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801406:	ff 30                	pushl  (%eax)
  801408:	e8 33 fc ff ff       	call   801040 <dev_lookup>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 44                	js     801458 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801414:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801417:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80141b:	75 21                	jne    80143e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80141d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801422:	8b 40 48             	mov    0x48(%eax),%eax
  801425:	83 ec 04             	sub    $0x4,%esp
  801428:	53                   	push   %ebx
  801429:	50                   	push   %eax
  80142a:	68 ec 24 80 00       	push   $0x8024ec
  80142f:	e8 cc ed ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143c:	eb 23                	jmp    801461 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80143e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801441:	8b 52 18             	mov    0x18(%edx),%edx
  801444:	85 d2                	test   %edx,%edx
  801446:	74 14                	je     80145c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	ff 75 0c             	pushl  0xc(%ebp)
  80144e:	50                   	push   %eax
  80144f:	ff d2                	call   *%edx
  801451:	89 c2                	mov    %eax,%edx
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	eb 09                	jmp    801461 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801458:	89 c2                	mov    %eax,%edx
  80145a:	eb 05                	jmp    801461 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80145c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801461:	89 d0                	mov    %edx,%eax
  801463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 14             	sub    $0x14,%esp
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	ff 75 08             	pushl  0x8(%ebp)
  801479:	e8 6c fb ff ff       	call   800fea <fd_lookup>
  80147e:	83 c4 08             	add    $0x8,%esp
  801481:	89 c2                	mov    %eax,%edx
  801483:	85 c0                	test   %eax,%eax
  801485:	78 58                	js     8014df <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	ff 30                	pushl  (%eax)
  801493:	e8 a8 fb ff ff       	call   801040 <dev_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 37                	js     8014d6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80149f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014a6:	74 32                	je     8014da <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014a8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014ab:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014b2:	00 00 00 
	stat->st_isdir = 0;
  8014b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014bc:	00 00 00 
	stat->st_dev = dev;
  8014bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	53                   	push   %ebx
  8014c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8014cc:	ff 50 14             	call   *0x14(%eax)
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	eb 09                	jmp    8014df <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	eb 05                	jmp    8014df <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014df:	89 d0                	mov    %edx,%eax
  8014e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	6a 00                	push   $0x0
  8014f0:	ff 75 08             	pushl  0x8(%ebp)
  8014f3:	e8 b7 01 00 00       	call   8016af <open>
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 1b                	js     80151c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	50                   	push   %eax
  801508:	e8 5b ff ff ff       	call   801468 <fstat>
  80150d:	89 c6                	mov    %eax,%esi
	close(fd);
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	e8 fd fb ff ff       	call   801114 <close>
	return r;
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	89 f0                	mov    %esi,%eax
}
  80151c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151f:	5b                   	pop    %ebx
  801520:	5e                   	pop    %esi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	89 c6                	mov    %eax,%esi
  80152a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80152c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801533:	75 12                	jne    801547 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	6a 01                	push   $0x1
  80153a:	e8 12 09 00 00       	call   801e51 <ipc_find_env>
  80153f:	a3 00 40 80 00       	mov    %eax,0x804000
  801544:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801547:	6a 07                	push   $0x7
  801549:	68 00 50 80 00       	push   $0x805000
  80154e:	56                   	push   %esi
  80154f:	ff 35 00 40 80 00    	pushl  0x804000
  801555:	e8 a3 08 00 00       	call   801dfd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80155a:	83 c4 0c             	add    $0xc,%esp
  80155d:	6a 00                	push   $0x0
  80155f:	53                   	push   %ebx
  801560:	6a 00                	push   $0x0
  801562:	e8 21 08 00 00       	call   801d88 <ipc_recv>
}
  801567:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801574:	8b 45 08             	mov    0x8(%ebp),%eax
  801577:	8b 40 0c             	mov    0xc(%eax),%eax
  80157a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80157f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801582:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801587:	ba 00 00 00 00       	mov    $0x0,%edx
  80158c:	b8 02 00 00 00       	mov    $0x2,%eax
  801591:	e8 8d ff ff ff       	call   801523 <fsipc>
}
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80159e:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8015b3:	e8 6b ff ff ff       	call   801523 <fsipc>
}
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ca:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d9:	e8 45 ff ff ff       	call   801523 <fsipc>
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 2c                	js     80160e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	68 00 50 80 00       	push   $0x805000
  8015ea:	53                   	push   %ebx
  8015eb:	e8 3c f2 ff ff       	call   80082c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015f0:	a1 80 50 80 00       	mov    0x805080,%eax
  8015f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015fb:	a1 84 50 80 00       	mov    0x805084,%eax
  801600:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    

00801613 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801619:	68 58 25 80 00       	push   $0x802558
  80161e:	68 90 00 00 00       	push   $0x90
  801623:	68 76 25 80 00       	push   $0x802576
  801628:	e8 15 07 00 00       	call   801d42 <_panic>

0080162d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801635:	8b 45 08             	mov    0x8(%ebp),%eax
  801638:	8b 40 0c             	mov    0xc(%eax),%eax
  80163b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801640:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801646:	ba 00 00 00 00       	mov    $0x0,%edx
  80164b:	b8 03 00 00 00       	mov    $0x3,%eax
  801650:	e8 ce fe ff ff       	call   801523 <fsipc>
  801655:	89 c3                	mov    %eax,%ebx
  801657:	85 c0                	test   %eax,%eax
  801659:	78 4b                	js     8016a6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80165b:	39 c6                	cmp    %eax,%esi
  80165d:	73 16                	jae    801675 <devfile_read+0x48>
  80165f:	68 81 25 80 00       	push   $0x802581
  801664:	68 88 25 80 00       	push   $0x802588
  801669:	6a 7c                	push   $0x7c
  80166b:	68 76 25 80 00       	push   $0x802576
  801670:	e8 cd 06 00 00       	call   801d42 <_panic>
	assert(r <= PGSIZE);
  801675:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80167a:	7e 16                	jle    801692 <devfile_read+0x65>
  80167c:	68 9d 25 80 00       	push   $0x80259d
  801681:	68 88 25 80 00       	push   $0x802588
  801686:	6a 7d                	push   $0x7d
  801688:	68 76 25 80 00       	push   $0x802576
  80168d:	e8 b0 06 00 00       	call   801d42 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	50                   	push   %eax
  801696:	68 00 50 80 00       	push   $0x805000
  80169b:	ff 75 0c             	pushl  0xc(%ebp)
  80169e:	e8 1b f3 ff ff       	call   8009be <memmove>
	return r;
  8016a3:	83 c4 10             	add    $0x10,%esp
}
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 20             	sub    $0x20,%esp
  8016b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016b9:	53                   	push   %ebx
  8016ba:	e8 34 f1 ff ff       	call   8007f3 <strlen>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016c7:	7f 67                	jg     801730 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	e8 c6 f8 ff ff       	call   800f9b <fd_alloc>
  8016d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8016d8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 57                	js     801735 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	68 00 50 80 00       	push   $0x805000
  8016e7:	e8 40 f1 ff ff       	call   80082c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8016fc:	e8 22 fe ff ff       	call   801523 <fsipc>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	79 14                	jns    80171e <open+0x6f>
		fd_close(fd, 0);
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	6a 00                	push   $0x0
  80170f:	ff 75 f4             	pushl  -0xc(%ebp)
  801712:	e8 7c f9 ff ff       	call   801093 <fd_close>
		return r;
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	89 da                	mov    %ebx,%edx
  80171c:	eb 17                	jmp    801735 <open+0x86>
	}

	return fd2num(fd);
  80171e:	83 ec 0c             	sub    $0xc,%esp
  801721:	ff 75 f4             	pushl  -0xc(%ebp)
  801724:	e8 4b f8 ff ff       	call   800f74 <fd2num>
  801729:	89 c2                	mov    %eax,%edx
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	eb 05                	jmp    801735 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801730:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801735:	89 d0                	mov    %edx,%eax
  801737:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801742:	ba 00 00 00 00       	mov    $0x0,%edx
  801747:	b8 08 00 00 00       	mov    $0x8,%eax
  80174c:	e8 d2 fd ff ff       	call   801523 <fsipc>
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801753:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801757:	7e 37                	jle    801790 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	53                   	push   %ebx
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801762:	ff 70 04             	pushl  0x4(%eax)
  801765:	8d 40 10             	lea    0x10(%eax),%eax
  801768:	50                   	push   %eax
  801769:	ff 33                	pushl  (%ebx)
  80176b:	e8 ba fb ff ff       	call   80132a <write>
		if (result > 0)
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	7e 03                	jle    80177a <writebuf+0x27>
			b->result += result;
  801777:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80177a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80177d:	74 0d                	je     80178c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80177f:	85 c0                	test   %eax,%eax
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
  801786:	0f 4f c2             	cmovg  %edx,%eax
  801789:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80178c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178f:	c9                   	leave  
  801790:	f3 c3                	repz ret 

00801792 <putch>:

static void
putch(int ch, void *thunk)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	53                   	push   %ebx
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80179c:	8b 53 04             	mov    0x4(%ebx),%edx
  80179f:	8d 42 01             	lea    0x1(%edx),%eax
  8017a2:	89 43 04             	mov    %eax,0x4(%ebx)
  8017a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a8:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017ac:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017b1:	75 0e                	jne    8017c1 <putch+0x2f>
		writebuf(b);
  8017b3:	89 d8                	mov    %ebx,%eax
  8017b5:	e8 99 ff ff ff       	call   801753 <writebuf>
		b->idx = 0;
  8017ba:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017c1:	83 c4 04             	add    $0x4,%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017d9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017e0:	00 00 00 
	b.result = 0;
  8017e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017ea:	00 00 00 
	b.error = 1;
  8017ed:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017f4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017f7:	ff 75 10             	pushl  0x10(%ebp)
  8017fa:	ff 75 0c             	pushl  0xc(%ebp)
  8017fd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801803:	50                   	push   %eax
  801804:	68 92 17 80 00       	push   $0x801792
  801809:	e8 ef ea ff ff       	call   8002fd <vprintfmt>
	if (b.idx > 0)
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801818:	7e 0b                	jle    801825 <vfprintf+0x5e>
		writebuf(&b);
  80181a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801820:	e8 2e ff ff ff       	call   801753 <writebuf>

	return (b.result ? b.result : b.error);
  801825:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80182b:	85 c0                	test   %eax,%eax
  80182d:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80183c:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80183f:	50                   	push   %eax
  801840:	ff 75 0c             	pushl  0xc(%ebp)
  801843:	ff 75 08             	pushl  0x8(%ebp)
  801846:	e8 7c ff ff ff       	call   8017c7 <vfprintf>
	va_end(ap);

	return cnt;
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <printf>:

int
printf(const char *fmt, ...)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801853:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801856:	50                   	push   %eax
  801857:	ff 75 08             	pushl  0x8(%ebp)
  80185a:	6a 01                	push   $0x1
  80185c:	e8 66 ff ff ff       	call   8017c7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80186b:	83 ec 0c             	sub    $0xc,%esp
  80186e:	ff 75 08             	pushl  0x8(%ebp)
  801871:	e8 0e f7 ff ff       	call   800f84 <fd2data>
  801876:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801878:	83 c4 08             	add    $0x8,%esp
  80187b:	68 a9 25 80 00       	push   $0x8025a9
  801880:	53                   	push   %ebx
  801881:	e8 a6 ef ff ff       	call   80082c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801886:	8b 46 04             	mov    0x4(%esi),%eax
  801889:	2b 06                	sub    (%esi),%eax
  80188b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801891:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801898:	00 00 00 
	stat->st_dev = &devpipe;
  80189b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018a2:	30 80 00 
	return 0;
}
  8018a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 0c             	sub    $0xc,%esp
  8018b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018bb:	53                   	push   %ebx
  8018bc:	6a 00                	push   $0x0
  8018be:	e8 f1 f3 ff ff       	call   800cb4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018c3:	89 1c 24             	mov    %ebx,(%esp)
  8018c6:	e8 b9 f6 ff ff       	call   800f84 <fd2data>
  8018cb:	83 c4 08             	add    $0x8,%esp
  8018ce:	50                   	push   %eax
  8018cf:	6a 00                	push   $0x0
  8018d1:	e8 de f3 ff ff       	call   800cb4 <sys_page_unmap>
}
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	57                   	push   %edi
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 1c             	sub    $0x1c,%esp
  8018e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018e7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ee:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018f7:	e8 8e 05 00 00       	call   801e8a <pageref>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	89 3c 24             	mov    %edi,(%esp)
  801901:	e8 84 05 00 00       	call   801e8a <pageref>
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	39 c3                	cmp    %eax,%ebx
  80190b:	0f 94 c1             	sete   %cl
  80190e:	0f b6 c9             	movzbl %cl,%ecx
  801911:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801914:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80191a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80191d:	39 ce                	cmp    %ecx,%esi
  80191f:	74 1b                	je     80193c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801921:	39 c3                	cmp    %eax,%ebx
  801923:	75 c4                	jne    8018e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801925:	8b 42 58             	mov    0x58(%edx),%eax
  801928:	ff 75 e4             	pushl  -0x1c(%ebp)
  80192b:	50                   	push   %eax
  80192c:	56                   	push   %esi
  80192d:	68 b0 25 80 00       	push   $0x8025b0
  801932:	e8 c9 e8 ff ff       	call   800200 <cprintf>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	eb ad                	jmp    8018e9 <_pipeisclosed+0xe>
	}
}
  80193c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5f                   	pop    %edi
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	57                   	push   %edi
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	83 ec 28             	sub    $0x28,%esp
  801950:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801953:	56                   	push   %esi
  801954:	e8 2b f6 ff ff       	call   800f84 <fd2data>
  801959:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	bf 00 00 00 00       	mov    $0x0,%edi
  801963:	eb 4b                	jmp    8019b0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801965:	89 da                	mov    %ebx,%edx
  801967:	89 f0                	mov    %esi,%eax
  801969:	e8 6d ff ff ff       	call   8018db <_pipeisclosed>
  80196e:	85 c0                	test   %eax,%eax
  801970:	75 48                	jne    8019ba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801972:	e8 99 f2 ff ff       	call   800c10 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801977:	8b 43 04             	mov    0x4(%ebx),%eax
  80197a:	8b 0b                	mov    (%ebx),%ecx
  80197c:	8d 51 20             	lea    0x20(%ecx),%edx
  80197f:	39 d0                	cmp    %edx,%eax
  801981:	73 e2                	jae    801965 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801983:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801986:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80198a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80198d:	89 c2                	mov    %eax,%edx
  80198f:	c1 fa 1f             	sar    $0x1f,%edx
  801992:	89 d1                	mov    %edx,%ecx
  801994:	c1 e9 1b             	shr    $0x1b,%ecx
  801997:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80199a:	83 e2 1f             	and    $0x1f,%edx
  80199d:	29 ca                	sub    %ecx,%edx
  80199f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019a3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019a7:	83 c0 01             	add    $0x1,%eax
  8019aa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ad:	83 c7 01             	add    $0x1,%edi
  8019b0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019b3:	75 c2                	jne    801977 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b8:	eb 05                	jmp    8019bf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c2:	5b                   	pop    %ebx
  8019c3:	5e                   	pop    %esi
  8019c4:	5f                   	pop    %edi
  8019c5:	5d                   	pop    %ebp
  8019c6:	c3                   	ret    

008019c7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	57                   	push   %edi
  8019cb:	56                   	push   %esi
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 18             	sub    $0x18,%esp
  8019d0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019d3:	57                   	push   %edi
  8019d4:	e8 ab f5 ff ff       	call   800f84 <fd2data>
  8019d9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e3:	eb 3d                	jmp    801a22 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019e5:	85 db                	test   %ebx,%ebx
  8019e7:	74 04                	je     8019ed <devpipe_read+0x26>
				return i;
  8019e9:	89 d8                	mov    %ebx,%eax
  8019eb:	eb 44                	jmp    801a31 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019ed:	89 f2                	mov    %esi,%edx
  8019ef:	89 f8                	mov    %edi,%eax
  8019f1:	e8 e5 fe ff ff       	call   8018db <_pipeisclosed>
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	75 32                	jne    801a2c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019fa:	e8 11 f2 ff ff       	call   800c10 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019ff:	8b 06                	mov    (%esi),%eax
  801a01:	3b 46 04             	cmp    0x4(%esi),%eax
  801a04:	74 df                	je     8019e5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a06:	99                   	cltd   
  801a07:	c1 ea 1b             	shr    $0x1b,%edx
  801a0a:	01 d0                	add    %edx,%eax
  801a0c:	83 e0 1f             	and    $0x1f,%eax
  801a0f:	29 d0                	sub    %edx,%eax
  801a11:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a19:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a1c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1f:	83 c3 01             	add    $0x1,%ebx
  801a22:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a25:	75 d8                	jne    8019ff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a27:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2a:	eb 05                	jmp    801a31 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5f                   	pop    %edi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	e8 51 f5 ff ff       	call   800f9b <fd_alloc>
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	89 c2                	mov    %eax,%edx
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	0f 88 2c 01 00 00    	js     801b83 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a57:	83 ec 04             	sub    $0x4,%esp
  801a5a:	68 07 04 00 00       	push   $0x407
  801a5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a62:	6a 00                	push   $0x0
  801a64:	e8 c6 f1 ff ff       	call   800c2f <sys_page_alloc>
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	0f 88 0d 01 00 00    	js     801b83 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a7c:	50                   	push   %eax
  801a7d:	e8 19 f5 ff ff       	call   800f9b <fd_alloc>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	0f 88 e2 00 00 00    	js     801b71 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8f:	83 ec 04             	sub    $0x4,%esp
  801a92:	68 07 04 00 00       	push   $0x407
  801a97:	ff 75 f0             	pushl  -0x10(%ebp)
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 8e f1 ff ff       	call   800c2f <sys_page_alloc>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	0f 88 c3 00 00 00    	js     801b71 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab4:	e8 cb f4 ff ff       	call   800f84 <fd2data>
  801ab9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abb:	83 c4 0c             	add    $0xc,%esp
  801abe:	68 07 04 00 00       	push   $0x407
  801ac3:	50                   	push   %eax
  801ac4:	6a 00                	push   $0x0
  801ac6:	e8 64 f1 ff ff       	call   800c2f <sys_page_alloc>
  801acb:	89 c3                	mov    %eax,%ebx
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	0f 88 89 00 00 00    	js     801b61 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ade:	e8 a1 f4 ff ff       	call   800f84 <fd2data>
  801ae3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aea:	50                   	push   %eax
  801aeb:	6a 00                	push   $0x0
  801aed:	56                   	push   %esi
  801aee:	6a 00                	push   $0x0
  801af0:	e8 7d f1 ff ff       	call   800c72 <sys_page_map>
  801af5:	89 c3                	mov    %eax,%ebx
  801af7:	83 c4 20             	add    $0x20,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 55                	js     801b53 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801afe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b07:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b21:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2e:	e8 41 f4 ff ff       	call   800f74 <fd2num>
  801b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b36:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b38:	83 c4 04             	add    $0x4,%esp
  801b3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3e:	e8 31 f4 ff ff       	call   800f74 <fd2num>
  801b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b46:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b51:	eb 30                	jmp    801b83 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	56                   	push   %esi
  801b57:	6a 00                	push   $0x0
  801b59:	e8 56 f1 ff ff       	call   800cb4 <sys_page_unmap>
  801b5e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b61:	83 ec 08             	sub    $0x8,%esp
  801b64:	ff 75 f0             	pushl  -0x10(%ebp)
  801b67:	6a 00                	push   $0x0
  801b69:	e8 46 f1 ff ff       	call   800cb4 <sys_page_unmap>
  801b6e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b71:	83 ec 08             	sub    $0x8,%esp
  801b74:	ff 75 f4             	pushl  -0xc(%ebp)
  801b77:	6a 00                	push   $0x0
  801b79:	e8 36 f1 ff ff       	call   800cb4 <sys_page_unmap>
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b83:	89 d0                	mov    %edx,%eax
  801b85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5e                   	pop    %esi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b95:	50                   	push   %eax
  801b96:	ff 75 08             	pushl  0x8(%ebp)
  801b99:	e8 4c f4 ff ff       	call   800fea <fd_lookup>
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 18                	js     801bbd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ba5:	83 ec 0c             	sub    $0xc,%esp
  801ba8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bab:	e8 d4 f3 ff ff       	call   800f84 <fd2data>
	return _pipeisclosed(fd, p);
  801bb0:	89 c2                	mov    %eax,%edx
  801bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb5:	e8 21 fd ff ff       	call   8018db <_pipeisclosed>
  801bba:	83 c4 10             	add    $0x10,%esp
}
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    

00801bbf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bcf:	68 c8 25 80 00       	push   $0x8025c8
  801bd4:	ff 75 0c             	pushl  0xc(%ebp)
  801bd7:	e8 50 ec ff ff       	call   80082c <strcpy>
	return 0;
}
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	57                   	push   %edi
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bf4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bfa:	eb 2d                	jmp    801c29 <devcons_write+0x46>
		m = n - tot;
  801bfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bff:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c01:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c04:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c09:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	53                   	push   %ebx
  801c10:	03 45 0c             	add    0xc(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	57                   	push   %edi
  801c15:	e8 a4 ed ff ff       	call   8009be <memmove>
		sys_cputs(buf, m);
  801c1a:	83 c4 08             	add    $0x8,%esp
  801c1d:	53                   	push   %ebx
  801c1e:	57                   	push   %edi
  801c1f:	e8 4f ef ff ff       	call   800b73 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c24:	01 de                	add    %ebx,%esi
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	89 f0                	mov    %esi,%eax
  801c2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c2e:	72 cc                	jb     801bfc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 08             	sub    $0x8,%esp
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c47:	74 2a                	je     801c73 <devcons_read+0x3b>
  801c49:	eb 05                	jmp    801c50 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c4b:	e8 c0 ef ff ff       	call   800c10 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c50:	e8 3c ef ff ff       	call   800b91 <sys_cgetc>
  801c55:	85 c0                	test   %eax,%eax
  801c57:	74 f2                	je     801c4b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 16                	js     801c73 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c5d:	83 f8 04             	cmp    $0x4,%eax
  801c60:	74 0c                	je     801c6e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c65:	88 02                	mov    %al,(%edx)
	return 1;
  801c67:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6c:	eb 05                	jmp    801c73 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c81:	6a 01                	push   $0x1
  801c83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c86:	50                   	push   %eax
  801c87:	e8 e7 ee ff ff       	call   800b73 <sys_cputs>
}
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <getchar>:

int
getchar(void)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c97:	6a 01                	push   $0x1
  801c99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c9c:	50                   	push   %eax
  801c9d:	6a 00                	push   $0x0
  801c9f:	e8 ac f5 ff ff       	call   801250 <read>
	if (r < 0)
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	78 0f                	js     801cba <getchar+0x29>
		return r;
	if (r < 1)
  801cab:	85 c0                	test   %eax,%eax
  801cad:	7e 06                	jle    801cb5 <getchar+0x24>
		return -E_EOF;
	return c;
  801caf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cb3:	eb 05                	jmp    801cba <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cb5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc5:	50                   	push   %eax
  801cc6:	ff 75 08             	pushl  0x8(%ebp)
  801cc9:	e8 1c f3 ff ff       	call   800fea <fd_lookup>
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	78 11                	js     801ce6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cde:	39 10                	cmp    %edx,(%eax)
  801ce0:	0f 94 c0             	sete   %al
  801ce3:	0f b6 c0             	movzbl %al,%eax
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <opencons>:

int
opencons(void)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf1:	50                   	push   %eax
  801cf2:	e8 a4 f2 ff ff       	call   800f9b <fd_alloc>
  801cf7:	83 c4 10             	add    $0x10,%esp
		return r;
  801cfa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 3e                	js     801d3e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d00:	83 ec 04             	sub    $0x4,%esp
  801d03:	68 07 04 00 00       	push   $0x407
  801d08:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 1d ef ff ff       	call   800c2f <sys_page_alloc>
  801d12:	83 c4 10             	add    $0x10,%esp
		return r;
  801d15:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 23                	js     801d3e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d1b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d24:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d29:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d30:	83 ec 0c             	sub    $0xc,%esp
  801d33:	50                   	push   %eax
  801d34:	e8 3b f2 ff ff       	call   800f74 <fd2num>
  801d39:	89 c2                	mov    %eax,%edx
  801d3b:	83 c4 10             	add    $0x10,%esp
}
  801d3e:	89 d0                	mov    %edx,%eax
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d47:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d4a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d50:	e8 9c ee ff ff       	call   800bf1 <sys_getenvid>
  801d55:	83 ec 0c             	sub    $0xc,%esp
  801d58:	ff 75 0c             	pushl  0xc(%ebp)
  801d5b:	ff 75 08             	pushl  0x8(%ebp)
  801d5e:	56                   	push   %esi
  801d5f:	50                   	push   %eax
  801d60:	68 d4 25 80 00       	push   $0x8025d4
  801d65:	e8 96 e4 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d6a:	83 c4 18             	add    $0x18,%esp
  801d6d:	53                   	push   %ebx
  801d6e:	ff 75 10             	pushl  0x10(%ebp)
  801d71:	e8 39 e4 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801d76:	c7 04 24 70 21 80 00 	movl   $0x802170,(%esp)
  801d7d:	e8 7e e4 ff ff       	call   800200 <cprintf>
  801d82:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d85:	cc                   	int3   
  801d86:	eb fd                	jmp    801d85 <_panic+0x43>

00801d88 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	56                   	push   %esi
  801d8c:	53                   	push   %ebx
  801d8d:	8b 75 08             	mov    0x8(%ebp),%esi
  801d90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801d96:	85 c0                	test   %eax,%eax
  801d98:	74 0e                	je     801da8 <ipc_recv+0x20>
  801d9a:	83 ec 0c             	sub    $0xc,%esp
  801d9d:	50                   	push   %eax
  801d9e:	e8 3c f0 ff ff       	call   800ddf <sys_ipc_recv>
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	eb 10                	jmp    801db8 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	68 00 00 c0 ee       	push   $0xeec00000
  801db0:	e8 2a f0 ff ff       	call   800ddf <sys_ipc_recv>
  801db5:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801db8:	85 c0                	test   %eax,%eax
  801dba:	74 16                	je     801dd2 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801dbc:	85 f6                	test   %esi,%esi
  801dbe:	74 06                	je     801dc6 <ipc_recv+0x3e>
  801dc0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801dc6:	85 db                	test   %ebx,%ebx
  801dc8:	74 2c                	je     801df6 <ipc_recv+0x6e>
  801dca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801dd0:	eb 24                	jmp    801df6 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801dd2:	85 f6                	test   %esi,%esi
  801dd4:	74 0a                	je     801de0 <ipc_recv+0x58>
  801dd6:	a1 04 40 80 00       	mov    0x804004,%eax
  801ddb:	8b 40 74             	mov    0x74(%eax),%eax
  801dde:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801de0:	85 db                	test   %ebx,%ebx
  801de2:	74 0a                	je     801dee <ipc_recv+0x66>
  801de4:	a1 04 40 80 00       	mov    0x804004,%eax
  801de9:	8b 40 78             	mov    0x78(%eax),%eax
  801dec:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801dee:	a1 04 40 80 00       	mov    0x804004,%eax
  801df3:	8b 40 70             	mov    0x70(%eax),%eax
}
  801df6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801df9:	5b                   	pop    %ebx
  801dfa:	5e                   	pop    %esi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	57                   	push   %edi
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e09:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801e16:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801e19:	ff 75 14             	pushl  0x14(%ebp)
  801e1c:	53                   	push   %ebx
  801e1d:	56                   	push   %esi
  801e1e:	57                   	push   %edi
  801e1f:	e8 98 ef ff ff       	call   800dbc <sys_ipc_try_send>
		if (ret == 0) break;
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	85 c0                	test   %eax,%eax
  801e29:	74 1e                	je     801e49 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801e2b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e2e:	74 12                	je     801e42 <ipc_send+0x45>
  801e30:	50                   	push   %eax
  801e31:	68 f8 25 80 00       	push   $0x8025f8
  801e36:	6a 39                	push   $0x39
  801e38:	68 05 26 80 00       	push   $0x802605
  801e3d:	e8 00 ff ff ff       	call   801d42 <_panic>
		sys_yield();
  801e42:	e8 c9 ed ff ff       	call   800c10 <sys_yield>
	}
  801e47:	eb d0                	jmp    801e19 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4c:	5b                   	pop    %ebx
  801e4d:	5e                   	pop    %esi
  801e4e:	5f                   	pop    %edi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e57:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e5c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e5f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e65:	8b 52 50             	mov    0x50(%edx),%edx
  801e68:	39 ca                	cmp    %ecx,%edx
  801e6a:	75 0d                	jne    801e79 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e6c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e6f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e74:	8b 40 48             	mov    0x48(%eax),%eax
  801e77:	eb 0f                	jmp    801e88 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e79:	83 c0 01             	add    $0x1,%eax
  801e7c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e81:	75 d9                	jne    801e5c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    

00801e8a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e90:	89 d0                	mov    %edx,%eax
  801e92:	c1 e8 16             	shr    $0x16,%eax
  801e95:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ea1:	f6 c1 01             	test   $0x1,%cl
  801ea4:	74 1d                	je     801ec3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ea6:	c1 ea 0c             	shr    $0xc,%edx
  801ea9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801eb0:	f6 c2 01             	test   $0x1,%dl
  801eb3:	74 0e                	je     801ec3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801eb5:	c1 ea 0c             	shr    $0xc,%edx
  801eb8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ebf:	ef 
  801ec0:	0f b7 c0             	movzwl %ax,%eax
}
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	66 90                	xchg   %ax,%ax
  801ec7:	66 90                	xchg   %ax,%ax
  801ec9:	66 90                	xchg   %ax,%ax
  801ecb:	66 90                	xchg   %ax,%ax
  801ecd:	66 90                	xchg   %ax,%ax
  801ecf:	90                   	nop

00801ed0 <__udivdi3>:
  801ed0:	55                   	push   %ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
  801ed7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801edb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801edf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ee7:	85 f6                	test   %esi,%esi
  801ee9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eed:	89 ca                	mov    %ecx,%edx
  801eef:	89 f8                	mov    %edi,%eax
  801ef1:	75 3d                	jne    801f30 <__udivdi3+0x60>
  801ef3:	39 cf                	cmp    %ecx,%edi
  801ef5:	0f 87 c5 00 00 00    	ja     801fc0 <__udivdi3+0xf0>
  801efb:	85 ff                	test   %edi,%edi
  801efd:	89 fd                	mov    %edi,%ebp
  801eff:	75 0b                	jne    801f0c <__udivdi3+0x3c>
  801f01:	b8 01 00 00 00       	mov    $0x1,%eax
  801f06:	31 d2                	xor    %edx,%edx
  801f08:	f7 f7                	div    %edi
  801f0a:	89 c5                	mov    %eax,%ebp
  801f0c:	89 c8                	mov    %ecx,%eax
  801f0e:	31 d2                	xor    %edx,%edx
  801f10:	f7 f5                	div    %ebp
  801f12:	89 c1                	mov    %eax,%ecx
  801f14:	89 d8                	mov    %ebx,%eax
  801f16:	89 cf                	mov    %ecx,%edi
  801f18:	f7 f5                	div    %ebp
  801f1a:	89 c3                	mov    %eax,%ebx
  801f1c:	89 d8                	mov    %ebx,%eax
  801f1e:	89 fa                	mov    %edi,%edx
  801f20:	83 c4 1c             	add    $0x1c,%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
  801f28:	90                   	nop
  801f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f30:	39 ce                	cmp    %ecx,%esi
  801f32:	77 74                	ja     801fa8 <__udivdi3+0xd8>
  801f34:	0f bd fe             	bsr    %esi,%edi
  801f37:	83 f7 1f             	xor    $0x1f,%edi
  801f3a:	0f 84 98 00 00 00    	je     801fd8 <__udivdi3+0x108>
  801f40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	89 c5                	mov    %eax,%ebp
  801f49:	29 fb                	sub    %edi,%ebx
  801f4b:	d3 e6                	shl    %cl,%esi
  801f4d:	89 d9                	mov    %ebx,%ecx
  801f4f:	d3 ed                	shr    %cl,%ebp
  801f51:	89 f9                	mov    %edi,%ecx
  801f53:	d3 e0                	shl    %cl,%eax
  801f55:	09 ee                	or     %ebp,%esi
  801f57:	89 d9                	mov    %ebx,%ecx
  801f59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5d:	89 d5                	mov    %edx,%ebp
  801f5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f63:	d3 ed                	shr    %cl,%ebp
  801f65:	89 f9                	mov    %edi,%ecx
  801f67:	d3 e2                	shl    %cl,%edx
  801f69:	89 d9                	mov    %ebx,%ecx
  801f6b:	d3 e8                	shr    %cl,%eax
  801f6d:	09 c2                	or     %eax,%edx
  801f6f:	89 d0                	mov    %edx,%eax
  801f71:	89 ea                	mov    %ebp,%edx
  801f73:	f7 f6                	div    %esi
  801f75:	89 d5                	mov    %edx,%ebp
  801f77:	89 c3                	mov    %eax,%ebx
  801f79:	f7 64 24 0c          	mull   0xc(%esp)
  801f7d:	39 d5                	cmp    %edx,%ebp
  801f7f:	72 10                	jb     801f91 <__udivdi3+0xc1>
  801f81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	d3 e6                	shl    %cl,%esi
  801f89:	39 c6                	cmp    %eax,%esi
  801f8b:	73 07                	jae    801f94 <__udivdi3+0xc4>
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	75 03                	jne    801f94 <__udivdi3+0xc4>
  801f91:	83 eb 01             	sub    $0x1,%ebx
  801f94:	31 ff                	xor    %edi,%edi
  801f96:	89 d8                	mov    %ebx,%eax
  801f98:	89 fa                	mov    %edi,%edx
  801f9a:	83 c4 1c             	add    $0x1c,%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    
  801fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fa8:	31 ff                	xor    %edi,%edi
  801faa:	31 db                	xor    %ebx,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	89 d8                	mov    %ebx,%eax
  801fc2:	f7 f7                	div    %edi
  801fc4:	31 ff                	xor    %edi,%edi
  801fc6:	89 c3                	mov    %eax,%ebx
  801fc8:	89 d8                	mov    %ebx,%eax
  801fca:	89 fa                	mov    %edi,%edx
  801fcc:	83 c4 1c             	add    $0x1c,%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5f                   	pop    %edi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
  801fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	39 ce                	cmp    %ecx,%esi
  801fda:	72 0c                	jb     801fe8 <__udivdi3+0x118>
  801fdc:	31 db                	xor    %ebx,%ebx
  801fde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fe2:	0f 87 34 ff ff ff    	ja     801f1c <__udivdi3+0x4c>
  801fe8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fed:	e9 2a ff ff ff       	jmp    801f1c <__udivdi3+0x4c>
  801ff2:	66 90                	xchg   %ax,%ax
  801ff4:	66 90                	xchg   %ax,%ax
  801ff6:	66 90                	xchg   %ax,%ax
  801ff8:	66 90                	xchg   %ax,%ax
  801ffa:	66 90                	xchg   %ax,%ax
  801ffc:	66 90                	xchg   %ax,%ax
  801ffe:	66 90                	xchg   %ax,%ax

00802000 <__umoddi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80200b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80200f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802017:	85 d2                	test   %edx,%edx
  802019:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80201d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802021:	89 f3                	mov    %esi,%ebx
  802023:	89 3c 24             	mov    %edi,(%esp)
  802026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80202a:	75 1c                	jne    802048 <__umoddi3+0x48>
  80202c:	39 f7                	cmp    %esi,%edi
  80202e:	76 50                	jbe    802080 <__umoddi3+0x80>
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	f7 f7                	div    %edi
  802036:	89 d0                	mov    %edx,%eax
  802038:	31 d2                	xor    %edx,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	39 f2                	cmp    %esi,%edx
  80204a:	89 d0                	mov    %edx,%eax
  80204c:	77 52                	ja     8020a0 <__umoddi3+0xa0>
  80204e:	0f bd ea             	bsr    %edx,%ebp
  802051:	83 f5 1f             	xor    $0x1f,%ebp
  802054:	75 5a                	jne    8020b0 <__umoddi3+0xb0>
  802056:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80205a:	0f 82 e0 00 00 00    	jb     802140 <__umoddi3+0x140>
  802060:	39 0c 24             	cmp    %ecx,(%esp)
  802063:	0f 86 d7 00 00 00    	jbe    802140 <__umoddi3+0x140>
  802069:	8b 44 24 08          	mov    0x8(%esp),%eax
  80206d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	85 ff                	test   %edi,%edi
  802082:	89 fd                	mov    %edi,%ebp
  802084:	75 0b                	jne    802091 <__umoddi3+0x91>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f7                	div    %edi
  80208f:	89 c5                	mov    %eax,%ebp
  802091:	89 f0                	mov    %esi,%eax
  802093:	31 d2                	xor    %edx,%edx
  802095:	f7 f5                	div    %ebp
  802097:	89 c8                	mov    %ecx,%eax
  802099:	f7 f5                	div    %ebp
  80209b:	89 d0                	mov    %edx,%eax
  80209d:	eb 99                	jmp    802038 <__umoddi3+0x38>
  80209f:	90                   	nop
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	83 c4 1c             	add    $0x1c,%esp
  8020a7:	5b                   	pop    %ebx
  8020a8:	5e                   	pop    %esi
  8020a9:	5f                   	pop    %edi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	8b 34 24             	mov    (%esp),%esi
  8020b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020b8:	89 e9                	mov    %ebp,%ecx
  8020ba:	29 ef                	sub    %ebp,%edi
  8020bc:	d3 e0                	shl    %cl,%eax
  8020be:	89 f9                	mov    %edi,%ecx
  8020c0:	89 f2                	mov    %esi,%edx
  8020c2:	d3 ea                	shr    %cl,%edx
  8020c4:	89 e9                	mov    %ebp,%ecx
  8020c6:	09 c2                	or     %eax,%edx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 14 24             	mov    %edx,(%esp)
  8020cd:	89 f2                	mov    %esi,%edx
  8020cf:	d3 e2                	shl    %cl,%edx
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	89 c6                	mov    %eax,%esi
  8020e1:	d3 e3                	shl    %cl,%ebx
  8020e3:	89 f9                	mov    %edi,%ecx
  8020e5:	89 d0                	mov    %edx,%eax
  8020e7:	d3 e8                	shr    %cl,%eax
  8020e9:	89 e9                	mov    %ebp,%ecx
  8020eb:	09 d8                	or     %ebx,%eax
  8020ed:	89 d3                	mov    %edx,%ebx
  8020ef:	89 f2                	mov    %esi,%edx
  8020f1:	f7 34 24             	divl   (%esp)
  8020f4:	89 d6                	mov    %edx,%esi
  8020f6:	d3 e3                	shl    %cl,%ebx
  8020f8:	f7 64 24 04          	mull   0x4(%esp)
  8020fc:	39 d6                	cmp    %edx,%esi
  8020fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802102:	89 d1                	mov    %edx,%ecx
  802104:	89 c3                	mov    %eax,%ebx
  802106:	72 08                	jb     802110 <__umoddi3+0x110>
  802108:	75 11                	jne    80211b <__umoddi3+0x11b>
  80210a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80210e:	73 0b                	jae    80211b <__umoddi3+0x11b>
  802110:	2b 44 24 04          	sub    0x4(%esp),%eax
  802114:	1b 14 24             	sbb    (%esp),%edx
  802117:	89 d1                	mov    %edx,%ecx
  802119:	89 c3                	mov    %eax,%ebx
  80211b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80211f:	29 da                	sub    %ebx,%edx
  802121:	19 ce                	sbb    %ecx,%esi
  802123:	89 f9                	mov    %edi,%ecx
  802125:	89 f0                	mov    %esi,%eax
  802127:	d3 e0                	shl    %cl,%eax
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	d3 ea                	shr    %cl,%edx
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	d3 ee                	shr    %cl,%esi
  802131:	09 d0                	or     %edx,%eax
  802133:	89 f2                	mov    %esi,%edx
  802135:	83 c4 1c             	add    $0x1c,%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    
  80213d:	8d 76 00             	lea    0x0(%esi),%esi
  802140:	29 f9                	sub    %edi,%ecx
  802142:	19 d6                	sbb    %edx,%esi
  802144:	89 74 24 04          	mov    %esi,0x4(%esp)
  802148:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80214c:	e9 18 ff ff ff       	jmp    802069 <__umoddi3+0x69>
