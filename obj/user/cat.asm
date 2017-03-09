
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 f5 11 00 00       	call   801242 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 40 20 80 00       	push   $0x802040
  800060:	6a 0d                	push   $0xd
  800062:	68 5b 20 80 00       	push   $0x80205b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 e9 10 00 00       	call   801168 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 66 20 80 00       	push   $0x802066
  800098:	6a 0f                	push   $0xf
  80009a:	68 5b 20 80 00       	push   $0x80205b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 7b 	movl   $0x80207b,0x803000
  8000be:	20 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 7f 20 80 00       	push   $0x80207f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 da 14 00 00       	call   8015c7 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 87 20 80 00       	push   $0x802087
  800102:	e8 5e 16 00 00       	call   801765 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 0c 0f 00 00       	call   80102c <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  80013e:	e8 1a 0b 00 00       	call   800c5d <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 d3 0e 00 00       	call   801057 <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 8e 0a 00 00       	call   800c1c <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 b7 0a 00 00       	call   800c5d <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 a4 20 80 00       	push   $0x8020a4
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 e5 24 80 00 	movl   $0x8024e5,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 d6 09 00 00       	call   800bdf <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 1a 01 00 00       	call   800369 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 7b 09 00 00       	call   800bdf <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 cc 1a 00 00       	call   801da0 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 b9 1b 00 00       	call   801ed0 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800335:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 0a                	jae    80034a <sprintputch+0x1b>
		*b->buf++ = ch;
  800340:	8d 4a 01             	lea    0x1(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	88 02                	mov    %al,(%edx)
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	ff 75 0c             	pushl  0xc(%ebp)
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	e8 05 00 00 00       	call   800369 <vprintfmt>
	va_end(ap);
}
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 2c             	sub    $0x2c,%esp
  800372:	8b 75 08             	mov    0x8(%ebp),%esi
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800378:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037b:	eb 12                	jmp    80038f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037d:	85 c0                	test   %eax,%eax
  80037f:	0f 84 6a 04 00 00    	je     8007ef <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	53                   	push   %ebx
  800389:	50                   	push   %eax
  80038a:	ff d6                	call   *%esi
  80038c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038f:	83 c7 01             	add    $0x1,%edi
  800392:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800396:	83 f8 25             	cmp    $0x25,%eax
  800399:	75 e2                	jne    80037d <vprintfmt+0x14>
  80039b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b9:	eb 07                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8d 47 01             	lea    0x1(%edi),%eax
  8003c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c8:	0f b6 07             	movzbl (%edi),%eax
  8003cb:	0f b6 d0             	movzbl %al,%edx
  8003ce:	83 e8 23             	sub    $0x23,%eax
  8003d1:	3c 55                	cmp    $0x55,%al
  8003d3:	0f 87 fb 03 00 00    	ja     8007d4 <vprintfmt+0x46b>
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ea:	eb d6                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fa:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003fe:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800401:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800404:	83 f9 09             	cmp    $0x9,%ecx
  800407:	77 3f                	ja     800448 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040c:	eb e9                	jmp    8003f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 00                	mov    (%eax),%eax
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 40 04             	lea    0x4(%eax),%eax
  80041c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800422:	eb 2a                	jmp    80044e <vprintfmt+0xe5>
  800424:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800427:	85 c0                	test   %eax,%eax
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
  80042e:	0f 49 d0             	cmovns %eax,%edx
  800431:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800437:	eb 89                	jmp    8003c2 <vprintfmt+0x59>
  800439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800443:	e9 7a ff ff ff       	jmp    8003c2 <vprintfmt+0x59>
  800448:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80044b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800452:	0f 89 6a ff ff ff    	jns    8003c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800458:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800465:	e9 58 ff ff ff       	jmp    8003c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800470:	e9 4d ff ff ff       	jmp    8003c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 78 04             	lea    0x4(%eax),%edi
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	ff 30                	pushl  (%eax)
  800481:	ff d6                	call   *%esi
			break;
  800483:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800486:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048c:	e9 fe fe ff ff       	jmp    80038f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 78 04             	lea    0x4(%eax),%edi
  800497:	8b 00                	mov    (%eax),%eax
  800499:	99                   	cltd   
  80049a:	31 d0                	xor    %edx,%eax
  80049c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049e:	83 f8 0f             	cmp    $0xf,%eax
  8004a1:	7f 0b                	jg     8004ae <vprintfmt+0x145>
  8004a3:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	75 1b                	jne    8004c9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004ae:	50                   	push   %eax
  8004af:	68 df 20 80 00       	push   $0x8020df
  8004b4:	53                   	push   %ebx
  8004b5:	56                   	push   %esi
  8004b6:	e8 91 fe ff ff       	call   80034c <printfmt>
  8004bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004be:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c4:	e9 c6 fe ff ff       	jmp    80038f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c9:	52                   	push   %edx
  8004ca:	68 be 24 80 00       	push   $0x8024be
  8004cf:	53                   	push   %ebx
  8004d0:	56                   	push   %esi
  8004d1:	e8 76 fe ff ff       	call   80034c <printfmt>
  8004d6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 ab fe ff ff       	jmp    80038f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	83 c0 04             	add    $0x4,%eax
  8004ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	b8 d8 20 80 00       	mov    $0x8020d8,%eax
  8004f9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	0f 8e 94 00 00 00    	jle    80059a <vprintfmt+0x231>
  800506:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050a:	0f 84 98 00 00 00    	je     8005a8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	ff 75 d0             	pushl  -0x30(%ebp)
  800516:	57                   	push   %edi
  800517:	e8 5b 03 00 00       	call   800877 <strnlen>
  80051c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800524:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800527:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800531:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	eb 0f                	jmp    800544 <vprintfmt+0x1db>
					putch(padc, putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	ff 75 e0             	pushl  -0x20(%ebp)
  80053c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ef 01             	sub    $0x1,%edi
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	85 ff                	test   %edi,%edi
  800546:	7f ed                	jg     800535 <vprintfmt+0x1cc>
  800548:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	0f 49 c1             	cmovns %ecx,%eax
  800558:	29 c1                	sub    %eax,%ecx
  80055a:	89 75 08             	mov    %esi,0x8(%ebp)
  80055d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800560:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800563:	89 cb                	mov    %ecx,%ebx
  800565:	eb 4d                	jmp    8005b4 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800567:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056b:	74 1b                	je     800588 <vprintfmt+0x21f>
  80056d:	0f be c0             	movsbl %al,%eax
  800570:	83 e8 20             	sub    $0x20,%eax
  800573:	83 f8 5e             	cmp    $0x5e,%eax
  800576:	76 10                	jbe    800588 <vprintfmt+0x21f>
					putch('?', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	ff 75 0c             	pushl  0xc(%ebp)
  80057e:	6a 3f                	push   $0x3f
  800580:	ff 55 08             	call   *0x8(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	eb 0d                	jmp    800595 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	52                   	push   %edx
  80058f:	ff 55 08             	call   *0x8(%ebp)
  800592:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800595:	83 eb 01             	sub    $0x1,%ebx
  800598:	eb 1a                	jmp    8005b4 <vprintfmt+0x24b>
  80059a:	89 75 08             	mov    %esi,0x8(%ebp)
  80059d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a6:	eb 0c                	jmp    8005b4 <vprintfmt+0x24b>
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b4:	83 c7 01             	add    $0x1,%edi
  8005b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bb:	0f be d0             	movsbl %al,%edx
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	74 23                	je     8005e5 <vprintfmt+0x27c>
  8005c2:	85 f6                	test   %esi,%esi
  8005c4:	78 a1                	js     800567 <vprintfmt+0x1fe>
  8005c6:	83 ee 01             	sub    $0x1,%esi
  8005c9:	79 9c                	jns    800567 <vprintfmt+0x1fe>
  8005cb:	89 df                	mov    %ebx,%edi
  8005cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d3:	eb 18                	jmp    8005ed <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	6a 20                	push   $0x20
  8005db:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dd:	83 ef 01             	sub    $0x1,%edi
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	eb 08                	jmp    8005ed <vprintfmt+0x284>
  8005e5:	89 df                	mov    %ebx,%edi
  8005e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	7f e4                	jg     8005d5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fa:	e9 90 fd ff ff       	jmp    80038f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ff:	83 f9 01             	cmp    $0x1,%ecx
  800602:	7e 19                	jle    80061d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 50 04             	mov    0x4(%eax),%edx
  80060a:	8b 00                	mov    (%eax),%eax
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 40 08             	lea    0x8(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
  80061b:	eb 38                	jmp    800655 <vprintfmt+0x2ec>
	else if (lflag)
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 1b                	je     80063c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800629:	89 c1                	mov    %eax,%ecx
  80062b:	c1 f9 1f             	sar    $0x1f,%ecx
  80062e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
  80063a:	eb 19                	jmp    800655 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800644:	89 c1                	mov    %eax,%ecx
  800646:	c1 f9 1f             	sar    $0x1f,%ecx
  800649:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 40 04             	lea    0x4(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800655:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800658:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800660:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800664:	0f 89 36 01 00 00    	jns    8007a0 <vprintfmt+0x437>
				putch('-', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 2d                	push   $0x2d
  800670:	ff d6                	call   *%esi
				num = -(long long) num;
  800672:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800675:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800678:	f7 da                	neg    %edx
  80067a:	83 d1 00             	adc    $0x0,%ecx
  80067d:	f7 d9                	neg    %ecx
  80067f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
  800687:	e9 14 01 00 00       	jmp    8007a0 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068c:	83 f9 01             	cmp    $0x1,%ecx
  80068f:	7e 18                	jle    8006a9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	8b 48 04             	mov    0x4(%eax),%ecx
  800699:	8d 40 08             	lea    0x8(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80069f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a4:	e9 f7 00 00 00       	jmp    8007a0 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	74 1a                	je     8006c7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c2:	e9 d9 00 00 00       	jmp    8007a0 <vprintfmt+0x437>
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

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dc:	e9 bf 00 00 00       	jmp    8007a0 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e1:	83 f9 01             	cmp    $0x1,%ecx
  8006e4:	7e 13                	jle    8006f9 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 50 04             	mov    0x4(%eax),%edx
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006f1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8006f4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006f7:	eb 28                	jmp    800721 <vprintfmt+0x3b8>
	else if (lflag)
  8006f9:	85 c9                	test   %ecx,%ecx
  8006fb:	74 13                	je     800710 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 10                	mov    (%eax),%edx
  800702:	89 d0                	mov    %edx,%eax
  800704:	99                   	cltd   
  800705:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800708:	8d 49 04             	lea    0x4(%ecx),%ecx
  80070b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80070e:	eb 11                	jmp    800721 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8b 10                	mov    (%eax),%edx
  800715:	89 d0                	mov    %edx,%eax
  800717:	99                   	cltd   
  800718:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80071b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80071e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800721:	89 d1                	mov    %edx,%ecx
  800723:	89 c2                	mov    %eax,%edx
			base = 8;
  800725:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80072a:	eb 74                	jmp    8007a0 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 30                	push   $0x30
  800732:	ff d6                	call   *%esi
			putch('x', putdat);
  800734:	83 c4 08             	add    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 78                	push   $0x78
  80073a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800746:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800749:	8d 40 04             	lea    0x4(%eax),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800754:	eb 4a                	jmp    8007a0 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800756:	83 f9 01             	cmp    $0x1,%ecx
  800759:	7e 15                	jle    800770 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8b 10                	mov    (%eax),%edx
  800760:	8b 48 04             	mov    0x4(%eax),%ecx
  800763:	8d 40 08             	lea    0x8(%eax),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800769:	b8 10 00 00 00       	mov    $0x10,%eax
  80076e:	eb 30                	jmp    8007a0 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800770:	85 c9                	test   %ecx,%ecx
  800772:	74 17                	je     80078b <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077e:	8d 40 04             	lea    0x4(%eax),%eax
  800781:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800784:	b8 10 00 00 00       	mov    $0x10,%eax
  800789:	eb 15                	jmp    8007a0 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8b 10                	mov    (%eax),%edx
  800790:	b9 00 00 00 00       	mov    $0x0,%ecx
  800795:	8d 40 04             	lea    0x4(%eax),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80079b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a0:	83 ec 0c             	sub    $0xc,%esp
  8007a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a7:	57                   	push   %edi
  8007a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ab:	50                   	push   %eax
  8007ac:	51                   	push   %ecx
  8007ad:	52                   	push   %edx
  8007ae:	89 da                	mov    %ebx,%edx
  8007b0:	89 f0                	mov    %esi,%eax
  8007b2:	e8 c9 fa ff ff       	call   800280 <printnum>
			break;
  8007b7:	83 c4 20             	add    $0x20,%esp
  8007ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bd:	e9 cd fb ff ff       	jmp    80038f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	53                   	push   %ebx
  8007c6:	52                   	push   %edx
  8007c7:	ff d6                	call   *%esi
			break;
  8007c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cf:	e9 bb fb ff ff       	jmp    80038f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	53                   	push   %ebx
  8007d8:	6a 25                	push   $0x25
  8007da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	eb 03                	jmp    8007e4 <vprintfmt+0x47b>
  8007e1:	83 ef 01             	sub    $0x1,%edi
  8007e4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e8:	75 f7                	jne    8007e1 <vprintfmt+0x478>
  8007ea:	e9 a0 fb ff ff       	jmp    80038f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5f                   	pop    %edi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	83 ec 18             	sub    $0x18,%esp
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800803:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800806:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800814:	85 c0                	test   %eax,%eax
  800816:	74 26                	je     80083e <vsnprintf+0x47>
  800818:	85 d2                	test   %edx,%edx
  80081a:	7e 22                	jle    80083e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081c:	ff 75 14             	pushl  0x14(%ebp)
  80081f:	ff 75 10             	pushl  0x10(%ebp)
  800822:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800825:	50                   	push   %eax
  800826:	68 2f 03 80 00       	push   $0x80032f
  80082b:	e8 39 fb ff ff       	call   800369 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800830:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800833:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	eb 05                	jmp    800843 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084e:	50                   	push   %eax
  80084f:	ff 75 10             	pushl  0x10(%ebp)
  800852:	ff 75 0c             	pushl  0xc(%ebp)
  800855:	ff 75 08             	pushl  0x8(%ebp)
  800858:	e8 9a ff ff ff       	call   8007f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
  80086a:	eb 03                	jmp    80086f <strlen+0x10>
		n++;
  80086c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800873:	75 f7                	jne    80086c <strlen+0xd>
		n++;
	return n;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800880:	ba 00 00 00 00       	mov    $0x0,%edx
  800885:	eb 03                	jmp    80088a <strnlen+0x13>
		n++;
  800887:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	39 c2                	cmp    %eax,%edx
  80088c:	74 08                	je     800896 <strnlen+0x1f>
  80088e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800892:	75 f3                	jne    800887 <strnlen+0x10>
  800894:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c2 01             	add    $0x1,%edx
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b1:	84 db                	test   %bl,%bl
  8008b3:	75 ef                	jne    8008a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b5:	5b                   	pop    %ebx
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bf:	53                   	push   %ebx
  8008c0:	e8 9a ff ff ff       	call   80085f <strlen>
  8008c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	01 d8                	add    %ebx,%eax
  8008cd:	50                   	push   %eax
  8008ce:	e8 c5 ff ff ff       	call   800898 <strcpy>
	return dst;
}
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	89 f3                	mov    %esi,%ebx
  8008e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ea:	89 f2                	mov    %esi,%edx
  8008ec:	eb 0f                	jmp    8008fd <strncpy+0x23>
		*dst++ = *src;
  8008ee:	83 c2 01             	add    $0x1,%edx
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f7:	80 39 01             	cmpb   $0x1,(%ecx)
  8008fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fd:	39 da                	cmp    %ebx,%edx
  8008ff:	75 ed                	jne    8008ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800901:	89 f0                	mov    %esi,%eax
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 75 08             	mov    0x8(%ebp),%esi
  80090f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800912:	8b 55 10             	mov    0x10(%ebp),%edx
  800915:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800917:	85 d2                	test   %edx,%edx
  800919:	74 21                	je     80093c <strlcpy+0x35>
  80091b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091f:	89 f2                	mov    %esi,%edx
  800921:	eb 09                	jmp    80092c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800923:	83 c2 01             	add    $0x1,%edx
  800926:	83 c1 01             	add    $0x1,%ecx
  800929:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092c:	39 c2                	cmp    %eax,%edx
  80092e:	74 09                	je     800939 <strlcpy+0x32>
  800930:	0f b6 19             	movzbl (%ecx),%ebx
  800933:	84 db                	test   %bl,%bl
  800935:	75 ec                	jne    800923 <strlcpy+0x1c>
  800937:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800939:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093c:	29 f0                	sub    %esi,%eax
}
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094b:	eb 06                	jmp    800953 <strcmp+0x11>
		p++, q++;
  80094d:	83 c1 01             	add    $0x1,%ecx
  800950:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800953:	0f b6 01             	movzbl (%ecx),%eax
  800956:	84 c0                	test   %al,%al
  800958:	74 04                	je     80095e <strcmp+0x1c>
  80095a:	3a 02                	cmp    (%edx),%al
  80095c:	74 ef                	je     80094d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095e:	0f b6 c0             	movzbl %al,%eax
  800961:	0f b6 12             	movzbl (%edx),%edx
  800964:	29 d0                	sub    %edx,%eax
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800972:	89 c3                	mov    %eax,%ebx
  800974:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800977:	eb 06                	jmp    80097f <strncmp+0x17>
		n--, p++, q++;
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097f:	39 d8                	cmp    %ebx,%eax
  800981:	74 15                	je     800998 <strncmp+0x30>
  800983:	0f b6 08             	movzbl (%eax),%ecx
  800986:	84 c9                	test   %cl,%cl
  800988:	74 04                	je     80098e <strncmp+0x26>
  80098a:	3a 0a                	cmp    (%edx),%cl
  80098c:	74 eb                	je     800979 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098e:	0f b6 00             	movzbl (%eax),%eax
  800991:	0f b6 12             	movzbl (%edx),%edx
  800994:	29 d0                	sub    %edx,%eax
  800996:	eb 05                	jmp    80099d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009aa:	eb 07                	jmp    8009b3 <strchr+0x13>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	74 0f                	je     8009bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	0f b6 10             	movzbl (%eax),%edx
  8009b6:	84 d2                	test   %dl,%dl
  8009b8:	75 f2                	jne    8009ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cb:	eb 03                	jmp    8009d0 <strfind+0xf>
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d3:	38 ca                	cmp    %cl,%dl
  8009d5:	74 04                	je     8009db <strfind+0x1a>
  8009d7:	84 d2                	test   %dl,%dl
  8009d9:	75 f2                	jne    8009cd <strfind+0xc>
			break;
	return (char *) s;
}
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	57                   	push   %edi
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e9:	85 c9                	test   %ecx,%ecx
  8009eb:	74 36                	je     800a23 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f3:	75 28                	jne    800a1d <memset+0x40>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 23                	jne    800a1d <memset+0x40>
		c &= 0xFF;
  8009fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fe:	89 d3                	mov    %edx,%ebx
  800a00:	c1 e3 08             	shl    $0x8,%ebx
  800a03:	89 d6                	mov    %edx,%esi
  800a05:	c1 e6 18             	shl    $0x18,%esi
  800a08:	89 d0                	mov    %edx,%eax
  800a0a:	c1 e0 10             	shl    $0x10,%eax
  800a0d:	09 f0                	or     %esi,%eax
  800a0f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a11:	89 d8                	mov    %ebx,%eax
  800a13:	09 d0                	or     %edx,%eax
  800a15:	c1 e9 02             	shr    $0x2,%ecx
  800a18:	fc                   	cld    
  800a19:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1b:	eb 06                	jmp    800a23 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a20:	fc                   	cld    
  800a21:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a23:	89 f8                	mov    %edi,%eax
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5f                   	pop    %edi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a38:	39 c6                	cmp    %eax,%esi
  800a3a:	73 35                	jae    800a71 <memmove+0x47>
  800a3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	73 2e                	jae    800a71 <memmove+0x47>
		s += n;
		d += n;
  800a43:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	89 d6                	mov    %edx,%esi
  800a48:	09 fe                	or     %edi,%esi
  800a4a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a50:	75 13                	jne    800a65 <memmove+0x3b>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	75 0e                	jne    800a65 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a57:	83 ef 04             	sub    $0x4,%edi
  800a5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	fd                   	std    
  800a61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a63:	eb 09                	jmp    800a6e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a65:	83 ef 01             	sub    $0x1,%edi
  800a68:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6b:	fd                   	std    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6e:	fc                   	cld    
  800a6f:	eb 1d                	jmp    800a8e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a71:	89 f2                	mov    %esi,%edx
  800a73:	09 c2                	or     %eax,%edx
  800a75:	f6 c2 03             	test   $0x3,%dl
  800a78:	75 0f                	jne    800a89 <memmove+0x5f>
  800a7a:	f6 c1 03             	test   $0x3,%cl
  800a7d:	75 0a                	jne    800a89 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7f:	c1 e9 02             	shr    $0x2,%ecx
  800a82:	89 c7                	mov    %eax,%edi
  800a84:	fc                   	cld    
  800a85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a87:	eb 05                	jmp    800a8e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a89:	89 c7                	mov    %eax,%edi
  800a8b:	fc                   	cld    
  800a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a95:	ff 75 10             	pushl  0x10(%ebp)
  800a98:	ff 75 0c             	pushl  0xc(%ebp)
  800a9b:	ff 75 08             	pushl  0x8(%ebp)
  800a9e:	e8 87 ff ff ff       	call   800a2a <memmove>
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab0:	89 c6                	mov    %eax,%esi
  800ab2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab5:	eb 1a                	jmp    800ad1 <memcmp+0x2c>
		if (*s1 != *s2)
  800ab7:	0f b6 08             	movzbl (%eax),%ecx
  800aba:	0f b6 1a             	movzbl (%edx),%ebx
  800abd:	38 d9                	cmp    %bl,%cl
  800abf:	74 0a                	je     800acb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac1:	0f b6 c1             	movzbl %cl,%eax
  800ac4:	0f b6 db             	movzbl %bl,%ebx
  800ac7:	29 d8                	sub    %ebx,%eax
  800ac9:	eb 0f                	jmp    800ada <memcmp+0x35>
		s1++, s2++;
  800acb:	83 c0 01             	add    $0x1,%eax
  800ace:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad1:	39 f0                	cmp    %esi,%eax
  800ad3:	75 e2                	jne    800ab7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	53                   	push   %ebx
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae5:	89 c1                	mov    %eax,%ecx
  800ae7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aee:	eb 0a                	jmp    800afa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af0:	0f b6 10             	movzbl (%eax),%edx
  800af3:	39 da                	cmp    %ebx,%edx
  800af5:	74 07                	je     800afe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	39 c8                	cmp    %ecx,%eax
  800afc:	72 f2                	jb     800af0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afe:	5b                   	pop    %ebx
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0d:	eb 03                	jmp    800b12 <strtol+0x11>
		s++;
  800b0f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b12:	0f b6 01             	movzbl (%ecx),%eax
  800b15:	3c 20                	cmp    $0x20,%al
  800b17:	74 f6                	je     800b0f <strtol+0xe>
  800b19:	3c 09                	cmp    $0x9,%al
  800b1b:	74 f2                	je     800b0f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1d:	3c 2b                	cmp    $0x2b,%al
  800b1f:	75 0a                	jne    800b2b <strtol+0x2a>
		s++;
  800b21:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b24:	bf 00 00 00 00       	mov    $0x0,%edi
  800b29:	eb 11                	jmp    800b3c <strtol+0x3b>
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b30:	3c 2d                	cmp    $0x2d,%al
  800b32:	75 08                	jne    800b3c <strtol+0x3b>
		s++, neg = 1;
  800b34:	83 c1 01             	add    $0x1,%ecx
  800b37:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b42:	75 15                	jne    800b59 <strtol+0x58>
  800b44:	80 39 30             	cmpb   $0x30,(%ecx)
  800b47:	75 10                	jne    800b59 <strtol+0x58>
  800b49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4d:	75 7c                	jne    800bcb <strtol+0xca>
		s += 2, base = 16;
  800b4f:	83 c1 02             	add    $0x2,%ecx
  800b52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b57:	eb 16                	jmp    800b6f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b59:	85 db                	test   %ebx,%ebx
  800b5b:	75 12                	jne    800b6f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b62:	80 39 30             	cmpb   $0x30,(%ecx)
  800b65:	75 08                	jne    800b6f <strtol+0x6e>
		s++, base = 8;
  800b67:	83 c1 01             	add    $0x1,%ecx
  800b6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b77:	0f b6 11             	movzbl (%ecx),%edx
  800b7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7d:	89 f3                	mov    %esi,%ebx
  800b7f:	80 fb 09             	cmp    $0x9,%bl
  800b82:	77 08                	ja     800b8c <strtol+0x8b>
			dig = *s - '0';
  800b84:	0f be d2             	movsbl %dl,%edx
  800b87:	83 ea 30             	sub    $0x30,%edx
  800b8a:	eb 22                	jmp    800bae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 19             	cmp    $0x19,%bl
  800b94:	77 08                	ja     800b9e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b96:	0f be d2             	movsbl %dl,%edx
  800b99:	83 ea 57             	sub    $0x57,%edx
  800b9c:	eb 10                	jmp    800bae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba1:	89 f3                	mov    %esi,%ebx
  800ba3:	80 fb 19             	cmp    $0x19,%bl
  800ba6:	77 16                	ja     800bbe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba8:	0f be d2             	movsbl %dl,%edx
  800bab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb1:	7d 0b                	jge    800bbe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb3:	83 c1 01             	add    $0x1,%ecx
  800bb6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bbc:	eb b9                	jmp    800b77 <strtol+0x76>

	if (endptr)
  800bbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc2:	74 0d                	je     800bd1 <strtol+0xd0>
		*endptr = (char *) s;
  800bc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc7:	89 0e                	mov    %ecx,(%esi)
  800bc9:	eb 06                	jmp    800bd1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcb:	85 db                	test   %ebx,%ebx
  800bcd:	74 98                	je     800b67 <strtol+0x66>
  800bcf:	eb 9e                	jmp    800b6f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd1:	89 c2                	mov    %eax,%edx
  800bd3:	f7 da                	neg    %edx
  800bd5:	85 ff                	test   %edi,%edi
  800bd7:	0f 45 c2             	cmovne %edx,%eax
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	89 c3                	mov    %eax,%ebx
  800bf2:	89 c7                	mov    %eax,%edi
  800bf4:	89 c6                	mov    %eax,%esi
  800bf6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	89 d7                	mov    %edx,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	89 cb                	mov    %ecx,%ebx
  800c34:	89 cf                	mov    %ecx,%edi
  800c36:	89 ce                	mov    %ecx,%esi
  800c38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7e 17                	jle    800c55 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	50                   	push   %eax
  800c42:	6a 03                	push   $0x3
  800c44:	68 bf 23 80 00       	push   $0x8023bf
  800c49:	6a 23                	push   $0x23
  800c4b:	68 dc 23 80 00       	push   $0x8023dc
  800c50:	e8 3e f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	ba 00 00 00 00       	mov    $0x0,%edx
  800c68:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6d:	89 d1                	mov    %edx,%ecx
  800c6f:	89 d3                	mov    %edx,%ebx
  800c71:	89 d7                	mov    %edx,%edi
  800c73:	89 d6                	mov    %edx,%esi
  800c75:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_yield>:

void
sys_yield(void)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8c:	89 d1                	mov    %edx,%ecx
  800c8e:	89 d3                	mov    %edx,%ebx
  800c90:	89 d7                	mov    %edx,%edi
  800c92:	89 d6                	mov    %edx,%esi
  800c94:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	be 00 00 00 00       	mov    $0x0,%esi
  800ca9:	b8 04 00 00 00       	mov    $0x4,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb7:	89 f7                	mov    %esi,%edi
  800cb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 17                	jle    800cd6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 04                	push   $0x4
  800cc5:	68 bf 23 80 00       	push   $0x8023bf
  800cca:	6a 23                	push   $0x23
  800ccc:	68 dc 23 80 00       	push   $0x8023dc
  800cd1:	e8 bd f4 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	b8 05 00 00 00       	mov    $0x5,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 17                	jle    800d18 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 05                	push   $0x5
  800d07:	68 bf 23 80 00       	push   $0x8023bf
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 dc 23 80 00       	push   $0x8023dc
  800d13:	e8 7b f4 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7e 17                	jle    800d5a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 06                	push   $0x6
  800d49:	68 bf 23 80 00       	push   $0x8023bf
  800d4e:	6a 23                	push   $0x23
  800d50:	68 dc 23 80 00       	push   $0x8023dc
  800d55:	e8 39 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d70:	b8 08 00 00 00       	mov    $0x8,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 df                	mov    %ebx,%edi
  800d7d:	89 de                	mov    %ebx,%esi
  800d7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 17                	jle    800d9c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	50                   	push   %eax
  800d89:	6a 08                	push   $0x8
  800d8b:	68 bf 23 80 00       	push   $0x8023bf
  800d90:	6a 23                	push   $0x23
  800d92:	68 dc 23 80 00       	push   $0x8023dc
  800d97:	e8 f7 f3 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	b8 09 00 00 00       	mov    $0x9,%eax
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 09                	push   $0x9
  800dcd:	68 bf 23 80 00       	push   $0x8023bf
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 dc 23 80 00       	push   $0x8023dc
  800dd9:	e8 b5 f3 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 df                	mov    %ebx,%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7e 17                	jle    800e20 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	50                   	push   %eax
  800e0d:	6a 0a                	push   $0xa
  800e0f:	68 bf 23 80 00       	push   $0x8023bf
  800e14:	6a 23                	push   $0x23
  800e16:	68 dc 23 80 00       	push   $0x8023dc
  800e1b:	e8 73 f3 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	be 00 00 00 00       	mov    $0x0,%esi
  800e33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e61:	89 cb                	mov    %ecx,%ebx
  800e63:	89 cf                	mov    %ecx,%edi
  800e65:	89 ce                	mov    %ecx,%esi
  800e67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	7e 17                	jle    800e84 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	50                   	push   %eax
  800e71:	6a 0d                	push   $0xd
  800e73:	68 bf 23 80 00       	push   $0x8023bf
  800e78:	6a 23                	push   $0x23
  800e7a:	68 dc 23 80 00       	push   $0x8023dc
  800e7f:	e8 0f f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	05 00 00 00 30       	add    $0x30000000,%eax
  800e97:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eac:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebe:	89 c2                	mov    %eax,%edx
  800ec0:	c1 ea 16             	shr    $0x16,%edx
  800ec3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eca:	f6 c2 01             	test   $0x1,%dl
  800ecd:	74 11                	je     800ee0 <fd_alloc+0x2d>
  800ecf:	89 c2                	mov    %eax,%edx
  800ed1:	c1 ea 0c             	shr    $0xc,%edx
  800ed4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edb:	f6 c2 01             	test   $0x1,%dl
  800ede:	75 09                	jne    800ee9 <fd_alloc+0x36>
			*fd_store = fd;
  800ee0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	eb 17                	jmp    800f00 <fd_alloc+0x4d>
  800ee9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef3:	75 c9                	jne    800ebe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f08:	83 f8 1f             	cmp    $0x1f,%eax
  800f0b:	77 36                	ja     800f43 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0d:	c1 e0 0c             	shl    $0xc,%eax
  800f10:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f15:	89 c2                	mov    %eax,%edx
  800f17:	c1 ea 16             	shr    $0x16,%edx
  800f1a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f21:	f6 c2 01             	test   $0x1,%dl
  800f24:	74 24                	je     800f4a <fd_lookup+0x48>
  800f26:	89 c2                	mov    %eax,%edx
  800f28:	c1 ea 0c             	shr    $0xc,%edx
  800f2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f32:	f6 c2 01             	test   $0x1,%dl
  800f35:	74 1a                	je     800f51 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f41:	eb 13                	jmp    800f56 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f48:	eb 0c                	jmp    800f56 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4f:	eb 05                	jmp    800f56 <fd_lookup+0x54>
  800f51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f61:	ba 6c 24 80 00       	mov    $0x80246c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f66:	eb 13                	jmp    800f7b <dev_lookup+0x23>
  800f68:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f6b:	39 08                	cmp    %ecx,(%eax)
  800f6d:	75 0c                	jne    800f7b <dev_lookup+0x23>
			*dev = devtab[i];
  800f6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f72:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
  800f79:	eb 2e                	jmp    800fa9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7b:	8b 02                	mov    (%edx),%eax
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	75 e7                	jne    800f68 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f81:	a1 20 60 80 00       	mov    0x806020,%eax
  800f86:	8b 40 48             	mov    0x48(%eax),%eax
  800f89:	83 ec 04             	sub    $0x4,%esp
  800f8c:	51                   	push   %ecx
  800f8d:	50                   	push   %eax
  800f8e:	68 ec 23 80 00       	push   $0x8023ec
  800f93:	e8 d4 f2 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 10             	sub    $0x10,%esp
  800fb3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc3:	c1 e8 0c             	shr    $0xc,%eax
  800fc6:	50                   	push   %eax
  800fc7:	e8 36 ff ff ff       	call   800f02 <fd_lookup>
  800fcc:	83 c4 08             	add    $0x8,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 05                	js     800fd8 <fd_close+0x2d>
	    || fd != fd2)
  800fd3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd6:	74 0c                	je     800fe4 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd8:	84 db                	test   %bl,%bl
  800fda:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdf:	0f 44 c2             	cmove  %edx,%eax
  800fe2:	eb 41                	jmp    801025 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	ff 36                	pushl  (%esi)
  800fed:	e8 66 ff ff ff       	call   800f58 <dev_lookup>
  800ff2:	89 c3                	mov    %eax,%ebx
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 1a                	js     801015 <fd_close+0x6a>
		if (dev->dev_close)
  800ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffe:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801006:	85 c0                	test   %eax,%eax
  801008:	74 0b                	je     801015 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	56                   	push   %esi
  80100e:	ff d0                	call   *%eax
  801010:	89 c3                	mov    %eax,%ebx
  801012:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801015:	83 ec 08             	sub    $0x8,%esp
  801018:	56                   	push   %esi
  801019:	6a 00                	push   $0x0
  80101b:	e8 00 fd ff ff       	call   800d20 <sys_page_unmap>
	return r;
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	89 d8                	mov    %ebx,%eax
}
  801025:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801032:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	ff 75 08             	pushl  0x8(%ebp)
  801039:	e8 c4 fe ff ff       	call   800f02 <fd_lookup>
  80103e:	83 c4 08             	add    $0x8,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	78 10                	js     801055 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801045:	83 ec 08             	sub    $0x8,%esp
  801048:	6a 01                	push   $0x1
  80104a:	ff 75 f4             	pushl  -0xc(%ebp)
  80104d:	e8 59 ff ff ff       	call   800fab <fd_close>
  801052:	83 c4 10             	add    $0x10,%esp
}
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <close_all>:

void
close_all(void)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	53                   	push   %ebx
  80105b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	53                   	push   %ebx
  801067:	e8 c0 ff ff ff       	call   80102c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106c:	83 c3 01             	add    $0x1,%ebx
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	83 fb 20             	cmp    $0x20,%ebx
  801075:	75 ec                	jne    801063 <close_all+0xc>
		close(i);
}
  801077:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 2c             	sub    $0x2c,%esp
  801085:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801088:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108b:	50                   	push   %eax
  80108c:	ff 75 08             	pushl  0x8(%ebp)
  80108f:	e8 6e fe ff ff       	call   800f02 <fd_lookup>
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	0f 88 c1 00 00 00    	js     801160 <dup+0xe4>
		return r;
	close(newfdnum);
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	56                   	push   %esi
  8010a3:	e8 84 ff ff ff       	call   80102c <close>

	newfd = INDEX2FD(newfdnum);
  8010a8:	89 f3                	mov    %esi,%ebx
  8010aa:	c1 e3 0c             	shl    $0xc,%ebx
  8010ad:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b3:	83 c4 04             	add    $0x4,%esp
  8010b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b9:	e8 de fd ff ff       	call   800e9c <fd2data>
  8010be:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010c0:	89 1c 24             	mov    %ebx,(%esp)
  8010c3:	e8 d4 fd ff ff       	call   800e9c <fd2data>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ce:	89 f8                	mov    %edi,%eax
  8010d0:	c1 e8 16             	shr    $0x16,%eax
  8010d3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010da:	a8 01                	test   $0x1,%al
  8010dc:	74 37                	je     801115 <dup+0x99>
  8010de:	89 f8                	mov    %edi,%eax
  8010e0:	c1 e8 0c             	shr    $0xc,%eax
  8010e3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	74 26                	je     801115 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fe:	50                   	push   %eax
  8010ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801102:	6a 00                	push   $0x0
  801104:	57                   	push   %edi
  801105:	6a 00                	push   $0x0
  801107:	e8 d2 fb ff ff       	call   800cde <sys_page_map>
  80110c:	89 c7                	mov    %eax,%edi
  80110e:	83 c4 20             	add    $0x20,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 2e                	js     801143 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801115:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801118:	89 d0                	mov    %edx,%eax
  80111a:	c1 e8 0c             	shr    $0xc,%eax
  80111d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	25 07 0e 00 00       	and    $0xe07,%eax
  80112c:	50                   	push   %eax
  80112d:	53                   	push   %ebx
  80112e:	6a 00                	push   $0x0
  801130:	52                   	push   %edx
  801131:	6a 00                	push   $0x0
  801133:	e8 a6 fb ff ff       	call   800cde <sys_page_map>
  801138:	89 c7                	mov    %eax,%edi
  80113a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80113d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113f:	85 ff                	test   %edi,%edi
  801141:	79 1d                	jns    801160 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	53                   	push   %ebx
  801147:	6a 00                	push   $0x0
  801149:	e8 d2 fb ff ff       	call   800d20 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114e:	83 c4 08             	add    $0x8,%esp
  801151:	ff 75 d4             	pushl  -0x2c(%ebp)
  801154:	6a 00                	push   $0x0
  801156:	e8 c5 fb ff ff       	call   800d20 <sys_page_unmap>
	return r;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	89 f8                	mov    %edi,%eax
}
  801160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	53                   	push   %ebx
  80116c:	83 ec 14             	sub    $0x14,%esp
  80116f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801172:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	53                   	push   %ebx
  801177:	e8 86 fd ff ff       	call   800f02 <fd_lookup>
  80117c:	83 c4 08             	add    $0x8,%esp
  80117f:	89 c2                	mov    %eax,%edx
  801181:	85 c0                	test   %eax,%eax
  801183:	78 6d                	js     8011f2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118f:	ff 30                	pushl  (%eax)
  801191:	e8 c2 fd ff ff       	call   800f58 <dev_lookup>
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 4c                	js     8011e9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a0:	8b 42 08             	mov    0x8(%edx),%eax
  8011a3:	83 e0 03             	and    $0x3,%eax
  8011a6:	83 f8 01             	cmp    $0x1,%eax
  8011a9:	75 21                	jne    8011cc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ab:	a1 20 60 80 00       	mov    0x806020,%eax
  8011b0:	8b 40 48             	mov    0x48(%eax),%eax
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	53                   	push   %ebx
  8011b7:	50                   	push   %eax
  8011b8:	68 30 24 80 00       	push   $0x802430
  8011bd:	e8 aa f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ca:	eb 26                	jmp    8011f2 <read+0x8a>
	}
	if (!dev->dev_read)
  8011cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cf:	8b 40 08             	mov    0x8(%eax),%eax
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	74 17                	je     8011ed <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	ff 75 10             	pushl  0x10(%ebp)
  8011dc:	ff 75 0c             	pushl  0xc(%ebp)
  8011df:	52                   	push   %edx
  8011e0:	ff d0                	call   *%eax
  8011e2:	89 c2                	mov    %eax,%edx
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	eb 09                	jmp    8011f2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	eb 05                	jmp    8011f2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011f2:	89 d0                	mov    %edx,%eax
  8011f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    

