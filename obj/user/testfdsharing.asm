
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 80 23 80 00       	push   $0x802380
  800043:	e8 0e 19 00 00       	call   801956 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 85 23 80 00       	push   $0x802385
  800057:	6a 0c                	push   $0xc
  800059:	68 93 23 80 00       	push   $0x802393
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 ef 15 00 00       	call   80165d <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 07 15 00 00       	call   801588 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 a8 23 80 00       	push   $0x8023a8
  800090:	6a 0f                	push   $0xf
  800092:	68 93 23 80 00       	push   $0x802393
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 1d 10 00 00       	call   8010be <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 b2 23 80 00       	push   $0x8023b2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 93 23 80 00       	push   $0x802393
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 91 15 00 00       	call   80165d <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 9d 14 00 00       	call   801588 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 34 24 80 00       	push   $0x802434
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 93 23 80 00       	push   $0x802393
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 0f 0a 00 00       	call   800b2a <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 60 24 80 00       	push   $0x802460
  80012a:	6a 19                	push   $0x19
  80012c:	68 93 23 80 00       	push   $0x802393
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 bb 23 80 00       	push   $0x8023bb
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 0f 15 00 00       	call   80165d <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 65 12 00 00       	call   8013bb <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 ef 1b 00 00       	call   801d56 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 0e 14 00 00       	call   801588 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 98 24 80 00       	push   $0x802498
  80018b:	6a 21                	push   $0x21
  80018d:	68 93 23 80 00       	push   $0x802393
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 d4 23 80 00       	push   $0x8023d4
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 0f 12 00 00       	call   8013bb <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8001c3:	e8 1a 0b 00 00       	call   800ce2 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 dd 11 00 00       	call   8013e6 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 8e 0a 00 00       	call   800ca1 <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 b7 0a 00 00       	call   800ce2 <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 c8 24 80 00       	push   $0x8024c8
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 d6 09 00 00       	call   800c64 <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 1a 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 7b 09 00 00       	call   800c64 <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 87 1d 00 00       	call   8020e0 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 74 1e 00 00       	call   802210 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 eb 24 80 00 	movsbl 0x8024eb(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c3:	73 0a                	jae    8003cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	88 02                	mov    %al,(%edx)
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
	va_end(ap);
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 2c             	sub    $0x2c,%esp
  8003f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800400:	eb 12                	jmp    800414 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800402:	85 c0                	test   %eax,%eax
  800404:	0f 84 6a 04 00 00    	je     800874 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	53                   	push   %ebx
  80040e:	50                   	push   %eax
  80040f:	ff d6                	call   *%esi
  800411:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800414:	83 c7 01             	add    $0x1,%edi
  800417:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041b:	83 f8 25             	cmp    $0x25,%eax
  80041e:	75 e2                	jne    800402 <vprintfmt+0x14>
  800420:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800424:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800432:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800439:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043e:	eb 07                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800443:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8d 47 01             	lea    0x1(%edi),%eax
  80044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044d:	0f b6 07             	movzbl (%edi),%eax
  800450:	0f b6 d0             	movzbl %al,%edx
  800453:	83 e8 23             	sub    $0x23,%eax
  800456:	3c 55                	cmp    $0x55,%al
  800458:	0f 87 fb 03 00 00    	ja     800859 <vprintfmt+0x46b>
  80045e:	0f b6 c0             	movzbl %al,%eax
  800461:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046f:	eb d6                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800483:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800486:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800489:	83 f9 09             	cmp    $0x9,%ecx
  80048c:	77 3f                	ja     8004cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800491:	eb e9                	jmp    80047c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 40 04             	lea    0x4(%eax),%eax
  8004a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a7:	eb 2a                	jmp    8004d3 <vprintfmt+0xe5>
  8004a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	0f 49 d0             	cmovns %eax,%edx
  8004b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	eb 89                	jmp    800447 <vprintfmt+0x59>
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c8:	e9 7a ff ff ff       	jmp    800447 <vprintfmt+0x59>
  8004cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 89 6a ff ff ff    	jns    800447 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ea:	e9 58 ff ff ff       	jmp    800447 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f5:	e9 4d ff ff ff       	jmp    800447 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 78 04             	lea    0x4(%eax),%edi
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	ff 30                	pushl  (%eax)
  800506:	ff d6                	call   *%esi
			break;
  800508:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800511:	e9 fe fe ff ff       	jmp    800414 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 78 04             	lea    0x4(%eax),%edi
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	99                   	cltd   
  80051f:	31 d0                	xor    %edx,%eax
  800521:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	83 f8 0f             	cmp    $0xf,%eax
  800526:	7f 0b                	jg     800533 <vprintfmt+0x145>
  800528:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  80052f:	85 d2                	test   %edx,%edx
  800531:	75 1b                	jne    80054e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800533:	50                   	push   %eax
  800534:	68 03 25 80 00       	push   $0x802503
  800539:	53                   	push   %ebx
  80053a:	56                   	push   %esi
  80053b:	e8 91 fe ff ff       	call   8003d1 <printfmt>
  800540:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800543:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800549:	e9 c6 fe ff ff       	jmp    800414 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054e:	52                   	push   %edx
  80054f:	68 be 29 80 00       	push   $0x8029be
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 76 fe ff ff       	call   8003d1 <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800564:	e9 ab fe ff ff       	jmp    800414 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	83 c0 04             	add    $0x4,%eax
  80056f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800577:	85 ff                	test   %edi,%edi
  800579:	b8 fc 24 80 00       	mov    $0x8024fc,%eax
  80057e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	0f 8e 94 00 00 00    	jle    80061f <vprintfmt+0x231>
  80058b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058f:	0f 84 98 00 00 00    	je     80062d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	ff 75 d0             	pushl  -0x30(%ebp)
  80059b:	57                   	push   %edi
  80059c:	e8 5b 03 00 00       	call   8008fc <strnlen>
  8005a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a4:	29 c1                	sub    %eax,%ecx
  8005a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	eb 0f                	jmp    8005c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ef 01             	sub    $0x1,%edi
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f ed                	jg     8005ba <vprintfmt+0x1cc>
  8005cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005da:	0f 49 c1             	cmovns %ecx,%eax
  8005dd:	29 c1                	sub    %eax,%ecx
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	89 cb                	mov    %ecx,%ebx
  8005ea:	eb 4d                	jmp    800639 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f0:	74 1b                	je     80060d <vprintfmt+0x21f>
  8005f2:	0f be c0             	movsbl %al,%eax
  8005f5:	83 e8 20             	sub    $0x20,%eax
  8005f8:	83 f8 5e             	cmp    $0x5e,%eax
  8005fb:	76 10                	jbe    80060d <vprintfmt+0x21f>
					putch('?', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	ff 75 0c             	pushl  0xc(%ebp)
  800603:	6a 3f                	push   $0x3f
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	ff 75 0c             	pushl  0xc(%ebp)
  800613:	52                   	push   %edx
  800614:	ff 55 08             	call   *0x8(%ebp)
  800617:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	83 eb 01             	sub    $0x1,%ebx
  80061d:	eb 1a                	jmp    800639 <vprintfmt+0x24b>
  80061f:	89 75 08             	mov    %esi,0x8(%ebp)
  800622:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800625:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800628:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062b:	eb 0c                	jmp    800639 <vprintfmt+0x24b>
  80062d:	89 75 08             	mov    %esi,0x8(%ebp)
  800630:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800633:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800636:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800640:	0f be d0             	movsbl %al,%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	74 23                	je     80066a <vprintfmt+0x27c>
  800647:	85 f6                	test   %esi,%esi
  800649:	78 a1                	js     8005ec <vprintfmt+0x1fe>
  80064b:	83 ee 01             	sub    $0x1,%esi
  80064e:	79 9c                	jns    8005ec <vprintfmt+0x1fe>
  800650:	89 df                	mov    %ebx,%edi
  800652:	8b 75 08             	mov    0x8(%ebp),%esi
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	eb 18                	jmp    800672 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 20                	push   $0x20
  800660:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	eb 08                	jmp    800672 <vprintfmt+0x284>
  80066a:	89 df                	mov    %ebx,%edi
  80066c:	8b 75 08             	mov    0x8(%ebp),%esi
  80066f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800672:	85 ff                	test   %edi,%edi
  800674:	7f e4                	jg     80065a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800676:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067f:	e9 90 fd ff ff       	jmp    800414 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800684:	83 f9 01             	cmp    $0x1,%ecx
  800687:	7e 19                	jle    8006a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb 38                	jmp    8006da <vprintfmt+0x2ec>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 1b                	je     8006c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ae:	89 c1                	mov    %eax,%ecx
  8006b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bf:	eb 19                	jmp    8006da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e9:	0f 89 36 01 00 00    	jns    800825 <vprintfmt+0x437>
				putch('-', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 2d                	push   $0x2d
  8006f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006fd:	f7 da                	neg    %edx
  8006ff:	83 d1 00             	adc    $0x0,%ecx
  800702:	f7 d9                	neg    %ecx
  800704:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070c:	e9 14 01 00 00       	jmp    800825 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800711:	83 f9 01             	cmp    $0x1,%ecx
  800714:	7e 18                	jle    80072e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8b 10                	mov    (%eax),%edx
  80071b:	8b 48 04             	mov    0x4(%eax),%ecx
  80071e:	8d 40 08             	lea    0x8(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800724:	b8 0a 00 00 00       	mov    $0xa,%eax
  800729:	e9 f7 00 00 00       	jmp    800825 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 1a                	je     80074c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 d9 00 00 00       	jmp    800825 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	b9 00 00 00 00       	mov    $0x0,%ecx
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80075c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800761:	e9 bf 00 00 00       	jmp    800825 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800766:	83 f9 01             	cmp    $0x1,%ecx
  800769:	7e 13                	jle    80077e <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800776:	8d 49 08             	lea    0x8(%ecx),%ecx
  800779:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80077c:	eb 28                	jmp    8007a6 <vprintfmt+0x3b8>
	else if (lflag)
  80077e:	85 c9                	test   %ecx,%ecx
  800780:	74 13                	je     800795 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8b 10                	mov    (%eax),%edx
  800787:	89 d0                	mov    %edx,%eax
  800789:	99                   	cltd   
  80078a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80078d:	8d 49 04             	lea    0x4(%ecx),%ecx
  800790:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800793:	eb 11                	jmp    8007a6 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 10                	mov    (%eax),%edx
  80079a:	89 d0                	mov    %edx,%eax
  80079c:	99                   	cltd   
  80079d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007a0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8007a6:	89 d1                	mov    %edx,%ecx
  8007a8:	89 c2                	mov    %eax,%edx
			base = 8;
  8007aa:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007af:	eb 74                	jmp    800825 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	53                   	push   %ebx
  8007b5:	6a 30                	push   $0x30
  8007b7:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	53                   	push   %ebx
  8007bd:	6a 78                	push   $0x78
  8007bf:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8b 10                	mov    (%eax),%edx
  8007c6:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cb:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d9:	eb 4a                	jmp    800825 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007db:	83 f9 01             	cmp    $0x1,%ecx
  8007de:	7e 15                	jle    8007f5 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8b 10                	mov    (%eax),%edx
  8007e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e8:	8d 40 08             	lea    0x8(%eax),%eax
  8007eb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ee:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f3:	eb 30                	jmp    800825 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007f5:	85 c9                	test   %ecx,%ecx
  8007f7:	74 17                	je     800810 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8b 10                	mov    (%eax),%edx
  8007fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800803:	8d 40 04             	lea    0x4(%eax),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800809:	b8 10 00 00 00       	mov    $0x10,%eax
  80080e:	eb 15                	jmp    800825 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081a:	8d 40 04             	lea    0x4(%eax),%eax
  80081d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800820:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800825:	83 ec 0c             	sub    $0xc,%esp
  800828:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80082c:	57                   	push   %edi
  80082d:	ff 75 e0             	pushl  -0x20(%ebp)
  800830:	50                   	push   %eax
  800831:	51                   	push   %ecx
  800832:	52                   	push   %edx
  800833:	89 da                	mov    %ebx,%edx
  800835:	89 f0                	mov    %esi,%eax
  800837:	e8 c9 fa ff ff       	call   800305 <printnum>
			break;
  80083c:	83 c4 20             	add    $0x20,%esp
  80083f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800842:	e9 cd fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	53                   	push   %ebx
  80084b:	52                   	push   %edx
  80084c:	ff d6                	call   *%esi
			break;
  80084e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800854:	e9 bb fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	53                   	push   %ebx
  80085d:	6a 25                	push   $0x25
  80085f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	eb 03                	jmp    800869 <vprintfmt+0x47b>
  800866:	83 ef 01             	sub    $0x1,%edi
  800869:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80086d:	75 f7                	jne    800866 <vprintfmt+0x478>
  80086f:	e9 a0 fb ff ff       	jmp    800414 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800874:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 18             	sub    $0x18,%esp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800888:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800892:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800899:	85 c0                	test   %eax,%eax
  80089b:	74 26                	je     8008c3 <vsnprintf+0x47>
  80089d:	85 d2                	test   %edx,%edx
  80089f:	7e 22                	jle    8008c3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a1:	ff 75 14             	pushl  0x14(%ebp)
  8008a4:	ff 75 10             	pushl  0x10(%ebp)
  8008a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	68 b4 03 80 00       	push   $0x8003b4
  8008b0:	e8 39 fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	eb 05                	jmp    8008c8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    

008008ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d3:	50                   	push   %eax
  8008d4:	ff 75 10             	pushl  0x10(%ebp)
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	ff 75 08             	pushl  0x8(%ebp)
  8008dd:	e8 9a ff ff ff       	call   80087c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	eb 03                	jmp    8008f4 <strlen+0x10>
		n++;
  8008f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f8:	75 f7                	jne    8008f1 <strlen+0xd>
		n++;
	return n;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	ba 00 00 00 00       	mov    $0x0,%edx
  80090a:	eb 03                	jmp    80090f <strnlen+0x13>
		n++;
  80090c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090f:	39 c2                	cmp    %eax,%edx
  800911:	74 08                	je     80091b <strnlen+0x1f>
  800913:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800917:	75 f3                	jne    80090c <strnlen+0x10>
  800919:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800927:	89 c2                	mov    %eax,%edx
  800929:	83 c2 01             	add    $0x1,%edx
  80092c:	83 c1 01             	add    $0x1,%ecx
  80092f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800933:	88 5a ff             	mov    %bl,-0x1(%edx)
  800936:	84 db                	test   %bl,%bl
  800938:	75 ef                	jne    800929 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	53                   	push   %ebx
  800941:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800944:	53                   	push   %ebx
  800945:	e8 9a ff ff ff       	call   8008e4 <strlen>
  80094a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80094d:	ff 75 0c             	pushl  0xc(%ebp)
  800950:	01 d8                	add    %ebx,%eax
  800952:	50                   	push   %eax
  800953:	e8 c5 ff ff ff       	call   80091d <strcpy>
	return dst;
}
  800958:	89 d8                	mov    %ebx,%eax
  80095a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096a:	89 f3                	mov    %esi,%ebx
  80096c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096f:	89 f2                	mov    %esi,%edx
  800971:	eb 0f                	jmp    800982 <strncpy+0x23>
		*dst++ = *src;
  800973:	83 c2 01             	add    $0x1,%edx
  800976:	0f b6 01             	movzbl (%ecx),%eax
  800979:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80097c:	80 39 01             	cmpb   $0x1,(%ecx)
  80097f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800982:	39 da                	cmp    %ebx,%edx
  800984:	75 ed                	jne    800973 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800986:	89 f0                	mov    %esi,%eax
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 75 08             	mov    0x8(%ebp),%esi
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	8b 55 10             	mov    0x10(%ebp),%edx
  80099a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80099c:	85 d2                	test   %edx,%edx
  80099e:	74 21                	je     8009c1 <strlcpy+0x35>
  8009a0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a4:	89 f2                	mov    %esi,%edx
  8009a6:	eb 09                	jmp    8009b1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a8:	83 c2 01             	add    $0x1,%edx
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b1:	39 c2                	cmp    %eax,%edx
  8009b3:	74 09                	je     8009be <strlcpy+0x32>
  8009b5:	0f b6 19             	movzbl (%ecx),%ebx
  8009b8:	84 db                	test   %bl,%bl
  8009ba:	75 ec                	jne    8009a8 <strlcpy+0x1c>
  8009bc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009be:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c1:	29 f0                	sub    %esi,%eax
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d0:	eb 06                	jmp    8009d8 <strcmp+0x11>
		p++, q++;
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d8:	0f b6 01             	movzbl (%ecx),%eax
  8009db:	84 c0                	test   %al,%al
  8009dd:	74 04                	je     8009e3 <strcmp+0x1c>
  8009df:	3a 02                	cmp    (%edx),%al
  8009e1:	74 ef                	je     8009d2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e3:	0f b6 c0             	movzbl %al,%eax
  8009e6:	0f b6 12             	movzbl (%edx),%edx
  8009e9:	29 d0                	sub    %edx,%eax
}
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	53                   	push   %ebx
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f7:	89 c3                	mov    %eax,%ebx
  8009f9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009fc:	eb 06                	jmp    800a04 <strncmp+0x17>
		n--, p++, q++;
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a04:	39 d8                	cmp    %ebx,%eax
  800a06:	74 15                	je     800a1d <strncmp+0x30>
  800a08:	0f b6 08             	movzbl (%eax),%ecx
  800a0b:	84 c9                	test   %cl,%cl
  800a0d:	74 04                	je     800a13 <strncmp+0x26>
  800a0f:	3a 0a                	cmp    (%edx),%cl
  800a11:	74 eb                	je     8009fe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a13:	0f b6 00             	movzbl (%eax),%eax
  800a16:	0f b6 12             	movzbl (%edx),%edx
  800a19:	29 d0                	sub    %edx,%eax
  800a1b:	eb 05                	jmp    800a22 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a22:	5b                   	pop    %ebx
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2f:	eb 07                	jmp    800a38 <strchr+0x13>
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 0f                	je     800a44 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	75 f2                	jne    800a31 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a50:	eb 03                	jmp    800a55 <strfind+0xf>
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a58:	38 ca                	cmp    %cl,%dl
  800a5a:	74 04                	je     800a60 <strfind+0x1a>
  800a5c:	84 d2                	test   %dl,%dl
  800a5e:	75 f2                	jne    800a52 <strfind+0xc>
			break;
	return (char *) s;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6e:	85 c9                	test   %ecx,%ecx
  800a70:	74 36                	je     800aa8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a72:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a78:	75 28                	jne    800aa2 <memset+0x40>
  800a7a:	f6 c1 03             	test   $0x3,%cl
  800a7d:	75 23                	jne    800aa2 <memset+0x40>
		c &= 0xFF;
  800a7f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a83:	89 d3                	mov    %edx,%ebx
  800a85:	c1 e3 08             	shl    $0x8,%ebx
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	c1 e6 18             	shl    $0x18,%esi
  800a8d:	89 d0                	mov    %edx,%eax
  800a8f:	c1 e0 10             	shl    $0x10,%eax
  800a92:	09 f0                	or     %esi,%eax
  800a94:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a96:	89 d8                	mov    %ebx,%eax
  800a98:	09 d0                	or     %edx,%eax
  800a9a:	c1 e9 02             	shr    $0x2,%ecx
  800a9d:	fc                   	cld    
  800a9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa0:	eb 06                	jmp    800aa8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa5:	fc                   	cld    
  800aa6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa8:	89 f8                	mov    %edi,%eax
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800abd:	39 c6                	cmp    %eax,%esi
  800abf:	73 35                	jae    800af6 <memmove+0x47>
  800ac1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac4:	39 d0                	cmp    %edx,%eax
  800ac6:	73 2e                	jae    800af6 <memmove+0x47>
		s += n;
		d += n;
  800ac8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acb:	89 d6                	mov    %edx,%esi
  800acd:	09 fe                	or     %edi,%esi
  800acf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad5:	75 13                	jne    800aea <memmove+0x3b>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 0e                	jne    800aea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800adc:	83 ef 04             	sub    $0x4,%edi
  800adf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
  800ae5:	fd                   	std    
  800ae6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae8:	eb 09                	jmp    800af3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af0:	fd                   	std    
  800af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af3:	fc                   	cld    
  800af4:	eb 1d                	jmp    800b13 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	89 f2                	mov    %esi,%edx
  800af8:	09 c2                	or     %eax,%edx
  800afa:	f6 c2 03             	test   $0x3,%dl
  800afd:	75 0f                	jne    800b0e <memmove+0x5f>
  800aff:	f6 c1 03             	test   $0x3,%cl
  800b02:	75 0a                	jne    800b0e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b04:	c1 e9 02             	shr    $0x2,%ecx
  800b07:	89 c7                	mov    %eax,%edi
  800b09:	fc                   	cld    
  800b0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0c:	eb 05                	jmp    800b13 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0e:	89 c7                	mov    %eax,%edi
  800b10:	fc                   	cld    
  800b11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1a:	ff 75 10             	pushl  0x10(%ebp)
  800b1d:	ff 75 0c             	pushl  0xc(%ebp)
  800b20:	ff 75 08             	pushl  0x8(%ebp)
  800b23:	e8 87 ff ff ff       	call   800aaf <memmove>
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	eb 1a                	jmp    800b56 <memcmp+0x2c>
		if (*s1 != *s2)
  800b3c:	0f b6 08             	movzbl (%eax),%ecx
  800b3f:	0f b6 1a             	movzbl (%edx),%ebx
  800b42:	38 d9                	cmp    %bl,%cl
  800b44:	74 0a                	je     800b50 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b46:	0f b6 c1             	movzbl %cl,%eax
  800b49:	0f b6 db             	movzbl %bl,%ebx
  800b4c:	29 d8                	sub    %ebx,%eax
  800b4e:	eb 0f                	jmp    800b5f <memcmp+0x35>
		s1++, s2++;
  800b50:	83 c0 01             	add    $0x1,%eax
  800b53:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b56:	39 f0                	cmp    %esi,%eax
  800b58:	75 e2                	jne    800b3c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	53                   	push   %ebx
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b6a:	89 c1                	mov    %eax,%ecx
  800b6c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b73:	eb 0a                	jmp    800b7f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b75:	0f b6 10             	movzbl (%eax),%edx
  800b78:	39 da                	cmp    %ebx,%edx
  800b7a:	74 07                	je     800b83 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b7c:	83 c0 01             	add    $0x1,%eax
  800b7f:	39 c8                	cmp    %ecx,%eax
  800b81:	72 f2                	jb     800b75 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b83:	5b                   	pop    %ebx
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b92:	eb 03                	jmp    800b97 <strtol+0x11>
		s++;
  800b94:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b97:	0f b6 01             	movzbl (%ecx),%eax
  800b9a:	3c 20                	cmp    $0x20,%al
  800b9c:	74 f6                	je     800b94 <strtol+0xe>
  800b9e:	3c 09                	cmp    $0x9,%al
  800ba0:	74 f2                	je     800b94 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba2:	3c 2b                	cmp    $0x2b,%al
  800ba4:	75 0a                	jne    800bb0 <strtol+0x2a>
		s++;
  800ba6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bae:	eb 11                	jmp    800bc1 <strtol+0x3b>
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb5:	3c 2d                	cmp    $0x2d,%al
  800bb7:	75 08                	jne    800bc1 <strtol+0x3b>
		s++, neg = 1;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc7:	75 15                	jne    800bde <strtol+0x58>
  800bc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcc:	75 10                	jne    800bde <strtol+0x58>
  800bce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd2:	75 7c                	jne    800c50 <strtol+0xca>
		s += 2, base = 16;
  800bd4:	83 c1 02             	add    $0x2,%ecx
  800bd7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bdc:	eb 16                	jmp    800bf4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bde:	85 db                	test   %ebx,%ebx
  800be0:	75 12                	jne    800bf4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be7:	80 39 30             	cmpb   $0x30,(%ecx)
  800bea:	75 08                	jne    800bf4 <strtol+0x6e>
		s++, base = 8;
  800bec:	83 c1 01             	add    $0x1,%ecx
  800bef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bfc:	0f b6 11             	movzbl (%ecx),%edx
  800bff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c02:	89 f3                	mov    %esi,%ebx
  800c04:	80 fb 09             	cmp    $0x9,%bl
  800c07:	77 08                	ja     800c11 <strtol+0x8b>
			dig = *s - '0';
  800c09:	0f be d2             	movsbl %dl,%edx
  800c0c:	83 ea 30             	sub    $0x30,%edx
  800c0f:	eb 22                	jmp    800c33 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c14:	89 f3                	mov    %esi,%ebx
  800c16:	80 fb 19             	cmp    $0x19,%bl
  800c19:	77 08                	ja     800c23 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c1b:	0f be d2             	movsbl %dl,%edx
  800c1e:	83 ea 57             	sub    $0x57,%edx
  800c21:	eb 10                	jmp    800c33 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c26:	89 f3                	mov    %esi,%ebx
  800c28:	80 fb 19             	cmp    $0x19,%bl
  800c2b:	77 16                	ja     800c43 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c2d:	0f be d2             	movsbl %dl,%edx
  800c30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c36:	7d 0b                	jge    800c43 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c38:	83 c1 01             	add    $0x1,%ecx
  800c3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c41:	eb b9                	jmp    800bfc <strtol+0x76>

	if (endptr)
  800c43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c47:	74 0d                	je     800c56 <strtol+0xd0>
		*endptr = (char *) s;
  800c49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4c:	89 0e                	mov    %ecx,(%esi)
  800c4e:	eb 06                	jmp    800c56 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c50:	85 db                	test   %ebx,%ebx
  800c52:	74 98                	je     800bec <strtol+0x66>
  800c54:	eb 9e                	jmp    800bf4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	f7 da                	neg    %edx
  800c5a:	85 ff                	test   %edi,%edi
  800c5c:	0f 45 c2             	cmovne %edx,%eax
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	89 c3                	mov    %eax,%ebx
  800c77:	89 c7                	mov    %eax,%edi
  800c79:	89 c6                	mov    %eax,%esi
  800c7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	89 d3                	mov    %edx,%ebx
  800c96:	89 d7                	mov    %edx,%edi
  800c98:	89 d6                	mov    %edx,%esi
  800c9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 cb                	mov    %ecx,%ebx
  800cb9:	89 cf                	mov    %ecx,%edi
  800cbb:	89 ce                	mov    %ecx,%esi
  800cbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 03                	push   $0x3
  800cc9:	68 df 27 80 00       	push   $0x8027df
  800cce:	6a 23                	push   $0x23
  800cd0:	68 fc 27 80 00       	push   $0x8027fc
  800cd5:	e8 3e f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ced:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf2:	89 d1                	mov    %edx,%ecx
  800cf4:	89 d3                	mov    %edx,%ebx
  800cf6:	89 d7                	mov    %edx,%edi
  800cf8:	89 d6                	mov    %edx,%esi
  800cfa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_yield>:

void
sys_yield(void)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d11:	89 d1                	mov    %edx,%ecx
  800d13:	89 d3                	mov    %edx,%ebx
  800d15:	89 d7                	mov    %edx,%edi
  800d17:	89 d6                	mov    %edx,%esi
  800d19:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d29:	be 00 00 00 00       	mov    $0x0,%esi
  800d2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3c:	89 f7                	mov    %esi,%edi
  800d3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 04                	push   $0x4
  800d4a:	68 df 27 80 00       	push   $0x8027df
  800d4f:	6a 23                	push   $0x23
  800d51:	68 fc 27 80 00       	push   $0x8027fc
  800d56:	e8 bd f4 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 05                	push   $0x5
  800d8c:	68 df 27 80 00       	push   $0x8027df
  800d91:	6a 23                	push   $0x23
  800d93:	68 fc 27 80 00       	push   $0x8027fc
  800d98:	e8 7b f4 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 06 00 00 00       	mov    $0x6,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 06                	push   $0x6
  800dce:	68 df 27 80 00       	push   $0x8027df
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 fc 27 80 00       	push   $0x8027fc
  800dda:	e8 39 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 08                	push   $0x8
  800e10:	68 df 27 80 00       	push   $0x8027df
  800e15:	6a 23                	push   $0x23
  800e17:	68 fc 27 80 00       	push   $0x8027fc
  800e1c:	e8 f7 f3 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e37:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	89 df                	mov    %ebx,%edi
  800e44:	89 de                	mov    %ebx,%esi
  800e46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	7e 17                	jle    800e63 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	50                   	push   %eax
  800e50:	6a 09                	push   $0x9
  800e52:	68 df 27 80 00       	push   $0x8027df
  800e57:	6a 23                	push   $0x23
  800e59:	68 fc 27 80 00       	push   $0x8027fc
  800e5e:	e8 b5 f3 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	89 df                	mov    %ebx,%edi
  800e86:	89 de                	mov    %ebx,%esi
  800e88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7e 17                	jle    800ea5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	50                   	push   %eax
  800e92:	6a 0a                	push   $0xa
  800e94:	68 df 27 80 00       	push   $0x8027df
  800e99:	6a 23                	push   $0x23
  800e9b:	68 fc 27 80 00       	push   $0x8027fc
  800ea0:	e8 73 f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb3:	be 00 00 00 00       	mov    $0x0,%esi
  800eb8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ebd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ede:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 cb                	mov    %ecx,%ebx
  800ee8:	89 cf                	mov    %ecx,%edi
  800eea:	89 ce                	mov    %ecx,%esi
  800eec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	7e 17                	jle    800f09 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	50                   	push   %eax
  800ef6:	6a 0d                	push   $0xd
  800ef8:	68 df 27 80 00       	push   $0x8027df
  800efd:	6a 23                	push   $0x23
  800eff:	68 fc 27 80 00       	push   $0x8027fc
  800f04:	e8 0f f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	53                   	push   %ebx
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f1b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f1d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f21:	0f 84 48 01 00 00    	je     80106f <pgfault+0x15e>
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e8 16             	shr    $0x16,%eax
  800f2c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f33:	a8 01                	test   $0x1,%al
  800f35:	0f 84 5f 01 00 00    	je     80109a <pgfault+0x189>
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	c1 e8 0c             	shr    $0xc,%eax
  800f40:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f47:	f6 c2 01             	test   $0x1,%dl
  800f4a:	0f 84 4a 01 00 00    	je     80109a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800f50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  800f57:	f6 c4 08             	test   $0x8,%ah
  800f5a:	75 79                	jne    800fd5 <pgfault+0xc4>
  800f5c:	e9 39 01 00 00       	jmp    80109a <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  800f61:	89 d8                	mov    %ebx,%eax
  800f63:	c1 e8 16             	shr    $0x16,%eax
  800f66:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6d:	a8 01                	test   $0x1,%al
  800f6f:	75 10                	jne    800f81 <pgfault+0x70>
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	68 0a 28 80 00       	push   $0x80280a
  800f79:	e8 73 f3 ff ff       	call   8002f1 <cprintf>
  800f7e:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  800f81:	c1 eb 0c             	shr    $0xc,%ebx
  800f84:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  800f8a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f91:	a8 01                	test   $0x1,%al
  800f93:	75 10                	jne    800fa5 <pgfault+0x94>
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	68 1b 28 80 00       	push   $0x80281b
  800f9d:	e8 4f f3 ff ff       	call   8002f1 <cprintf>
  800fa2:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  800fa5:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fac:	f6 c4 08             	test   $0x8,%ah
  800faf:	75 10                	jne    800fc1 <pgfault+0xb0>
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	68 2c 28 80 00       	push   $0x80282c
  800fb9:	e8 33 f3 ff ff       	call   8002f1 <cprintf>
  800fbe:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	68 3f 28 80 00       	push   $0x80283f
  800fc9:	6a 23                	push   $0x23
  800fcb:	68 4f 28 80 00       	push   $0x80284f
  800fd0:	e8 43 f2 ff ff       	call   800218 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fd5:	83 ec 04             	sub    $0x4,%esp
  800fd8:	6a 07                	push   $0x7
  800fda:	68 00 f0 7f 00       	push   $0x7ff000
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 3a fd ff ff       	call   800d20 <sys_page_alloc>
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	79 12                	jns    800fff <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  800fed:	50                   	push   %eax
  800fee:	68 5a 28 80 00       	push   $0x80285a
  800ff3:	6a 2f                	push   $0x2f
  800ff5:	68 4f 28 80 00       	push   $0x80284f
  800ffa:	e8 19 f2 ff ff       	call   800218 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800fff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	68 00 10 00 00       	push   $0x1000
  80100d:	53                   	push   %ebx
  80100e:	68 00 f0 7f 00       	push   $0x7ff000
  801013:	e8 ff fa ff ff       	call   800b17 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  801018:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80101f:	53                   	push   %ebx
  801020:	6a 00                	push   $0x0
  801022:	68 00 f0 7f 00       	push   $0x7ff000
  801027:	6a 00                	push   $0x0
  801029:	e8 35 fd ff ff       	call   800d63 <sys_page_map>
  80102e:	83 c4 20             	add    $0x20,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	79 12                	jns    801047 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  801035:	50                   	push   %eax
  801036:	68 74 28 80 00       	push   $0x802874
  80103b:	6a 33                	push   $0x33
  80103d:	68 4f 28 80 00       	push   $0x80284f
  801042:	e8 d1 f1 ff ff       	call   800218 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	68 00 f0 7f 00       	push   $0x7ff000
  80104f:	6a 00                	push   $0x0
  801051:	e8 4f fd ff ff       	call   800da5 <sys_page_unmap>
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	79 5c                	jns    8010b9 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  80105d:	50                   	push   %eax
  80105e:	68 8c 28 80 00       	push   $0x80288c
  801063:	6a 35                	push   $0x35
  801065:	68 4f 28 80 00       	push   $0x80284f
  80106a:	e8 a9 f1 ff ff       	call   800218 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80106f:	a1 20 44 80 00       	mov    0x804420,%eax
  801074:	8b 40 48             	mov    0x48(%eax),%eax
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	50                   	push   %eax
  80107b:	53                   	push   %ebx
  80107c:	68 c8 28 80 00       	push   $0x8028c8
  801081:	e8 6b f2 ff ff       	call   8002f1 <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  801086:	c7 04 24 a6 28 80 00 	movl   $0x8028a6,(%esp)
  80108d:	e8 5f f2 ff ff       	call   8002f1 <cprintf>
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	e9 c7 fe ff ff       	jmp    800f61 <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80109a:	a1 20 44 80 00       	mov    0x804420,%eax
  80109f:	8b 40 48             	mov    0x48(%eax),%eax
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	50                   	push   %eax
  8010a6:	53                   	push   %ebx
  8010a7:	68 c8 28 80 00       	push   $0x8028c8
  8010ac:	e8 40 f2 ff ff       	call   8002f1 <cprintf>
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	e9 a8 fe ff ff       	jmp    800f61 <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  8010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  8010c7:	68 11 0f 80 00       	push   $0x800f11
  8010cc:	e8 57 0e 00 00       	call   801f28 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010d1:	b8 07 00 00 00       	mov    $0x7,%eax
  8010d6:	cd 30                	int    $0x30
  8010d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010db:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	0f 88 0d 01 00 00    	js     8011f6 <fork+0x138>
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ee:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	75 2f                	jne    801126 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  8010f7:	e8 e6 fb ff ff       	call   800ce2 <sys_getenvid>
  8010fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  801101:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801104:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801109:	a3 20 44 80 00       	mov    %eax,0x804420
		// set_pgfault_handler(pgfault);
		return 0;
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
  801113:	e9 e1 00 00 00       	jmp    8011f9 <fork+0x13b>
  801118:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  80111e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801124:	74 77                	je     80119d <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  801126:	89 f0                	mov    %esi,%eax
  801128:	c1 e8 0a             	shr    $0xa,%eax
  80112b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  801132:	a8 01                	test   $0x1,%al
  801134:	74 0b                	je     801141 <fork+0x83>
	pte_t pte = uvpt[pn];
  801136:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  80113d:	a8 01                	test   $0x1,%al
  80113f:	75 08                	jne    801149 <fork+0x8b>
  801141:	8d 5e 01             	lea    0x1(%esi),%ebx
  801144:	c1 e3 0c             	shl    $0xc,%ebx
  801147:	eb 56                	jmp    80119f <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801149:	25 02 08 00 00       	and    $0x802,%eax
  80114e:	83 f8 01             	cmp    $0x1,%eax
  801151:	19 ff                	sbb    %edi,%edi
  801153:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801159:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80115f:	a1 20 44 80 00       	mov    0x804420,%eax
  801164:	8b 40 48             	mov    0x48(%eax),%eax
  801167:	83 ec 0c             	sub    $0xc,%esp
  80116a:	57                   	push   %edi
  80116b:	53                   	push   %ebx
  80116c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116f:	53                   	push   %ebx
  801170:	50                   	push   %eax
  801171:	e8 ed fb ff ff       	call   800d63 <sys_page_map>
  801176:	83 c4 20             	add    $0x20,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	78 7c                	js     8011f9 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  80117d:	a1 20 44 80 00       	mov    0x804420,%eax
  801182:	8b 40 48             	mov    0x48(%eax),%eax
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	57                   	push   %edi
  801189:	53                   	push   %ebx
  80118a:	50                   	push   %eax
  80118b:	53                   	push   %ebx
  80118c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118f:	e8 cf fb ff ff       	call   800d63 <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	79 a6                	jns    801141 <fork+0x83>
  80119b:	eb 5c                	jmp    8011f9 <fork+0x13b>
  80119d:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  80119f:	83 c6 01             	add    $0x1,%esi
  8011a2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8011a8:	0f 86 6a ff ff ff    	jbe    801118 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	6a 07                	push   $0x7
  8011b3:	68 00 f0 bf ee       	push   $0xeebff000
  8011b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8011bb:	57                   	push   %edi
  8011bc:	e8 5f fb ff ff       	call   800d20 <sys_page_alloc>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 31                	js     8011f9 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  8011c8:	a1 20 44 80 00       	mov    0x804420,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  8011cd:	8b 40 64             	mov    0x64(%eax),%eax
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	50                   	push   %eax
  8011d4:	57                   	push   %edi
  8011d5:	e8 91 fc ff ff       	call   800e6b <sys_env_set_pgfault_upcall>
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 18                	js     8011f9 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	6a 02                	push   $0x2
  8011e6:	57                   	push   %edi
  8011e7:	e8 fb fb ff ff       	call   800de7 <sys_env_set_status>
  8011ec:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	0f 49 c7             	cmovns %edi,%eax
  8011f4:	eb 03                	jmp    8011f9 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8011f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8011f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fc:	5b                   	pop    %ebx
  8011fd:	5e                   	pop    %esi
  8011fe:	5f                   	pop    %edi
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <sfork>:

// Challenge!
int
sfork(void)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801207:	68 b1 28 80 00       	push   $0x8028b1
  80120c:	68 9f 00 00 00       	push   $0x9f
  801211:	68 4f 28 80 00       	push   $0x80284f
  801216:	e8 fd ef ff ff       	call   800218 <_panic>

0080121b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	05 00 00 00 30       	add    $0x30000000,%eax
  801226:	c1 e8 0c             	shr    $0xc,%eax
}
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80122e:	8b 45 08             	mov    0x8(%ebp),%eax
  801231:	05 00 00 00 30       	add    $0x30000000,%eax
  801236:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801248:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124d:	89 c2                	mov    %eax,%edx
  80124f:	c1 ea 16             	shr    $0x16,%edx
  801252:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801259:	f6 c2 01             	test   $0x1,%dl
  80125c:	74 11                	je     80126f <fd_alloc+0x2d>
  80125e:	89 c2                	mov    %eax,%edx
  801260:	c1 ea 0c             	shr    $0xc,%edx
  801263:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126a:	f6 c2 01             	test   $0x1,%dl
  80126d:	75 09                	jne    801278 <fd_alloc+0x36>
			*fd_store = fd;
  80126f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	eb 17                	jmp    80128f <fd_alloc+0x4d>
  801278:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801282:	75 c9                	jne    80124d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801284:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80128a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801297:	83 f8 1f             	cmp    $0x1f,%eax
  80129a:	77 36                	ja     8012d2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129c:	c1 e0 0c             	shl    $0xc,%eax
  80129f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	c1 ea 16             	shr    $0x16,%edx
  8012a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b0:	f6 c2 01             	test   $0x1,%dl
  8012b3:	74 24                	je     8012d9 <fd_lookup+0x48>
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	c1 ea 0c             	shr    $0xc,%edx
  8012ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c1:	f6 c2 01             	test   $0x1,%dl
  8012c4:	74 1a                	je     8012e0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c9:	89 02                	mov    %eax,(%edx)
	return 0;
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d0:	eb 13                	jmp    8012e5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d7:	eb 0c                	jmp    8012e5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012de:	eb 05                	jmp    8012e5 <fd_lookup+0x54>
  8012e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f0:	ba 6c 29 80 00       	mov    $0x80296c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f5:	eb 13                	jmp    80130a <dev_lookup+0x23>
  8012f7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012fa:	39 08                	cmp    %ecx,(%eax)
  8012fc:	75 0c                	jne    80130a <dev_lookup+0x23>
			*dev = devtab[i];
  8012fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801301:	89 01                	mov    %eax,(%ecx)
			return 0;
  801303:	b8 00 00 00 00       	mov    $0x0,%eax
  801308:	eb 2e                	jmp    801338 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80130a:	8b 02                	mov    (%edx),%eax
  80130c:	85 c0                	test   %eax,%eax
  80130e:	75 e7                	jne    8012f7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801310:	a1 20 44 80 00       	mov    0x804420,%eax
  801315:	8b 40 48             	mov    0x48(%eax),%eax
  801318:	83 ec 04             	sub    $0x4,%esp
  80131b:	51                   	push   %ecx
  80131c:	50                   	push   %eax
  80131d:	68 ec 28 80 00       	push   $0x8028ec
  801322:	e8 ca ef ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  801327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	56                   	push   %esi
  80133e:	53                   	push   %ebx
  80133f:	83 ec 10             	sub    $0x10,%esp
  801342:	8b 75 08             	mov    0x8(%ebp),%esi
  801345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
  801355:	50                   	push   %eax
  801356:	e8 36 ff ff ff       	call   801291 <fd_lookup>
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 05                	js     801367 <fd_close+0x2d>
	    || fd != fd2)
  801362:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801365:	74 0c                	je     801373 <fd_close+0x39>
		return (must_exist ? r : 0);
  801367:	84 db                	test   %bl,%bl
  801369:	ba 00 00 00 00       	mov    $0x0,%edx
  80136e:	0f 44 c2             	cmove  %edx,%eax
  801371:	eb 41                	jmp    8013b4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	ff 36                	pushl  (%esi)
  80137c:	e8 66 ff ff ff       	call   8012e7 <dev_lookup>
  801381:	89 c3                	mov    %eax,%ebx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 1a                	js     8013a4 <fd_close+0x6a>
		if (dev->dev_close)
  80138a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801390:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801395:	85 c0                	test   %eax,%eax
  801397:	74 0b                	je     8013a4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	56                   	push   %esi
  80139d:	ff d0                	call   *%eax
  80139f:	89 c3                	mov    %eax,%ebx
  8013a1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	56                   	push   %esi
  8013a8:	6a 00                	push   $0x0
  8013aa:	e8 f6 f9 ff ff       	call   800da5 <sys_page_unmap>
	return r;
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	89 d8                	mov    %ebx,%eax
}
  8013b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	ff 75 08             	pushl  0x8(%ebp)
  8013c8:	e8 c4 fe ff ff       	call   801291 <fd_lookup>
  8013cd:	83 c4 08             	add    $0x8,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 10                	js     8013e4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	6a 01                	push   $0x1
  8013d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013dc:	e8 59 ff ff ff       	call   80133a <fd_close>
  8013e1:	83 c4 10             	add    $0x10,%esp
}
  8013e4:	c9                   	leave  
  8013e5:	c3                   	ret    

