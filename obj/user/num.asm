
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 80 20 80 00       	push   $0x802080
  800062:	e8 50 17 00 00       	call   8017b7 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 13 12 00 00       	call   801294 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 85 20 80 00       	push   $0x802085
  800095:	6a 13                	push   $0x13
  800097:	68 a0 20 80 00       	push   $0x8020a0
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 fd 10 00 00       	call   8011ba <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 ab 20 80 00       	push   $0x8020ab
  8000d8:	6a 18                	push   $0x18
  8000da:	68 a0 20 80 00       	push   $0x8020a0
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 c0 	movl   $0x8020c0,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 c4 20 80 00       	push   $0x8020c4
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 e5 14 00 00       	call   801619 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 cc 20 80 00       	push   $0x8020cc
  80014b:	6a 27                	push   $0x27
  80014d:	68 a0 20 80 00       	push   $0x8020a0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 14 0f 00 00       	call   80107e <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800190:	e8 1a 0b 00 00       	call   800caf <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 d3 0e 00 00       	call   8010a9 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 8e 0a 00 00       	call   800c6e <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 b7 0a 00 00       	call   800caf <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 e8 20 80 00       	push   $0x8020e8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 25 25 80 00 	movl   $0x802525,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 d6 09 00 00       	call   800c31 <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 1a 01 00 00       	call   8003bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 7b 09 00 00       	call   800c31 <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 ca 1a 00 00       	call   801df0 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 b7 1b 00 00       	call   801f20 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 0b 21 80 00 	movsbl 0x80210b(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800387:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 0a                	jae    80039c <sprintputch+0x1b>
		*b->buf++ = ch;
  800392:	8d 4a 01             	lea    0x1(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	88 02                	mov    %al,(%edx)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	50                   	push   %eax
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	ff 75 0c             	pushl  0xc(%ebp)
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	e8 05 00 00 00       	call   8003bb <vprintfmt>
	va_end(ap);
}
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 2c             	sub    $0x2c,%esp
  8003c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cd:	eb 12                	jmp    8003e1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	0f 84 6a 04 00 00    	je     800841 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	53                   	push   %ebx
  8003db:	50                   	push   %eax
  8003dc:	ff d6                	call   *%esi
  8003de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	83 c7 01             	add    $0x1,%edi
  8003e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003e8:	83 f8 25             	cmp    $0x25,%eax
  8003eb:	75 e2                	jne    8003cf <vprintfmt+0x14>
  8003ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040b:	eb 07                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800410:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8d 47 01             	lea    0x1(%edi),%eax
  800417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041a:	0f b6 07             	movzbl (%edi),%eax
  80041d:	0f b6 d0             	movzbl %al,%edx
  800420:	83 e8 23             	sub    $0x23,%eax
  800423:	3c 55                	cmp    $0x55,%al
  800425:	0f 87 fb 03 00 00    	ja     800826 <vprintfmt+0x46b>
  80042b:	0f b6 c0             	movzbl %al,%eax
  80042e:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800438:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80043c:	eb d6                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800449:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800450:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800453:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800456:	83 f9 09             	cmp    $0x9,%ecx
  800459:	77 3f                	ja     80049a <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb e9                	jmp    800449 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8b 00                	mov    (%eax),%eax
  800465:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 40 04             	lea    0x4(%eax),%eax
  80046e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800474:	eb 2a                	jmp    8004a0 <vprintfmt+0xe5>
  800476:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800479:	85 c0                	test   %eax,%eax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
  800480:	0f 49 d0             	cmovns %eax,%edx
  800483:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800489:	eb 89                	jmp    800414 <vprintfmt+0x59>
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800495:	e9 7a ff ff ff       	jmp    800414 <vprintfmt+0x59>
  80049a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80049d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a4:	0f 89 6a ff ff ff    	jns    800414 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b7:	e9 58 ff ff ff       	jmp    800414 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bc:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c2:	e9 4d ff ff ff       	jmp    800414 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 78 04             	lea    0x4(%eax),%edi
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	53                   	push   %ebx
  8004d1:	ff 30                	pushl  (%eax)
  8004d3:	ff d6                	call   *%esi
			break;
  8004d5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004de:	e9 fe fe ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 78 04             	lea    0x4(%eax),%edi
  8004e9:	8b 00                	mov    (%eax),%eax
  8004eb:	99                   	cltd   
  8004ec:	31 d0                	xor    %edx,%eax
  8004ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f0:	83 f8 0f             	cmp    $0xf,%eax
  8004f3:	7f 0b                	jg     800500 <vprintfmt+0x145>
  8004f5:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  8004fc:	85 d2                	test   %edx,%edx
  8004fe:	75 1b                	jne    80051b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800500:	50                   	push   %eax
  800501:	68 23 21 80 00       	push   $0x802123
  800506:	53                   	push   %ebx
  800507:	56                   	push   %esi
  800508:	e8 91 fe ff ff       	call   80039e <printfmt>
  80050d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800510:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800516:	e9 c6 fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051b:	52                   	push   %edx
  80051c:	68 fe 24 80 00       	push   $0x8024fe
  800521:	53                   	push   %ebx
  800522:	56                   	push   %esi
  800523:	e8 76 fe ff ff       	call   80039e <printfmt>
  800528:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800531:	e9 ab fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	83 c0 04             	add    $0x4,%eax
  80053c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800544:	85 ff                	test   %edi,%edi
  800546:	b8 1c 21 80 00       	mov    $0x80211c,%eax
  80054b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800552:	0f 8e 94 00 00 00    	jle    8005ec <vprintfmt+0x231>
  800558:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055c:	0f 84 98 00 00 00    	je     8005fa <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 d0             	pushl  -0x30(%ebp)
  800568:	57                   	push   %edi
  800569:	e8 5b 03 00 00       	call   8008c9 <strnlen>
  80056e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800571:	29 c1                	sub    %eax,%ecx
  800573:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800579:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800583:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x1db>
					putch(padc, putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	ff 75 e0             	pushl  -0x20(%ebp)
  80058e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	85 ff                	test   %edi,%edi
  800598:	7f ed                	jg     800587 <vprintfmt+0x1cc>
  80059a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a7:	0f 49 c1             	cmovns %ecx,%eax
  8005aa:	29 c1                	sub    %eax,%ecx
  8005ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8005af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b5:	89 cb                	mov    %ecx,%ebx
  8005b7:	eb 4d                	jmp    800606 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bd:	74 1b                	je     8005da <vprintfmt+0x21f>
  8005bf:	0f be c0             	movsbl %al,%eax
  8005c2:	83 e8 20             	sub    $0x20,%eax
  8005c5:	83 f8 5e             	cmp    $0x5e,%eax
  8005c8:	76 10                	jbe    8005da <vprintfmt+0x21f>
					putch('?', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	ff 75 0c             	pushl  0xc(%ebp)
  8005d0:	6a 3f                	push   $0x3f
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb 0d                	jmp    8005e7 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	ff 75 0c             	pushl  0xc(%ebp)
  8005e0:	52                   	push   %edx
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e7:	83 eb 01             	sub    $0x1,%ebx
  8005ea:	eb 1a                	jmp    800606 <vprintfmt+0x24b>
  8005ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f8:	eb 0c                	jmp    800606 <vprintfmt+0x24b>
  8005fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800600:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800603:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800606:	83 c7 01             	add    $0x1,%edi
  800609:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060d:	0f be d0             	movsbl %al,%edx
  800610:	85 d2                	test   %edx,%edx
  800612:	74 23                	je     800637 <vprintfmt+0x27c>
  800614:	85 f6                	test   %esi,%esi
  800616:	78 a1                	js     8005b9 <vprintfmt+0x1fe>
  800618:	83 ee 01             	sub    $0x1,%esi
  80061b:	79 9c                	jns    8005b9 <vprintfmt+0x1fe>
  80061d:	89 df                	mov    %ebx,%edi
  80061f:	8b 75 08             	mov    0x8(%ebp),%esi
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800625:	eb 18                	jmp    80063f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 20                	push   $0x20
  80062d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062f:	83 ef 01             	sub    $0x1,%edi
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb 08                	jmp    80063f <vprintfmt+0x284>
  800637:	89 df                	mov    %ebx,%edi
  800639:	8b 75 08             	mov    0x8(%ebp),%esi
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063f:	85 ff                	test   %edi,%edi
  800641:	7f e4                	jg     800627 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800643:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064c:	e9 90 fd ff ff       	jmp    8003e1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800651:	83 f9 01             	cmp    $0x1,%ecx
  800654:	7e 19                	jle    80066f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 50 04             	mov    0x4(%eax),%edx
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 40 08             	lea    0x8(%eax),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
  80066d:	eb 38                	jmp    8006a7 <vprintfmt+0x2ec>
	else if (lflag)
  80066f:	85 c9                	test   %ecx,%ecx
  800671:	74 1b                	je     80068e <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 c1                	mov    %eax,%ecx
  80067d:	c1 f9 1f             	sar    $0x1f,%ecx
  800680:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 40 04             	lea    0x4(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
  80068c:	eb 19                	jmp    8006a7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800696:	89 c1                	mov    %eax,%ecx
  800698:	c1 f9 1f             	sar    $0x1f,%ecx
  80069b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 40 04             	lea    0x4(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ad:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006b6:	0f 89 36 01 00 00    	jns    8007f2 <vprintfmt+0x437>
				putch('-', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 2d                	push   $0x2d
  8006c2:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ca:	f7 da                	neg    %edx
  8006cc:	83 d1 00             	adc    $0x0,%ecx
  8006cf:	f7 d9                	neg    %ecx
  8006d1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d9:	e9 14 01 00 00       	jmp    8007f2 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006de:	83 f9 01             	cmp    $0x1,%ecx
  8006e1:	7e 18                	jle    8006fb <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006eb:	8d 40 08             	lea    0x8(%eax),%eax
  8006ee:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f6:	e9 f7 00 00 00       	jmp    8007f2 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	74 1a                	je     800719 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	b9 00 00 00 00       	mov    $0x0,%ecx
  800709:	8d 40 04             	lea    0x4(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80070f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800714:	e9 d9 00 00 00       	jmp    8007f2 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800723:	8d 40 04             	lea    0x4(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800729:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072e:	e9 bf 00 00 00       	jmp    8007f2 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800733:	83 f9 01             	cmp    $0x1,%ecx
  800736:	7e 13                	jle    80074b <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 50 04             	mov    0x4(%eax),%edx
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800743:	8d 49 08             	lea    0x8(%ecx),%ecx
  800746:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800749:	eb 28                	jmp    800773 <vprintfmt+0x3b8>
	else if (lflag)
  80074b:	85 c9                	test   %ecx,%ecx
  80074d:	74 13                	je     800762 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 10                	mov    (%eax),%edx
  800754:	89 d0                	mov    %edx,%eax
  800756:	99                   	cltd   
  800757:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80075a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80075d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800760:	eb 11                	jmp    800773 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 10                	mov    (%eax),%edx
  800767:	89 d0                	mov    %edx,%eax
  800769:	99                   	cltd   
  80076a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80076d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800770:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800773:	89 d1                	mov    %edx,%ecx
  800775:	89 c2                	mov    %eax,%edx
			base = 8;
  800777:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80077c:	eb 74                	jmp    8007f2 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	53                   	push   %ebx
  800782:	6a 30                	push   $0x30
  800784:	ff d6                	call   *%esi
			putch('x', putdat);
  800786:	83 c4 08             	add    $0x8,%esp
  800789:	53                   	push   %ebx
  80078a:	6a 78                	push   $0x78
  80078c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8b 10                	mov    (%eax),%edx
  800793:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800798:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007a6:	eb 4a                	jmp    8007f2 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a8:	83 f9 01             	cmp    $0x1,%ecx
  8007ab:	7e 15                	jle    8007c2 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b5:	8d 40 08             	lea    0x8(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c0:	eb 30                	jmp    8007f2 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007c2:	85 c9                	test   %ecx,%ecx
  8007c4:	74 17                	je     8007dd <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007db:	eb 15                	jmp    8007f2 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ed:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f2:	83 ec 0c             	sub    $0xc,%esp
  8007f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007f9:	57                   	push   %edi
  8007fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fd:	50                   	push   %eax
  8007fe:	51                   	push   %ecx
  8007ff:	52                   	push   %edx
  800800:	89 da                	mov    %ebx,%edx
  800802:	89 f0                	mov    %esi,%eax
  800804:	e8 c9 fa ff ff       	call   8002d2 <printnum>
			break;
  800809:	83 c4 20             	add    $0x20,%esp
  80080c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080f:	e9 cd fb ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	52                   	push   %edx
  800819:	ff d6                	call   *%esi
			break;
  80081b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800821:	e9 bb fb ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	53                   	push   %ebx
  80082a:	6a 25                	push   $0x25
  80082c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 03                	jmp    800836 <vprintfmt+0x47b>
  800833:	83 ef 01             	sub    $0x1,%edi
  800836:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80083a:	75 f7                	jne    800833 <vprintfmt+0x478>
  80083c:	e9 a0 fb ff ff       	jmp    8003e1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800841:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5f                   	pop    %edi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	83 ec 18             	sub    $0x18,%esp
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800855:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800858:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800866:	85 c0                	test   %eax,%eax
  800868:	74 26                	je     800890 <vsnprintf+0x47>
  80086a:	85 d2                	test   %edx,%edx
  80086c:	7e 22                	jle    800890 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086e:	ff 75 14             	pushl  0x14(%ebp)
  800871:	ff 75 10             	pushl  0x10(%ebp)
  800874:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800877:	50                   	push   %eax
  800878:	68 81 03 80 00       	push   $0x800381
  80087d:	e8 39 fb ff ff       	call   8003bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800882:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800885:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	eb 05                	jmp    800895 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800890:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a0:	50                   	push   %eax
  8008a1:	ff 75 10             	pushl  0x10(%ebp)
  8008a4:	ff 75 0c             	pushl  0xc(%ebp)
  8008a7:	ff 75 08             	pushl  0x8(%ebp)
  8008aa:	e8 9a ff ff ff       	call   800849 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	eb 03                	jmp    8008c1 <strlen+0x10>
		n++;
  8008be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c5:	75 f7                	jne    8008be <strlen+0xd>
		n++;
	return n;
}
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d7:	eb 03                	jmp    8008dc <strnlen+0x13>
		n++;
  8008d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	39 c2                	cmp    %eax,%edx
  8008de:	74 08                	je     8008e8 <strnlen+0x1f>
  8008e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008e4:	75 f3                	jne    8008d9 <strnlen+0x10>
  8008e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f4:	89 c2                	mov    %eax,%edx
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	83 c1 01             	add    $0x1,%ecx
  8008fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800900:	88 5a ff             	mov    %bl,-0x1(%edx)
  800903:	84 db                	test   %bl,%bl
  800905:	75 ef                	jne    8008f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800911:	53                   	push   %ebx
  800912:	e8 9a ff ff ff       	call   8008b1 <strlen>
  800917:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80091a:	ff 75 0c             	pushl  0xc(%ebp)
  80091d:	01 d8                	add    %ebx,%eax
  80091f:	50                   	push   %eax
  800920:	e8 c5 ff ff ff       	call   8008ea <strcpy>
	return dst;
}
  800925:	89 d8                	mov    %ebx,%eax
  800927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 75 08             	mov    0x8(%ebp),%esi
  800934:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800937:	89 f3                	mov    %esi,%ebx
  800939:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093c:	89 f2                	mov    %esi,%edx
  80093e:	eb 0f                	jmp    80094f <strncpy+0x23>
		*dst++ = *src;
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	0f b6 01             	movzbl (%ecx),%eax
  800946:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800949:	80 39 01             	cmpb   $0x1,(%ecx)
  80094c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094f:	39 da                	cmp    %ebx,%edx
  800951:	75 ed                	jne    800940 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800953:	89 f0                	mov    %esi,%eax
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 75 08             	mov    0x8(%ebp),%esi
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800964:	8b 55 10             	mov    0x10(%ebp),%edx
  800967:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800969:	85 d2                	test   %edx,%edx
  80096b:	74 21                	je     80098e <strlcpy+0x35>
  80096d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800971:	89 f2                	mov    %esi,%edx
  800973:	eb 09                	jmp    80097e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	83 c1 01             	add    $0x1,%ecx
  80097b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80097e:	39 c2                	cmp    %eax,%edx
  800980:	74 09                	je     80098b <strlcpy+0x32>
  800982:	0f b6 19             	movzbl (%ecx),%ebx
  800985:	84 db                	test   %bl,%bl
  800987:	75 ec                	jne    800975 <strlcpy+0x1c>
  800989:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80098b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098e:	29 f0                	sub    %esi,%eax
}
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099d:	eb 06                	jmp    8009a5 <strcmp+0x11>
		p++, q++;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a5:	0f b6 01             	movzbl (%ecx),%eax
  8009a8:	84 c0                	test   %al,%al
  8009aa:	74 04                	je     8009b0 <strcmp+0x1c>
  8009ac:	3a 02                	cmp    (%edx),%al
  8009ae:	74 ef                	je     80099f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b0:	0f b6 c0             	movzbl %al,%eax
  8009b3:	0f b6 12             	movzbl (%edx),%edx
  8009b6:	29 d0                	sub    %edx,%eax
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c3                	mov    %eax,%ebx
  8009c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c9:	eb 06                	jmp    8009d1 <strncmp+0x17>
		n--, p++, q++;
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d1:	39 d8                	cmp    %ebx,%eax
  8009d3:	74 15                	je     8009ea <strncmp+0x30>
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	84 c9                	test   %cl,%cl
  8009da:	74 04                	je     8009e0 <strncmp+0x26>
  8009dc:	3a 0a                	cmp    (%edx),%cl
  8009de:	74 eb                	je     8009cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e0:	0f b6 00             	movzbl (%eax),%eax
  8009e3:	0f b6 12             	movzbl (%edx),%edx
  8009e6:	29 d0                	sub    %edx,%eax
  8009e8:	eb 05                	jmp    8009ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fc:	eb 07                	jmp    800a05 <strchr+0x13>
		if (*s == c)
  8009fe:	38 ca                	cmp    %cl,%dl
  800a00:	74 0f                	je     800a11 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	75 f2                	jne    8009fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1d:	eb 03                	jmp    800a22 <strfind+0xf>
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a25:	38 ca                	cmp    %cl,%dl
  800a27:	74 04                	je     800a2d <strfind+0x1a>
  800a29:	84 d2                	test   %dl,%dl
  800a2b:	75 f2                	jne    800a1f <strfind+0xc>
			break;
	return (char *) s;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3b:	85 c9                	test   %ecx,%ecx
  800a3d:	74 36                	je     800a75 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a45:	75 28                	jne    800a6f <memset+0x40>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 23                	jne    800a6f <memset+0x40>
		c &= 0xFF;
  800a4c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a50:	89 d3                	mov    %edx,%ebx
  800a52:	c1 e3 08             	shl    $0x8,%ebx
  800a55:	89 d6                	mov    %edx,%esi
  800a57:	c1 e6 18             	shl    $0x18,%esi
  800a5a:	89 d0                	mov    %edx,%eax
  800a5c:	c1 e0 10             	shl    $0x10,%eax
  800a5f:	09 f0                	or     %esi,%eax
  800a61:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a63:	89 d8                	mov    %ebx,%eax
  800a65:	09 d0                	or     %edx,%eax
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	fc                   	cld    
  800a6b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6d:	eb 06                	jmp    800a75 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a72:	fc                   	cld    
  800a73:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a75:	89 f8                	mov    %edi,%eax
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8a:	39 c6                	cmp    %eax,%esi
  800a8c:	73 35                	jae    800ac3 <memmove+0x47>
  800a8e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a91:	39 d0                	cmp    %edx,%eax
  800a93:	73 2e                	jae    800ac3 <memmove+0x47>
		s += n;
		d += n;
  800a95:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	09 fe                	or     %edi,%esi
  800a9c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa2:	75 13                	jne    800ab7 <memmove+0x3b>
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 0e                	jne    800ab7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aa9:	83 ef 04             	sub    $0x4,%edi
  800aac:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aaf:	c1 e9 02             	shr    $0x2,%ecx
  800ab2:	fd                   	std    
  800ab3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab5:	eb 09                	jmp    800ac0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab7:	83 ef 01             	sub    $0x1,%edi
  800aba:	8d 72 ff             	lea    -0x1(%edx),%esi
  800abd:	fd                   	std    
  800abe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac0:	fc                   	cld    
  800ac1:	eb 1d                	jmp    800ae0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac3:	89 f2                	mov    %esi,%edx
  800ac5:	09 c2                	or     %eax,%edx
  800ac7:	f6 c2 03             	test   $0x3,%dl
  800aca:	75 0f                	jne    800adb <memmove+0x5f>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 0a                	jne    800adb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ad1:	c1 e9 02             	shr    $0x2,%ecx
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad9:	eb 05                	jmp    800ae0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800adb:	89 c7                	mov    %eax,%edi
  800add:	fc                   	cld    
  800ade:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae7:	ff 75 10             	pushl  0x10(%ebp)
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	ff 75 08             	pushl  0x8(%ebp)
  800af0:	e8 87 ff ff ff       	call   800a7c <memmove>
}
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	89 c6                	mov    %eax,%esi
  800b04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b07:	eb 1a                	jmp    800b23 <memcmp+0x2c>
		if (*s1 != *s2)
  800b09:	0f b6 08             	movzbl (%eax),%ecx
  800b0c:	0f b6 1a             	movzbl (%edx),%ebx
  800b0f:	38 d9                	cmp    %bl,%cl
  800b11:	74 0a                	je     800b1d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b13:	0f b6 c1             	movzbl %cl,%eax
  800b16:	0f b6 db             	movzbl %bl,%ebx
  800b19:	29 d8                	sub    %ebx,%eax
  800b1b:	eb 0f                	jmp    800b2c <memcmp+0x35>
		s1++, s2++;
  800b1d:	83 c0 01             	add    $0x1,%eax
  800b20:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	39 f0                	cmp    %esi,%eax
  800b25:	75 e2                	jne    800b09 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	53                   	push   %ebx
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b37:	89 c1                	mov    %eax,%ecx
  800b39:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b40:	eb 0a                	jmp    800b4c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b42:	0f b6 10             	movzbl (%eax),%edx
  800b45:	39 da                	cmp    %ebx,%edx
  800b47:	74 07                	je     800b50 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	39 c8                	cmp    %ecx,%eax
  800b4e:	72 f2                	jb     800b42 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5f:	eb 03                	jmp    800b64 <strtol+0x11>
		s++;
  800b61:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b64:	0f b6 01             	movzbl (%ecx),%eax
  800b67:	3c 20                	cmp    $0x20,%al
  800b69:	74 f6                	je     800b61 <strtol+0xe>
  800b6b:	3c 09                	cmp    $0x9,%al
  800b6d:	74 f2                	je     800b61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b6f:	3c 2b                	cmp    $0x2b,%al
  800b71:	75 0a                	jne    800b7d <strtol+0x2a>
		s++;
  800b73:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b76:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7b:	eb 11                	jmp    800b8e <strtol+0x3b>
  800b7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b82:	3c 2d                	cmp    $0x2d,%al
  800b84:	75 08                	jne    800b8e <strtol+0x3b>
		s++, neg = 1;
  800b86:	83 c1 01             	add    $0x1,%ecx
  800b89:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b94:	75 15                	jne    800bab <strtol+0x58>
  800b96:	80 39 30             	cmpb   $0x30,(%ecx)
  800b99:	75 10                	jne    800bab <strtol+0x58>
  800b9b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b9f:	75 7c                	jne    800c1d <strtol+0xca>
		s += 2, base = 16;
  800ba1:	83 c1 02             	add    $0x2,%ecx
  800ba4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba9:	eb 16                	jmp    800bc1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bab:	85 db                	test   %ebx,%ebx
  800bad:	75 12                	jne    800bc1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800baf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb7:	75 08                	jne    800bc1 <strtol+0x6e>
		s++, base = 8;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc9:	0f b6 11             	movzbl (%ecx),%edx
  800bcc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bcf:	89 f3                	mov    %esi,%ebx
  800bd1:	80 fb 09             	cmp    $0x9,%bl
  800bd4:	77 08                	ja     800bde <strtol+0x8b>
			dig = *s - '0';
  800bd6:	0f be d2             	movsbl %dl,%edx
  800bd9:	83 ea 30             	sub    $0x30,%edx
  800bdc:	eb 22                	jmp    800c00 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bde:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be1:	89 f3                	mov    %esi,%ebx
  800be3:	80 fb 19             	cmp    $0x19,%bl
  800be6:	77 08                	ja     800bf0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800be8:	0f be d2             	movsbl %dl,%edx
  800beb:	83 ea 57             	sub    $0x57,%edx
  800bee:	eb 10                	jmp    800c00 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf3:	89 f3                	mov    %esi,%ebx
  800bf5:	80 fb 19             	cmp    $0x19,%bl
  800bf8:	77 16                	ja     800c10 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bfa:	0f be d2             	movsbl %dl,%edx
  800bfd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c00:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c03:	7d 0b                	jge    800c10 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c05:	83 c1 01             	add    $0x1,%ecx
  800c08:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c0c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c0e:	eb b9                	jmp    800bc9 <strtol+0x76>

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 0d                	je     800c23 <strtol+0xd0>
		*endptr = (char *) s;
  800c16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c19:	89 0e                	mov    %ecx,(%esi)
  800c1b:	eb 06                	jmp    800c23 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c1d:	85 db                	test   %ebx,%ebx
  800c1f:	74 98                	je     800bb9 <strtol+0x66>
  800c21:	eb 9e                	jmp    800bc1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c23:	89 c2                	mov    %eax,%edx
  800c25:	f7 da                	neg    %edx
  800c27:	85 ff                	test   %edi,%edi
  800c29:	0f 45 c2             	cmovne %edx,%eax
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 c3                	mov    %eax,%ebx
  800c44:	89 c7                	mov    %eax,%edi
  800c46:	89 c6                	mov    %eax,%esi
  800c48:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 cb                	mov    %ecx,%ebx
  800c86:	89 cf                	mov    %ecx,%edi
  800c88:	89 ce                	mov    %ecx,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 03                	push   $0x3
  800c96:	68 ff 23 80 00       	push   $0x8023ff
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 1c 24 80 00       	push   $0x80241c
  800ca2:	e8 3e f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cba:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	89 d3                	mov    %edx,%ebx
  800cc3:	89 d7                	mov    %edx,%edi
  800cc5:	89 d6                	mov    %edx,%esi
  800cc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_yield>:

void
sys_yield(void)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cde:	89 d1                	mov    %edx,%ecx
  800ce0:	89 d3                	mov    %edx,%ebx
  800ce2:	89 d7                	mov    %edx,%edi
  800ce4:	89 d6                	mov    %edx,%esi
  800ce6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800cf6:	be 00 00 00 00       	mov    $0x0,%esi
  800cfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d09:	89 f7                	mov    %esi,%edi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 04                	push   $0x4
  800d17:	68 ff 23 80 00       	push   $0x8023ff
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 1c 24 80 00       	push   $0x80241c
  800d23:	e8 bd f4 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800d39:	b8 05 00 00 00       	mov    $0x5,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 05                	push   $0x5
  800d59:	68 ff 23 80 00       	push   $0x8023ff
  800d5e:	6a 23                	push   $0x23
  800d60:	68 1c 24 80 00       	push   $0x80241c
  800d65:	e8 7b f4 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d80:	b8 06 00 00 00       	mov    $0x6,%eax
  800d85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 df                	mov    %ebx,%edi
  800d8d:	89 de                	mov    %ebx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 06                	push   $0x6
  800d9b:	68 ff 23 80 00       	push   $0x8023ff
  800da0:	6a 23                	push   $0x23
  800da2:	68 1c 24 80 00       	push   $0x80241c
  800da7:	e8 39 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 17                	jle    800dee <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 08                	push   $0x8
  800ddd:	68 ff 23 80 00       	push   $0x8023ff
  800de2:	6a 23                	push   $0x23
  800de4:	68 1c 24 80 00       	push   $0x80241c
  800de9:	e8 f7 f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e04:	b8 09 00 00 00       	mov    $0x9,%eax
  800e09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 df                	mov    %ebx,%edi
  800e11:	89 de                	mov    %ebx,%esi
  800e13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 17                	jle    800e30 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	50                   	push   %eax
  800e1d:	6a 09                	push   $0x9
  800e1f:	68 ff 23 80 00       	push   $0x8023ff
  800e24:	6a 23                	push   $0x23
  800e26:	68 1c 24 80 00       	push   $0x80241c
  800e2b:	e8 b5 f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	57                   	push   %edi
  800e3c:	56                   	push   %esi
  800e3d:	53                   	push   %ebx
  800e3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e51:	89 df                	mov    %ebx,%edi
  800e53:	89 de                	mov    %ebx,%esi
  800e55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e57:	85 c0                	test   %eax,%eax
  800e59:	7e 17                	jle    800e72 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	50                   	push   %eax
  800e5f:	6a 0a                	push   $0xa
  800e61:	68 ff 23 80 00       	push   $0x8023ff
  800e66:	6a 23                	push   $0x23
  800e68:	68 1c 24 80 00       	push   $0x80241c
  800e6d:	e8 73 f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	be 00 00 00 00       	mov    $0x0,%esi
  800e85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e96:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eab:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 cb                	mov    %ecx,%ebx
  800eb5:	89 cf                	mov    %ecx,%edi
  800eb7:	89 ce                	mov    %ecx,%esi
  800eb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	7e 17                	jle    800ed6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	50                   	push   %eax
  800ec3:	6a 0d                	push   $0xd
  800ec5:	68 ff 23 80 00       	push   $0x8023ff
  800eca:	6a 23                	push   $0x23
  800ecc:	68 1c 24 80 00       	push   $0x80241c
  800ed1:	e8 0f f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee4:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee9:	c1 e8 0c             	shr    $0xc,%eax
}
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef4:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800efe:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f10:	89 c2                	mov    %eax,%edx
  800f12:	c1 ea 16             	shr    $0x16,%edx
  800f15:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1c:	f6 c2 01             	test   $0x1,%dl
  800f1f:	74 11                	je     800f32 <fd_alloc+0x2d>
  800f21:	89 c2                	mov    %eax,%edx
  800f23:	c1 ea 0c             	shr    $0xc,%edx
  800f26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2d:	f6 c2 01             	test   $0x1,%dl
  800f30:	75 09                	jne    800f3b <fd_alloc+0x36>
			*fd_store = fd;
  800f32:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
  800f39:	eb 17                	jmp    800f52 <fd_alloc+0x4d>
  800f3b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f40:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f45:	75 c9                	jne    800f10 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f47:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f4d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f5a:	83 f8 1f             	cmp    $0x1f,%eax
  800f5d:	77 36                	ja     800f95 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f5f:	c1 e0 0c             	shl    $0xc,%eax
  800f62:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f67:	89 c2                	mov    %eax,%edx
  800f69:	c1 ea 16             	shr    $0x16,%edx
  800f6c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f73:	f6 c2 01             	test   $0x1,%dl
  800f76:	74 24                	je     800f9c <fd_lookup+0x48>
  800f78:	89 c2                	mov    %eax,%edx
  800f7a:	c1 ea 0c             	shr    $0xc,%edx
  800f7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f84:	f6 c2 01             	test   $0x1,%dl
  800f87:	74 1a                	je     800fa3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8c:	89 02                	mov    %eax,(%edx)
	return 0;
  800f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f93:	eb 13                	jmp    800fa8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9a:	eb 0c                	jmp    800fa8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa1:	eb 05                	jmp    800fa8 <fd_lookup+0x54>
  800fa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 08             	sub    $0x8,%esp
  800fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb3:	ba ac 24 80 00       	mov    $0x8024ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb8:	eb 13                	jmp    800fcd <dev_lookup+0x23>
  800fba:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fbd:	39 08                	cmp    %ecx,(%eax)
  800fbf:	75 0c                	jne    800fcd <dev_lookup+0x23>
			*dev = devtab[i];
  800fc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	eb 2e                	jmp    800ffb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fcd:	8b 02                	mov    (%edx),%eax
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	75 e7                	jne    800fba <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd3:	a1 08 40 80 00       	mov    0x804008,%eax
  800fd8:	8b 40 48             	mov    0x48(%eax),%eax
  800fdb:	83 ec 04             	sub    $0x4,%esp
  800fde:	51                   	push   %ecx
  800fdf:	50                   	push   %eax
  800fe0:	68 2c 24 80 00       	push   $0x80242c
  800fe5:	e8 d4 f2 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800fea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 10             	sub    $0x10,%esp
  801005:	8b 75 08             	mov    0x8(%ebp),%esi
  801008:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80100b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100e:	50                   	push   %eax
  80100f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801015:	c1 e8 0c             	shr    $0xc,%eax
  801018:	50                   	push   %eax
  801019:	e8 36 ff ff ff       	call   800f54 <fd_lookup>
  80101e:	83 c4 08             	add    $0x8,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 05                	js     80102a <fd_close+0x2d>
	    || fd != fd2)
  801025:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801028:	74 0c                	je     801036 <fd_close+0x39>
		return (must_exist ? r : 0);
  80102a:	84 db                	test   %bl,%bl
  80102c:	ba 00 00 00 00       	mov    $0x0,%edx
  801031:	0f 44 c2             	cmove  %edx,%eax
  801034:	eb 41                	jmp    801077 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801036:	83 ec 08             	sub    $0x8,%esp
  801039:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	ff 36                	pushl  (%esi)
  80103f:	e8 66 ff ff ff       	call   800faa <dev_lookup>
  801044:	89 c3                	mov    %eax,%ebx
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	78 1a                	js     801067 <fd_close+0x6a>
		if (dev->dev_close)
  80104d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801050:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801058:	85 c0                	test   %eax,%eax
  80105a:	74 0b                	je     801067 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	56                   	push   %esi
  801060:	ff d0                	call   *%eax
  801062:	89 c3                	mov    %eax,%ebx
  801064:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801067:	83 ec 08             	sub    $0x8,%esp
  80106a:	56                   	push   %esi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 00 fd ff ff       	call   800d72 <sys_page_unmap>
	return r;
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	89 d8                	mov    %ebx,%eax
}
  801077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107a:	5b                   	pop    %ebx
  80107b:	5e                   	pop    %esi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801084:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801087:	50                   	push   %eax
  801088:	ff 75 08             	pushl  0x8(%ebp)
  80108b:	e8 c4 fe ff ff       	call   800f54 <fd_lookup>
  801090:	83 c4 08             	add    $0x8,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 10                	js     8010a7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	6a 01                	push   $0x1
  80109c:	ff 75 f4             	pushl  -0xc(%ebp)
  80109f:	e8 59 ff ff ff       	call   800ffd <fd_close>
  8010a4:	83 c4 10             	add    $0x10,%esp
}
  8010a7:	c9                   	leave  
  8010a8:	c3                   	ret    

008010a9 <close_all>:

void
close_all(void)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	53                   	push   %ebx
  8010b9:	e8 c0 ff ff ff       	call   80107e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010be:	83 c3 01             	add    $0x1,%ebx
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	83 fb 20             	cmp    $0x20,%ebx
  8010c7:	75 ec                	jne    8010b5 <close_all+0xc>
		close(i);
}
  8010c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    

