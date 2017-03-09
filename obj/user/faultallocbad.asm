
obj/user/faultallocbad.debug:     file format elf32-i386


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
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 bf 0b 00 00       	call   800c1d <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 1f 80 00       	push   $0x801f40
  80006f:	6a 0f                	push   $0xf
  800071:	68 2a 1f 80 00       	push   $0x801f2a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 1f 80 00       	push   $0x801f6c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 3e 07 00 00       	call   8007c7 <snprintf>
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
  80009c:	e8 6d 0d 00 00       	call   800e0e <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 b1 0a 00 00       	call   800b61 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000c0:	e8 1a 0b 00 00       	call   800bdf <sys_getenvid>
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
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

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
  800101:	e8 43 0f 00 00       	call   801049 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 8e 0a 00 00       	call   800b9e <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 b7 0a 00 00       	call   800bdf <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 98 1f 80 00       	push   $0x801f98
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 d6 09 00 00       	call   800b61 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 1a 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 7b 09 00 00       	call   800b61 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 2a 1a 00 00       	call   801c80 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 17 1b 00 00       	call   801db0 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 bb 1f 80 00 	movsbl 0x801fbb(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 6a 04 00 00    	je     800771 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 d0             	movzbl %al,%edx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 fb 03 00 00    	ja     800756 <vprintfmt+0x46b>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 3f                	ja     8003ca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a4:	eb 2a                	jmp    8003d0 <vprintfmt+0xe5>
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	0f 49 d0             	cmovns %eax,%edx
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	eb 89                	jmp    800344 <vprintfmt+0x59>
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c5:	e9 7a ff ff ff       	jmp    800344 <vprintfmt+0x59>
  8003ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	0f 89 6a ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	e9 58 ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f2:	e9 4d ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 78 04             	lea    0x4(%eax),%edi
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	53                   	push   %ebx
  800401:	ff 30                	pushl  (%eax)
  800403:	ff d6                	call   *%esi
			break;
  800405:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040e:	e9 fe fe ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 78 04             	lea    0x4(%eax),%edi
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	99                   	cltd   
  80041c:	31 d0                	xor    %edx,%eax
  80041e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 0f             	cmp    $0xf,%eax
  800423:	7f 0b                	jg     800430 <vprintfmt+0x145>
  800425:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 1b                	jne    80044b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 d3 1f 80 00       	push   $0x801fd3
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 91 fe ff ff       	call   8002ce <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800446:	e9 c6 fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	52                   	push   %edx
  80044c:	68 be 23 80 00       	push   $0x8023be
  800451:	53                   	push   %ebx
  800452:	56                   	push   %esi
  800453:	e8 76 fe ff ff       	call   8002ce <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800461:	e9 ab fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	83 c0 04             	add    $0x4,%eax
  80046c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800474:	85 ff                	test   %edi,%edi
  800476:	b8 cc 1f 80 00       	mov    $0x801fcc,%eax
  80047b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	0f 8e 94 00 00 00    	jle    80051c <vprintfmt+0x231>
  800488:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048c:	0f 84 98 00 00 00    	je     80052a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 d0             	pushl  -0x30(%ebp)
  800498:	57                   	push   %edi
  800499:	e8 5b 03 00 00       	call   8007f9 <strnlen>
  80049e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a1:	29 c1                	sub    %eax,%ecx
  8004a3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0f                	jmp    8004c6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ef 01             	sub    $0x1,%edi
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	7f ed                	jg     8004b7 <vprintfmt+0x1cc>
  8004ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c1             	cmovns %ecx,%eax
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	89 cb                	mov    %ecx,%ebx
  8004e7:	eb 4d                	jmp    800536 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ed:	74 1b                	je     80050a <vprintfmt+0x21f>
  8004ef:	0f be c0             	movsbl %al,%eax
  8004f2:	83 e8 20             	sub    $0x20,%eax
  8004f5:	83 f8 5e             	cmp    $0x5e,%eax
  8004f8:	76 10                	jbe    80050a <vprintfmt+0x21f>
					putch('?', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	6a 3f                	push   $0x3f
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 0d                	jmp    800517 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	52                   	push   %edx
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 eb 01             	sub    $0x1,%ebx
  80051a:	eb 1a                	jmp    800536 <vprintfmt+0x24b>
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800528:	eb 0c                	jmp    800536 <vprintfmt+0x24b>
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800533:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	0f be d0             	movsbl %al,%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	74 23                	je     800567 <vprintfmt+0x27c>
  800544:	85 f6                	test   %esi,%esi
  800546:	78 a1                	js     8004e9 <vprintfmt+0x1fe>
  800548:	83 ee 01             	sub    $0x1,%esi
  80054b:	79 9c                	jns    8004e9 <vprintfmt+0x1fe>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	eb 18                	jmp    80056f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	6a 20                	push   $0x20
  80055d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055f:	83 ef 01             	sub    $0x1,%edi
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 08                	jmp    80056f <vprintfmt+0x284>
  800567:	89 df                	mov    %ebx,%edi
  800569:	8b 75 08             	mov    0x8(%ebp),%esi
  80056c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056f:	85 ff                	test   %edi,%edi
  800571:	7f e4                	jg     800557 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800573:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057c:	e9 90 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800581:	83 f9 01             	cmp    $0x1,%ecx
  800584:	7e 19                	jle    80059f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 50 04             	mov    0x4(%eax),%edx
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 08             	lea    0x8(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb 38                	jmp    8005d7 <vprintfmt+0x2ec>
	else if (lflag)
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	74 1b                	je     8005be <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 c1                	mov    %eax,%ecx
  8005ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bc:	eb 19                	jmp    8005d7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 c1                	mov    %eax,%ecx
  8005c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e6:	0f 89 36 01 00 00    	jns    800722 <vprintfmt+0x437>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fa:	f7 da                	neg    %edx
  8005fc:	83 d1 00             	adc    $0x0,%ecx
  8005ff:	f7 d9                	neg    %ecx
  800601:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
  800609:	e9 14 01 00 00       	jmp    800722 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7e 18                	jle    80062b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8b 48 04             	mov    0x4(%eax),%ecx
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	e9 f7 00 00 00       	jmp    800722 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062b:	85 c9                	test   %ecx,%ecx
  80062d:	74 1a                	je     800649 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 d9 00 00 00       	jmp    800722 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 bf 00 00 00       	jmp    800722 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800663:	83 f9 01             	cmp    $0x1,%ecx
  800666:	7e 13                	jle    80067b <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 50 04             	mov    0x4(%eax),%edx
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800673:	8d 49 08             	lea    0x8(%ecx),%ecx
  800676:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800679:	eb 28                	jmp    8006a3 <vprintfmt+0x3b8>
	else if (lflag)
  80067b:	85 c9                	test   %ecx,%ecx
  80067d:	74 13                	je     800692 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	89 d0                	mov    %edx,%eax
  800686:	99                   	cltd   
  800687:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80068a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80068d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800690:	eb 11                	jmp    8006a3 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	89 d0                	mov    %edx,%eax
  800699:	99                   	cltd   
  80069a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80069d:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8006a3:	89 d1                	mov    %edx,%ecx
  8006a5:	89 c2                	mov    %eax,%edx
			base = 8;
  8006a7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006ac:	eb 74                	jmp    800722 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 30                	push   $0x30
  8006b4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b6:	83 c4 08             	add    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 78                	push   $0x78
  8006bc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 10                	mov    (%eax),%edx
  8006c3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d6:	eb 4a                	jmp    800722 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 f9 01             	cmp    $0x1,%ecx
  8006db:	7e 15                	jle    8006f2 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e5:	8d 40 08             	lea    0x8(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f0:	eb 30                	jmp    800722 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006f2:	85 c9                	test   %ecx,%ecx
  8006f4:	74 17                	je     80070d <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800706:	b8 10 00 00 00       	mov    $0x10,%eax
  80070b:	eb 15                	jmp    800722 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800722:	83 ec 0c             	sub    $0xc,%esp
  800725:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800729:	57                   	push   %edi
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	50                   	push   %eax
  80072e:	51                   	push   %ecx
  80072f:	52                   	push   %edx
  800730:	89 da                	mov    %ebx,%edx
  800732:	89 f0                	mov    %esi,%eax
  800734:	e8 c9 fa ff ff       	call   800202 <printnum>
			break;
  800739:	83 c4 20             	add    $0x20,%esp
  80073c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073f:	e9 cd fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	52                   	push   %edx
  800749:	ff d6                	call   *%esi
			break;
  80074b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800751:	e9 bb fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 25                	push   $0x25
  80075c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb 03                	jmp    800766 <vprintfmt+0x47b>
  800763:	83 ef 01             	sub    $0x1,%edi
  800766:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80076a:	75 f7                	jne    800763 <vprintfmt+0x478>
  80076c:	e9 a0 fb ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800771:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5f                   	pop    %edi
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	83 ec 18             	sub    $0x18,%esp
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800785:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800788:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800796:	85 c0                	test   %eax,%eax
  800798:	74 26                	je     8007c0 <vsnprintf+0x47>
  80079a:	85 d2                	test   %edx,%edx
  80079c:	7e 22                	jle    8007c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079e:	ff 75 14             	pushl  0x14(%ebp)
  8007a1:	ff 75 10             	pushl  0x10(%ebp)
  8007a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	68 b1 02 80 00       	push   $0x8002b1
  8007ad:	e8 39 fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 05                	jmp    8007c5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 10             	pushl  0x10(%ebp)
  8007d4:	ff 75 0c             	pushl  0xc(%ebp)
  8007d7:	ff 75 08             	pushl  0x8(%ebp)
  8007da:	e8 9a ff ff ff       	call   800779 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 03                	jmp    8007f1 <strlen+0x10>
		n++;
  8007ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f5:	75 f7                	jne    8007ee <strlen+0xd>
		n++;
	return n;
}
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800802:	ba 00 00 00 00       	mov    $0x0,%edx
  800807:	eb 03                	jmp    80080c <strnlen+0x13>
		n++;
  800809:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080c:	39 c2                	cmp    %eax,%edx
  80080e:	74 08                	je     800818 <strnlen+0x1f>
  800810:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800814:	75 f3                	jne    800809 <strnlen+0x10>
  800816:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	83 c1 01             	add    $0x1,%ecx
  80082c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800830:	88 5a ff             	mov    %bl,-0x1(%edx)
  800833:	84 db                	test   %bl,%bl
  800835:	75 ef                	jne    800826 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800841:	53                   	push   %ebx
  800842:	e8 9a ff ff ff       	call   8007e1 <strlen>
  800847:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	50                   	push   %eax
  800850:	e8 c5 ff ff ff       	call   80081a <strcpy>
	return dst;
}
  800855:	89 d8                	mov    %ebx,%eax
  800857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 75 08             	mov    0x8(%ebp),%esi
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800867:	89 f3                	mov    %esi,%ebx
  800869:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	89 f2                	mov    %esi,%edx
  80086e:	eb 0f                	jmp    80087f <strncpy+0x23>
		*dst++ = *src;
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	0f b6 01             	movzbl (%ecx),%eax
  800876:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800879:	80 39 01             	cmpb   $0x1,(%ecx)
  80087c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087f:	39 da                	cmp    %ebx,%edx
  800881:	75 ed                	jne    800870 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800883:	89 f0                	mov    %esi,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	56                   	push   %esi
  80088d:	53                   	push   %ebx
  80088e:	8b 75 08             	mov    0x8(%ebp),%esi
  800891:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800894:	8b 55 10             	mov    0x10(%ebp),%edx
  800897:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800899:	85 d2                	test   %edx,%edx
  80089b:	74 21                	je     8008be <strlcpy+0x35>
  80089d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a1:	89 f2                	mov    %esi,%edx
  8008a3:	eb 09                	jmp    8008ae <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a5:	83 c2 01             	add    $0x1,%edx
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ae:	39 c2                	cmp    %eax,%edx
  8008b0:	74 09                	je     8008bb <strlcpy+0x32>
  8008b2:	0f b6 19             	movzbl (%ecx),%ebx
  8008b5:	84 db                	test   %bl,%bl
  8008b7:	75 ec                	jne    8008a5 <strlcpy+0x1c>
  8008b9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008be:	29 f0                	sub    %esi,%eax
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cd:	eb 06                	jmp    8008d5 <strcmp+0x11>
		p++, q++;
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d5:	0f b6 01             	movzbl (%ecx),%eax
  8008d8:	84 c0                	test   %al,%al
  8008da:	74 04                	je     8008e0 <strcmp+0x1c>
  8008dc:	3a 02                	cmp    (%edx),%al
  8008de:	74 ef                	je     8008cf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e0:	0f b6 c0             	movzbl %al,%eax
  8008e3:	0f b6 12             	movzbl (%edx),%edx
  8008e6:	29 d0                	sub    %edx,%eax
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f4:	89 c3                	mov    %eax,%ebx
  8008f6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f9:	eb 06                	jmp    800901 <strncmp+0x17>
		n--, p++, q++;
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800901:	39 d8                	cmp    %ebx,%eax
  800903:	74 15                	je     80091a <strncmp+0x30>
  800905:	0f b6 08             	movzbl (%eax),%ecx
  800908:	84 c9                	test   %cl,%cl
  80090a:	74 04                	je     800910 <strncmp+0x26>
  80090c:	3a 0a                	cmp    (%edx),%cl
  80090e:	74 eb                	je     8008fb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800910:	0f b6 00             	movzbl (%eax),%eax
  800913:	0f b6 12             	movzbl (%edx),%edx
  800916:	29 d0                	sub    %edx,%eax
  800918:	eb 05                	jmp    80091f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091f:	5b                   	pop    %ebx
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092c:	eb 07                	jmp    800935 <strchr+0x13>
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 0f                	je     800941 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	0f b6 10             	movzbl (%eax),%edx
  800938:	84 d2                	test   %dl,%dl
  80093a:	75 f2                	jne    80092e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094d:	eb 03                	jmp    800952 <strfind+0xf>
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800955:	38 ca                	cmp    %cl,%dl
  800957:	74 04                	je     80095d <strfind+0x1a>
  800959:	84 d2                	test   %dl,%dl
  80095b:	75 f2                	jne    80094f <strfind+0xc>
			break;
	return (char *) s;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 7d 08             	mov    0x8(%ebp),%edi
  800968:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096b:	85 c9                	test   %ecx,%ecx
  80096d:	74 36                	je     8009a5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800975:	75 28                	jne    80099f <memset+0x40>
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 23                	jne    80099f <memset+0x40>
		c &= 0xFF;
  80097c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800980:	89 d3                	mov    %edx,%ebx
  800982:	c1 e3 08             	shl    $0x8,%ebx
  800985:	89 d6                	mov    %edx,%esi
  800987:	c1 e6 18             	shl    $0x18,%esi
  80098a:	89 d0                	mov    %edx,%eax
  80098c:	c1 e0 10             	shl    $0x10,%eax
  80098f:	09 f0                	or     %esi,%eax
  800991:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800993:	89 d8                	mov    %ebx,%eax
  800995:	09 d0                	or     %edx,%eax
  800997:	c1 e9 02             	shr    $0x2,%ecx
  80099a:	fc                   	cld    
  80099b:	f3 ab                	rep stos %eax,%es:(%edi)
  80099d:	eb 06                	jmp    8009a5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	fc                   	cld    
  8009a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a5:	89 f8                	mov    %edi,%eax
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	5f                   	pop    %edi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ba:	39 c6                	cmp    %eax,%esi
  8009bc:	73 35                	jae    8009f3 <memmove+0x47>
  8009be:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c1:	39 d0                	cmp    %edx,%eax
  8009c3:	73 2e                	jae    8009f3 <memmove+0x47>
		s += n;
		d += n;
  8009c5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c8:	89 d6                	mov    %edx,%esi
  8009ca:	09 fe                	or     %edi,%esi
  8009cc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d2:	75 13                	jne    8009e7 <memmove+0x3b>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0e                	jne    8009e7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d9:	83 ef 04             	sub    $0x4,%edi
  8009dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009df:	c1 e9 02             	shr    $0x2,%ecx
  8009e2:	fd                   	std    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 09                	jmp    8009f0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e7:	83 ef 01             	sub    $0x1,%edi
  8009ea:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ed:	fd                   	std    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f0:	fc                   	cld    
  8009f1:	eb 1d                	jmp    800a10 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f3:	89 f2                	mov    %esi,%edx
  8009f5:	09 c2                	or     %eax,%edx
  8009f7:	f6 c2 03             	test   $0x3,%dl
  8009fa:	75 0f                	jne    800a0b <memmove+0x5f>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 0a                	jne    800a0b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a01:	c1 e9 02             	shr    $0x2,%ecx
  800a04:	89 c7                	mov    %eax,%edi
  800a06:	fc                   	cld    
  800a07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a09:	eb 05                	jmp    800a10 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0b:	89 c7                	mov    %eax,%edi
  800a0d:	fc                   	cld    
  800a0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a17:	ff 75 10             	pushl  0x10(%ebp)
  800a1a:	ff 75 0c             	pushl  0xc(%ebp)
  800a1d:	ff 75 08             	pushl  0x8(%ebp)
  800a20:	e8 87 ff ff ff       	call   8009ac <memmove>
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a32:	89 c6                	mov    %eax,%esi
  800a34:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a37:	eb 1a                	jmp    800a53 <memcmp+0x2c>
		if (*s1 != *s2)
  800a39:	0f b6 08             	movzbl (%eax),%ecx
  800a3c:	0f b6 1a             	movzbl (%edx),%ebx
  800a3f:	38 d9                	cmp    %bl,%cl
  800a41:	74 0a                	je     800a4d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a43:	0f b6 c1             	movzbl %cl,%eax
  800a46:	0f b6 db             	movzbl %bl,%ebx
  800a49:	29 d8                	sub    %ebx,%eax
  800a4b:	eb 0f                	jmp    800a5c <memcmp+0x35>
		s1++, s2++;
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	39 f0                	cmp    %esi,%eax
  800a55:	75 e2                	jne    800a39 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a67:	89 c1                	mov    %eax,%ecx
  800a69:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a70:	eb 0a                	jmp    800a7c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a72:	0f b6 10             	movzbl (%eax),%edx
  800a75:	39 da                	cmp    %ebx,%edx
  800a77:	74 07                	je     800a80 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	39 c8                	cmp    %ecx,%eax
  800a7e:	72 f2                	jb     800a72 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a80:	5b                   	pop    %ebx
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	eb 03                	jmp    800a94 <strtol+0x11>
		s++;
  800a91:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a94:	0f b6 01             	movzbl (%ecx),%eax
  800a97:	3c 20                	cmp    $0x20,%al
  800a99:	74 f6                	je     800a91 <strtol+0xe>
  800a9b:	3c 09                	cmp    $0x9,%al
  800a9d:	74 f2                	je     800a91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a9f:	3c 2b                	cmp    $0x2b,%al
  800aa1:	75 0a                	jne    800aad <strtol+0x2a>
		s++;
  800aa3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa6:	bf 00 00 00 00       	mov    $0x0,%edi
  800aab:	eb 11                	jmp    800abe <strtol+0x3b>
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab2:	3c 2d                	cmp    $0x2d,%al
  800ab4:	75 08                	jne    800abe <strtol+0x3b>
		s++, neg = 1;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac4:	75 15                	jne    800adb <strtol+0x58>
  800ac6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac9:	75 10                	jne    800adb <strtol+0x58>
  800acb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800acf:	75 7c                	jne    800b4d <strtol+0xca>
		s += 2, base = 16;
  800ad1:	83 c1 02             	add    $0x2,%ecx
  800ad4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad9:	eb 16                	jmp    800af1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800adb:	85 db                	test   %ebx,%ebx
  800add:	75 12                	jne    800af1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae7:	75 08                	jne    800af1 <strtol+0x6e>
		s++, base = 8;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af9:	0f b6 11             	movzbl (%ecx),%edx
  800afc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aff:	89 f3                	mov    %esi,%ebx
  800b01:	80 fb 09             	cmp    $0x9,%bl
  800b04:	77 08                	ja     800b0e <strtol+0x8b>
			dig = *s - '0';
  800b06:	0f be d2             	movsbl %dl,%edx
  800b09:	83 ea 30             	sub    $0x30,%edx
  800b0c:	eb 22                	jmp    800b30 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b11:	89 f3                	mov    %esi,%ebx
  800b13:	80 fb 19             	cmp    $0x19,%bl
  800b16:	77 08                	ja     800b20 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b18:	0f be d2             	movsbl %dl,%edx
  800b1b:	83 ea 57             	sub    $0x57,%edx
  800b1e:	eb 10                	jmp    800b30 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b23:	89 f3                	mov    %esi,%ebx
  800b25:	80 fb 19             	cmp    $0x19,%bl
  800b28:	77 16                	ja     800b40 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b2a:	0f be d2             	movsbl %dl,%edx
  800b2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b30:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b33:	7d 0b                	jge    800b40 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b3e:	eb b9                	jmp    800af9 <strtol+0x76>

	if (endptr)
  800b40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b44:	74 0d                	je     800b53 <strtol+0xd0>
		*endptr = (char *) s;
  800b46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b49:	89 0e                	mov    %ecx,(%esi)
  800b4b:	eb 06                	jmp    800b53 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4d:	85 db                	test   %ebx,%ebx
  800b4f:	74 98                	je     800ae9 <strtol+0x66>
  800b51:	eb 9e                	jmp    800af1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	f7 da                	neg    %edx
  800b57:	85 ff                	test   %edi,%edi
  800b59:	0f 45 c2             	cmovne %edx,%eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	89 c3                	mov    %eax,%ebx
  800b74:	89 c7                	mov    %eax,%edi
  800b76:	89 c6                	mov    %eax,%esi
  800b78:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	89 cb                	mov    %ecx,%ebx
  800bb6:	89 cf                	mov    %ecx,%edi
  800bb8:	89 ce                	mov    %ecx,%esi
  800bba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 03                	push   $0x3
  800bc6:	68 bf 22 80 00       	push   $0x8022bf
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 dc 22 80 00       	push   $0x8022dc
  800bd2:	e8 3e f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	b8 02 00 00 00       	mov    $0x2,%eax
  800bef:	89 d1                	mov    %edx,%ecx
  800bf1:	89 d3                	mov    %edx,%ebx
  800bf3:	89 d7                	mov    %edx,%edi
  800bf5:	89 d6                	mov    %edx,%esi
  800bf7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_yield>:

void
sys_yield(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	be 00 00 00 00       	mov    $0x0,%esi
  800c2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c39:	89 f7                	mov    %esi,%edi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 04                	push   $0x4
  800c47:	68 bf 22 80 00       	push   $0x8022bf
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 dc 22 80 00       	push   $0x8022dc
  800c53:	e8 bd f4 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 05                	push   $0x5
  800c89:	68 bf 22 80 00       	push   $0x8022bf
  800c8e:	6a 23                	push   $0x23
  800c90:	68 dc 22 80 00       	push   $0x8022dc
  800c95:	e8 7b f4 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 06                	push   $0x6
  800ccb:	68 bf 22 80 00       	push   $0x8022bf
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 dc 22 80 00       	push   $0x8022dc
  800cd7:	e8 39 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 08                	push   $0x8
  800d0d:	68 bf 22 80 00       	push   $0x8022bf
  800d12:	6a 23                	push   $0x23
  800d14:	68 dc 22 80 00       	push   $0x8022dc
  800d19:	e8 f7 f3 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 09 00 00 00       	mov    $0x9,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 09                	push   $0x9
  800d4f:	68 bf 22 80 00       	push   $0x8022bf
  800d54:	6a 23                	push   $0x23
  800d56:	68 dc 22 80 00       	push   $0x8022dc
  800d5b:	e8 b5 f3 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0a                	push   $0xa
  800d91:	68 bf 22 80 00       	push   $0x8022bf
  800d96:	6a 23                	push   $0x23
  800d98:	68 dc 22 80 00       	push   $0x8022dc
  800d9d:	e8 73 f3 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	be 00 00 00 00       	mov    $0x0,%esi
  800db5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 cb                	mov    %ecx,%ebx
  800de5:	89 cf                	mov    %ecx,%edi
  800de7:	89 ce                	mov    %ecx,%esi
  800de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 0d                	push   $0xd
  800df5:	68 bf 22 80 00       	push   $0x8022bf
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 dc 22 80 00       	push   $0x8022dc
  800e01:	e8 0f f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e14:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e1b:	75 31                	jne    800e4e <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  800e1d:	a1 04 40 80 00       	mov    0x804004,%eax
  800e22:	8b 40 48             	mov    0x48(%eax),%eax
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	6a 07                	push   $0x7
  800e2a:	68 00 f0 bf ee       	push   $0xeebff000
  800e2f:	50                   	push   %eax
  800e30:	e8 e8 fd ff ff       	call   800c1d <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  800e35:	a1 04 40 80 00       	mov    0x804004,%eax
  800e3a:	8b 40 48             	mov    0x48(%eax),%eax
  800e3d:	83 c4 08             	add    $0x8,%esp
  800e40:	68 58 0e 80 00       	push   $0x800e58
  800e45:	50                   	push   %eax
  800e46:	e8 1d ff ff ff       	call   800d68 <sys_env_set_pgfault_upcall>
  800e4b:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e58:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e59:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e5e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e60:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  800e63:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  800e66:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  800e6a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  800e6e:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  800e71:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  800e73:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e77:	61                   	popa   
	addl $4, %esp        // skip eip
  800e78:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  800e7b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800e7c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e7d:	c3                   	ret    

00800e7e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	05 00 00 00 30       	add    $0x30000000,%eax
  800e89:	c1 e8 0c             	shr    $0xc,%eax
}
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	05 00 00 00 30       	add    $0x30000000,%eax
  800e99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e9e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	c1 ea 16             	shr    $0x16,%edx
  800eb5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebc:	f6 c2 01             	test   $0x1,%dl
  800ebf:	74 11                	je     800ed2 <fd_alloc+0x2d>
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	c1 ea 0c             	shr    $0xc,%edx
  800ec6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ecd:	f6 c2 01             	test   $0x1,%dl
  800ed0:	75 09                	jne    800edb <fd_alloc+0x36>
			*fd_store = fd;
  800ed2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	eb 17                	jmp    800ef2 <fd_alloc+0x4d>
  800edb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ee0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee5:	75 c9                	jne    800eb0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eed:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efa:	83 f8 1f             	cmp    $0x1f,%eax
  800efd:	77 36                	ja     800f35 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eff:	c1 e0 0c             	shl    $0xc,%eax
  800f02:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f07:	89 c2                	mov    %eax,%edx
  800f09:	c1 ea 16             	shr    $0x16,%edx
  800f0c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f13:	f6 c2 01             	test   $0x1,%dl
  800f16:	74 24                	je     800f3c <fd_lookup+0x48>
  800f18:	89 c2                	mov    %eax,%edx
  800f1a:	c1 ea 0c             	shr    $0xc,%edx
  800f1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f24:	f6 c2 01             	test   $0x1,%dl
  800f27:	74 1a                	je     800f43 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2c:	89 02                	mov    %eax,(%edx)
	return 0;
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f33:	eb 13                	jmp    800f48 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3a:	eb 0c                	jmp    800f48 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f41:	eb 05                	jmp    800f48 <fd_lookup+0x54>
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 08             	sub    $0x8,%esp
  800f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f53:	ba 6c 23 80 00       	mov    $0x80236c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f58:	eb 13                	jmp    800f6d <dev_lookup+0x23>
  800f5a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f5d:	39 08                	cmp    %ecx,(%eax)
  800f5f:	75 0c                	jne    800f6d <dev_lookup+0x23>
			*dev = devtab[i];
  800f61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f64:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	eb 2e                	jmp    800f9b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f6d:	8b 02                	mov    (%edx),%eax
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	75 e7                	jne    800f5a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f73:	a1 04 40 80 00       	mov    0x804004,%eax
  800f78:	8b 40 48             	mov    0x48(%eax),%eax
  800f7b:	83 ec 04             	sub    $0x4,%esp
  800f7e:	51                   	push   %ecx
  800f7f:	50                   	push   %eax
  800f80:	68 ec 22 80 00       	push   $0x8022ec
  800f85:	e8 64 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 10             	sub    $0x10,%esp
  800fa5:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
  800fb8:	50                   	push   %eax
  800fb9:	e8 36 ff ff ff       	call   800ef4 <fd_lookup>
  800fbe:	83 c4 08             	add    $0x8,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 05                	js     800fca <fd_close+0x2d>
	    || fd != fd2)
  800fc5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fc8:	74 0c                	je     800fd6 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fca:	84 db                	test   %bl,%bl
  800fcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd1:	0f 44 c2             	cmove  %edx,%eax
  800fd4:	eb 41                	jmp    801017 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 36                	pushl  (%esi)
  800fdf:	e8 66 ff ff ff       	call   800f4a <dev_lookup>
  800fe4:	89 c3                	mov    %eax,%ebx
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 1a                	js     801007 <fd_close+0x6a>
		if (dev->dev_close)
  800fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	74 0b                	je     801007 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	56                   	push   %esi
  801000:	ff d0                	call   *%eax
  801002:	89 c3                	mov    %eax,%ebx
  801004:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	56                   	push   %esi
  80100b:	6a 00                	push   $0x0
  80100d:	e8 90 fc ff ff       	call   800ca2 <sys_page_unmap>
	return r;
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	89 d8                	mov    %ebx,%eax
}
  801017:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801024:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	ff 75 08             	pushl  0x8(%ebp)
  80102b:	e8 c4 fe ff ff       	call   800ef4 <fd_lookup>
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 10                	js     801047 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	6a 01                	push   $0x1
  80103c:	ff 75 f4             	pushl  -0xc(%ebp)
  80103f:	e8 59 ff ff ff       	call   800f9d <fd_close>
  801044:	83 c4 10             	add    $0x10,%esp
}
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <close_all>:

