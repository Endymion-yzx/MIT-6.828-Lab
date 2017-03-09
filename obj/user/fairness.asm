
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 45 0b 00 00       	call   800b85 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 56 0d 00 00       	call   800db4 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 a0 1e 80 00       	push   $0x801ea0
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 b1 1e 80 00       	push   $0x801eb1
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 8d 0d 00 00       	call   800e29 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8000ac:	e8 d4 0a 00 00       	call   800b85 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 8f 0f 00 00       	call   801081 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 48 0a 00 00       	call   800b44 <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 d6 09 00 00       	call   800b07 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 1a 01 00 00       	call   800291 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 7b 09 00 00       	call   800b07 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 04 1a 00 00       	call   801c00 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 f1 1a 00 00       	call   801d30 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 d2 1e 80 00 	movsbl 0x801ed2(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800261:	8b 10                	mov    (%eax),%edx
  800263:	3b 50 04             	cmp    0x4(%eax),%edx
  800266:	73 0a                	jae    800272 <sprintputch+0x1b>
		*b->buf++ = ch;
  800268:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	88 02                	mov    %al,(%edx)
}
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027d:	50                   	push   %eax
  80027e:	ff 75 10             	pushl  0x10(%ebp)
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	e8 05 00 00 00       	call   800291 <vprintfmt>
	va_end(ap);
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	8b 75 08             	mov    0x8(%ebp),%esi
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a3:	eb 12                	jmp    8002b7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a5:	85 c0                	test   %eax,%eax
  8002a7:	0f 84 6a 04 00 00    	je     800717 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	53                   	push   %ebx
  8002b1:	50                   	push   %eax
  8002b2:	ff d6                	call   *%esi
  8002b4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b7:	83 c7 01             	add    $0x1,%edi
  8002ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002be:	83 f8 25             	cmp    $0x25,%eax
  8002c1:	75 e2                	jne    8002a5 <vprintfmt+0x14>
  8002c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e1:	eb 07                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8d 47 01             	lea    0x1(%edi),%eax
  8002ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f0:	0f b6 07             	movzbl (%edi),%eax
  8002f3:	0f b6 d0             	movzbl %al,%edx
  8002f6:	83 e8 23             	sub    $0x23,%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 fb 03 00 00    	ja     8006fc <vprintfmt+0x46b>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800312:	eb d6                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	b8 00 00 00 00       	mov    $0x0,%eax
  80031c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800322:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800326:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800329:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032c:	83 f9 09             	cmp    $0x9,%ecx
  80032f:	77 3f                	ja     800370 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800331:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800334:	eb e9                	jmp    80031f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 40 04             	lea    0x4(%eax),%eax
  800344:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034a:	eb 2a                	jmp    800376 <vprintfmt+0xe5>
  80034c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034f:	85 c0                	test   %eax,%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	0f 49 d0             	cmovns %eax,%edx
  800359:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035f:	eb 89                	jmp    8002ea <vprintfmt+0x59>
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800364:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036b:	e9 7a ff ff ff       	jmp    8002ea <vprintfmt+0x59>
  800370:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037a:	0f 89 6a ff ff ff    	jns    8002ea <vprintfmt+0x59>
				width = precision, precision = -1;
  800380:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038d:	e9 58 ff ff ff       	jmp    8002ea <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800392:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800398:	e9 4d ff ff ff       	jmp    8002ea <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 78 04             	lea    0x4(%eax),%edi
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	53                   	push   %ebx
  8003a7:	ff 30                	pushl  (%eax)
  8003a9:	ff d6                	call   *%esi
			break;
  8003ab:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b4:	e9 fe fe ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 0f             	cmp    $0xf,%eax
  8003c9:	7f 0b                	jg     8003d6 <vprintfmt+0x145>
  8003cb:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	75 1b                	jne    8003f1 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003d6:	50                   	push   %eax
  8003d7:	68 ea 1e 80 00       	push   $0x801eea
  8003dc:	53                   	push   %ebx
  8003dd:	56                   	push   %esi
  8003de:	e8 91 fe ff ff       	call   800274 <printfmt>
  8003e3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ec:	e9 c6 fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 f2 22 80 00       	push   $0x8022f2
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 76 fe ff ff       	call   800274 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	e9 ab fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	83 c0 04             	add    $0x4,%eax
  800412:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041a:	85 ff                	test   %edi,%edi
  80041c:	b8 e3 1e 80 00       	mov    $0x801ee3,%eax
  800421:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800428:	0f 8e 94 00 00 00    	jle    8004c2 <vprintfmt+0x231>
  80042e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800432:	0f 84 98 00 00 00    	je     8004d0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 d0             	pushl  -0x30(%ebp)
  80043e:	57                   	push   %edi
  80043f:	e8 5b 03 00 00       	call   80079f <strnlen>
  800444:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800447:	29 c1                	sub    %eax,%ecx
  800449:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80044c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800459:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	eb 0f                	jmp    80046c <vprintfmt+0x1db>
					putch(padc, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	53                   	push   %ebx
  800461:	ff 75 e0             	pushl  -0x20(%ebp)
  800464:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ef 01             	sub    $0x1,%edi
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	85 ff                	test   %edi,%edi
  80046e:	7f ed                	jg     80045d <vprintfmt+0x1cc>
  800470:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800473:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800476:	85 c9                	test   %ecx,%ecx
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	0f 49 c1             	cmovns %ecx,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 75 08             	mov    %esi,0x8(%ebp)
  800485:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800488:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048b:	89 cb                	mov    %ecx,%ebx
  80048d:	eb 4d                	jmp    8004dc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800493:	74 1b                	je     8004b0 <vprintfmt+0x21f>
  800495:	0f be c0             	movsbl %al,%eax
  800498:	83 e8 20             	sub    $0x20,%eax
  80049b:	83 f8 5e             	cmp    $0x5e,%eax
  80049e:	76 10                	jbe    8004b0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	6a 3f                	push   $0x3f
  8004a8:	ff 55 08             	call   *0x8(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	eb 0d                	jmp    8004bd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	52                   	push   %edx
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bd:	83 eb 01             	sub    $0x1,%ebx
  8004c0:	eb 1a                	jmp    8004dc <vprintfmt+0x24b>
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ce:	eb 0c                	jmp    8004dc <vprintfmt+0x24b>
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dc:	83 c7 01             	add    $0x1,%edi
  8004df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e3:	0f be d0             	movsbl %al,%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 23                	je     80050d <vprintfmt+0x27c>
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	78 a1                	js     80048f <vprintfmt+0x1fe>
  8004ee:	83 ee 01             	sub    $0x1,%esi
  8004f1:	79 9c                	jns    80048f <vprintfmt+0x1fe>
  8004f3:	89 df                	mov    %ebx,%edi
  8004f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fb:	eb 18                	jmp    800515 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	6a 20                	push   $0x20
  800503:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 08                	jmp    800515 <vprintfmt+0x284>
  80050d:	89 df                	mov    %ebx,%edi
  80050f:	8b 75 08             	mov    0x8(%ebp),%esi
  800512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800515:	85 ff                	test   %edi,%edi
  800517:	7f e4                	jg     8004fd <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800522:	e9 90 fd ff ff       	jmp    8002b7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 19                	jle    800545 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8b 50 04             	mov    0x4(%eax),%edx
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 40 08             	lea    0x8(%eax),%eax
  800540:	89 45 14             	mov    %eax,0x14(%ebp)
  800543:	eb 38                	jmp    80057d <vprintfmt+0x2ec>
	else if (lflag)
  800545:	85 c9                	test   %ecx,%ecx
  800547:	74 1b                	je     800564 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 04             	lea    0x4(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
  800562:	eb 19                	jmp    80057d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	89 c1                	mov    %eax,%ecx
  80056e:	c1 f9 1f             	sar    $0x1f,%ecx
  800571:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800583:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	0f 89 36 01 00 00    	jns    8006c8 <vprintfmt+0x437>
				putch('-', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 2d                	push   $0x2d
  800598:	ff d6                	call   *%esi
				num = -(long long) num;
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a0:	f7 da                	neg    %edx
  8005a2:	83 d1 00             	adc    $0x0,%ecx
  8005a5:	f7 d9                	neg    %ecx
  8005a7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 14 01 00 00       	jmp    8006c8 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b4:	83 f9 01             	cmp    $0x1,%ecx
  8005b7:	7e 18                	jle    8005d1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c1:	8d 40 08             	lea    0x8(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 f7 00 00 00       	jmp    8006c8 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	74 1a                	je     8005ef <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ea:	e9 d9 00 00 00       	jmp    8006c8 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 bf 00 00 00       	jmp    8006c8 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800609:	83 f9 01             	cmp    $0x1,%ecx
  80060c:	7e 13                	jle    800621 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 50 04             	mov    0x4(%eax),%edx
  800614:	8b 00                	mov    (%eax),%eax
  800616:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800619:	8d 49 08             	lea    0x8(%ecx),%ecx
  80061c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80061f:	eb 28                	jmp    800649 <vprintfmt+0x3b8>
	else if (lflag)
  800621:	85 c9                	test   %ecx,%ecx
  800623:	74 13                	je     800638 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	89 d0                	mov    %edx,%eax
  80062c:	99                   	cltd   
  80062d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800630:	8d 49 04             	lea    0x4(%ecx),%ecx
  800633:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800636:	eb 11                	jmp    800649 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	89 d0                	mov    %edx,%eax
  80063f:	99                   	cltd   
  800640:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800643:	8d 49 04             	lea    0x4(%ecx),%ecx
  800646:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800649:	89 d1                	mov    %edx,%ecx
  80064b:	89 c2                	mov    %eax,%edx
			base = 8;
  80064d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800652:	eb 74                	jmp    8006c8 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 30                	push   $0x30
  80065a:	ff d6                	call   *%esi
			putch('x', putdat);
  80065c:	83 c4 08             	add    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 78                	push   $0x78
  800662:	ff d6                	call   *%esi
			num = (unsigned long long)
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 10                	mov    (%eax),%edx
  800669:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067c:	eb 4a                	jmp    8006c8 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067e:	83 f9 01             	cmp    $0x1,%ecx
  800681:	7e 15                	jle    800698 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	8b 48 04             	mov    0x4(%eax),%ecx
  80068b:	8d 40 08             	lea    0x8(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800691:	b8 10 00 00 00       	mov    $0x10,%eax
  800696:	eb 30                	jmp    8006c8 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 17                	je     8006b3 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b1:	eb 15                	jmp    8006c8 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cf:	57                   	push   %edi
  8006d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d3:	50                   	push   %eax
  8006d4:	51                   	push   %ecx
  8006d5:	52                   	push   %edx
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	e8 c9 fa ff ff       	call   8001a8 <printnum>
			break;
  8006df:	83 c4 20             	add    $0x20,%esp
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e5:	e9 cd fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	52                   	push   %edx
  8006ef:	ff d6                	call   *%esi
			break;
  8006f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f7:	e9 bb fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 25                	push   $0x25
  800702:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 03                	jmp    80070c <vprintfmt+0x47b>
  800709:	83 ef 01             	sub    $0x1,%edi
  80070c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800710:	75 f7                	jne    800709 <vprintfmt+0x478>
  800712:	e9 a0 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x47>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 22                	jle    800766 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	pushl  0x14(%ebp)
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 57 02 80 00       	push   $0x800257
  800753:	e8 39 fb ff ff       	call   800291 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 05                	jmp    80076b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	ff 75 08             	pushl  0x8(%ebp)
  800780:	e8 9a ff ff ff       	call   80071f <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 03                	jmp    800797 <strlen+0x10>
		n++;
  800794:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800797:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079b:	75 f7                	jne    800794 <strlen+0xd>
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	eb 03                	jmp    8007b2 <strnlen+0x13>
		n++;
  8007af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b2:	39 c2                	cmp    %eax,%edx
  8007b4:	74 08                	je     8007be <strnlen+0x1f>
  8007b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ba:	75 f3                	jne    8007af <strnlen+0x10>
  8007bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d9:	84 db                	test   %bl,%bl
  8007db:	75 ef                	jne    8007cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e7:	53                   	push   %ebx
  8007e8:	e8 9a ff ff ff       	call   800787 <strlen>
  8007ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	01 d8                	add    %ebx,%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c5 ff ff ff       	call   8007c0 <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	89 f3                	mov    %esi,%ebx
  80080f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	89 f2                	mov    %esi,%edx
  800814:	eb 0f                	jmp    800825 <strncpy+0x23>
		*dst++ = *src;
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081f:	80 39 01             	cmpb   $0x1,(%ecx)
  800822:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	39 da                	cmp    %ebx,%edx
  800827:	75 ed                	jne    800816 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800829:	89 f0                	mov    %esi,%eax
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	8b 55 10             	mov    0x10(%ebp),%edx
  80083d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083f:	85 d2                	test   %edx,%edx
  800841:	74 21                	je     800864 <strlcpy+0x35>
  800843:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 09                	jmp    800854 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800854:	39 c2                	cmp    %eax,%edx
  800856:	74 09                	je     800861 <strlcpy+0x32>
  800858:	0f b6 19             	movzbl (%ecx),%ebx
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ec                	jne    80084b <strlcpy+0x1c>
  80085f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800861:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800864:	29 f0                	sub    %esi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800873:	eb 06                	jmp    80087b <strcmp+0x11>
		p++, q++;
  800875:	83 c1 01             	add    $0x1,%ecx
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087b:	0f b6 01             	movzbl (%ecx),%eax
  80087e:	84 c0                	test   %al,%al
  800880:	74 04                	je     800886 <strcmp+0x1c>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	74 ef                	je     800875 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 c0             	movzbl %al,%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	89 c3                	mov    %eax,%ebx
  80089c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089f:	eb 06                	jmp    8008a7 <strncmp+0x17>
		n--, p++, q++;
  8008a1:	83 c0 01             	add    $0x1,%eax
  8008a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a7:	39 d8                	cmp    %ebx,%eax
  8008a9:	74 15                	je     8008c0 <strncmp+0x30>
  8008ab:	0f b6 08             	movzbl (%eax),%ecx
  8008ae:	84 c9                	test   %cl,%cl
  8008b0:	74 04                	je     8008b6 <strncmp+0x26>
  8008b2:	3a 0a                	cmp    (%edx),%cl
  8008b4:	74 eb                	je     8008a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 00             	movzbl (%eax),%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
  8008be:	eb 05                	jmp    8008c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	eb 07                	jmp    8008db <strchr+0x13>
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 0f                	je     8008e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	0f b6 10             	movzbl (%eax),%edx
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	75 f2                	jne    8008d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f3:	eb 03                	jmp    8008f8 <strfind+0xf>
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	74 04                	je     800903 <strfind+0x1a>
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f2                	jne    8008f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800911:	85 c9                	test   %ecx,%ecx
  800913:	74 36                	je     80094b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800915:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091b:	75 28                	jne    800945 <memset+0x40>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 23                	jne    800945 <memset+0x40>
		c &= 0xFF;
  800922:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800926:	89 d3                	mov    %edx,%ebx
  800928:	c1 e3 08             	shl    $0x8,%ebx
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	c1 e6 18             	shl    $0x18,%esi
  800930:	89 d0                	mov    %edx,%eax
  800932:	c1 e0 10             	shl    $0x10,%eax
  800935:	09 f0                	or     %esi,%eax
  800937:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800939:	89 d8                	mov    %ebx,%eax
  80093b:	09 d0                	or     %edx,%eax
  80093d:	c1 e9 02             	shr    $0x2,%ecx
  800940:	fc                   	cld    
  800941:	f3 ab                	rep stos %eax,%es:(%edi)
  800943:	eb 06                	jmp    80094b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800945:	8b 45 0c             	mov    0xc(%ebp),%eax
  800948:	fc                   	cld    
  800949:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094b:	89 f8                	mov    %edi,%eax
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5f                   	pop    %edi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800960:	39 c6                	cmp    %eax,%esi
  800962:	73 35                	jae    800999 <memmove+0x47>
  800964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800967:	39 d0                	cmp    %edx,%eax
  800969:	73 2e                	jae    800999 <memmove+0x47>
		s += n;
		d += n;
  80096b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 d6                	mov    %edx,%esi
  800970:	09 fe                	or     %edi,%esi
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	75 13                	jne    80098d <memmove+0x3b>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0e                	jne    80098d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097f:	83 ef 04             	sub    $0x4,%edi
  800982:	8d 72 fc             	lea    -0x4(%edx),%esi
  800985:	c1 e9 02             	shr    $0x2,%ecx
  800988:	fd                   	std    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 09                	jmp    800996 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098d:	83 ef 01             	sub    $0x1,%edi
  800990:	8d 72 ff             	lea    -0x1(%edx),%esi
  800993:	fd                   	std    
  800994:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800996:	fc                   	cld    
  800997:	eb 1d                	jmp    8009b6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 f2                	mov    %esi,%edx
  80099b:	09 c2                	or     %eax,%edx
  80099d:	f6 c2 03             	test   $0x3,%dl
  8009a0:	75 0f                	jne    8009b1 <memmove+0x5f>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 0a                	jne    8009b1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 05                	jmp    8009b6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bd:	ff 75 10             	pushl  0x10(%ebp)
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	ff 75 08             	pushl  0x8(%ebp)
  8009c6:	e8 87 ff ff ff       	call   800952 <memmove>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d8:	89 c6                	mov    %eax,%esi
  8009da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dd:	eb 1a                	jmp    8009f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	0f b6 1a             	movzbl (%edx),%ebx
  8009e5:	38 d9                	cmp    %bl,%cl
  8009e7:	74 0a                	je     8009f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e9:	0f b6 c1             	movzbl %cl,%eax
  8009ec:	0f b6 db             	movzbl %bl,%ebx
  8009ef:	29 d8                	sub    %ebx,%eax
  8009f1:	eb 0f                	jmp    800a02 <memcmp+0x35>
		s1++, s2++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f0                	cmp    %esi,%eax
  8009fb:	75 e2                	jne    8009df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0d:	89 c1                	mov    %eax,%ecx
  800a0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a16:	eb 0a                	jmp    800a22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	39 da                	cmp    %ebx,%edx
  800a1d:	74 07                	je     800a26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	39 c8                	cmp    %ecx,%eax
  800a24:	72 f2                	jb     800a18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x11>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0xe>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	75 0a                	jne    800a53 <strtol+0x2a>
		s++;
  800a49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a51:	eb 11                	jmp    800a64 <strtol+0x3b>
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a58:	3c 2d                	cmp    $0x2d,%al
  800a5a:	75 08                	jne    800a64 <strtol+0x3b>
		s++, neg = 1;
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 15                	jne    800a81 <strtol+0x58>
  800a6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6f:	75 10                	jne    800a81 <strtol+0x58>
  800a71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a75:	75 7c                	jne    800af3 <strtol+0xca>
		s += 2, base = 16;
  800a77:	83 c1 02             	add    $0x2,%ecx
  800a7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7f:	eb 16                	jmp    800a97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	75 12                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8d:	75 08                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9f:	0f b6 11             	movzbl (%ecx),%edx
  800aa2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 09             	cmp    $0x9,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0x8b>
			dig = *s - '0';
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 30             	sub    $0x30,%edx
  800ab2:	eb 22                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 08                	ja     800ac6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 57             	sub    $0x57,%edx
  800ac4:	eb 10                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 16                	ja     800ae6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad9:	7d 0b                	jge    800ae6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae4:	eb b9                	jmp    800a9f <strtol+0x76>

	if (endptr)
  800ae6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aea:	74 0d                	je     800af9 <strtol+0xd0>
		*endptr = (char *) s;
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	89 0e                	mov    %ecx,(%esi)
  800af1:	eb 06                	jmp    800af9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af3:	85 db                	test   %ebx,%ebx
  800af5:	74 98                	je     800a8f <strtol+0x66>
  800af7:	eb 9e                	jmp    800a97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af9:	89 c2                	mov    %eax,%edx
  800afb:	f7 da                	neg    %edx
  800afd:	85 ff                	test   %edi,%edi
  800aff:	0f 45 c2             	cmovne %edx,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	89 c6                	mov    %eax,%esi
  800b1e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	b8 03 00 00 00       	mov    $0x3,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	89 cb                	mov    %ecx,%ebx
  800b5c:	89 cf                	mov    %ecx,%edi
  800b5e:	89 ce                	mov    %ecx,%esi
  800b60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7e 17                	jle    800b7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	50                   	push   %eax
  800b6a:	6a 03                	push   $0x3
  800b6c:	68 df 21 80 00       	push   $0x8021df
  800b71:	6a 23                	push   $0x23
  800b73:	68 fc 21 80 00       	push   $0x8021fc
  800b78:	e8 f7 0f 00 00       	call   801b74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 02 00 00 00       	mov    $0x2,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_yield>:

void
sys_yield(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	be 00 00 00 00       	mov    $0x0,%esi
  800bd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	89 f7                	mov    %esi,%edi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 04                	push   $0x4
  800bed:	68 df 21 80 00       	push   $0x8021df
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 fc 21 80 00       	push   $0x8021fc
  800bf9:	e8 76 0f 00 00       	call   801b74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c20:	8b 75 18             	mov    0x18(%ebp),%esi
  800c23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 05                	push   $0x5
  800c2f:	68 df 21 80 00       	push   $0x8021df
  800c34:	6a 23                	push   $0x23
  800c36:	68 fc 21 80 00       	push   $0x8021fc
  800c3b:	e8 34 0f 00 00       	call   801b74 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 06                	push   $0x6
  800c71:	68 df 21 80 00       	push   $0x8021df
  800c76:	6a 23                	push   $0x23
  800c78:	68 fc 21 80 00       	push   $0x8021fc
  800c7d:	e8 f2 0e 00 00       	call   801b74 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 08                	push   $0x8
  800cb3:	68 df 21 80 00       	push   $0x8021df
  800cb8:	6a 23                	push   $0x23
  800cba:	68 fc 21 80 00       	push   $0x8021fc
  800cbf:	e8 b0 0e 00 00       	call   801b74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 09                	push   $0x9
  800cf5:	68 df 21 80 00       	push   $0x8021df
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 fc 21 80 00       	push   $0x8021fc
  800d01:	e8 6e 0e 00 00       	call   801b74 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 0a                	push   $0xa
  800d37:	68 df 21 80 00       	push   $0x8021df
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 fc 21 80 00       	push   $0x8021fc
  800d43:	e8 2c 0e 00 00       	call   801b74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 0d                	push   $0xd
  800d9b:	68 df 21 80 00       	push   $0x8021df
  800da0:	6a 23                	push   $0x23
  800da2:	68 fc 21 80 00       	push   $0x8021fc
  800da7:	e8 c8 0d 00 00       	call   801b74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	74 0e                	je     800dd4 <ipc_recv+0x20>
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	e8 a4 ff ff ff       	call   800d73 <sys_ipc_recv>
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	eb 10                	jmp    800de4 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	68 00 00 c0 ee       	push   $0xeec00000
  800ddc:	e8 92 ff ff ff       	call   800d73 <sys_ipc_recv>
  800de1:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  800de4:	85 c0                	test   %eax,%eax
  800de6:	74 16                	je     800dfe <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  800de8:	85 f6                	test   %esi,%esi
  800dea:	74 06                	je     800df2 <ipc_recv+0x3e>
  800dec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  800df2:	85 db                	test   %ebx,%ebx
  800df4:	74 2c                	je     800e22 <ipc_recv+0x6e>
  800df6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800dfc:	eb 24                	jmp    800e22 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  800dfe:	85 f6                	test   %esi,%esi
  800e00:	74 0a                	je     800e0c <ipc_recv+0x58>
  800e02:	a1 04 40 80 00       	mov    0x804004,%eax
  800e07:	8b 40 74             	mov    0x74(%eax),%eax
  800e0a:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  800e0c:	85 db                	test   %ebx,%ebx
  800e0e:	74 0a                	je     800e1a <ipc_recv+0x66>
  800e10:	a1 04 40 80 00       	mov    0x804004,%eax
  800e15:	8b 40 78             	mov    0x78(%eax),%eax
  800e18:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  800e1a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e1f:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e38:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800e42:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  800e45:	ff 75 14             	pushl  0x14(%ebp)
  800e48:	53                   	push   %ebx
  800e49:	56                   	push   %esi
  800e4a:	57                   	push   %edi
  800e4b:	e8 00 ff ff ff       	call   800d50 <sys_ipc_try_send>
		if (ret == 0) break;
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	74 1e                	je     800e75 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  800e57:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e5a:	74 12                	je     800e6e <ipc_send+0x45>
  800e5c:	50                   	push   %eax
  800e5d:	68 0a 22 80 00       	push   $0x80220a
  800e62:	6a 39                	push   $0x39
  800e64:	68 17 22 80 00       	push   $0x802217
  800e69:	e8 06 0d 00 00       	call   801b74 <_panic>
		sys_yield();
  800e6e:	e8 31 fd ff ff       	call   800ba4 <sys_yield>
	}
  800e73:	eb d0                	jmp    800e45 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  800e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e88:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e8b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e91:	8b 52 50             	mov    0x50(%edx),%edx
  800e94:	39 ca                	cmp    %ecx,%edx
  800e96:	75 0d                	jne    800ea5 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e98:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e9b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea0:	8b 40 48             	mov    0x48(%eax),%eax
  800ea3:	eb 0f                	jmp    800eb4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ea5:	83 c0 01             	add    $0x1,%eax
  800ea8:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ead:	75 d9                	jne    800e88 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec1:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	c1 ea 16             	shr    $0x16,%edx
  800eed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef4:	f6 c2 01             	test   $0x1,%dl
  800ef7:	74 11                	je     800f0a <fd_alloc+0x2d>
  800ef9:	89 c2                	mov    %eax,%edx
  800efb:	c1 ea 0c             	shr    $0xc,%edx
  800efe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f05:	f6 c2 01             	test   $0x1,%dl
  800f08:	75 09                	jne    800f13 <fd_alloc+0x36>
			*fd_store = fd;
  800f0a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f11:	eb 17                	jmp    800f2a <fd_alloc+0x4d>
  800f13:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f18:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f1d:	75 c9                	jne    800ee8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f1f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f25:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f32:	83 f8 1f             	cmp    $0x1f,%eax
  800f35:	77 36                	ja     800f6d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f37:	c1 e0 0c             	shl    $0xc,%eax
  800f3a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f3f:	89 c2                	mov    %eax,%edx
  800f41:	c1 ea 16             	shr    $0x16,%edx
  800f44:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4b:	f6 c2 01             	test   $0x1,%dl
  800f4e:	74 24                	je     800f74 <fd_lookup+0x48>
  800f50:	89 c2                	mov    %eax,%edx
  800f52:	c1 ea 0c             	shr    $0xc,%edx
  800f55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5c:	f6 c2 01             	test   $0x1,%dl
  800f5f:	74 1a                	je     800f7b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f64:	89 02                	mov    %eax,(%edx)
	return 0;
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	eb 13                	jmp    800f80 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f72:	eb 0c                	jmp    800f80 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f79:	eb 05                	jmp    800f80 <fd_lookup+0x54>
  800f7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8b:	ba a0 22 80 00       	mov    $0x8022a0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f90:	eb 13                	jmp    800fa5 <dev_lookup+0x23>
  800f92:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f95:	39 08                	cmp    %ecx,(%eax)
  800f97:	75 0c                	jne    800fa5 <dev_lookup+0x23>
			*dev = devtab[i];
  800f99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa3:	eb 2e                	jmp    800fd3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fa5:	8b 02                	mov    (%edx),%eax
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	75 e7                	jne    800f92 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fab:	a1 04 40 80 00       	mov    0x804004,%eax
  800fb0:	8b 40 48             	mov    0x48(%eax),%eax
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	51                   	push   %ecx
  800fb7:	50                   	push   %eax
  800fb8:	68 24 22 80 00       	push   $0x802224
  800fbd:	e8 d2 f1 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 10             	sub    $0x10,%esp
  800fdd:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fed:	c1 e8 0c             	shr    $0xc,%eax
  800ff0:	50                   	push   %eax
  800ff1:	e8 36 ff ff ff       	call   800f2c <fd_lookup>
  800ff6:	83 c4 08             	add    $0x8,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 05                	js     801002 <fd_close+0x2d>
	    || fd != fd2)
  800ffd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801000:	74 0c                	je     80100e <fd_close+0x39>
		return (must_exist ? r : 0);
  801002:	84 db                	test   %bl,%bl
  801004:	ba 00 00 00 00       	mov    $0x0,%edx
  801009:	0f 44 c2             	cmove  %edx,%eax
  80100c:	eb 41                	jmp    80104f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801014:	50                   	push   %eax
  801015:	ff 36                	pushl  (%esi)
  801017:	e8 66 ff ff ff       	call   800f82 <dev_lookup>
  80101c:	89 c3                	mov    %eax,%ebx
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 1a                	js     80103f <fd_close+0x6a>
		if (dev->dev_close)
  801025:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801028:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80102b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801030:	85 c0                	test   %eax,%eax
  801032:	74 0b                	je     80103f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	56                   	push   %esi
  801038:	ff d0                	call   *%eax
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	56                   	push   %esi
  801043:	6a 00                	push   $0x0
  801045:	e8 fe fb ff ff       	call   800c48 <sys_page_unmap>
	return r;
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	89 d8                	mov    %ebx,%eax
}
  80104f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105f:	50                   	push   %eax
  801060:	ff 75 08             	pushl  0x8(%ebp)
  801063:	e8 c4 fe ff ff       	call   800f2c <fd_lookup>
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 10                	js     80107f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	6a 01                	push   $0x1
  801074:	ff 75 f4             	pushl  -0xc(%ebp)
  801077:	e8 59 ff ff ff       	call   800fd5 <fd_close>
  80107c:	83 c4 10             	add    $0x10,%esp
}
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <close_all>:

void
close_all(void)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	53                   	push   %ebx
  801085:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801088:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	53                   	push   %ebx
  801091:	e8 c0 ff ff ff       	call   801056 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801096:	83 c3 01             	add    $0x1,%ebx
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	83 fb 20             	cmp    $0x20,%ebx
  80109f:	75 ec                	jne    80108d <close_all+0xc>
		close(i);
}
  8010a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 2c             	sub    $0x2c,%esp
  8010af:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	ff 75 08             	pushl  0x8(%ebp)
  8010b9:	e8 6e fe ff ff       	call   800f2c <fd_lookup>
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	0f 88 c1 00 00 00    	js     80118a <dup+0xe4>
		return r;
	close(newfdnum);
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	56                   	push   %esi
  8010cd:	e8 84 ff ff ff       	call   801056 <close>

	newfd = INDEX2FD(newfdnum);
  8010d2:	89 f3                	mov    %esi,%ebx
  8010d4:	c1 e3 0c             	shl    $0xc,%ebx
  8010d7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010dd:	83 c4 04             	add    $0x4,%esp
  8010e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e3:	e8 de fd ff ff       	call   800ec6 <fd2data>
  8010e8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010ea:	89 1c 24             	mov    %ebx,(%esp)
  8010ed:	e8 d4 fd ff ff       	call   800ec6 <fd2data>
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f8:	89 f8                	mov    %edi,%eax
  8010fa:	c1 e8 16             	shr    $0x16,%eax
  8010fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801104:	a8 01                	test   $0x1,%al
  801106:	74 37                	je     80113f <dup+0x99>
  801108:	89 f8                	mov    %edi,%eax
  80110a:	c1 e8 0c             	shr    $0xc,%eax
  80110d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801114:	f6 c2 01             	test   $0x1,%dl
  801117:	74 26                	je     80113f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801119:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	25 07 0e 00 00       	and    $0xe07,%eax
  801128:	50                   	push   %eax
  801129:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112c:	6a 00                	push   $0x0
  80112e:	57                   	push   %edi
  80112f:	6a 00                	push   $0x0
  801131:	e8 d0 fa ff ff       	call   800c06 <sys_page_map>
  801136:	89 c7                	mov    %eax,%edi
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 2e                	js     80116d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801142:	89 d0                	mov    %edx,%eax
  801144:	c1 e8 0c             	shr    $0xc,%eax
  801147:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	25 07 0e 00 00       	and    $0xe07,%eax
  801156:	50                   	push   %eax
  801157:	53                   	push   %ebx
  801158:	6a 00                	push   $0x0
  80115a:	52                   	push   %edx
  80115b:	6a 00                	push   $0x0
  80115d:	e8 a4 fa ff ff       	call   800c06 <sys_page_map>
  801162:	89 c7                	mov    %eax,%edi
  801164:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801167:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801169:	85 ff                	test   %edi,%edi
  80116b:	79 1d                	jns    80118a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	53                   	push   %ebx
  801171:	6a 00                	push   $0x0
  801173:	e8 d0 fa ff ff       	call   800c48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80117e:	6a 00                	push   $0x0
  801180:	e8 c3 fa ff ff       	call   800c48 <sys_page_unmap>
	return r;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	89 f8                	mov    %edi,%eax
}
  80118a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	53                   	push   %ebx
  801196:	83 ec 14             	sub    $0x14,%esp
  801199:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	53                   	push   %ebx
  8011a1:	e8 86 fd ff ff       	call   800f2c <fd_lookup>
  8011a6:	83 c4 08             	add    $0x8,%esp
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 6d                	js     80121c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b9:	ff 30                	pushl  (%eax)
  8011bb:	e8 c2 fd ff ff       	call   800f82 <dev_lookup>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 4c                	js     801213 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ca:	8b 42 08             	mov    0x8(%edx),%eax
  8011cd:	83 e0 03             	and    $0x3,%eax
  8011d0:	83 f8 01             	cmp    $0x1,%eax
  8011d3:	75 21                	jne    8011f6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8011da:	8b 40 48             	mov    0x48(%eax),%eax
  8011dd:	83 ec 04             	sub    $0x4,%esp
  8011e0:	53                   	push   %ebx
  8011e1:	50                   	push   %eax
  8011e2:	68 65 22 80 00       	push   $0x802265
  8011e7:	e8 a8 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f4:	eb 26                	jmp    80121c <read+0x8a>
	}
	if (!dev->dev_read)
  8011f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f9:	8b 40 08             	mov    0x8(%eax),%eax
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	74 17                	je     801217 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	ff 75 10             	pushl  0x10(%ebp)
  801206:	ff 75 0c             	pushl  0xc(%ebp)
  801209:	52                   	push   %edx
  80120a:	ff d0                	call   *%eax
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	eb 09                	jmp    80121c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	89 c2                	mov    %eax,%edx
  801215:	eb 05                	jmp    80121c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801217:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80121c:	89 d0                	mov    %edx,%eax
  80121e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801221:	c9                   	leave  
  801222:	c3                   	ret    