008010ce <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 2c             	sub    $0x2c,%esp
  8010d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	ff 75 08             	pushl  0x8(%ebp)
  8010e1:	e8 6e fe ff ff       	call   800f54 <fd_lookup>
  8010e6:	83 c4 08             	add    $0x8,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	0f 88 c1 00 00 00    	js     8011b2 <dup+0xe4>
		return r;
	close(newfdnum);
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	56                   	push   %esi
  8010f5:	e8 84 ff ff ff       	call   80107e <close>

	newfd = INDEX2FD(newfdnum);
  8010fa:	89 f3                	mov    %esi,%ebx
  8010fc:	c1 e3 0c             	shl    $0xc,%ebx
  8010ff:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801105:	83 c4 04             	add    $0x4,%esp
  801108:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110b:	e8 de fd ff ff       	call   800eee <fd2data>
  801110:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801112:	89 1c 24             	mov    %ebx,(%esp)
  801115:	e8 d4 fd ff ff       	call   800eee <fd2data>
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801120:	89 f8                	mov    %edi,%eax
  801122:	c1 e8 16             	shr    $0x16,%eax
  801125:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112c:	a8 01                	test   $0x1,%al
  80112e:	74 37                	je     801167 <dup+0x99>
  801130:	89 f8                	mov    %edi,%eax
  801132:	c1 e8 0c             	shr    $0xc,%eax
  801135:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113c:	f6 c2 01             	test   $0x1,%dl
  80113f:	74 26                	je     801167 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801141:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801148:	83 ec 0c             	sub    $0xc,%esp
  80114b:	25 07 0e 00 00       	and    $0xe07,%eax
  801150:	50                   	push   %eax
  801151:	ff 75 d4             	pushl  -0x2c(%ebp)
  801154:	6a 00                	push   $0x0
  801156:	57                   	push   %edi
  801157:	6a 00                	push   $0x0
  801159:	e8 d2 fb ff ff       	call   800d30 <sys_page_map>
  80115e:	89 c7                	mov    %eax,%edi
  801160:	83 c4 20             	add    $0x20,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 2e                	js     801195 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801167:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80116a:	89 d0                	mov    %edx,%eax
  80116c:	c1 e8 0c             	shr    $0xc,%eax
  80116f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	25 07 0e 00 00       	and    $0xe07,%eax
  80117e:	50                   	push   %eax
  80117f:	53                   	push   %ebx
  801180:	6a 00                	push   $0x0
  801182:	52                   	push   %edx
  801183:	6a 00                	push   $0x0
  801185:	e8 a6 fb ff ff       	call   800d30 <sys_page_map>
  80118a:	89 c7                	mov    %eax,%edi
  80118c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80118f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801191:	85 ff                	test   %edi,%edi
  801193:	79 1d                	jns    8011b2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	53                   	push   %ebx
  801199:	6a 00                	push   $0x0
  80119b:	e8 d2 fb ff ff       	call   800d72 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011a6:	6a 00                	push   $0x0
  8011a8:	e8 c5 fb ff ff       	call   800d72 <sys_page_unmap>
	return r;
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	89 f8                	mov    %edi,%eax
}
  8011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 14             	sub    $0x14,%esp
  8011c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	53                   	push   %ebx
  8011c9:	e8 86 fd ff ff       	call   800f54 <fd_lookup>
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	78 6d                	js     801244 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011dd:	50                   	push   %eax
  8011de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e1:	ff 30                	pushl  (%eax)
  8011e3:	e8 c2 fd ff ff       	call   800faa <dev_lookup>
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 4c                	js     80123b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011f2:	8b 42 08             	mov    0x8(%edx),%eax
  8011f5:	83 e0 03             	and    $0x3,%eax
  8011f8:	83 f8 01             	cmp    $0x1,%eax
  8011fb:	75 21                	jne    80121e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011fd:	a1 08 40 80 00       	mov    0x804008,%eax
  801202:	8b 40 48             	mov    0x48(%eax),%eax
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	53                   	push   %ebx
  801209:	50                   	push   %eax
  80120a:	68 70 24 80 00       	push   $0x802470
  80120f:	e8 aa f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80121c:	eb 26                	jmp    801244 <read+0x8a>
	}
	if (!dev->dev_read)
  80121e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801221:	8b 40 08             	mov    0x8(%eax),%eax
  801224:	85 c0                	test   %eax,%eax
  801226:	74 17                	je     80123f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	ff 75 10             	pushl  0x10(%ebp)
  80122e:	ff 75 0c             	pushl  0xc(%ebp)
  801231:	52                   	push   %edx
  801232:	ff d0                	call   *%eax
  801234:	89 c2                	mov    %eax,%edx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	eb 09                	jmp    801244 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	eb 05                	jmp    801244 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80123f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801244:	89 d0                	mov    %edx,%eax
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	8b 7d 08             	mov    0x8(%ebp),%edi
  801257:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80125a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125f:	eb 21                	jmp    801282 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	89 f0                	mov    %esi,%eax
  801266:	29 d8                	sub    %ebx,%eax
  801268:	50                   	push   %eax
  801269:	89 d8                	mov    %ebx,%eax
  80126b:	03 45 0c             	add    0xc(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	57                   	push   %edi
  801270:	e8 45 ff ff ff       	call   8011ba <read>
		if (m < 0)
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 10                	js     80128c <readn+0x41>
			return m;
		if (m == 0)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	74 0a                	je     80128a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801280:	01 c3                	add    %eax,%ebx
  801282:	39 f3                	cmp    %esi,%ebx
  801284:	72 db                	jb     801261 <readn+0x16>
  801286:	89 d8                	mov    %ebx,%eax
  801288:	eb 02                	jmp    80128c <readn+0x41>
  80128a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80128c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	53                   	push   %ebx
  801298:	83 ec 14             	sub    $0x14,%esp
  80129b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	53                   	push   %ebx
  8012a3:	e8 ac fc ff ff       	call   800f54 <fd_lookup>
  8012a8:	83 c4 08             	add    $0x8,%esp
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 68                	js     801319 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bb:	ff 30                	pushl  (%eax)
  8012bd:	e8 e8 fc ff ff       	call   800faa <dev_lookup>
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 47                	js     801310 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d0:	75 21                	jne    8012f3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d7:	8b 40 48             	mov    0x48(%eax),%eax
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	53                   	push   %ebx
  8012de:	50                   	push   %eax
  8012df:	68 8c 24 80 00       	push   $0x80248c
  8012e4:	e8 d5 ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f1:	eb 26                	jmp    801319 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8012f9:	85 d2                	test   %edx,%edx
  8012fb:	74 17                	je     801314 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	ff 75 10             	pushl  0x10(%ebp)
  801303:	ff 75 0c             	pushl  0xc(%ebp)
  801306:	50                   	push   %eax
  801307:	ff d2                	call   *%edx
  801309:	89 c2                	mov    %eax,%edx
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	eb 09                	jmp    801319 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801310:	89 c2                	mov    %eax,%edx
  801312:	eb 05                	jmp    801319 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801314:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801319:	89 d0                	mov    %edx,%eax
  80131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <seek>:

int
seek(int fdnum, off_t offset)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801326:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801329:	50                   	push   %eax
  80132a:	ff 75 08             	pushl  0x8(%ebp)
  80132d:	e8 22 fc ff ff       	call   800f54 <fd_lookup>
  801332:	83 c4 08             	add    $0x8,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 0e                	js     801347 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801339:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80133c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801342:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	53                   	push   %ebx
  80134d:	83 ec 14             	sub    $0x14,%esp
  801350:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801353:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801356:	50                   	push   %eax
  801357:	53                   	push   %ebx
  801358:	e8 f7 fb ff ff       	call   800f54 <fd_lookup>
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	89 c2                	mov    %eax,%edx
  801362:	85 c0                	test   %eax,%eax
  801364:	78 65                	js     8013cb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	ff 30                	pushl  (%eax)
  801372:	e8 33 fc ff ff       	call   800faa <dev_lookup>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 44                	js     8013c2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80137e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801381:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801385:	75 21                	jne    8013a8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801387:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80138c:	8b 40 48             	mov    0x48(%eax),%eax
  80138f:	83 ec 04             	sub    $0x4,%esp
  801392:	53                   	push   %ebx
  801393:	50                   	push   %eax
  801394:	68 4c 24 80 00       	push   $0x80244c
  801399:	e8 20 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013a6:	eb 23                	jmp    8013cb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ab:	8b 52 18             	mov    0x18(%edx),%edx
  8013ae:	85 d2                	test   %edx,%edx
  8013b0:	74 14                	je     8013c6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	ff 75 0c             	pushl  0xc(%ebp)
  8013b8:	50                   	push   %eax
  8013b9:	ff d2                	call   *%edx
  8013bb:	89 c2                	mov    %eax,%edx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	eb 09                	jmp    8013cb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	eb 05                	jmp    8013cb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013cb:	89 d0                	mov    %edx,%eax
  8013cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d0:	c9                   	leave  
  8013d1:	c3                   	ret    

008013d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 14             	sub    $0x14,%esp
  8013d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013df:	50                   	push   %eax
  8013e0:	ff 75 08             	pushl  0x8(%ebp)
  8013e3:	e8 6c fb ff ff       	call   800f54 <fd_lookup>
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	89 c2                	mov    %eax,%edx
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 58                	js     801449 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fb:	ff 30                	pushl  (%eax)
  8013fd:	e8 a8 fb ff ff       	call   800faa <dev_lookup>
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 37                	js     801440 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801410:	74 32                	je     801444 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801412:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801415:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80141c:	00 00 00 
	stat->st_isdir = 0;
  80141f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801426:	00 00 00 
	stat->st_dev = dev;
  801429:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	53                   	push   %ebx
  801433:	ff 75 f0             	pushl  -0x10(%ebp)
  801436:	ff 50 14             	call   *0x14(%eax)
  801439:	89 c2                	mov    %eax,%edx
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	eb 09                	jmp    801449 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801440:	89 c2                	mov    %eax,%edx
  801442:	eb 05                	jmp    801449 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801444:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801449:	89 d0                	mov    %edx,%eax
  80144b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	6a 00                	push   $0x0
  80145a:	ff 75 08             	pushl  0x8(%ebp)
  80145d:	e8 b7 01 00 00       	call   801619 <open>
  801462:	89 c3                	mov    %eax,%ebx
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	78 1b                	js     801486 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	ff 75 0c             	pushl  0xc(%ebp)
  801471:	50                   	push   %eax
  801472:	e8 5b ff ff ff       	call   8013d2 <fstat>
  801477:	89 c6                	mov    %eax,%esi
	close(fd);
  801479:	89 1c 24             	mov    %ebx,(%esp)
  80147c:	e8 fd fb ff ff       	call   80107e <close>
	return r;
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	89 f0                	mov    %esi,%eax
}
  801486:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	56                   	push   %esi
  801491:	53                   	push   %ebx
  801492:	89 c6                	mov    %eax,%esi
  801494:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801496:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80149d:	75 12                	jne    8014b1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80149f:	83 ec 0c             	sub    $0xc,%esp
  8014a2:	6a 01                	push   $0x1
  8014a4:	e8 cc 08 00 00       	call   801d75 <ipc_find_env>
  8014a9:	a3 04 40 80 00       	mov    %eax,0x804004
  8014ae:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014b1:	6a 07                	push   $0x7
  8014b3:	68 00 50 80 00       	push   $0x805000
  8014b8:	56                   	push   %esi
  8014b9:	ff 35 04 40 80 00    	pushl  0x804004
  8014bf:	e8 5d 08 00 00       	call   801d21 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014c4:	83 c4 0c             	add    $0xc,%esp
  8014c7:	6a 00                	push   $0x0
  8014c9:	53                   	push   %ebx
  8014ca:	6a 00                	push   $0x0
  8014cc:	e8 db 07 00 00       	call   801cac <ipc_recv>
}
  8014d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014de:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ec:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8014fb:	e8 8d ff ff ff       	call   80148d <fsipc>
}
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	8b 40 0c             	mov    0xc(%eax),%eax
  80150e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
  801518:	b8 06 00 00 00       	mov    $0x6,%eax
  80151d:	e8 6b ff ff ff       	call   80148d <fsipc>
}
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	53                   	push   %ebx
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	8b 40 0c             	mov    0xc(%eax),%eax
  801534:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 05 00 00 00       	mov    $0x5,%eax
  801543:	e8 45 ff ff ff       	call   80148d <fsipc>
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 2c                	js     801578 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	68 00 50 80 00       	push   $0x805000
  801554:	53                   	push   %ebx
  801555:	e8 90 f3 ff ff       	call   8008ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80155a:	a1 80 50 80 00       	mov    0x805080,%eax
  80155f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801565:	a1 84 50 80 00       	mov    0x805084,%eax
  80156a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801583:	68 bc 24 80 00       	push   $0x8024bc
  801588:	68 90 00 00 00       	push   $0x90
  80158d:	68 da 24 80 00       	push   $0x8024da
  801592:	e8 4e ec ff ff       	call   8001e5 <_panic>

