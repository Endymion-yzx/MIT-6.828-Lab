
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 f9 0c 00 00       	call   800d43 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 c0 1f 80 00       	push   $0x801fc0
  800057:	6a 20                	push   $0x20
  800059:	68 d3 1f 80 00       	push   $0x801fd3
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 10 0d 00 00       	call   800d86 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 e3 1f 80 00       	push   $0x801fe3
  800083:	6a 22                	push   $0x22
  800085:	68 d3 1f 80 00       	push   $0x801fd3
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 30 0a 00 00       	call   800ad2 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 17 0d 00 00       	call   800dc8 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 f4 1f 80 00       	push   $0x801ff4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 d3 1f 80 00       	push   $0x801fd3
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 07 20 80 00       	push   $0x802007
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 d3 1f 80 00       	push   $0x801fd3
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 02 0c 00 00       	call   800d05 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 a9 0c 00 00       	call   800e0a <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 17 20 80 00       	push   $0x802017
  80016e:	6a 4c                	push   $0x4c
  800170:	68 d3 1f 80 00       	push   $0x801fd3
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 35 20 80 00       	mov    $0x802035,%esi
  80019a:	b8 2e 20 80 00       	mov    $0x80202e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 3b 20 80 00       	push   $0x80203b
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 67 0b 00 00       	call   800d24 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  8001e6:	e8 1a 0b 00 00       	call   800d05 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 d3 0e 00 00       	call   8010ff <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 8e 0a 00 00       	call   800cc4 <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 b7 0a 00 00       	call   800d05 <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 58 20 80 00       	push   $0x802058
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 4b 20 80 00 	movl   $0x80204b,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 d6 09 00 00       	call   800c87 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 1a 01 00 00       	call   800411 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 7b 09 00 00       	call   800c87 <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 b4 19 00 00       	call   801d30 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 a1 1a 00 00       	call   801e60 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 7b 20 80 00 	movsbl 0x80207b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e6:	73 0a                	jae    8003f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003eb:	89 08                	mov    %ecx,(%eax)
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	88 02                	mov    %al,(%edx)
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fd:	50                   	push   %eax
  8003fe:	ff 75 10             	pushl  0x10(%ebp)
  800401:	ff 75 0c             	pushl  0xc(%ebp)
  800404:	ff 75 08             	pushl  0x8(%ebp)
  800407:	e8 05 00 00 00       	call   800411 <vprintfmt>
	va_end(ap);
}
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 2c             	sub    $0x2c,%esp
  80041a:	8b 75 08             	mov    0x8(%ebp),%esi
  80041d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800420:	8b 7d 10             	mov    0x10(%ebp),%edi
  800423:	eb 12                	jmp    800437 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800425:	85 c0                	test   %eax,%eax
  800427:	0f 84 6a 04 00 00    	je     800897 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	53                   	push   %ebx
  800431:	50                   	push   %eax
  800432:	ff d6                	call   *%esi
  800434:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800437:	83 c7 01             	add    $0x1,%edi
  80043a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80043e:	83 f8 25             	cmp    $0x25,%eax
  800441:	75 e2                	jne    800425 <vprintfmt+0x14>
  800443:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800447:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800455:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800461:	eb 07                	jmp    80046a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800466:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8d 47 01             	lea    0x1(%edi),%eax
  80046d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800470:	0f b6 07             	movzbl (%edi),%eax
  800473:	0f b6 d0             	movzbl %al,%edx
  800476:	83 e8 23             	sub    $0x23,%eax
  800479:	3c 55                	cmp    $0x55,%al
  80047b:	0f 87 fb 03 00 00    	ja     80087c <vprintfmt+0x46b>
  800481:	0f b6 c0             	movzbl %al,%eax
  800484:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800492:	eb d6                	jmp    80046a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ac:	83 f9 09             	cmp    $0x9,%ecx
  8004af:	77 3f                	ja     8004f0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b4:	eb e9                	jmp    80049f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 40 04             	lea    0x4(%eax),%eax
  8004c4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ca:	eb 2a                	jmp    8004f6 <vprintfmt+0xe5>
  8004cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	0f 49 d0             	cmovns %eax,%edx
  8004d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	eb 89                	jmp    80046a <vprintfmt+0x59>
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004eb:	e9 7a ff ff ff       	jmp    80046a <vprintfmt+0x59>
  8004f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fa:	0f 89 6a ff ff ff    	jns    80046a <vprintfmt+0x59>
				width = precision, precision = -1;
  800500:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800503:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800506:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050d:	e9 58 ff ff ff       	jmp    80046a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800512:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800518:	e9 4d ff ff ff       	jmp    80046a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 78 04             	lea    0x4(%eax),%edi
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	ff 30                	pushl  (%eax)
  800529:	ff d6                	call   *%esi
			break;
  80052b:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800534:	e9 fe fe ff ff       	jmp    800437 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 78 04             	lea    0x4(%eax),%edi
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	99                   	cltd   
  800542:	31 d0                	xor    %edx,%eax
  800544:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800546:	83 f8 0f             	cmp    $0xf,%eax
  800549:	7f 0b                	jg     800556 <vprintfmt+0x145>
  80054b:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  800552:	85 d2                	test   %edx,%edx
  800554:	75 1b                	jne    800571 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800556:	50                   	push   %eax
  800557:	68 93 20 80 00       	push   $0x802093
  80055c:	53                   	push   %ebx
  80055d:	56                   	push   %esi
  80055e:	e8 91 fe ff ff       	call   8003f4 <printfmt>
  800563:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800566:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056c:	e9 c6 fe ff ff       	jmp    800437 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800571:	52                   	push   %edx
  800572:	68 7e 24 80 00       	push   $0x80247e
  800577:	53                   	push   %ebx
  800578:	56                   	push   %esi
  800579:	e8 76 fe ff ff       	call   8003f4 <printfmt>
  80057e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800581:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800587:	e9 ab fe ff ff       	jmp    800437 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	83 c0 04             	add    $0x4,%eax
  800592:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80059a:	85 ff                	test   %edi,%edi
  80059c:	b8 8c 20 80 00       	mov    $0x80208c,%eax
  8005a1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a8:	0f 8e 94 00 00 00    	jle    800642 <vprintfmt+0x231>
  8005ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b2:	0f 84 98 00 00 00    	je     800650 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8005be:	57                   	push   %edi
  8005bf:	e8 5b 03 00 00       	call   80091f <strnlen>
  8005c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c7:	29 c1                	sub    %eax,%ecx
  8005c9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	eb 0f                	jmp    8005ec <vprintfmt+0x1db>
					putch(padc, putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ef 01             	sub    $0x1,%edi
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	85 ff                	test   %edi,%edi
  8005ee:	7f ed                	jg     8005dd <vprintfmt+0x1cc>
  8005f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005f6:	85 c9                	test   %ecx,%ecx
  8005f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fd:	0f 49 c1             	cmovns %ecx,%eax
  800600:	29 c1                	sub    %eax,%ecx
  800602:	89 75 08             	mov    %esi,0x8(%ebp)
  800605:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800608:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80060b:	89 cb                	mov    %ecx,%ebx
  80060d:	eb 4d                	jmp    80065c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800613:	74 1b                	je     800630 <vprintfmt+0x21f>
  800615:	0f be c0             	movsbl %al,%eax
  800618:	83 e8 20             	sub    $0x20,%eax
  80061b:	83 f8 5e             	cmp    $0x5e,%eax
  80061e:	76 10                	jbe    800630 <vprintfmt+0x21f>
					putch('?', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	ff 75 0c             	pushl  0xc(%ebp)
  800626:	6a 3f                	push   $0x3f
  800628:	ff 55 08             	call   *0x8(%ebp)
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	eb 0d                	jmp    80063d <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	ff 75 0c             	pushl  0xc(%ebp)
  800636:	52                   	push   %edx
  800637:	ff 55 08             	call   *0x8(%ebp)
  80063a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063d:	83 eb 01             	sub    $0x1,%ebx
  800640:	eb 1a                	jmp    80065c <vprintfmt+0x24b>
  800642:	89 75 08             	mov    %esi,0x8(%ebp)
  800645:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800648:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064e:	eb 0c                	jmp    80065c <vprintfmt+0x24b>
  800650:	89 75 08             	mov    %esi,0x8(%ebp)
  800653:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800656:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800659:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065c:	83 c7 01             	add    $0x1,%edi
  80065f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800663:	0f be d0             	movsbl %al,%edx
  800666:	85 d2                	test   %edx,%edx
  800668:	74 23                	je     80068d <vprintfmt+0x27c>
  80066a:	85 f6                	test   %esi,%esi
  80066c:	78 a1                	js     80060f <vprintfmt+0x1fe>
  80066e:	83 ee 01             	sub    $0x1,%esi
  800671:	79 9c                	jns    80060f <vprintfmt+0x1fe>
  800673:	89 df                	mov    %ebx,%edi
  800675:	8b 75 08             	mov    0x8(%ebp),%esi
  800678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067b:	eb 18                	jmp    800695 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 20                	push   $0x20
  800683:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 08                	jmp    800695 <vprintfmt+0x284>
  80068d:	89 df                	mov    %ebx,%edi
  80068f:	8b 75 08             	mov    0x8(%ebp),%esi
  800692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800695:	85 ff                	test   %edi,%edi
  800697:	7f e4                	jg     80067d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800699:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 90 fd ff ff       	jmp    800437 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	7e 19                	jle    8006c5 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 50 04             	mov    0x4(%eax),%edx
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 40 08             	lea    0x8(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c3:	eb 38                	jmp    8006fd <vprintfmt+0x2ec>
	else if (lflag)
  8006c5:	85 c9                	test   %ecx,%ecx
  8006c7:	74 1b                	je     8006e4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d1:	89 c1                	mov    %eax,%ecx
  8006d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e2:	eb 19                	jmp    8006fd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 c1                	mov    %eax,%ecx
  8006ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800700:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800703:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800708:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070c:	0f 89 36 01 00 00    	jns    800848 <vprintfmt+0x437>
				putch('-', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 2d                	push   $0x2d
  800718:	ff d6                	call   *%esi
				num = -(long long) num;
  80071a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800720:	f7 da                	neg    %edx
  800722:	83 d1 00             	adc    $0x0,%ecx
  800725:	f7 d9                	neg    %ecx
  800727:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072f:	e9 14 01 00 00       	jmp    800848 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800734:	83 f9 01             	cmp    $0x1,%ecx
  800737:	7e 18                	jle    800751 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	8b 48 04             	mov    0x4(%eax),%ecx
  800741:	8d 40 08             	lea    0x8(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800747:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074c:	e9 f7 00 00 00       	jmp    800848 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800751:	85 c9                	test   %ecx,%ecx
  800753:	74 1a                	je     80076f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075f:	8d 40 04             	lea    0x4(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800765:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076a:	e9 d9 00 00 00       	jmp    800848 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	b9 00 00 00 00       	mov    $0x0,%ecx
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80077f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800784:	e9 bf 00 00 00       	jmp    800848 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800789:	83 f9 01             	cmp    $0x1,%ecx
  80078c:	7e 13                	jle    8007a1 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8b 50 04             	mov    0x4(%eax),%edx
  800794:	8b 00                	mov    (%eax),%eax
  800796:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800799:	8d 49 08             	lea    0x8(%ecx),%ecx
  80079c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079f:	eb 28                	jmp    8007c9 <vprintfmt+0x3b8>
	else if (lflag)
  8007a1:	85 c9                	test   %ecx,%ecx
  8007a3:	74 13                	je     8007b8 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8b 10                	mov    (%eax),%edx
  8007aa:	89 d0                	mov    %edx,%eax
  8007ac:	99                   	cltd   
  8007ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007b0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b6:	eb 11                	jmp    8007c9 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	89 d0                	mov    %edx,%eax
  8007bf:	99                   	cltd   
  8007c0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007c3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8007c9:	89 d1                	mov    %edx,%ecx
  8007cb:	89 c2                	mov    %eax,%edx
			base = 8;
  8007cd:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007d2:	eb 74                	jmp    800848 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	53                   	push   %ebx
  8007d8:	6a 30                	push   $0x30
  8007da:	ff d6                	call   *%esi
			putch('x', putdat);
  8007dc:	83 c4 08             	add    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 78                	push   $0x78
  8007e2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ee:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f1:	8d 40 04             	lea    0x4(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fc:	eb 4a                	jmp    800848 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fe:	83 f9 01             	cmp    $0x1,%ecx
  800801:	7e 15                	jle    800818 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8b 10                	mov    (%eax),%edx
  800808:	8b 48 04             	mov    0x4(%eax),%ecx
  80080b:	8d 40 08             	lea    0x8(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800811:	b8 10 00 00 00       	mov    $0x10,%eax
  800816:	eb 30                	jmp    800848 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800818:	85 c9                	test   %ecx,%ecx
  80081a:	74 17                	je     800833 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8b 10                	mov    (%eax),%edx
  800821:	b9 00 00 00 00       	mov    $0x0,%ecx
  800826:	8d 40 04             	lea    0x4(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80082c:	b8 10 00 00 00       	mov    $0x10,%eax
  800831:	eb 15                	jmp    800848 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083d:	8d 40 04             	lea    0x4(%eax),%eax
  800840:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800843:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800848:	83 ec 0c             	sub    $0xc,%esp
  80084b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80084f:	57                   	push   %edi
  800850:	ff 75 e0             	pushl  -0x20(%ebp)
  800853:	50                   	push   %eax
  800854:	51                   	push   %ecx
  800855:	52                   	push   %edx
  800856:	89 da                	mov    %ebx,%edx
  800858:	89 f0                	mov    %esi,%eax
  80085a:	e8 c9 fa ff ff       	call   800328 <printnum>
			break;
  80085f:	83 c4 20             	add    $0x20,%esp
  800862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800865:	e9 cd fb ff ff       	jmp    800437 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	53                   	push   %ebx
  80086e:	52                   	push   %edx
  80086f:	ff d6                	call   *%esi
			break;
  800871:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800874:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800877:	e9 bb fb ff ff       	jmp    800437 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	53                   	push   %ebx
  800880:	6a 25                	push   $0x25
  800882:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	eb 03                	jmp    80088c <vprintfmt+0x47b>
  800889:	83 ef 01             	sub    $0x1,%edi
  80088c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800890:	75 f7                	jne    800889 <vprintfmt+0x478>
  800892:	e9 a0 fb ff ff       	jmp    800437 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800897:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5f                   	pop    %edi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 18             	sub    $0x18,%esp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	74 26                	je     8008e6 <vsnprintf+0x47>
  8008c0:	85 d2                	test   %edx,%edx
  8008c2:	7e 22                	jle    8008e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c4:	ff 75 14             	pushl  0x14(%ebp)
  8008c7:	ff 75 10             	pushl  0x10(%ebp)
  8008ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cd:	50                   	push   %eax
  8008ce:	68 d7 03 80 00       	push   $0x8003d7
  8008d3:	e8 39 fb ff ff       	call   800411 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	eb 05                	jmp    8008eb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f6:	50                   	push   %eax
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	ff 75 08             	pushl  0x8(%ebp)
  800900:	e8 9a ff ff ff       	call   80089f <vsnprintf>
	va_end(ap);

	return rc;
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	eb 03                	jmp    800917 <strlen+0x10>
		n++;
  800914:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800917:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091b:	75 f7                	jne    800914 <strlen+0xd>
		n++;
	return n;
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800928:	ba 00 00 00 00       	mov    $0x0,%edx
  80092d:	eb 03                	jmp    800932 <strnlen+0x13>
		n++;
  80092f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800932:	39 c2                	cmp    %eax,%edx
  800934:	74 08                	je     80093e <strnlen+0x1f>
  800936:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80093a:	75 f3                	jne    80092f <strnlen+0x10>
  80093c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	53                   	push   %ebx
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094a:	89 c2                	mov    %eax,%edx
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800956:	88 5a ff             	mov    %bl,-0x1(%edx)
  800959:	84 db                	test   %bl,%bl
  80095b:	75 ef                	jne    80094c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095d:	5b                   	pop    %ebx
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800967:	53                   	push   %ebx
  800968:	e8 9a ff ff ff       	call   800907 <strlen>
  80096d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800970:	ff 75 0c             	pushl  0xc(%ebp)
  800973:	01 d8                	add    %ebx,%eax
  800975:	50                   	push   %eax
  800976:	e8 c5 ff ff ff       	call   800940 <strcpy>
	return dst;
}
  80097b:	89 d8                	mov    %ebx,%eax
  80097d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	89 f3                	mov    %esi,%ebx
  80098f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800992:	89 f2                	mov    %esi,%edx
  800994:	eb 0f                	jmp    8009a5 <strncpy+0x23>
		*dst++ = *src;
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099f:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	39 da                	cmp    %ebx,%edx
  8009a7:	75 ed                	jne    800996 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8009bd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bf:	85 d2                	test   %edx,%edx
  8009c1:	74 21                	je     8009e4 <strlcpy+0x35>
  8009c3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	eb 09                	jmp    8009d4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cb:	83 c2 01             	add    $0x1,%edx
  8009ce:	83 c1 01             	add    $0x1,%ecx
  8009d1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d4:	39 c2                	cmp    %eax,%edx
  8009d6:	74 09                	je     8009e1 <strlcpy+0x32>
  8009d8:	0f b6 19             	movzbl (%ecx),%ebx
  8009db:	84 db                	test   %bl,%bl
  8009dd:	75 ec                	jne    8009cb <strlcpy+0x1c>
  8009df:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e4:	29 f0                	sub    %esi,%eax
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f3:	eb 06                	jmp    8009fb <strcmp+0x11>
		p++, q++;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fb:	0f b6 01             	movzbl (%ecx),%eax
  8009fe:	84 c0                	test   %al,%al
  800a00:	74 04                	je     800a06 <strcmp+0x1c>
  800a02:	3a 02                	cmp    (%edx),%al
  800a04:	74 ef                	je     8009f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a06:	0f b6 c0             	movzbl %al,%eax
  800a09:	0f b6 12             	movzbl (%edx),%edx
  800a0c:	29 d0                	sub    %edx,%eax
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 c3                	mov    %eax,%ebx
  800a1c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1f:	eb 06                	jmp    800a27 <strncmp+0x17>
		n--, p++, q++;
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a27:	39 d8                	cmp    %ebx,%eax
  800a29:	74 15                	je     800a40 <strncmp+0x30>
  800a2b:	0f b6 08             	movzbl (%eax),%ecx
  800a2e:	84 c9                	test   %cl,%cl
  800a30:	74 04                	je     800a36 <strncmp+0x26>
  800a32:	3a 0a                	cmp    (%edx),%cl
  800a34:	74 eb                	je     800a21 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 00             	movzbl (%eax),%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
  800a3e:	eb 05                	jmp    800a45 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a52:	eb 07                	jmp    800a5b <strchr+0x13>
		if (*s == c)
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 0f                	je     800a67 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	0f b6 10             	movzbl (%eax),%edx
  800a5e:	84 d2                	test   %dl,%dl
  800a60:	75 f2                	jne    800a54 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a73:	eb 03                	jmp    800a78 <strfind+0xf>
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7b:	38 ca                	cmp    %cl,%dl
  800a7d:	74 04                	je     800a83 <strfind+0x1a>
  800a7f:	84 d2                	test   %dl,%dl
  800a81:	75 f2                	jne    800a75 <strfind+0xc>
			break;
	return (char *) s;
}
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a91:	85 c9                	test   %ecx,%ecx
  800a93:	74 36                	je     800acb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9b:	75 28                	jne    800ac5 <memset+0x40>
  800a9d:	f6 c1 03             	test   $0x3,%cl
  800aa0:	75 23                	jne    800ac5 <memset+0x40>
		c &= 0xFF;
  800aa2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa6:	89 d3                	mov    %edx,%ebx
  800aa8:	c1 e3 08             	shl    $0x8,%ebx
  800aab:	89 d6                	mov    %edx,%esi
  800aad:	c1 e6 18             	shl    $0x18,%esi
  800ab0:	89 d0                	mov    %edx,%eax
  800ab2:	c1 e0 10             	shl    $0x10,%eax
  800ab5:	09 f0                	or     %esi,%eax
  800ab7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	09 d0                	or     %edx,%eax
  800abd:	c1 e9 02             	shr    $0x2,%ecx
  800ac0:	fc                   	cld    
  800ac1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac3:	eb 06                	jmp    800acb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	fc                   	cld    
  800ac9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acb:	89 f8                	mov    %edi,%eax
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	8b 75 0c             	mov    0xc(%ebp),%esi
  800add:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae0:	39 c6                	cmp    %eax,%esi
  800ae2:	73 35                	jae    800b19 <memmove+0x47>
  800ae4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae7:	39 d0                	cmp    %edx,%eax
  800ae9:	73 2e                	jae    800b19 <memmove+0x47>
		s += n;
		d += n;
  800aeb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	09 fe                	or     %edi,%esi
  800af2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af8:	75 13                	jne    800b0d <memmove+0x3b>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 0e                	jne    800b0d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aff:	83 ef 04             	sub    $0x4,%edi
  800b02:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b05:	c1 e9 02             	shr    $0x2,%ecx
  800b08:	fd                   	std    
  800b09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0b:	eb 09                	jmp    800b16 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0d:	83 ef 01             	sub    $0x1,%edi
  800b10:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b13:	fd                   	std    
  800b14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b16:	fc                   	cld    
  800b17:	eb 1d                	jmp    800b36 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b19:	89 f2                	mov    %esi,%edx
  800b1b:	09 c2                	or     %eax,%edx
  800b1d:	f6 c2 03             	test   $0x3,%dl
  800b20:	75 0f                	jne    800b31 <memmove+0x5f>
  800b22:	f6 c1 03             	test   $0x3,%cl
  800b25:	75 0a                	jne    800b31 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b27:	c1 e9 02             	shr    $0x2,%ecx
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	fc                   	cld    
  800b2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2f:	eb 05                	jmp    800b36 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	fc                   	cld    
  800b34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3d:	ff 75 10             	pushl  0x10(%ebp)
  800b40:	ff 75 0c             	pushl  0xc(%ebp)
  800b43:	ff 75 08             	pushl  0x8(%ebp)
  800b46:	e8 87 ff ff ff       	call   800ad2 <memmove>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b58:	89 c6                	mov    %eax,%esi
  800b5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5d:	eb 1a                	jmp    800b79 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5f:	0f b6 08             	movzbl (%eax),%ecx
  800b62:	0f b6 1a             	movzbl (%edx),%ebx
  800b65:	38 d9                	cmp    %bl,%cl
  800b67:	74 0a                	je     800b73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b69:	0f b6 c1             	movzbl %cl,%eax
  800b6c:	0f b6 db             	movzbl %bl,%ebx
  800b6f:	29 d8                	sub    %ebx,%eax
  800b71:	eb 0f                	jmp    800b82 <memcmp+0x35>
		s1++, s2++;
  800b73:	83 c0 01             	add    $0x1,%eax
  800b76:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b79:	39 f0                	cmp    %esi,%eax
  800b7b:	75 e2                	jne    800b5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	53                   	push   %ebx
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b8d:	89 c1                	mov    %eax,%ecx
  800b8f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b96:	eb 0a                	jmp    800ba2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b98:	0f b6 10             	movzbl (%eax),%edx
  800b9b:	39 da                	cmp    %ebx,%edx
  800b9d:	74 07                	je     800ba6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9f:	83 c0 01             	add    $0x1,%eax
  800ba2:	39 c8                	cmp    %ecx,%eax
  800ba4:	72 f2                	jb     800b98 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	eb 03                	jmp    800bba <strtol+0x11>
		s++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 01             	movzbl (%ecx),%eax
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 f6                	je     800bb7 <strtol+0xe>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	74 f2                	je     800bb7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc5:	3c 2b                	cmp    $0x2b,%al
  800bc7:	75 0a                	jne    800bd3 <strtol+0x2a>
		s++;
  800bc9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bcc:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd1:	eb 11                	jmp    800be4 <strtol+0x3b>
  800bd3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd8:	3c 2d                	cmp    $0x2d,%al
  800bda:	75 08                	jne    800be4 <strtol+0x3b>
		s++, neg = 1;
  800bdc:	83 c1 01             	add    $0x1,%ecx
  800bdf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bea:	75 15                	jne    800c01 <strtol+0x58>
  800bec:	80 39 30             	cmpb   $0x30,(%ecx)
  800bef:	75 10                	jne    800c01 <strtol+0x58>
  800bf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf5:	75 7c                	jne    800c73 <strtol+0xca>
		s += 2, base = 16;
  800bf7:	83 c1 02             	add    $0x2,%ecx
  800bfa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bff:	eb 16                	jmp    800c17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c01:	85 db                	test   %ebx,%ebx
  800c03:	75 12                	jne    800c17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0d:	75 08                	jne    800c17 <strtol+0x6e>
		s++, base = 8;
  800c0f:	83 c1 01             	add    $0x1,%ecx
  800c12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c17:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1f:	0f b6 11             	movzbl (%ecx),%edx
  800c22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c25:	89 f3                	mov    %esi,%ebx
  800c27:	80 fb 09             	cmp    $0x9,%bl
  800c2a:	77 08                	ja     800c34 <strtol+0x8b>
			dig = *s - '0';
  800c2c:	0f be d2             	movsbl %dl,%edx
  800c2f:	83 ea 30             	sub    $0x30,%edx
  800c32:	eb 22                	jmp    800c56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c37:	89 f3                	mov    %esi,%ebx
  800c39:	80 fb 19             	cmp    $0x19,%bl
  800c3c:	77 08                	ja     800c46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c3e:	0f be d2             	movsbl %dl,%edx
  800c41:	83 ea 57             	sub    $0x57,%edx
  800c44:	eb 10                	jmp    800c56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c49:	89 f3                	mov    %esi,%ebx
  800c4b:	80 fb 19             	cmp    $0x19,%bl
  800c4e:	77 16                	ja     800c66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c50:	0f be d2             	movsbl %dl,%edx
  800c53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c56:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c59:	7d 0b                	jge    800c66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c5b:	83 c1 01             	add    $0x1,%ecx
  800c5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c64:	eb b9                	jmp    800c1f <strtol+0x76>

	if (endptr)
  800c66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6a:	74 0d                	je     800c79 <strtol+0xd0>
		*endptr = (char *) s;
  800c6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6f:	89 0e                	mov    %ecx,(%esi)
  800c71:	eb 06                	jmp    800c79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c73:	85 db                	test   %ebx,%ebx
  800c75:	74 98                	je     800c0f <strtol+0x66>
  800c77:	eb 9e                	jmp    800c17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	f7 da                	neg    %edx
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	89 c7                	mov    %eax,%edi
  800c9c:	89 c6                	mov    %eax,%esi
  800c9e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 cb                	mov    %ecx,%ebx
  800cdc:	89 cf                	mov    %ecx,%edi
  800cde:	89 ce                	mov    %ecx,%esi
  800ce0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 03                	push   $0x3
  800cec:	68 7f 23 80 00       	push   $0x80237f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 9c 23 80 00       	push   $0x80239c
  800cf8:	e8 3e f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 02 00 00 00       	mov    $0x2,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_yield>:

void
sys_yield(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 04 00 00 00       	mov    $0x4,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	89 f7                	mov    %esi,%edi
  800d61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 17                	jle    800d7e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 04                	push   $0x4
  800d6d:	68 7f 23 80 00       	push   $0x80237f
  800d72:	6a 23                	push   $0x23
  800d74:	68 9c 23 80 00       	push   $0x80239c
  800d79:	e8 bd f4 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da0:	8b 75 18             	mov    0x18(%ebp),%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 05                	push   $0x5
  800daf:	68 7f 23 80 00       	push   $0x80237f
  800db4:	6a 23                	push   $0x23
  800db6:	68 9c 23 80 00       	push   $0x80239c
  800dbb:	e8 7b f4 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 06                	push   $0x6
  800df1:	68 7f 23 80 00       	push   $0x80237f
  800df6:	6a 23                	push   $0x23
  800df8:	68 9c 23 80 00       	push   $0x80239c
  800dfd:	e8 39 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 08                	push   $0x8
  800e33:	68 7f 23 80 00       	push   $0x80237f
  800e38:	6a 23                	push   $0x23
  800e3a:	68 9c 23 80 00       	push   $0x80239c
  800e3f:	e8 f7 f3 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 09                	push   $0x9
  800e75:	68 7f 23 80 00       	push   $0x80237f
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 9c 23 80 00       	push   $0x80239c
  800e81:	e8 b5 f3 ff ff       	call   80023b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 0a                	push   $0xa
  800eb7:	68 7f 23 80 00       	push   $0x80237f
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 9c 23 80 00       	push   $0x80239c
  800ec3:	e8 73 f3 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	be 00 00 00 00       	mov    $0x0,%esi
  800edb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f01:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	89 cb                	mov    %ecx,%ebx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	89 ce                	mov    %ecx,%esi
  800f0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7e 17                	jle    800f2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	50                   	push   %eax
  800f19:	6a 0d                	push   $0xd
  800f1b:	68 7f 23 80 00       	push   $0x80237f
  800f20:	6a 23                	push   $0x23
  800f22:	68 9c 23 80 00       	push   $0x80239c
  800f27:	e8 0f f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f3f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f54:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f61:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f66:	89 c2                	mov    %eax,%edx
  800f68:	c1 ea 16             	shr    $0x16,%edx
  800f6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f72:	f6 c2 01             	test   $0x1,%dl
  800f75:	74 11                	je     800f88 <fd_alloc+0x2d>
  800f77:	89 c2                	mov    %eax,%edx
  800f79:	c1 ea 0c             	shr    $0xc,%edx
  800f7c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f83:	f6 c2 01             	test   $0x1,%dl
  800f86:	75 09                	jne    800f91 <fd_alloc+0x36>
			*fd_store = fd;
  800f88:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	eb 17                	jmp    800fa8 <fd_alloc+0x4d>
  800f91:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f96:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f9b:	75 c9                	jne    800f66 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f9d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fa3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fb0:	83 f8 1f             	cmp    $0x1f,%eax
  800fb3:	77 36                	ja     800feb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb5:	c1 e0 0c             	shl    $0xc,%eax
  800fb8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fbd:	89 c2                	mov    %eax,%edx
  800fbf:	c1 ea 16             	shr    $0x16,%edx
  800fc2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fc9:	f6 c2 01             	test   $0x1,%dl
  800fcc:	74 24                	je     800ff2 <fd_lookup+0x48>
  800fce:	89 c2                	mov    %eax,%edx
  800fd0:	c1 ea 0c             	shr    $0xc,%edx
  800fd3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	74 1a                	je     800ff9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe2:	89 02                	mov    %eax,(%edx)
	return 0;
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	eb 13                	jmp    800ffe <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800feb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff0:	eb 0c                	jmp    800ffe <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff7:	eb 05                	jmp    800ffe <fd_lookup+0x54>
  800ff9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801009:	ba 2c 24 80 00       	mov    $0x80242c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80100e:	eb 13                	jmp    801023 <dev_lookup+0x23>
  801010:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801013:	39 08                	cmp    %ecx,(%eax)
  801015:	75 0c                	jne    801023 <dev_lookup+0x23>
			*dev = devtab[i];
  801017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
  801021:	eb 2e                	jmp    801051 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801023:	8b 02                	mov    (%edx),%eax
  801025:	85 c0                	test   %eax,%eax
  801027:	75 e7                	jne    801010 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801029:	a1 04 40 80 00       	mov    0x804004,%eax
  80102e:	8b 40 48             	mov    0x48(%eax),%eax
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	51                   	push   %ecx
  801035:	50                   	push   %eax
  801036:	68 ac 23 80 00       	push   $0x8023ac
  80103b:	e8 d4 f2 ff ff       	call   800314 <cprintf>
	*dev = 0;
  801040:	8b 45 0c             	mov    0xc(%ebp),%eax
  801043:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 10             	sub    $0x10,%esp
  80105b:	8b 75 08             	mov    0x8(%ebp),%esi
  80105e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
  80106e:	50                   	push   %eax
  80106f:	e8 36 ff ff ff       	call   800faa <fd_lookup>
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 05                	js     801080 <fd_close+0x2d>
	    || fd != fd2)
  80107b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80107e:	74 0c                	je     80108c <fd_close+0x39>
		return (must_exist ? r : 0);
  801080:	84 db                	test   %bl,%bl
  801082:	ba 00 00 00 00       	mov    $0x0,%edx
  801087:	0f 44 c2             	cmove  %edx,%eax
  80108a:	eb 41                	jmp    8010cd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80108c:	83 ec 08             	sub    $0x8,%esp
  80108f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	ff 36                	pushl  (%esi)
  801095:	e8 66 ff ff ff       	call   801000 <dev_lookup>
  80109a:	89 c3                	mov    %eax,%ebx
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 1a                	js     8010bd <fd_close+0x6a>
		if (dev->dev_close)
  8010a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	74 0b                	je     8010bd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	56                   	push   %esi
  8010b6:	ff d0                	call   *%eax
  8010b8:	89 c3                	mov    %eax,%ebx
  8010ba:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	56                   	push   %esi
  8010c1:	6a 00                	push   $0x0
  8010c3:	e8 00 fd ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	89 d8                	mov    %ebx,%eax
}
  8010cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	ff 75 08             	pushl  0x8(%ebp)
  8010e1:	e8 c4 fe ff ff       	call   800faa <fd_lookup>
  8010e6:	83 c4 08             	add    $0x8,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 10                	js     8010fd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	6a 01                	push   $0x1
  8010f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010f5:	e8 59 ff ff ff       	call   801053 <fd_close>
  8010fa:	83 c4 10             	add    $0x10,%esp
}
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <close_all>:

void
close_all(void)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	53                   	push   %ebx
  801103:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801106:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	53                   	push   %ebx
  80110f:	e8 c0 ff ff ff       	call   8010d4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801114:	83 c3 01             	add    $0x1,%ebx
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	83 fb 20             	cmp    $0x20,%ebx
  80111d:	75 ec                	jne    80110b <close_all+0xc>
		close(i);
}
  80111f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
  80112a:	83 ec 2c             	sub    $0x2c,%esp
  80112d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801130:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801133:	50                   	push   %eax
  801134:	ff 75 08             	pushl  0x8(%ebp)
  801137:	e8 6e fe ff ff       	call   800faa <fd_lookup>
  80113c:	83 c4 08             	add    $0x8,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	0f 88 c1 00 00 00    	js     801208 <dup+0xe4>
		return r;
	close(newfdnum);
  801147:	83 ec 0c             	sub    $0xc,%esp
  80114a:	56                   	push   %esi
  80114b:	e8 84 ff ff ff       	call   8010d4 <close>

	newfd = INDEX2FD(newfdnum);
  801150:	89 f3                	mov    %esi,%ebx
  801152:	c1 e3 0c             	shl    $0xc,%ebx
  801155:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80115b:	83 c4 04             	add    $0x4,%esp
  80115e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801161:	e8 de fd ff ff       	call   800f44 <fd2data>
  801166:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801168:	89 1c 24             	mov    %ebx,(%esp)
  80116b:	e8 d4 fd ff ff       	call   800f44 <fd2data>
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801176:	89 f8                	mov    %edi,%eax
  801178:	c1 e8 16             	shr    $0x16,%eax
  80117b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801182:	a8 01                	test   $0x1,%al
  801184:	74 37                	je     8011bd <dup+0x99>
  801186:	89 f8                	mov    %edi,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
  80118b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801192:	f6 c2 01             	test   $0x1,%dl
  801195:	74 26                	je     8011bd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801197:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8011a6:	50                   	push   %eax
  8011a7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011aa:	6a 00                	push   $0x0
  8011ac:	57                   	push   %edi
  8011ad:	6a 00                	push   $0x0
  8011af:	e8 d2 fb ff ff       	call   800d86 <sys_page_map>
  8011b4:	89 c7                	mov    %eax,%edi
  8011b6:	83 c4 20             	add    $0x20,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 2e                	js     8011eb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011c0:	89 d0                	mov    %edx,%eax
  8011c2:	c1 e8 0c             	shr    $0xc,%eax
  8011c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011cc:	83 ec 0c             	sub    $0xc,%esp
  8011cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8011d4:	50                   	push   %eax
  8011d5:	53                   	push   %ebx
  8011d6:	6a 00                	push   $0x0
  8011d8:	52                   	push   %edx
  8011d9:	6a 00                	push   $0x0
  8011db:	e8 a6 fb ff ff       	call   800d86 <sys_page_map>
  8011e0:	89 c7                	mov    %eax,%edi
  8011e2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011e5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e7:	85 ff                	test   %edi,%edi
  8011e9:	79 1d                	jns    801208 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	53                   	push   %ebx
  8011ef:	6a 00                	push   $0x0
  8011f1:	e8 d2 fb ff ff       	call   800dc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011f6:	83 c4 08             	add    $0x8,%esp
  8011f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011fc:	6a 00                	push   $0x0
  8011fe:	e8 c5 fb ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	89 f8                	mov    %edi,%eax
}
  801208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	53                   	push   %ebx
  801214:	83 ec 14             	sub    $0x14,%esp
  801217:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	53                   	push   %ebx
  80121f:	e8 86 fd ff ff       	call   800faa <fd_lookup>
  801224:	83 c4 08             	add    $0x8,%esp
  801227:	89 c2                	mov    %eax,%edx
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 6d                	js     80129a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801233:	50                   	push   %eax
  801234:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801237:	ff 30                	pushl  (%eax)
  801239:	e8 c2 fd ff ff       	call   801000 <dev_lookup>
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 4c                	js     801291 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801245:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801248:	8b 42 08             	mov    0x8(%edx),%eax
  80124b:	83 e0 03             	and    $0x3,%eax
  80124e:	83 f8 01             	cmp    $0x1,%eax
  801251:	75 21                	jne    801274 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801253:	a1 04 40 80 00       	mov    0x804004,%eax
  801258:	8b 40 48             	mov    0x48(%eax),%eax
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	53                   	push   %ebx
  80125f:	50                   	push   %eax
  801260:	68 f0 23 80 00       	push   $0x8023f0
  801265:	e8 aa f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801272:	eb 26                	jmp    80129a <read+0x8a>
	}
	if (!dev->dev_read)
  801274:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801277:	8b 40 08             	mov    0x8(%eax),%eax
  80127a:	85 c0                	test   %eax,%eax
  80127c:	74 17                	je     801295 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	ff 75 10             	pushl  0x10(%ebp)
  801284:	ff 75 0c             	pushl  0xc(%ebp)
  801287:	52                   	push   %edx
  801288:	ff d0                	call   *%eax
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	eb 09                	jmp    80129a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801291:	89 c2                	mov    %eax,%edx
  801293:	eb 05                	jmp    80129a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801295:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80129a:	89 d0                	mov    %edx,%eax
  80129c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	57                   	push   %edi
  8012a5:	56                   	push   %esi
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 0c             	sub    $0xc,%esp
  8012aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b5:	eb 21                	jmp    8012d8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	89 f0                	mov    %esi,%eax
  8012bc:	29 d8                	sub    %ebx,%eax
  8012be:	50                   	push   %eax
  8012bf:	89 d8                	mov    %ebx,%eax
  8012c1:	03 45 0c             	add    0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	57                   	push   %edi
  8012c6:	e8 45 ff ff ff       	call   801210 <read>
		if (m < 0)
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 10                	js     8012e2 <readn+0x41>
			return m;
		if (m == 0)
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	74 0a                	je     8012e0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012d6:	01 c3                	add    %eax,%ebx
  8012d8:	39 f3                	cmp    %esi,%ebx
  8012da:	72 db                	jb     8012b7 <readn+0x16>
  8012dc:	89 d8                	mov    %ebx,%eax
  8012de:	eb 02                	jmp    8012e2 <readn+0x41>
  8012e0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5f                   	pop    %edi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 14             	sub    $0x14,%esp
  8012f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	53                   	push   %ebx
  8012f9:	e8 ac fc ff ff       	call   800faa <fd_lookup>
  8012fe:	83 c4 08             	add    $0x8,%esp
  801301:	89 c2                	mov    %eax,%edx
  801303:	85 c0                	test   %eax,%eax
  801305:	78 68                	js     80136f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801311:	ff 30                	pushl  (%eax)
  801313:	e8 e8 fc ff ff       	call   801000 <dev_lookup>
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 47                	js     801366 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801326:	75 21                	jne    801349 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801328:	a1 04 40 80 00       	mov    0x804004,%eax
  80132d:	8b 40 48             	mov    0x48(%eax),%eax
  801330:	83 ec 04             	sub    $0x4,%esp
  801333:	53                   	push   %ebx
  801334:	50                   	push   %eax
  801335:	68 0c 24 80 00       	push   $0x80240c
  80133a:	e8 d5 ef ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801347:	eb 26                	jmp    80136f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801349:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134c:	8b 52 0c             	mov    0xc(%edx),%edx
  80134f:	85 d2                	test   %edx,%edx
  801351:	74 17                	je     80136a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	ff 75 10             	pushl  0x10(%ebp)
  801359:	ff 75 0c             	pushl  0xc(%ebp)
  80135c:	50                   	push   %eax
  80135d:	ff d2                	call   *%edx
  80135f:	89 c2                	mov    %eax,%edx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	eb 09                	jmp    80136f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	89 c2                	mov    %eax,%edx
  801368:	eb 05                	jmp    80136f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80136a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <seek>:

int
seek(int fdnum, off_t offset)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 75 08             	pushl  0x8(%ebp)
  801383:	e8 22 fc ff ff       	call   800faa <fd_lookup>
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 0e                	js     80139d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80138f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801392:	8b 55 0c             	mov    0xc(%ebp),%edx
  801395:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801398:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 14             	sub    $0x14,%esp
  8013a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	53                   	push   %ebx
  8013ae:	e8 f7 fb ff ff       	call   800faa <fd_lookup>
  8013b3:	83 c4 08             	add    $0x8,%esp
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 65                	js     801421 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	ff 30                	pushl  (%eax)
  8013c8:	e8 33 fc ff ff       	call   801000 <dev_lookup>
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 44                	js     801418 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013db:	75 21                	jne    8013fe <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013dd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013e2:	8b 40 48             	mov    0x48(%eax),%eax
  8013e5:	83 ec 04             	sub    $0x4,%esp
  8013e8:	53                   	push   %ebx
  8013e9:	50                   	push   %eax
  8013ea:	68 cc 23 80 00       	push   $0x8023cc
  8013ef:	e8 20 ef ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013fc:	eb 23                	jmp    801421 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801401:	8b 52 18             	mov    0x18(%edx),%edx
  801404:	85 d2                	test   %edx,%edx
  801406:	74 14                	je     80141c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	ff 75 0c             	pushl  0xc(%ebp)
  80140e:	50                   	push   %eax
  80140f:	ff d2                	call   *%edx
  801411:	89 c2                	mov    %eax,%edx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	eb 09                	jmp    801421 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801418:	89 c2                	mov    %eax,%edx
  80141a:	eb 05                	jmp    801421 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80141c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801421:	89 d0                	mov    %edx,%eax
  801423:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 14             	sub    $0x14,%esp
  80142f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801432:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	ff 75 08             	pushl  0x8(%ebp)
  801439:	e8 6c fb ff ff       	call   800faa <fd_lookup>
  80143e:	83 c4 08             	add    $0x8,%esp
  801441:	89 c2                	mov    %eax,%edx
  801443:	85 c0                	test   %eax,%eax
  801445:	78 58                	js     80149f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801451:	ff 30                	pushl  (%eax)
  801453:	e8 a8 fb ff ff       	call   801000 <dev_lookup>
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 37                	js     801496 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80145f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801462:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801466:	74 32                	je     80149a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801468:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80146b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801472:	00 00 00 
	stat->st_isdir = 0;
  801475:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80147c:	00 00 00 
	stat->st_dev = dev;
  80147f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	53                   	push   %ebx
  801489:	ff 75 f0             	pushl  -0x10(%ebp)
  80148c:	ff 50 14             	call   *0x14(%eax)
  80148f:	89 c2                	mov    %eax,%edx
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	eb 09                	jmp    80149f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801496:	89 c2                	mov    %eax,%edx
  801498:	eb 05                	jmp    80149f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80149a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80149f:	89 d0                	mov    %edx,%eax
  8014a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	56                   	push   %esi
  8014aa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014ab:	83 ec 08             	sub    $0x8,%esp
  8014ae:	6a 00                	push   $0x0
  8014b0:	ff 75 08             	pushl  0x8(%ebp)
  8014b3:	e8 b7 01 00 00       	call   80166f <open>
  8014b8:	89 c3                	mov    %eax,%ebx
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 1b                	js     8014dc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	ff 75 0c             	pushl  0xc(%ebp)
  8014c7:	50                   	push   %eax
  8014c8:	e8 5b ff ff ff       	call   801428 <fstat>
  8014cd:	89 c6                	mov    %eax,%esi
	close(fd);
  8014cf:	89 1c 24             	mov    %ebx,(%esp)
  8014d2:	e8 fd fb ff ff       	call   8010d4 <close>
	return r;
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	89 f0                	mov    %esi,%eax
}
  8014dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	89 c6                	mov    %eax,%esi
  8014ea:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014ec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014f3:	75 12                	jne    801507 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	6a 01                	push   $0x1
  8014fa:	e8 bc 07 00 00       	call   801cbb <ipc_find_env>
  8014ff:	a3 00 40 80 00       	mov    %eax,0x804000
  801504:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801507:	6a 07                	push   $0x7
  801509:	68 00 50 80 00       	push   $0x805000
  80150e:	56                   	push   %esi
  80150f:	ff 35 00 40 80 00    	pushl  0x804000
  801515:	e8 4d 07 00 00       	call   801c67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80151a:	83 c4 0c             	add    $0xc,%esp
  80151d:	6a 00                	push   $0x0
  80151f:	53                   	push   %ebx
  801520:	6a 00                	push   $0x0
  801522:	e8 cb 06 00 00       	call   801bf2 <ipc_recv>
}
  801527:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	8b 40 0c             	mov    0xc(%eax),%eax
  80153a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80153f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801542:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801547:	ba 00 00 00 00       	mov    $0x0,%edx
  80154c:	b8 02 00 00 00       	mov    $0x2,%eax
  801551:	e8 8d ff ff ff       	call   8014e3 <fsipc>
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80155e:	8b 45 08             	mov    0x8(%ebp),%eax
  801561:	8b 40 0c             	mov    0xc(%eax),%eax
  801564:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 06 00 00 00       	mov    $0x6,%eax
  801573:	e8 6b ff ff ff       	call   8014e3 <fsipc>
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 04             	sub    $0x4,%esp
  801581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	8b 40 0c             	mov    0xc(%eax),%eax
  80158a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80158f:	ba 00 00 00 00       	mov    $0x0,%edx
  801594:	b8 05 00 00 00       	mov    $0x5,%eax
  801599:	e8 45 ff ff ff       	call   8014e3 <fsipc>
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 2c                	js     8015ce <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	68 00 50 80 00       	push   $0x805000
  8015aa:	53                   	push   %ebx
  8015ab:	e8 90 f3 ff ff       	call   800940 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015b0:	a1 80 50 80 00       	mov    0x805080,%eax
  8015b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015bb:	a1 84 50 80 00       	mov    0x805084,%eax
  8015c0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8015d9:	68 3c 24 80 00       	push   $0x80243c
  8015de:	68 90 00 00 00       	push   $0x90
  8015e3:	68 5a 24 80 00       	push   $0x80245a
  8015e8:	e8 4e ec ff ff       	call   80023b <_panic>

