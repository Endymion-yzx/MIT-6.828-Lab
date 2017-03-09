
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 20 1f 80 00       	push   $0x801f20
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 d4 0b 00 00       	call   800c32 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 1f 80 00       	push   $0x801f40
  80006f:	6a 0e                	push   $0xe
  800071:	68 2a 1f 80 00       	push   $0x801f2a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 1f 80 00       	push   $0x801f6c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 53 07 00 00       	call   8007dc <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 82 0d 00 00       	call   800e23 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 3c 1f 80 00       	push   $0x801f3c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 3c 1f 80 00       	push   $0x801f3c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000d5:	e8 1a 0b 00 00       	call   800bf4 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 43 0f 00 00       	call   80105e <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 8e 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 b7 0a 00 00       	call   800bf4 <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 98 1f 80 00       	push   $0x801f98
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 d6 09 00 00       	call   800b76 <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 1a 01 00 00       	call   800300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 7b 09 00 00       	call   800b76 <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 25 1a 00 00       	call   801c90 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 12 1b 00 00       	call   801dc0 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 bb 1f 80 00 	movsbl 0x801fbb(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d5:	73 0a                	jae    8002e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ec:	50                   	push   %eax
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	ff 75 0c             	pushl  0xc(%ebp)
  8002f3:	ff 75 08             	pushl  0x8(%ebp)
  8002f6:	e8 05 00 00 00       	call   800300 <vprintfmt>
	va_end(ap);
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 2c             	sub    $0x2c,%esp
  800309:	8b 75 08             	mov    0x8(%ebp),%esi
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800312:	eb 12                	jmp    800326 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800314:	85 c0                	test   %eax,%eax
  800316:	0f 84 6a 04 00 00    	je     800786 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	53                   	push   %ebx
  800320:	50                   	push   %eax
  800321:	ff d6                	call   *%esi
  800323:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800326:	83 c7 01             	add    $0x1,%edi
  800329:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e2                	jne    800314 <vprintfmt+0x14>
  800332:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800336:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800350:	eb 07                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8d 47 01             	lea    0x1(%edi),%eax
  80035c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035f:	0f b6 07             	movzbl (%edi),%eax
  800362:	0f b6 d0             	movzbl %al,%edx
  800365:	83 e8 23             	sub    $0x23,%eax
  800368:	3c 55                	cmp    $0x55,%al
  80036a:	0f 87 fb 03 00 00    	ja     80076b <vprintfmt+0x46b>
  800370:	0f b6 c0             	movzbl %al,%eax
  800373:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800381:	eb d6                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800386:	b8 00 00 00 00       	mov    $0x0,%eax
  80038b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800391:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800395:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800398:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 3f                	ja     8003df <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a3:	eb e9                	jmp    80038e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 40 04             	lea    0x4(%eax),%eax
  8003b3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 2a                	jmp    8003e5 <vprintfmt+0xe5>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c5:	0f 49 d0             	cmovns %eax,%edx
  8003c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 89                	jmp    800359 <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	e9 7a ff ff ff       	jmp    800359 <vprintfmt+0x59>
  8003df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	0f 89 6a ff ff ff    	jns    800359 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fc:	e9 58 ff ff ff       	jmp    800359 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800401:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	e9 4d ff ff ff       	jmp    800359 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800423:	e9 fe fe ff ff       	jmp    800326 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x145>
  80043a:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 1b                	jne    800460 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 d3 1f 80 00       	push   $0x801fd3
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 91 fe ff ff       	call   8002e3 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 c6 fe ff ff       	jmp    800326 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	52                   	push   %edx
  800461:	68 be 23 80 00       	push   $0x8023be
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 76 fe ff ff       	call   8002e3 <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800476:	e9 ab fe ff ff       	jmp    800326 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	83 c0 04             	add    $0x4,%eax
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800489:	85 ff                	test   %edi,%edi
  80048b:	b8 cc 1f 80 00       	mov    $0x801fcc,%eax
  800490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 8e 94 00 00 00    	jle    800531 <vprintfmt+0x231>
  80049d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a1:	0f 84 98 00 00 00    	je     80053f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 5b 03 00 00       	call   80080e <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1db>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1cc>
  8004df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c1             	cmovns %ecx,%eax
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 4d                	jmp    80054b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x21f>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x21f>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x24b>
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	eb 0c                	jmp    80054b <vprintfmt+0x24b>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	74 23                	je     80057c <vprintfmt+0x27c>
  800559:	85 f6                	test   %esi,%esi
  80055b:	78 a1                	js     8004fe <vprintfmt+0x1fe>
  80055d:	83 ee 01             	sub    $0x1,%esi
  800560:	79 9c                	jns    8004fe <vprintfmt+0x1fe>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb 18                	jmp    800584 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 20                	push   $0x20
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x284>
  80057c:	89 df                	mov    %ebx,%edi
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	85 ff                	test   %edi,%edi
  800586:	7f e4                	jg     80056c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800588:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	e9 90 fd ff ff       	jmp    800326 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800596:	83 f9 01             	cmp    $0x1,%ecx
  800599:	7e 19                	jle    8005b4 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 40 08             	lea    0x8(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b2:	eb 38                	jmp    8005ec <vprintfmt+0x2ec>
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	74 1b                	je     8005d3 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d1:	eb 19                	jmp    8005ec <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fb:	0f 89 36 01 00 00    	jns    800737 <vprintfmt+0x437>
				putch('-', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 2d                	push   $0x2d
  800607:	ff d6                	call   *%esi
				num = -(long long) num;
  800609:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060f:	f7 da                	neg    %edx
  800611:	83 d1 00             	adc    $0x0,%ecx
  800614:	f7 d9                	neg    %ecx
  800616:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 14 01 00 00       	jmp    800737 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 18                	jle    800640 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	e9 f7 00 00 00       	jmp    800737 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800640:	85 c9                	test   %ecx,%ecx
  800642:	74 1a                	je     80065e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
  800659:	e9 d9 00 00 00       	jmp    800737 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800673:	e9 bf 00 00 00       	jmp    800737 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800678:	83 f9 01             	cmp    $0x1,%ecx
  80067b:	7e 13                	jle    800690 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 50 04             	mov    0x4(%eax),%edx
  800683:	8b 00                	mov    (%eax),%eax
  800685:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800688:	8d 49 08             	lea    0x8(%ecx),%ecx
  80068b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80068e:	eb 28                	jmp    8006b8 <vprintfmt+0x3b8>
	else if (lflag)
  800690:	85 c9                	test   %ecx,%ecx
  800692:	74 13                	je     8006a7 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	89 d0                	mov    %edx,%eax
  80069b:	99                   	cltd   
  80069c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80069f:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006a2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006a5:	eb 11                	jmp    8006b8 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	99                   	cltd   
  8006af:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006b2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b5:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8006b8:	89 d1                	mov    %edx,%ecx
  8006ba:	89 c2                	mov    %eax,%edx
			base = 8;
  8006bc:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006c1:	eb 74                	jmp    800737 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006dd:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006eb:	eb 4a                	jmp    800737 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ed:	83 f9 01             	cmp    $0x1,%ecx
  8006f0:	7e 15                	jle    800707 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	8b 48 04             	mov    0x4(%eax),%ecx
  8006fa:	8d 40 08             	lea    0x8(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800700:	b8 10 00 00 00       	mov    $0x10,%eax
  800705:	eb 30                	jmp    800737 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800707:	85 c9                	test   %ecx,%ecx
  800709:	74 17                	je     800722 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8b 10                	mov    (%eax),%edx
  800710:	b9 00 00 00 00       	mov    $0x0,%ecx
  800715:	8d 40 04             	lea    0x4(%eax),%eax
  800718:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071b:	b8 10 00 00 00       	mov    $0x10,%eax
  800720:	eb 15                	jmp    800737 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 10                	mov    (%eax),%edx
  800727:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072c:	8d 40 04             	lea    0x4(%eax),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800737:	83 ec 0c             	sub    $0xc,%esp
  80073a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80073e:	57                   	push   %edi
  80073f:	ff 75 e0             	pushl  -0x20(%ebp)
  800742:	50                   	push   %eax
  800743:	51                   	push   %ecx
  800744:	52                   	push   %edx
  800745:	89 da                	mov    %ebx,%edx
  800747:	89 f0                	mov    %esi,%eax
  800749:	e8 c9 fa ff ff       	call   800217 <printnum>
			break;
  80074e:	83 c4 20             	add    $0x20,%esp
  800751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800754:	e9 cd fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	52                   	push   %edx
  80075e:	ff d6                	call   *%esi
			break;
  800760:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800766:	e9 bb fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 25                	push   $0x25
  800771:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 03                	jmp    80077b <vprintfmt+0x47b>
  800778:	83 ef 01             	sub    $0x1,%edi
  80077b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80077f:	75 f7                	jne    800778 <vprintfmt+0x478>
  800781:	e9 a0 fb ff ff       	jmp    800326 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800786:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	5f                   	pop    %edi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 18             	sub    $0x18,%esp
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	74 26                	je     8007d5 <vsnprintf+0x47>
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	7e 22                	jle    8007d5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b3:	ff 75 14             	pushl  0x14(%ebp)
  8007b6:	ff 75 10             	pushl  0x10(%ebp)
  8007b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bc:	50                   	push   %eax
  8007bd:	68 c6 02 80 00       	push   $0x8002c6
  8007c2:	e8 39 fb ff ff       	call   800300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	eb 05                	jmp    8007da <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 10             	pushl  0x10(%ebp)
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	ff 75 08             	pushl  0x8(%ebp)
  8007ef:	e8 9a ff ff ff       	call   80078e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	eb 03                	jmp    800806 <strlen+0x10>
		n++;
  800803:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080a:	75 f7                	jne    800803 <strlen+0xd>
		n++;
	return n;
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800814:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	ba 00 00 00 00       	mov    $0x0,%edx
  80081c:	eb 03                	jmp    800821 <strnlen+0x13>
		n++;
  80081e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800821:	39 c2                	cmp    %eax,%edx
  800823:	74 08                	je     80082d <strnlen+0x1f>
  800825:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800829:	75 f3                	jne    80081e <strnlen+0x10>
  80082b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	89 c2                	mov    %eax,%edx
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	83 c1 01             	add    $0x1,%ecx
  800841:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800845:	88 5a ff             	mov    %bl,-0x1(%edx)
  800848:	84 db                	test   %bl,%bl
  80084a:	75 ef                	jne    80083b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800856:	53                   	push   %ebx
  800857:	e8 9a ff ff ff       	call   8007f6 <strlen>
  80085c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	01 d8                	add    %ebx,%eax
  800864:	50                   	push   %eax
  800865:	e8 c5 ff ff ff       	call   80082f <strcpy>
	return dst;
}
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
  800876:	8b 75 08             	mov    0x8(%ebp),%esi
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087c:	89 f3                	mov    %esi,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800881:	89 f2                	mov    %esi,%edx
  800883:	eb 0f                	jmp    800894 <strncpy+0x23>
		*dst++ = *src;
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	0f b6 01             	movzbl (%ecx),%eax
  80088b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088e:	80 39 01             	cmpb   $0x1,(%ecx)
  800891:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	39 da                	cmp    %ebx,%edx
  800896:	75 ed                	jne    800885 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800898:	89 f0                	mov    %esi,%eax
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ac:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 21                	je     8008d3 <strlcpy+0x35>
  8008b2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b6:	89 f2                	mov    %esi,%edx
  8008b8:	eb 09                	jmp    8008c3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ba:	83 c2 01             	add    $0x1,%edx
  8008bd:	83 c1 01             	add    $0x1,%ecx
  8008c0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c3:	39 c2                	cmp    %eax,%edx
  8008c5:	74 09                	je     8008d0 <strlcpy+0x32>
  8008c7:	0f b6 19             	movzbl (%ecx),%ebx
  8008ca:	84 db                	test   %bl,%bl
  8008cc:	75 ec                	jne    8008ba <strlcpy+0x1c>
  8008ce:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d3:	29 f0                	sub    %esi,%eax
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e2:	eb 06                	jmp    8008ea <strcmp+0x11>
		p++, q++;
  8008e4:	83 c1 01             	add    $0x1,%ecx
  8008e7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ea:	0f b6 01             	movzbl (%ecx),%eax
  8008ed:	84 c0                	test   %al,%al
  8008ef:	74 04                	je     8008f5 <strcmp+0x1c>
  8008f1:	3a 02                	cmp    (%edx),%al
  8008f3:	74 ef                	je     8008e4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 c0             	movzbl %al,%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	53                   	push   %ebx
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80090e:	eb 06                	jmp    800916 <strncmp+0x17>
		n--, p++, q++;
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800916:	39 d8                	cmp    %ebx,%eax
  800918:	74 15                	je     80092f <strncmp+0x30>
  80091a:	0f b6 08             	movzbl (%eax),%ecx
  80091d:	84 c9                	test   %cl,%cl
  80091f:	74 04                	je     800925 <strncmp+0x26>
  800921:	3a 0a                	cmp    (%edx),%cl
  800923:	74 eb                	je     800910 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800925:	0f b6 00             	movzbl (%eax),%eax
  800928:	0f b6 12             	movzbl (%edx),%edx
  80092b:	29 d0                	sub    %edx,%eax
  80092d:	eb 05                	jmp    800934 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800941:	eb 07                	jmp    80094a <strchr+0x13>
		if (*s == c)
  800943:	38 ca                	cmp    %cl,%dl
  800945:	74 0f                	je     800956 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	0f b6 10             	movzbl (%eax),%edx
  80094d:	84 d2                	test   %dl,%dl
  80094f:	75 f2                	jne    800943 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800962:	eb 03                	jmp    800967 <strfind+0xf>
  800964:	83 c0 01             	add    $0x1,%eax
  800967:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096a:	38 ca                	cmp    %cl,%dl
  80096c:	74 04                	je     800972 <strfind+0x1a>
  80096e:	84 d2                	test   %dl,%dl
  800970:	75 f2                	jne    800964 <strfind+0xc>
			break;
	return (char *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800980:	85 c9                	test   %ecx,%ecx
  800982:	74 36                	je     8009ba <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800984:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098a:	75 28                	jne    8009b4 <memset+0x40>
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 23                	jne    8009b4 <memset+0x40>
		c &= 0xFF;
  800991:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800995:	89 d3                	mov    %edx,%ebx
  800997:	c1 e3 08             	shl    $0x8,%ebx
  80099a:	89 d6                	mov    %edx,%esi
  80099c:	c1 e6 18             	shl    $0x18,%esi
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	c1 e0 10             	shl    $0x10,%eax
  8009a4:	09 f0                	or     %esi,%eax
  8009a6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a8:	89 d8                	mov    %ebx,%eax
  8009aa:	09 d0                	or     %edx,%eax
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
  8009af:	fc                   	cld    
  8009b0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b2:	eb 06                	jmp    8009ba <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	fc                   	cld    
  8009b8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ba:	89 f8                	mov    %edi,%eax
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5f                   	pop    %edi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cf:	39 c6                	cmp    %eax,%esi
  8009d1:	73 35                	jae    800a08 <memmove+0x47>
  8009d3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	73 2e                	jae    800a08 <memmove+0x47>
		s += n;
		d += n;
  8009da:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dd:	89 d6                	mov    %edx,%esi
  8009df:	09 fe                	or     %edi,%esi
  8009e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e7:	75 13                	jne    8009fc <memmove+0x3b>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0e                	jne    8009fc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ee:	83 ef 04             	sub    $0x4,%edi
  8009f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
  8009f7:	fd                   	std    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb 09                	jmp    800a05 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009fc:	83 ef 01             	sub    $0x1,%edi
  8009ff:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a02:	fd                   	std    
  800a03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a05:	fc                   	cld    
  800a06:	eb 1d                	jmp    800a25 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	89 f2                	mov    %esi,%edx
  800a0a:	09 c2                	or     %eax,%edx
  800a0c:	f6 c2 03             	test   $0x3,%dl
  800a0f:	75 0f                	jne    800a20 <memmove+0x5f>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 0a                	jne    800a20 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a16:	c1 e9 02             	shr    $0x2,%ecx
  800a19:	89 c7                	mov    %eax,%edi
  800a1b:	fc                   	cld    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 05                	jmp    800a25 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a2c:	ff 75 10             	pushl  0x10(%ebp)
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	ff 75 08             	pushl  0x8(%ebp)
  800a35:	e8 87 ff ff ff       	call   8009c1 <memmove>
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a47:	89 c6                	mov    %eax,%esi
  800a49:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4c:	eb 1a                	jmp    800a68 <memcmp+0x2c>
		if (*s1 != *s2)
  800a4e:	0f b6 08             	movzbl (%eax),%ecx
  800a51:	0f b6 1a             	movzbl (%edx),%ebx
  800a54:	38 d9                	cmp    %bl,%cl
  800a56:	74 0a                	je     800a62 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a58:	0f b6 c1             	movzbl %cl,%eax
  800a5b:	0f b6 db             	movzbl %bl,%ebx
  800a5e:	29 d8                	sub    %ebx,%eax
  800a60:	eb 0f                	jmp    800a71 <memcmp+0x35>
		s1++, s2++;
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a68:	39 f0                	cmp    %esi,%eax
  800a6a:	75 e2                	jne    800a4e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a7c:	89 c1                	mov    %eax,%ecx
  800a7e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a81:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a85:	eb 0a                	jmp    800a91 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a87:	0f b6 10             	movzbl (%eax),%edx
  800a8a:	39 da                	cmp    %ebx,%edx
  800a8c:	74 07                	je     800a95 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	39 c8                	cmp    %ecx,%eax
  800a93:	72 f2                	jb     800a87 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a95:	5b                   	pop    %ebx
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa4:	eb 03                	jmp    800aa9 <strtol+0x11>
		s++;
  800aa6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa9:	0f b6 01             	movzbl (%ecx),%eax
  800aac:	3c 20                	cmp    $0x20,%al
  800aae:	74 f6                	je     800aa6 <strtol+0xe>
  800ab0:	3c 09                	cmp    $0x9,%al
  800ab2:	74 f2                	je     800aa6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab4:	3c 2b                	cmp    $0x2b,%al
  800ab6:	75 0a                	jne    800ac2 <strtol+0x2a>
		s++;
  800ab8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac0:	eb 11                	jmp    800ad3 <strtol+0x3b>
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac7:	3c 2d                	cmp    $0x2d,%al
  800ac9:	75 08                	jne    800ad3 <strtol+0x3b>
		s++, neg = 1;
  800acb:	83 c1 01             	add    $0x1,%ecx
  800ace:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad9:	75 15                	jne    800af0 <strtol+0x58>
  800adb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ade:	75 10                	jne    800af0 <strtol+0x58>
  800ae0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae4:	75 7c                	jne    800b62 <strtol+0xca>
		s += 2, base = 16;
  800ae6:	83 c1 02             	add    $0x2,%ecx
  800ae9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aee:	eb 16                	jmp    800b06 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af0:	85 db                	test   %ebx,%ebx
  800af2:	75 12                	jne    800b06 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af9:	80 39 30             	cmpb   $0x30,(%ecx)
  800afc:	75 08                	jne    800b06 <strtol+0x6e>
		s++, base = 8;
  800afe:	83 c1 01             	add    $0x1,%ecx
  800b01:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0e:	0f b6 11             	movzbl (%ecx),%edx
  800b11:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 09             	cmp    $0x9,%bl
  800b19:	77 08                	ja     800b23 <strtol+0x8b>
			dig = *s - '0';
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 30             	sub    $0x30,%edx
  800b21:	eb 22                	jmp    800b45 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b23:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b26:	89 f3                	mov    %esi,%ebx
  800b28:	80 fb 19             	cmp    $0x19,%bl
  800b2b:	77 08                	ja     800b35 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b2d:	0f be d2             	movsbl %dl,%edx
  800b30:	83 ea 57             	sub    $0x57,%edx
  800b33:	eb 10                	jmp    800b45 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b35:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b38:	89 f3                	mov    %esi,%ebx
  800b3a:	80 fb 19             	cmp    $0x19,%bl
  800b3d:	77 16                	ja     800b55 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3f:	0f be d2             	movsbl %dl,%edx
  800b42:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b45:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b48:	7d 0b                	jge    800b55 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b4a:	83 c1 01             	add    $0x1,%ecx
  800b4d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b51:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b53:	eb b9                	jmp    800b0e <strtol+0x76>

	if (endptr)
  800b55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b59:	74 0d                	je     800b68 <strtol+0xd0>
		*endptr = (char *) s;
  800b5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5e:	89 0e                	mov    %ecx,(%esi)
  800b60:	eb 06                	jmp    800b68 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b62:	85 db                	test   %ebx,%ebx
  800b64:	74 98                	je     800afe <strtol+0x66>
  800b66:	eb 9e                	jmp    800b06 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b68:	89 c2                	mov    %eax,%edx
  800b6a:	f7 da                	neg    %edx
  800b6c:	85 ff                	test   %edi,%edi
  800b6e:	0f 45 c2             	cmovne %edx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 c3                	mov    %eax,%ebx
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	89 c6                	mov    %eax,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 cb                	mov    %ecx,%ebx
  800bcb:	89 cf                	mov    %ecx,%edi
  800bcd:	89 ce                	mov    %ecx,%esi
  800bcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7e 17                	jle    800bec <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	50                   	push   %eax
  800bd9:	6a 03                	push   $0x3
  800bdb:	68 bf 22 80 00       	push   $0x8022bf
  800be0:	6a 23                	push   $0x23
  800be2:	68 dc 22 80 00       	push   $0x8022dc
  800be7:	e8 3e f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 02 00 00 00       	mov    $0x2,%eax
  800c04:	89 d1                	mov    %edx,%ecx
  800c06:	89 d3                	mov    %edx,%ebx
  800c08:	89 d7                	mov    %edx,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_yield>:

void
sys_yield(void)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c23:	89 d1                	mov    %edx,%ecx
  800c25:	89 d3                	mov    %edx,%ebx
  800c27:	89 d7                	mov    %edx,%edi
  800c29:	89 d6                	mov    %edx,%esi
  800c2b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	be 00 00 00 00       	mov    $0x0,%esi
  800c40:	b8 04 00 00 00       	mov    $0x4,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	89 f7                	mov    %esi,%edi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 04                	push   $0x4
  800c5c:	68 bf 22 80 00       	push   $0x8022bf
  800c61:	6a 23                	push   $0x23
  800c63:	68 dc 22 80 00       	push   $0x8022dc
  800c68:	e8 bd f4 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 05                	push   $0x5
  800c9e:	68 bf 22 80 00       	push   $0x8022bf
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 dc 22 80 00       	push   $0x8022dc
  800caa:	e8 7b f4 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 06                	push   $0x6
  800ce0:	68 bf 22 80 00       	push   $0x8022bf
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 dc 22 80 00       	push   $0x8022dc
  800cec:	e8 39 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 08                	push   $0x8
  800d22:	68 bf 22 80 00       	push   $0x8022bf
  800d27:	6a 23                	push   $0x23
  800d29:	68 dc 22 80 00       	push   $0x8022dc
  800d2e:	e8 f7 f3 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 09                	push   $0x9
  800d64:	68 bf 22 80 00       	push   $0x8022bf
  800d69:	6a 23                	push   $0x23
  800d6b:	68 dc 22 80 00       	push   $0x8022dc
  800d70:	e8 b5 f3 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 0a                	push   $0xa
  800da6:	68 bf 22 80 00       	push   $0x8022bf
  800dab:	6a 23                	push   $0x23
  800dad:	68 dc 22 80 00       	push   $0x8022dc
  800db2:	e8 73 f3 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	be 00 00 00 00       	mov    $0x0,%esi
  800dca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	89 cb                	mov    %ecx,%ebx
  800dfa:	89 cf                	mov    %ecx,%edi
  800dfc:	89 ce                	mov    %ecx,%esi
  800dfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e00:	85 c0                	test   %eax,%eax
  800e02:	7e 17                	jle    800e1b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	50                   	push   %eax
  800e08:	6a 0d                	push   $0xd
  800e0a:	68 bf 22 80 00       	push   $0x8022bf
  800e0f:	6a 23                	push   $0x23
  800e11:	68 dc 22 80 00       	push   $0x8022dc
  800e16:	e8 0f f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e29:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e30:	75 31                	jne    800e63 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  800e32:	a1 04 40 80 00       	mov    0x804004,%eax
  800e37:	8b 40 48             	mov    0x48(%eax),%eax
  800e3a:	83 ec 04             	sub    $0x4,%esp
  800e3d:	6a 07                	push   $0x7
  800e3f:	68 00 f0 bf ee       	push   $0xeebff000
  800e44:	50                   	push   %eax
  800e45:	e8 e8 fd ff ff       	call   800c32 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  800e4a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e4f:	8b 40 48             	mov    0x48(%eax),%eax
  800e52:	83 c4 08             	add    $0x8,%esp
  800e55:	68 6d 0e 80 00       	push   $0x800e6d
  800e5a:	50                   	push   %eax
  800e5b:	e8 1d ff ff ff       	call   800d7d <sys_env_set_pgfault_upcall>
  800e60:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e6d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e6e:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e73:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e75:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  800e78:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  800e7b:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  800e7f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  800e83:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  800e86:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  800e88:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e8c:	61                   	popa   
	addl $4, %esp        // skip eip
  800e8d:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  800e90:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800e91:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e92:	c3                   	ret    

00800e93 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9e:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	05 00 00 00 30       	add    $0x30000000,%eax
  800eae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 16             	shr    $0x16,%edx
  800eca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	74 11                	je     800ee7 <fd_alloc+0x2d>
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	c1 ea 0c             	shr    $0xc,%edx
  800edb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	75 09                	jne    800ef0 <fd_alloc+0x36>
			*fd_store = fd;
  800ee7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	eb 17                	jmp    800f07 <fd_alloc+0x4d>
  800ef0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800efa:	75 c9                	jne    800ec5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800efc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f02:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f0f:	83 f8 1f             	cmp    $0x1f,%eax
  800f12:	77 36                	ja     800f4a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f14:	c1 e0 0c             	shl    $0xc,%eax
  800f17:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1c:	89 c2                	mov    %eax,%edx
  800f1e:	c1 ea 16             	shr    $0x16,%edx
  800f21:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f28:	f6 c2 01             	test   $0x1,%dl
  800f2b:	74 24                	je     800f51 <fd_lookup+0x48>
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 0c             	shr    $0xc,%edx
  800f32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 1a                	je     800f58 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f41:	89 02                	mov    %eax,(%edx)
	return 0;
  800f43:	b8 00 00 00 00       	mov    $0x0,%eax
  800f48:	eb 13                	jmp    800f5d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4f:	eb 0c                	jmp    800f5d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f56:	eb 05                	jmp    800f5d <fd_lookup+0x54>
  800f58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f68:	ba 6c 23 80 00       	mov    $0x80236c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f6d:	eb 13                	jmp    800f82 <dev_lookup+0x23>
  800f6f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f72:	39 08                	cmp    %ecx,(%eax)
  800f74:	75 0c                	jne    800f82 <dev_lookup+0x23>
			*dev = devtab[i];
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f80:	eb 2e                	jmp    800fb0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f82:	8b 02                	mov    (%edx),%eax
  800f84:	85 c0                	test   %eax,%eax
  800f86:	75 e7                	jne    800f6f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f88:	a1 04 40 80 00       	mov    0x804004,%eax
  800f8d:	8b 40 48             	mov    0x48(%eax),%eax
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	51                   	push   %ecx
  800f94:	50                   	push   %eax
  800f95:	68 ec 22 80 00       	push   $0x8022ec
  800f9a:	e8 64 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 10             	sub    $0x10,%esp
  800fba:	8b 75 08             	mov    0x8(%ebp),%esi
  800fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fca:	c1 e8 0c             	shr    $0xc,%eax
  800fcd:	50                   	push   %eax
  800fce:	e8 36 ff ff ff       	call   800f09 <fd_lookup>
  800fd3:	83 c4 08             	add    $0x8,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 05                	js     800fdf <fd_close+0x2d>
	    || fd != fd2)
  800fda:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fdd:	74 0c                	je     800feb <fd_close+0x39>
		return (must_exist ? r : 0);
  800fdf:	84 db                	test   %bl,%bl
  800fe1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe6:	0f 44 c2             	cmove  %edx,%eax
  800fe9:	eb 41                	jmp    80102c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	ff 36                	pushl  (%esi)
  800ff4:	e8 66 ff ff ff       	call   800f5f <dev_lookup>
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	83 c4 10             	add    $0x10,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	78 1a                	js     80101c <fd_close+0x6a>
		if (dev->dev_close)
  801002:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801005:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801008:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	74 0b                	je     80101c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	56                   	push   %esi
  801015:	ff d0                	call   *%eax
  801017:	89 c3                	mov    %eax,%ebx
  801019:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	56                   	push   %esi
  801020:	6a 00                	push   $0x0
  801022:	e8 90 fc ff ff       	call   800cb7 <sys_page_unmap>
	return r;
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	89 d8                	mov    %ebx,%eax
}
  80102c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	ff 75 08             	pushl  0x8(%ebp)
  801040:	e8 c4 fe ff ff       	call   800f09 <fd_lookup>
  801045:	83 c4 08             	add    $0x8,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 10                	js     80105c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	6a 01                	push   $0x1
  801051:	ff 75 f4             	pushl  -0xc(%ebp)
  801054:	e8 59 ff ff ff       	call   800fb2 <fd_close>
  801059:	83 c4 10             	add    $0x10,%esp
}
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    

0080105e <close_all>:

void
close_all(void)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	53                   	push   %ebx
  801062:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801065:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	53                   	push   %ebx
  80106e:	e8 c0 ff ff ff       	call   801033 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801073:	83 c3 01             	add    $0x1,%ebx
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	83 fb 20             	cmp    $0x20,%ebx
  80107c:	75 ec                	jne    80106a <close_all+0xc>
		close(i);
}
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 2c             	sub    $0x2c,%esp
  80108c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80108f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	e8 6e fe ff ff       	call   800f09 <fd_lookup>
  80109b:	83 c4 08             	add    $0x8,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	0f 88 c1 00 00 00    	js     801167 <dup+0xe4>
		return r;
	close(newfdnum);
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	56                   	push   %esi
  8010aa:	e8 84 ff ff ff       	call   801033 <close>

	newfd = INDEX2FD(newfdnum);
  8010af:	89 f3                	mov    %esi,%ebx
  8010b1:	c1 e3 0c             	shl    $0xc,%ebx
  8010b4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010ba:	83 c4 04             	add    $0x4,%esp
  8010bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c0:	e8 de fd ff ff       	call   800ea3 <fd2data>
  8010c5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010c7:	89 1c 24             	mov    %ebx,(%esp)
  8010ca:	e8 d4 fd ff ff       	call   800ea3 <fd2data>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d5:	89 f8                	mov    %edi,%eax
  8010d7:	c1 e8 16             	shr    $0x16,%eax
  8010da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e1:	a8 01                	test   $0x1,%al
  8010e3:	74 37                	je     80111c <dup+0x99>
  8010e5:	89 f8                	mov    %edi,%eax
  8010e7:	c1 e8 0c             	shr    $0xc,%eax
  8010ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f1:	f6 c2 01             	test   $0x1,%dl
  8010f4:	74 26                	je     80111c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	25 07 0e 00 00       	and    $0xe07,%eax
  801105:	50                   	push   %eax
  801106:	ff 75 d4             	pushl  -0x2c(%ebp)
  801109:	6a 00                	push   $0x0
  80110b:	57                   	push   %edi
  80110c:	6a 00                	push   $0x0
  80110e:	e8 62 fb ff ff       	call   800c75 <sys_page_map>
  801113:	89 c7                	mov    %eax,%edi
  801115:	83 c4 20             	add    $0x20,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 2e                	js     80114a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80111c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80111f:	89 d0                	mov    %edx,%eax
  801121:	c1 e8 0c             	shr    $0xc,%eax
  801124:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	25 07 0e 00 00       	and    $0xe07,%eax
  801133:	50                   	push   %eax
  801134:	53                   	push   %ebx
  801135:	6a 00                	push   $0x0
  801137:	52                   	push   %edx
  801138:	6a 00                	push   $0x0
  80113a:	e8 36 fb ff ff       	call   800c75 <sys_page_map>
  80113f:	89 c7                	mov    %eax,%edi
  801141:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801144:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801146:	85 ff                	test   %edi,%edi
  801148:	79 1d                	jns    801167 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	53                   	push   %ebx
  80114e:	6a 00                	push   $0x0
  801150:	e8 62 fb ff ff       	call   800cb7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801155:	83 c4 08             	add    $0x8,%esp
  801158:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115b:	6a 00                	push   $0x0
  80115d:	e8 55 fb ff ff       	call   800cb7 <sys_page_unmap>
	return r;
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	89 f8                	mov    %edi,%eax
}
  801167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5f                   	pop    %edi
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	53                   	push   %ebx
  801173:	83 ec 14             	sub    $0x14,%esp
  801176:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801179:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117c:	50                   	push   %eax
  80117d:	53                   	push   %ebx
  80117e:	e8 86 fd ff ff       	call   800f09 <fd_lookup>
  801183:	83 c4 08             	add    $0x8,%esp
  801186:	89 c2                	mov    %eax,%edx
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 6d                	js     8011f9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	50                   	push   %eax
  801193:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801196:	ff 30                	pushl  (%eax)
  801198:	e8 c2 fd ff ff       	call   800f5f <dev_lookup>
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 4c                	js     8011f0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a7:	8b 42 08             	mov    0x8(%edx),%eax
  8011aa:	83 e0 03             	and    $0x3,%eax
  8011ad:	83 f8 01             	cmp    $0x1,%eax
  8011b0:	75 21                	jne    8011d3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	53                   	push   %ebx
  8011be:	50                   	push   %eax
  8011bf:	68 30 23 80 00       	push   $0x802330
  8011c4:	e8 3a f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d1:	eb 26                	jmp    8011f9 <read+0x8a>
	}
	if (!dev->dev_read)
  8011d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d6:	8b 40 08             	mov    0x8(%eax),%eax
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	74 17                	je     8011f4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011dd:	83 ec 04             	sub    $0x4,%esp
  8011e0:	ff 75 10             	pushl  0x10(%ebp)
  8011e3:	ff 75 0c             	pushl  0xc(%ebp)
  8011e6:	52                   	push   %edx
  8011e7:	ff d0                	call   *%eax
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	eb 09                	jmp    8011f9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	eb 05                	jmp    8011f9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011f9:	89 d0                	mov    %edx,%eax
  8011fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fe:	c9                   	leave  
  8011ff:	c3                   	ret    