008013e6 <close_all>:

void
close_all(void)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	53                   	push   %ebx
  8013f6:	e8 c0 ff ff ff       	call   8013bb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fb:	83 c3 01             	add    $0x1,%ebx
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	83 fb 20             	cmp    $0x20,%ebx
  801404:	75 ec                	jne    8013f2 <close_all+0xc>
		close(i);
}
  801406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	57                   	push   %edi
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 2c             	sub    $0x2c,%esp
  801414:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801417:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	ff 75 08             	pushl  0x8(%ebp)
  80141e:	e8 6e fe ff ff       	call   801291 <fd_lookup>
  801423:	83 c4 08             	add    $0x8,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	0f 88 c1 00 00 00    	js     8014ef <dup+0xe4>
		return r;
	close(newfdnum);
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	56                   	push   %esi
  801432:	e8 84 ff ff ff       	call   8013bb <close>

	newfd = INDEX2FD(newfdnum);
  801437:	89 f3                	mov    %esi,%ebx
  801439:	c1 e3 0c             	shl    $0xc,%ebx
  80143c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801442:	83 c4 04             	add    $0x4,%esp
  801445:	ff 75 e4             	pushl  -0x1c(%ebp)
  801448:	e8 de fd ff ff       	call   80122b <fd2data>
  80144d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80144f:	89 1c 24             	mov    %ebx,(%esp)
  801452:	e8 d4 fd ff ff       	call   80122b <fd2data>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145d:	89 f8                	mov    %edi,%eax
  80145f:	c1 e8 16             	shr    $0x16,%eax
  801462:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801469:	a8 01                	test   $0x1,%al
  80146b:	74 37                	je     8014a4 <dup+0x99>
  80146d:	89 f8                	mov    %edi,%eax
  80146f:	c1 e8 0c             	shr    $0xc,%eax
  801472:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801479:	f6 c2 01             	test   $0x1,%dl
  80147c:	74 26                	je     8014a4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801485:	83 ec 0c             	sub    $0xc,%esp
  801488:	25 07 0e 00 00       	and    $0xe07,%eax
  80148d:	50                   	push   %eax
  80148e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801491:	6a 00                	push   $0x0
  801493:	57                   	push   %edi
  801494:	6a 00                	push   $0x0
  801496:	e8 c8 f8 ff ff       	call   800d63 <sys_page_map>
  80149b:	89 c7                	mov    %eax,%edi
  80149d:	83 c4 20             	add    $0x20,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 2e                	js     8014d2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a7:	89 d0                	mov    %edx,%eax
  8014a9:	c1 e8 0c             	shr    $0xc,%eax
  8014ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014bb:	50                   	push   %eax
  8014bc:	53                   	push   %ebx
  8014bd:	6a 00                	push   $0x0
  8014bf:	52                   	push   %edx
  8014c0:	6a 00                	push   $0x0
  8014c2:	e8 9c f8 ff ff       	call   800d63 <sys_page_map>
  8014c7:	89 c7                	mov    %eax,%edi
  8014c9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014cc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ce:	85 ff                	test   %edi,%edi
  8014d0:	79 1d                	jns    8014ef <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	53                   	push   %ebx
  8014d6:	6a 00                	push   $0x0
  8014d8:	e8 c8 f8 ff ff       	call   800da5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e3:	6a 00                	push   $0x0
  8014e5:	e8 bb f8 ff ff       	call   800da5 <sys_page_unmap>
	return r;
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	89 f8                	mov    %edi,%eax
}
  8014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f2:	5b                   	pop    %ebx
  8014f3:	5e                   	pop    %esi
  8014f4:	5f                   	pop    %edi
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	53                   	push   %ebx
  8014fb:	83 ec 14             	sub    $0x14,%esp
  8014fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801501:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	53                   	push   %ebx
  801506:	e8 86 fd ff ff       	call   801291 <fd_lookup>
  80150b:	83 c4 08             	add    $0x8,%esp
  80150e:	89 c2                	mov    %eax,%edx
  801510:	85 c0                	test   %eax,%eax
  801512:	78 6d                	js     801581 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	ff 30                	pushl  (%eax)
  801520:	e8 c2 fd ff ff       	call   8012e7 <dev_lookup>
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 4c                	js     801578 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152f:	8b 42 08             	mov    0x8(%edx),%eax
  801532:	83 e0 03             	and    $0x3,%eax
  801535:	83 f8 01             	cmp    $0x1,%eax
  801538:	75 21                	jne    80155b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80153a:	a1 20 44 80 00       	mov    0x804420,%eax
  80153f:	8b 40 48             	mov    0x48(%eax),%eax
  801542:	83 ec 04             	sub    $0x4,%esp
  801545:	53                   	push   %ebx
  801546:	50                   	push   %eax
  801547:	68 30 29 80 00       	push   $0x802930
  80154c:	e8 a0 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801559:	eb 26                	jmp    801581 <read+0x8a>
	}
	if (!dev->dev_read)
  80155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155e:	8b 40 08             	mov    0x8(%eax),%eax
  801561:	85 c0                	test   %eax,%eax
  801563:	74 17                	je     80157c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801565:	83 ec 04             	sub    $0x4,%esp
  801568:	ff 75 10             	pushl  0x10(%ebp)
  80156b:	ff 75 0c             	pushl  0xc(%ebp)
  80156e:	52                   	push   %edx
  80156f:	ff d0                	call   *%eax
  801571:	89 c2                	mov    %eax,%edx
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	eb 09                	jmp    801581 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801578:	89 c2                	mov    %eax,%edx
  80157a:	eb 05                	jmp    801581 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801581:	89 d0                	mov    %edx,%eax
  801583:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	57                   	push   %edi
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	8b 7d 08             	mov    0x8(%ebp),%edi
  801594:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801597:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159c:	eb 21                	jmp    8015bf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	89 f0                	mov    %esi,%eax
  8015a3:	29 d8                	sub    %ebx,%eax
  8015a5:	50                   	push   %eax
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	03 45 0c             	add    0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	57                   	push   %edi
  8015ad:	e8 45 ff ff ff       	call   8014f7 <read>
		if (m < 0)
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 10                	js     8015c9 <readn+0x41>
			return m;
		if (m == 0)
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	74 0a                	je     8015c7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bd:	01 c3                	add    %eax,%ebx
  8015bf:	39 f3                	cmp    %esi,%ebx
  8015c1:	72 db                	jb     80159e <readn+0x16>
  8015c3:	89 d8                	mov    %ebx,%eax
  8015c5:	eb 02                	jmp    8015c9 <readn+0x41>
  8015c7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5f                   	pop    %edi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 14             	sub    $0x14,%esp
  8015d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	53                   	push   %ebx
  8015e0:	e8 ac fc ff ff       	call   801291 <fd_lookup>
  8015e5:	83 c4 08             	add    $0x8,%esp
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 68                	js     801656 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ee:	83 ec 08             	sub    $0x8,%esp
  8015f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f8:	ff 30                	pushl  (%eax)
  8015fa:	e8 e8 fc ff ff       	call   8012e7 <dev_lookup>
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 47                	js     80164d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801609:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160d:	75 21                	jne    801630 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160f:	a1 20 44 80 00       	mov    0x804420,%eax
  801614:	8b 40 48             	mov    0x48(%eax),%eax
  801617:	83 ec 04             	sub    $0x4,%esp
  80161a:	53                   	push   %ebx
  80161b:	50                   	push   %eax
  80161c:	68 4c 29 80 00       	push   $0x80294c
  801621:	e8 cb ec ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162e:	eb 26                	jmp    801656 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801630:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801633:	8b 52 0c             	mov    0xc(%edx),%edx
  801636:	85 d2                	test   %edx,%edx
  801638:	74 17                	je     801651 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163a:	83 ec 04             	sub    $0x4,%esp
  80163d:	ff 75 10             	pushl  0x10(%ebp)
  801640:	ff 75 0c             	pushl  0xc(%ebp)
  801643:	50                   	push   %eax
  801644:	ff d2                	call   *%edx
  801646:	89 c2                	mov    %eax,%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 09                	jmp    801656 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164d:	89 c2                	mov    %eax,%edx
  80164f:	eb 05                	jmp    801656 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801651:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801656:	89 d0                	mov    %edx,%eax
  801658:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <seek>:

int
seek(int fdnum, off_t offset)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801663:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	ff 75 08             	pushl  0x8(%ebp)
  80166a:	e8 22 fc ff ff       	call   801291 <fd_lookup>
  80166f:	83 c4 08             	add    $0x8,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 0e                	js     801684 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801676:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801679:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	53                   	push   %ebx
  801695:	e8 f7 fb ff ff       	call   801291 <fd_lookup>
  80169a:	83 c4 08             	add    $0x8,%esp
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 65                	js     801708 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	ff 30                	pushl  (%eax)
  8016af:	e8 33 fc ff ff       	call   8012e7 <dev_lookup>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 44                	js     8016ff <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c2:	75 21                	jne    8016e5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c4:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c9:	8b 40 48             	mov    0x48(%eax),%eax
  8016cc:	83 ec 04             	sub    $0x4,%esp
  8016cf:	53                   	push   %ebx
  8016d0:	50                   	push   %eax
  8016d1:	68 0c 29 80 00       	push   $0x80290c
  8016d6:	e8 16 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e3:	eb 23                	jmp    801708 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e8:	8b 52 18             	mov    0x18(%edx),%edx
  8016eb:	85 d2                	test   %edx,%edx
  8016ed:	74 14                	je     801703 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	ff 75 0c             	pushl  0xc(%ebp)
  8016f5:	50                   	push   %eax
  8016f6:	ff d2                	call   *%edx
  8016f8:	89 c2                	mov    %eax,%edx
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	eb 09                	jmp    801708 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	eb 05                	jmp    801708 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801703:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801708:	89 d0                	mov    %edx,%eax
  80170a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 14             	sub    $0x14,%esp
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801719:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171c:	50                   	push   %eax
  80171d:	ff 75 08             	pushl  0x8(%ebp)
  801720:	e8 6c fb ff ff       	call   801291 <fd_lookup>
  801725:	83 c4 08             	add    $0x8,%esp
  801728:	89 c2                	mov    %eax,%edx
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 58                	js     801786 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	ff 30                	pushl  (%eax)
  80173a:	e8 a8 fb ff ff       	call   8012e7 <dev_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 37                	js     80177d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801749:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174d:	74 32                	je     801781 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801752:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801759:	00 00 00 
	stat->st_isdir = 0;
  80175c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801763:	00 00 00 
	stat->st_dev = dev;
  801766:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	53                   	push   %ebx
  801770:	ff 75 f0             	pushl  -0x10(%ebp)
  801773:	ff 50 14             	call   *0x14(%eax)
  801776:	89 c2                	mov    %eax,%edx
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	eb 09                	jmp    801786 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177d:	89 c2                	mov    %eax,%edx
  80177f:	eb 05                	jmp    801786 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801786:	89 d0                	mov    %edx,%eax
  801788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	6a 00                	push   $0x0
  801797:	ff 75 08             	pushl  0x8(%ebp)
  80179a:	e8 b7 01 00 00       	call   801956 <open>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 1b                	js     8017c3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	50                   	push   %eax
  8017af:	e8 5b ff ff ff       	call   80170f <fstat>
  8017b4:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b6:	89 1c 24             	mov    %ebx,(%esp)
  8017b9:	e8 fd fb ff ff       	call   8013bb <close>
	return r;
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	89 f0                	mov    %esi,%eax
}
  8017c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	56                   	push   %esi
  8017ce:	53                   	push   %ebx
  8017cf:	89 c6                	mov    %eax,%esi
  8017d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017da:	75 12                	jne    8017ee <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017dc:	83 ec 0c             	sub    $0xc,%esp
  8017df:	6a 01                	push   $0x1
  8017e1:	e8 7b 08 00 00       	call   802061 <ipc_find_env>
  8017e6:	a3 00 40 80 00       	mov    %eax,0x804000
  8017eb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ee:	6a 07                	push   $0x7
  8017f0:	68 00 50 80 00       	push   $0x805000
  8017f5:	56                   	push   %esi
  8017f6:	ff 35 00 40 80 00    	pushl  0x804000
  8017fc:	e8 0c 08 00 00       	call   80200d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801801:	83 c4 0c             	add    $0xc,%esp
  801804:	6a 00                	push   $0x0
  801806:	53                   	push   %ebx
  801807:	6a 00                	push   $0x0
  801809:	e8 8a 07 00 00       	call   801f98 <ipc_recv>
}
  80180e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801811:	5b                   	pop    %ebx
  801812:	5e                   	pop    %esi
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	8b 40 0c             	mov    0xc(%eax),%eax
  801821:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	b8 02 00 00 00       	mov    $0x2,%eax
  801838:	e8 8d ff ff ff       	call   8017ca <fsipc>
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	8b 40 0c             	mov    0xc(%eax),%eax
  80184b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801850:	ba 00 00 00 00       	mov    $0x0,%edx
  801855:	b8 06 00 00 00       	mov    $0x6,%eax
  80185a:	e8 6b ff ff ff       	call   8017ca <fsipc>
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	53                   	push   %ebx
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186b:	8b 45 08             	mov    0x8(%ebp),%eax
  80186e:	8b 40 0c             	mov    0xc(%eax),%eax
  801871:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801876:	ba 00 00 00 00       	mov    $0x0,%edx
  80187b:	b8 05 00 00 00       	mov    $0x5,%eax
  801880:	e8 45 ff ff ff       	call   8017ca <fsipc>
  801885:	85 c0                	test   %eax,%eax
  801887:	78 2c                	js     8018b5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	68 00 50 80 00       	push   $0x805000
  801891:	53                   	push   %ebx
  801892:	e8 86 f0 ff ff       	call   80091d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801897:	a1 80 50 80 00       	mov    0x805080,%eax
  80189c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a2:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018c0:	68 7c 29 80 00       	push   $0x80297c
  8018c5:	68 90 00 00 00       	push   $0x90
  8018ca:	68 9a 29 80 00       	push   $0x80299a
  8018cf:	e8 44 e9 ff ff       	call   800218 <_panic>