00801223 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	57                   	push   %edi
  801227:	56                   	push   %esi
  801228:	53                   	push   %ebx
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801232:	bb 00 00 00 00       	mov    $0x0,%ebx
  801237:	eb 21                	jmp    80125a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	89 f0                	mov    %esi,%eax
  80123e:	29 d8                	sub    %ebx,%eax
  801240:	50                   	push   %eax
  801241:	89 d8                	mov    %ebx,%eax
  801243:	03 45 0c             	add    0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	57                   	push   %edi
  801248:	e8 45 ff ff ff       	call   801192 <read>
		if (m < 0)
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 10                	js     801264 <readn+0x41>
			return m;
		if (m == 0)
  801254:	85 c0                	test   %eax,%eax
  801256:	74 0a                	je     801262 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801258:	01 c3                	add    %eax,%ebx
  80125a:	39 f3                	cmp    %esi,%ebx
  80125c:	72 db                	jb     801239 <readn+0x16>
  80125e:	89 d8                	mov    %ebx,%eax
  801260:	eb 02                	jmp    801264 <readn+0x41>
  801262:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5f                   	pop    %edi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	53                   	push   %ebx
  801270:	83 ec 14             	sub    $0x14,%esp
  801273:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801276:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	53                   	push   %ebx
  80127b:	e8 ac fc ff ff       	call   800f2c <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	89 c2                	mov    %eax,%edx
  801285:	85 c0                	test   %eax,%eax
  801287:	78 68                	js     8012f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801293:	ff 30                	pushl  (%eax)
  801295:	e8 e8 fc ff ff       	call   800f82 <dev_lookup>
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 47                	js     8012e8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a8:	75 21                	jne    8012cb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	50                   	push   %eax
  8012b7:	68 81 22 80 00       	push   $0x802281
  8012bc:	e8 d3 ee ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c9:	eb 26                	jmp    8012f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d1:	85 d2                	test   %edx,%edx
  8012d3:	74 17                	je     8012ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d5:	83 ec 04             	sub    $0x4,%esp
  8012d8:	ff 75 10             	pushl  0x10(%ebp)
  8012db:	ff 75 0c             	pushl  0xc(%ebp)
  8012de:	50                   	push   %eax
  8012df:	ff d2                	call   *%edx
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	eb 09                	jmp    8012f1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	eb 05                	jmp    8012f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012f1:	89 d0                	mov    %edx,%eax
  8012f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 22 fc ff ff       	call   800f2c <fd_lookup>
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 0e                	js     80131f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801311:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	53                   	push   %ebx
  801325:	83 ec 14             	sub    $0x14,%esp
  801328:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	53                   	push   %ebx
  801330:	e8 f7 fb ff ff       	call   800f2c <fd_lookup>
  801335:	83 c4 08             	add    $0x8,%esp
  801338:	89 c2                	mov    %eax,%edx
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 65                	js     8013a3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801348:	ff 30                	pushl  (%eax)
  80134a:	e8 33 fc ff ff       	call   800f82 <dev_lookup>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 44                	js     80139a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801356:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801359:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135d:	75 21                	jne    801380 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80135f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801364:	8b 40 48             	mov    0x48(%eax),%eax
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	53                   	push   %ebx
  80136b:	50                   	push   %eax
  80136c:	68 44 22 80 00       	push   $0x802244
  801371:	e8 1e ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80137e:	eb 23                	jmp    8013a3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801380:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801383:	8b 52 18             	mov    0x18(%edx),%edx
  801386:	85 d2                	test   %edx,%edx
  801388:	74 14                	je     80139e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	ff 75 0c             	pushl  0xc(%ebp)
  801390:	50                   	push   %eax
  801391:	ff d2                	call   *%edx
  801393:	89 c2                	mov    %eax,%edx
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	eb 09                	jmp    8013a3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	eb 05                	jmp    8013a3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80139e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013a3:	89 d0                	mov    %edx,%eax
  8013a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 14             	sub    $0x14,%esp
  8013b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b7:	50                   	push   %eax
  8013b8:	ff 75 08             	pushl  0x8(%ebp)
  8013bb:	e8 6c fb ff ff       	call   800f2c <fd_lookup>
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	89 c2                	mov    %eax,%edx
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 58                	js     801421 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c9:	83 ec 08             	sub    $0x8,%esp
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d3:	ff 30                	pushl  (%eax)
  8013d5:	e8 a8 fb ff ff       	call   800f82 <dev_lookup>
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 37                	js     801418 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e8:	74 32                	je     80141c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f4:	00 00 00 
	stat->st_isdir = 0;
  8013f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013fe:	00 00 00 
	stat->st_dev = dev;
  801401:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	53                   	push   %ebx
  80140b:	ff 75 f0             	pushl  -0x10(%ebp)
  80140e:	ff 50 14             	call   *0x14(%eax)
  801411:	89 c2                	mov    %eax,%edx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	eb 09                	jmp    801421 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801418:	89 c2                	mov    %eax,%edx
  80141a:	eb 05                	jmp    801421 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80141c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801421:	89 d0                	mov    %edx,%eax
  801423:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	6a 00                	push   $0x0
  801432:	ff 75 08             	pushl  0x8(%ebp)
  801435:	e8 b7 01 00 00       	call   8015f1 <open>
  80143a:	89 c3                	mov    %eax,%ebx
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 1b                	js     80145e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	ff 75 0c             	pushl  0xc(%ebp)
  801449:	50                   	push   %eax
  80144a:	e8 5b ff ff ff       	call   8013aa <fstat>
  80144f:	89 c6                	mov    %eax,%esi
	close(fd);
  801451:	89 1c 24             	mov    %ebx,(%esp)
  801454:	e8 fd fb ff ff       	call   801056 <close>
	return r;
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	89 f0                	mov    %esi,%eax
}
  80145e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	56                   	push   %esi
  801469:	53                   	push   %ebx
  80146a:	89 c6                	mov    %eax,%esi
  80146c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80146e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801475:	75 12                	jne    801489 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801477:	83 ec 0c             	sub    $0xc,%esp
  80147a:	6a 01                	push   $0x1
  80147c:	e8 fc f9 ff ff       	call   800e7d <ipc_find_env>
  801481:	a3 00 40 80 00       	mov    %eax,0x804000
  801486:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801489:	6a 07                	push   $0x7
  80148b:	68 00 50 80 00       	push   $0x805000
  801490:	56                   	push   %esi
  801491:	ff 35 00 40 80 00    	pushl  0x804000
  801497:	e8 8d f9 ff ff       	call   800e29 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80149c:	83 c4 0c             	add    $0xc,%esp
  80149f:	6a 00                	push   $0x0
  8014a1:	53                   	push   %ebx
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 0b f9 ff ff       	call   800db4 <ipc_recv>
}
  8014a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d3:	e8 8d ff ff ff       	call   801465 <fsipc>
}
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014f5:	e8 6b ff ff ff       	call   801465 <fsipc>
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	8b 40 0c             	mov    0xc(%eax),%eax
  80150c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 05 00 00 00       	mov    $0x5,%eax
  80151b:	e8 45 ff ff ff       	call   801465 <fsipc>
  801520:	85 c0                	test   %eax,%eax
  801522:	78 2c                	js     801550 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	68 00 50 80 00       	push   $0x805000
  80152c:	53                   	push   %ebx
  80152d:	e8 8e f2 ff ff       	call   8007c0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801532:	a1 80 50 80 00       	mov    0x805080,%eax
  801537:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80153d:	a1 84 50 80 00       	mov    0x805084,%eax
  801542:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80155b:	68 b0 22 80 00       	push   $0x8022b0
  801560:	68 90 00 00 00       	push   $0x90
  801565:	68 ce 22 80 00       	push   $0x8022ce
  80156a:	e8 05 06 00 00       	call   801b74 <_panic>