void
close_all(void)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	53                   	push   %ebx
  80104d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801050:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	53                   	push   %ebx
  801059:	e8 c0 ff ff ff       	call   80101e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80105e:	83 c3 01             	add    $0x1,%ebx
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	83 fb 20             	cmp    $0x20,%ebx
  801067:	75 ec                	jne    801055 <close_all+0xc>
		close(i);
}
  801069:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 2c             	sub    $0x2c,%esp
  801077:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	ff 75 08             	pushl  0x8(%ebp)
  801081:	e8 6e fe ff ff       	call   800ef4 <fd_lookup>
  801086:	83 c4 08             	add    $0x8,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	0f 88 c1 00 00 00    	js     801152 <dup+0xe4>
		return r;
	close(newfdnum);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	56                   	push   %esi
  801095:	e8 84 ff ff ff       	call   80101e <close>

	newfd = INDEX2FD(newfdnum);
  80109a:	89 f3                	mov    %esi,%ebx
  80109c:	c1 e3 0c             	shl    $0xc,%ebx
  80109f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010a5:	83 c4 04             	add    $0x4,%esp
  8010a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ab:	e8 de fd ff ff       	call   800e8e <fd2data>
  8010b0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010b2:	89 1c 24             	mov    %ebx,(%esp)
  8010b5:	e8 d4 fd ff ff       	call   800e8e <fd2data>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c0:	89 f8                	mov    %edi,%eax
  8010c2:	c1 e8 16             	shr    $0x16,%eax
  8010c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010cc:	a8 01                	test   $0x1,%al
  8010ce:	74 37                	je     801107 <dup+0x99>
  8010d0:	89 f8                	mov    %edi,%eax
  8010d2:	c1 e8 0c             	shr    $0xc,%eax
  8010d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010dc:	f6 c2 01             	test   $0x1,%dl
  8010df:	74 26                	je     801107 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f0:	50                   	push   %eax
  8010f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f4:	6a 00                	push   $0x0
  8010f6:	57                   	push   %edi
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 62 fb ff ff       	call   800c60 <sys_page_map>
  8010fe:	89 c7                	mov    %eax,%edi
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	78 2e                	js     801135 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801107:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80110a:	89 d0                	mov    %edx,%eax
  80110c:	c1 e8 0c             	shr    $0xc,%eax
  80110f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	25 07 0e 00 00       	and    $0xe07,%eax
  80111e:	50                   	push   %eax
  80111f:	53                   	push   %ebx
  801120:	6a 00                	push   $0x0
  801122:	52                   	push   %edx
  801123:	6a 00                	push   $0x0
  801125:	e8 36 fb ff ff       	call   800c60 <sys_page_map>
  80112a:	89 c7                	mov    %eax,%edi
  80112c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80112f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801131:	85 ff                	test   %edi,%edi
  801133:	79 1d                	jns    801152 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	53                   	push   %ebx
  801139:	6a 00                	push   $0x0
  80113b:	e8 62 fb ff ff       	call   800ca2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801140:	83 c4 08             	add    $0x8,%esp
  801143:	ff 75 d4             	pushl  -0x2c(%ebp)
  801146:	6a 00                	push   $0x0
  801148:	e8 55 fb ff ff       	call   800ca2 <sys_page_unmap>
	return r;
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	89 f8                	mov    %edi,%eax
}
  801152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	83 ec 14             	sub    $0x14,%esp
  801161:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801164:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801167:	50                   	push   %eax
  801168:	53                   	push   %ebx
  801169:	e8 86 fd ff ff       	call   800ef4 <fd_lookup>
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	89 c2                	mov    %eax,%edx
  801173:	85 c0                	test   %eax,%eax
  801175:	78 6d                	js     8011e4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117d:	50                   	push   %eax
  80117e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801181:	ff 30                	pushl  (%eax)
  801183:	e8 c2 fd ff ff       	call   800f4a <dev_lookup>
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 4c                	js     8011db <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80118f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801192:	8b 42 08             	mov    0x8(%edx),%eax
  801195:	83 e0 03             	and    $0x3,%eax
  801198:	83 f8 01             	cmp    $0x1,%eax
  80119b:	75 21                	jne    8011be <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80119d:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a2:	8b 40 48             	mov    0x48(%eax),%eax
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	53                   	push   %ebx
  8011a9:	50                   	push   %eax
  8011aa:	68 30 23 80 00       	push   $0x802330
  8011af:	e8 3a f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011bc:	eb 26                	jmp    8011e4 <read+0x8a>
	}
	if (!dev->dev_read)
  8011be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c1:	8b 40 08             	mov    0x8(%eax),%eax
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	74 17                	je     8011df <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011c8:	83 ec 04             	sub    $0x4,%esp
  8011cb:	ff 75 10             	pushl  0x10(%ebp)
  8011ce:	ff 75 0c             	pushl  0xc(%ebp)
  8011d1:	52                   	push   %edx
  8011d2:	ff d0                	call   *%eax
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	eb 09                	jmp    8011e4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	eb 05                	jmp    8011e4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011e4:	89 d0                	mov    %edx,%eax
  8011e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	57                   	push   %edi
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ff:	eb 21                	jmp    801222 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	89 f0                	mov    %esi,%eax
  801206:	29 d8                	sub    %ebx,%eax
  801208:	50                   	push   %eax
  801209:	89 d8                	mov    %ebx,%eax
  80120b:	03 45 0c             	add    0xc(%ebp),%eax
  80120e:	50                   	push   %eax
  80120f:	57                   	push   %edi
  801210:	e8 45 ff ff ff       	call   80115a <read>
		if (m < 0)
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 10                	js     80122c <readn+0x41>
			return m;
		if (m == 0)
  80121c:	85 c0                	test   %eax,%eax
  80121e:	74 0a                	je     80122a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801220:	01 c3                	add    %eax,%ebx
  801222:	39 f3                	cmp    %esi,%ebx
  801224:	72 db                	jb     801201 <readn+0x16>
  801226:	89 d8                	mov    %ebx,%eax
  801228:	eb 02                	jmp    80122c <readn+0x41>
  80122a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80122c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	53                   	push   %ebx
  801238:	83 ec 14             	sub    $0x14,%esp
  80123b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	53                   	push   %ebx
  801243:	e8 ac fc ff ff       	call   800ef4 <fd_lookup>
  801248:	83 c4 08             	add    $0x8,%esp
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 68                	js     8012b9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	ff 30                	pushl  (%eax)
  80125d:	e8 e8 fc ff ff       	call   800f4a <dev_lookup>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 47                	js     8012b0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801270:	75 21                	jne    801293 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801272:	a1 04 40 80 00       	mov    0x804004,%eax
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	53                   	push   %ebx
  80127e:	50                   	push   %eax
  80127f:	68 4c 23 80 00       	push   $0x80234c
  801284:	e8 65 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801291:	eb 26                	jmp    8012b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801293:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801296:	8b 52 0c             	mov    0xc(%edx),%edx
  801299:	85 d2                	test   %edx,%edx
  80129b:	74 17                	je     8012b4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80129d:	83 ec 04             	sub    $0x4,%esp
  8012a0:	ff 75 10             	pushl  0x10(%ebp)
  8012a3:	ff 75 0c             	pushl  0xc(%ebp)
  8012a6:	50                   	push   %eax
  8012a7:	ff d2                	call   *%edx
  8012a9:	89 c2                	mov    %eax,%edx
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	eb 09                	jmp    8012b9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b0:	89 c2                	mov    %eax,%edx
  8012b2:	eb 05                	jmp    8012b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012b9:	89 d0                	mov    %edx,%eax
  8012bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 22 fc ff ff       	call   800ef4 <fd_lookup>
  8012d2:	83 c4 08             	add    $0x8,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 0e                	js     8012e7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012df:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 14             	sub    $0x14,%esp
  8012f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	53                   	push   %ebx
  8012f8:	e8 f7 fb ff ff       	call   800ef4 <fd_lookup>
  8012fd:	83 c4 08             	add    $0x8,%esp
  801300:	89 c2                	mov    %eax,%edx
  801302:	85 c0                	test   %eax,%eax
  801304:	78 65                	js     80136b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	ff 30                	pushl  (%eax)
  801312:	e8 33 fc ff ff       	call   800f4a <dev_lookup>
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 44                	js     801362 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801321:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801325:	75 21                	jne    801348 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801327:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80132c:	8b 40 48             	mov    0x48(%eax),%eax
  80132f:	83 ec 04             	sub    $0x4,%esp
  801332:	53                   	push   %ebx
  801333:	50                   	push   %eax
  801334:	68 0c 23 80 00       	push   $0x80230c
  801339:	e8 b0 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801346:	eb 23                	jmp    80136b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801348:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134b:	8b 52 18             	mov    0x18(%edx),%edx
  80134e:	85 d2                	test   %edx,%edx
  801350:	74 14                	je     801366 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	ff 75 0c             	pushl  0xc(%ebp)
  801358:	50                   	push   %eax
  801359:	ff d2                	call   *%edx
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	eb 09                	jmp    80136b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801362:	89 c2                	mov    %eax,%edx
  801364:	eb 05                	jmp    80136b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801366:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80136b:	89 d0                	mov    %edx,%eax
  80136d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801370:	c9                   	leave  
  801371:	c3                   	ret    