008018d4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f7:	e8 ce fe ff ff       	call   8017ca <fsipc>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 4b                	js     80194d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801902:	39 c6                	cmp    %eax,%esi
  801904:	73 16                	jae    80191c <devfile_read+0x48>
  801906:	68 a5 29 80 00       	push   $0x8029a5
  80190b:	68 ac 29 80 00       	push   $0x8029ac
  801910:	6a 7c                	push   $0x7c
  801912:	68 9a 29 80 00       	push   $0x80299a
  801917:	e8 fc e8 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  80191c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801921:	7e 16                	jle    801939 <devfile_read+0x65>
  801923:	68 c1 29 80 00       	push   $0x8029c1
  801928:	68 ac 29 80 00       	push   $0x8029ac
  80192d:	6a 7d                	push   $0x7d
  80192f:	68 9a 29 80 00       	push   $0x80299a
  801934:	e8 df e8 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	50                   	push   %eax
  80193d:	68 00 50 80 00       	push   $0x805000
  801942:	ff 75 0c             	pushl  0xc(%ebp)
  801945:	e8 65 f1 ff ff       	call   800aaf <memmove>
	return r;
  80194a:	83 c4 10             	add    $0x10,%esp
}
  80194d:	89 d8                	mov    %ebx,%eax
  80194f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	53                   	push   %ebx
  80195a:	83 ec 20             	sub    $0x20,%esp
  80195d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801960:	53                   	push   %ebx
  801961:	e8 7e ef ff ff       	call   8008e4 <strlen>
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80196e:	7f 67                	jg     8019d7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	e8 c6 f8 ff ff       	call   801242 <fd_alloc>
  80197c:	83 c4 10             	add    $0x10,%esp
		return r;
  80197f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801981:	85 c0                	test   %eax,%eax
  801983:	78 57                	js     8019dc <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	53                   	push   %ebx
  801989:	68 00 50 80 00       	push   $0x805000
  80198e:	e8 8a ef ff ff       	call   80091d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801993:	8b 45 0c             	mov    0xc(%ebp),%eax
  801996:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80199b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199e:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a3:	e8 22 fe ff ff       	call   8017ca <fsipc>
  8019a8:	89 c3                	mov    %eax,%ebx
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	79 14                	jns    8019c5 <open+0x6f>
		fd_close(fd, 0);
  8019b1:	83 ec 08             	sub    $0x8,%esp
  8019b4:	6a 00                	push   $0x0
  8019b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b9:	e8 7c f9 ff ff       	call   80133a <fd_close>
		return r;
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	89 da                	mov    %ebx,%edx
  8019c3:	eb 17                	jmp    8019dc <open+0x86>
	}

	return fd2num(fd);
  8019c5:	83 ec 0c             	sub    $0xc,%esp
  8019c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cb:	e8 4b f8 ff ff       	call   80121b <fd2num>
  8019d0:	89 c2                	mov    %eax,%edx
  8019d2:	83 c4 10             	add    $0x10,%esp
  8019d5:	eb 05                	jmp    8019dc <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019d7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019dc:	89 d0                	mov    %edx,%eax
  8019de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f3:	e8 d2 fd ff ff       	call   8017ca <fsipc>
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 08             	pushl  0x8(%ebp)
  801a08:	e8 1e f8 ff ff       	call   80122b <fd2data>
  801a0d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a0f:	83 c4 08             	add    $0x8,%esp
  801a12:	68 cd 29 80 00       	push   $0x8029cd
  801a17:	53                   	push   %ebx
  801a18:	e8 00 ef ff ff       	call   80091d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a1d:	8b 46 04             	mov    0x4(%esi),%eax
  801a20:	2b 06                	sub    (%esi),%eax
  801a22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a2f:	00 00 00 
	stat->st_dev = &devpipe;
  801a32:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a39:	30 80 00 
	return 0;
}
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a52:	53                   	push   %ebx
  801a53:	6a 00                	push   $0x0
  801a55:	e8 4b f3 ff ff       	call   800da5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5a:	89 1c 24             	mov    %ebx,(%esp)
  801a5d:	e8 c9 f7 ff ff       	call   80122b <fd2data>
  801a62:	83 c4 08             	add    $0x8,%esp
  801a65:	50                   	push   %eax
  801a66:	6a 00                	push   $0x0
  801a68:	e8 38 f3 ff ff       	call   800da5 <sys_page_unmap>
}
  801a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	57                   	push   %edi
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	83 ec 1c             	sub    $0x1c,%esp
  801a7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a7e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a80:	a1 20 44 80 00       	mov    0x804420,%eax
  801a85:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a8e:	e8 07 06 00 00       	call   80209a <pageref>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	89 3c 24             	mov    %edi,(%esp)
  801a98:	e8 fd 05 00 00       	call   80209a <pageref>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	39 c3                	cmp    %eax,%ebx
  801aa2:	0f 94 c1             	sete   %cl
  801aa5:	0f b6 c9             	movzbl %cl,%ecx
  801aa8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aab:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ab1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab4:	39 ce                	cmp    %ecx,%esi
  801ab6:	74 1b                	je     801ad3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ab8:	39 c3                	cmp    %eax,%ebx
  801aba:	75 c4                	jne    801a80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abc:	8b 42 58             	mov    0x58(%edx),%eax
  801abf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac2:	50                   	push   %eax
  801ac3:	56                   	push   %esi
  801ac4:	68 d4 29 80 00       	push   $0x8029d4
  801ac9:	e8 23 e8 ff ff       	call   8002f1 <cprintf>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	eb ad                	jmp    801a80 <_pipeisclosed+0xe>
	}
}
  801ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 28             	sub    $0x28,%esp
  801ae7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aea:	56                   	push   %esi
  801aeb:	e8 3b f7 ff ff       	call   80122b <fd2data>
  801af0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	bf 00 00 00 00       	mov    $0x0,%edi
  801afa:	eb 4b                	jmp    801b47 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801afc:	89 da                	mov    %ebx,%edx
  801afe:	89 f0                	mov    %esi,%eax
  801b00:	e8 6d ff ff ff       	call   801a72 <_pipeisclosed>
  801b05:	85 c0                	test   %eax,%eax
  801b07:	75 48                	jne    801b51 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b09:	e8 f3 f1 ff ff       	call   800d01 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b0e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b11:	8b 0b                	mov    (%ebx),%ecx
  801b13:	8d 51 20             	lea    0x20(%ecx),%edx
  801b16:	39 d0                	cmp    %edx,%eax
  801b18:	73 e2                	jae    801afc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b21:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b24:	89 c2                	mov    %eax,%edx
  801b26:	c1 fa 1f             	sar    $0x1f,%edx
  801b29:	89 d1                	mov    %edx,%ecx
  801b2b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b2e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b31:	83 e2 1f             	and    $0x1f,%edx
  801b34:	29 ca                	sub    %ecx,%edx
  801b36:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b3a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b3e:	83 c0 01             	add    $0x1,%eax
  801b41:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b44:	83 c7 01             	add    $0x1,%edi
  801b47:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4a:	75 c2                	jne    801b0e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4f:	eb 05                	jmp    801b56 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 18             	sub    $0x18,%esp
  801b67:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b6a:	57                   	push   %edi
  801b6b:	e8 bb f6 ff ff       	call   80122b <fd2data>
  801b70:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7a:	eb 3d                	jmp    801bb9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7c:	85 db                	test   %ebx,%ebx
  801b7e:	74 04                	je     801b84 <devpipe_read+0x26>
				return i;
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	eb 44                	jmp    801bc8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b84:	89 f2                	mov    %esi,%edx
  801b86:	89 f8                	mov    %edi,%eax
  801b88:	e8 e5 fe ff ff       	call   801a72 <_pipeisclosed>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	75 32                	jne    801bc3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b91:	e8 6b f1 ff ff       	call   800d01 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b96:	8b 06                	mov    (%esi),%eax
  801b98:	3b 46 04             	cmp    0x4(%esi),%eax
  801b9b:	74 df                	je     801b7c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b9d:	99                   	cltd   
  801b9e:	c1 ea 1b             	shr    $0x1b,%edx
  801ba1:	01 d0                	add    %edx,%eax
  801ba3:	83 e0 1f             	and    $0x1f,%eax
  801ba6:	29 d0                	sub    %edx,%eax
  801ba8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bb3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb6:	83 c3 01             	add    $0x1,%ebx
  801bb9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bbc:	75 d8                	jne    801b96 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bbe:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc1:	eb 05                	jmp    801bc8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	e8 61 f6 ff ff       	call   801242 <fd_alloc>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	89 c2                	mov    %eax,%edx
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 2c 01 00 00    	js     801d1a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	68 07 04 00 00       	push   $0x407
  801bf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 20 f1 ff ff       	call   800d20 <sys_page_alloc>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 0d 01 00 00    	js     801d1a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	e8 29 f6 ff ff       	call   801242 <fd_alloc>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	0f 88 e2 00 00 00    	js     801d08 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c26:	83 ec 04             	sub    $0x4,%esp
  801c29:	68 07 04 00 00       	push   $0x407
  801c2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c31:	6a 00                	push   $0x0
  801c33:	e8 e8 f0 ff ff       	call   800d20 <sys_page_alloc>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	0f 88 c3 00 00 00    	js     801d08 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4b:	e8 db f5 ff ff       	call   80122b <fd2data>
  801c50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c52:	83 c4 0c             	add    $0xc,%esp
  801c55:	68 07 04 00 00       	push   $0x407
  801c5a:	50                   	push   %eax
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 be f0 ff ff       	call   800d20 <sys_page_alloc>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	0f 88 89 00 00 00    	js     801cf8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	ff 75 f0             	pushl  -0x10(%ebp)
  801c75:	e8 b1 f5 ff ff       	call   80122b <fd2data>
  801c7a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c81:	50                   	push   %eax
  801c82:	6a 00                	push   $0x0
  801c84:	56                   	push   %esi
  801c85:	6a 00                	push   $0x0
  801c87:	e8 d7 f0 ff ff       	call   800d63 <sys_page_map>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	83 c4 20             	add    $0x20,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 55                	js     801cea <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c95:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801caa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	e8 51 f5 ff ff       	call   80121b <fd2num>
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ccf:	83 c4 04             	add    $0x4,%esp
  801cd2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd5:	e8 41 f5 ff ff       	call   80121b <fd2num>
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce8:	eb 30                	jmp    801d1a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	56                   	push   %esi
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 b0 f0 ff ff       	call   800da5 <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 a0 f0 ff ff       	call   800da5 <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 90 f0 ff ff       	call   800da5 <sys_page_unmap>
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2c:	50                   	push   %eax
  801d2d:	ff 75 08             	pushl  0x8(%ebp)
  801d30:	e8 5c f5 ff ff       	call   801291 <fd_lookup>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 18                	js     801d54 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d42:	e8 e4 f4 ff ff       	call   80122b <fd2data>
	return _pipeisclosed(fd, p);
  801d47:	89 c2                	mov    %eax,%edx
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	e8 21 fd ff ff       	call   801a72 <_pipeisclosed>
  801d51:	83 c4 10             	add    $0x10,%esp
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	56                   	push   %esi
  801d5a:	53                   	push   %ebx
  801d5b:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d5e:	85 f6                	test   %esi,%esi
  801d60:	75 16                	jne    801d78 <wait+0x22>
  801d62:	68 ec 29 80 00       	push   $0x8029ec
  801d67:	68 ac 29 80 00       	push   $0x8029ac
  801d6c:	6a 09                	push   $0x9
  801d6e:	68 f7 29 80 00       	push   $0x8029f7
  801d73:	e8 a0 e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d78:	89 f3                	mov    %esi,%ebx
  801d7a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d80:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d83:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d89:	eb 05                	jmp    801d90 <wait+0x3a>
		sys_yield();
  801d8b:	e8 71 ef ff ff       	call   800d01 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d90:	8b 43 48             	mov    0x48(%ebx),%eax
  801d93:	39 c6                	cmp    %eax,%esi
  801d95:	75 07                	jne    801d9e <wait+0x48>
  801d97:	8b 43 54             	mov    0x54(%ebx),%eax
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	75 ed                	jne    801d8b <wait+0x35>
		sys_yield();
}
  801d9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801db5:	68 02 2a 80 00       	push   $0x802a02
  801dba:	ff 75 0c             	pushl  0xc(%ebp)
  801dbd:	e8 5b eb ff ff       	call   80091d <strcpy>
	return 0;
}
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	57                   	push   %edi
  801dcd:	56                   	push   %esi
  801dce:	53                   	push   %ebx
  801dcf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dda:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de0:	eb 2d                	jmp    801e0f <devcons_write+0x46>
		m = n - tot;
  801de2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801de5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801de7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dea:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801def:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df2:	83 ec 04             	sub    $0x4,%esp
  801df5:	53                   	push   %ebx
  801df6:	03 45 0c             	add    0xc(%ebp),%eax
  801df9:	50                   	push   %eax
  801dfa:	57                   	push   %edi
  801dfb:	e8 af ec ff ff       	call   800aaf <memmove>
		sys_cputs(buf, m);
  801e00:	83 c4 08             	add    $0x8,%esp
  801e03:	53                   	push   %ebx
  801e04:	57                   	push   %edi
  801e05:	e8 5a ee ff ff       	call   800c64 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0a:	01 de                	add    %ebx,%esi
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e14:	72 cc                	jb     801de2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e19:	5b                   	pop    %ebx
  801e1a:	5e                   	pop    %esi
  801e1b:	5f                   	pop    %edi
  801e1c:	5d                   	pop    %ebp
  801e1d:	c3                   	ret    