008015ed <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801600:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801606:	ba 00 00 00 00       	mov    $0x0,%edx
  80160b:	b8 03 00 00 00       	mov    $0x3,%eax
  801610:	e8 ce fe ff ff       	call   8014e3 <fsipc>
  801615:	89 c3                	mov    %eax,%ebx
  801617:	85 c0                	test   %eax,%eax
  801619:	78 4b                	js     801666 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80161b:	39 c6                	cmp    %eax,%esi
  80161d:	73 16                	jae    801635 <devfile_read+0x48>
  80161f:	68 65 24 80 00       	push   $0x802465
  801624:	68 6c 24 80 00       	push   $0x80246c
  801629:	6a 7c                	push   $0x7c
  80162b:	68 5a 24 80 00       	push   $0x80245a
  801630:	e8 06 ec ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  801635:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80163a:	7e 16                	jle    801652 <devfile_read+0x65>
  80163c:	68 81 24 80 00       	push   $0x802481
  801641:	68 6c 24 80 00       	push   $0x80246c
  801646:	6a 7d                	push   $0x7d
  801648:	68 5a 24 80 00       	push   $0x80245a
  80164d:	e8 e9 eb ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801652:	83 ec 04             	sub    $0x4,%esp
  801655:	50                   	push   %eax
  801656:	68 00 50 80 00       	push   $0x805000
  80165b:	ff 75 0c             	pushl  0xc(%ebp)
  80165e:	e8 6f f4 ff ff       	call   800ad2 <memmove>
	return r;
  801663:	83 c4 10             	add    $0x10,%esp
}
  801666:	89 d8                	mov    %ebx,%eax
  801668:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	53                   	push   %ebx
  801673:	83 ec 20             	sub    $0x20,%esp
  801676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801679:	53                   	push   %ebx
  80167a:	e8 88 f2 ff ff       	call   800907 <strlen>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801687:	7f 67                	jg     8016f0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	e8 c6 f8 ff ff       	call   800f5b <fd_alloc>
  801695:	83 c4 10             	add    $0x10,%esp
		return r;
  801698:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 57                	js     8016f5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	53                   	push   %ebx
  8016a2:	68 00 50 80 00       	push   $0x805000
  8016a7:	e8 94 f2 ff ff       	call   800940 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016af:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8016bc:	e8 22 fe ff ff       	call   8014e3 <fsipc>
  8016c1:	89 c3                	mov    %eax,%ebx
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	79 14                	jns    8016de <open+0x6f>
		fd_close(fd, 0);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	6a 00                	push   $0x0
  8016cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d2:	e8 7c f9 ff ff       	call   801053 <fd_close>
		return r;
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	89 da                	mov    %ebx,%edx
  8016dc:	eb 17                	jmp    8016f5 <open+0x86>
	}

	return fd2num(fd);
  8016de:	83 ec 0c             	sub    $0xc,%esp
  8016e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e4:	e8 4b f8 ff ff       	call   800f34 <fd2num>
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	eb 05                	jmp    8016f5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016f0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016f5:	89 d0                	mov    %edx,%eax
  8016f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801702:	ba 00 00 00 00       	mov    $0x0,%edx
  801707:	b8 08 00 00 00       	mov    $0x8,%eax
  80170c:	e8 d2 fd ff ff       	call   8014e3 <fsipc>
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	ff 75 08             	pushl  0x8(%ebp)
  801721:	e8 1e f8 ff ff       	call   800f44 <fd2data>
  801726:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801728:	83 c4 08             	add    $0x8,%esp
  80172b:	68 8d 24 80 00       	push   $0x80248d
  801730:	53                   	push   %ebx
  801731:	e8 0a f2 ff ff       	call   800940 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801736:	8b 46 04             	mov    0x4(%esi),%eax
  801739:	2b 06                	sub    (%esi),%eax
  80173b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801741:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801748:	00 00 00 
	stat->st_dev = &devpipe;
  80174b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801752:	30 80 00 
	return 0;
}
  801755:	b8 00 00 00 00       	mov    $0x0,%eax
  80175a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	53                   	push   %ebx
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80176b:	53                   	push   %ebx
  80176c:	6a 00                	push   $0x0
  80176e:	e8 55 f6 ff ff       	call   800dc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801773:	89 1c 24             	mov    %ebx,(%esp)
  801776:	e8 c9 f7 ff ff       	call   800f44 <fd2data>
  80177b:	83 c4 08             	add    $0x8,%esp
  80177e:	50                   	push   %eax
  80177f:	6a 00                	push   $0x0
  801781:	e8 42 f6 ff ff       	call   800dc8 <sys_page_unmap>
}
  801786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	57                   	push   %edi
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	83 ec 1c             	sub    $0x1c,%esp
  801794:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801797:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801799:	a1 04 40 80 00       	mov    0x804004,%eax
  80179e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8017a7:	e8 48 05 00 00       	call   801cf4 <pageref>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	89 3c 24             	mov    %edi,(%esp)
  8017b1:	e8 3e 05 00 00       	call   801cf4 <pageref>
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	39 c3                	cmp    %eax,%ebx
  8017bb:	0f 94 c1             	sete   %cl
  8017be:	0f b6 c9             	movzbl %cl,%ecx
  8017c1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017c4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017ca:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017cd:	39 ce                	cmp    %ecx,%esi
  8017cf:	74 1b                	je     8017ec <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017d1:	39 c3                	cmp    %eax,%ebx
  8017d3:	75 c4                	jne    801799 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017d5:	8b 42 58             	mov    0x58(%edx),%eax
  8017d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017db:	50                   	push   %eax
  8017dc:	56                   	push   %esi
  8017dd:	68 94 24 80 00       	push   $0x802494
  8017e2:	e8 2d eb ff ff       	call   800314 <cprintf>
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	eb ad                	jmp    801799 <_pipeisclosed+0xe>
	}
}
  8017ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5e                   	pop    %esi
  8017f4:	5f                   	pop    %edi
  8017f5:	5d                   	pop    %ebp
  8017f6:	c3                   	ret    