008011f9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	57                   	push   %edi
  8011fd:	56                   	push   %esi
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 0c             	sub    $0xc,%esp
  801202:	8b 7d 08             	mov    0x8(%ebp),%edi
  801205:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120d:	eb 21                	jmp    801230 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	89 f0                	mov    %esi,%eax
  801214:	29 d8                	sub    %ebx,%eax
  801216:	50                   	push   %eax
  801217:	89 d8                	mov    %ebx,%eax
  801219:	03 45 0c             	add    0xc(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	57                   	push   %edi
  80121e:	e8 45 ff ff ff       	call   801168 <read>
		if (m < 0)
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	78 10                	js     80123a <readn+0x41>
			return m;
		if (m == 0)
  80122a:	85 c0                	test   %eax,%eax
  80122c:	74 0a                	je     801238 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122e:	01 c3                	add    %eax,%ebx
  801230:	39 f3                	cmp    %esi,%ebx
  801232:	72 db                	jb     80120f <readn+0x16>
  801234:	89 d8                	mov    %ebx,%eax
  801236:	eb 02                	jmp    80123a <readn+0x41>
  801238:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80123a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5f                   	pop    %edi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 14             	sub    $0x14,%esp
  801249:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	53                   	push   %ebx
  801251:	e8 ac fc ff ff       	call   800f02 <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	89 c2                	mov    %eax,%edx
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 68                	js     8012c7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	83 ec 08             	sub    $0x8,%esp
  801262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801269:	ff 30                	pushl  (%eax)
  80126b:	e8 e8 fc ff ff       	call   800f58 <dev_lookup>
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 47                	js     8012be <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127e:	75 21                	jne    8012a1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801280:	a1 20 60 80 00       	mov    0x806020,%eax
  801285:	8b 40 48             	mov    0x48(%eax),%eax
  801288:	83 ec 04             	sub    $0x4,%esp
  80128b:	53                   	push   %ebx
  80128c:	50                   	push   %eax
  80128d:	68 4c 24 80 00       	push   $0x80244c
  801292:	e8 d5 ef ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129f:	eb 26                	jmp    8012c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a7:	85 d2                	test   %edx,%edx
  8012a9:	74 17                	je     8012c2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	ff 75 10             	pushl  0x10(%ebp)
  8012b1:	ff 75 0c             	pushl  0xc(%ebp)
  8012b4:	50                   	push   %eax
  8012b5:	ff d2                	call   *%edx
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	eb 09                	jmp    8012c7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	eb 05                	jmp    8012c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c7:	89 d0                	mov    %edx,%eax
  8012c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d7:	50                   	push   %eax
  8012d8:	ff 75 08             	pushl  0x8(%ebp)
  8012db:	e8 22 fc ff ff       	call   800f02 <fd_lookup>
  8012e0:	83 c4 08             	add    $0x8,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 0e                	js     8012f5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ed:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 14             	sub    $0x14,%esp
  8012fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801301:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	53                   	push   %ebx
  801306:	e8 f7 fb ff ff       	call   800f02 <fd_lookup>
  80130b:	83 c4 08             	add    $0x8,%esp
  80130e:	89 c2                	mov    %eax,%edx
  801310:	85 c0                	test   %eax,%eax
  801312:	78 65                	js     801379 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131e:	ff 30                	pushl  (%eax)
  801320:	e8 33 fc ff ff       	call   800f58 <dev_lookup>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 44                	js     801370 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801333:	75 21                	jne    801356 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801335:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80133a:	8b 40 48             	mov    0x48(%eax),%eax
  80133d:	83 ec 04             	sub    $0x4,%esp
  801340:	53                   	push   %ebx
  801341:	50                   	push   %eax
  801342:	68 0c 24 80 00       	push   $0x80240c
  801347:	e8 20 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801354:	eb 23                	jmp    801379 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801356:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801359:	8b 52 18             	mov    0x18(%edx),%edx
  80135c:	85 d2                	test   %edx,%edx
  80135e:	74 14                	je     801374 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	ff 75 0c             	pushl  0xc(%ebp)
  801366:	50                   	push   %eax
  801367:	ff d2                	call   *%edx
  801369:	89 c2                	mov    %eax,%edx
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	eb 09                	jmp    801379 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801370:	89 c2                	mov    %eax,%edx
  801372:	eb 05                	jmp    801379 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801374:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801379:	89 d0                	mov    %edx,%eax
  80137b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 14             	sub    $0x14,%esp
  801387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	ff 75 08             	pushl  0x8(%ebp)
  801391:	e8 6c fb ff ff       	call   800f02 <fd_lookup>
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	89 c2                	mov    %eax,%edx
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 58                	js     8013f7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	ff 30                	pushl  (%eax)
  8013ab:	e8 a8 fb ff ff       	call   800f58 <dev_lookup>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 37                	js     8013ee <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013be:	74 32                	je     8013f2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ca:	00 00 00 
	stat->st_isdir = 0;
  8013cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d4:	00 00 00 
	stat->st_dev = dev;
  8013d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	53                   	push   %ebx
  8013e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e4:	ff 50 14             	call   *0x14(%eax)
  8013e7:	89 c2                	mov    %eax,%edx
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	eb 09                	jmp    8013f7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	eb 05                	jmp    8013f7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f7:	89 d0                	mov    %edx,%eax
  8013f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	56                   	push   %esi
  801402:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	6a 00                	push   $0x0
  801408:	ff 75 08             	pushl  0x8(%ebp)
  80140b:	e8 b7 01 00 00       	call   8015c7 <open>
  801410:	89 c3                	mov    %eax,%ebx
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	85 c0                	test   %eax,%eax
  801417:	78 1b                	js     801434 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	ff 75 0c             	pushl  0xc(%ebp)
  80141f:	50                   	push   %eax
  801420:	e8 5b ff ff ff       	call   801380 <fstat>
  801425:	89 c6                	mov    %eax,%esi
	close(fd);
  801427:	89 1c 24             	mov    %ebx,(%esp)
  80142a:	e8 fd fb ff ff       	call   80102c <close>
	return r;
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	89 f0                	mov    %esi,%eax
}
  801434:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
  801440:	89 c6                	mov    %eax,%esi
  801442:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801444:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80144b:	75 12                	jne    80145f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	6a 01                	push   $0x1
  801452:	e8 cc 08 00 00       	call   801d23 <ipc_find_env>
  801457:	a3 00 40 80 00       	mov    %eax,0x804000
  80145c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80145f:	6a 07                	push   $0x7
  801461:	68 00 70 80 00       	push   $0x807000
  801466:	56                   	push   %esi
  801467:	ff 35 00 40 80 00    	pushl  0x804000
  80146d:	e8 5d 08 00 00       	call   801ccf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801472:	83 c4 0c             	add    $0xc,%esp
  801475:	6a 00                	push   $0x0
  801477:	53                   	push   %ebx
  801478:	6a 00                	push   $0x0
  80147a:	e8 db 07 00 00       	call   801c5a <ipc_recv>
}
  80147f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	8b 40 0c             	mov    0xc(%eax),%eax
  801492:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801497:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149a:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149f:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a9:	e8 8d ff ff ff       	call   80143b <fsipc>
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bc:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8014cb:	e8 6b ff ff ff       	call   80143b <fsipc>
}
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	53                   	push   %ebx
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e2:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f1:	e8 45 ff ff ff       	call   80143b <fsipc>
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 2c                	js     801526 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	68 00 70 80 00       	push   $0x807000
  801502:	53                   	push   %ebx
  801503:	e8 90 f3 ff ff       	call   800898 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801508:	a1 80 70 80 00       	mov    0x807080,%eax
  80150d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801513:	a1 84 70 80 00       	mov    0x807084,%eax
  801518:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801531:	68 7c 24 80 00       	push   $0x80247c
  801536:	68 90 00 00 00       	push   $0x90
  80153b:	68 9a 24 80 00       	push   $0x80249a
  801540:	e8 4e ec ff ff       	call   800193 <_panic>