00801e1e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	83 ec 08             	sub    $0x8,%esp
  801e24:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e2d:	74 2a                	je     801e59 <devcons_read+0x3b>
  801e2f:	eb 05                	jmp    801e36 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e31:	e8 cb ee ff ff       	call   800d01 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e36:	e8 47 ee ff ff       	call   800c82 <sys_cgetc>
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	74 f2                	je     801e31 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	78 16                	js     801e59 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e43:	83 f8 04             	cmp    $0x4,%eax
  801e46:	74 0c                	je     801e54 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4b:	88 02                	mov    %al,(%edx)
	return 1;
  801e4d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e52:	eb 05                	jmp    801e59 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e61:	8b 45 08             	mov    0x8(%ebp),%eax
  801e64:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e67:	6a 01                	push   $0x1
  801e69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6c:	50                   	push   %eax
  801e6d:	e8 f2 ed ff ff       	call   800c64 <sys_cputs>
}
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <getchar>:

int
getchar(void)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e7d:	6a 01                	push   $0x1
  801e7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	6a 00                	push   $0x0
  801e85:	e8 6d f6 ff ff       	call   8014f7 <read>
	if (r < 0)
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 0f                	js     801ea0 <getchar+0x29>
		return r;
	if (r < 1)
  801e91:	85 c0                	test   %eax,%eax
  801e93:	7e 06                	jle    801e9b <getchar+0x24>
		return -E_EOF;
	return c;
  801e95:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e99:	eb 05                	jmp    801ea0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e9b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	ff 75 08             	pushl  0x8(%ebp)
  801eaf:	e8 dd f3 ff ff       	call   801291 <fd_lookup>
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 11                	js     801ecc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec4:	39 10                	cmp    %edx,(%eax)
  801ec6:	0f 94 c0             	sete   %al
  801ec9:	0f b6 c0             	movzbl %al,%eax
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <opencons>:

int
opencons(void)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	e8 65 f3 ff ff       	call   801242 <fd_alloc>
  801edd:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 3e                	js     801f24 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee6:	83 ec 04             	sub    $0x4,%esp
  801ee9:	68 07 04 00 00       	push   $0x407
  801eee:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef1:	6a 00                	push   $0x0
  801ef3:	e8 28 ee ff ff       	call   800d20 <sys_page_alloc>
  801ef8:	83 c4 10             	add    $0x10,%esp
		return r;
  801efb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801efd:	85 c0                	test   %eax,%eax
  801eff:	78 23                	js     801f24 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	50                   	push   %eax
  801f1a:	e8 fc f2 ff ff       	call   80121b <fd2num>
  801f1f:	89 c2                	mov    %eax,%edx
  801f21:	83 c4 10             	add    $0x10,%esp
}
  801f24:	89 d0                	mov    %edx,%eax
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f2e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f35:	75 31                	jne    801f68 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801f37:	a1 20 44 80 00       	mov    0x804420,%eax
  801f3c:	8b 40 48             	mov    0x48(%eax),%eax
  801f3f:	83 ec 04             	sub    $0x4,%esp
  801f42:	6a 07                	push   $0x7
  801f44:	68 00 f0 bf ee       	push   $0xeebff000
  801f49:	50                   	push   %eax
  801f4a:	e8 d1 ed ff ff       	call   800d20 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801f4f:	a1 20 44 80 00       	mov    0x804420,%eax
  801f54:	8b 40 48             	mov    0x48(%eax),%eax
  801f57:	83 c4 08             	add    $0x8,%esp
  801f5a:	68 72 1f 80 00       	push   $0x801f72
  801f5f:	50                   	push   %eax
  801f60:	e8 06 ef ff ff       	call   800e6b <sys_env_set_pgfault_upcall>
  801f65:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f68:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6b:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f72:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f73:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f78:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f7a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  801f7d:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  801f80:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  801f84:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  801f88:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  801f8b:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  801f8d:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801f91:	61                   	popa   
	addl $4, %esp        // skip eip
  801f92:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  801f95:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801f96:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f97:	c3                   	ret    