0080156f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	56                   	push   %esi
  801573:	53                   	push   %ebx
  801574:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	8b 40 0c             	mov    0xc(%eax),%eax
  80157d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801582:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801588:	ba 00 00 00 00       	mov    $0x0,%edx
  80158d:	b8 03 00 00 00       	mov    $0x3,%eax
  801592:	e8 ce fe ff ff       	call   801465 <fsipc>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 4b                	js     8015e8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80159d:	39 c6                	cmp    %eax,%esi
  80159f:	73 16                	jae    8015b7 <devfile_read+0x48>
  8015a1:	68 d9 22 80 00       	push   $0x8022d9
  8015a6:	68 e0 22 80 00       	push   $0x8022e0
  8015ab:	6a 7c                	push   $0x7c
  8015ad:	68 ce 22 80 00       	push   $0x8022ce
  8015b2:	e8 bd 05 00 00       	call   801b74 <_panic>
	assert(r <= PGSIZE);
  8015b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015bc:	7e 16                	jle    8015d4 <devfile_read+0x65>
  8015be:	68 f5 22 80 00       	push   $0x8022f5
  8015c3:	68 e0 22 80 00       	push   $0x8022e0
  8015c8:	6a 7d                	push   $0x7d
  8015ca:	68 ce 22 80 00       	push   $0x8022ce
  8015cf:	e8 a0 05 00 00       	call   801b74 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015d4:	83 ec 04             	sub    $0x4,%esp
  8015d7:	50                   	push   %eax
  8015d8:	68 00 50 80 00       	push   $0x805000
  8015dd:	ff 75 0c             	pushl  0xc(%ebp)
  8015e0:	e8 6d f3 ff ff       	call   800952 <memmove>
	return r;
  8015e5:	83 c4 10             	add    $0x10,%esp
}
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    