00801597 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
  80159c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80159f:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015aa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ba:	e8 ce fe ff ff       	call   80148d <fsipc>
  8015bf:	89 c3                	mov    %eax,%ebx
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 4b                	js     801610 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015c5:	39 c6                	cmp    %eax,%esi
  8015c7:	73 16                	jae    8015df <devfile_read+0x48>
  8015c9:	68 e5 24 80 00       	push   $0x8024e5
  8015ce:	68 ec 24 80 00       	push   $0x8024ec
  8015d3:	6a 7c                	push   $0x7c
  8015d5:	68 da 24 80 00       	push   $0x8024da
  8015da:	e8 06 ec ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  8015df:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e4:	7e 16                	jle    8015fc <devfile_read+0x65>
  8015e6:	68 01 25 80 00       	push   $0x802501
  8015eb:	68 ec 24 80 00       	push   $0x8024ec
  8015f0:	6a 7d                	push   $0x7d
  8015f2:	68 da 24 80 00       	push   $0x8024da
  8015f7:	e8 e9 eb ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	50                   	push   %eax
  801600:	68 00 50 80 00       	push   $0x805000
  801605:	ff 75 0c             	pushl  0xc(%ebp)
  801608:	e8 6f f4 ff ff       	call   800a7c <memmove>
	return r;
  80160d:	83 c4 10             	add    $0x10,%esp
}
  801610:	89 d8                	mov    %ebx,%eax
  801612:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	53                   	push   %ebx
  80161d:	83 ec 20             	sub    $0x20,%esp
  801620:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801623:	53                   	push   %ebx
  801624:	e8 88 f2 ff ff       	call   8008b1 <strlen>
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801631:	7f 67                	jg     80169a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	e8 c6 f8 ff ff       	call   800f05 <fd_alloc>
  80163f:	83 c4 10             	add    $0x10,%esp
		return r;
  801642:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801644:	85 c0                	test   %eax,%eax
  801646:	78 57                	js     80169f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	53                   	push   %ebx
  80164c:	68 00 50 80 00       	push   $0x805000
  801651:	e8 94 f2 ff ff       	call   8008ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801656:	8b 45 0c             	mov    0xc(%ebp),%eax
  801659:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80165e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801661:	b8 01 00 00 00       	mov    $0x1,%eax
  801666:	e8 22 fe ff ff       	call   80148d <fsipc>
  80166b:	89 c3                	mov    %eax,%ebx
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	79 14                	jns    801688 <open+0x6f>
		fd_close(fd, 0);
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	6a 00                	push   $0x0
  801679:	ff 75 f4             	pushl  -0xc(%ebp)
  80167c:	e8 7c f9 ff ff       	call   800ffd <fd_close>
		return r;
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	89 da                	mov    %ebx,%edx
  801686:	eb 17                	jmp    80169f <open+0x86>
	}

	return fd2num(fd);
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	ff 75 f4             	pushl  -0xc(%ebp)
  80168e:	e8 4b f8 ff ff       	call   800ede <fd2num>
  801693:	89 c2                	mov    %eax,%edx
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	eb 05                	jmp    80169f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80169a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80169f:	89 d0                	mov    %edx,%eax
  8016a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8016b6:	e8 d2 fd ff ff       	call   80148d <fsipc>
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016bd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016c1:	7e 37                	jle    8016fa <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016cc:	ff 70 04             	pushl  0x4(%eax)
  8016cf:	8d 40 10             	lea    0x10(%eax),%eax
  8016d2:	50                   	push   %eax
  8016d3:	ff 33                	pushl  (%ebx)
  8016d5:	e8 ba fb ff ff       	call   801294 <write>
		if (result > 0)
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	7e 03                	jle    8016e4 <writebuf+0x27>
			b->result += result;
  8016e1:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016e4:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016e7:	74 0d                	je     8016f6 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f0:	0f 4f c2             	cmovg  %edx,%eax
  8016f3:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f9:	c9                   	leave  
  8016fa:	f3 c3                	repz ret 