00801f98 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	56                   	push   %esi
  801f9c:	53                   	push   %ebx
  801f9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	74 0e                	je     801fb8 <ipc_recv+0x20>
  801faa:	83 ec 0c             	sub    $0xc,%esp
  801fad:	50                   	push   %eax
  801fae:	e8 1d ef ff ff       	call   800ed0 <sys_ipc_recv>
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	eb 10                	jmp    801fc8 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	68 00 00 c0 ee       	push   $0xeec00000
  801fc0:	e8 0b ef ff ff       	call   800ed0 <sys_ipc_recv>
  801fc5:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	74 16                	je     801fe2 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801fcc:	85 f6                	test   %esi,%esi
  801fce:	74 06                	je     801fd6 <ipc_recv+0x3e>
  801fd0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801fd6:	85 db                	test   %ebx,%ebx
  801fd8:	74 2c                	je     802006 <ipc_recv+0x6e>
  801fda:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fe0:	eb 24                	jmp    802006 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801fe2:	85 f6                	test   %esi,%esi
  801fe4:	74 0a                	je     801ff0 <ipc_recv+0x58>
  801fe6:	a1 20 44 80 00       	mov    0x804420,%eax
  801feb:	8b 40 74             	mov    0x74(%eax),%eax
  801fee:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801ff0:	85 db                	test   %ebx,%ebx
  801ff2:	74 0a                	je     801ffe <ipc_recv+0x66>
  801ff4:	a1 20 44 80 00       	mov    0x804420,%eax
  801ff9:	8b 40 78             	mov    0x78(%eax),%eax
  801ffc:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ffe:	a1 20 44 80 00       	mov    0x804420,%eax
  802003:	8b 40 70             	mov    0x70(%eax),%eax
}
  802006:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802009:	5b                   	pop    %ebx
  80200a:	5e                   	pop    %esi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    

