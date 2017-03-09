
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 c0 1e 80 00       	push   $0x801ec0
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 3b 1f 80 00       	push   $0x801f3b
  80005b:	6a 11                	push   $0x11
  80005d:	68 58 1f 80 00       	push   $0x801f58
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 e0 1e 80 00       	push   $0x801ee0
  80009b:	6a 16                	push   $0x16
  80009d:	68 58 1f 80 00       	push   $0x801f58
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 08 1f 80 00       	push   $0x801f08
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 67 1f 80 00       	push   $0x801f67
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 58 1f 80 00       	push   $0x801f58
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000e7:	e8 1a 0b 00 00       	call   800c06 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 d3 0e 00 00       	call   801000 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 8e 0a 00 00       	call   800bc5 <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 b7 0a 00 00       	call   800c06 <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 88 1f 80 00       	push   $0x801f88
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 56 1f 80 00 	movl   $0x801f56,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 d6 09 00 00       	call   800b88 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 1a 01 00 00       	call   800312 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 7b 09 00 00       	call   800b88 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 b3 19 00 00       	call   801c30 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 a0 1a 00 00       	call   801d60 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 ab 1f 80 00 	movsbl 0x801fab(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002de:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e7:	73 0a                	jae    8002f3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	88 02                	mov    %al,(%edx)
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fe:	50                   	push   %eax
  8002ff:	ff 75 10             	pushl  0x10(%ebp)
  800302:	ff 75 0c             	pushl  0xc(%ebp)
  800305:	ff 75 08             	pushl  0x8(%ebp)
  800308:	e8 05 00 00 00       	call   800312 <vprintfmt>
	va_end(ap);
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 2c             	sub    $0x2c,%esp
  80031b:	8b 75 08             	mov    0x8(%ebp),%esi
  80031e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800321:	8b 7d 10             	mov    0x10(%ebp),%edi
  800324:	eb 12                	jmp    800338 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800326:	85 c0                	test   %eax,%eax
  800328:	0f 84 6a 04 00 00    	je     800798 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80032e:	83 ec 08             	sub    $0x8,%esp
  800331:	53                   	push   %ebx
  800332:	50                   	push   %eax
  800333:	ff d6                	call   *%esi
  800335:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800338:	83 c7 01             	add    $0x1,%edi
  80033b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033f:	83 f8 25             	cmp    $0x25,%eax
  800342:	75 e2                	jne    800326 <vprintfmt+0x14>
  800344:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800348:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800356:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	eb 07                	jmp    80036b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8d 47 01             	lea    0x1(%edi),%eax
  80036e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800371:	0f b6 07             	movzbl (%edi),%eax
  800374:	0f b6 d0             	movzbl %al,%edx
  800377:	83 e8 23             	sub    $0x23,%eax
  80037a:	3c 55                	cmp    $0x55,%al
  80037c:	0f 87 fb 03 00 00    	ja     80077d <vprintfmt+0x46b>
  800382:	0f b6 c0             	movzbl %al,%eax
  800385:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d6                	jmp    80036b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	b8 00 00 00 00       	mov    $0x0,%eax
  80039d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003aa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ad:	83 f9 09             	cmp    $0x9,%ecx
  8003b0:	77 3f                	ja     8003f1 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b5:	eb e9                	jmp    8003a0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 40 04             	lea    0x4(%eax),%eax
  8003c5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cb:	eb 2a                	jmp    8003f7 <vprintfmt+0xe5>
  8003cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	0f 49 d0             	cmovns %eax,%edx
  8003da:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e0:	eb 89                	jmp    80036b <vprintfmt+0x59>
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ec:	e9 7a ff ff ff       	jmp    80036b <vprintfmt+0x59>
  8003f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fb:	0f 89 6a ff ff ff    	jns    80036b <vprintfmt+0x59>
				width = precision, precision = -1;
  800401:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800404:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800407:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040e:	e9 58 ff ff ff       	jmp    80036b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800413:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800419:	e9 4d ff ff ff       	jmp    80036b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 78 04             	lea    0x4(%eax),%edi
  800424:	83 ec 08             	sub    $0x8,%esp
  800427:	53                   	push   %ebx
  800428:	ff 30                	pushl  (%eax)
  80042a:	ff d6                	call   *%esi
			break;
  80042c:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800435:	e9 fe fe ff ff       	jmp    800338 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	8b 00                	mov    (%eax),%eax
  800442:	99                   	cltd   
  800443:	31 d0                	xor    %edx,%eax
  800445:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800447:	83 f8 0f             	cmp    $0xf,%eax
  80044a:	7f 0b                	jg     800457 <vprintfmt+0x145>
  80044c:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  800453:	85 d2                	test   %edx,%edx
  800455:	75 1b                	jne    800472 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800457:	50                   	push   %eax
  800458:	68 c3 1f 80 00       	push   $0x801fc3
  80045d:	53                   	push   %ebx
  80045e:	56                   	push   %esi
  80045f:	e8 91 fe ff ff       	call   8002f5 <printfmt>
  800464:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800467:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046d:	e9 c6 fe ff ff       	jmp    800338 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800472:	52                   	push   %edx
  800473:	68 9e 23 80 00       	push   $0x80239e
  800478:	53                   	push   %ebx
  800479:	56                   	push   %esi
  80047a:	e8 76 fe ff ff       	call   8002f5 <printfmt>
  80047f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800482:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800488:	e9 ab fe ff ff       	jmp    800338 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	83 c0 04             	add    $0x4,%eax
  800493:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049b:	85 ff                	test   %edi,%edi
  80049d:	b8 bc 1f 80 00       	mov    $0x801fbc,%eax
  8004a2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a9:	0f 8e 94 00 00 00    	jle    800543 <vprintfmt+0x231>
  8004af:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b3:	0f 84 98 00 00 00    	je     800551 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bf:	57                   	push   %edi
  8004c0:	e8 5b 03 00 00       	call   800820 <strnlen>
  8004c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c8:	29 c1                	sub    %eax,%ecx
  8004ca:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004da:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	eb 0f                	jmp    8004ed <vprintfmt+0x1db>
					putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ef 01             	sub    $0x1,%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f ed                	jg     8004de <vprintfmt+0x1cc>
  8004f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f7:	85 c9                	test   %ecx,%ecx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c1             	cmovns %ecx,%eax
  800501:	29 c1                	sub    %eax,%ecx
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	89 cb                	mov    %ecx,%ebx
  80050e:	eb 4d                	jmp    80055d <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	74 1b                	je     800531 <vprintfmt+0x21f>
  800516:	0f be c0             	movsbl %al,%eax
  800519:	83 e8 20             	sub    $0x20,%eax
  80051c:	83 f8 5e             	cmp    $0x5e,%eax
  80051f:	76 10                	jbe    800531 <vprintfmt+0x21f>
					putch('?', putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	6a 3f                	push   $0x3f
  800529:	ff 55 08             	call   *0x8(%ebp)
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	eb 0d                	jmp    80053e <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	ff 75 0c             	pushl  0xc(%ebp)
  800537:	52                   	push   %edx
  800538:	ff 55 08             	call   *0x8(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	83 eb 01             	sub    $0x1,%ebx
  800541:	eb 1a                	jmp    80055d <vprintfmt+0x24b>
  800543:	89 75 08             	mov    %esi,0x8(%ebp)
  800546:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800549:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054f:	eb 0c                	jmp    80055d <vprintfmt+0x24b>
  800551:	89 75 08             	mov    %esi,0x8(%ebp)
  800554:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800557:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055d:	83 c7 01             	add    $0x1,%edi
  800560:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800564:	0f be d0             	movsbl %al,%edx
  800567:	85 d2                	test   %edx,%edx
  800569:	74 23                	je     80058e <vprintfmt+0x27c>
  80056b:	85 f6                	test   %esi,%esi
  80056d:	78 a1                	js     800510 <vprintfmt+0x1fe>
  80056f:	83 ee 01             	sub    $0x1,%esi
  800572:	79 9c                	jns    800510 <vprintfmt+0x1fe>
  800574:	89 df                	mov    %ebx,%edi
  800576:	8b 75 08             	mov    0x8(%ebp),%esi
  800579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057c:	eb 18                	jmp    800596 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	53                   	push   %ebx
  800582:	6a 20                	push   $0x20
  800584:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800586:	83 ef 01             	sub    $0x1,%edi
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	eb 08                	jmp    800596 <vprintfmt+0x284>
  80058e:	89 df                	mov    %ebx,%edi
  800590:	8b 75 08             	mov    0x8(%ebp),%esi
  800593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800596:	85 ff                	test   %edi,%edi
  800598:	7f e4                	jg     80057e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	e9 90 fd ff ff       	jmp    800338 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a8:	83 f9 01             	cmp    $0x1,%ecx
  8005ab:	7e 19                	jle    8005c6 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 50 04             	mov    0x4(%eax),%edx
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 40 08             	lea    0x8(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c4:	eb 38                	jmp    8005fe <vprintfmt+0x2ec>
	else if (lflag)
  8005c6:	85 c9                	test   %ecx,%ecx
  8005c8:	74 1b                	je     8005e5 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d2:	89 c1                	mov    %eax,%ecx
  8005d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 40 04             	lea    0x4(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e3:	eb 19                	jmp    8005fe <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800601:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800609:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060d:	0f 89 36 01 00 00    	jns    800749 <vprintfmt+0x437>
				putch('-', putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 2d                	push   $0x2d
  800619:	ff d6                	call   *%esi
				num = -(long long) num;
  80061b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800621:	f7 da                	neg    %edx
  800623:	83 d1 00             	adc    $0x0,%ecx
  800626:	f7 d9                	neg    %ecx
  800628:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800630:	e9 14 01 00 00       	jmp    800749 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 18                	jle    800652 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	8b 48 04             	mov    0x4(%eax),%ecx
  800642:	8d 40 08             	lea    0x8(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800648:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064d:	e9 f7 00 00 00       	jmp    800749 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	74 1a                	je     800670 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800660:	8d 40 04             	lea    0x4(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 d9 00 00 00       	jmp    800749 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800680:	b8 0a 00 00 00       	mov    $0xa,%eax
  800685:	e9 bf 00 00 00       	jmp    800749 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068a:	83 f9 01             	cmp    $0x1,%ecx
  80068d:	7e 13                	jle    8006a2 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 50 04             	mov    0x4(%eax),%edx
  800695:	8b 00                	mov    (%eax),%eax
  800697:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80069a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80069d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006a0:	eb 28                	jmp    8006ca <vprintfmt+0x3b8>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 13                	je     8006b9 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	89 d0                	mov    %edx,%eax
  8006ad:	99                   	cltd   
  8006ae:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006b1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006b4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b7:	eb 11                	jmp    8006ca <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	89 d0                	mov    %edx,%eax
  8006c0:	99                   	cltd   
  8006c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8006ca:	89 d1                	mov    %edx,%ecx
  8006cc:	89 c2                	mov    %eax,%edx
			base = 8;
  8006ce:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006d3:	eb 74                	jmp    800749 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	6a 30                	push   $0x30
  8006db:	ff d6                	call   *%esi
			putch('x', putdat);
  8006dd:	83 c4 08             	add    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 78                	push   $0x78
  8006e3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ef:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006fd:	eb 4a                	jmp    800749 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 15                	jle    800719 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800712:	b8 10 00 00 00       	mov    $0x10,%eax
  800717:	eb 30                	jmp    800749 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800719:	85 c9                	test   %ecx,%ecx
  80071b:	74 17                	je     800734 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
  800732:	eb 15                	jmp    800749 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800744:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800749:	83 ec 0c             	sub    $0xc,%esp
  80074c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800750:	57                   	push   %edi
  800751:	ff 75 e0             	pushl  -0x20(%ebp)
  800754:	50                   	push   %eax
  800755:	51                   	push   %ecx
  800756:	52                   	push   %edx
  800757:	89 da                	mov    %ebx,%edx
  800759:	89 f0                	mov    %esi,%eax
  80075b:	e8 c9 fa ff ff       	call   800229 <printnum>
			break;
  800760:	83 c4 20             	add    $0x20,%esp
  800763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800766:	e9 cd fb ff ff       	jmp    800338 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	52                   	push   %edx
  800770:	ff d6                	call   *%esi
			break;
  800772:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800778:	e9 bb fb ff ff       	jmp    800338 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 25                	push   $0x25
  800783:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	eb 03                	jmp    80078d <vprintfmt+0x47b>
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800791:	75 f7                	jne    80078a <vprintfmt+0x478>
  800793:	e9 a0 fb ff ff       	jmp    800338 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800798:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5f                   	pop    %edi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 18             	sub    $0x18,%esp
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	74 26                	je     8007e7 <vsnprintf+0x47>
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	7e 22                	jle    8007e7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c5:	ff 75 14             	pushl  0x14(%ebp)
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ce:	50                   	push   %eax
  8007cf:	68 d8 02 80 00       	push   $0x8002d8
  8007d4:	e8 39 fb ff ff       	call   800312 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	eb 05                	jmp    8007ec <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f7:	50                   	push   %eax
  8007f8:	ff 75 10             	pushl  0x10(%ebp)
  8007fb:	ff 75 0c             	pushl  0xc(%ebp)
  8007fe:	ff 75 08             	pushl  0x8(%ebp)
  800801:	e8 9a ff ff ff       	call   8007a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	eb 03                	jmp    800818 <strlen+0x10>
		n++;
  800815:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800818:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081c:	75 f7                	jne    800815 <strlen+0xd>
		n++;
	return n;
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800829:	ba 00 00 00 00       	mov    $0x0,%edx
  80082e:	eb 03                	jmp    800833 <strnlen+0x13>
		n++;
  800830:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800833:	39 c2                	cmp    %eax,%edx
  800835:	74 08                	je     80083f <strnlen+0x1f>
  800837:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80083b:	75 f3                	jne    800830 <strnlen+0x10>
  80083d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	53                   	push   %ebx
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	83 c2 01             	add    $0x1,%edx
  800850:	83 c1 01             	add    $0x1,%ecx
  800853:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800857:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085a:	84 db                	test   %bl,%bl
  80085c:	75 ef                	jne    80084d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80085e:	5b                   	pop    %ebx
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800868:	53                   	push   %ebx
  800869:	e8 9a ff ff ff       	call   800808 <strlen>
  80086e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	01 d8                	add    %ebx,%eax
  800876:	50                   	push   %eax
  800877:	e8 c5 ff ff ff       	call   800841 <strcpy>
	return dst;
}
  80087c:	89 d8                	mov    %ebx,%eax
  80087e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 75 08             	mov    0x8(%ebp),%esi
  80088b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088e:	89 f3                	mov    %esi,%ebx
  800890:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800893:	89 f2                	mov    %esi,%edx
  800895:	eb 0f                	jmp    8008a6 <strncpy+0x23>
		*dst++ = *src;
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	0f b6 01             	movzbl (%ecx),%eax
  80089d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a6:	39 da                	cmp    %ebx,%edx
  8008a8:	75 ed                	jne    800897 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008aa:	89 f0                	mov    %esi,%eax
  8008ac:	5b                   	pop    %ebx
  8008ad:	5e                   	pop    %esi
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	56                   	push   %esi
  8008b4:	53                   	push   %ebx
  8008b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8008be:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c0:	85 d2                	test   %edx,%edx
  8008c2:	74 21                	je     8008e5 <strlcpy+0x35>
  8008c4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c8:	89 f2                	mov    %esi,%edx
  8008ca:	eb 09                	jmp    8008d5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d5:	39 c2                	cmp    %eax,%edx
  8008d7:	74 09                	je     8008e2 <strlcpy+0x32>
  8008d9:	0f b6 19             	movzbl (%ecx),%ebx
  8008dc:	84 db                	test   %bl,%bl
  8008de:	75 ec                	jne    8008cc <strlcpy+0x1c>
  8008e0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e5:	29 f0                	sub    %esi,%eax
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5e                   	pop    %esi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f4:	eb 06                	jmp    8008fc <strcmp+0x11>
		p++, q++;
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fc:	0f b6 01             	movzbl (%ecx),%eax
  8008ff:	84 c0                	test   %al,%al
  800901:	74 04                	je     800907 <strcmp+0x1c>
  800903:	3a 02                	cmp    (%edx),%al
  800905:	74 ef                	je     8008f6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 c0             	movzbl %al,%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091b:	89 c3                	mov    %eax,%ebx
  80091d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800920:	eb 06                	jmp    800928 <strncmp+0x17>
		n--, p++, q++;
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800928:	39 d8                	cmp    %ebx,%eax
  80092a:	74 15                	je     800941 <strncmp+0x30>
  80092c:	0f b6 08             	movzbl (%eax),%ecx
  80092f:	84 c9                	test   %cl,%cl
  800931:	74 04                	je     800937 <strncmp+0x26>
  800933:	3a 0a                	cmp    (%edx),%cl
  800935:	74 eb                	je     800922 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800937:	0f b6 00             	movzbl (%eax),%eax
  80093a:	0f b6 12             	movzbl (%edx),%edx
  80093d:	29 d0                	sub    %edx,%eax
  80093f:	eb 05                	jmp    800946 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800946:	5b                   	pop    %ebx
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800953:	eb 07                	jmp    80095c <strchr+0x13>
		if (*s == c)
  800955:	38 ca                	cmp    %cl,%dl
  800957:	74 0f                	je     800968 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	0f b6 10             	movzbl (%eax),%edx
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f2                	jne    800955 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800974:	eb 03                	jmp    800979 <strfind+0xf>
  800976:	83 c0 01             	add    $0x1,%eax
  800979:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	74 04                	je     800984 <strfind+0x1a>
  800980:	84 d2                	test   %dl,%dl
  800982:	75 f2                	jne    800976 <strfind+0xc>
			break;
	return (char *) s;
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800992:	85 c9                	test   %ecx,%ecx
  800994:	74 36                	je     8009cc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800996:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099c:	75 28                	jne    8009c6 <memset+0x40>
  80099e:	f6 c1 03             	test   $0x3,%cl
  8009a1:	75 23                	jne    8009c6 <memset+0x40>
		c &= 0xFF;
  8009a3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a7:	89 d3                	mov    %edx,%ebx
  8009a9:	c1 e3 08             	shl    $0x8,%ebx
  8009ac:	89 d6                	mov    %edx,%esi
  8009ae:	c1 e6 18             	shl    $0x18,%esi
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c1 e0 10             	shl    $0x10,%eax
  8009b6:	09 f0                	or     %esi,%eax
  8009b8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ba:	89 d8                	mov    %ebx,%eax
  8009bc:	09 d0                	or     %edx,%eax
  8009be:	c1 e9 02             	shr    $0x2,%ecx
  8009c1:	fc                   	cld    
  8009c2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c4:	eb 06                	jmp    8009cc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c9:	fc                   	cld    
  8009ca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cc:	89 f8                	mov    %edi,%eax
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e1:	39 c6                	cmp    %eax,%esi
  8009e3:	73 35                	jae    800a1a <memmove+0x47>
  8009e5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e8:	39 d0                	cmp    %edx,%eax
  8009ea:	73 2e                	jae    800a1a <memmove+0x47>
		s += n;
		d += n;
  8009ec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ef:	89 d6                	mov    %edx,%esi
  8009f1:	09 fe                	or     %edi,%esi
  8009f3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f9:	75 13                	jne    800a0e <memmove+0x3b>
  8009fb:	f6 c1 03             	test   $0x3,%cl
  8009fe:	75 0e                	jne    800a0e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a00:	83 ef 04             	sub    $0x4,%edi
  800a03:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a06:	c1 e9 02             	shr    $0x2,%ecx
  800a09:	fd                   	std    
  800a0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0c:	eb 09                	jmp    800a17 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0e:	83 ef 01             	sub    $0x1,%edi
  800a11:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a14:	fd                   	std    
  800a15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a17:	fc                   	cld    
  800a18:	eb 1d                	jmp    800a37 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	89 f2                	mov    %esi,%edx
  800a1c:	09 c2                	or     %eax,%edx
  800a1e:	f6 c2 03             	test   $0x3,%dl
  800a21:	75 0f                	jne    800a32 <memmove+0x5f>
  800a23:	f6 c1 03             	test   $0x3,%cl
  800a26:	75 0a                	jne    800a32 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a28:	c1 e9 02             	shr    $0x2,%ecx
  800a2b:	89 c7                	mov    %eax,%edi
  800a2d:	fc                   	cld    
  800a2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a30:	eb 05                	jmp    800a37 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a32:	89 c7                	mov    %eax,%edi
  800a34:	fc                   	cld    
  800a35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3e:	ff 75 10             	pushl  0x10(%ebp)
  800a41:	ff 75 0c             	pushl  0xc(%ebp)
  800a44:	ff 75 08             	pushl  0x8(%ebp)
  800a47:	e8 87 ff ff ff       	call   8009d3 <memmove>
}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a59:	89 c6                	mov    %eax,%esi
  800a5b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5e:	eb 1a                	jmp    800a7a <memcmp+0x2c>
		if (*s1 != *s2)
  800a60:	0f b6 08             	movzbl (%eax),%ecx
  800a63:	0f b6 1a             	movzbl (%edx),%ebx
  800a66:	38 d9                	cmp    %bl,%cl
  800a68:	74 0a                	je     800a74 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a6a:	0f b6 c1             	movzbl %cl,%eax
  800a6d:	0f b6 db             	movzbl %bl,%ebx
  800a70:	29 d8                	sub    %ebx,%eax
  800a72:	eb 0f                	jmp    800a83 <memcmp+0x35>
		s1++, s2++;
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7a:	39 f0                	cmp    %esi,%eax
  800a7c:	75 e2                	jne    800a60 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a8e:	89 c1                	mov    %eax,%ecx
  800a90:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a93:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a97:	eb 0a                	jmp    800aa3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a99:	0f b6 10             	movzbl (%eax),%edx
  800a9c:	39 da                	cmp    %ebx,%edx
  800a9e:	74 07                	je     800aa7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	39 c8                	cmp    %ecx,%eax
  800aa5:	72 f2                	jb     800a99 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab6:	eb 03                	jmp    800abb <strtol+0x11>
		s++;
  800ab8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abb:	0f b6 01             	movzbl (%ecx),%eax
  800abe:	3c 20                	cmp    $0x20,%al
  800ac0:	74 f6                	je     800ab8 <strtol+0xe>
  800ac2:	3c 09                	cmp    $0x9,%al
  800ac4:	74 f2                	je     800ab8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac6:	3c 2b                	cmp    $0x2b,%al
  800ac8:	75 0a                	jne    800ad4 <strtol+0x2a>
		s++;
  800aca:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad2:	eb 11                	jmp    800ae5 <strtol+0x3b>
  800ad4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad9:	3c 2d                	cmp    $0x2d,%al
  800adb:	75 08                	jne    800ae5 <strtol+0x3b>
		s++, neg = 1;
  800add:	83 c1 01             	add    $0x1,%ecx
  800ae0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aeb:	75 15                	jne    800b02 <strtol+0x58>
  800aed:	80 39 30             	cmpb   $0x30,(%ecx)
  800af0:	75 10                	jne    800b02 <strtol+0x58>
  800af2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af6:	75 7c                	jne    800b74 <strtol+0xca>
		s += 2, base = 16;
  800af8:	83 c1 02             	add    $0x2,%ecx
  800afb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b00:	eb 16                	jmp    800b18 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b02:	85 db                	test   %ebx,%ebx
  800b04:	75 12                	jne    800b18 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b06:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0e:	75 08                	jne    800b18 <strtol+0x6e>
		s++, base = 8;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b20:	0f b6 11             	movzbl (%ecx),%edx
  800b23:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b26:	89 f3                	mov    %esi,%ebx
  800b28:	80 fb 09             	cmp    $0x9,%bl
  800b2b:	77 08                	ja     800b35 <strtol+0x8b>
			dig = *s - '0';
  800b2d:	0f be d2             	movsbl %dl,%edx
  800b30:	83 ea 30             	sub    $0x30,%edx
  800b33:	eb 22                	jmp    800b57 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b35:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b38:	89 f3                	mov    %esi,%ebx
  800b3a:	80 fb 19             	cmp    $0x19,%bl
  800b3d:	77 08                	ja     800b47 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b3f:	0f be d2             	movsbl %dl,%edx
  800b42:	83 ea 57             	sub    $0x57,%edx
  800b45:	eb 10                	jmp    800b57 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b47:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4a:	89 f3                	mov    %esi,%ebx
  800b4c:	80 fb 19             	cmp    $0x19,%bl
  800b4f:	77 16                	ja     800b67 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b51:	0f be d2             	movsbl %dl,%edx
  800b54:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b57:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5a:	7d 0b                	jge    800b67 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b63:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b65:	eb b9                	jmp    800b20 <strtol+0x76>

	if (endptr)
  800b67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6b:	74 0d                	je     800b7a <strtol+0xd0>
		*endptr = (char *) s;
  800b6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b70:	89 0e                	mov    %ecx,(%esi)
  800b72:	eb 06                	jmp    800b7a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b74:	85 db                	test   %ebx,%ebx
  800b76:	74 98                	je     800b10 <strtol+0x66>
  800b78:	eb 9e                	jmp    800b18 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b7a:	89 c2                	mov    %eax,%edx
  800b7c:	f7 da                	neg    %edx
  800b7e:	85 ff                	test   %edi,%edi
  800b80:	0f 45 c2             	cmovne %edx,%eax
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	89 c7                	mov    %eax,%edi
  800b9d:	89 c6                	mov    %eax,%esi
  800b9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb6:	89 d1                	mov    %edx,%ecx
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 cb                	mov    %ecx,%ebx
  800bdd:	89 cf                	mov    %ecx,%edi
  800bdf:	89 ce                	mov    %ecx,%esi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 03                	push   $0x3
  800bed:	68 9f 22 80 00       	push   $0x80229f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 bc 22 80 00       	push   $0x8022bc
  800bf9:	e8 3e f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	b8 02 00 00 00       	mov    $0x2,%eax
  800c16:	89 d1                	mov    %edx,%ecx
  800c18:	89 d3                	mov    %edx,%ebx
  800c1a:	89 d7                	mov    %edx,%edi
  800c1c:	89 d6                	mov    %edx,%esi
  800c1e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_yield>:

void
sys_yield(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	be 00 00 00 00       	mov    $0x0,%esi
  800c52:	b8 04 00 00 00       	mov    $0x4,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c60:	89 f7                	mov    %esi,%edi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 04                	push   $0x4
  800c6e:	68 9f 22 80 00       	push   $0x80229f
  800c73:	6a 23                	push   $0x23
  800c75:	68 bc 22 80 00       	push   $0x8022bc
  800c7a:	e8 bd f4 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	b8 05 00 00 00       	mov    $0x5,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca1:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 05                	push   $0x5
  800cb0:	68 9f 22 80 00       	push   $0x80229f
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 bc 22 80 00       	push   $0x8022bc
  800cbc:	e8 7b f4 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 df                	mov    %ebx,%edi
  800ce4:	89 de                	mov    %ebx,%esi
  800ce6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 17                	jle    800d03 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 06                	push   $0x6
  800cf2:	68 9f 22 80 00       	push   $0x80229f
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 bc 22 80 00       	push   $0x8022bc
  800cfe:	e8 39 f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d19:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 df                	mov    %ebx,%edi
  800d26:	89 de                	mov    %ebx,%esi
  800d28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 08                	push   $0x8
  800d34:	68 9f 22 80 00       	push   $0x80229f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 bc 22 80 00       	push   $0x8022bc
  800d40:	e8 f7 f3 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 df                	mov    %ebx,%edi
  800d68:	89 de                	mov    %ebx,%esi
  800d6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7e 17                	jle    800d87 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	50                   	push   %eax
  800d74:	6a 09                	push   $0x9
  800d76:	68 9f 22 80 00       	push   $0x80229f
  800d7b:	6a 23                	push   $0x23
  800d7d:	68 bc 22 80 00       	push   $0x8022bc
  800d82:	e8 b5 f3 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	89 df                	mov    %ebx,%edi
  800daa:	89 de                	mov    %ebx,%esi
  800dac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dae:	85 c0                	test   %eax,%eax
  800db0:	7e 17                	jle    800dc9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	50                   	push   %eax
  800db6:	6a 0a                	push   $0xa
  800db8:	68 9f 22 80 00       	push   $0x80229f
  800dbd:	6a 23                	push   $0x23
  800dbf:	68 bc 22 80 00       	push   $0x8022bc
  800dc4:	e8 73 f3 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	be 00 00 00 00       	mov    $0x0,%esi
  800ddc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ded:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e02:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	89 cb                	mov    %ecx,%ebx
  800e0c:	89 cf                	mov    %ecx,%edi
  800e0e:	89 ce                	mov    %ecx,%esi
  800e10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 17                	jle    800e2d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 0d                	push   $0xd
  800e1c:	68 9f 22 80 00       	push   $0x80229f
  800e21:	6a 23                	push   $0x23
  800e23:	68 bc 22 80 00       	push   $0x8022bc
  800e28:	e8 0f f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e40:	c1 e8 0c             	shr    $0xc,%eax
}
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e48:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e55:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e62:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	c1 ea 16             	shr    $0x16,%edx
  800e6c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e73:	f6 c2 01             	test   $0x1,%dl
  800e76:	74 11                	je     800e89 <fd_alloc+0x2d>
  800e78:	89 c2                	mov    %eax,%edx
  800e7a:	c1 ea 0c             	shr    $0xc,%edx
  800e7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e84:	f6 c2 01             	test   $0x1,%dl
  800e87:	75 09                	jne    800e92 <fd_alloc+0x36>
			*fd_store = fd;
  800e89:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	eb 17                	jmp    800ea9 <fd_alloc+0x4d>
  800e92:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e97:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e9c:	75 c9                	jne    800e67 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e9e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb1:	83 f8 1f             	cmp    $0x1f,%eax
  800eb4:	77 36                	ja     800eec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb6:	c1 e0 0c             	shl    $0xc,%eax
  800eb9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ebe:	89 c2                	mov    %eax,%edx
  800ec0:	c1 ea 16             	shr    $0x16,%edx
  800ec3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eca:	f6 c2 01             	test   $0x1,%dl
  800ecd:	74 24                	je     800ef3 <fd_lookup+0x48>
  800ecf:	89 c2                	mov    %eax,%edx
  800ed1:	c1 ea 0c             	shr    $0xc,%edx
  800ed4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edb:	f6 c2 01             	test   $0x1,%dl
  800ede:	74 1a                	je     800efa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee3:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eea:	eb 13                	jmp    800eff <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef1:	eb 0c                	jmp    800eff <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef8:	eb 05                	jmp    800eff <fd_lookup+0x54>
  800efa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0a:	ba 4c 23 80 00       	mov    $0x80234c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0f:	eb 13                	jmp    800f24 <dev_lookup+0x23>
  800f11:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f14:	39 08                	cmp    %ecx,(%eax)
  800f16:	75 0c                	jne    800f24 <dev_lookup+0x23>
			*dev = devtab[i];
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	eb 2e                	jmp    800f52 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f24:	8b 02                	mov    (%edx),%eax
  800f26:	85 c0                	test   %eax,%eax
  800f28:	75 e7                	jne    800f11 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f2a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f2f:	8b 40 48             	mov    0x48(%eax),%eax
  800f32:	83 ec 04             	sub    $0x4,%esp
  800f35:	51                   	push   %ecx
  800f36:	50                   	push   %eax
  800f37:	68 cc 22 80 00       	push   $0x8022cc
  800f3c:	e8 d4 f2 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800f41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	83 ec 10             	sub    $0x10,%esp
  800f5c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f65:	50                   	push   %eax
  800f66:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f6c:	c1 e8 0c             	shr    $0xc,%eax
  800f6f:	50                   	push   %eax
  800f70:	e8 36 ff ff ff       	call   800eab <fd_lookup>
  800f75:	83 c4 08             	add    $0x8,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 05                	js     800f81 <fd_close+0x2d>
	    || fd != fd2)
  800f7c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7f:	74 0c                	je     800f8d <fd_close+0x39>
		return (must_exist ? r : 0);
  800f81:	84 db                	test   %bl,%bl
  800f83:	ba 00 00 00 00       	mov    $0x0,%edx
  800f88:	0f 44 c2             	cmove  %edx,%eax
  800f8b:	eb 41                	jmp    800fce <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	ff 36                	pushl  (%esi)
  800f96:	e8 66 ff ff ff       	call   800f01 <dev_lookup>
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 1a                	js     800fbe <fd_close+0x6a>
		if (dev->dev_close)
  800fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	74 0b                	je     800fbe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	56                   	push   %esi
  800fb7:	ff d0                	call   *%eax
  800fb9:	89 c3                	mov    %eax,%ebx
  800fbb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	56                   	push   %esi
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 00 fd ff ff       	call   800cc9 <sys_page_unmap>
	return r;
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	89 d8                	mov    %ebx,%eax
}
  800fce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fde:	50                   	push   %eax
  800fdf:	ff 75 08             	pushl  0x8(%ebp)
  800fe2:	e8 c4 fe ff ff       	call   800eab <fd_lookup>
  800fe7:	83 c4 08             	add    $0x8,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 10                	js     800ffe <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	6a 01                	push   $0x1
  800ff3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff6:	e8 59 ff ff ff       	call   800f54 <fd_close>
  800ffb:	83 c4 10             	add    $0x10,%esp
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <close_all>:

void
close_all(void)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	53                   	push   %ebx
  801004:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801007:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	53                   	push   %ebx
  801010:	e8 c0 ff ff ff       	call   800fd5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801015:	83 c3 01             	add    $0x1,%ebx
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	83 fb 20             	cmp    $0x20,%ebx
  80101e:	75 ec                	jne    80100c <close_all+0xc>
		close(i);
}
  801020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801023:	c9                   	leave  
  801024:	c3                   	ret    

00801025 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	57                   	push   %edi
  801029:	56                   	push   %esi
  80102a:	53                   	push   %ebx
  80102b:	83 ec 2c             	sub    $0x2c,%esp
  80102e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801031:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	ff 75 08             	pushl  0x8(%ebp)
  801038:	e8 6e fe ff ff       	call   800eab <fd_lookup>
  80103d:	83 c4 08             	add    $0x8,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	0f 88 c1 00 00 00    	js     801109 <dup+0xe4>
		return r;
	close(newfdnum);
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	56                   	push   %esi
  80104c:	e8 84 ff ff ff       	call   800fd5 <close>

	newfd = INDEX2FD(newfdnum);
  801051:	89 f3                	mov    %esi,%ebx
  801053:	c1 e3 0c             	shl    $0xc,%ebx
  801056:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80105c:	83 c4 04             	add    $0x4,%esp
  80105f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801062:	e8 de fd ff ff       	call   800e45 <fd2data>
  801067:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801069:	89 1c 24             	mov    %ebx,(%esp)
  80106c:	e8 d4 fd ff ff       	call   800e45 <fd2data>
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801077:	89 f8                	mov    %edi,%eax
  801079:	c1 e8 16             	shr    $0x16,%eax
  80107c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801083:	a8 01                	test   $0x1,%al
  801085:	74 37                	je     8010be <dup+0x99>
  801087:	89 f8                	mov    %edi,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801093:	f6 c2 01             	test   $0x1,%dl
  801096:	74 26                	je     8010be <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801098:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a7:	50                   	push   %eax
  8010a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ab:	6a 00                	push   $0x0
  8010ad:	57                   	push   %edi
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 d2 fb ff ff       	call   800c87 <sys_page_map>
  8010b5:	89 c7                	mov    %eax,%edi
  8010b7:	83 c4 20             	add    $0x20,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 2e                	js     8010ec <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010c1:	89 d0                	mov    %edx,%eax
  8010c3:	c1 e8 0c             	shr    $0xc,%eax
  8010c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d5:	50                   	push   %eax
  8010d6:	53                   	push   %ebx
  8010d7:	6a 00                	push   $0x0
  8010d9:	52                   	push   %edx
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 a6 fb ff ff       	call   800c87 <sys_page_map>
  8010e1:	89 c7                	mov    %eax,%edi
  8010e3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e8:	85 ff                	test   %edi,%edi
  8010ea:	79 1d                	jns    801109 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	53                   	push   %ebx
  8010f0:	6a 00                	push   $0x0
  8010f2:	e8 d2 fb ff ff       	call   800cc9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f7:	83 c4 08             	add    $0x8,%esp
  8010fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010fd:	6a 00                	push   $0x0
  8010ff:	e8 c5 fb ff ff       	call   800cc9 <sys_page_unmap>
	return r;
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	89 f8                	mov    %edi,%eax
}
  801109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110c:	5b                   	pop    %ebx
  80110d:	5e                   	pop    %esi
  80110e:	5f                   	pop    %edi
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	53                   	push   %ebx
  801115:	83 ec 14             	sub    $0x14,%esp
  801118:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	53                   	push   %ebx
  801120:	e8 86 fd ff ff       	call   800eab <fd_lookup>
  801125:	83 c4 08             	add    $0x8,%esp
  801128:	89 c2                	mov    %eax,%edx
  80112a:	85 c0                	test   %eax,%eax
  80112c:	78 6d                	js     80119b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801138:	ff 30                	pushl  (%eax)
  80113a:	e8 c2 fd ff ff       	call   800f01 <dev_lookup>
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	85 c0                	test   %eax,%eax
  801144:	78 4c                	js     801192 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801146:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801149:	8b 42 08             	mov    0x8(%edx),%eax
  80114c:	83 e0 03             	and    $0x3,%eax
  80114f:	83 f8 01             	cmp    $0x1,%eax
  801152:	75 21                	jne    801175 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801154:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801159:	8b 40 48             	mov    0x48(%eax),%eax
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	53                   	push   %ebx
  801160:	50                   	push   %eax
  801161:	68 10 23 80 00       	push   $0x802310
  801166:	e8 aa f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801173:	eb 26                	jmp    80119b <read+0x8a>
	}
	if (!dev->dev_read)
  801175:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801178:	8b 40 08             	mov    0x8(%eax),%eax
  80117b:	85 c0                	test   %eax,%eax
  80117d:	74 17                	je     801196 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	ff 75 10             	pushl  0x10(%ebp)
  801185:	ff 75 0c             	pushl  0xc(%ebp)
  801188:	52                   	push   %edx
  801189:	ff d0                	call   *%eax
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb 09                	jmp    80119b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801192:	89 c2                	mov    %eax,%edx
  801194:	eb 05                	jmp    80119b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801196:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80119b:	89 d0                	mov    %edx,%eax
  80119d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a0:	c9                   	leave  
  8011a1:	c3                   	ret    

008011a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	57                   	push   %edi
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 0c             	sub    $0xc,%esp
  8011ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b6:	eb 21                	jmp    8011d9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	89 f0                	mov    %esi,%eax
  8011bd:	29 d8                	sub    %ebx,%eax
  8011bf:	50                   	push   %eax
  8011c0:	89 d8                	mov    %ebx,%eax
  8011c2:	03 45 0c             	add    0xc(%ebp),%eax
  8011c5:	50                   	push   %eax
  8011c6:	57                   	push   %edi
  8011c7:	e8 45 ff ff ff       	call   801111 <read>
		if (m < 0)
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 10                	js     8011e3 <readn+0x41>
			return m;
		if (m == 0)
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 0a                	je     8011e1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d7:	01 c3                	add    %eax,%ebx
  8011d9:	39 f3                	cmp    %esi,%ebx
  8011db:	72 db                	jb     8011b8 <readn+0x16>
  8011dd:	89 d8                	mov    %ebx,%eax
  8011df:	eb 02                	jmp    8011e3 <readn+0x41>
  8011e1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 14             	sub    $0x14,%esp
  8011f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	53                   	push   %ebx
  8011fa:	e8 ac fc ff ff       	call   800eab <fd_lookup>
  8011ff:	83 c4 08             	add    $0x8,%esp
  801202:	89 c2                	mov    %eax,%edx
  801204:	85 c0                	test   %eax,%eax
  801206:	78 68                	js     801270 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801208:	83 ec 08             	sub    $0x8,%esp
  80120b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120e:	50                   	push   %eax
  80120f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801212:	ff 30                	pushl  (%eax)
  801214:	e8 e8 fc ff ff       	call   800f01 <dev_lookup>
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 47                	js     801267 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801223:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801227:	75 21                	jne    80124a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801229:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80122e:	8b 40 48             	mov    0x48(%eax),%eax
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	53                   	push   %ebx
  801235:	50                   	push   %eax
  801236:	68 2c 23 80 00       	push   $0x80232c
  80123b:	e8 d5 ef ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801248:	eb 26                	jmp    801270 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80124a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124d:	8b 52 0c             	mov    0xc(%edx),%edx
  801250:	85 d2                	test   %edx,%edx
  801252:	74 17                	je     80126b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801254:	83 ec 04             	sub    $0x4,%esp
  801257:	ff 75 10             	pushl  0x10(%ebp)
  80125a:	ff 75 0c             	pushl  0xc(%ebp)
  80125d:	50                   	push   %eax
  80125e:	ff d2                	call   *%edx
  801260:	89 c2                	mov    %eax,%edx
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	eb 09                	jmp    801270 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801267:	89 c2                	mov    %eax,%edx
  801269:	eb 05                	jmp    801270 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80126b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801270:	89 d0                	mov    %edx,%eax
  801272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <seek>:

int
seek(int fdnum, off_t offset)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	ff 75 08             	pushl  0x8(%ebp)
  801284:	e8 22 fc ff ff       	call   800eab <fd_lookup>
  801289:	83 c4 08             	add    $0x8,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 0e                	js     80129e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801290:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801293:	8b 55 0c             	mov    0xc(%ebp),%edx
  801296:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 14             	sub    $0x14,%esp
  8012a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	53                   	push   %ebx
  8012af:	e8 f7 fb ff ff       	call   800eab <fd_lookup>
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 65                	js     801322 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c3:	50                   	push   %eax
  8012c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c7:	ff 30                	pushl  (%eax)
  8012c9:	e8 33 fc ff ff       	call   800f01 <dev_lookup>
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	78 44                	js     801319 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012dc:	75 21                	jne    8012ff <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012de:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e3:	8b 40 48             	mov    0x48(%eax),%eax
  8012e6:	83 ec 04             	sub    $0x4,%esp
  8012e9:	53                   	push   %ebx
  8012ea:	50                   	push   %eax
  8012eb:	68 ec 22 80 00       	push   $0x8022ec
  8012f0:	e8 20 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012fd:	eb 23                	jmp    801322 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801302:	8b 52 18             	mov    0x18(%edx),%edx
  801305:	85 d2                	test   %edx,%edx
  801307:	74 14                	je     80131d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	ff 75 0c             	pushl  0xc(%ebp)
  80130f:	50                   	push   %eax
  801310:	ff d2                	call   *%edx
  801312:	89 c2                	mov    %eax,%edx
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	eb 09                	jmp    801322 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801319:	89 c2                	mov    %eax,%edx
  80131b:	eb 05                	jmp    801322 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80131d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801322:	89 d0                	mov    %edx,%eax
  801324:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801327:	c9                   	leave  
  801328:	c3                   	ret    

00801329 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	53                   	push   %ebx
  80132d:	83 ec 14             	sub    $0x14,%esp
  801330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801333:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 75 08             	pushl  0x8(%ebp)
  80133a:	e8 6c fb ff ff       	call   800eab <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	89 c2                	mov    %eax,%edx
  801344:	85 c0                	test   %eax,%eax
  801346:	78 58                	js     8013a0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134e:	50                   	push   %eax
  80134f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801352:	ff 30                	pushl  (%eax)
  801354:	e8 a8 fb ff ff       	call   800f01 <dev_lookup>
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 37                	js     801397 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801363:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801367:	74 32                	je     80139b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801369:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80136c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801373:	00 00 00 
	stat->st_isdir = 0;
  801376:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80137d:	00 00 00 
	stat->st_dev = dev;
  801380:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	53                   	push   %ebx
  80138a:	ff 75 f0             	pushl  -0x10(%ebp)
  80138d:	ff 50 14             	call   *0x14(%eax)
  801390:	89 c2                	mov    %eax,%edx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	eb 09                	jmp    8013a0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801397:	89 c2                	mov    %eax,%edx
  801399:	eb 05                	jmp    8013a0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80139b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a0:	89 d0                	mov    %edx,%eax
  8013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	6a 00                	push   $0x0
  8013b1:	ff 75 08             	pushl  0x8(%ebp)
  8013b4:	e8 b7 01 00 00       	call   801570 <open>
  8013b9:	89 c3                	mov    %eax,%ebx
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 1b                	js     8013dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	ff 75 0c             	pushl  0xc(%ebp)
  8013c8:	50                   	push   %eax
  8013c9:	e8 5b ff ff ff       	call   801329 <fstat>
  8013ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d0:	89 1c 24             	mov    %ebx,(%esp)
  8013d3:	e8 fd fb ff ff       	call   800fd5 <close>
	return r;
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 f0                	mov    %esi,%eax
}
  8013dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	56                   	push   %esi
  8013e8:	53                   	push   %ebx
  8013e9:	89 c6                	mov    %eax,%esi
  8013eb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ed:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f4:	75 12                	jne    801408 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	6a 01                	push   $0x1
  8013fb:	e8 bc 07 00 00       	call   801bbc <ipc_find_env>
  801400:	a3 00 40 80 00       	mov    %eax,0x804000
  801405:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801408:	6a 07                	push   $0x7
  80140a:	68 00 50 c0 00       	push   $0xc05000
  80140f:	56                   	push   %esi
  801410:	ff 35 00 40 80 00    	pushl  0x804000
  801416:	e8 4d 07 00 00       	call   801b68 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80141b:	83 c4 0c             	add    $0xc,%esp
  80141e:	6a 00                	push   $0x0
  801420:	53                   	push   %ebx
  801421:	6a 00                	push   $0x0
  801423:	e8 cb 06 00 00       	call   801af3 <ipc_recv>
}
  801428:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
  801438:	8b 40 0c             	mov    0xc(%eax),%eax
  80143b:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801440:	8b 45 0c             	mov    0xc(%ebp),%eax
  801443:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801448:	ba 00 00 00 00       	mov    $0x0,%edx
  80144d:	b8 02 00 00 00       	mov    $0x2,%eax
  801452:	e8 8d ff ff ff       	call   8013e4 <fsipc>
}
  801457:	c9                   	leave  
  801458:	c3                   	ret    