008015f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 20             	sub    $0x20,%esp
  8015f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015fb:	53                   	push   %ebx
  8015fc:	e8 86 f1 ff ff       	call   800787 <strlen>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801609:	7f 67                	jg     801672 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	e8 c6 f8 ff ff       	call   800edd <fd_alloc>
  801617:	83 c4 10             	add    $0x10,%esp
		return r;
  80161a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 57                	js     801677 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	53                   	push   %ebx
  801624:	68 00 50 80 00       	push   $0x805000
  801629:	e8 92 f1 ff ff       	call   8007c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80162e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801631:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801636:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801639:	b8 01 00 00 00       	mov    $0x1,%eax
  80163e:	e8 22 fe ff ff       	call   801465 <fsipc>
  801643:	89 c3                	mov    %eax,%ebx
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	85 c0                	test   %eax,%eax
  80164a:	79 14                	jns    801660 <open+0x6f>
		fd_close(fd, 0);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	6a 00                	push   $0x0
  801651:	ff 75 f4             	pushl  -0xc(%ebp)
  801654:	e8 7c f9 ff ff       	call   800fd5 <fd_close>
		return r;
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	89 da                	mov    %ebx,%edx
  80165e:	eb 17                	jmp    801677 <open+0x86>
	}

	return fd2num(fd);
  801660:	83 ec 0c             	sub    $0xc,%esp
  801663:	ff 75 f4             	pushl  -0xc(%ebp)
  801666:	e8 4b f8 ff ff       	call   800eb6 <fd2num>
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	eb 05                	jmp    801677 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801672:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801677:	89 d0                	mov    %edx,%eax
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801684:	ba 00 00 00 00       	mov    $0x0,%edx
  801689:	b8 08 00 00 00       	mov    $0x8,%eax
  80168e:	e8 d2 fd ff ff       	call   801465 <fsipc>
}
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	56                   	push   %esi
  801699:	53                   	push   %ebx
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80169d:	83 ec 0c             	sub    $0xc,%esp
  8016a0:	ff 75 08             	pushl  0x8(%ebp)
  8016a3:	e8 1e f8 ff ff       	call   800ec6 <fd2data>
  8016a8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016aa:	83 c4 08             	add    $0x8,%esp
  8016ad:	68 01 23 80 00       	push   $0x802301
  8016b2:	53                   	push   %ebx
  8016b3:	e8 08 f1 ff ff       	call   8007c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016b8:	8b 46 04             	mov    0x4(%esi),%eax
  8016bb:	2b 06                	sub    (%esi),%eax
  8016bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ca:	00 00 00 
	stat->st_dev = &devpipe;
  8016cd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016d4:	30 80 00 
	return 0;
}
  8016d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 0c             	sub    $0xc,%esp
  8016ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ed:	53                   	push   %ebx
  8016ee:	6a 00                	push   $0x0
  8016f0:	e8 53 f5 ff ff       	call   800c48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016f5:	89 1c 24             	mov    %ebx,(%esp)
  8016f8:	e8 c9 f7 ff ff       	call   800ec6 <fd2data>
  8016fd:	83 c4 08             	add    $0x8,%esp
  801700:	50                   	push   %eax
  801701:	6a 00                	push   $0x0
  801703:	e8 40 f5 ff ff       	call   800c48 <sys_page_unmap>
}
  801708:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	57                   	push   %edi
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
  801713:	83 ec 1c             	sub    $0x1c,%esp
  801716:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801719:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80171b:	a1 04 40 80 00       	mov    0x804004,%eax
  801720:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	ff 75 e0             	pushl  -0x20(%ebp)
  801729:	e8 8c 04 00 00       	call   801bba <pageref>
  80172e:	89 c3                	mov    %eax,%ebx
  801730:	89 3c 24             	mov    %edi,(%esp)
  801733:	e8 82 04 00 00       	call   801bba <pageref>
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	39 c3                	cmp    %eax,%ebx
  80173d:	0f 94 c1             	sete   %cl
  801740:	0f b6 c9             	movzbl %cl,%ecx
  801743:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801746:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80174c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80174f:	39 ce                	cmp    %ecx,%esi
  801751:	74 1b                	je     80176e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801753:	39 c3                	cmp    %eax,%ebx
  801755:	75 c4                	jne    80171b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801757:	8b 42 58             	mov    0x58(%edx),%eax
  80175a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175d:	50                   	push   %eax
  80175e:	56                   	push   %esi
  80175f:	68 08 23 80 00       	push   $0x802308
  801764:	e8 2b ea ff ff       	call   800194 <cprintf>
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	eb ad                	jmp    80171b <_pipeisclosed+0xe>
	}
}
  80176e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801771:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	57                   	push   %edi
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
  80177f:	83 ec 28             	sub    $0x28,%esp
  801782:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801785:	56                   	push   %esi
  801786:	e8 3b f7 ff ff       	call   800ec6 <fd2data>
  80178b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	bf 00 00 00 00       	mov    $0x0,%edi
  801795:	eb 4b                	jmp    8017e2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801797:	89 da                	mov    %ebx,%edx
  801799:	89 f0                	mov    %esi,%eax
  80179b:	e8 6d ff ff ff       	call   80170d <_pipeisclosed>
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	75 48                	jne    8017ec <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017a4:	e8 fb f3 ff ff       	call   800ba4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8017ac:	8b 0b                	mov    (%ebx),%ecx
  8017ae:	8d 51 20             	lea    0x20(%ecx),%edx
  8017b1:	39 d0                	cmp    %edx,%eax
  8017b3:	73 e2                	jae    801797 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017bc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	c1 fa 1f             	sar    $0x1f,%edx
  8017c4:	89 d1                	mov    %edx,%ecx
  8017c6:	c1 e9 1b             	shr    $0x1b,%ecx
  8017c9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017cc:	83 e2 1f             	and    $0x1f,%edx
  8017cf:	29 ca                	sub    %ecx,%edx
  8017d1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017d9:	83 c0 01             	add    $0x1,%eax
  8017dc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017df:	83 c7 01             	add    $0x1,%edi
  8017e2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017e5:	75 c2                	jne    8017a9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ea:	eb 05                	jmp    8017f1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5f                   	pop    %edi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	57                   	push   %edi
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 18             	sub    $0x18,%esp
  801802:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801805:	57                   	push   %edi
  801806:	e8 bb f6 ff ff       	call   800ec6 <fd2data>
  80180b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	bb 00 00 00 00       	mov    $0x0,%ebx
  801815:	eb 3d                	jmp    801854 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801817:	85 db                	test   %ebx,%ebx
  801819:	74 04                	je     80181f <devpipe_read+0x26>
				return i;
  80181b:	89 d8                	mov    %ebx,%eax
  80181d:	eb 44                	jmp    801863 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80181f:	89 f2                	mov    %esi,%edx
  801821:	89 f8                	mov    %edi,%eax
  801823:	e8 e5 fe ff ff       	call   80170d <_pipeisclosed>
  801828:	85 c0                	test   %eax,%eax
  80182a:	75 32                	jne    80185e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80182c:	e8 73 f3 ff ff       	call   800ba4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801831:	8b 06                	mov    (%esi),%eax
  801833:	3b 46 04             	cmp    0x4(%esi),%eax
  801836:	74 df                	je     801817 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801838:	99                   	cltd   
  801839:	c1 ea 1b             	shr    $0x1b,%edx
  80183c:	01 d0                	add    %edx,%eax
  80183e:	83 e0 1f             	and    $0x1f,%eax
  801841:	29 d0                	sub    %edx,%eax
  801843:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80184e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801851:	83 c3 01             	add    $0x1,%ebx
  801854:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801857:	75 d8                	jne    801831 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801859:	8b 45 10             	mov    0x10(%ebp),%eax
  80185c:	eb 05                	jmp    801863 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80185e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801863:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5f                   	pop    %edi
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	56                   	push   %esi
  80186f:	53                   	push   %ebx
  801870:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801873:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	e8 61 f6 ff ff       	call   800edd <fd_alloc>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	89 c2                	mov    %eax,%edx
  801881:	85 c0                	test   %eax,%eax
  801883:	0f 88 2c 01 00 00    	js     8019b5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	68 07 04 00 00       	push   $0x407
  801891:	ff 75 f4             	pushl  -0xc(%ebp)
  801894:	6a 00                	push   $0x0
  801896:	e8 28 f3 ff ff       	call   800bc3 <sys_page_alloc>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	89 c2                	mov    %eax,%edx
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	0f 88 0d 01 00 00    	js     8019b5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018a8:	83 ec 0c             	sub    $0xc,%esp
  8018ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ae:	50                   	push   %eax
  8018af:	e8 29 f6 ff ff       	call   800edd <fd_alloc>
  8018b4:	89 c3                	mov    %eax,%ebx
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	0f 88 e2 00 00 00    	js     8019a3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	68 07 04 00 00       	push   $0x407
  8018c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cc:	6a 00                	push   $0x0
  8018ce:	e8 f0 f2 ff ff       	call   800bc3 <sys_page_alloc>
  8018d3:	89 c3                	mov    %eax,%ebx
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	0f 88 c3 00 00 00    	js     8019a3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018e0:	83 ec 0c             	sub    $0xc,%esp
  8018e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e6:	e8 db f5 ff ff       	call   800ec6 <fd2data>
  8018eb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ed:	83 c4 0c             	add    $0xc,%esp
  8018f0:	68 07 04 00 00       	push   $0x407
  8018f5:	50                   	push   %eax
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 c6 f2 ff ff       	call   800bc3 <sys_page_alloc>
  8018fd:	89 c3                	mov    %eax,%ebx
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	85 c0                	test   %eax,%eax
  801904:	0f 88 89 00 00 00    	js     801993 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80190a:	83 ec 0c             	sub    $0xc,%esp
  80190d:	ff 75 f0             	pushl  -0x10(%ebp)
  801910:	e8 b1 f5 ff ff       	call   800ec6 <fd2data>
  801915:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80191c:	50                   	push   %eax
  80191d:	6a 00                	push   $0x0
  80191f:	56                   	push   %esi
  801920:	6a 00                	push   $0x0
  801922:	e8 df f2 ff ff       	call   800c06 <sys_page_map>
  801927:	89 c3                	mov    %eax,%ebx
  801929:	83 c4 20             	add    $0x20,%esp
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 55                	js     801985 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801930:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801936:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801939:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80193b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801945:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801950:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801953:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	e8 51 f5 ff ff       	call   800eb6 <fd2num>
  801965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801968:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80196a:	83 c4 04             	add    $0x4,%esp
  80196d:	ff 75 f0             	pushl  -0x10(%ebp)
  801970:	e8 41 f5 ff ff       	call   800eb6 <fd2num>
  801975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801978:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	ba 00 00 00 00       	mov    $0x0,%edx
  801983:	eb 30                	jmp    8019b5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	56                   	push   %esi
  801989:	6a 00                	push   $0x0
  80198b:	e8 b8 f2 ff ff       	call   800c48 <sys_page_unmap>
  801990:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	ff 75 f0             	pushl  -0x10(%ebp)
  801999:	6a 00                	push   $0x0
  80199b:	e8 a8 f2 ff ff       	call   800c48 <sys_page_unmap>
  8019a0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a9:	6a 00                	push   $0x0
  8019ab:	e8 98 f2 ff ff       	call   800c48 <sys_page_unmap>
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019b5:	89 d0                	mov    %edx,%eax
  8019b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	50                   	push   %eax
  8019c8:	ff 75 08             	pushl  0x8(%ebp)
  8019cb:	e8 5c f5 ff ff       	call   800f2c <fd_lookup>
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 18                	js     8019ef <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	e8 e4 f4 ff ff       	call   800ec6 <fd2data>
	return _pipeisclosed(fd, p);
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e7:	e8 21 fd ff ff       	call   80170d <_pipeisclosed>
  8019ec:	83 c4 10             	add    $0x10,%esp
}
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a01:	68 20 23 80 00       	push   $0x802320
  801a06:	ff 75 0c             	pushl  0xc(%ebp)
  801a09:	e8 b2 ed ff ff       	call   8007c0 <strcpy>
	return 0;
}
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	57                   	push   %edi
  801a19:	56                   	push   %esi
  801a1a:	53                   	push   %ebx
  801a1b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a21:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a26:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a2c:	eb 2d                	jmp    801a5b <devcons_write+0x46>
		m = n - tot;
  801a2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a31:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a33:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a36:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a3b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	53                   	push   %ebx
  801a42:	03 45 0c             	add    0xc(%ebp),%eax
  801a45:	50                   	push   %eax
  801a46:	57                   	push   %edi
  801a47:	e8 06 ef ff ff       	call   800952 <memmove>
		sys_cputs(buf, m);
  801a4c:	83 c4 08             	add    $0x8,%esp
  801a4f:	53                   	push   %ebx
  801a50:	57                   	push   %edi
  801a51:	e8 b1 f0 ff ff       	call   800b07 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a56:	01 de                	add    %ebx,%esi
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	89 f0                	mov    %esi,%eax
  801a5d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a60:	72 cc                	jb     801a2e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5f                   	pop    %edi
  801a68:	5d                   	pop    %ebp
  801a69:	c3                   	ret    