008017f7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	57                   	push   %edi
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 28             	sub    $0x28,%esp
  801800:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801803:	56                   	push   %esi
  801804:	e8 3b f7 ff ff       	call   800f44 <fd2data>
  801809:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	bf 00 00 00 00       	mov    $0x0,%edi
  801813:	eb 4b                	jmp    801860 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801815:	89 da                	mov    %ebx,%edx
  801817:	89 f0                	mov    %esi,%eax
  801819:	e8 6d ff ff ff       	call   80178b <_pipeisclosed>
  80181e:	85 c0                	test   %eax,%eax
  801820:	75 48                	jne    80186a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801822:	e8 fd f4 ff ff       	call   800d24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801827:	8b 43 04             	mov    0x4(%ebx),%eax
  80182a:	8b 0b                	mov    (%ebx),%ecx
  80182c:	8d 51 20             	lea    0x20(%ecx),%edx
  80182f:	39 d0                	cmp    %edx,%eax
  801831:	73 e2                	jae    801815 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801836:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80183a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	c1 fa 1f             	sar    $0x1f,%edx
  801842:	89 d1                	mov    %edx,%ecx
  801844:	c1 e9 1b             	shr    $0x1b,%ecx
  801847:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80184a:	83 e2 1f             	and    $0x1f,%edx
  80184d:	29 ca                	sub    %ecx,%edx
  80184f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801853:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801857:	83 c0 01             	add    $0x1,%eax
  80185a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80185d:	83 c7 01             	add    $0x1,%edi
  801860:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801863:	75 c2                	jne    801827 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801865:	8b 45 10             	mov    0x10(%ebp),%eax
  801868:	eb 05                	jmp    80186f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80186f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5f                   	pop    %edi
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	57                   	push   %edi
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	83 ec 18             	sub    $0x18,%esp
  801880:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801883:	57                   	push   %edi
  801884:	e8 bb f6 ff ff       	call   800f44 <fd2data>
  801889:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801893:	eb 3d                	jmp    8018d2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801895:	85 db                	test   %ebx,%ebx
  801897:	74 04                	je     80189d <devpipe_read+0x26>
				return i;
  801899:	89 d8                	mov    %ebx,%eax
  80189b:	eb 44                	jmp    8018e1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80189d:	89 f2                	mov    %esi,%edx
  80189f:	89 f8                	mov    %edi,%eax
  8018a1:	e8 e5 fe ff ff       	call   80178b <_pipeisclosed>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	75 32                	jne    8018dc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018aa:	e8 75 f4 ff ff       	call   800d24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018af:	8b 06                	mov    (%esi),%eax
  8018b1:	3b 46 04             	cmp    0x4(%esi),%eax
  8018b4:	74 df                	je     801895 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018b6:	99                   	cltd   
  8018b7:	c1 ea 1b             	shr    $0x1b,%edx
  8018ba:	01 d0                	add    %edx,%eax
  8018bc:	83 e0 1f             	and    $0x1f,%eax
  8018bf:	29 d0                	sub    %edx,%eax
  8018c1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018c9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018cc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018cf:	83 c3 01             	add    $0x1,%ebx
  8018d2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018d5:	75 d8                	jne    8018af <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8018da:	eb 05                	jmp    8018e1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018dc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5f                   	pop    %edi
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    