00801545 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	56                   	push   %esi
  801549:	53                   	push   %ebx
  80154a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154d:	8b 45 08             	mov    0x8(%ebp),%eax
  801550:	8b 40 0c             	mov    0xc(%eax),%eax
  801553:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801558:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80155e:	ba 00 00 00 00       	mov    $0x0,%edx
  801563:	b8 03 00 00 00       	mov    $0x3,%eax
  801568:	e8 ce fe ff ff       	call   80143b <fsipc>
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 4b                	js     8015be <devfile_read+0x79>
		return r;
	assert(r <= n);
  801573:	39 c6                	cmp    %eax,%esi
  801575:	73 16                	jae    80158d <devfile_read+0x48>
  801577:	68 a5 24 80 00       	push   $0x8024a5
  80157c:	68 ac 24 80 00       	push   $0x8024ac
  801581:	6a 7c                	push   $0x7c
  801583:	68 9a 24 80 00       	push   $0x80249a
  801588:	e8 06 ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  80158d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801592:	7e 16                	jle    8015aa <devfile_read+0x65>
  801594:	68 c1 24 80 00       	push   $0x8024c1
  801599:	68 ac 24 80 00       	push   $0x8024ac
  80159e:	6a 7d                	push   $0x7d
  8015a0:	68 9a 24 80 00       	push   $0x80249a
  8015a5:	e8 e9 eb ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015aa:	83 ec 04             	sub    $0x4,%esp
  8015ad:	50                   	push   %eax
  8015ae:	68 00 70 80 00       	push   $0x807000
  8015b3:	ff 75 0c             	pushl  0xc(%ebp)
  8015b6:	e8 6f f4 ff ff       	call   800a2a <memmove>
	return r;
  8015bb:	83 c4 10             	add    $0x10,%esp
}
  8015be:	89 d8                	mov    %ebx,%eax
  8015c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 20             	sub    $0x20,%esp
  8015ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d1:	53                   	push   %ebx
  8015d2:	e8 88 f2 ff ff       	call   80085f <strlen>
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015df:	7f 67                	jg     801648 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	e8 c6 f8 ff ff       	call   800eb3 <fd_alloc>
  8015ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 57                	js     80164d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	53                   	push   %ebx
  8015fa:	68 00 70 80 00       	push   $0x807000
  8015ff:	e8 94 f2 ff ff       	call   800898 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801604:	8b 45 0c             	mov    0xc(%ebp),%eax
  801607:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160f:	b8 01 00 00 00       	mov    $0x1,%eax
  801614:	e8 22 fe ff ff       	call   80143b <fsipc>
  801619:	89 c3                	mov    %eax,%ebx
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	79 14                	jns    801636 <open+0x6f>
		fd_close(fd, 0);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	6a 00                	push   $0x0
  801627:	ff 75 f4             	pushl  -0xc(%ebp)
  80162a:	e8 7c f9 ff ff       	call   800fab <fd_close>
		return r;
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	89 da                	mov    %ebx,%edx
  801634:	eb 17                	jmp    80164d <open+0x86>
	}

	return fd2num(fd);
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	ff 75 f4             	pushl  -0xc(%ebp)
  80163c:	e8 4b f8 ff ff       	call   800e8c <fd2num>
  801641:	89 c2                	mov    %eax,%edx
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	eb 05                	jmp    80164d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801648:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164d:	89 d0                	mov    %edx,%eax
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80165a:	ba 00 00 00 00       	mov    $0x0,%edx
  80165f:	b8 08 00 00 00       	mov    $0x8,%eax
  801664:	e8 d2 fd ff ff       	call   80143b <fsipc>
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80166b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80166f:	7e 37                	jle    8016a8 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80167a:	ff 70 04             	pushl  0x4(%eax)
  80167d:	8d 40 10             	lea    0x10(%eax),%eax
  801680:	50                   	push   %eax
  801681:	ff 33                	pushl  (%ebx)
  801683:	e8 ba fb ff ff       	call   801242 <write>
		if (result > 0)
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	7e 03                	jle    801692 <writebuf+0x27>
			b->result += result;
  80168f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801692:	3b 43 04             	cmp    0x4(%ebx),%eax
  801695:	74 0d                	je     8016a4 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801697:	85 c0                	test   %eax,%eax
  801699:	ba 00 00 00 00       	mov    $0x0,%edx
  80169e:	0f 4f c2             	cmovg  %edx,%eax
  8016a1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	f3 c3                	repz ret 