008016fc <putch>:

static void
putch(int ch, void *thunk)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801706:	8b 53 04             	mov    0x4(%ebx),%edx
  801709:	8d 42 01             	lea    0x1(%edx),%eax
  80170c:	89 43 04             	mov    %eax,0x4(%ebx)
  80170f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801712:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801716:	3d 00 01 00 00       	cmp    $0x100,%eax
  80171b:	75 0e                	jne    80172b <putch+0x2f>
		writebuf(b);
  80171d:	89 d8                	mov    %ebx,%eax
  80171f:	e8 99 ff ff ff       	call   8016bd <writebuf>
		b->idx = 0;
  801724:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80172b:	83 c4 04             	add    $0x4,%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
  80173d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801743:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80174a:	00 00 00 
	b.result = 0;
  80174d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801754:	00 00 00 
	b.error = 1;
  801757:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80175e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801761:	ff 75 10             	pushl  0x10(%ebp)
  801764:	ff 75 0c             	pushl  0xc(%ebp)
  801767:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80176d:	50                   	push   %eax
  80176e:	68 fc 16 80 00       	push   $0x8016fc
  801773:	e8 43 ec ff ff       	call   8003bb <vprintfmt>
	if (b.idx > 0)
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801782:	7e 0b                	jle    80178f <vfprintf+0x5e>
		writebuf(&b);
  801784:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80178a:	e8 2e ff ff ff       	call   8016bd <writebuf>

	return (b.result ? b.result : b.error);
  80178f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801795:	85 c0                	test   %eax,%eax
  801797:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017a6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017a9:	50                   	push   %eax
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	ff 75 08             	pushl  0x8(%ebp)
  8017b0:	e8 7c ff ff ff       	call   801731 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <printf>:

int
printf(const char *fmt, ...)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017c0:	50                   	push   %eax
  8017c1:	ff 75 08             	pushl  0x8(%ebp)
  8017c4:	6a 01                	push   $0x1
  8017c6:	e8 66 ff ff ff       	call   801731 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
  8017d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	ff 75 08             	pushl  0x8(%ebp)
  8017db:	e8 0e f7 ff ff       	call   800eee <fd2data>
  8017e0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017e2:	83 c4 08             	add    $0x8,%esp
  8017e5:	68 0d 25 80 00       	push   $0x80250d
  8017ea:	53                   	push   %ebx
  8017eb:	e8 fa f0 ff ff       	call   8008ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017f0:	8b 46 04             	mov    0x4(%esi),%eax
  8017f3:	2b 06                	sub    (%esi),%eax
  8017f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801802:	00 00 00 
	stat->st_dev = &devpipe;
  801805:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  80180c:	30 80 00 
	return 0;
}
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801825:	53                   	push   %ebx
  801826:	6a 00                	push   $0x0
  801828:	e8 45 f5 ff ff       	call   800d72 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 b9 f6 ff ff       	call   800eee <fd2data>
  801835:	83 c4 08             	add    $0x8,%esp
  801838:	50                   	push   %eax
  801839:	6a 00                	push   $0x0
  80183b:	e8 32 f5 ff ff       	call   800d72 <sys_page_unmap>
}
  801840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	57                   	push   %edi
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	83 ec 1c             	sub    $0x1c,%esp
  80184e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801851:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801853:	a1 08 40 80 00       	mov    0x804008,%eax
  801858:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	ff 75 e0             	pushl  -0x20(%ebp)
  801861:	e8 48 05 00 00       	call   801dae <pageref>
  801866:	89 c3                	mov    %eax,%ebx
  801868:	89 3c 24             	mov    %edi,(%esp)
  80186b:	e8 3e 05 00 00       	call   801dae <pageref>
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	39 c3                	cmp    %eax,%ebx
  801875:	0f 94 c1             	sete   %cl
  801878:	0f b6 c9             	movzbl %cl,%ecx
  80187b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80187e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801884:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801887:	39 ce                	cmp    %ecx,%esi
  801889:	74 1b                	je     8018a6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80188b:	39 c3                	cmp    %eax,%ebx
  80188d:	75 c4                	jne    801853 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80188f:	8b 42 58             	mov    0x58(%edx),%eax
  801892:	ff 75 e4             	pushl  -0x1c(%ebp)
  801895:	50                   	push   %eax
  801896:	56                   	push   %esi
  801897:	68 14 25 80 00       	push   $0x802514
  80189c:	e8 1d ea ff ff       	call   8002be <cprintf>
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	eb ad                	jmp    801853 <_pipeisclosed+0xe>
	}
}
  8018a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5e                   	pop    %esi
  8018ae:	5f                   	pop    %edi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	57                   	push   %edi
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 28             	sub    $0x28,%esp
  8018ba:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018bd:	56                   	push   %esi
  8018be:	e8 2b f6 ff ff       	call   800eee <fd2data>
  8018c3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8018cd:	eb 4b                	jmp    80191a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018cf:	89 da                	mov    %ebx,%edx
  8018d1:	89 f0                	mov    %esi,%eax
  8018d3:	e8 6d ff ff ff       	call   801845 <_pipeisclosed>
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	75 48                	jne    801924 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018dc:	e8 ed f3 ff ff       	call   800cce <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8018e4:	8b 0b                	mov    (%ebx),%ecx
  8018e6:	8d 51 20             	lea    0x20(%ecx),%edx
  8018e9:	39 d0                	cmp    %edx,%eax
  8018eb:	73 e2                	jae    8018cf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018f4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018f7:	89 c2                	mov    %eax,%edx
  8018f9:	c1 fa 1f             	sar    $0x1f,%edx
  8018fc:	89 d1                	mov    %edx,%ecx
  8018fe:	c1 e9 1b             	shr    $0x1b,%ecx
  801901:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801904:	83 e2 1f             	and    $0x1f,%edx
  801907:	29 ca                	sub    %ecx,%edx
  801909:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80190d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801911:	83 c0 01             	add    $0x1,%eax
  801914:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801917:	83 c7 01             	add    $0x1,%edi
  80191a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80191d:	75 c2                	jne    8018e1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80191f:	8b 45 10             	mov    0x10(%ebp),%eax
  801922:	eb 05                	jmp    801929 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801924:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801929:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5f                   	pop    %edi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	57                   	push   %edi
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
  801937:	83 ec 18             	sub    $0x18,%esp
  80193a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80193d:	57                   	push   %edi
  80193e:	e8 ab f5 ff ff       	call   800eee <fd2data>
  801943:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	bb 00 00 00 00       	mov    $0x0,%ebx
  80194d:	eb 3d                	jmp    80198c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80194f:	85 db                	test   %ebx,%ebx
  801951:	74 04                	je     801957 <devpipe_read+0x26>
				return i;
  801953:	89 d8                	mov    %ebx,%eax
  801955:	eb 44                	jmp    80199b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801957:	89 f2                	mov    %esi,%edx
  801959:	89 f8                	mov    %edi,%eax
  80195b:	e8 e5 fe ff ff       	call   801845 <_pipeisclosed>
  801960:	85 c0                	test   %eax,%eax
  801962:	75 32                	jne    801996 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801964:	e8 65 f3 ff ff       	call   800cce <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801969:	8b 06                	mov    (%esi),%eax
  80196b:	3b 46 04             	cmp    0x4(%esi),%eax
  80196e:	74 df                	je     80194f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801970:	99                   	cltd   
  801971:	c1 ea 1b             	shr    $0x1b,%edx
  801974:	01 d0                	add    %edx,%eax
  801976:	83 e0 1f             	and    $0x1f,%eax
  801979:	29 d0                	sub    %edx,%eax
  80197b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801980:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801983:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801986:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801989:	83 c3 01             	add    $0x1,%ebx
  80198c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80198f:	75 d8                	jne    801969 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801991:	8b 45 10             	mov    0x10(%ebp),%eax
  801994:	eb 05                	jmp    80199b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801996:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80199b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5f                   	pop    %edi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ae:	50                   	push   %eax
  8019af:	e8 51 f5 ff ff       	call   800f05 <fd_alloc>
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	89 c2                	mov    %eax,%edx
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	0f 88 2c 01 00 00    	js     801aed <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	68 07 04 00 00       	push   $0x407
  8019c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cc:	6a 00                	push   $0x0
  8019ce:	e8 1a f3 ff ff       	call   800ced <sys_page_alloc>
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	89 c2                	mov    %eax,%edx
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	0f 88 0d 01 00 00    	js     801aed <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e6:	50                   	push   %eax
  8019e7:	e8 19 f5 ff ff       	call   800f05 <fd_alloc>
  8019ec:	89 c3                	mov    %eax,%ebx
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	0f 88 e2 00 00 00    	js     801adb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f9:	83 ec 04             	sub    $0x4,%esp
  8019fc:	68 07 04 00 00       	push   $0x407
  801a01:	ff 75 f0             	pushl  -0x10(%ebp)
  801a04:	6a 00                	push   $0x0
  801a06:	e8 e2 f2 ff ff       	call   800ced <sys_page_alloc>
  801a0b:	89 c3                	mov    %eax,%ebx
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	85 c0                	test   %eax,%eax
  801a12:	0f 88 c3 00 00 00    	js     801adb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1e:	e8 cb f4 ff ff       	call   800eee <fd2data>
  801a23:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a25:	83 c4 0c             	add    $0xc,%esp
  801a28:	68 07 04 00 00       	push   $0x407
  801a2d:	50                   	push   %eax
  801a2e:	6a 00                	push   $0x0
  801a30:	e8 b8 f2 ff ff       	call   800ced <sys_page_alloc>
  801a35:	89 c3                	mov    %eax,%ebx
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	0f 88 89 00 00 00    	js     801acb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	ff 75 f0             	pushl  -0x10(%ebp)
  801a48:	e8 a1 f4 ff ff       	call   800eee <fd2data>
  801a4d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a54:	50                   	push   %eax
  801a55:	6a 00                	push   $0x0
  801a57:	56                   	push   %esi
  801a58:	6a 00                	push   $0x0
  801a5a:	e8 d1 f2 ff ff       	call   800d30 <sys_page_map>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	83 c4 20             	add    $0x20,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 55                	js     801abd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a68:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a71:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a7d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a86:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	e8 41 f4 ff ff       	call   800ede <fd2num>
  801a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aa2:	83 c4 04             	add    $0x4,%esp
  801aa5:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa8:	e8 31 f4 ff ff       	call   800ede <fd2num>
  801aad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  801abb:	eb 30                	jmp    801aed <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801abd:	83 ec 08             	sub    $0x8,%esp
  801ac0:	56                   	push   %esi
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 aa f2 ff ff       	call   800d72 <sys_page_unmap>
  801ac8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801acb:	83 ec 08             	sub    $0x8,%esp
  801ace:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad1:	6a 00                	push   $0x0
  801ad3:	e8 9a f2 ff ff       	call   800d72 <sys_page_unmap>
  801ad8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 8a f2 ff ff       	call   800d72 <sys_page_unmap>
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801aed:	89 d0                	mov    %edx,%eax
  801aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801afc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aff:	50                   	push   %eax
  801b00:	ff 75 08             	pushl  0x8(%ebp)
  801b03:	e8 4c f4 ff ff       	call   800f54 <fd_lookup>
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 18                	js     801b27 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	ff 75 f4             	pushl  -0xc(%ebp)
  801b15:	e8 d4 f3 ff ff       	call   800eee <fd2data>
	return _pipeisclosed(fd, p);
  801b1a:	89 c2                	mov    %eax,%edx
  801b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1f:	e8 21 fd ff ff       	call   801845 <_pipeisclosed>
  801b24:	83 c4 10             	add    $0x10,%esp
}
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b39:	68 2c 25 80 00       	push   $0x80252c
  801b3e:	ff 75 0c             	pushl  0xc(%ebp)
  801b41:	e8 a4 ed ff ff       	call   8008ea <strcpy>
	return 0;
}
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	57                   	push   %edi
  801b51:	56                   	push   %esi
  801b52:	53                   	push   %ebx
  801b53:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b59:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b5e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b64:	eb 2d                	jmp    801b93 <devcons_write+0x46>
		m = n - tot;
  801b66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b69:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b6b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b6e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b73:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b76:	83 ec 04             	sub    $0x4,%esp
  801b79:	53                   	push   %ebx
  801b7a:	03 45 0c             	add    0xc(%ebp),%eax
  801b7d:	50                   	push   %eax
  801b7e:	57                   	push   %edi
  801b7f:	e8 f8 ee ff ff       	call   800a7c <memmove>
		sys_cputs(buf, m);
  801b84:	83 c4 08             	add    $0x8,%esp
  801b87:	53                   	push   %ebx
  801b88:	57                   	push   %edi
  801b89:	e8 a3 f0 ff ff       	call   800c31 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b8e:	01 de                	add    %ebx,%esi
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	89 f0                	mov    %esi,%eax
  801b95:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b98:	72 cc                	jb     801b66 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5f                   	pop    %edi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 08             	sub    $0x8,%esp
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801bad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bb1:	74 2a                	je     801bdd <devcons_read+0x3b>
  801bb3:	eb 05                	jmp    801bba <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bb5:	e8 14 f1 ff ff       	call   800cce <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bba:	e8 90 f0 ff ff       	call   800c4f <sys_cgetc>
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	74 f2                	je     801bb5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	78 16                	js     801bdd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bc7:	83 f8 04             	cmp    $0x4,%eax
  801bca:	74 0c                	je     801bd8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bcf:	88 02                	mov    %al,(%edx)
	return 1;
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	eb 05                	jmp    801bdd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801beb:	6a 01                	push   $0x1
  801bed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bf0:	50                   	push   %eax
  801bf1:	e8 3b f0 ff ff       	call   800c31 <sys_cputs>
}
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <getchar>:

int
getchar(void)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c01:	6a 01                	push   $0x1
  801c03:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c06:	50                   	push   %eax
  801c07:	6a 00                	push   $0x0
  801c09:	e8 ac f5 ff ff       	call   8011ba <read>
	if (r < 0)
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 0f                	js     801c24 <getchar+0x29>
		return r;
	if (r < 1)
  801c15:	85 c0                	test   %eax,%eax
  801c17:	7e 06                	jle    801c1f <getchar+0x24>
		return -E_EOF;
	return c;
  801c19:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c1d:	eb 05                	jmp    801c24 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c1f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c24:	c9                   	leave  
  801c25:	c3                   	ret    

00801c26 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2f:	50                   	push   %eax
  801c30:	ff 75 08             	pushl  0x8(%ebp)
  801c33:	e8 1c f3 ff ff       	call   800f54 <fd_lookup>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	78 11                	js     801c50 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c42:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c48:	39 10                	cmp    %edx,(%eax)
  801c4a:	0f 94 c0             	sete   %al
  801c4d:	0f b6 c0             	movzbl %al,%eax
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <opencons>:

int
opencons(void)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5b:	50                   	push   %eax
  801c5c:	e8 a4 f2 ff ff       	call   800f05 <fd_alloc>
  801c61:	83 c4 10             	add    $0x10,%esp
		return r;
  801c64:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 3e                	js     801ca8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	68 07 04 00 00       	push   $0x407
  801c72:	ff 75 f4             	pushl  -0xc(%ebp)
  801c75:	6a 00                	push   $0x0
  801c77:	e8 71 f0 ff ff       	call   800ced <sys_page_alloc>
  801c7c:	83 c4 10             	add    $0x10,%esp
		return r;
  801c7f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 23                	js     801ca8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c85:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c93:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c9a:	83 ec 0c             	sub    $0xc,%esp
  801c9d:	50                   	push   %eax
  801c9e:	e8 3b f2 ff ff       	call   800ede <fd2num>
  801ca3:	89 c2                	mov    %eax,%edx
  801ca5:	83 c4 10             	add    $0x10,%esp
}
  801ca8:	89 d0                	mov    %edx,%eax
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	56                   	push   %esi
  801cb0:	53                   	push   %ebx
  801cb1:	8b 75 08             	mov    0x8(%ebp),%esi
  801cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	74 0e                	je     801ccc <ipc_recv+0x20>
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	50                   	push   %eax
  801cc2:	e8 d6 f1 ff ff       	call   800e9d <sys_ipc_recv>
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	eb 10                	jmp    801cdc <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801ccc:	83 ec 0c             	sub    $0xc,%esp
  801ccf:	68 00 00 c0 ee       	push   $0xeec00000
  801cd4:	e8 c4 f1 ff ff       	call   800e9d <sys_ipc_recv>
  801cd9:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	74 16                	je     801cf6 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801ce0:	85 f6                	test   %esi,%esi
  801ce2:	74 06                	je     801cea <ipc_recv+0x3e>
  801ce4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801cea:	85 db                	test   %ebx,%ebx
  801cec:	74 2c                	je     801d1a <ipc_recv+0x6e>
  801cee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cf4:	eb 24                	jmp    801d1a <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801cf6:	85 f6                	test   %esi,%esi
  801cf8:	74 0a                	je     801d04 <ipc_recv+0x58>
  801cfa:	a1 08 40 80 00       	mov    0x804008,%eax
  801cff:	8b 40 74             	mov    0x74(%eax),%eax
  801d02:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801d04:	85 db                	test   %ebx,%ebx
  801d06:	74 0a                	je     801d12 <ipc_recv+0x66>
  801d08:	a1 08 40 80 00       	mov    0x804008,%eax
  801d0d:	8b 40 78             	mov    0x78(%eax),%eax
  801d10:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d12:	a1 08 40 80 00       	mov    0x804008,%eax
  801d17:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	57                   	push   %edi
  801d25:	56                   	push   %esi
  801d26:	53                   	push   %ebx
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d30:	8b 45 10             	mov    0x10(%ebp),%eax
  801d33:	85 c0                	test   %eax,%eax
  801d35:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801d3a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801d3d:	ff 75 14             	pushl  0x14(%ebp)
  801d40:	53                   	push   %ebx
  801d41:	56                   	push   %esi
  801d42:	57                   	push   %edi
  801d43:	e8 32 f1 ff ff       	call   800e7a <sys_ipc_try_send>
		if (ret == 0) break;
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	74 1e                	je     801d6d <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801d4f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d52:	74 12                	je     801d66 <ipc_send+0x45>
  801d54:	50                   	push   %eax
  801d55:	68 38 25 80 00       	push   $0x802538
  801d5a:	6a 39                	push   $0x39
  801d5c:	68 45 25 80 00       	push   $0x802545
  801d61:	e8 7f e4 ff ff       	call   8001e5 <_panic>
		sys_yield();
  801d66:	e8 63 ef ff ff       	call   800cce <sys_yield>
	}
  801d6b:	eb d0                	jmp    801d3d <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5f                   	pop    %edi
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d80:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d83:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d89:	8b 52 50             	mov    0x50(%edx),%edx
  801d8c:	39 ca                	cmp    %ecx,%edx
  801d8e:	75 0d                	jne    801d9d <ipc_find_env+0x28>
			return envs[i].env_id;
  801d90:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d93:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d98:	8b 40 48             	mov    0x48(%eax),%eax
  801d9b:	eb 0f                	jmp    801dac <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d9d:	83 c0 01             	add    $0x1,%eax
  801da0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801da5:	75 d9                	jne    801d80 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801db4:	89 d0                	mov    %edx,%eax
  801db6:	c1 e8 16             	shr    $0x16,%eax
  801db9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dc0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dc5:	f6 c1 01             	test   $0x1,%cl
  801dc8:	74 1d                	je     801de7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801dca:	c1 ea 0c             	shr    $0xc,%edx
  801dcd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dd4:	f6 c2 01             	test   $0x1,%dl
  801dd7:	74 0e                	je     801de7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dd9:	c1 ea 0c             	shr    $0xc,%edx
  801ddc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801de3:	ef 
  801de4:	0f b7 c0             	movzwl %ax,%eax
}
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
  801de9:	66 90                	xchg   %ax,%ax
  801deb:	66 90                	xchg   %ax,%ax
  801ded:	66 90                	xchg   %ax,%ax
  801def:	90                   	nop