008018e9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	e8 61 f6 ff ff       	call   800f5b <fd_alloc>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	85 c0                	test   %eax,%eax
  801901:	0f 88 2c 01 00 00    	js     801a33 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	68 07 04 00 00       	push   $0x407
  80190f:	ff 75 f4             	pushl  -0xc(%ebp)
  801912:	6a 00                	push   $0x0
  801914:	e8 2a f4 ff ff       	call   800d43 <sys_page_alloc>
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	89 c2                	mov    %eax,%edx
  80191e:	85 c0                	test   %eax,%eax
  801920:	0f 88 0d 01 00 00    	js     801a33 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	e8 29 f6 ff ff       	call   800f5b <fd_alloc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	0f 88 e2 00 00 00    	js     801a21 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80193f:	83 ec 04             	sub    $0x4,%esp
  801942:	68 07 04 00 00       	push   $0x407
  801947:	ff 75 f0             	pushl  -0x10(%ebp)
  80194a:	6a 00                	push   $0x0
  80194c:	e8 f2 f3 ff ff       	call   800d43 <sys_page_alloc>
  801951:	89 c3                	mov    %eax,%ebx
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	0f 88 c3 00 00 00    	js     801a21 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	e8 db f5 ff ff       	call   800f44 <fd2data>
  801969:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80196b:	83 c4 0c             	add    $0xc,%esp
  80196e:	68 07 04 00 00       	push   $0x407
  801973:	50                   	push   %eax
  801974:	6a 00                	push   $0x0
  801976:	e8 c8 f3 ff ff       	call   800d43 <sys_page_alloc>
  80197b:	89 c3                	mov    %eax,%ebx
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	85 c0                	test   %eax,%eax
  801982:	0f 88 89 00 00 00    	js     801a11 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801988:	83 ec 0c             	sub    $0xc,%esp
  80198b:	ff 75 f0             	pushl  -0x10(%ebp)
  80198e:	e8 b1 f5 ff ff       	call   800f44 <fd2data>
  801993:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80199a:	50                   	push   %eax
  80199b:	6a 00                	push   $0x0
  80199d:	56                   	push   %esi
  80199e:	6a 00                	push   $0x0
  8019a0:	e8 e1 f3 ff ff       	call   800d86 <sys_page_map>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	83 c4 20             	add    $0x20,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 55                	js     801a03 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019ae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019c3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 51 f5 ff ff       	call   800f34 <fd2num>
  8019e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019e8:	83 c4 04             	add    $0x4,%esp
  8019eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ee:	e8 41 f5 ff ff       	call   800f34 <fd2num>
  8019f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801a01:	eb 30                	jmp    801a33 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	56                   	push   %esi
  801a07:	6a 00                	push   $0x0
  801a09:	e8 ba f3 ff ff       	call   800dc8 <sys_page_unmap>
  801a0e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	ff 75 f0             	pushl  -0x10(%ebp)
  801a17:	6a 00                	push   $0x0
  801a19:	e8 aa f3 ff ff       	call   800dc8 <sys_page_unmap>
  801a1e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a21:	83 ec 08             	sub    $0x8,%esp
  801a24:	ff 75 f4             	pushl  -0xc(%ebp)
  801a27:	6a 00                	push   $0x0
  801a29:	e8 9a f3 ff ff       	call   800dc8 <sys_page_unmap>
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a33:	89 d0                	mov    %edx,%eax
  801a35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a45:	50                   	push   %eax
  801a46:	ff 75 08             	pushl  0x8(%ebp)
  801a49:	e8 5c f5 ff ff       	call   800faa <fd_lookup>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 18                	js     801a6d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5b:	e8 e4 f4 ff ff       	call   800f44 <fd2data>
	return _pipeisclosed(fd, p);
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	e8 21 fd ff ff       	call   80178b <_pipeisclosed>
  801a6a:	83 c4 10             	add    $0x10,%esp
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a72:	b8 00 00 00 00       	mov    $0x0,%eax
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a7f:	68 ac 24 80 00       	push   $0x8024ac
  801a84:	ff 75 0c             	pushl  0xc(%ebp)
  801a87:	e8 b4 ee ff ff       	call   800940 <strcpy>
	return 0;
}
  801a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	57                   	push   %edi
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a9f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801aa4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aaa:	eb 2d                	jmp    801ad9 <devcons_write+0x46>
		m = n - tot;
  801aac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aaf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ab1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ab4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ab9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801abc:	83 ec 04             	sub    $0x4,%esp
  801abf:	53                   	push   %ebx
  801ac0:	03 45 0c             	add    0xc(%ebp),%eax
  801ac3:	50                   	push   %eax
  801ac4:	57                   	push   %edi
  801ac5:	e8 08 f0 ff ff       	call   800ad2 <memmove>
		sys_cputs(buf, m);
  801aca:	83 c4 08             	add    $0x8,%esp
  801acd:	53                   	push   %ebx
  801ace:	57                   	push   %edi
  801acf:	e8 b3 f1 ff ff       	call   800c87 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ad4:	01 de                	add    %ebx,%esi
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	89 f0                	mov    %esi,%eax
  801adb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ade:	72 cc                	jb     801aac <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae3:	5b                   	pop    %ebx
  801ae4:	5e                   	pop    %esi
  801ae5:	5f                   	pop    %edi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	83 ec 08             	sub    $0x8,%esp
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801af3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af7:	74 2a                	je     801b23 <devcons_read+0x3b>
  801af9:	eb 05                	jmp    801b00 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801afb:	e8 24 f2 ff ff       	call   800d24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b00:	e8 a0 f1 ff ff       	call   800ca5 <sys_cgetc>
  801b05:	85 c0                	test   %eax,%eax
  801b07:	74 f2                	je     801afb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 16                	js     801b23 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b0d:	83 f8 04             	cmp    $0x4,%eax
  801b10:	74 0c                	je     801b1e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b15:	88 02                	mov    %al,(%edx)
	return 1;
  801b17:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1c:	eb 05                	jmp    801b23 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b31:	6a 01                	push   $0x1
  801b33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	e8 4b f1 ff ff       	call   800c87 <sys_cputs>
}
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	c9                   	leave  
  801b40:	c3                   	ret    