008016aa <putch>:

static void
putch(int ch, void *thunk)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016b4:	8b 53 04             	mov    0x4(%ebx),%edx
  8016b7:	8d 42 01             	lea    0x1(%edx),%eax
  8016ba:	89 43 04             	mov    %eax,0x4(%ebx)
  8016bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c0:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016c4:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016c9:	75 0e                	jne    8016d9 <putch+0x2f>
		writebuf(b);
  8016cb:	89 d8                	mov    %ebx,%eax
  8016cd:	e8 99 ff ff ff       	call   80166b <writebuf>
		b->idx = 0;
  8016d2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016d9:	83 c4 04             	add    $0x4,%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5d                   	pop    %ebp
  8016de:	c3                   	ret    

008016df <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016f1:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016f8:	00 00 00 
	b.result = 0;
  8016fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801702:	00 00 00 
	b.error = 1;
  801705:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80170c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80170f:	ff 75 10             	pushl  0x10(%ebp)
  801712:	ff 75 0c             	pushl  0xc(%ebp)
  801715:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	68 aa 16 80 00       	push   $0x8016aa
  801721:	e8 43 ec ff ff       	call   800369 <vprintfmt>
	if (b.idx > 0)
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801730:	7e 0b                	jle    80173d <vfprintf+0x5e>
		writebuf(&b);
  801732:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801738:	e8 2e ff ff ff       	call   80166b <writebuf>

	return (b.result ? b.result : b.error);
  80173d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801743:	85 c0                	test   %eax,%eax
  801745:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801754:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801757:	50                   	push   %eax
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	ff 75 08             	pushl  0x8(%ebp)
  80175e:	e8 7c ff ff ff       	call   8016df <vfprintf>
	va_end(ap);

	return cnt;
}
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <printf>:

int
printf(const char *fmt, ...)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80176b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80176e:	50                   	push   %eax
  80176f:	ff 75 08             	pushl  0x8(%ebp)
  801772:	6a 01                	push   $0x1
  801774:	e8 66 ff ff ff       	call   8016df <vfprintf>
	va_end(ap);

	return cnt;
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	ff 75 08             	pushl  0x8(%ebp)
  801789:	e8 0e f7 ff ff       	call   800e9c <fd2data>
  80178e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801790:	83 c4 08             	add    $0x8,%esp
  801793:	68 cd 24 80 00       	push   $0x8024cd
  801798:	53                   	push   %ebx
  801799:	e8 fa f0 ff ff       	call   800898 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80179e:	8b 46 04             	mov    0x4(%esi),%eax
  8017a1:	2b 06                	sub    (%esi),%eax
  8017a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b0:	00 00 00 
	stat->st_dev = &devpipe;
  8017b3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017ba:	30 80 00 
	return 0;
}
  8017bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c5:	5b                   	pop    %ebx
  8017c6:	5e                   	pop    %esi
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d3:	53                   	push   %ebx
  8017d4:	6a 00                	push   $0x0
  8017d6:	e8 45 f5 ff ff       	call   800d20 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017db:	89 1c 24             	mov    %ebx,(%esp)
  8017de:	e8 b9 f6 ff ff       	call   800e9c <fd2data>
  8017e3:	83 c4 08             	add    $0x8,%esp
  8017e6:	50                   	push   %eax
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 32 f5 ff ff       	call   800d20 <sys_page_unmap>
}
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	57                   	push   %edi
  8017f7:	56                   	push   %esi
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 1c             	sub    $0x1c,%esp
  8017fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ff:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801801:	a1 20 60 80 00       	mov    0x806020,%eax
  801806:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801809:	83 ec 0c             	sub    $0xc,%esp
  80180c:	ff 75 e0             	pushl  -0x20(%ebp)
  80180f:	e8 48 05 00 00       	call   801d5c <pageref>
  801814:	89 c3                	mov    %eax,%ebx
  801816:	89 3c 24             	mov    %edi,(%esp)
  801819:	e8 3e 05 00 00       	call   801d5c <pageref>
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	39 c3                	cmp    %eax,%ebx
  801823:	0f 94 c1             	sete   %cl
  801826:	0f b6 c9             	movzbl %cl,%ecx
  801829:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80182c:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801832:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801835:	39 ce                	cmp    %ecx,%esi
  801837:	74 1b                	je     801854 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801839:	39 c3                	cmp    %eax,%ebx
  80183b:	75 c4                	jne    801801 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80183d:	8b 42 58             	mov    0x58(%edx),%eax
  801840:	ff 75 e4             	pushl  -0x1c(%ebp)
  801843:	50                   	push   %eax
  801844:	56                   	push   %esi
  801845:	68 d4 24 80 00       	push   $0x8024d4
  80184a:	e8 1d ea ff ff       	call   80026c <cprintf>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	eb ad                	jmp    801801 <_pipeisclosed+0xe>
	}
}
  801854:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801857:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5f                   	pop    %edi
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	57                   	push   %edi
  801863:	56                   	push   %esi
  801864:	53                   	push   %ebx
  801865:	83 ec 28             	sub    $0x28,%esp
  801868:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80186b:	56                   	push   %esi
  80186c:	e8 2b f6 ff ff       	call   800e9c <fd2data>
  801871:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	bf 00 00 00 00       	mov    $0x0,%edi
  80187b:	eb 4b                	jmp    8018c8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80187d:	89 da                	mov    %ebx,%edx
  80187f:	89 f0                	mov    %esi,%eax
  801881:	e8 6d ff ff ff       	call   8017f3 <_pipeisclosed>
  801886:	85 c0                	test   %eax,%eax
  801888:	75 48                	jne    8018d2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80188a:	e8 ed f3 ff ff       	call   800c7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80188f:	8b 43 04             	mov    0x4(%ebx),%eax
  801892:	8b 0b                	mov    (%ebx),%ecx
  801894:	8d 51 20             	lea    0x20(%ecx),%edx
  801897:	39 d0                	cmp    %edx,%eax
  801899:	73 e2                	jae    80187d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80189b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018a2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018a5:	89 c2                	mov    %eax,%edx
  8018a7:	c1 fa 1f             	sar    $0x1f,%edx
  8018aa:	89 d1                	mov    %edx,%ecx
  8018ac:	c1 e9 1b             	shr    $0x1b,%ecx
  8018af:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018b2:	83 e2 1f             	and    $0x1f,%edx
  8018b5:	29 ca                	sub    %ecx,%edx
  8018b7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018bb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018bf:	83 c0 01             	add    $0x1,%eax
  8018c2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c5:	83 c7 01             	add    $0x1,%edi
  8018c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018cb:	75 c2                	jne    80188f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d0:	eb 05                	jmp    8018d7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018da:	5b                   	pop    %ebx
  8018db:	5e                   	pop    %esi
  8018dc:	5f                   	pop    %edi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	57                   	push   %edi
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 18             	sub    $0x18,%esp
  8018e8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018eb:	57                   	push   %edi
  8018ec:	e8 ab f5 ff ff       	call   800e9c <fd2data>
  8018f1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018fb:	eb 3d                	jmp    80193a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018fd:	85 db                	test   %ebx,%ebx
  8018ff:	74 04                	je     801905 <devpipe_read+0x26>
				return i;
  801901:	89 d8                	mov    %ebx,%eax
  801903:	eb 44                	jmp    801949 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801905:	89 f2                	mov    %esi,%edx
  801907:	89 f8                	mov    %edi,%eax
  801909:	e8 e5 fe ff ff       	call   8017f3 <_pipeisclosed>
  80190e:	85 c0                	test   %eax,%eax
  801910:	75 32                	jne    801944 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801912:	e8 65 f3 ff ff       	call   800c7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801917:	8b 06                	mov    (%esi),%eax
  801919:	3b 46 04             	cmp    0x4(%esi),%eax
  80191c:	74 df                	je     8018fd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80191e:	99                   	cltd   
  80191f:	c1 ea 1b             	shr    $0x1b,%edx
  801922:	01 d0                	add    %edx,%eax
  801924:	83 e0 1f             	and    $0x1f,%eax
  801927:	29 d0                	sub    %edx,%eax
  801929:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80192e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801931:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801934:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801937:	83 c3 01             	add    $0x1,%ebx
  80193a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80193d:	75 d8                	jne    801917 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80193f:	8b 45 10             	mov    0x10(%ebp),%eax
  801942:	eb 05                	jmp    801949 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801949:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5f                   	pop    %edi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	e8 51 f5 ff ff       	call   800eb3 <fd_alloc>
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	89 c2                	mov    %eax,%edx
  801967:	85 c0                	test   %eax,%eax
  801969:	0f 88 2c 01 00 00    	js     801a9b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80196f:	83 ec 04             	sub    $0x4,%esp
  801972:	68 07 04 00 00       	push   $0x407
  801977:	ff 75 f4             	pushl  -0xc(%ebp)
  80197a:	6a 00                	push   $0x0
  80197c:	e8 1a f3 ff ff       	call   800c9b <sys_page_alloc>
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	89 c2                	mov    %eax,%edx
  801986:	85 c0                	test   %eax,%eax
  801988:	0f 88 0d 01 00 00    	js     801a9b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801994:	50                   	push   %eax
  801995:	e8 19 f5 ff ff       	call   800eb3 <fd_alloc>
  80199a:	89 c3                	mov    %eax,%ebx
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	0f 88 e2 00 00 00    	js     801a89 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a7:	83 ec 04             	sub    $0x4,%esp
  8019aa:	68 07 04 00 00       	push   $0x407
  8019af:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b2:	6a 00                	push   $0x0
  8019b4:	e8 e2 f2 ff ff       	call   800c9b <sys_page_alloc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	0f 88 c3 00 00 00    	js     801a89 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019c6:	83 ec 0c             	sub    $0xc,%esp
  8019c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cc:	e8 cb f4 ff ff       	call   800e9c <fd2data>
  8019d1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d3:	83 c4 0c             	add    $0xc,%esp
  8019d6:	68 07 04 00 00       	push   $0x407
  8019db:	50                   	push   %eax
  8019dc:	6a 00                	push   $0x0
  8019de:	e8 b8 f2 ff ff       	call   800c9b <sys_page_alloc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	0f 88 89 00 00 00    	js     801a79 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f6:	e8 a1 f4 ff ff       	call   800e9c <fd2data>
  8019fb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a02:	50                   	push   %eax
  801a03:	6a 00                	push   $0x0
  801a05:	56                   	push   %esi
  801a06:	6a 00                	push   $0x0
  801a08:	e8 d1 f2 ff ff       	call   800cde <sys_page_map>
  801a0d:	89 c3                	mov    %eax,%ebx
  801a0f:	83 c4 20             	add    $0x20,%esp
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 55                	js     801a6b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a16:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a24:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a34:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a39:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	ff 75 f4             	pushl  -0xc(%ebp)
  801a46:	e8 41 f4 ff ff       	call   800e8c <fd2num>
  801a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a4e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a50:	83 c4 04             	add    $0x4,%esp
  801a53:	ff 75 f0             	pushl  -0x10(%ebp)
  801a56:	e8 31 f4 ff ff       	call   800e8c <fd2num>
  801a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a5e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	ba 00 00 00 00       	mov    $0x0,%edx
  801a69:	eb 30                	jmp    801a9b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	56                   	push   %esi
  801a6f:	6a 00                	push   $0x0
  801a71:	e8 aa f2 ff ff       	call   800d20 <sys_page_unmap>
  801a76:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a79:	83 ec 08             	sub    $0x8,%esp
  801a7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 9a f2 ff ff       	call   800d20 <sys_page_unmap>
  801a86:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a89:	83 ec 08             	sub    $0x8,%esp
  801a8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8f:	6a 00                	push   $0x0
  801a91:	e8 8a f2 ff ff       	call   800d20 <sys_page_unmap>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a9b:	89 d0                	mov    %edx,%eax
  801a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aad:	50                   	push   %eax
  801aae:	ff 75 08             	pushl  0x8(%ebp)
  801ab1:	e8 4c f4 ff ff       	call   800f02 <fd_lookup>
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 18                	js     801ad5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac3:	e8 d4 f3 ff ff       	call   800e9c <fd2data>
	return _pipeisclosed(fd, p);
  801ac8:	89 c2                	mov    %eax,%edx
  801aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acd:	e8 21 fd ff ff       	call   8017f3 <_pipeisclosed>
  801ad2:	83 c4 10             	add    $0x10,%esp
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ae7:	68 ec 24 80 00       	push   $0x8024ec
  801aec:	ff 75 0c             	pushl  0xc(%ebp)
  801aef:	e8 a4 ed ff ff       	call   800898 <strcpy>
	return 0;
}
  801af4:	b8 00 00 00 00       	mov    $0x0,%eax
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	57                   	push   %edi
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b07:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b0c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b12:	eb 2d                	jmp    801b41 <devcons_write+0x46>
		m = n - tot;
  801b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b17:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b19:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b1c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b21:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	53                   	push   %ebx
  801b28:	03 45 0c             	add    0xc(%ebp),%eax
  801b2b:	50                   	push   %eax
  801b2c:	57                   	push   %edi
  801b2d:	e8 f8 ee ff ff       	call   800a2a <memmove>
		sys_cputs(buf, m);
  801b32:	83 c4 08             	add    $0x8,%esp
  801b35:	53                   	push   %ebx
  801b36:	57                   	push   %edi
  801b37:	e8 a3 f0 ff ff       	call   800bdf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b3c:	01 de                	add    %ebx,%esi
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	89 f0                	mov    %esi,%eax
  801b43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b46:	72 cc                	jb     801b14 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b5f:	74 2a                	je     801b8b <devcons_read+0x3b>
  801b61:	eb 05                	jmp    801b68 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b63:	e8 14 f1 ff ff       	call   800c7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b68:	e8 90 f0 ff ff       	call   800bfd <sys_cgetc>
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	74 f2                	je     801b63 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 16                	js     801b8b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b75:	83 f8 04             	cmp    $0x4,%eax
  801b78:	74 0c                	je     801b86 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b7d:	88 02                	mov    %al,(%edx)
	return 1;
  801b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b84:	eb 05                	jmp    801b8b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b86:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b99:	6a 01                	push   $0x1
  801b9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b9e:	50                   	push   %eax
  801b9f:	e8 3b f0 ff ff       	call   800bdf <sys_cputs>
}
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <getchar>:

int
getchar(void)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801baf:	6a 01                	push   $0x1
  801bb1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bb4:	50                   	push   %eax
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 ac f5 ff ff       	call   801168 <read>
	if (r < 0)
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 0f                	js     801bd2 <getchar+0x29>
		return r;
	if (r < 1)
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	7e 06                	jle    801bcd <getchar+0x24>
		return -E_EOF;
	return c;
  801bc7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bcb:	eb 05                	jmp    801bd2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bcd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	ff 75 08             	pushl  0x8(%ebp)
  801be1:	e8 1c f3 ff ff       	call   800f02 <fd_lookup>
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 11                	js     801bfe <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bf6:	39 10                	cmp    %edx,(%eax)
  801bf8:	0f 94 c0             	sete   %al
  801bfb:	0f b6 c0             	movzbl %al,%eax
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <opencons>:

int
opencons(void)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c09:	50                   	push   %eax
  801c0a:	e8 a4 f2 ff ff       	call   800eb3 <fd_alloc>
  801c0f:	83 c4 10             	add    $0x10,%esp
		return r;
  801c12:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c14:	85 c0                	test   %eax,%eax
  801c16:	78 3e                	js     801c56 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	68 07 04 00 00       	push   $0x407
  801c20:	ff 75 f4             	pushl  -0xc(%ebp)
  801c23:	6a 00                	push   $0x0
  801c25:	e8 71 f0 ff ff       	call   800c9b <sys_page_alloc>
  801c2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c2d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 23                	js     801c56 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c41:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c48:	83 ec 0c             	sub    $0xc,%esp
  801c4b:	50                   	push   %eax
  801c4c:	e8 3b f2 ff ff       	call   800e8c <fd2num>
  801c51:	89 c2                	mov    %eax,%edx
  801c53:	83 c4 10             	add    $0x10,%esp
}
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	56                   	push   %esi
  801c5e:	53                   	push   %ebx
  801c5f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	74 0e                	je     801c7a <ipc_recv+0x20>
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	50                   	push   %eax
  801c70:	e8 d6 f1 ff ff       	call   800e4b <sys_ipc_recv>
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	eb 10                	jmp    801c8a <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	68 00 00 c0 ee       	push   $0xeec00000
  801c82:	e8 c4 f1 ff ff       	call   800e4b <sys_ipc_recv>
  801c87:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	74 16                	je     801ca4 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801c8e:	85 f6                	test   %esi,%esi
  801c90:	74 06                	je     801c98 <ipc_recv+0x3e>
  801c92:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801c98:	85 db                	test   %ebx,%ebx
  801c9a:	74 2c                	je     801cc8 <ipc_recv+0x6e>
  801c9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ca2:	eb 24                	jmp    801cc8 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801ca4:	85 f6                	test   %esi,%esi
  801ca6:	74 0a                	je     801cb2 <ipc_recv+0x58>
  801ca8:	a1 20 60 80 00       	mov    0x806020,%eax
  801cad:	8b 40 74             	mov    0x74(%eax),%eax
  801cb0:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801cb2:	85 db                	test   %ebx,%ebx
  801cb4:	74 0a                	je     801cc0 <ipc_recv+0x66>
  801cb6:	a1 20 60 80 00       	mov    0x806020,%eax
  801cbb:	8b 40 78             	mov    0x78(%eax),%eax
  801cbe:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801cc0:	a1 20 60 80 00       	mov    0x806020,%eax
  801cc5:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	57                   	push   %edi
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cde:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ce8:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801ceb:	ff 75 14             	pushl  0x14(%ebp)
  801cee:	53                   	push   %ebx
  801cef:	56                   	push   %esi
  801cf0:	57                   	push   %edi
  801cf1:	e8 32 f1 ff ff       	call   800e28 <sys_ipc_try_send>
		if (ret == 0) break;
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	74 1e                	je     801d1b <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801cfd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d00:	74 12                	je     801d14 <ipc_send+0x45>
  801d02:	50                   	push   %eax
  801d03:	68 f8 24 80 00       	push   $0x8024f8
  801d08:	6a 39                	push   $0x39
  801d0a:	68 05 25 80 00       	push   $0x802505
  801d0f:	e8 7f e4 ff ff       	call   800193 <_panic>
		sys_yield();
  801d14:	e8 63 ef ff ff       	call   800c7c <sys_yield>
	}
  801d19:	eb d0                	jmp    801ceb <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d2e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d31:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d37:	8b 52 50             	mov    0x50(%edx),%edx
  801d3a:	39 ca                	cmp    %ecx,%edx
  801d3c:	75 0d                	jne    801d4b <ipc_find_env+0x28>
			return envs[i].env_id;
  801d3e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d41:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d46:	8b 40 48             	mov    0x48(%eax),%eax
  801d49:	eb 0f                	jmp    801d5a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d4b:	83 c0 01             	add    $0x1,%eax
  801d4e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d53:	75 d9                	jne    801d2e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d62:	89 d0                	mov    %edx,%eax
  801d64:	c1 e8 16             	shr    $0x16,%eax
  801d67:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d73:	f6 c1 01             	test   $0x1,%cl
  801d76:	74 1d                	je     801d95 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d78:	c1 ea 0c             	shr    $0xc,%edx
  801d7b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d82:	f6 c2 01             	test   $0x1,%dl
  801d85:	74 0e                	je     801d95 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d87:	c1 ea 0c             	shr    $0xc,%edx
  801d8a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d91:	ef 
  801d92:	0f b7 c0             	movzwl %ax,%eax
}
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    
  801d97:	66 90                	xchg   %ax,%ax
  801d99:	66 90                	xchg   %ax,%ax
  801d9b:	66 90                	xchg   %ax,%ax
  801d9d:	66 90                	xchg   %ax,%ax
  801d9f:	90                   	nop