00801459 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145f:	8b 45 08             	mov    0x8(%ebp),%eax
  801462:	8b 40 0c             	mov    0xc(%eax),%eax
  801465:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80146a:	ba 00 00 00 00       	mov    $0x0,%edx
  80146f:	b8 06 00 00 00       	mov    $0x6,%eax
  801474:	e8 6b ff ff ff       	call   8013e4 <fsipc>
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	53                   	push   %ebx
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801485:	8b 45 08             	mov    0x8(%ebp),%eax
  801488:	8b 40 0c             	mov    0xc(%eax),%eax
  80148b:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801490:	ba 00 00 00 00       	mov    $0x0,%edx
  801495:	b8 05 00 00 00       	mov    $0x5,%eax
  80149a:	e8 45 ff ff ff       	call   8013e4 <fsipc>
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 2c                	js     8014cf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	68 00 50 c0 00       	push   $0xc05000
  8014ab:	53                   	push   %ebx
  8014ac:	e8 90 f3 ff ff       	call   800841 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b1:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8014b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014bc:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8014da:	68 5c 23 80 00       	push   $0x80235c
  8014df:	68 90 00 00 00       	push   $0x90
  8014e4:	68 7a 23 80 00       	push   $0x80237a
  8014e9:	e8 4e ec ff ff       	call   80013c <_panic>