00801a6a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	83 ec 08             	sub    $0x8,%esp
  801a70:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a79:	74 2a                	je     801aa5 <devcons_read+0x3b>
  801a7b:	eb 05                	jmp    801a82 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a7d:	e8 22 f1 ff ff       	call   800ba4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a82:	e8 9e f0 ff ff       	call   800b25 <sys_cgetc>
  801a87:	85 c0                	test   %eax,%eax
  801a89:	74 f2                	je     801a7d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 16                	js     801aa5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a8f:	83 f8 04             	cmp    $0x4,%eax
  801a92:	74 0c                	je     801aa0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a97:	88 02                	mov    %al,(%edx)
	return 1;
  801a99:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9e:	eb 05                	jmp    801aa5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aa0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ab3:	6a 01                	push   $0x1
  801ab5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	e8 49 f0 ff ff       	call   800b07 <sys_cputs>
}
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <getchar>:

int
getchar(void)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ac9:	6a 01                	push   $0x1
  801acb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ace:	50                   	push   %eax
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 bc f6 ff ff       	call   801192 <read>
	if (r < 0)
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	78 0f                	js     801aec <getchar+0x29>
		return r;
	if (r < 1)
  801add:	85 c0                	test   %eax,%eax
  801adf:	7e 06                	jle    801ae7 <getchar+0x24>
		return -E_EOF;
	return c;
  801ae1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ae5:	eb 05                	jmp    801aec <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ae7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af7:	50                   	push   %eax
  801af8:	ff 75 08             	pushl  0x8(%ebp)
  801afb:	e8 2c f4 ff ff       	call   800f2c <fd_lookup>
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	78 11                	js     801b18 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b10:	39 10                	cmp    %edx,(%eax)
  801b12:	0f 94 c0             	sete   %al
  801b15:	0f b6 c0             	movzbl %al,%eax
}
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <opencons>:

int
opencons(void)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b23:	50                   	push   %eax
  801b24:	e8 b4 f3 ff ff       	call   800edd <fd_alloc>
  801b29:	83 c4 10             	add    $0x10,%esp
		return r;
  801b2c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 3e                	js     801b70 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	68 07 04 00 00       	push   $0x407
  801b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 7f f0 ff ff       	call   800bc3 <sys_page_alloc>
  801b44:	83 c4 10             	add    $0x10,%esp
		return r;
  801b47:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 23                	js     801b70 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b62:	83 ec 0c             	sub    $0xc,%esp
  801b65:	50                   	push   %eax
  801b66:	e8 4b f3 ff ff       	call   800eb6 <fd2num>
  801b6b:	89 c2                	mov    %eax,%edx
  801b6d:	83 c4 10             	add    $0x10,%esp
}
  801b70:	89 d0                	mov    %edx,%eax
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	56                   	push   %esi
  801b78:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b79:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b7c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b82:	e8 fe ef ff ff       	call   800b85 <sys_getenvid>
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	ff 75 0c             	pushl  0xc(%ebp)
  801b8d:	ff 75 08             	pushl  0x8(%ebp)
  801b90:	56                   	push   %esi
  801b91:	50                   	push   %eax
  801b92:	68 2c 23 80 00       	push   $0x80232c
  801b97:	e8 f8 e5 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b9c:	83 c4 18             	add    $0x18,%esp
  801b9f:	53                   	push   %ebx
  801ba0:	ff 75 10             	pushl  0x10(%ebp)
  801ba3:	e8 9b e5 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801ba8:	c7 04 24 19 23 80 00 	movl   $0x802319,(%esp)
  801baf:	e8 e0 e5 ff ff       	call   800194 <cprintf>
  801bb4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bb7:	cc                   	int3   
  801bb8:	eb fd                	jmp    801bb7 <_panic+0x43>