00801da0 <__udivdi3>:
  801da0:	55                   	push   %ebp
  801da1:	57                   	push   %edi
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	83 ec 1c             	sub    $0x1c,%esp
  801da7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801dab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801daf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801db7:	85 f6                	test   %esi,%esi
  801db9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dbd:	89 ca                	mov    %ecx,%edx
  801dbf:	89 f8                	mov    %edi,%eax
  801dc1:	75 3d                	jne    801e00 <__udivdi3+0x60>
  801dc3:	39 cf                	cmp    %ecx,%edi
  801dc5:	0f 87 c5 00 00 00    	ja     801e90 <__udivdi3+0xf0>
  801dcb:	85 ff                	test   %edi,%edi
  801dcd:	89 fd                	mov    %edi,%ebp
  801dcf:	75 0b                	jne    801ddc <__udivdi3+0x3c>
  801dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd6:	31 d2                	xor    %edx,%edx
  801dd8:	f7 f7                	div    %edi
  801dda:	89 c5                	mov    %eax,%ebp
  801ddc:	89 c8                	mov    %ecx,%eax
  801dde:	31 d2                	xor    %edx,%edx
  801de0:	f7 f5                	div    %ebp
  801de2:	89 c1                	mov    %eax,%ecx
  801de4:	89 d8                	mov    %ebx,%eax
  801de6:	89 cf                	mov    %ecx,%edi
  801de8:	f7 f5                	div    %ebp
  801dea:	89 c3                	mov    %eax,%ebx
  801dec:	89 d8                	mov    %ebx,%eax
  801dee:	89 fa                	mov    %edi,%edx
  801df0:	83 c4 1c             	add    $0x1c,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    
  801df8:	90                   	nop
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	39 ce                	cmp    %ecx,%esi
  801e02:	77 74                	ja     801e78 <__udivdi3+0xd8>
  801e04:	0f bd fe             	bsr    %esi,%edi
  801e07:	83 f7 1f             	xor    $0x1f,%edi
  801e0a:	0f 84 98 00 00 00    	je     801ea8 <__udivdi3+0x108>
  801e10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e15:	89 f9                	mov    %edi,%ecx
  801e17:	89 c5                	mov    %eax,%ebp
  801e19:	29 fb                	sub    %edi,%ebx
  801e1b:	d3 e6                	shl    %cl,%esi
  801e1d:	89 d9                	mov    %ebx,%ecx
  801e1f:	d3 ed                	shr    %cl,%ebp
  801e21:	89 f9                	mov    %edi,%ecx
  801e23:	d3 e0                	shl    %cl,%eax
  801e25:	09 ee                	or     %ebp,%esi
  801e27:	89 d9                	mov    %ebx,%ecx
  801e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e2d:	89 d5                	mov    %edx,%ebp
  801e2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e33:	d3 ed                	shr    %cl,%ebp
  801e35:	89 f9                	mov    %edi,%ecx
  801e37:	d3 e2                	shl    %cl,%edx
  801e39:	89 d9                	mov    %ebx,%ecx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	09 c2                	or     %eax,%edx
  801e3f:	89 d0                	mov    %edx,%eax
  801e41:	89 ea                	mov    %ebp,%edx
  801e43:	f7 f6                	div    %esi
  801e45:	89 d5                	mov    %edx,%ebp
  801e47:	89 c3                	mov    %eax,%ebx
  801e49:	f7 64 24 0c          	mull   0xc(%esp)
  801e4d:	39 d5                	cmp    %edx,%ebp
  801e4f:	72 10                	jb     801e61 <__udivdi3+0xc1>
  801e51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e55:	89 f9                	mov    %edi,%ecx
  801e57:	d3 e6                	shl    %cl,%esi
  801e59:	39 c6                	cmp    %eax,%esi
  801e5b:	73 07                	jae    801e64 <__udivdi3+0xc4>
  801e5d:	39 d5                	cmp    %edx,%ebp
  801e5f:	75 03                	jne    801e64 <__udivdi3+0xc4>
  801e61:	83 eb 01             	sub    $0x1,%ebx
  801e64:	31 ff                	xor    %edi,%edi
  801e66:	89 d8                	mov    %ebx,%eax
  801e68:	89 fa                	mov    %edi,%edx
  801e6a:	83 c4 1c             	add    $0x1c,%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5f                   	pop    %edi
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    
  801e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e78:	31 ff                	xor    %edi,%edi
  801e7a:	31 db                	xor    %ebx,%ebx
  801e7c:	89 d8                	mov    %ebx,%eax
  801e7e:	89 fa                	mov    %edi,%edx
  801e80:	83 c4 1c             	add    $0x1c,%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    
  801e88:	90                   	nop
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	89 d8                	mov    %ebx,%eax
  801e92:	f7 f7                	div    %edi
  801e94:	31 ff                	xor    %edi,%edi
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	89 d8                	mov    %ebx,%eax
  801e9a:	89 fa                	mov    %edi,%edx
  801e9c:	83 c4 1c             	add    $0x1c,%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5f                   	pop    %edi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    
  801ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea8:	39 ce                	cmp    %ecx,%esi
  801eaa:	72 0c                	jb     801eb8 <__udivdi3+0x118>
  801eac:	31 db                	xor    %ebx,%ebx
  801eae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801eb2:	0f 87 34 ff ff ff    	ja     801dec <__udivdi3+0x4c>
  801eb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ebd:	e9 2a ff ff ff       	jmp    801dec <__udivdi3+0x4c>
  801ec2:	66 90                	xchg   %ax,%ax
  801ec4:	66 90                	xchg   %ax,%ax
  801ec6:	66 90                	xchg   %ax,%ax
  801ec8:	66 90                	xchg   %ax,%ax
  801eca:	66 90                	xchg   %ax,%ax
  801ecc:	66 90                	xchg   %ax,%ax
  801ece:	66 90                	xchg   %ax,%ax