0080200d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	57                   	push   %edi
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	83 ec 0c             	sub    $0xc,%esp
  802016:	8b 7d 08             	mov    0x8(%ebp),%edi
  802019:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201c:	8b 45 10             	mov    0x10(%ebp),%eax
  80201f:	85 c0                	test   %eax,%eax
  802021:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802026:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  802029:	ff 75 14             	pushl  0x14(%ebp)
  80202c:	53                   	push   %ebx
  80202d:	56                   	push   %esi
  80202e:	57                   	push   %edi
  80202f:	e8 79 ee ff ff       	call   800ead <sys_ipc_try_send>
		if (ret == 0) break;
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	85 c0                	test   %eax,%eax
  802039:	74 1e                	je     802059 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  80203b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80203e:	74 12                	je     802052 <ipc_send+0x45>
  802040:	50                   	push   %eax
  802041:	68 0e 2a 80 00       	push   $0x802a0e
  802046:	6a 39                	push   $0x39
  802048:	68 1b 2a 80 00       	push   $0x802a1b
  80204d:	e8 c6 e1 ff ff       	call   800218 <_panic>
		sys_yield();
  802052:	e8 aa ec ff ff       	call   800d01 <sys_yield>
	}
  802057:	eb d0                	jmp    802029 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  802059:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205c:	5b                   	pop    %ebx
  80205d:	5e                   	pop    %esi
  80205e:	5f                   	pop    %edi
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    

00802061 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80206c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80206f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802075:	8b 52 50             	mov    0x50(%edx),%edx
  802078:	39 ca                	cmp    %ecx,%edx
  80207a:	75 0d                	jne    802089 <ipc_find_env+0x28>
			return envs[i].env_id;
  80207c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80207f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802084:	8b 40 48             	mov    0x48(%eax),%eax
  802087:	eb 0f                	jmp    802098 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802089:	83 c0 01             	add    $0x1,%eax
  80208c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802091:	75 d9                	jne    80206c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802098:	5d                   	pop    %ebp
  802099:	c3                   	ret    

0080209a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80209a:	55                   	push   %ebp
  80209b:	89 e5                	mov    %esp,%ebp
  80209d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a0:	89 d0                	mov    %edx,%eax
  8020a2:	c1 e8 16             	shr    $0x16,%eax
  8020a5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b1:	f6 c1 01             	test   $0x1,%cl
  8020b4:	74 1d                	je     8020d3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020b6:	c1 ea 0c             	shr    $0xc,%edx
  8020b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020c0:	f6 c2 01             	test   $0x1,%dl
  8020c3:	74 0e                	je     8020d3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c5:	c1 ea 0c             	shr    $0xc,%edx
  8020c8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020cf:	ef 
  8020d0:	0f b7 c0             	movzwl %ax,%eax
}
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    
  8020d5:	66 90                	xchg   %ax,%ax
  8020d7:	66 90                	xchg   %ax,%ax
  8020d9:	66 90                	xchg   %ax,%ax
  8020db:	66 90                	xchg   %ax,%ax
  8020dd:	66 90                	xchg   %ax,%ax
  8020df:	90                   	nop

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