00801bba <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc0:	89 d0                	mov    %edx,%eax
  801bc2:	c1 e8 16             	shr    $0x16,%eax
  801bc5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd1:	f6 c1 01             	test   $0x1,%cl
  801bd4:	74 1d                	je     801bf3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bd6:	c1 ea 0c             	shr    $0xc,%edx
  801bd9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801be0:	f6 c2 01             	test   $0x1,%dl
  801be3:	74 0e                	je     801bf3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801be5:	c1 ea 0c             	shr    $0xc,%edx
  801be8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bef:	ef 
  801bf0:	0f b7 c0             	movzwl %ax,%eax
}
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    
  801bf5:	66 90                	xchg   %ax,%ax
  801bf7:	66 90                	xchg   %ax,%ax
  801bf9:	66 90                	xchg   %ax,%ax
  801bfb:	66 90                	xchg   %ax,%ax
  801bfd:	66 90                	xchg   %ax,%ax
  801bff:	90                   	nop

00801c00 <__udivdi3>:
  801c00:	55                   	push   %ebp
  801c01:	57                   	push   %edi
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	83 ec 1c             	sub    $0x1c,%esp
  801c07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c17:	85 f6                	test   %esi,%esi
  801c19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c1d:	89 ca                	mov    %ecx,%edx
  801c1f:	89 f8                	mov    %edi,%eax
  801c21:	75 3d                	jne    801c60 <__udivdi3+0x60>
  801c23:	39 cf                	cmp    %ecx,%edi
  801c25:	0f 87 c5 00 00 00    	ja     801cf0 <__udivdi3+0xf0>
  801c2b:	85 ff                	test   %edi,%edi
  801c2d:	89 fd                	mov    %edi,%ebp
  801c2f:	75 0b                	jne    801c3c <__udivdi3+0x3c>
  801c31:	b8 01 00 00 00       	mov    $0x1,%eax
  801c36:	31 d2                	xor    %edx,%edx
  801c38:	f7 f7                	div    %edi
  801c3a:	89 c5                	mov    %eax,%ebp
  801c3c:	89 c8                	mov    %ecx,%eax
  801c3e:	31 d2                	xor    %edx,%edx
  801c40:	f7 f5                	div    %ebp
  801c42:	89 c1                	mov    %eax,%ecx
  801c44:	89 d8                	mov    %ebx,%eax
  801c46:	89 cf                	mov    %ecx,%edi
  801c48:	f7 f5                	div    %ebp
  801c4a:	89 c3                	mov    %eax,%ebx
  801c4c:	89 d8                	mov    %ebx,%eax
  801c4e:	89 fa                	mov    %edi,%edx
  801c50:	83 c4 1c             	add    $0x1c,%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    
  801c58:	90                   	nop
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	39 ce                	cmp    %ecx,%esi
  801c62:	77 74                	ja     801cd8 <__udivdi3+0xd8>
  801c64:	0f bd fe             	bsr    %esi,%edi
  801c67:	83 f7 1f             	xor    $0x1f,%edi
  801c6a:	0f 84 98 00 00 00    	je     801d08 <__udivdi3+0x108>
  801c70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	89 c5                	mov    %eax,%ebp
  801c79:	29 fb                	sub    %edi,%ebx
  801c7b:	d3 e6                	shl    %cl,%esi
  801c7d:	89 d9                	mov    %ebx,%ecx
  801c7f:	d3 ed                	shr    %cl,%ebp
  801c81:	89 f9                	mov    %edi,%ecx
  801c83:	d3 e0                	shl    %cl,%eax
  801c85:	09 ee                	or     %ebp,%esi
  801c87:	89 d9                	mov    %ebx,%ecx
  801c89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c8d:	89 d5                	mov    %edx,%ebp
  801c8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c93:	d3 ed                	shr    %cl,%ebp
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e2                	shl    %cl,%edx
  801c99:	89 d9                	mov    %ebx,%ecx
  801c9b:	d3 e8                	shr    %cl,%eax
  801c9d:	09 c2                	or     %eax,%edx
  801c9f:	89 d0                	mov    %edx,%eax
  801ca1:	89 ea                	mov    %ebp,%edx
  801ca3:	f7 f6                	div    %esi
  801ca5:	89 d5                	mov    %edx,%ebp
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	f7 64 24 0c          	mull   0xc(%esp)
  801cad:	39 d5                	cmp    %edx,%ebp
  801caf:	72 10                	jb     801cc1 <__udivdi3+0xc1>
  801cb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	d3 e6                	shl    %cl,%esi
  801cb9:	39 c6                	cmp    %eax,%esi
  801cbb:	73 07                	jae    801cc4 <__udivdi3+0xc4>
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	75 03                	jne    801cc4 <__udivdi3+0xc4>
  801cc1:	83 eb 01             	sub    $0x1,%ebx
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 d8                	mov    %ebx,%eax
  801cc8:	89 fa                	mov    %edi,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	31 ff                	xor    %edi,%edi
  801cda:	31 db                	xor    %ebx,%ebx
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
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	f7 f7                	div    %edi
  801cf4:	31 ff                	xor    %edi,%edi
  801cf6:	89 c3                	mov    %eax,%ebx
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	89 fa                	mov    %edi,%edx
  801cfc:	83 c4 1c             	add    $0x1c,%esp
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	39 ce                	cmp    %ecx,%esi
  801d0a:	72 0c                	jb     801d18 <__udivdi3+0x118>
  801d0c:	31 db                	xor    %ebx,%ebx
  801d0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d12:	0f 87 34 ff ff ff    	ja     801c4c <__udivdi3+0x4c>
  801d18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d1d:	e9 2a ff ff ff       	jmp    801c4c <__udivdi3+0x4c>
  801d22:	66 90                	xchg   %ax,%ax
  801d24:	66 90                	xchg   %ax,%ax
  801d26:	66 90                	xchg   %ax,%ax
  801d28:	66 90                	xchg   %ax,%ax
  801d2a:	66 90                	xchg   %ax,%ax
  801d2c:	66 90                	xchg   %ax,%ax
  801d2e:	66 90                	xchg   %ax,%ax