00801ed0 <__umoddi3>:
  801ed0:	55                   	push   %ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
  801ed7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801edb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801edf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ee7:	85 d2                	test   %edx,%edx
  801ee9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ef1:	89 f3                	mov    %esi,%ebx
  801ef3:	89 3c 24             	mov    %edi,(%esp)
  801ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801efa:	75 1c                	jne    801f18 <__umoddi3+0x48>
  801efc:	39 f7                	cmp    %esi,%edi
  801efe:	76 50                	jbe    801f50 <__umoddi3+0x80>
  801f00:	89 c8                	mov    %ecx,%eax
  801f02:	89 f2                	mov    %esi,%edx
  801f04:	f7 f7                	div    %edi
  801f06:	89 d0                	mov    %edx,%eax
  801f08:	31 d2                	xor    %edx,%edx
  801f0a:	83 c4 1c             	add    $0x1c,%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5f                   	pop    %edi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    
  801f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f18:	39 f2                	cmp    %esi,%edx
  801f1a:	89 d0                	mov    %edx,%eax
  801f1c:	77 52                	ja     801f70 <__umoddi3+0xa0>
  801f1e:	0f bd ea             	bsr    %edx,%ebp
  801f21:	83 f5 1f             	xor    $0x1f,%ebp
  801f24:	75 5a                	jne    801f80 <__umoddi3+0xb0>
  801f26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f2a:	0f 82 e0 00 00 00    	jb     802010 <__umoddi3+0x140>
  801f30:	39 0c 24             	cmp    %ecx,(%esp)
  801f33:	0f 86 d7 00 00 00    	jbe    802010 <__umoddi3+0x140>
  801f39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f41:	83 c4 1c             	add    $0x1c,%esp
  801f44:	5b                   	pop    %ebx
  801f45:	5e                   	pop    %esi
  801f46:	5f                   	pop    %edi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    
  801f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f50:	85 ff                	test   %edi,%edi
  801f52:	89 fd                	mov    %edi,%ebp
  801f54:	75 0b                	jne    801f61 <__umoddi3+0x91>
  801f56:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	f7 f7                	div    %edi
  801f5f:	89 c5                	mov    %eax,%ebp
  801f61:	89 f0                	mov    %esi,%eax
  801f63:	31 d2                	xor    %edx,%edx
  801f65:	f7 f5                	div    %ebp
  801f67:	89 c8                	mov    %ecx,%eax
  801f69:	f7 f5                	div    %ebp
  801f6b:	89 d0                	mov    %edx,%eax
  801f6d:	eb 99                	jmp    801f08 <__umoddi3+0x38>
  801f6f:	90                   	nop
  801f70:	89 c8                	mov    %ecx,%eax
  801f72:	89 f2                	mov    %esi,%edx
  801f74:	83 c4 1c             	add    $0x1c,%esp
  801f77:	5b                   	pop    %ebx
  801f78:	5e                   	pop    %esi
  801f79:	5f                   	pop    %edi
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    
  801f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f80:	8b 34 24             	mov    (%esp),%esi
  801f83:	bf 20 00 00 00       	mov    $0x20,%edi
  801f88:	89 e9                	mov    %ebp,%ecx
  801f8a:	29 ef                	sub    %ebp,%edi
  801f8c:	d3 e0                	shl    %cl,%eax
  801f8e:	89 f9                	mov    %edi,%ecx
  801f90:	89 f2                	mov    %esi,%edx
  801f92:	d3 ea                	shr    %cl,%edx
  801f94:	89 e9                	mov    %ebp,%ecx
  801f96:	09 c2                	or     %eax,%edx
  801f98:	89 d8                	mov    %ebx,%eax
  801f9a:	89 14 24             	mov    %edx,(%esp)
  801f9d:	89 f2                	mov    %esi,%edx
  801f9f:	d3 e2                	shl    %cl,%edx
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fa7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801fab:	d3 e8                	shr    %cl,%eax
  801fad:	89 e9                	mov    %ebp,%ecx
  801faf:	89 c6                	mov    %eax,%esi
  801fb1:	d3 e3                	shl    %cl,%ebx
  801fb3:	89 f9                	mov    %edi,%ecx
  801fb5:	89 d0                	mov    %edx,%eax
  801fb7:	d3 e8                	shr    %cl,%eax
  801fb9:	89 e9                	mov    %ebp,%ecx
  801fbb:	09 d8                	or     %ebx,%eax
  801fbd:	89 d3                	mov    %edx,%ebx
  801fbf:	89 f2                	mov    %esi,%edx
  801fc1:	f7 34 24             	divl   (%esp)
  801fc4:	89 d6                	mov    %edx,%esi
  801fc6:	d3 e3                	shl    %cl,%ebx
  801fc8:	f7 64 24 04          	mull   0x4(%esp)
  801fcc:	39 d6                	cmp    %edx,%esi
  801fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd2:	89 d1                	mov    %edx,%ecx
  801fd4:	89 c3                	mov    %eax,%ebx
  801fd6:	72 08                	jb     801fe0 <__umoddi3+0x110>
  801fd8:	75 11                	jne    801feb <__umoddi3+0x11b>
  801fda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801fde:	73 0b                	jae    801feb <__umoddi3+0x11b>
  801fe0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801fe4:	1b 14 24             	sbb    (%esp),%edx
  801fe7:	89 d1                	mov    %edx,%ecx
  801fe9:	89 c3                	mov    %eax,%ebx
  801feb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801fef:	29 da                	sub    %ebx,%edx
  801ff1:	19 ce                	sbb    %ecx,%esi
  801ff3:	89 f9                	mov    %edi,%ecx
  801ff5:	89 f0                	mov    %esi,%eax
  801ff7:	d3 e0                	shl    %cl,%eax
  801ff9:	89 e9                	mov    %ebp,%ecx
  801ffb:	d3 ea                	shr    %cl,%edx
  801ffd:	89 e9                	mov    %ebp,%ecx
  801fff:	d3 ee                	shr    %cl,%esi
  802001:	09 d0                	or     %edx,%eax
  802003:	89 f2                	mov    %esi,%edx
  802005:	83 c4 1c             	add    $0x1c,%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    
  80200d:	8d 76 00             	lea    0x0(%esi),%esi
  802010:	29 f9                	sub    %edi,%ecx
  802012:	19 d6                	sbb    %edx,%esi
  802014:	89 74 24 04          	mov    %esi,0x4(%esp)
  802018:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80201c:	e9 18 ff ff ff       	jmp    801f39 <__umoddi3+0x69>