00801df0 <__udivdi3>:
  801df0:	55                   	push   %ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	83 ec 1c             	sub    $0x1c,%esp
  801df7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801dfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801dff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e07:	85 f6                	test   %esi,%esi
  801e09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e0d:	89 ca                	mov    %ecx,%edx
  801e0f:	89 f8                	mov    %edi,%eax
  801e11:	75 3d                	jne    801e50 <__udivdi3+0x60>
  801e13:	39 cf                	cmp    %ecx,%edi
  801e15:	0f 87 c5 00 00 00    	ja     801ee0 <__udivdi3+0xf0>
  801e1b:	85 ff                	test   %edi,%edi
  801e1d:	89 fd                	mov    %edi,%ebp
  801e1f:	75 0b                	jne    801e2c <__udivdi3+0x3c>
  801e21:	b8 01 00 00 00       	mov    $0x1,%eax
  801e26:	31 d2                	xor    %edx,%edx
  801e28:	f7 f7                	div    %edi
  801e2a:	89 c5                	mov    %eax,%ebp
  801e2c:	89 c8                	mov    %ecx,%eax
  801e2e:	31 d2                	xor    %edx,%edx
  801e30:	f7 f5                	div    %ebp
  801e32:	89 c1                	mov    %eax,%ecx
  801e34:	89 d8                	mov    %ebx,%eax
  801e36:	89 cf                	mov    %ecx,%edi
  801e38:	f7 f5                	div    %ebp
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	89 d8                	mov    %ebx,%eax
  801e3e:	89 fa                	mov    %edi,%edx
  801e40:	83 c4 1c             	add    $0x1c,%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5f                   	pop    %edi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    
  801e48:	90                   	nop
  801e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e50:	39 ce                	cmp    %ecx,%esi
  801e52:	77 74                	ja     801ec8 <__udivdi3+0xd8>
  801e54:	0f bd fe             	bsr    %esi,%edi
  801e57:	83 f7 1f             	xor    $0x1f,%edi
  801e5a:	0f 84 98 00 00 00    	je     801ef8 <__udivdi3+0x108>
  801e60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e65:	89 f9                	mov    %edi,%ecx
  801e67:	89 c5                	mov    %eax,%ebp
  801e69:	29 fb                	sub    %edi,%ebx
  801e6b:	d3 e6                	shl    %cl,%esi
  801e6d:	89 d9                	mov    %ebx,%ecx
  801e6f:	d3 ed                	shr    %cl,%ebp
  801e71:	89 f9                	mov    %edi,%ecx
  801e73:	d3 e0                	shl    %cl,%eax
  801e75:	09 ee                	or     %ebp,%esi
  801e77:	89 d9                	mov    %ebx,%ecx
  801e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e7d:	89 d5                	mov    %edx,%ebp
  801e7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e83:	d3 ed                	shr    %cl,%ebp
  801e85:	89 f9                	mov    %edi,%ecx
  801e87:	d3 e2                	shl    %cl,%edx
  801e89:	89 d9                	mov    %ebx,%ecx
  801e8b:	d3 e8                	shr    %cl,%eax
  801e8d:	09 c2                	or     %eax,%edx
  801e8f:	89 d0                	mov    %edx,%eax
  801e91:	89 ea                	mov    %ebp,%edx
  801e93:	f7 f6                	div    %esi
  801e95:	89 d5                	mov    %edx,%ebp
  801e97:	89 c3                	mov    %eax,%ebx
  801e99:	f7 64 24 0c          	mull   0xc(%esp)
  801e9d:	39 d5                	cmp    %edx,%ebp
  801e9f:	72 10                	jb     801eb1 <__udivdi3+0xc1>
  801ea1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ea5:	89 f9                	mov    %edi,%ecx
  801ea7:	d3 e6                	shl    %cl,%esi
  801ea9:	39 c6                	cmp    %eax,%esi
  801eab:	73 07                	jae    801eb4 <__udivdi3+0xc4>
  801ead:	39 d5                	cmp    %edx,%ebp
  801eaf:	75 03                	jne    801eb4 <__udivdi3+0xc4>
  801eb1:	83 eb 01             	sub    $0x1,%ebx
  801eb4:	31 ff                	xor    %edi,%edi
  801eb6:	89 d8                	mov    %ebx,%eax
  801eb8:	89 fa                	mov    %edi,%edx
  801eba:	83 c4 1c             	add    $0x1c,%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    
  801ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ec8:	31 ff                	xor    %edi,%edi
  801eca:	31 db                	xor    %ebx,%ebx
  801ecc:	89 d8                	mov    %ebx,%eax
  801ece:	89 fa                	mov    %edi,%edx
  801ed0:	83 c4 1c             	add    $0x1c,%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5f                   	pop    %edi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    
  801ed8:	90                   	nop
  801ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee0:	89 d8                	mov    %ebx,%eax
  801ee2:	f7 f7                	div    %edi
  801ee4:	31 ff                	xor    %edi,%edi
  801ee6:	89 c3                	mov    %eax,%ebx
  801ee8:	89 d8                	mov    %ebx,%eax
  801eea:	89 fa                	mov    %edi,%edx
  801eec:	83 c4 1c             	add    $0x1c,%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5f                   	pop    %edi
  801ef2:	5d                   	pop    %ebp
  801ef3:	c3                   	ret    
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	39 ce                	cmp    %ecx,%esi
  801efa:	72 0c                	jb     801f08 <__udivdi3+0x118>
  801efc:	31 db                	xor    %ebx,%ebx
  801efe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f02:	0f 87 34 ff ff ff    	ja     801e3c <__udivdi3+0x4c>
  801f08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f0d:	e9 2a ff ff ff       	jmp    801e3c <__udivdi3+0x4c>
  801f12:	66 90                	xchg   %ax,%ax
  801f14:	66 90                	xchg   %ax,%ax
  801f16:	66 90                	xchg   %ax,%ax
  801f18:	66 90                	xchg   %ax,%ax
  801f1a:	66 90                	xchg   %ax,%ax
  801f1c:	66 90                	xchg   %ax,%ax
  801f1e:	66 90                	xchg   %ax,%ax