00801d30 <__umoddi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 1c             	sub    $0x1c,%esp
  801d37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d47:	85 d2                	test   %edx,%edx
  801d49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 f3                	mov    %esi,%ebx
  801d53:	89 3c 24             	mov    %edi,(%esp)
  801d56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5a:	75 1c                	jne    801d78 <__umoddi3+0x48>
  801d5c:	39 f7                	cmp    %esi,%edi
  801d5e:	76 50                	jbe    801db0 <__umoddi3+0x80>
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	f7 f7                	div    %edi
  801d66:	89 d0                	mov    %edx,%eax
  801d68:	31 d2                	xor    %edx,%edx
  801d6a:	83 c4 1c             	add    $0x1c,%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
  801d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d78:	39 f2                	cmp    %esi,%edx
  801d7a:	89 d0                	mov    %edx,%eax
  801d7c:	77 52                	ja     801dd0 <__umoddi3+0xa0>
  801d7e:	0f bd ea             	bsr    %edx,%ebp
  801d81:	83 f5 1f             	xor    $0x1f,%ebp
  801d84:	75 5a                	jne    801de0 <__umoddi3+0xb0>
  801d86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d8a:	0f 82 e0 00 00 00    	jb     801e70 <__umoddi3+0x140>
  801d90:	39 0c 24             	cmp    %ecx,(%esp)
  801d93:	0f 86 d7 00 00 00    	jbe    801e70 <__umoddi3+0x140>
  801d99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da1:	83 c4 1c             	add    $0x1c,%esp
  801da4:	5b                   	pop    %ebx
  801da5:	5e                   	pop    %esi
  801da6:	5f                   	pop    %edi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	85 ff                	test   %edi,%edi
  801db2:	89 fd                	mov    %edi,%ebp
  801db4:	75 0b                	jne    801dc1 <__umoddi3+0x91>
  801db6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	f7 f7                	div    %edi
  801dbf:	89 c5                	mov    %eax,%ebp
  801dc1:	89 f0                	mov    %esi,%eax
  801dc3:	31 d2                	xor    %edx,%edx
  801dc5:	f7 f5                	div    %ebp
  801dc7:	89 c8                	mov    %ecx,%eax
  801dc9:	f7 f5                	div    %ebp
  801dcb:	89 d0                	mov    %edx,%eax
  801dcd:	eb 99                	jmp    801d68 <__umoddi3+0x38>
  801dcf:	90                   	nop
  801dd0:	89 c8                	mov    %ecx,%eax
  801dd2:	89 f2                	mov    %esi,%edx
  801dd4:	83 c4 1c             	add    $0x1c,%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    
  801ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de0:	8b 34 24             	mov    (%esp),%esi
  801de3:	bf 20 00 00 00       	mov    $0x20,%edi
  801de8:	89 e9                	mov    %ebp,%ecx
  801dea:	29 ef                	sub    %ebp,%edi
  801dec:	d3 e0                	shl    %cl,%eax
  801dee:	89 f9                	mov    %edi,%ecx
  801df0:	89 f2                	mov    %esi,%edx
  801df2:	d3 ea                	shr    %cl,%edx
  801df4:	89 e9                	mov    %ebp,%ecx
  801df6:	09 c2                	or     %eax,%edx
  801df8:	89 d8                	mov    %ebx,%eax
  801dfa:	89 14 24             	mov    %edx,(%esp)
  801dfd:	89 f2                	mov    %esi,%edx
  801dff:	d3 e2                	shl    %cl,%edx
  801e01:	89 f9                	mov    %edi,%ecx
  801e03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e0b:	d3 e8                	shr    %cl,%eax
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	89 c6                	mov    %eax,%esi
  801e11:	d3 e3                	shl    %cl,%ebx
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 d0                	mov    %edx,%eax
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	09 d8                	or     %ebx,%eax
  801e1d:	89 d3                	mov    %edx,%ebx
  801e1f:	89 f2                	mov    %esi,%edx
  801e21:	f7 34 24             	divl   (%esp)
  801e24:	89 d6                	mov    %edx,%esi
  801e26:	d3 e3                	shl    %cl,%ebx
  801e28:	f7 64 24 04          	mull   0x4(%esp)
  801e2c:	39 d6                	cmp    %edx,%esi
  801e2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e32:	89 d1                	mov    %edx,%ecx
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	72 08                	jb     801e40 <__umoddi3+0x110>
  801e38:	75 11                	jne    801e4b <__umoddi3+0x11b>
  801e3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e3e:	73 0b                	jae    801e4b <__umoddi3+0x11b>
  801e40:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e44:	1b 14 24             	sbb    (%esp),%edx
  801e47:	89 d1                	mov    %edx,%ecx
  801e49:	89 c3                	mov    %eax,%ebx
  801e4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e4f:	29 da                	sub    %ebx,%edx
  801e51:	19 ce                	sbb    %ecx,%esi
  801e53:	89 f9                	mov    %edi,%ecx
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	d3 e0                	shl    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	d3 ea                	shr    %cl,%edx
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	d3 ee                	shr    %cl,%esi
  801e61:	09 d0                	or     %edx,%eax
  801e63:	89 f2                	mov    %esi,%edx
  801e65:	83 c4 1c             	add    $0x1c,%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5f                   	pop    %edi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    
  801e6d:	8d 76 00             	lea    0x0(%esi),%esi
  801e70:	29 f9                	sub    %edi,%ecx
  801e72:	19 d6                	sbb    %edx,%esi
  801e74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e7c:	e9 18 ff ff ff       	jmp    801d99 <__umoddi3+0x69>