00801372 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	53                   	push   %ebx
  801376:	83 ec 14             	sub    $0x14,%esp
  801379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 75 08             	pushl  0x8(%ebp)
  801383:	e8 6c fb ff ff       	call   800ef4 <fd_lookup>
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 58                	js     8013e9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139b:	ff 30                	pushl  (%eax)
  80139d:	e8 a8 fb ff ff       	call   800f4a <dev_lookup>
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 37                	js     8013e0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ac:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b0:	74 32                	je     8013e4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013bc:	00 00 00 
	stat->st_isdir = 0;
  8013bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c6:	00 00 00 
	stat->st_dev = dev;
  8013c9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	53                   	push   %ebx
  8013d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d6:	ff 50 14             	call   *0x14(%eax)
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	eb 09                	jmp    8013e9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e0:	89 c2                	mov    %eax,%edx
  8013e2:	eb 05                	jmp    8013e9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013e9:	89 d0                	mov    %edx,%eax
  8013eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	6a 00                	push   $0x0
  8013fa:	ff 75 08             	pushl  0x8(%ebp)
  8013fd:	e8 b7 01 00 00       	call   8015b9 <open>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 1b                	js     801426 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	ff 75 0c             	pushl  0xc(%ebp)
  801411:	50                   	push   %eax
  801412:	e8 5b ff ff ff       	call   801372 <fstat>
  801417:	89 c6                	mov    %eax,%esi
	close(fd);
  801419:	89 1c 24             	mov    %ebx,(%esp)
  80141c:	e8 fd fb ff ff       	call   80101e <close>
	return r;
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	89 f0                	mov    %esi,%eax
}
  801426:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801429:	5b                   	pop    %ebx
  80142a:	5e                   	pop    %esi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    