00801b41 <getchar>:

int
getchar(void)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b47:	6a 01                	push   $0x1
  801b49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b4c:	50                   	push   %eax
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 bc f6 ff ff       	call   801210 <read>
	if (r < 0)
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 0f                	js     801b6a <getchar+0x29>
		return r;
	if (r < 1)
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	7e 06                	jle    801b65 <getchar+0x24>
		return -E_EOF;
	return c;
  801b5f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b63:	eb 05                	jmp    801b6a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b65:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b75:	50                   	push   %eax
  801b76:	ff 75 08             	pushl  0x8(%ebp)
  801b79:	e8 2c f4 ff ff       	call   800faa <fd_lookup>
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	85 c0                	test   %eax,%eax
  801b83:	78 11                	js     801b96 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b88:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b8e:	39 10                	cmp    %edx,(%eax)
  801b90:	0f 94 c0             	sete   %al
  801b93:	0f b6 c0             	movzbl %al,%eax
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <opencons>:

int
opencons(void)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 b4 f3 ff ff       	call   800f5b <fd_alloc>
  801ba7:	83 c4 10             	add    $0x10,%esp
		return r;
  801baa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 3e                	js     801bee <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 81 f1 ff ff       	call   800d43 <sys_page_alloc>
  801bc2:	83 c4 10             	add    $0x10,%esp
		return r;
  801bc5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 23                	js     801bee <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bcb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	50                   	push   %eax
  801be4:	e8 4b f3 ff ff       	call   800f34 <fd2num>
  801be9:	89 c2                	mov    %eax,%edx
  801beb:	83 c4 10             	add    $0x10,%esp
}
  801bee:	89 d0                	mov    %edx,%eax
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801c00:	85 c0                	test   %eax,%eax
  801c02:	74 0e                	je     801c12 <ipc_recv+0x20>
  801c04:	83 ec 0c             	sub    $0xc,%esp
  801c07:	50                   	push   %eax
  801c08:	e8 e6 f2 ff ff       	call   800ef3 <sys_ipc_recv>
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	eb 10                	jmp    801c22 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	68 00 00 c0 ee       	push   $0xeec00000
  801c1a:	e8 d4 f2 ff ff       	call   800ef3 <sys_ipc_recv>
  801c1f:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801c22:	85 c0                	test   %eax,%eax
  801c24:	74 16                	je     801c3c <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801c26:	85 f6                	test   %esi,%esi
  801c28:	74 06                	je     801c30 <ipc_recv+0x3e>
  801c2a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801c30:	85 db                	test   %ebx,%ebx
  801c32:	74 2c                	je     801c60 <ipc_recv+0x6e>
  801c34:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c3a:	eb 24                	jmp    801c60 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801c3c:	85 f6                	test   %esi,%esi
  801c3e:	74 0a                	je     801c4a <ipc_recv+0x58>
  801c40:	a1 04 40 80 00       	mov    0x804004,%eax
  801c45:	8b 40 74             	mov    0x74(%eax),%eax
  801c48:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801c4a:	85 db                	test   %ebx,%ebx
  801c4c:	74 0a                	je     801c58 <ipc_recv+0x66>
  801c4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801c53:	8b 40 78             	mov    0x78(%eax),%eax
  801c56:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c58:	a1 04 40 80 00       	mov    0x804004,%eax
  801c5d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	57                   	push   %edi
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 0c             	sub    $0xc,%esp
  801c70:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c73:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c76:	8b 45 10             	mov    0x10(%ebp),%eax
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801c80:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801c83:	ff 75 14             	pushl  0x14(%ebp)
  801c86:	53                   	push   %ebx
  801c87:	56                   	push   %esi
  801c88:	57                   	push   %edi
  801c89:	e8 42 f2 ff ff       	call   800ed0 <sys_ipc_try_send>
		if (ret == 0) break;
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	74 1e                	je     801cb3 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801c95:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c98:	74 12                	je     801cac <ipc_send+0x45>
  801c9a:	50                   	push   %eax
  801c9b:	68 b8 24 80 00       	push   $0x8024b8
  801ca0:	6a 39                	push   $0x39
  801ca2:	68 c5 24 80 00       	push   $0x8024c5
  801ca7:	e8 8f e5 ff ff       	call   80023b <_panic>
		sys_yield();
  801cac:	e8 73 f0 ff ff       	call   800d24 <sys_yield>
	}
  801cb1:	eb d0                	jmp    801c83 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5f                   	pop    %edi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cc6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cc9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ccf:	8b 52 50             	mov    0x50(%edx),%edx
  801cd2:	39 ca                	cmp    %ecx,%edx
  801cd4:	75 0d                	jne    801ce3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cd6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cd9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cde:	8b 40 48             	mov    0x48(%eax),%eax
  801ce1:	eb 0f                	jmp    801cf2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ce3:	83 c0 01             	add    $0x1,%eax
  801ce6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ceb:	75 d9                	jne    801cc6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	c1 e8 16             	shr    $0x16,%eax
  801cff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d06:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d0b:	f6 c1 01             	test   $0x1,%cl
  801d0e:	74 1d                	je     801d2d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d10:	c1 ea 0c             	shr    $0xc,%edx
  801d13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d1a:	f6 c2 01             	test   $0x1,%dl
  801d1d:	74 0e                	je     801d2d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d1f:	c1 ea 0c             	shr    $0xc,%edx
  801d22:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d29:	ef 
  801d2a:	0f b7 c0             	movzwl %ax,%eax
}
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    
  801d2f:	90                   	nop