00801200 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	53                   	push   %ebx
  801206:	83 ec 0c             	sub    $0xc,%esp
  801209:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801214:	eb 21                	jmp    801237 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	89 f0                	mov    %esi,%eax
  80121b:	29 d8                	sub    %ebx,%eax
  80121d:	50                   	push   %eax
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	03 45 0c             	add    0xc(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	57                   	push   %edi
  801225:	e8 45 ff ff ff       	call   80116f <read>
		if (m < 0)
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 10                	js     801241 <readn+0x41>
			return m;
		if (m == 0)
  801231:	85 c0                	test   %eax,%eax
  801233:	74 0a                	je     80123f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801235:	01 c3                	add    %eax,%ebx
  801237:	39 f3                	cmp    %esi,%ebx
  801239:	72 db                	jb     801216 <readn+0x16>
  80123b:	89 d8                	mov    %ebx,%eax
  80123d:	eb 02                	jmp    801241 <readn+0x41>
  80123f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	53                   	push   %ebx
  80124d:	83 ec 14             	sub    $0x14,%esp
  801250:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	53                   	push   %ebx
  801258:	e8 ac fc ff ff       	call   800f09 <fd_lookup>
  80125d:	83 c4 08             	add    $0x8,%esp
  801260:	89 c2                	mov    %eax,%edx
  801262:	85 c0                	test   %eax,%eax
  801264:	78 68                	js     8012ce <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	ff 30                	pushl  (%eax)
  801272:	e8 e8 fc ff ff       	call   800f5f <dev_lookup>
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 47                	js     8012c5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801285:	75 21                	jne    8012a8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801287:	a1 04 40 80 00       	mov    0x804004,%eax
  80128c:	8b 40 48             	mov    0x48(%eax),%eax
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	53                   	push   %ebx
  801293:	50                   	push   %eax
  801294:	68 4c 23 80 00       	push   $0x80234c
  801299:	e8 65 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a6:	eb 26                	jmp    8012ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8012ae:	85 d2                	test   %edx,%edx
  8012b0:	74 17                	je     8012c9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	ff 75 10             	pushl  0x10(%ebp)
  8012b8:	ff 75 0c             	pushl  0xc(%ebp)
  8012bb:	50                   	push   %eax
  8012bc:	ff d2                	call   *%edx
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	eb 09                	jmp    8012ce <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c5:	89 c2                	mov    %eax,%edx
  8012c7:	eb 05                	jmp    8012ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012ce:	89 d0                	mov    %edx,%eax
  8012d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 22 fc ff ff       	call   800f09 <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 0e                	js     8012fc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 14             	sub    $0x14,%esp
  801305:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	53                   	push   %ebx
  80130d:	e8 f7 fb ff ff       	call   800f09 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	89 c2                	mov    %eax,%edx
  801317:	85 c0                	test   %eax,%eax
  801319:	78 65                	js     801380 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	ff 30                	pushl  (%eax)
  801327:	e8 33 fc ff ff       	call   800f5f <dev_lookup>
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 44                	js     801377 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801336:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133a:	75 21                	jne    80135d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80133c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801341:	8b 40 48             	mov    0x48(%eax),%eax
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	53                   	push   %ebx
  801348:	50                   	push   %eax
  801349:	68 0c 23 80 00       	push   $0x80230c
  80134e:	e8 b0 ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80135b:	eb 23                	jmp    801380 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80135d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801360:	8b 52 18             	mov    0x18(%edx),%edx
  801363:	85 d2                	test   %edx,%edx
  801365:	74 14                	je     80137b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	ff 75 0c             	pushl  0xc(%ebp)
  80136d:	50                   	push   %eax
  80136e:	ff d2                	call   *%edx
  801370:	89 c2                	mov    %eax,%edx
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	eb 09                	jmp    801380 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801377:	89 c2                	mov    %eax,%edx
  801379:	eb 05                	jmp    801380 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80137b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801380:	89 d0                	mov    %edx,%eax
  801382:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	53                   	push   %ebx
  80138b:	83 ec 14             	sub    $0x14,%esp
  80138e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801391:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	ff 75 08             	pushl  0x8(%ebp)
  801398:	e8 6c fb ff ff       	call   800f09 <fd_lookup>
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	89 c2                	mov    %eax,%edx
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 58                	js     8013fe <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b0:	ff 30                	pushl  (%eax)
  8013b2:	e8 a8 fb ff ff       	call   800f5f <dev_lookup>
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 37                	js     8013f5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c5:	74 32                	je     8013f9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d1:	00 00 00 
	stat->st_isdir = 0;
  8013d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013db:	00 00 00 
	stat->st_dev = dev;
  8013de:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013eb:	ff 50 14             	call   *0x14(%eax)
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	eb 09                	jmp    8013fe <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	eb 05                	jmp    8013fe <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013fe:	89 d0                	mov    %edx,%eax
  801400:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	6a 00                	push   $0x0
  80140f:	ff 75 08             	pushl  0x8(%ebp)
  801412:	e8 b7 01 00 00       	call   8015ce <open>
  801417:	89 c3                	mov    %eax,%ebx
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 1b                	js     80143b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	ff 75 0c             	pushl  0xc(%ebp)
  801426:	50                   	push   %eax
  801427:	e8 5b ff ff ff       	call   801387 <fstat>
  80142c:	89 c6                	mov    %eax,%esi
	close(fd);
  80142e:	89 1c 24             	mov    %ebx,(%esp)
  801431:	e8 fd fb ff ff       	call   801033 <close>
	return r;
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	89 f0                	mov    %esi,%eax
}
  80143b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143e:	5b                   	pop    %ebx
  80143f:	5e                   	pop    %esi
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	56                   	push   %esi
  801446:	53                   	push   %ebx
  801447:	89 c6                	mov    %eax,%esi
  801449:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80144b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801452:	75 12                	jne    801466 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	6a 01                	push   $0x1
  801459:	e8 bc 07 00 00       	call   801c1a <ipc_find_env>
  80145e:	a3 00 40 80 00       	mov    %eax,0x804000
  801463:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801466:	6a 07                	push   $0x7
  801468:	68 00 50 80 00       	push   $0x805000
  80146d:	56                   	push   %esi
  80146e:	ff 35 00 40 80 00    	pushl  0x804000
  801474:	e8 4d 07 00 00       	call   801bc6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801479:	83 c4 0c             	add    $0xc,%esp
  80147c:	6a 00                	push   $0x0
  80147e:	53                   	push   %ebx
  80147f:	6a 00                	push   $0x0
  801481:	e8 cb 06 00 00       	call   801b51 <ipc_recv>
}
  801486:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	8b 40 0c             	mov    0xc(%eax),%eax
  801499:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80149e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8014b0:	e8 8d ff ff ff       	call   801442 <fsipc>
}
  8014b5:	c9                   	leave  
  8014b6:	c3                   	ret    