0080142d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	89 c6                	mov    %eax,%esi
  801434:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801436:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80143d:	75 12                	jne    801451 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	6a 01                	push   $0x1
  801444:	e8 bc 07 00 00       	call   801c05 <ipc_find_env>
  801449:	a3 00 40 80 00       	mov    %eax,0x804000
  80144e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801451:	6a 07                	push   $0x7
  801453:	68 00 50 80 00       	push   $0x805000
  801458:	56                   	push   %esi
  801459:	ff 35 00 40 80 00    	pushl  0x804000
  80145f:	e8 4d 07 00 00       	call   801bb1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801464:	83 c4 0c             	add    $0xc,%esp
  801467:	6a 00                	push   $0x0
  801469:	53                   	push   %ebx
  80146a:	6a 00                	push   $0x0
  80146c:	e8 cb 06 00 00       	call   801b3c <ipc_recv>
}
  801471:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801474:	5b                   	pop    %ebx
  801475:	5e                   	pop    %esi
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80147e:	8b 45 08             	mov    0x8(%ebp),%eax
  801481:	8b 40 0c             	mov    0xc(%eax),%eax
  801484:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801489:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801491:	ba 00 00 00 00       	mov    $0x0,%edx
  801496:	b8 02 00 00 00       	mov    $0x2,%eax
  80149b:	e8 8d ff ff ff       	call   80142d <fsipc>
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ae:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8014bd:	e8 6b ff ff ff       	call   80142d <fsipc>
}
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e3:	e8 45 ff ff ff       	call   80142d <fsipc>
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 2c                	js     801518 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	68 00 50 80 00       	push   $0x805000
  8014f4:	53                   	push   %ebx
  8014f5:	e8 20 f3 ff ff       	call   80081a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014fa:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801505:	a1 84 50 80 00       	mov    0x805084,%eax
  80150a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801523:	68 7c 23 80 00       	push   $0x80237c
  801528:	68 90 00 00 00       	push   $0x90
  80152d:	68 9a 23 80 00       	push   $0x80239a
  801532:	e8 de eb ff ff       	call   800115 <_panic>