00801d30 <__udivdi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 1c             	sub    $0x1c,%esp
  801d37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d47:	85 f6                	test   %esi,%esi
  801d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d4d:	89 ca                	mov    %ecx,%edx
  801d4f:	89 f8                	mov    %edi,%eax
  801d51:	75 3d                	jne    801d90 <__udivdi3+0x60>
  801d53:	39 cf                	cmp    %ecx,%edi
  801d55:	0f 87 c5 00 00 00    	ja     801e20 <__udivdi3+0xf0>
  801d5b:	85 ff                	test   %edi,%edi
  801d5d:	89 fd                	mov    %edi,%ebp
  801d5f:	75 0b                	jne    801d6c <__udivdi3+0x3c>
  801d61:	b8 01 00 00 00       	mov    $0x1,%eax
  801d66:	31 d2                	xor    %edx,%edx
  801d68:	f7 f7                	div    %edi
  801d6a:	89 c5                	mov    %eax,%ebp
  801d6c:	89 c8                	mov    %ecx,%eax
  801d6e:	31 d2                	xor    %edx,%edx
  801d70:	f7 f5                	div    %ebp
  801d72:	89 c1                	mov    %eax,%ecx
  801d74:	89 d8                	mov    %ebx,%eax
  801d76:	89 cf                	mov    %ecx,%edi
  801d78:	f7 f5                	div    %ebp
  801d7a:	89 c3                	mov    %eax,%ebx
  801d7c:	89 d8                	mov    %ebx,%eax
  801d7e:	89 fa                	mov    %edi,%edx
  801d80:	83 c4 1c             	add    $0x1c,%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    
  801d88:	90                   	nop
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	39 ce                	cmp    %ecx,%esi
  801d92:	77 74                	ja     801e08 <__udivdi3+0xd8>
  801d94:	0f bd fe             	bsr    %esi,%edi
  801d97:	83 f7 1f             	xor    $0x1f,%edi
  801d9a:	0f 84 98 00 00 00    	je     801e38 <__udivdi3+0x108>
  801da0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801da5:	89 f9                	mov    %edi,%ecx
  801da7:	89 c5                	mov    %eax,%ebp
  801da9:	29 fb                	sub    %edi,%ebx
  801dab:	d3 e6                	shl    %cl,%esi
  801dad:	89 d9                	mov    %ebx,%ecx
  801daf:	d3 ed                	shr    %cl,%ebp
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	d3 e0                	shl    %cl,%eax
  801db5:	09 ee                	or     %ebp,%esi
  801db7:	89 d9                	mov    %ebx,%ecx
  801db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dbd:	89 d5                	mov    %edx,%ebp
  801dbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dc3:	d3 ed                	shr    %cl,%ebp
  801dc5:	89 f9                	mov    %edi,%ecx
  801dc7:	d3 e2                	shl    %cl,%edx
  801dc9:	89 d9                	mov    %ebx,%ecx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	09 c2                	or     %eax,%edx
  801dcf:	89 d0                	mov    %edx,%eax
  801dd1:	89 ea                	mov    %ebp,%edx
  801dd3:	f7 f6                	div    %esi
  801dd5:	89 d5                	mov    %edx,%ebp
  801dd7:	89 c3                	mov    %eax,%ebx
  801dd9:	f7 64 24 0c          	mull   0xc(%esp)
  801ddd:	39 d5                	cmp    %edx,%ebp
  801ddf:	72 10                	jb     801df1 <__udivdi3+0xc1>
  801de1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e6                	shl    %cl,%esi
  801de9:	39 c6                	cmp    %eax,%esi
  801deb:	73 07                	jae    801df4 <__udivdi3+0xc4>
  801ded:	39 d5                	cmp    %edx,%ebp
  801def:	75 03                	jne    801df4 <__udivdi3+0xc4>
  801df1:	83 eb 01             	sub    $0x1,%ebx
  801df4:	31 ff                	xor    %edi,%edi
  801df6:	89 d8                	mov    %ebx,%eax
  801df8:	89 fa                	mov    %edi,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	31 ff                	xor    %edi,%edi
  801e0a:	31 db                	xor    %ebx,%ebx
  801e0c:	89 d8                	mov    %ebx,%eax
  801e0e:	89 fa                	mov    %edi,%edx
  801e10:	83 c4 1c             	add    $0x1c,%esp
  801e13:	5b                   	pop    %ebx
  801e14:	5e                   	pop    %esi
  801e15:	5f                   	pop    %edi
  801e16:	5d                   	pop    %ebp
  801e17:	c3                   	ret    
  801e18:	90                   	nop
  801e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e20:	89 d8                	mov    %ebx,%eax
  801e22:	f7 f7                	div    %edi
  801e24:	31 ff                	xor    %edi,%edi
  801e26:	89 c3                	mov    %eax,%ebx
  801e28:	89 d8                	mov    %ebx,%eax
  801e2a:	89 fa                	mov    %edi,%edx
  801e2c:	83 c4 1c             	add    $0x1c,%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5f                   	pop    %edi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    
  801e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e38:	39 ce                	cmp    %ecx,%esi
  801e3a:	72 0c                	jb     801e48 <__udivdi3+0x118>
  801e3c:	31 db                	xor    %ebx,%ebx
  801e3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e42:	0f 87 34 ff ff ff    	ja     801d7c <__udivdi3+0x4c>
  801e48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e4d:	e9 2a ff ff ff       	jmp    801d7c <__udivdi3+0x4c>
  801e52:	66 90                	xchg   %ax,%ax
  801e54:	66 90                	xchg   %ax,%ax
  801e56:	66 90                	xchg   %ax,%ax
  801e58:	66 90                	xchg   %ax,%ax
  801e5a:	66 90                	xchg   %ax,%ax
  801e5c:	66 90                	xchg   %ax,%ax
  801e5e:	66 90                	xchg   %ax,%ax