00801f20 <__umoddi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 d2                	test   %edx,%edx
  801f39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f41:	89 f3                	mov    %esi,%ebx
  801f43:	89 3c 24             	mov    %edi,(%esp)
  801f46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f4a:	75 1c                	jne    801f68 <__umoddi3+0x48>
  801f4c:	39 f7                	cmp    %esi,%edi
  801f4e:	76 50                	jbe    801fa0 <__umoddi3+0x80>
  801f50:	89 c8                	mov    %ecx,%eax
  801f52:	89 f2                	mov    %esi,%edx
  801f54:	f7 f7                	div    %edi
  801f56:	89 d0                	mov    %edx,%eax
  801f58:	31 d2                	xor    %edx,%edx
  801f5a:	83 c4 1c             	add    $0x1c,%esp
  801f5d:	5b                   	pop    %ebx
  801f5e:	5e                   	pop    %esi
  801f5f:	5f                   	pop    %edi
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    
  801f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f68:	39 f2                	cmp    %esi,%edx
  801f6a:	89 d0                	mov    %edx,%eax
  801f6c:	77 52                	ja     801fc0 <__umoddi3+0xa0>
  801f6e:	0f bd ea             	bsr    %edx,%ebp
  801f71:	83 f5 1f             	xor    $0x1f,%ebp
  801f74:	75 5a                	jne    801fd0 <__umoddi3+0xb0>
  801f76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f7a:	0f 82 e0 00 00 00    	jb     802060 <__umoddi3+0x140>
  801f80:	39 0c 24             	cmp    %ecx,(%esp)
  801f83:	0f 86 d7 00 00 00    	jbe    802060 <__umoddi3+0x140>
  801f89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f91:	83 c4 1c             	add    $0x1c,%esp
  801f94:	5b                   	pop    %ebx
  801f95:	5e                   	pop    %esi
  801f96:	5f                   	pop    %edi
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	85 ff                	test   %edi,%edi
  801fa2:	89 fd                	mov    %edi,%ebp
  801fa4:	75 0b                	jne    801fb1 <__umoddi3+0x91>
  801fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fab:	31 d2                	xor    %edx,%edx
  801fad:	f7 f7                	div    %edi
  801faf:	89 c5                	mov    %eax,%ebp
  801fb1:	89 f0                	mov    %esi,%eax
  801fb3:	31 d2                	xor    %edx,%edx
  801fb5:	f7 f5                	div    %ebp
  801fb7:	89 c8                	mov    %ecx,%eax
  801fb9:	f7 f5                	div    %ebp
  801fbb:	89 d0                	mov    %edx,%eax
  801fbd:	eb 99                	jmp    801f58 <__umoddi3+0x38>
  801fbf:	90                   	nop
  801fc0:	89 c8                	mov    %ecx,%eax
  801fc2:	89 f2                	mov    %esi,%edx
  801fc4:	83 c4 1c             	add    $0x1c,%esp
  801fc7:	5b                   	pop    %ebx
  801fc8:	5e                   	pop    %esi
  801fc9:	5f                   	pop    %edi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    
  801fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	8b 34 24             	mov    (%esp),%esi
  801fd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801fd8:	89 e9                	mov    %ebp,%ecx
  801fda:	29 ef                	sub    %ebp,%edi
  801fdc:	d3 e0                	shl    %cl,%eax
  801fde:	89 f9                	mov    %edi,%ecx
  801fe0:	89 f2                	mov    %esi,%edx
  801fe2:	d3 ea                	shr    %cl,%edx
  801fe4:	89 e9                	mov    %ebp,%ecx
  801fe6:	09 c2                	or     %eax,%edx
  801fe8:	89 d8                	mov    %ebx,%eax
  801fea:	89 14 24             	mov    %edx,(%esp)
  801fed:	89 f2                	mov    %esi,%edx
  801fef:	d3 e2                	shl    %cl,%edx
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ff7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	89 e9                	mov    %ebp,%ecx
  801fff:	89 c6                	mov    %eax,%esi
  802001:	d3 e3                	shl    %cl,%ebx
  802003:	89 f9                	mov    %edi,%ecx
  802005:	89 d0                	mov    %edx,%eax
  802007:	d3 e8                	shr    %cl,%eax
  802009:	89 e9                	mov    %ebp,%ecx
  80200b:	09 d8                	or     %ebx,%eax
  80200d:	89 d3                	mov    %edx,%ebx
  80200f:	89 f2                	mov    %esi,%edx
  802011:	f7 34 24             	divl   (%esp)
  802014:	89 d6                	mov    %edx,%esi
  802016:	d3 e3                	shl    %cl,%ebx
  802018:	f7 64 24 04          	mull   0x4(%esp)
  80201c:	39 d6                	cmp    %edx,%esi
  80201e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802022:	89 d1                	mov    %edx,%ecx
  802024:	89 c3                	mov    %eax,%ebx
  802026:	72 08                	jb     802030 <__umoddi3+0x110>
  802028:	75 11                	jne    80203b <__umoddi3+0x11b>
  80202a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80202e:	73 0b                	jae    80203b <__umoddi3+0x11b>
  802030:	2b 44 24 04          	sub    0x4(%esp),%eax
  802034:	1b 14 24             	sbb    (%esp),%edx
  802037:	89 d1                	mov    %edx,%ecx
  802039:	89 c3                	mov    %eax,%ebx
  80203b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80203f:	29 da                	sub    %ebx,%edx
  802041:	19 ce                	sbb    %ecx,%esi
  802043:	89 f9                	mov    %edi,%ecx
  802045:	89 f0                	mov    %esi,%eax
  802047:	d3 e0                	shl    %cl,%eax
  802049:	89 e9                	mov    %ebp,%ecx
  80204b:	d3 ea                	shr    %cl,%edx
  80204d:	89 e9                	mov    %ebp,%ecx
  80204f:	d3 ee                	shr    %cl,%esi
  802051:	09 d0                	or     %edx,%eax
  802053:	89 f2                	mov    %esi,%edx
  802055:	83 c4 1c             	add    $0x1c,%esp
  802058:	5b                   	pop    %ebx
  802059:	5e                   	pop    %esi
  80205a:	5f                   	pop    %edi
  80205b:	5d                   	pop    %ebp
  80205c:	c3                   	ret    
  80205d:	8d 76 00             	lea    0x0(%esi),%esi
  802060:	29 f9                	sub    %edi,%ecx
  802062:	19 d6                	sbb    %edx,%esi
  802064:	89 74 24 04          	mov    %esi,0x4(%esp)
  802068:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80206c:	e9 18 ff ff ff       	jmp    801f89 <__umoddi3+0x69>