00801537 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	56                   	push   %esi
  80153b:	53                   	push   %ebx
  80153c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80153f:	8b 45 08             	mov    0x8(%ebp),%eax
  801542:	8b 40 0c             	mov    0xc(%eax),%eax
  801545:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80154a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 03 00 00 00       	mov    $0x3,%eax
  80155a:	e8 ce fe ff ff       	call   80142d <fsipc>
  80155f:	89 c3                	mov    %eax,%ebx
  801561:	85 c0                	test   %eax,%eax
  801563:	78 4b                	js     8015b0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801565:	39 c6                	cmp    %eax,%esi
  801567:	73 16                	jae    80157f <devfile_read+0x48>
  801569:	68 a5 23 80 00       	push   $0x8023a5
  80156e:	68 ac 23 80 00       	push   $0x8023ac
  801573:	6a 7c                	push   $0x7c
  801575:	68 9a 23 80 00       	push   $0x80239a
  80157a:	e8 96 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  80157f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801584:	7e 16                	jle    80159c <devfile_read+0x65>
  801586:	68 c1 23 80 00       	push   $0x8023c1
  80158b:	68 ac 23 80 00       	push   $0x8023ac
  801590:	6a 7d                	push   $0x7d
  801592:	68 9a 23 80 00       	push   $0x80239a
  801597:	e8 79 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	50                   	push   %eax
  8015a0:	68 00 50 80 00       	push   $0x805000
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	e8 ff f3 ff ff       	call   8009ac <memmove>
	return r;
  8015ad:	83 c4 10             	add    $0x10,%esp
}
  8015b0:	89 d8                	mov    %ebx,%eax
  8015b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5e                   	pop    %esi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 20             	sub    $0x20,%esp
  8015c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c3:	53                   	push   %ebx
  8015c4:	e8 18 f2 ff ff       	call   8007e1 <strlen>
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d1:	7f 67                	jg     80163a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	e8 c6 f8 ff ff       	call   800ea5 <fd_alloc>
  8015df:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 57                	js     80163f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	68 00 50 80 00       	push   $0x805000
  8015f1:	e8 24 f2 ff ff       	call   80081a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801601:	b8 01 00 00 00       	mov    $0x1,%eax
  801606:	e8 22 fe ff ff       	call   80142d <fsipc>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	79 14                	jns    801628 <open+0x6f>
		fd_close(fd, 0);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	6a 00                	push   $0x0
  801619:	ff 75 f4             	pushl  -0xc(%ebp)
  80161c:	e8 7c f9 ff ff       	call   800f9d <fd_close>
		return r;
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	89 da                	mov    %ebx,%edx
  801626:	eb 17                	jmp    80163f <open+0x86>
	}

	return fd2num(fd);
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	ff 75 f4             	pushl  -0xc(%ebp)
  80162e:	e8 4b f8 ff ff       	call   800e7e <fd2num>
  801633:	89 c2                	mov    %eax,%edx
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	eb 05                	jmp    80163f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80163f:	89 d0                	mov    %edx,%eax
  801641:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164c:	ba 00 00 00 00       	mov    $0x0,%edx
  801651:	b8 08 00 00 00       	mov    $0x8,%eax
  801656:	e8 d2 fd ff ff       	call   80142d <fsipc>
}
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	ff 75 08             	pushl  0x8(%ebp)
  80166b:	e8 1e f8 ff ff       	call   800e8e <fd2data>
  801670:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801672:	83 c4 08             	add    $0x8,%esp
  801675:	68 cd 23 80 00       	push   $0x8023cd
  80167a:	53                   	push   %ebx
  80167b:	e8 9a f1 ff ff       	call   80081a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801680:	8b 46 04             	mov    0x4(%esi),%eax
  801683:	2b 06                	sub    (%esi),%eax
  801685:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80168b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801692:	00 00 00 
	stat->st_dev = &devpipe;
  801695:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80169c:	30 80 00 
	return 0;
}
  80169f:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 0c             	sub    $0xc,%esp
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016b5:	53                   	push   %ebx
  8016b6:	6a 00                	push   $0x0
  8016b8:	e8 e5 f5 ff ff       	call   800ca2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016bd:	89 1c 24             	mov    %ebx,(%esp)
  8016c0:	e8 c9 f7 ff ff       	call   800e8e <fd2data>
  8016c5:	83 c4 08             	add    $0x8,%esp
  8016c8:	50                   	push   %eax
  8016c9:	6a 00                	push   $0x0
  8016cb:	e8 d2 f5 ff ff       	call   800ca2 <sys_page_unmap>
}
  8016d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	57                   	push   %edi
  8016d9:	56                   	push   %esi
  8016da:	53                   	push   %ebx
  8016db:	83 ec 1c             	sub    $0x1c,%esp
  8016de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f1:	e8 48 05 00 00       	call   801c3e <pageref>
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	89 3c 24             	mov    %edi,(%esp)
  8016fb:	e8 3e 05 00 00       	call   801c3e <pageref>
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	39 c3                	cmp    %eax,%ebx
  801705:	0f 94 c1             	sete   %cl
  801708:	0f b6 c9             	movzbl %cl,%ecx
  80170b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80170e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801714:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801717:	39 ce                	cmp    %ecx,%esi
  801719:	74 1b                	je     801736 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80171b:	39 c3                	cmp    %eax,%ebx
  80171d:	75 c4                	jne    8016e3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80171f:	8b 42 58             	mov    0x58(%edx),%eax
  801722:	ff 75 e4             	pushl  -0x1c(%ebp)
  801725:	50                   	push   %eax
  801726:	56                   	push   %esi
  801727:	68 d4 23 80 00       	push   $0x8023d4
  80172c:	e8 bd ea ff ff       	call   8001ee <cprintf>
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	eb ad                	jmp    8016e3 <_pipeisclosed+0xe>
	}
}
  801736:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801739:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5f                   	pop    %edi
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	57                   	push   %edi
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	83 ec 28             	sub    $0x28,%esp
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80174d:	56                   	push   %esi
  80174e:	e8 3b f7 ff ff       	call   800e8e <fd2data>
  801753:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	bf 00 00 00 00       	mov    $0x0,%edi
  80175d:	eb 4b                	jmp    8017aa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80175f:	89 da                	mov    %ebx,%edx
  801761:	89 f0                	mov    %esi,%eax
  801763:	e8 6d ff ff ff       	call   8016d5 <_pipeisclosed>
  801768:	85 c0                	test   %eax,%eax
  80176a:	75 48                	jne    8017b4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80176c:	e8 8d f4 ff ff       	call   800bfe <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801771:	8b 43 04             	mov    0x4(%ebx),%eax
  801774:	8b 0b                	mov    (%ebx),%ecx
  801776:	8d 51 20             	lea    0x20(%ecx),%edx
  801779:	39 d0                	cmp    %edx,%eax
  80177b:	73 e2                	jae    80175f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80177d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801780:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801784:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801787:	89 c2                	mov    %eax,%edx
  801789:	c1 fa 1f             	sar    $0x1f,%edx
  80178c:	89 d1                	mov    %edx,%ecx
  80178e:	c1 e9 1b             	shr    $0x1b,%ecx
  801791:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801794:	83 e2 1f             	and    $0x1f,%edx
  801797:	29 ca                	sub    %ecx,%edx
  801799:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80179d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017a1:	83 c0 01             	add    $0x1,%eax
  8017a4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a7:	83 c7 01             	add    $0x1,%edi
  8017aa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017ad:	75 c2                	jne    801771 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017af:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b2:	eb 05                	jmp    8017b9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5f                   	pop    %edi
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    