00801e60 <__umoddi3>:
  801e60:	55                   	push   %ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 1c             	sub    $0x1c,%esp
  801e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e77:	85 d2                	test   %edx,%edx
  801e79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e81:	89 f3                	mov    %esi,%ebx
  801e83:	89 3c 24             	mov    %edi,(%esp)
  801e86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e8a:	75 1c                	jne    801ea8 <__umoddi3+0x48>
  801e8c:	39 f7                	cmp    %esi,%edi
  801e8e:	76 50                	jbe    801ee0 <__umoddi3+0x80>
  801e90:	89 c8                	mov    %ecx,%eax
  801e92:	89 f2                	mov    %esi,%edx
  801e94:	f7 f7                	div    %edi
  801e96:	89 d0                	mov    %edx,%eax
  801e98:	31 d2                	xor    %edx,%edx
  801e9a:	83 c4 1c             	add    $0x1c,%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    
  801ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ea8:	39 f2                	cmp    %esi,%edx
  801eaa:	89 d0                	mov    %edx,%eax
  801eac:	77 52                	ja     801f00 <__umoddi3+0xa0>
  801eae:	0f bd ea             	bsr    %edx,%ebp
  801eb1:	83 f5 1f             	xor    $0x1f,%ebp
  801eb4:	75 5a                	jne    801f10 <__umoddi3+0xb0>
  801eb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eba:	0f 82 e0 00 00 00    	jb     801fa0 <__umoddi3+0x140>
  801ec0:	39 0c 24             	cmp    %ecx,(%esp)
  801ec3:	0f 86 d7 00 00 00    	jbe    801fa0 <__umoddi3+0x140>
  801ec9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ecd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ed1:	83 c4 1c             	add    $0x1c,%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    
  801ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee0:	85 ff                	test   %edi,%edi
  801ee2:	89 fd                	mov    %edi,%ebp
  801ee4:	75 0b                	jne    801ef1 <__umoddi3+0x91>
  801ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  801eeb:	31 d2                	xor    %edx,%edx
  801eed:	f7 f7                	div    %edi
  801eef:	89 c5                	mov    %eax,%ebp
  801ef1:	89 f0                	mov    %esi,%eax
  801ef3:	31 d2                	xor    %edx,%edx
  801ef5:	f7 f5                	div    %ebp
  801ef7:	89 c8                	mov    %ecx,%eax
  801ef9:	f7 f5                	div    %ebp
  801efb:	89 d0                	mov    %edx,%eax
  801efd:	eb 99                	jmp    801e98 <__umoddi3+0x38>
  801eff:	90                   	nop
  801f00:	89 c8                	mov    %ecx,%eax
  801f02:	89 f2                	mov    %esi,%edx
  801f04:	83 c4 1c             	add    $0x1c,%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5f                   	pop    %edi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    
  801f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f10:	8b 34 24             	mov    (%esp),%esi
  801f13:	bf 20 00 00 00       	mov    $0x20,%edi
  801f18:	89 e9                	mov    %ebp,%ecx
  801f1a:	29 ef                	sub    %ebp,%edi
  801f1c:	d3 e0                	shl    %cl,%eax
  801f1e:	89 f9                	mov    %edi,%ecx
  801f20:	89 f2                	mov    %esi,%edx
  801f22:	d3 ea                	shr    %cl,%edx
  801f24:	89 e9                	mov    %ebp,%ecx
  801f26:	09 c2                	or     %eax,%edx
  801f28:	89 d8                	mov    %ebx,%eax
  801f2a:	89 14 24             	mov    %edx,(%esp)
  801f2d:	89 f2                	mov    %esi,%edx
  801f2f:	d3 e2                	shl    %cl,%edx
  801f31:	89 f9                	mov    %edi,%ecx
  801f33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f3b:	d3 e8                	shr    %cl,%eax
  801f3d:	89 e9                	mov    %ebp,%ecx
  801f3f:	89 c6                	mov    %eax,%esi
  801f41:	d3 e3                	shl    %cl,%ebx
  801f43:	89 f9                	mov    %edi,%ecx
  801f45:	89 d0                	mov    %edx,%eax
  801f47:	d3 e8                	shr    %cl,%eax
  801f49:	89 e9                	mov    %ebp,%ecx
  801f4b:	09 d8                	or     %ebx,%eax
  801f4d:	89 d3                	mov    %edx,%ebx
  801f4f:	89 f2                	mov    %esi,%edx
  801f51:	f7 34 24             	divl   (%esp)
  801f54:	89 d6                	mov    %edx,%esi
  801f56:	d3 e3                	shl    %cl,%ebx
  801f58:	f7 64 24 04          	mull   0x4(%esp)
  801f5c:	39 d6                	cmp    %edx,%esi
  801f5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f62:	89 d1                	mov    %edx,%ecx
  801f64:	89 c3                	mov    %eax,%ebx
  801f66:	72 08                	jb     801f70 <__umoddi3+0x110>
  801f68:	75 11                	jne    801f7b <__umoddi3+0x11b>
  801f6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f6e:	73 0b                	jae    801f7b <__umoddi3+0x11b>
  801f70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f74:	1b 14 24             	sbb    (%esp),%edx
  801f77:	89 d1                	mov    %edx,%ecx
  801f79:	89 c3                	mov    %eax,%ebx
  801f7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f7f:	29 da                	sub    %ebx,%edx
  801f81:	19 ce                	sbb    %ecx,%esi
  801f83:	89 f9                	mov    %edi,%ecx
  801f85:	89 f0                	mov    %esi,%eax
  801f87:	d3 e0                	shl    %cl,%eax
  801f89:	89 e9                	mov    %ebp,%ecx
  801f8b:	d3 ea                	shr    %cl,%edx
  801f8d:	89 e9                	mov    %ebp,%ecx
  801f8f:	d3 ee                	shr    %cl,%esi
  801f91:	09 d0                	or     %edx,%eax
  801f93:	89 f2                	mov    %esi,%edx
  801f95:	83 c4 1c             	add    $0x1c,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    
  801f9d:	8d 76 00             	lea    0x0(%esi),%esi
  801fa0:	29 f9                	sub    %edi,%ecx
  801fa2:	19 d6                	sbb    %edx,%esi
  801fa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fac:	e9 18 ff ff ff       	jmp    801ec9 <__umoddi3+0x69>