008014b7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8014d2:	e8 6b ff ff ff       	call   801442 <fsipc>
}
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f8:	e8 45 ff ff ff       	call   801442 <fsipc>
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 2c                	js     80152d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	68 00 50 80 00       	push   $0x805000
  801509:	53                   	push   %ebx
  80150a:	e8 20 f3 ff ff       	call   80082f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80150f:	a1 80 50 80 00       	mov    0x805080,%eax
  801514:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80151a:	a1 84 50 80 00       	mov    0x805084,%eax
  80151f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801538:	68 7c 23 80 00       	push   $0x80237c
  80153d:	68 90 00 00 00       	push   $0x90
  801542:	68 9a 23 80 00       	push   $0x80239a
  801547:	e8 de eb ff ff       	call   80012a <_panic>

0080154c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	56                   	push   %esi
  801550:	53                   	push   %ebx
  801551:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	8b 40 0c             	mov    0xc(%eax),%eax
  80155a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801565:	ba 00 00 00 00       	mov    $0x0,%edx
  80156a:	b8 03 00 00 00       	mov    $0x3,%eax
  80156f:	e8 ce fe ff ff       	call   801442 <fsipc>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	85 c0                	test   %eax,%eax
  801578:	78 4b                	js     8015c5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80157a:	39 c6                	cmp    %eax,%esi
  80157c:	73 16                	jae    801594 <devfile_read+0x48>
  80157e:	68 a5 23 80 00       	push   $0x8023a5
  801583:	68 ac 23 80 00       	push   $0x8023ac
  801588:	6a 7c                	push   $0x7c
  80158a:	68 9a 23 80 00       	push   $0x80239a
  80158f:	e8 96 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  801594:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801599:	7e 16                	jle    8015b1 <devfile_read+0x65>
  80159b:	68 c1 23 80 00       	push   $0x8023c1
  8015a0:	68 ac 23 80 00       	push   $0x8023ac
  8015a5:	6a 7d                	push   $0x7d
  8015a7:	68 9a 23 80 00       	push   $0x80239a
  8015ac:	e8 79 eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	50                   	push   %eax
  8015b5:	68 00 50 80 00       	push   $0x805000
  8015ba:	ff 75 0c             	pushl  0xc(%ebp)
  8015bd:	e8 ff f3 ff ff       	call   8009c1 <memmove>
	return r;
  8015c2:	83 c4 10             	add    $0x10,%esp
}
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 20             	sub    $0x20,%esp
  8015d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d8:	53                   	push   %ebx
  8015d9:	e8 18 f2 ff ff       	call   8007f6 <strlen>
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e6:	7f 67                	jg     80164f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	e8 c6 f8 ff ff       	call   800eba <fd_alloc>
  8015f4:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 57                	js     801654 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	53                   	push   %ebx
  801601:	68 00 50 80 00       	push   $0x805000
  801606:	e8 24 f2 ff ff       	call   80082f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801613:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801616:	b8 01 00 00 00       	mov    $0x1,%eax
  80161b:	e8 22 fe ff ff       	call   801442 <fsipc>
  801620:	89 c3                	mov    %eax,%ebx
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	79 14                	jns    80163d <open+0x6f>
		fd_close(fd, 0);
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	6a 00                	push   $0x0
  80162e:	ff 75 f4             	pushl  -0xc(%ebp)
  801631:	e8 7c f9 ff ff       	call   800fb2 <fd_close>
		return r;
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	89 da                	mov    %ebx,%edx
  80163b:	eb 17                	jmp    801654 <open+0x86>
	}

	return fd2num(fd);
  80163d:	83 ec 0c             	sub    $0xc,%esp
  801640:	ff 75 f4             	pushl  -0xc(%ebp)
  801643:	e8 4b f8 ff ff       	call   800e93 <fd2num>
  801648:	89 c2                	mov    %eax,%edx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	eb 05                	jmp    801654 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801654:	89 d0                	mov    %edx,%eax
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801661:	ba 00 00 00 00       	mov    $0x0,%edx
  801666:	b8 08 00 00 00       	mov    $0x8,%eax
  80166b:	e8 d2 fd ff ff       	call   801442 <fsipc>
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	56                   	push   %esi
  801676:	53                   	push   %ebx
  801677:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	ff 75 08             	pushl  0x8(%ebp)
  801680:	e8 1e f8 ff ff       	call   800ea3 <fd2data>
  801685:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	68 cd 23 80 00       	push   $0x8023cd
  80168f:	53                   	push   %ebx
  801690:	e8 9a f1 ff ff       	call   80082f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801695:	8b 46 04             	mov    0x4(%esi),%eax
  801698:	2b 06                	sub    (%esi),%eax
  80169a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016a0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a7:	00 00 00 
	stat->st_dev = &devpipe;
  8016aa:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016b1:	30 80 00 
	return 0;
}
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 0c             	sub    $0xc,%esp
  8016c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ca:	53                   	push   %ebx
  8016cb:	6a 00                	push   $0x0
  8016cd:	e8 e5 f5 ff ff       	call   800cb7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d2:	89 1c 24             	mov    %ebx,(%esp)
  8016d5:	e8 c9 f7 ff ff       	call   800ea3 <fd2data>
  8016da:	83 c4 08             	add    $0x8,%esp
  8016dd:	50                   	push   %eax
  8016de:	6a 00                	push   $0x0
  8016e0:	e8 d2 f5 ff ff       	call   800cb7 <sys_page_unmap>
}
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	57                   	push   %edi
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 1c             	sub    $0x1c,%esp
  8016f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016f6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8016fd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801700:	83 ec 0c             	sub    $0xc,%esp
  801703:	ff 75 e0             	pushl  -0x20(%ebp)
  801706:	e8 48 05 00 00       	call   801c53 <pageref>
  80170b:	89 c3                	mov    %eax,%ebx
  80170d:	89 3c 24             	mov    %edi,(%esp)
  801710:	e8 3e 05 00 00       	call   801c53 <pageref>
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	39 c3                	cmp    %eax,%ebx
  80171a:	0f 94 c1             	sete   %cl
  80171d:	0f b6 c9             	movzbl %cl,%ecx
  801720:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801723:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801729:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80172c:	39 ce                	cmp    %ecx,%esi
  80172e:	74 1b                	je     80174b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801730:	39 c3                	cmp    %eax,%ebx
  801732:	75 c4                	jne    8016f8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801734:	8b 42 58             	mov    0x58(%edx),%eax
  801737:	ff 75 e4             	pushl  -0x1c(%ebp)
  80173a:	50                   	push   %eax
  80173b:	56                   	push   %esi
  80173c:	68 d4 23 80 00       	push   $0x8023d4
  801741:	e8 bd ea ff ff       	call   800203 <cprintf>
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	eb ad                	jmp    8016f8 <_pipeisclosed+0xe>
	}
}
  80174b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80174e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5f                   	pop    %edi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	57                   	push   %edi
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
  80175c:	83 ec 28             	sub    $0x28,%esp
  80175f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801762:	56                   	push   %esi
  801763:	e8 3b f7 ff ff       	call   800ea3 <fd2data>
  801768:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	bf 00 00 00 00       	mov    $0x0,%edi
  801772:	eb 4b                	jmp    8017bf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801774:	89 da                	mov    %ebx,%edx
  801776:	89 f0                	mov    %esi,%eax
  801778:	e8 6d ff ff ff       	call   8016ea <_pipeisclosed>
  80177d:	85 c0                	test   %eax,%eax
  80177f:	75 48                	jne    8017c9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801781:	e8 8d f4 ff ff       	call   800c13 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801786:	8b 43 04             	mov    0x4(%ebx),%eax
  801789:	8b 0b                	mov    (%ebx),%ecx
  80178b:	8d 51 20             	lea    0x20(%ecx),%edx
  80178e:	39 d0                	cmp    %edx,%eax
  801790:	73 e2                	jae    801774 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801795:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801799:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	c1 fa 1f             	sar    $0x1f,%edx
  8017a1:	89 d1                	mov    %edx,%ecx
  8017a3:	c1 e9 1b             	shr    $0x1b,%ecx
  8017a6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017a9:	83 e2 1f             	and    $0x1f,%edx
  8017ac:	29 ca                	sub    %ecx,%edx
  8017ae:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017b6:	83 c0 01             	add    $0x1,%eax
  8017b9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bc:	83 c7 01             	add    $0x1,%edi
  8017bf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017c2:	75 c2                	jne    801786 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c7:	eb 05                	jmp    8017ce <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5f                   	pop    %edi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	57                   	push   %edi
  8017da:	56                   	push   %esi
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 18             	sub    $0x18,%esp
  8017df:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017e2:	57                   	push   %edi
  8017e3:	e8 bb f6 ff ff       	call   800ea3 <fd2data>
  8017e8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f2:	eb 3d                	jmp    801831 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017f4:	85 db                	test   %ebx,%ebx
  8017f6:	74 04                	je     8017fc <devpipe_read+0x26>
				return i;
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	eb 44                	jmp    801840 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017fc:	89 f2                	mov    %esi,%edx
  8017fe:	89 f8                	mov    %edi,%eax
  801800:	e8 e5 fe ff ff       	call   8016ea <_pipeisclosed>
  801805:	85 c0                	test   %eax,%eax
  801807:	75 32                	jne    80183b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801809:	e8 05 f4 ff ff       	call   800c13 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80180e:	8b 06                	mov    (%esi),%eax
  801810:	3b 46 04             	cmp    0x4(%esi),%eax
  801813:	74 df                	je     8017f4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801815:	99                   	cltd   
  801816:	c1 ea 1b             	shr    $0x1b,%edx
  801819:	01 d0                	add    %edx,%eax
  80181b:	83 e0 1f             	and    $0x1f,%eax
  80181e:	29 d0                	sub    %edx,%eax
  801820:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801828:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80182b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80182e:	83 c3 01             	add    $0x1,%ebx
  801831:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801834:	75 d8                	jne    80180e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801836:	8b 45 10             	mov    0x10(%ebp),%eax
  801839:	eb 05                	jmp    801840 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80183b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801840:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801843:	5b                   	pop    %ebx
  801844:	5e                   	pop    %esi
  801845:	5f                   	pop    %edi
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801853:	50                   	push   %eax
  801854:	e8 61 f6 ff ff       	call   800eba <fd_alloc>
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	89 c2                	mov    %eax,%edx
  80185e:	85 c0                	test   %eax,%eax
  801860:	0f 88 2c 01 00 00    	js     801992 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	68 07 04 00 00       	push   $0x407
  80186e:	ff 75 f4             	pushl  -0xc(%ebp)
  801871:	6a 00                	push   $0x0
  801873:	e8 ba f3 ff ff       	call   800c32 <sys_page_alloc>
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	85 c0                	test   %eax,%eax
  80187f:	0f 88 0d 01 00 00    	js     801992 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801885:	83 ec 0c             	sub    $0xc,%esp
  801888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	e8 29 f6 ff ff       	call   800eba <fd_alloc>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	0f 88 e2 00 00 00    	js     801980 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	68 07 04 00 00       	push   $0x407
  8018a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a9:	6a 00                	push   $0x0
  8018ab:	e8 82 f3 ff ff       	call   800c32 <sys_page_alloc>
  8018b0:	89 c3                	mov    %eax,%ebx
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	0f 88 c3 00 00 00    	js     801980 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c3:	e8 db f5 ff ff       	call   800ea3 <fd2data>
  8018c8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ca:	83 c4 0c             	add    $0xc,%esp
  8018cd:	68 07 04 00 00       	push   $0x407
  8018d2:	50                   	push   %eax
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 58 f3 ff ff       	call   800c32 <sys_page_alloc>
  8018da:	89 c3                	mov    %eax,%ebx
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	0f 88 89 00 00 00    	js     801970 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ed:	e8 b1 f5 ff ff       	call   800ea3 <fd2data>
  8018f2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018f9:	50                   	push   %eax
  8018fa:	6a 00                	push   $0x0
  8018fc:	56                   	push   %esi
  8018fd:	6a 00                	push   $0x0
  8018ff:	e8 71 f3 ff ff       	call   800c75 <sys_page_map>
  801904:	89 c3                	mov    %eax,%ebx
  801906:	83 c4 20             	add    $0x20,%esp
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 55                	js     801962 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80190d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801916:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801918:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801922:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801928:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80192d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801930:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 f4             	pushl  -0xc(%ebp)
  80193d:	e8 51 f5 ff ff       	call   800e93 <fd2num>
  801942:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801945:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801947:	83 c4 04             	add    $0x4,%esp
  80194a:	ff 75 f0             	pushl  -0x10(%ebp)
  80194d:	e8 41 f5 ff ff       	call   800e93 <fd2num>
  801952:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801955:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	eb 30                	jmp    801992 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801962:	83 ec 08             	sub    $0x8,%esp
  801965:	56                   	push   %esi
  801966:	6a 00                	push   $0x0
  801968:	e8 4a f3 ff ff       	call   800cb7 <sys_page_unmap>
  80196d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801970:	83 ec 08             	sub    $0x8,%esp
  801973:	ff 75 f0             	pushl  -0x10(%ebp)
  801976:	6a 00                	push   $0x0
  801978:	e8 3a f3 ff ff       	call   800cb7 <sys_page_unmap>
  80197d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	ff 75 f4             	pushl  -0xc(%ebp)
  801986:	6a 00                	push   $0x0
  801988:	e8 2a f3 ff ff       	call   800cb7 <sys_page_unmap>
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801992:	89 d0                	mov    %edx,%eax
  801994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a4:	50                   	push   %eax
  8019a5:	ff 75 08             	pushl  0x8(%ebp)
  8019a8:	e8 5c f5 ff ff       	call   800f09 <fd_lookup>
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 18                	js     8019cc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019b4:	83 ec 0c             	sub    $0xc,%esp
  8019b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ba:	e8 e4 f4 ff ff       	call   800ea3 <fd2data>
	return _pipeisclosed(fd, p);
  8019bf:	89 c2                	mov    %eax,%edx
  8019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c4:	e8 21 fd ff ff       	call   8016ea <_pipeisclosed>
  8019c9:	83 c4 10             	add    $0x10,%esp
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019de:	68 ec 23 80 00       	push   $0x8023ec
  8019e3:	ff 75 0c             	pushl  0xc(%ebp)
  8019e6:	e8 44 ee ff ff       	call   80082f <strcpy>
	return 0;
}
  8019eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	57                   	push   %edi
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019fe:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a03:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a09:	eb 2d                	jmp    801a38 <devcons_write+0x46>
		m = n - tot;
  801a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a0e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a10:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a13:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a18:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a1b:	83 ec 04             	sub    $0x4,%esp
  801a1e:	53                   	push   %ebx
  801a1f:	03 45 0c             	add    0xc(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	57                   	push   %edi
  801a24:	e8 98 ef ff ff       	call   8009c1 <memmove>
		sys_cputs(buf, m);
  801a29:	83 c4 08             	add    $0x8,%esp
  801a2c:	53                   	push   %ebx
  801a2d:	57                   	push   %edi
  801a2e:	e8 43 f1 ff ff       	call   800b76 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a33:	01 de                	add    %ebx,%esi
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	89 f0                	mov    %esi,%eax
  801a3a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a3d:	72 cc                	jb     801a0b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5e                   	pop    %esi
  801a44:	5f                   	pop    %edi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a56:	74 2a                	je     801a82 <devcons_read+0x3b>
  801a58:	eb 05                	jmp    801a5f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a5a:	e8 b4 f1 ff ff       	call   800c13 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a5f:	e8 30 f1 ff ff       	call   800b94 <sys_cgetc>
  801a64:	85 c0                	test   %eax,%eax
  801a66:	74 f2                	je     801a5a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 16                	js     801a82 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a6c:	83 f8 04             	cmp    $0x4,%eax
  801a6f:	74 0c                	je     801a7d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a74:	88 02                	mov    %al,(%edx)
	return 1;
  801a76:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7b:	eb 05                	jmp    801a82 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a7d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a90:	6a 01                	push   $0x1
  801a92:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	e8 db f0 ff ff       	call   800b76 <sys_cputs>
}
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <getchar>:

int
getchar(void)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aa6:	6a 01                	push   $0x1
  801aa8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aab:	50                   	push   %eax
  801aac:	6a 00                	push   $0x0
  801aae:	e8 bc f6 ff ff       	call   80116f <read>
	if (r < 0)
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 0f                	js     801ac9 <getchar+0x29>
		return r;
	if (r < 1)
  801aba:	85 c0                	test   %eax,%eax
  801abc:	7e 06                	jle    801ac4 <getchar+0x24>
		return -E_EOF;
	return c;
  801abe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ac2:	eb 05                	jmp    801ac9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ac4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ac9:	c9                   	leave  
  801aca:	c3                   	ret    

00801acb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad4:	50                   	push   %eax
  801ad5:	ff 75 08             	pushl  0x8(%ebp)
  801ad8:	e8 2c f4 ff ff       	call   800f09 <fd_lookup>
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 11                	js     801af5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aed:	39 10                	cmp    %edx,(%eax)
  801aef:	0f 94 c0             	sete   %al
  801af2:	0f b6 c0             	movzbl %al,%eax
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <opencons>:

int
opencons(void)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801afd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b00:	50                   	push   %eax
  801b01:	e8 b4 f3 ff ff       	call   800eba <fd_alloc>
  801b06:	83 c4 10             	add    $0x10,%esp
		return r;
  801b09:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 3e                	js     801b4d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b0f:	83 ec 04             	sub    $0x4,%esp
  801b12:	68 07 04 00 00       	push   $0x407
  801b17:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1a:	6a 00                	push   $0x0
  801b1c:	e8 11 f1 ff ff       	call   800c32 <sys_page_alloc>
  801b21:	83 c4 10             	add    $0x10,%esp
		return r;
  801b24:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 23                	js     801b4d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b2a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b38:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	50                   	push   %eax
  801b43:	e8 4b f3 ff ff       	call   800e93 <fd2num>
  801b48:	89 c2                	mov    %eax,%edx
  801b4a:	83 c4 10             	add    $0x10,%esp
}
  801b4d:	89 d0                	mov    %edx,%eax
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	8b 75 08             	mov    0x8(%ebp),%esi
  801b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	74 0e                	je     801b71 <ipc_recv+0x20>
  801b63:	83 ec 0c             	sub    $0xc,%esp
  801b66:	50                   	push   %eax
  801b67:	e8 76 f2 ff ff       	call   800de2 <sys_ipc_recv>
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	eb 10                	jmp    801b81 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801b71:	83 ec 0c             	sub    $0xc,%esp
  801b74:	68 00 00 c0 ee       	push   $0xeec00000
  801b79:	e8 64 f2 ff ff       	call   800de2 <sys_ipc_recv>
  801b7e:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801b81:	85 c0                	test   %eax,%eax
  801b83:	74 16                	je     801b9b <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801b85:	85 f6                	test   %esi,%esi
  801b87:	74 06                	je     801b8f <ipc_recv+0x3e>
  801b89:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801b8f:	85 db                	test   %ebx,%ebx
  801b91:	74 2c                	je     801bbf <ipc_recv+0x6e>
  801b93:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b99:	eb 24                	jmp    801bbf <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b9b:	85 f6                	test   %esi,%esi
  801b9d:	74 0a                	je     801ba9 <ipc_recv+0x58>
  801b9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba4:	8b 40 74             	mov    0x74(%eax),%eax
  801ba7:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801ba9:	85 db                	test   %ebx,%ebx
  801bab:	74 0a                	je     801bb7 <ipc_recv+0x66>
  801bad:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb2:	8b 40 78             	mov    0x78(%eax),%eax
  801bb5:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801bb7:	a1 04 40 80 00       	mov    0x804004,%eax
  801bbc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc2:	5b                   	pop    %ebx
  801bc3:	5e                   	pop    %esi
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	57                   	push   %edi
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801bdf:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801be2:	ff 75 14             	pushl  0x14(%ebp)
  801be5:	53                   	push   %ebx
  801be6:	56                   	push   %esi
  801be7:	57                   	push   %edi
  801be8:	e8 d2 f1 ff ff       	call   800dbf <sys_ipc_try_send>
		if (ret == 0) break;
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	74 1e                	je     801c12 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801bf4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf7:	74 12                	je     801c0b <ipc_send+0x45>
  801bf9:	50                   	push   %eax
  801bfa:	68 f8 23 80 00       	push   $0x8023f8
  801bff:	6a 39                	push   $0x39
  801c01:	68 05 24 80 00       	push   $0x802405
  801c06:	e8 1f e5 ff ff       	call   80012a <_panic>
		sys_yield();
  801c0b:	e8 03 f0 ff ff       	call   800c13 <sys_yield>
	}
  801c10:	eb d0                	jmp    801be2 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c15:	5b                   	pop    %ebx
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c20:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c25:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c28:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c2e:	8b 52 50             	mov    0x50(%edx),%edx
  801c31:	39 ca                	cmp    %ecx,%edx
  801c33:	75 0d                	jne    801c42 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c35:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c38:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c3d:	8b 40 48             	mov    0x48(%eax),%eax
  801c40:	eb 0f                	jmp    801c51 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c42:	83 c0 01             	add    $0x1,%eax
  801c45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c4a:	75 d9                	jne    801c25 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	c1 e8 16             	shr    $0x16,%eax
  801c5e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c65:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c6a:	f6 c1 01             	test   $0x1,%cl
  801c6d:	74 1d                	je     801c8c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c6f:	c1 ea 0c             	shr    $0xc,%edx
  801c72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c79:	f6 c2 01             	test   $0x1,%dl
  801c7c:	74 0e                	je     801c8c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c7e:	c1 ea 0c             	shr    $0xc,%edx
  801c81:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c88:	ef 
  801c89:	0f b7 c0             	movzwl %ax,%eax
}
  801c8c:	5d                   	pop    %ebp
  801c8d:	c3                   	ret    
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cad:	89 ca                	mov    %ecx,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	75 3d                	jne    801cf0 <__udivdi3+0x60>
  801cb3:	39 cf                	cmp    %ecx,%edi
  801cb5:	0f 87 c5 00 00 00    	ja     801d80 <__udivdi3+0xf0>
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	89 fd                	mov    %edi,%ebp
  801cbf:	75 0b                	jne    801ccc <__udivdi3+0x3c>
  801cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc6:	31 d2                	xor    %edx,%edx
  801cc8:	f7 f7                	div    %edi
  801cca:	89 c5                	mov    %eax,%ebp
  801ccc:	89 c8                	mov    %ecx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f5                	div    %ebp
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	89 cf                	mov    %ecx,%edi
  801cd8:	f7 f5                	div    %ebp
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	89 fa                	mov    %edi,%edx
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	90                   	nop
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	39 ce                	cmp    %ecx,%esi
  801cf2:	77 74                	ja     801d68 <__udivdi3+0xd8>
  801cf4:	0f bd fe             	bsr    %esi,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0x108>
  801d00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	29 fb                	sub    %edi,%ebx
  801d0b:	d3 e6                	shl    %cl,%esi
  801d0d:	89 d9                	mov    %ebx,%ecx
  801d0f:	d3 ed                	shr    %cl,%ebp
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e0                	shl    %cl,%eax
  801d15:	09 ee                	or     %ebp,%esi
  801d17:	89 d9                	mov    %ebx,%ecx
  801d19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1d:	89 d5                	mov    %edx,%ebp
  801d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d23:	d3 ed                	shr    %cl,%ebp
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e2                	shl    %cl,%edx
  801d29:	89 d9                	mov    %ebx,%ecx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	89 ea                	mov    %ebp,%edx
  801d33:	f7 f6                	div    %esi
  801d35:	89 d5                	mov    %edx,%ebp
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	f7 64 24 0c          	mull   0xc(%esp)
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	72 10                	jb     801d51 <__udivdi3+0xc1>
  801d41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e6                	shl    %cl,%esi
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 07                	jae    801d54 <__udivdi3+0xc4>
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	75 03                	jne    801d54 <__udivdi3+0xc4>
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	89 fa                	mov    %edi,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	31 ff                	xor    %edi,%edi
  801d6a:	31 db                	xor    %ebx,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	f7 f7                	div    %edi
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 ce                	cmp    %ecx,%esi
  801d9a:	72 0c                	jb     801da8 <__udivdi3+0x118>
  801d9c:	31 db                	xor    %ebx,%ebx
  801d9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801da2:	0f 87 34 ff ff ff    	ja     801cdc <__udivdi3+0x4c>
  801da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dad:	e9 2a ff ff ff       	jmp    801cdc <__udivdi3+0x4c>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 d2                	test   %edx,%edx
  801dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f3                	mov    %esi,%ebx
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	75 1c                	jne    801e08 <__umoddi3+0x48>
  801dec:	39 f7                	cmp    %esi,%edi
  801dee:	76 50                	jbe    801e40 <__umoddi3+0x80>
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	f7 f7                	div    %edi
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	77 52                	ja     801e60 <__umoddi3+0xa0>
  801e0e:	0f bd ea             	bsr    %edx,%ebp
  801e11:	83 f5 1f             	xor    $0x1f,%ebp
  801e14:	75 5a                	jne    801e70 <__umoddi3+0xb0>
  801e16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e1a:	0f 82 e0 00 00 00    	jb     801f00 <__umoddi3+0x140>
  801e20:	39 0c 24             	cmp    %ecx,(%esp)
  801e23:	0f 86 d7 00 00 00    	jbe    801f00 <__umoddi3+0x140>
  801e29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	85 ff                	test   %edi,%edi
  801e42:	89 fd                	mov    %edi,%ebp
  801e44:	75 0b                	jne    801e51 <__umoddi3+0x91>
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f7                	div    %edi
  801e4f:	89 c5                	mov    %eax,%ebp
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f5                	div    %ebp
  801e57:	89 c8                	mov    %ecx,%eax
  801e59:	f7 f5                	div    %ebp
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	eb 99                	jmp    801df8 <__umoddi3+0x38>
  801e5f:	90                   	nop
  801e60:	89 c8                	mov    %ecx,%eax
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	8b 34 24             	mov    (%esp),%esi
  801e73:	bf 20 00 00 00       	mov    $0x20,%edi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	29 ef                	sub    %ebp,%edi
  801e7c:	d3 e0                	shl    %cl,%eax
  801e7e:	89 f9                	mov    %edi,%ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	d3 ea                	shr    %cl,%edx
  801e84:	89 e9                	mov    %ebp,%ecx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 14 24             	mov    %edx,(%esp)
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	d3 e2                	shl    %cl,%edx
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	d3 e3                	shl    %cl,%ebx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	d3 e8                	shr    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	09 d8                	or     %ebx,%eax
  801ead:	89 d3                	mov    %edx,%ebx
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 34 24             	divl   (%esp)
  801eb4:	89 d6                	mov    %edx,%esi
  801eb6:	d3 e3                	shl    %cl,%ebx
  801eb8:	f7 64 24 04          	mull   0x4(%esp)
  801ebc:	39 d6                	cmp    %edx,%esi
  801ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec2:	89 d1                	mov    %edx,%ecx
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	72 08                	jb     801ed0 <__umoddi3+0x110>
  801ec8:	75 11                	jne    801edb <__umoddi3+0x11b>
  801eca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ece:	73 0b                	jae    801edb <__umoddi3+0x11b>
  801ed0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ed4:	1b 14 24             	sbb    (%esp),%edx
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801edf:	29 da                	sub    %ebx,%edx
  801ee1:	19 ce                	sbb    %ecx,%esi
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	d3 ea                	shr    %cl,%edx
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	d3 ee                	shr    %cl,%esi
  801ef1:	09 d0                	or     %edx,%eax
  801ef3:	89 f2                	mov    %esi,%edx
  801ef5:	83 c4 1c             	add    $0x1c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	29 f9                	sub    %edi,%ecx
  801f02:	19 d6                	sbb    %edx,%esi
  801f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0c:	e9 18 ff ff ff       	jmp    801e29 <__umoddi3+0x69>