008017c1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	57                   	push   %edi
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 18             	sub    $0x18,%esp
  8017ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017cd:	57                   	push   %edi
  8017ce:	e8 bb f6 ff ff       	call   800e8e <fd2data>
  8017d3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017dd:	eb 3d                	jmp    80181c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017df:	85 db                	test   %ebx,%ebx
  8017e1:	74 04                	je     8017e7 <devpipe_read+0x26>
				return i;
  8017e3:	89 d8                	mov    %ebx,%eax
  8017e5:	eb 44                	jmp    80182b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017e7:	89 f2                	mov    %esi,%edx
  8017e9:	89 f8                	mov    %edi,%eax
  8017eb:	e8 e5 fe ff ff       	call   8016d5 <_pipeisclosed>
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	75 32                	jne    801826 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017f4:	e8 05 f4 ff ff       	call   800bfe <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017f9:	8b 06                	mov    (%esi),%eax
  8017fb:	3b 46 04             	cmp    0x4(%esi),%eax
  8017fe:	74 df                	je     8017df <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801800:	99                   	cltd   
  801801:	c1 ea 1b             	shr    $0x1b,%edx
  801804:	01 d0                	add    %edx,%eax
  801806:	83 e0 1f             	and    $0x1f,%eax
  801809:	29 d0                	sub    %edx,%eax
  80180b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801813:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801816:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801819:	83 c3 01             	add    $0x1,%ebx
  80181c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80181f:	75 d8                	jne    8017f9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801821:	8b 45 10             	mov    0x10(%ebp),%eax
  801824:	eb 05                	jmp    80182b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801826:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80182b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5f                   	pop    %edi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80183b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183e:	50                   	push   %eax
  80183f:	e8 61 f6 ff ff       	call   800ea5 <fd_alloc>
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	89 c2                	mov    %eax,%edx
  801849:	85 c0                	test   %eax,%eax
  80184b:	0f 88 2c 01 00 00    	js     80197d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	68 07 04 00 00       	push   $0x407
  801859:	ff 75 f4             	pushl  -0xc(%ebp)
  80185c:	6a 00                	push   $0x0
  80185e:	e8 ba f3 ff ff       	call   800c1d <sys_page_alloc>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	89 c2                	mov    %eax,%edx
  801868:	85 c0                	test   %eax,%eax
  80186a:	0f 88 0d 01 00 00    	js     80197d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	e8 29 f6 ff ff       	call   800ea5 <fd_alloc>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	0f 88 e2 00 00 00    	js     80196b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	68 07 04 00 00       	push   $0x407
  801891:	ff 75 f0             	pushl  -0x10(%ebp)
  801894:	6a 00                	push   $0x0
  801896:	e8 82 f3 ff ff       	call   800c1d <sys_page_alloc>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	0f 88 c3 00 00 00    	js     80196b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 db f5 ff ff       	call   800e8e <fd2data>
  8018b3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b5:	83 c4 0c             	add    $0xc,%esp
  8018b8:	68 07 04 00 00       	push   $0x407
  8018bd:	50                   	push   %eax
  8018be:	6a 00                	push   $0x0
  8018c0:	e8 58 f3 ff ff       	call   800c1d <sys_page_alloc>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	0f 88 89 00 00 00    	js     80195b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d8:	e8 b1 f5 ff ff       	call   800e8e <fd2data>
  8018dd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018e4:	50                   	push   %eax
  8018e5:	6a 00                	push   $0x0
  8018e7:	56                   	push   %esi
  8018e8:	6a 00                	push   $0x0
  8018ea:	e8 71 f3 ff ff       	call   800c60 <sys_page_map>
  8018ef:	89 c3                	mov    %eax,%ebx
  8018f1:	83 c4 20             	add    $0x20,%esp
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 55                	js     80194d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018f8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801901:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801903:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801906:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80190d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801913:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801916:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	ff 75 f4             	pushl  -0xc(%ebp)
  801928:	e8 51 f5 ff ff       	call   800e7e <fd2num>
  80192d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801930:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801932:	83 c4 04             	add    $0x4,%esp
  801935:	ff 75 f0             	pushl  -0x10(%ebp)
  801938:	e8 41 f5 ff ff       	call   800e7e <fd2num>
  80193d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801940:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	ba 00 00 00 00       	mov    $0x0,%edx
  80194b:	eb 30                	jmp    80197d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	56                   	push   %esi
  801951:	6a 00                	push   $0x0
  801953:	e8 4a f3 ff ff       	call   800ca2 <sys_page_unmap>
  801958:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80195b:	83 ec 08             	sub    $0x8,%esp
  80195e:	ff 75 f0             	pushl  -0x10(%ebp)
  801961:	6a 00                	push   $0x0
  801963:	e8 3a f3 ff ff       	call   800ca2 <sys_page_unmap>
  801968:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	ff 75 f4             	pushl  -0xc(%ebp)
  801971:	6a 00                	push   $0x0
  801973:	e8 2a f3 ff ff       	call   800ca2 <sys_page_unmap>
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80197d:	89 d0                	mov    %edx,%eax
  80197f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	ff 75 08             	pushl  0x8(%ebp)
  801993:	e8 5c f5 ff ff       	call   800ef4 <fd_lookup>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 18                	js     8019b7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a5:	e8 e4 f4 ff ff       	call   800e8e <fd2data>
	return _pipeisclosed(fd, p);
  8019aa:	89 c2                	mov    %eax,%edx
  8019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019af:	e8 21 fd ff ff       	call   8016d5 <_pipeisclosed>
  8019b4:	83 c4 10             	add    $0x10,%esp
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    