008014ee <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	56                   	push   %esi
  8014f2:	53                   	push   %ebx
  8014f3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fc:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801501:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801507:	ba 00 00 00 00       	mov    $0x0,%edx
  80150c:	b8 03 00 00 00       	mov    $0x3,%eax
  801511:	e8 ce fe ff ff       	call   8013e4 <fsipc>
  801516:	89 c3                	mov    %eax,%ebx
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 4b                	js     801567 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80151c:	39 c6                	cmp    %eax,%esi
  80151e:	73 16                	jae    801536 <devfile_read+0x48>
  801520:	68 85 23 80 00       	push   $0x802385
  801525:	68 8c 23 80 00       	push   $0x80238c
  80152a:	6a 7c                	push   $0x7c
  80152c:	68 7a 23 80 00       	push   $0x80237a
  801531:	e8 06 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  801536:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80153b:	7e 16                	jle    801553 <devfile_read+0x65>
  80153d:	68 a1 23 80 00       	push   $0x8023a1
  801542:	68 8c 23 80 00       	push   $0x80238c
  801547:	6a 7d                	push   $0x7d
  801549:	68 7a 23 80 00       	push   $0x80237a
  80154e:	e8 e9 eb ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	50                   	push   %eax
  801557:	68 00 50 c0 00       	push   $0xc05000
  80155c:	ff 75 0c             	pushl  0xc(%ebp)
  80155f:	e8 6f f4 ff ff       	call   8009d3 <memmove>
	return r;
  801564:	83 c4 10             	add    $0x10,%esp
}
  801567:	89 d8                	mov    %ebx,%eax
  801569:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5e                   	pop    %esi
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	53                   	push   %ebx
  801574:	83 ec 20             	sub    $0x20,%esp
  801577:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80157a:	53                   	push   %ebx
  80157b:	e8 88 f2 ff ff       	call   800808 <strlen>
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801588:	7f 67                	jg     8015f1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	e8 c6 f8 ff ff       	call   800e5c <fd_alloc>
  801596:	83 c4 10             	add    $0x10,%esp
		return r;
  801599:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 57                	js     8015f6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	53                   	push   %ebx
  8015a3:	68 00 50 c0 00       	push   $0xc05000
  8015a8:	e8 94 f2 ff ff       	call   800841 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b0:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bd:	e8 22 fe ff ff       	call   8013e4 <fsipc>
  8015c2:	89 c3                	mov    %eax,%ebx
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	79 14                	jns    8015df <open+0x6f>
		fd_close(fd, 0);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	6a 00                	push   $0x0
  8015d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d3:	e8 7c f9 ff ff       	call   800f54 <fd_close>
		return r;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	89 da                	mov    %ebx,%edx
  8015dd:	eb 17                	jmp    8015f6 <open+0x86>
	}

	return fd2num(fd);
  8015df:	83 ec 0c             	sub    $0xc,%esp
  8015e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e5:	e8 4b f8 ff ff       	call   800e35 <fd2num>
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb 05                	jmp    8015f6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801603:	ba 00 00 00 00       	mov    $0x0,%edx
  801608:	b8 08 00 00 00       	mov    $0x8,%eax
  80160d:	e8 d2 fd ff ff       	call   8013e4 <fsipc>
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	ff 75 08             	pushl  0x8(%ebp)
  801622:	e8 1e f8 ff ff       	call   800e45 <fd2data>
  801627:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	68 ad 23 80 00       	push   $0x8023ad
  801631:	53                   	push   %ebx
  801632:	e8 0a f2 ff ff       	call   800841 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801637:	8b 46 04             	mov    0x4(%esi),%eax
  80163a:	2b 06                	sub    (%esi),%eax
  80163c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801642:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801649:	00 00 00 
	stat->st_dev = &devpipe;
  80164c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801653:	30 80 00 
	return 0;
}
  801656:	b8 00 00 00 00       	mov    $0x0,%eax
  80165b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165e:	5b                   	pop    %ebx
  80165f:	5e                   	pop    %esi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	53                   	push   %ebx
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80166c:	53                   	push   %ebx
  80166d:	6a 00                	push   $0x0
  80166f:	e8 55 f6 ff ff       	call   800cc9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801674:	89 1c 24             	mov    %ebx,(%esp)
  801677:	e8 c9 f7 ff ff       	call   800e45 <fd2data>
  80167c:	83 c4 08             	add    $0x8,%esp
  80167f:	50                   	push   %eax
  801680:	6a 00                	push   $0x0
  801682:	e8 42 f6 ff ff       	call   800cc9 <sys_page_unmap>
}
  801687:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	57                   	push   %edi
  801690:	56                   	push   %esi
  801691:	53                   	push   %ebx
  801692:	83 ec 1c             	sub    $0x1c,%esp
  801695:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801698:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80169a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80169f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016a2:	83 ec 0c             	sub    $0xc,%esp
  8016a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a8:	e8 48 05 00 00       	call   801bf5 <pageref>
  8016ad:	89 c3                	mov    %eax,%ebx
  8016af:	89 3c 24             	mov    %edi,(%esp)
  8016b2:	e8 3e 05 00 00       	call   801bf5 <pageref>
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	39 c3                	cmp    %eax,%ebx
  8016bc:	0f 94 c1             	sete   %cl
  8016bf:	0f b6 c9             	movzbl %cl,%ecx
  8016c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016c5:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8016cb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ce:	39 ce                	cmp    %ecx,%esi
  8016d0:	74 1b                	je     8016ed <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016d2:	39 c3                	cmp    %eax,%ebx
  8016d4:	75 c4                	jne    80169a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016d6:	8b 42 58             	mov    0x58(%edx),%eax
  8016d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016dc:	50                   	push   %eax
  8016dd:	56                   	push   %esi
  8016de:	68 b4 23 80 00       	push   $0x8023b4
  8016e3:	e8 2d eb ff ff       	call   800215 <cprintf>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	eb ad                	jmp    80169a <_pipeisclosed+0xe>
	}
}
  8016ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	57                   	push   %edi
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 28             	sub    $0x28,%esp
  801701:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801704:	56                   	push   %esi
  801705:	e8 3b f7 ff ff       	call   800e45 <fd2data>
  80170a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	bf 00 00 00 00       	mov    $0x0,%edi
  801714:	eb 4b                	jmp    801761 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801716:	89 da                	mov    %ebx,%edx
  801718:	89 f0                	mov    %esi,%eax
  80171a:	e8 6d ff ff ff       	call   80168c <_pipeisclosed>
  80171f:	85 c0                	test   %eax,%eax
  801721:	75 48                	jne    80176b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801723:	e8 fd f4 ff ff       	call   800c25 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801728:	8b 43 04             	mov    0x4(%ebx),%eax
  80172b:	8b 0b                	mov    (%ebx),%ecx
  80172d:	8d 51 20             	lea    0x20(%ecx),%edx
  801730:	39 d0                	cmp    %edx,%eax
  801732:	73 e2                	jae    801716 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801737:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80173b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80173e:	89 c2                	mov    %eax,%edx
  801740:	c1 fa 1f             	sar    $0x1f,%edx
  801743:	89 d1                	mov    %edx,%ecx
  801745:	c1 e9 1b             	shr    $0x1b,%ecx
  801748:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80174b:	83 e2 1f             	and    $0x1f,%edx
  80174e:	29 ca                	sub    %ecx,%edx
  801750:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801754:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801758:	83 c0 01             	add    $0x1,%eax
  80175b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175e:	83 c7 01             	add    $0x1,%edi
  801761:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801764:	75 c2                	jne    801728 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801766:	8b 45 10             	mov    0x10(%ebp),%eax
  801769:	eb 05                	jmp    801770 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80176b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5f                   	pop    %edi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	57                   	push   %edi
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	83 ec 18             	sub    $0x18,%esp
  801781:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801784:	57                   	push   %edi
  801785:	e8 bb f6 ff ff       	call   800e45 <fd2data>
  80178a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801794:	eb 3d                	jmp    8017d3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801796:	85 db                	test   %ebx,%ebx
  801798:	74 04                	je     80179e <devpipe_read+0x26>
				return i;
  80179a:	89 d8                	mov    %ebx,%eax
  80179c:	eb 44                	jmp    8017e2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80179e:	89 f2                	mov    %esi,%edx
  8017a0:	89 f8                	mov    %edi,%eax
  8017a2:	e8 e5 fe ff ff       	call   80168c <_pipeisclosed>
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	75 32                	jne    8017dd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017ab:	e8 75 f4 ff ff       	call   800c25 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017b0:	8b 06                	mov    (%esi),%eax
  8017b2:	3b 46 04             	cmp    0x4(%esi),%eax
  8017b5:	74 df                	je     801796 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017b7:	99                   	cltd   
  8017b8:	c1 ea 1b             	shr    $0x1b,%edx
  8017bb:	01 d0                	add    %edx,%eax
  8017bd:	83 e0 1f             	and    $0x1f,%eax
  8017c0:	29 d0                	sub    %edx,%eax
  8017c2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ca:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017cd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d0:	83 c3 01             	add    $0x1,%ebx
  8017d3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017d6:	75 d8                	jne    8017b0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017db:	eb 05                	jmp    8017e2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017dd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	56                   	push   %esi
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f5:	50                   	push   %eax
  8017f6:	e8 61 f6 ff ff       	call   800e5c <fd_alloc>
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	89 c2                	mov    %eax,%edx
  801800:	85 c0                	test   %eax,%eax
  801802:	0f 88 2c 01 00 00    	js     801934 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	68 07 04 00 00       	push   $0x407
  801810:	ff 75 f4             	pushl  -0xc(%ebp)
  801813:	6a 00                	push   $0x0
  801815:	e8 2a f4 ff ff       	call   800c44 <sys_page_alloc>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	89 c2                	mov    %eax,%edx
  80181f:	85 c0                	test   %eax,%eax
  801821:	0f 88 0d 01 00 00    	js     801934 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	e8 29 f6 ff ff       	call   800e5c <fd_alloc>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	0f 88 e2 00 00 00    	js     801922 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801840:	83 ec 04             	sub    $0x4,%esp
  801843:	68 07 04 00 00       	push   $0x407
  801848:	ff 75 f0             	pushl  -0x10(%ebp)
  80184b:	6a 00                	push   $0x0
  80184d:	e8 f2 f3 ff ff       	call   800c44 <sys_page_alloc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	0f 88 c3 00 00 00    	js     801922 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	ff 75 f4             	pushl  -0xc(%ebp)
  801865:	e8 db f5 ff ff       	call   800e45 <fd2data>
  80186a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186c:	83 c4 0c             	add    $0xc,%esp
  80186f:	68 07 04 00 00       	push   $0x407
  801874:	50                   	push   %eax
  801875:	6a 00                	push   $0x0
  801877:	e8 c8 f3 ff ff       	call   800c44 <sys_page_alloc>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	0f 88 89 00 00 00    	js     801912 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	ff 75 f0             	pushl  -0x10(%ebp)
  80188f:	e8 b1 f5 ff ff       	call   800e45 <fd2data>
  801894:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80189b:	50                   	push   %eax
  80189c:	6a 00                	push   $0x0
  80189e:	56                   	push   %esi
  80189f:	6a 00                	push   $0x0
  8018a1:	e8 e1 f3 ff ff       	call   800c87 <sys_page_map>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	83 c4 20             	add    $0x20,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 55                	js     801904 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018af:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018c4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018df:	e8 51 f5 ff ff       	call   800e35 <fd2num>
  8018e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018e9:	83 c4 04             	add    $0x4,%esp
  8018ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ef:	e8 41 f5 ff ff       	call   800e35 <fd2num>
  8018f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	eb 30                	jmp    801934 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	56                   	push   %esi
  801908:	6a 00                	push   $0x0
  80190a:	e8 ba f3 ff ff       	call   800cc9 <sys_page_unmap>
  80190f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801912:	83 ec 08             	sub    $0x8,%esp
  801915:	ff 75 f0             	pushl  -0x10(%ebp)
  801918:	6a 00                	push   $0x0
  80191a:	e8 aa f3 ff ff       	call   800cc9 <sys_page_unmap>
  80191f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	ff 75 f4             	pushl  -0xc(%ebp)
  801928:	6a 00                	push   $0x0
  80192a:	e8 9a f3 ff ff       	call   800cc9 <sys_page_unmap>
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801934:	89 d0                	mov    %edx,%eax
  801936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	50                   	push   %eax
  801947:	ff 75 08             	pushl  0x8(%ebp)
  80194a:	e8 5c f5 ff ff       	call   800eab <fd_lookup>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	78 18                	js     80196e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801956:	83 ec 0c             	sub    $0xc,%esp
  801959:	ff 75 f4             	pushl  -0xc(%ebp)
  80195c:	e8 e4 f4 ff ff       	call   800e45 <fd2data>
	return _pipeisclosed(fd, p);
  801961:	89 c2                	mov    %eax,%edx
  801963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801966:	e8 21 fd ff ff       	call   80168c <_pipeisclosed>
  80196b:	83 c4 10             	add    $0x10,%esp
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801980:	68 cc 23 80 00       	push   $0x8023cc
  801985:	ff 75 0c             	pushl  0xc(%ebp)
  801988:	e8 b4 ee ff ff       	call   800841 <strcpy>
	return 0;
}
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ab:	eb 2d                	jmp    8019da <devcons_write+0x46>
		m = n - tot;
  8019ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019b0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019b2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019b5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019ba:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	53                   	push   %ebx
  8019c1:	03 45 0c             	add    0xc(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	57                   	push   %edi
  8019c6:	e8 08 f0 ff ff       	call   8009d3 <memmove>
		sys_cputs(buf, m);
  8019cb:	83 c4 08             	add    $0x8,%esp
  8019ce:	53                   	push   %ebx
  8019cf:	57                   	push   %edi
  8019d0:	e8 b3 f1 ff ff       	call   800b88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d5:	01 de                	add    %ebx,%esi
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	89 f0                	mov    %esi,%eax
  8019dc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019df:	72 cc                	jb     8019ad <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5f                   	pop    %edi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019f8:	74 2a                	je     801a24 <devcons_read+0x3b>
  8019fa:	eb 05                	jmp    801a01 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019fc:	e8 24 f2 ff ff       	call   800c25 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a01:	e8 a0 f1 ff ff       	call   800ba6 <sys_cgetc>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	74 f2                	je     8019fc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 16                	js     801a24 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a0e:	83 f8 04             	cmp    $0x4,%eax
  801a11:	74 0c                	je     801a1f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a13:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a16:	88 02                	mov    %al,(%edx)
	return 1;
  801a18:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1d:	eb 05                	jmp    801a24 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a1f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a32:	6a 01                	push   $0x1
  801a34:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a37:	50                   	push   %eax
  801a38:	e8 4b f1 ff ff       	call   800b88 <sys_cputs>
}
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <getchar>:

int
getchar(void)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a48:	6a 01                	push   $0x1
  801a4a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4d:	50                   	push   %eax
  801a4e:	6a 00                	push   $0x0
  801a50:	e8 bc f6 ff ff       	call   801111 <read>
	if (r < 0)
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 0f                	js     801a6b <getchar+0x29>
		return r;
	if (r < 1)
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	7e 06                	jle    801a66 <getchar+0x24>
		return -E_EOF;
	return c;
  801a60:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a64:	eb 05                	jmp    801a6b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a66:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a76:	50                   	push   %eax
  801a77:	ff 75 08             	pushl  0x8(%ebp)
  801a7a:	e8 2c f4 ff ff       	call   800eab <fd_lookup>
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 11                	js     801a97 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a89:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a8f:	39 10                	cmp    %edx,(%eax)
  801a91:	0f 94 c0             	sete   %al
  801a94:	0f b6 c0             	movzbl %al,%eax
}
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <opencons>:

int
opencons(void)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	e8 b4 f3 ff ff       	call   800e5c <fd_alloc>
  801aa8:	83 c4 10             	add    $0x10,%esp
		return r;
  801aab:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 3e                	js     801aef <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab1:	83 ec 04             	sub    $0x4,%esp
  801ab4:	68 07 04 00 00       	push   $0x407
  801ab9:	ff 75 f4             	pushl  -0xc(%ebp)
  801abc:	6a 00                	push   $0x0
  801abe:	e8 81 f1 ff ff       	call   800c44 <sys_page_alloc>
  801ac3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	78 23                	js     801aef <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801acc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ada:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	50                   	push   %eax
  801ae5:	e8 4b f3 ff ff       	call   800e35 <fd2num>
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	83 c4 10             	add    $0x10,%esp
}
  801aef:	89 d0                	mov    %edx,%eax
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	8b 75 08             	mov    0x8(%ebp),%esi
  801afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801b01:	85 c0                	test   %eax,%eax
  801b03:	74 0e                	je     801b13 <ipc_recv+0x20>
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	50                   	push   %eax
  801b09:	e8 e6 f2 ff ff       	call   800df4 <sys_ipc_recv>
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	eb 10                	jmp    801b23 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	68 00 00 c0 ee       	push   $0xeec00000
  801b1b:	e8 d4 f2 ff ff       	call   800df4 <sys_ipc_recv>
  801b20:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801b23:	85 c0                	test   %eax,%eax
  801b25:	74 16                	je     801b3d <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801b27:	85 f6                	test   %esi,%esi
  801b29:	74 06                	je     801b31 <ipc_recv+0x3e>
  801b2b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801b31:	85 db                	test   %ebx,%ebx
  801b33:	74 2c                	je     801b61 <ipc_recv+0x6e>
  801b35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b3b:	eb 24                	jmp    801b61 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b3d:	85 f6                	test   %esi,%esi
  801b3f:	74 0a                	je     801b4b <ipc_recv+0x58>
  801b41:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b46:	8b 40 74             	mov    0x74(%eax),%eax
  801b49:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801b4b:	85 db                	test   %ebx,%ebx
  801b4d:	74 0a                	je     801b59 <ipc_recv+0x66>
  801b4f:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b54:	8b 40 78             	mov    0x78(%eax),%eax
  801b57:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b59:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b5e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	57                   	push   %edi
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b74:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b77:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b81:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b84:	ff 75 14             	pushl  0x14(%ebp)
  801b87:	53                   	push   %ebx
  801b88:	56                   	push   %esi
  801b89:	57                   	push   %edi
  801b8a:	e8 42 f2 ff ff       	call   800dd1 <sys_ipc_try_send>
		if (ret == 0) break;
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	74 1e                	je     801bb4 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b99:	74 12                	je     801bad <ipc_send+0x45>
  801b9b:	50                   	push   %eax
  801b9c:	68 d8 23 80 00       	push   $0x8023d8
  801ba1:	6a 39                	push   $0x39
  801ba3:	68 e5 23 80 00       	push   $0x8023e5
  801ba8:	e8 8f e5 ff ff       	call   80013c <_panic>
		sys_yield();
  801bad:	e8 73 f0 ff ff       	call   800c25 <sys_yield>
	}
  801bb2:	eb d0                	jmp    801b84 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5f                   	pop    %edi
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bc2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bc7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bd0:	8b 52 50             	mov    0x50(%edx),%edx
  801bd3:	39 ca                	cmp    %ecx,%edx
  801bd5:	75 0d                	jne    801be4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bd7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bda:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bdf:	8b 40 48             	mov    0x48(%eax),%eax
  801be2:	eb 0f                	jmp    801bf3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801be4:	83 c0 01             	add    $0x1,%eax
  801be7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bec:	75 d9                	jne    801bc7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bfb:	89 d0                	mov    %edx,%eax
  801bfd:	c1 e8 16             	shr    $0x16,%eax
  801c00:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0c:	f6 c1 01             	test   $0x1,%cl
  801c0f:	74 1d                	je     801c2e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c11:	c1 ea 0c             	shr    $0xc,%edx
  801c14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c1b:	f6 c2 01             	test   $0x1,%dl
  801c1e:	74 0e                	je     801c2e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c20:	c1 ea 0c             	shr    $0xc,%edx
  801c23:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c2a:	ef 
  801c2b:	0f b7 c0             	movzwl %ax,%eax
}
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <__udivdi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 f6                	test   %esi,%esi
  801c49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4d:	89 ca                	mov    %ecx,%edx
  801c4f:	89 f8                	mov    %edi,%eax
  801c51:	75 3d                	jne    801c90 <__udivdi3+0x60>
  801c53:	39 cf                	cmp    %ecx,%edi
  801c55:	0f 87 c5 00 00 00    	ja     801d20 <__udivdi3+0xf0>
  801c5b:	85 ff                	test   %edi,%edi
  801c5d:	89 fd                	mov    %edi,%ebp
  801c5f:	75 0b                	jne    801c6c <__udivdi3+0x3c>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	31 d2                	xor    %edx,%edx
  801c68:	f7 f7                	div    %edi
  801c6a:	89 c5                	mov    %eax,%ebp
  801c6c:	89 c8                	mov    %ecx,%eax
  801c6e:	31 d2                	xor    %edx,%edx
  801c70:	f7 f5                	div    %ebp
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	89 cf                	mov    %ecx,%edi
  801c78:	f7 f5                	div    %ebp
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	39 ce                	cmp    %ecx,%esi
  801c92:	77 74                	ja     801d08 <__udivdi3+0xd8>
  801c94:	0f bd fe             	bsr    %esi,%edi
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	0f 84 98 00 00 00    	je     801d38 <__udivdi3+0x108>
  801ca0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	89 c5                	mov    %eax,%ebp
  801ca9:	29 fb                	sub    %edi,%ebx
  801cab:	d3 e6                	shl    %cl,%esi
  801cad:	89 d9                	mov    %ebx,%ecx
  801caf:	d3 ed                	shr    %cl,%ebp
  801cb1:	89 f9                	mov    %edi,%ecx
  801cb3:	d3 e0                	shl    %cl,%eax
  801cb5:	09 ee                	or     %ebp,%esi
  801cb7:	89 d9                	mov    %ebx,%ecx
  801cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cbd:	89 d5                	mov    %edx,%ebp
  801cbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cc3:	d3 ed                	shr    %cl,%ebp
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e2                	shl    %cl,%edx
  801cc9:	89 d9                	mov    %ebx,%ecx
  801ccb:	d3 e8                	shr    %cl,%eax
  801ccd:	09 c2                	or     %eax,%edx
  801ccf:	89 d0                	mov    %edx,%eax
  801cd1:	89 ea                	mov    %ebp,%edx
  801cd3:	f7 f6                	div    %esi
  801cd5:	89 d5                	mov    %edx,%ebp
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	f7 64 24 0c          	mull   0xc(%esp)
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	72 10                	jb     801cf1 <__udivdi3+0xc1>
  801ce1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e6                	shl    %cl,%esi
  801ce9:	39 c6                	cmp    %eax,%esi
  801ceb:	73 07                	jae    801cf4 <__udivdi3+0xc4>
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	75 03                	jne    801cf4 <__udivdi3+0xc4>
  801cf1:	83 eb 01             	sub    $0x1,%ebx
  801cf4:	31 ff                	xor    %edi,%edi
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	89 fa                	mov    %edi,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	31 ff                	xor    %edi,%edi
  801d0a:	31 db                	xor    %ebx,%ebx
  801d0c:	89 d8                	mov    %ebx,%eax
  801d0e:	89 fa                	mov    %edi,%edx
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
  801d18:	90                   	nop
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	f7 f7                	div    %edi
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 1c             	add    $0x1c,%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
  801d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d38:	39 ce                	cmp    %ecx,%esi
  801d3a:	72 0c                	jb     801d48 <__udivdi3+0x118>
  801d3c:	31 db                	xor    %ebx,%ebx
  801d3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d42:	0f 87 34 ff ff ff    	ja     801c7c <__udivdi3+0x4c>
  801d48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d4d:	e9 2a ff ff ff       	jmp    801c7c <__udivdi3+0x4c>
  801d52:	66 90                	xchg   %ax,%ax
  801d54:	66 90                	xchg   %ax,%ax
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d77:	85 d2                	test   %edx,%edx
  801d79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d81:	89 f3                	mov    %esi,%ebx
  801d83:	89 3c 24             	mov    %edi,(%esp)
  801d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d8a:	75 1c                	jne    801da8 <__umoddi3+0x48>
  801d8c:	39 f7                	cmp    %esi,%edi
  801d8e:	76 50                	jbe    801de0 <__umoddi3+0x80>
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	f7 f7                	div    %edi
  801d96:	89 d0                	mov    %edx,%eax
  801d98:	31 d2                	xor    %edx,%edx
  801d9a:	83 c4 1c             	add    $0x1c,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
  801da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801da8:	39 f2                	cmp    %esi,%edx
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	77 52                	ja     801e00 <__umoddi3+0xa0>
  801dae:	0f bd ea             	bsr    %edx,%ebp
  801db1:	83 f5 1f             	xor    $0x1f,%ebp
  801db4:	75 5a                	jne    801e10 <__umoddi3+0xb0>
  801db6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	39 0c 24             	cmp    %ecx,(%esp)
  801dc3:	0f 86 d7 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dd1:	83 c4 1c             	add    $0x1c,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	85 ff                	test   %edi,%edi
  801de2:	89 fd                	mov    %edi,%ebp
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 c8                	mov    %ecx,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	eb 99                	jmp    801d98 <__umoddi3+0x38>
  801dff:	90                   	nop
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	83 c4 1c             	add    $0x1c,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    
  801e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e10:	8b 34 24             	mov    (%esp),%esi
  801e13:	bf 20 00 00 00       	mov    $0x20,%edi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	29 ef                	sub    %ebp,%edi
  801e1c:	d3 e0                	shl    %cl,%eax
  801e1e:	89 f9                	mov    %edi,%ecx
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	d3 ea                	shr    %cl,%edx
  801e24:	89 e9                	mov    %ebp,%ecx
  801e26:	09 c2                	or     %eax,%edx
  801e28:	89 d8                	mov    %ebx,%eax
  801e2a:	89 14 24             	mov    %edx,(%esp)
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	d3 e2                	shl    %cl,%edx
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	89 c6                	mov    %eax,%esi
  801e41:	d3 e3                	shl    %cl,%ebx
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 d0                	mov    %edx,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	09 d8                	or     %ebx,%eax
  801e4d:	89 d3                	mov    %edx,%ebx
  801e4f:	89 f2                	mov    %esi,%edx
  801e51:	f7 34 24             	divl   (%esp)
  801e54:	89 d6                	mov    %edx,%esi
  801e56:	d3 e3                	shl    %cl,%ebx
  801e58:	f7 64 24 04          	mull   0x4(%esp)
  801e5c:	39 d6                	cmp    %edx,%esi
  801e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e62:	89 d1                	mov    %edx,%ecx
  801e64:	89 c3                	mov    %eax,%ebx
  801e66:	72 08                	jb     801e70 <__umoddi3+0x110>
  801e68:	75 11                	jne    801e7b <__umoddi3+0x11b>
  801e6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e6e:	73 0b                	jae    801e7b <__umoddi3+0x11b>
  801e70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e74:	1b 14 24             	sbb    (%esp),%edx
  801e77:	89 d1                	mov    %edx,%ecx
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e7f:	29 da                	sub    %ebx,%edx
  801e81:	19 ce                	sbb    %ecx,%esi
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	89 f0                	mov    %esi,%eax
  801e87:	d3 e0                	shl    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	d3 ea                	shr    %cl,%edx
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	d3 ee                	shr    %cl,%esi
  801e91:	09 d0                	or     %edx,%eax
  801e93:	89 f2                	mov    %esi,%edx
  801e95:	83 c4 1c             	add    $0x1c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 f9                	sub    %edi,%ecx
  801ea2:	19 d6                	sbb    %edx,%esi
  801ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eac:	e9 18 ff ff ff       	jmp    801dc9 <__umoddi3+0x69>