008019c3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019c9:	68 ec 23 80 00       	push   $0x8023ec
  8019ce:	ff 75 0c             	pushl  0xc(%ebp)
  8019d1:	e8 44 ee ff ff       	call   80081a <strcpy>
	return 0;
}
  8019d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	57                   	push   %edi
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f4:	eb 2d                	jmp    801a23 <devcons_write+0x46>
		m = n - tot;
  8019f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019f9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019fb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019fe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a03:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a06:	83 ec 04             	sub    $0x4,%esp
  801a09:	53                   	push   %ebx
  801a0a:	03 45 0c             	add    0xc(%ebp),%eax
  801a0d:	50                   	push   %eax
  801a0e:	57                   	push   %edi
  801a0f:	e8 98 ef ff ff       	call   8009ac <memmove>
		sys_cputs(buf, m);
  801a14:	83 c4 08             	add    $0x8,%esp
  801a17:	53                   	push   %ebx
  801a18:	57                   	push   %edi
  801a19:	e8 43 f1 ff ff       	call   800b61 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a1e:	01 de                	add    %ebx,%esi
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	89 f0                	mov    %esi,%eax
  801a25:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a28:	72 cc                	jb     8019f6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5f                   	pop    %edi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 08             	sub    $0x8,%esp
  801a38:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a41:	74 2a                	je     801a6d <devcons_read+0x3b>
  801a43:	eb 05                	jmp    801a4a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a45:	e8 b4 f1 ff ff       	call   800bfe <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a4a:	e8 30 f1 ff ff       	call   800b7f <sys_cgetc>
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	74 f2                	je     801a45 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 16                	js     801a6d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a57:	83 f8 04             	cmp    $0x4,%eax
  801a5a:	74 0c                	je     801a68 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a5f:	88 02                	mov    %al,(%edx)
	return 1;
  801a61:	b8 01 00 00 00       	mov    $0x1,%eax
  801a66:	eb 05                	jmp    801a6d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a68:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a75:	8b 45 08             	mov    0x8(%ebp),%eax
  801a78:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a7b:	6a 01                	push   $0x1
  801a7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a80:	50                   	push   %eax
  801a81:	e8 db f0 ff ff       	call   800b61 <sys_cputs>
}
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <getchar>:

int
getchar(void)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a91:	6a 01                	push   $0x1
  801a93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a96:	50                   	push   %eax
  801a97:	6a 00                	push   $0x0
  801a99:	e8 bc f6 ff ff       	call   80115a <read>
	if (r < 0)
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	78 0f                	js     801ab4 <getchar+0x29>
		return r;
	if (r < 1)
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	7e 06                	jle    801aaf <getchar+0x24>
		return -E_EOF;
	return c;
  801aa9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801aad:	eb 05                	jmp    801ab4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801aaf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801abc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abf:	50                   	push   %eax
  801ac0:	ff 75 08             	pushl  0x8(%ebp)
  801ac3:	e8 2c f4 ff ff       	call   800ef4 <fd_lookup>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	85 c0                	test   %eax,%eax
  801acd:	78 11                	js     801ae0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad8:	39 10                	cmp    %edx,(%eax)
  801ada:	0f 94 c0             	sete   %al
  801add:	0f b6 c0             	movzbl %al,%eax
}
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <opencons>:

int
opencons(void)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ae8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aeb:	50                   	push   %eax
  801aec:	e8 b4 f3 ff ff       	call   800ea5 <fd_alloc>
  801af1:	83 c4 10             	add    $0x10,%esp
		return r;
  801af4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 3e                	js     801b38 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801afa:	83 ec 04             	sub    $0x4,%esp
  801afd:	68 07 04 00 00       	push   $0x407
  801b02:	ff 75 f4             	pushl  -0xc(%ebp)
  801b05:	6a 00                	push   $0x0
  801b07:	e8 11 f1 ff ff       	call   800c1d <sys_page_alloc>
  801b0c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b0f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 23                	js     801b38 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b23:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	50                   	push   %eax
  801b2e:	e8 4b f3 ff ff       	call   800e7e <fd2num>
  801b33:	89 c2                	mov    %eax,%edx
  801b35:	83 c4 10             	add    $0x10,%esp
}
  801b38:	89 d0                	mov    %edx,%eax
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	8b 75 08             	mov    0x8(%ebp),%esi
  801b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	74 0e                	je     801b5c <ipc_recv+0x20>
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	50                   	push   %eax
  801b52:	e8 76 f2 ff ff       	call   800dcd <sys_ipc_recv>
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	eb 10                	jmp    801b6c <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	68 00 00 c0 ee       	push   $0xeec00000
  801b64:	e8 64 f2 ff ff       	call   800dcd <sys_ipc_recv>
  801b69:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	74 16                	je     801b86 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801b70:	85 f6                	test   %esi,%esi
  801b72:	74 06                	je     801b7a <ipc_recv+0x3e>
  801b74:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801b7a:	85 db                	test   %ebx,%ebx
  801b7c:	74 2c                	je     801baa <ipc_recv+0x6e>
  801b7e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b84:	eb 24                	jmp    801baa <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b86:	85 f6                	test   %esi,%esi
  801b88:	74 0a                	je     801b94 <ipc_recv+0x58>
  801b8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8f:	8b 40 74             	mov    0x74(%eax),%eax
  801b92:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801b94:	85 db                	test   %ebx,%ebx
  801b96:	74 0a                	je     801ba2 <ipc_recv+0x66>
  801b98:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9d:	8b 40 78             	mov    0x78(%eax),%eax
  801ba0:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ba2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	57                   	push   %edi
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801bca:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801bcd:	ff 75 14             	pushl  0x14(%ebp)
  801bd0:	53                   	push   %ebx
  801bd1:	56                   	push   %esi
  801bd2:	57                   	push   %edi
  801bd3:	e8 d2 f1 ff ff       	call   800daa <sys_ipc_try_send>
		if (ret == 0) break;
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	74 1e                	je     801bfd <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801bdf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be2:	74 12                	je     801bf6 <ipc_send+0x45>
  801be4:	50                   	push   %eax
  801be5:	68 f8 23 80 00       	push   $0x8023f8
  801bea:	6a 39                	push   $0x39
  801bec:	68 05 24 80 00       	push   $0x802405
  801bf1:	e8 1f e5 ff ff       	call   800115 <_panic>
		sys_yield();
  801bf6:	e8 03 f0 ff ff       	call   800bfe <sys_yield>
	}
  801bfb:	eb d0                	jmp    801bcd <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c10:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c13:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c19:	8b 52 50             	mov    0x50(%edx),%edx
  801c1c:	39 ca                	cmp    %ecx,%edx
  801c1e:	75 0d                	jne    801c2d <ipc_find_env+0x28>
			return envs[i].env_id;
  801c20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c28:	8b 40 48             	mov    0x48(%eax),%eax
  801c2b:	eb 0f                	jmp    801c3c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2d:	83 c0 01             	add    $0x1,%eax
  801c30:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c35:	75 d9                	jne    801c10 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c44:	89 d0                	mov    %edx,%eax
  801c46:	c1 e8 16             	shr    $0x16,%eax
  801c49:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c50:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c55:	f6 c1 01             	test   $0x1,%cl
  801c58:	74 1d                	je     801c77 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c5a:	c1 ea 0c             	shr    $0xc,%edx
  801c5d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c64:	f6 c2 01             	test   $0x1,%dl
  801c67:	74 0e                	je     801c77 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c69:	c1 ea 0c             	shr    $0xc,%edx
  801c6c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c73:	ef 
  801c74:	0f b7 c0             	movzwl %ax,%eax
}
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__udivdi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 f6                	test   %esi,%esi
  801c99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9d:	89 ca                	mov    %ecx,%edx
  801c9f:	89 f8                	mov    %edi,%eax
  801ca1:	75 3d                	jne    801ce0 <__udivdi3+0x60>
  801ca3:	39 cf                	cmp    %ecx,%edi
  801ca5:	0f 87 c5 00 00 00    	ja     801d70 <__udivdi3+0xf0>
  801cab:	85 ff                	test   %edi,%edi
  801cad:	89 fd                	mov    %edi,%ebp
  801caf:	75 0b                	jne    801cbc <__udivdi3+0x3c>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	31 d2                	xor    %edx,%edx
  801cb8:	f7 f7                	div    %edi
  801cba:	89 c5                	mov    %eax,%ebp
  801cbc:	89 c8                	mov    %ecx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	f7 f5                	div    %ebp
  801cc2:	89 c1                	mov    %eax,%ecx
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	89 cf                	mov    %ecx,%edi
  801cc8:	f7 f5                	div    %ebp
  801cca:	89 c3                	mov    %eax,%ebx
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
  801ce0:	39 ce                	cmp    %ecx,%esi
  801ce2:	77 74                	ja     801d58 <__udivdi3+0xd8>
  801ce4:	0f bd fe             	bsr    %esi,%edi
  801ce7:	83 f7 1f             	xor    $0x1f,%edi
  801cea:	0f 84 98 00 00 00    	je     801d88 <__udivdi3+0x108>
  801cf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	89 c5                	mov    %eax,%ebp
  801cf9:	29 fb                	sub    %edi,%ebx
  801cfb:	d3 e6                	shl    %cl,%esi
  801cfd:	89 d9                	mov    %ebx,%ecx
  801cff:	d3 ed                	shr    %cl,%ebp
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e0                	shl    %cl,%eax
  801d05:	09 ee                	or     %ebp,%esi
  801d07:	89 d9                	mov    %ebx,%ecx
  801d09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0d:	89 d5                	mov    %edx,%ebp
  801d0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d13:	d3 ed                	shr    %cl,%ebp
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e2                	shl    %cl,%edx
  801d19:	89 d9                	mov    %ebx,%ecx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	09 c2                	or     %eax,%edx
  801d1f:	89 d0                	mov    %edx,%eax
  801d21:	89 ea                	mov    %ebp,%edx
  801d23:	f7 f6                	div    %esi
  801d25:	89 d5                	mov    %edx,%ebp
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	f7 64 24 0c          	mull   0xc(%esp)
  801d2d:	39 d5                	cmp    %edx,%ebp
  801d2f:	72 10                	jb     801d41 <__udivdi3+0xc1>
  801d31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e6                	shl    %cl,%esi
  801d39:	39 c6                	cmp    %eax,%esi
  801d3b:	73 07                	jae    801d44 <__udivdi3+0xc4>
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	75 03                	jne    801d44 <__udivdi3+0xc4>
  801d41:	83 eb 01             	sub    $0x1,%ebx
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	31 ff                	xor    %edi,%edi
  801d5a:	31 db                	xor    %ebx,%ebx
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	89 fa                	mov    %edi,%edx
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    
  801d68:	90                   	nop
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	f7 f7                	div    %edi
  801d74:	31 ff                	xor    %edi,%edi
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 fa                	mov    %edi,%edx
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	39 ce                	cmp    %ecx,%esi
  801d8a:	72 0c                	jb     801d98 <__udivdi3+0x118>
  801d8c:	31 db                	xor    %ebx,%ebx
  801d8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d92:	0f 87 34 ff ff ff    	ja     801ccc <__udivdi3+0x4c>
  801d98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d9d:	e9 2a ff ff ff       	jmp    801ccc <__udivdi3+0x4c>
  801da2:	66 90                	xchg   %ax,%ax
  801da4:	66 90                	xchg   %ax,%ax
  801da6:	66 90                	xchg   %ax,%ax
  801da8:	66 90                	xchg   %ax,%ax
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 d2                	test   %edx,%edx
  801dc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dd1:	89 f3                	mov    %esi,%ebx
  801dd3:	89 3c 24             	mov    %edi,(%esp)
  801dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dda:	75 1c                	jne    801df8 <__umoddi3+0x48>
  801ddc:	39 f7                	cmp    %esi,%edi
  801dde:	76 50                	jbe    801e30 <__umoddi3+0x80>
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	f7 f7                	div    %edi
  801de6:	89 d0                	mov    %edx,%eax
  801de8:	31 d2                	xor    %edx,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	39 f2                	cmp    %esi,%edx
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	77 52                	ja     801e50 <__umoddi3+0xa0>
  801dfe:	0f bd ea             	bsr    %edx,%ebp
  801e01:	83 f5 1f             	xor    $0x1f,%ebp
  801e04:	75 5a                	jne    801e60 <__umoddi3+0xb0>
  801e06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	39 0c 24             	cmp    %ecx,(%esp)
  801e13:	0f 86 d7 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e21:	83 c4 1c             	add    $0x1c,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	85 ff                	test   %edi,%edi
  801e32:	89 fd                	mov    %edi,%ebp
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 f0                	mov    %esi,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 c8                	mov    %ecx,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	eb 99                	jmp    801de8 <__umoddi3+0x38>
  801e4f:	90                   	nop
  801e50:	89 c8                	mov    %ecx,%eax
  801e52:	89 f2                	mov    %esi,%edx
  801e54:	83 c4 1c             	add    $0x1c,%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    
  801e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e60:	8b 34 24             	mov    (%esp),%esi
  801e63:	bf 20 00 00 00       	mov    $0x20,%edi
  801e68:	89 e9                	mov    %ebp,%ecx
  801e6a:	29 ef                	sub    %ebp,%edi
  801e6c:	d3 e0                	shl    %cl,%eax
  801e6e:	89 f9                	mov    %edi,%ecx
  801e70:	89 f2                	mov    %esi,%edx
  801e72:	d3 ea                	shr    %cl,%edx
  801e74:	89 e9                	mov    %ebp,%ecx
  801e76:	09 c2                	or     %eax,%edx
  801e78:	89 d8                	mov    %ebx,%eax
  801e7a:	89 14 24             	mov    %edx,(%esp)
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	d3 e2                	shl    %cl,%edx
  801e81:	89 f9                	mov    %edi,%ecx
  801e83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e8b:	d3 e8                	shr    %cl,%eax
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	89 c6                	mov    %eax,%esi
  801e91:	d3 e3                	shl    %cl,%ebx
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 d0                	mov    %edx,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	09 d8                	or     %ebx,%eax
  801e9d:	89 d3                	mov    %edx,%ebx
  801e9f:	89 f2                	mov    %esi,%edx
  801ea1:	f7 34 24             	divl   (%esp)
  801ea4:	89 d6                	mov    %edx,%esi
  801ea6:	d3 e3                	shl    %cl,%ebx
  801ea8:	f7 64 24 04          	mull   0x4(%esp)
  801eac:	39 d6                	cmp    %edx,%esi
  801eae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb2:	89 d1                	mov    %edx,%ecx
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	72 08                	jb     801ec0 <__umoddi3+0x110>
  801eb8:	75 11                	jne    801ecb <__umoddi3+0x11b>
  801eba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ebe:	73 0b                	jae    801ecb <__umoddi3+0x11b>
  801ec0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ec4:	1b 14 24             	sbb    (%esp),%edx
  801ec7:	89 d1                	mov    %edx,%ecx
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ecf:	29 da                	sub    %ebx,%edx
  801ed1:	19 ce                	sbb    %ecx,%esi
  801ed3:	89 f9                	mov    %edi,%ecx
  801ed5:	89 f0                	mov    %esi,%eax
  801ed7:	d3 e0                	shl    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	d3 ea                	shr    %cl,%edx
  801edd:	89 e9                	mov    %ebp,%ecx
  801edf:	d3 ee                	shr    %cl,%esi
  801ee1:	09 d0                	or     %edx,%eax
  801ee3:	89 f2                	mov    %esi,%edx
  801ee5:	83 c4 1c             	add    $0x1c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 f9                	sub    %edi,%ecx
  801ef2:	19 d6                	sbb    %edx,%esi
  801ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801efc:	e9 18 ff ff ff       	jmp    801e19 <__umoddi3+0x69>
