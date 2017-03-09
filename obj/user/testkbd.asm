
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
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
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 64 0e 00 00       	call   800ea8 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 05 12 00 00       	call   801258 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 e0 20 80 00       	push   $0x8020e0
  800065:	6a 0f                	push   $0xf
  800067:	68 ed 20 80 00       	push   $0x8020ed
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 fc 20 80 00       	push   $0x8020fc
  80007b:	6a 11                	push   $0x11
  80007d:	68 ed 20 80 00       	push   $0x8020ed
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 15 12 00 00       	call   8012a8 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 16 21 80 00       	push   $0x802116
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 ed 20 80 00       	push   $0x8020ed
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 1e 21 80 00       	push   $0x80211e
  8000b4:	e8 df 08 00 00       	call   800998 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 2c 21 80 00       	push   $0x80212c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 aa 18 00 00       	call   80197a <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 30 21 80 00       	push   $0x802130
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 96 18 00 00       	call   80197a <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 48 21 80 00       	push   $0x802148
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 be 09 00 00       	call   800ac4 <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 12 0b 00 00       	call   800c56 <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 bd 0c 00 00       	call   800e0b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 2e 0d 00 00       	call   800ea8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 aa 0c 00 00       	call   800e29 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 55 0c 00 00       	call   800e0b <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 c6 11 00 00       	call   801394 <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 36 0f 00 00       	call   80112e <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 be 0e 00 00       	call   8010df <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 8b 0c 00 00       	call   800ec7 <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 55 0e 00 00       	call   8010b8 <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800277:	e8 0d 0c 00 00       	call   800e89 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 c6 0f 00 00       	call   801283 <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 81 0b 00 00       	call   800e48 <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 aa 0b 00 00       	call   800e89 <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 60 21 80 00       	push   $0x802160
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 46 21 80 00 	movl   $0x802146,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 c9 0a 00 00       	call   800e0b <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 1a 01 00 00       	call   8004a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 6e 0a 00 00       	call   800e0b <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 33 1a 00 00       	call   801e40 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 20 1b 00 00       	call   801f70 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 83 21 80 00 	movsbl 0x802183(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800472:	8b 10                	mov    (%eax),%edx
  800474:	3b 50 04             	cmp    0x4(%eax),%edx
  800477:	73 0a                	jae    800483 <sprintputch+0x1b>
		*b->buf++ = ch;
  800479:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047c:	89 08                	mov    %ecx,(%eax)
  80047e:	8b 45 08             	mov    0x8(%ebp),%eax
  800481:	88 02                	mov    %al,(%edx)
}
  800483:	5d                   	pop    %ebp
  800484:	c3                   	ret    

00800485 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80048b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048e:	50                   	push   %eax
  80048f:	ff 75 10             	pushl  0x10(%ebp)
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	ff 75 08             	pushl  0x8(%ebp)
  800498:	e8 05 00 00 00       	call   8004a2 <vprintfmt>
	va_end(ap);
}
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    

008004a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	57                   	push   %edi
  8004a6:	56                   	push   %esi
  8004a7:	53                   	push   %ebx
  8004a8:	83 ec 2c             	sub    $0x2c,%esp
  8004ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004b4:	eb 12                	jmp    8004c8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	0f 84 6a 04 00 00    	je     800928 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	53                   	push   %ebx
  8004c2:	50                   	push   %eax
  8004c3:	ff d6                	call   *%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c8:	83 c7 01             	add    $0x1,%edi
  8004cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cf:	83 f8 25             	cmp    $0x25,%eax
  8004d2:	75 e2                	jne    8004b6 <vprintfmt+0x14>
  8004d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f2:	eb 07                	jmp    8004fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8d 47 01             	lea    0x1(%edi),%eax
  8004fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800501:	0f b6 07             	movzbl (%edi),%eax
  800504:	0f b6 d0             	movzbl %al,%edx
  800507:	83 e8 23             	sub    $0x23,%eax
  80050a:	3c 55                	cmp    $0x55,%al
  80050c:	0f 87 fb 03 00 00    	ja     80090d <vprintfmt+0x46b>
  800512:	0f b6 c0             	movzbl %al,%eax
  800515:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80051f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800523:	eb d6                	jmp    8004fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800528:	b8 00 00 00 00       	mov    $0x0,%eax
  80052d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800530:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800533:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800537:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80053a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80053d:	83 f9 09             	cmp    $0x9,%ecx
  800540:	77 3f                	ja     800581 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800542:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800545:	eb e9                	jmp    800530 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 04             	lea    0x4(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055b:	eb 2a                	jmp    800587 <vprintfmt+0xe5>
  80055d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800560:	85 c0                	test   %eax,%eax
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	0f 49 d0             	cmovns %eax,%edx
  80056a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800570:	eb 89                	jmp    8004fb <vprintfmt+0x59>
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800575:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057c:	e9 7a ff ff ff       	jmp    8004fb <vprintfmt+0x59>
  800581:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 6a ff ff ff    	jns    8004fb <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 58 ff ff ff       	jmp    8004fb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 4d ff ff ff       	jmp    8004fb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 78 04             	lea    0x4(%eax),%edi
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	ff 30                	pushl  (%eax)
  8005ba:	ff d6                	call   *%esi
			break;
  8005bc:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005bf:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 fe fe ff ff       	jmp    8004c8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 78 04             	lea    0x4(%eax),%edi
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	99                   	cltd   
  8005d3:	31 d0                	xor    %edx,%eax
  8005d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d7:	83 f8 0f             	cmp    $0xf,%eax
  8005da:	7f 0b                	jg     8005e7 <vprintfmt+0x145>
  8005dc:	8b 14 85 20 24 80 00 	mov    0x802420(,%eax,4),%edx
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	75 1b                	jne    800602 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8005e7:	50                   	push   %eax
  8005e8:	68 9b 21 80 00       	push   $0x80219b
  8005ed:	53                   	push   %ebx
  8005ee:	56                   	push   %esi
  8005ef:	e8 91 fe ff ff       	call   800485 <printfmt>
  8005f4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 c6 fe ff ff       	jmp    8004c8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 8e 25 80 00       	push   $0x80258e
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 76 fe ff ff       	call   800485 <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800618:	e9 ab fe ff ff       	jmp    8004c8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	83 c0 04             	add    $0x4,%eax
  800623:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80062b:	85 ff                	test   %edi,%edi
  80062d:	b8 94 21 80 00       	mov    $0x802194,%eax
  800632:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800635:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800639:	0f 8e 94 00 00 00    	jle    8006d3 <vprintfmt+0x231>
  80063f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800643:	0f 84 98 00 00 00    	je     8006e1 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 d0             	pushl  -0x30(%ebp)
  80064f:	57                   	push   %edi
  800650:	e8 4e 04 00 00       	call   800aa3 <strnlen>
  800655:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800658:	29 c1                	sub    %eax,%ecx
  80065a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80065d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800660:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800664:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800667:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80066a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066c:	eb 0f                	jmp    80067d <vprintfmt+0x1db>
					putch(padc, putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	ff 75 e0             	pushl  -0x20(%ebp)
  800675:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ef 01             	sub    $0x1,%edi
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	85 ff                	test   %edi,%edi
  80067f:	7f ed                	jg     80066e <vprintfmt+0x1cc>
  800681:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800684:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800687:	85 c9                	test   %ecx,%ecx
  800689:	b8 00 00 00 00       	mov    $0x0,%eax
  80068e:	0f 49 c1             	cmovns %ecx,%eax
  800691:	29 c1                	sub    %eax,%ecx
  800693:	89 75 08             	mov    %esi,0x8(%ebp)
  800696:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800699:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069c:	89 cb                	mov    %ecx,%ebx
  80069e:	eb 4d                	jmp    8006ed <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006a4:	74 1b                	je     8006c1 <vprintfmt+0x21f>
  8006a6:	0f be c0             	movsbl %al,%eax
  8006a9:	83 e8 20             	sub    $0x20,%eax
  8006ac:	83 f8 5e             	cmp    $0x5e,%eax
  8006af:	76 10                	jbe    8006c1 <vprintfmt+0x21f>
					putch('?', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	ff 75 0c             	pushl  0xc(%ebp)
  8006b7:	6a 3f                	push   $0x3f
  8006b9:	ff 55 08             	call   *0x8(%ebp)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 0d                	jmp    8006ce <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	52                   	push   %edx
  8006c8:	ff 55 08             	call   *0x8(%ebp)
  8006cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ce:	83 eb 01             	sub    $0x1,%ebx
  8006d1:	eb 1a                	jmp    8006ed <vprintfmt+0x24b>
  8006d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006df:	eb 0c                	jmp    8006ed <vprintfmt+0x24b>
  8006e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ed:	83 c7 01             	add    $0x1,%edi
  8006f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f4:	0f be d0             	movsbl %al,%edx
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	74 23                	je     80071e <vprintfmt+0x27c>
  8006fb:	85 f6                	test   %esi,%esi
  8006fd:	78 a1                	js     8006a0 <vprintfmt+0x1fe>
  8006ff:	83 ee 01             	sub    $0x1,%esi
  800702:	79 9c                	jns    8006a0 <vprintfmt+0x1fe>
  800704:	89 df                	mov    %ebx,%edi
  800706:	8b 75 08             	mov    0x8(%ebp),%esi
  800709:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80070c:	eb 18                	jmp    800726 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 20                	push   $0x20
  800714:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800716:	83 ef 01             	sub    $0x1,%edi
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	eb 08                	jmp    800726 <vprintfmt+0x284>
  80071e:	89 df                	mov    %ebx,%edi
  800720:	8b 75 08             	mov    0x8(%ebp),%esi
  800723:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800726:	85 ff                	test   %edi,%edi
  800728:	7f e4                	jg     80070e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80072a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800733:	e9 90 fd ff ff       	jmp    8004c8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800738:	83 f9 01             	cmp    $0x1,%ecx
  80073b:	7e 19                	jle    800756 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 50 04             	mov    0x4(%eax),%edx
  800743:	8b 00                	mov    (%eax),%eax
  800745:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800748:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 40 08             	lea    0x8(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
  800754:	eb 38                	jmp    80078e <vprintfmt+0x2ec>
	else if (lflag)
  800756:	85 c9                	test   %ecx,%ecx
  800758:	74 1b                	je     800775 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800762:	89 c1                	mov    %eax,%ecx
  800764:	c1 f9 1f             	sar    $0x1f,%ecx
  800767:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 40 04             	lea    0x4(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
  800773:	eb 19                	jmp    80078e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077d:	89 c1                	mov    %eax,%ecx
  80077f:	c1 f9 1f             	sar    $0x1f,%ecx
  800782:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 40 04             	lea    0x4(%eax),%eax
  80078b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80078e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800791:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800794:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800799:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079d:	0f 89 36 01 00 00    	jns    8008d9 <vprintfmt+0x437>
				putch('-', putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 2d                	push   $0x2d
  8007a9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007b1:	f7 da                	neg    %edx
  8007b3:	83 d1 00             	adc    $0x0,%ecx
  8007b6:	f7 d9                	neg    %ecx
  8007b8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c0:	e9 14 01 00 00       	jmp    8008d9 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c5:	83 f9 01             	cmp    $0x1,%ecx
  8007c8:	7e 18                	jle    8007e2 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 10                	mov    (%eax),%edx
  8007cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d2:	8d 40 08             	lea    0x8(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007dd:	e9 f7 00 00 00       	jmp    8008d9 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007e2:	85 c9                	test   %ecx,%ecx
  8007e4:	74 1a                	je     800800 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f0:	8d 40 04             	lea    0x4(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fb:	e9 d9 00 00 00       	jmp    8008d9 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8b 10                	mov    (%eax),%edx
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080a:	8d 40 04             	lea    0x4(%eax),%eax
  80080d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800810:	b8 0a 00 00 00       	mov    $0xa,%eax
  800815:	e9 bf 00 00 00       	jmp    8008d9 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081a:	83 f9 01             	cmp    $0x1,%ecx
  80081d:	7e 13                	jle    800832 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8b 50 04             	mov    0x4(%eax),%edx
  800825:	8b 00                	mov    (%eax),%eax
  800827:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80082a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80082d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800830:	eb 28                	jmp    80085a <vprintfmt+0x3b8>
	else if (lflag)
  800832:	85 c9                	test   %ecx,%ecx
  800834:	74 13                	je     800849 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8b 10                	mov    (%eax),%edx
  80083b:	89 d0                	mov    %edx,%eax
  80083d:	99                   	cltd   
  80083e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800841:	8d 49 04             	lea    0x4(%ecx),%ecx
  800844:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800847:	eb 11                	jmp    80085a <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8b 10                	mov    (%eax),%edx
  80084e:	89 d0                	mov    %edx,%eax
  800850:	99                   	cltd   
  800851:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800854:	8d 49 04             	lea    0x4(%ecx),%ecx
  800857:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  80085a:	89 d1                	mov    %edx,%ecx
  80085c:	89 c2                	mov    %eax,%edx
			base = 8;
  80085e:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800863:	eb 74                	jmp    8008d9 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 30                	push   $0x30
  80086b:	ff d6                	call   *%esi
			putch('x', putdat);
  80086d:	83 c4 08             	add    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	6a 78                	push   $0x78
  800873:	ff d6                	call   *%esi
			num = (unsigned long long)
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8b 10                	mov    (%eax),%edx
  80087a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800882:	8d 40 04             	lea    0x4(%eax),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800888:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088d:	eb 4a                	jmp    8008d9 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80088f:	83 f9 01             	cmp    $0x1,%ecx
  800892:	7e 15                	jle    8008a9 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8b 10                	mov    (%eax),%edx
  800899:	8b 48 04             	mov    0x4(%eax),%ecx
  80089c:	8d 40 08             	lea    0x8(%eax),%eax
  80089f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008a2:	b8 10 00 00 00       	mov    $0x10,%eax
  8008a7:	eb 30                	jmp    8008d9 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 17                	je     8008c4 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8b 10                	mov    (%eax),%edx
  8008b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ba:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8008c2:	eb 15                	jmp    8008d9 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8b 10                	mov    (%eax),%edx
  8008c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ce:	8d 40 04             	lea    0x4(%eax),%eax
  8008d1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008d4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d9:	83 ec 0c             	sub    $0xc,%esp
  8008dc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008e0:	57                   	push   %edi
  8008e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8008e4:	50                   	push   %eax
  8008e5:	51                   	push   %ecx
  8008e6:	52                   	push   %edx
  8008e7:	89 da                	mov    %ebx,%edx
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	e8 c9 fa ff ff       	call   8003b9 <printnum>
			break;
  8008f0:	83 c4 20             	add    $0x20,%esp
  8008f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f6:	e9 cd fb ff ff       	jmp    8004c8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	53                   	push   %ebx
  8008ff:	52                   	push   %edx
  800900:	ff d6                	call   *%esi
			break;
  800902:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800908:	e9 bb fb ff ff       	jmp    8004c8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	53                   	push   %ebx
  800911:	6a 25                	push   $0x25
  800913:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	eb 03                	jmp    80091d <vprintfmt+0x47b>
  80091a:	83 ef 01             	sub    $0x1,%edi
  80091d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800921:	75 f7                	jne    80091a <vprintfmt+0x478>
  800923:	e9 a0 fb ff ff       	jmp    8004c8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800928:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	83 ec 18             	sub    $0x18,%esp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800943:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	74 26                	je     800977 <vsnprintf+0x47>
  800951:	85 d2                	test   %edx,%edx
  800953:	7e 22                	jle    800977 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800955:	ff 75 14             	pushl  0x14(%ebp)
  800958:	ff 75 10             	pushl  0x10(%ebp)
  80095b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095e:	50                   	push   %eax
  80095f:	68 68 04 80 00       	push   $0x800468
  800964:	e8 39 fb ff ff       	call   8004a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800969:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80096c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	eb 05                	jmp    80097c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800977:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800984:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800987:	50                   	push   %eax
  800988:	ff 75 10             	pushl  0x10(%ebp)
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	ff 75 08             	pushl  0x8(%ebp)
  800991:	e8 9a ff ff ff       	call   800930 <vsnprintf>
	va_end(ap);

	return rc;
}
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	83 ec 0c             	sub    $0xc,%esp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	74 13                	je     8009bb <readline+0x23>
		fprintf(1, "%s", prompt);
  8009a8:	83 ec 04             	sub    $0x4,%esp
  8009ab:	50                   	push   %eax
  8009ac:	68 8e 25 80 00       	push   $0x80258e
  8009b1:	6a 01                	push   $0x1
  8009b3:	e8 c2 0f 00 00       	call   80197a <fprintf>
  8009b8:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8009bb:	83 ec 0c             	sub    $0xc,%esp
  8009be:	6a 00                	push   $0x0
  8009c0:	e8 21 f8 ff ff       	call   8001e6 <iscons>
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009ca:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009cf:	e8 e7 f7 ff ff       	call   8001bb <getchar>
  8009d4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	79 29                	jns    800a03 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8009df:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8009e2:	0f 84 9b 00 00 00    	je     800a83 <readline+0xeb>
				cprintf("read error: %e\n", c);
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	53                   	push   %ebx
  8009ec:	68 7f 24 80 00       	push   $0x80247f
  8009f1:	e8 af f9 ff ff       	call   8003a5 <cprintf>
  8009f6:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	e9 80 00 00 00       	jmp    800a83 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a03:	83 f8 08             	cmp    $0x8,%eax
  800a06:	0f 94 c2             	sete   %dl
  800a09:	83 f8 7f             	cmp    $0x7f,%eax
  800a0c:	0f 94 c0             	sete   %al
  800a0f:	08 c2                	or     %al,%dl
  800a11:	74 1a                	je     800a2d <readline+0x95>
  800a13:	85 f6                	test   %esi,%esi
  800a15:	7e 16                	jle    800a2d <readline+0x95>
			if (echoing)
  800a17:	85 ff                	test   %edi,%edi
  800a19:	74 0d                	je     800a28 <readline+0x90>
				cputchar('\b');
  800a1b:	83 ec 0c             	sub    $0xc,%esp
  800a1e:	6a 08                	push   $0x8
  800a20:	e8 7a f7 ff ff       	call   80019f <cputchar>
  800a25:	83 c4 10             	add    $0x10,%esp
			i--;
  800a28:	83 ee 01             	sub    $0x1,%esi
  800a2b:	eb a2                	jmp    8009cf <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a2d:	83 fb 1f             	cmp    $0x1f,%ebx
  800a30:	7e 26                	jle    800a58 <readline+0xc0>
  800a32:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a38:	7f 1e                	jg     800a58 <readline+0xc0>
			if (echoing)
  800a3a:	85 ff                	test   %edi,%edi
  800a3c:	74 0c                	je     800a4a <readline+0xb2>
				cputchar(c);
  800a3e:	83 ec 0c             	sub    $0xc,%esp
  800a41:	53                   	push   %ebx
  800a42:	e8 58 f7 ff ff       	call   80019f <cputchar>
  800a47:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800a4a:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a50:	8d 76 01             	lea    0x1(%esi),%esi
  800a53:	e9 77 ff ff ff       	jmp    8009cf <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  800a58:	83 fb 0a             	cmp    $0xa,%ebx
  800a5b:	74 09                	je     800a66 <readline+0xce>
  800a5d:	83 fb 0d             	cmp    $0xd,%ebx
  800a60:	0f 85 69 ff ff ff    	jne    8009cf <readline+0x37>
			if (echoing)
  800a66:	85 ff                	test   %edi,%edi
  800a68:	74 0d                	je     800a77 <readline+0xdf>
				cputchar('\n');
  800a6a:	83 ec 0c             	sub    $0xc,%esp
  800a6d:	6a 0a                	push   $0xa
  800a6f:	e8 2b f7 ff ff       	call   80019f <cputchar>
  800a74:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800a77:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a7e:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	eb 03                	jmp    800a9b <strlen+0x10>
		n++;
  800a98:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a9b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a9f:	75 f7                	jne    800a98 <strlen+0xd>
		n++;
	return n;
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	eb 03                	jmp    800ab6 <strnlen+0x13>
		n++;
  800ab3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab6:	39 c2                	cmp    %eax,%edx
  800ab8:	74 08                	je     800ac2 <strnlen+0x1f>
  800aba:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800abe:	75 f3                	jne    800ab3 <strnlen+0x10>
  800ac0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	53                   	push   %ebx
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ace:	89 c2                	mov    %eax,%edx
  800ad0:	83 c2 01             	add    $0x1,%edx
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ada:	88 5a ff             	mov    %bl,-0x1(%edx)
  800add:	84 db                	test   %bl,%bl
  800adf:	75 ef                	jne    800ad0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aeb:	53                   	push   %ebx
  800aec:	e8 9a ff ff ff       	call   800a8b <strlen>
  800af1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800af4:	ff 75 0c             	pushl  0xc(%ebp)
  800af7:	01 d8                	add    %ebx,%eax
  800af9:	50                   	push   %eax
  800afa:	e8 c5 ff ff ff       	call   800ac4 <strcpy>
	return dst;
}
  800aff:	89 d8                	mov    %ebx,%eax
  800b01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	89 f3                	mov    %esi,%ebx
  800b13:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b16:	89 f2                	mov    %esi,%edx
  800b18:	eb 0f                	jmp    800b29 <strncpy+0x23>
		*dst++ = *src;
  800b1a:	83 c2 01             	add    $0x1,%edx
  800b1d:	0f b6 01             	movzbl (%ecx),%eax
  800b20:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b23:	80 39 01             	cmpb   $0x1,(%ecx)
  800b26:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b29:	39 da                	cmp    %ebx,%edx
  800b2b:	75 ed                	jne    800b1a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b2d:	89 f0                	mov    %esi,%eax
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 10             	mov    0x10(%ebp),%edx
  800b41:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b43:	85 d2                	test   %edx,%edx
  800b45:	74 21                	je     800b68 <strlcpy+0x35>
  800b47:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b4b:	89 f2                	mov    %esi,%edx
  800b4d:	eb 09                	jmp    800b58 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b4f:	83 c2 01             	add    $0x1,%edx
  800b52:	83 c1 01             	add    $0x1,%ecx
  800b55:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b58:	39 c2                	cmp    %eax,%edx
  800b5a:	74 09                	je     800b65 <strlcpy+0x32>
  800b5c:	0f b6 19             	movzbl (%ecx),%ebx
  800b5f:	84 db                	test   %bl,%bl
  800b61:	75 ec                	jne    800b4f <strlcpy+0x1c>
  800b63:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b65:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b68:	29 f0                	sub    %esi,%eax
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b74:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b77:	eb 06                	jmp    800b7f <strcmp+0x11>
		p++, q++;
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b7f:	0f b6 01             	movzbl (%ecx),%eax
  800b82:	84 c0                	test   %al,%al
  800b84:	74 04                	je     800b8a <strcmp+0x1c>
  800b86:	3a 02                	cmp    (%edx),%al
  800b88:	74 ef                	je     800b79 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8a:	0f b6 c0             	movzbl %al,%eax
  800b8d:	0f b6 12             	movzbl (%edx),%edx
  800b90:	29 d0                	sub    %edx,%eax
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	53                   	push   %ebx
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9e:	89 c3                	mov    %eax,%ebx
  800ba0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ba3:	eb 06                	jmp    800bab <strncmp+0x17>
		n--, p++, q++;
  800ba5:	83 c0 01             	add    $0x1,%eax
  800ba8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bab:	39 d8                	cmp    %ebx,%eax
  800bad:	74 15                	je     800bc4 <strncmp+0x30>
  800baf:	0f b6 08             	movzbl (%eax),%ecx
  800bb2:	84 c9                	test   %cl,%cl
  800bb4:	74 04                	je     800bba <strncmp+0x26>
  800bb6:	3a 0a                	cmp    (%edx),%cl
  800bb8:	74 eb                	je     800ba5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bba:	0f b6 00             	movzbl (%eax),%eax
  800bbd:	0f b6 12             	movzbl (%edx),%edx
  800bc0:	29 d0                	sub    %edx,%eax
  800bc2:	eb 05                	jmp    800bc9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd6:	eb 07                	jmp    800bdf <strchr+0x13>
		if (*s == c)
  800bd8:	38 ca                	cmp    %cl,%dl
  800bda:	74 0f                	je     800beb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bdc:	83 c0 01             	add    $0x1,%eax
  800bdf:	0f b6 10             	movzbl (%eax),%edx
  800be2:	84 d2                	test   %dl,%dl
  800be4:	75 f2                	jne    800bd8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bf7:	eb 03                	jmp    800bfc <strfind+0xf>
  800bf9:	83 c0 01             	add    $0x1,%eax
  800bfc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bff:	38 ca                	cmp    %cl,%dl
  800c01:	74 04                	je     800c07 <strfind+0x1a>
  800c03:	84 d2                	test   %dl,%dl
  800c05:	75 f2                	jne    800bf9 <strfind+0xc>
			break;
	return (char *) s;
}
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c15:	85 c9                	test   %ecx,%ecx
  800c17:	74 36                	je     800c4f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c1f:	75 28                	jne    800c49 <memset+0x40>
  800c21:	f6 c1 03             	test   $0x3,%cl
  800c24:	75 23                	jne    800c49 <memset+0x40>
		c &= 0xFF;
  800c26:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c2a:	89 d3                	mov    %edx,%ebx
  800c2c:	c1 e3 08             	shl    $0x8,%ebx
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	c1 e6 18             	shl    $0x18,%esi
  800c34:	89 d0                	mov    %edx,%eax
  800c36:	c1 e0 10             	shl    $0x10,%eax
  800c39:	09 f0                	or     %esi,%eax
  800c3b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c3d:	89 d8                	mov    %ebx,%eax
  800c3f:	09 d0                	or     %edx,%eax
  800c41:	c1 e9 02             	shr    $0x2,%ecx
  800c44:	fc                   	cld    
  800c45:	f3 ab                	rep stos %eax,%es:(%edi)
  800c47:	eb 06                	jmp    800c4f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4c:	fc                   	cld    
  800c4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c4f:	89 f8                	mov    %edi,%eax
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c64:	39 c6                	cmp    %eax,%esi
  800c66:	73 35                	jae    800c9d <memmove+0x47>
  800c68:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c6b:	39 d0                	cmp    %edx,%eax
  800c6d:	73 2e                	jae    800c9d <memmove+0x47>
		s += n;
		d += n;
  800c6f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c72:	89 d6                	mov    %edx,%esi
  800c74:	09 fe                	or     %edi,%esi
  800c76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c7c:	75 13                	jne    800c91 <memmove+0x3b>
  800c7e:	f6 c1 03             	test   $0x3,%cl
  800c81:	75 0e                	jne    800c91 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c83:	83 ef 04             	sub    $0x4,%edi
  800c86:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c89:	c1 e9 02             	shr    $0x2,%ecx
  800c8c:	fd                   	std    
  800c8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8f:	eb 09                	jmp    800c9a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c91:	83 ef 01             	sub    $0x1,%edi
  800c94:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c97:	fd                   	std    
  800c98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c9a:	fc                   	cld    
  800c9b:	eb 1d                	jmp    800cba <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c9d:	89 f2                	mov    %esi,%edx
  800c9f:	09 c2                	or     %eax,%edx
  800ca1:	f6 c2 03             	test   $0x3,%dl
  800ca4:	75 0f                	jne    800cb5 <memmove+0x5f>
  800ca6:	f6 c1 03             	test   $0x3,%cl
  800ca9:	75 0a                	jne    800cb5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cab:	c1 e9 02             	shr    $0x2,%ecx
  800cae:	89 c7                	mov    %eax,%edi
  800cb0:	fc                   	cld    
  800cb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cb3:	eb 05                	jmp    800cba <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cb5:	89 c7                	mov    %eax,%edi
  800cb7:	fc                   	cld    
  800cb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cc1:	ff 75 10             	pushl  0x10(%ebp)
  800cc4:	ff 75 0c             	pushl  0xc(%ebp)
  800cc7:	ff 75 08             	pushl  0x8(%ebp)
  800cca:	e8 87 ff ff ff       	call   800c56 <memmove>
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cdc:	89 c6                	mov    %eax,%esi
  800cde:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce1:	eb 1a                	jmp    800cfd <memcmp+0x2c>
		if (*s1 != *s2)
  800ce3:	0f b6 08             	movzbl (%eax),%ecx
  800ce6:	0f b6 1a             	movzbl (%edx),%ebx
  800ce9:	38 d9                	cmp    %bl,%cl
  800ceb:	74 0a                	je     800cf7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ced:	0f b6 c1             	movzbl %cl,%eax
  800cf0:	0f b6 db             	movzbl %bl,%ebx
  800cf3:	29 d8                	sub    %ebx,%eax
  800cf5:	eb 0f                	jmp    800d06 <memcmp+0x35>
		s1++, s2++;
  800cf7:	83 c0 01             	add    $0x1,%eax
  800cfa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cfd:	39 f0                	cmp    %esi,%eax
  800cff:	75 e2                	jne    800ce3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	53                   	push   %ebx
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d11:	89 c1                	mov    %eax,%ecx
  800d13:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d16:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d1a:	eb 0a                	jmp    800d26 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1c:	0f b6 10             	movzbl (%eax),%edx
  800d1f:	39 da                	cmp    %ebx,%edx
  800d21:	74 07                	je     800d2a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d23:	83 c0 01             	add    $0x1,%eax
  800d26:	39 c8                	cmp    %ecx,%eax
  800d28:	72 f2                	jb     800d1c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d39:	eb 03                	jmp    800d3e <strtol+0x11>
		s++;
  800d3b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3e:	0f b6 01             	movzbl (%ecx),%eax
  800d41:	3c 20                	cmp    $0x20,%al
  800d43:	74 f6                	je     800d3b <strtol+0xe>
  800d45:	3c 09                	cmp    $0x9,%al
  800d47:	74 f2                	je     800d3b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d49:	3c 2b                	cmp    $0x2b,%al
  800d4b:	75 0a                	jne    800d57 <strtol+0x2a>
		s++;
  800d4d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d50:	bf 00 00 00 00       	mov    $0x0,%edi
  800d55:	eb 11                	jmp    800d68 <strtol+0x3b>
  800d57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d5c:	3c 2d                	cmp    $0x2d,%al
  800d5e:	75 08                	jne    800d68 <strtol+0x3b>
		s++, neg = 1;
  800d60:	83 c1 01             	add    $0x1,%ecx
  800d63:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d6e:	75 15                	jne    800d85 <strtol+0x58>
  800d70:	80 39 30             	cmpb   $0x30,(%ecx)
  800d73:	75 10                	jne    800d85 <strtol+0x58>
  800d75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d79:	75 7c                	jne    800df7 <strtol+0xca>
		s += 2, base = 16;
  800d7b:	83 c1 02             	add    $0x2,%ecx
  800d7e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d83:	eb 16                	jmp    800d9b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d85:	85 db                	test   %ebx,%ebx
  800d87:	75 12                	jne    800d9b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d89:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800d91:	75 08                	jne    800d9b <strtol+0x6e>
		s++, base = 8;
  800d93:	83 c1 01             	add    $0x1,%ecx
  800d96:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800da0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da3:	0f b6 11             	movzbl (%ecx),%edx
  800da6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da9:	89 f3                	mov    %esi,%ebx
  800dab:	80 fb 09             	cmp    $0x9,%bl
  800dae:	77 08                	ja     800db8 <strtol+0x8b>
			dig = *s - '0';
  800db0:	0f be d2             	movsbl %dl,%edx
  800db3:	83 ea 30             	sub    $0x30,%edx
  800db6:	eb 22                	jmp    800dda <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800db8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dbb:	89 f3                	mov    %esi,%ebx
  800dbd:	80 fb 19             	cmp    $0x19,%bl
  800dc0:	77 08                	ja     800dca <strtol+0x9d>
			dig = *s - 'a' + 10;
  800dc2:	0f be d2             	movsbl %dl,%edx
  800dc5:	83 ea 57             	sub    $0x57,%edx
  800dc8:	eb 10                	jmp    800dda <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800dca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dcd:	89 f3                	mov    %esi,%ebx
  800dcf:	80 fb 19             	cmp    $0x19,%bl
  800dd2:	77 16                	ja     800dea <strtol+0xbd>
			dig = *s - 'A' + 10;
  800dd4:	0f be d2             	movsbl %dl,%edx
  800dd7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800dda:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ddd:	7d 0b                	jge    800dea <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ddf:	83 c1 01             	add    $0x1,%ecx
  800de2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800de6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800de8:	eb b9                	jmp    800da3 <strtol+0x76>

	if (endptr)
  800dea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dee:	74 0d                	je     800dfd <strtol+0xd0>
		*endptr = (char *) s;
  800df0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df3:	89 0e                	mov    %ecx,(%esi)
  800df5:	eb 06                	jmp    800dfd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800df7:	85 db                	test   %ebx,%ebx
  800df9:	74 98                	je     800d93 <strtol+0x66>
  800dfb:	eb 9e                	jmp    800d9b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	f7 da                	neg    %edx
  800e01:	85 ff                	test   %edi,%edi
  800e03:	0f 45 c2             	cmovne %edx,%eax
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 c3                	mov    %eax,%ebx
  800e1e:	89 c7                	mov    %eax,%edi
  800e20:	89 c6                	mov    %eax,%esi
  800e22:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e34:	b8 01 00 00 00       	mov    $0x1,%eax
  800e39:	89 d1                	mov    %edx,%ecx
  800e3b:	89 d3                	mov    %edx,%ebx
  800e3d:	89 d7                	mov    %edx,%edi
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e56:	b8 03 00 00 00       	mov    $0x3,%eax
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	89 cb                	mov    %ecx,%ebx
  800e60:	89 cf                	mov    %ecx,%edi
  800e62:	89 ce                	mov    %ecx,%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 17                	jle    800e81 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	50                   	push   %eax
  800e6e:	6a 03                	push   $0x3
  800e70:	68 8f 24 80 00       	push   $0x80248f
  800e75:	6a 23                	push   $0x23
  800e77:	68 ac 24 80 00       	push   $0x8024ac
  800e7c:	e8 4b f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e94:	b8 02 00 00 00       	mov    $0x2,%eax
  800e99:	89 d1                	mov    %edx,%ecx
  800e9b:	89 d3                	mov    %edx,%ebx
  800e9d:	89 d7                	mov    %edx,%edi
  800e9f:	89 d6                	mov    %edx,%esi
  800ea1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_yield>:

void
sys_yield(void)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eb8:	89 d1                	mov    %edx,%ecx
  800eba:	89 d3                	mov    %edx,%ebx
  800ebc:	89 d7                	mov    %edx,%edi
  800ebe:	89 d6                	mov    %edx,%esi
  800ec0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	be 00 00 00 00       	mov    $0x0,%esi
  800ed5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee3:	89 f7                	mov    %esi,%edi
  800ee5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	7e 17                	jle    800f02 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	50                   	push   %eax
  800eef:	6a 04                	push   $0x4
  800ef1:	68 8f 24 80 00       	push   $0x80248f
  800ef6:	6a 23                	push   $0x23
  800ef8:	68 ac 24 80 00       	push   $0x8024ac
  800efd:	e8 ca f3 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f13:	b8 05 00 00 00       	mov    $0x5,%eax
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f21:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f24:	8b 75 18             	mov    0x18(%ebp),%esi
  800f27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	7e 17                	jle    800f44 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2d:	83 ec 0c             	sub    $0xc,%esp
  800f30:	50                   	push   %eax
  800f31:	6a 05                	push   $0x5
  800f33:	68 8f 24 80 00       	push   $0x80248f
  800f38:	6a 23                	push   $0x23
  800f3a:	68 ac 24 80 00       	push   $0x8024ac
  800f3f:	e8 88 f3 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 df                	mov    %ebx,%edi
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	7e 17                	jle    800f86 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	50                   	push   %eax
  800f73:	6a 06                	push   $0x6
  800f75:	68 8f 24 80 00       	push   $0x80248f
  800f7a:	6a 23                	push   $0x23
  800f7c:	68 ac 24 80 00       	push   $0x8024ac
  800f81:	e8 46 f3 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	89 df                	mov    %ebx,%edi
  800fa9:	89 de                	mov    %ebx,%esi
  800fab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fad:	85 c0                	test   %eax,%eax
  800faf:	7e 17                	jle    800fc8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	50                   	push   %eax
  800fb5:	6a 08                	push   $0x8
  800fb7:	68 8f 24 80 00       	push   $0x80248f
  800fbc:	6a 23                	push   $0x23
  800fbe:	68 ac 24 80 00       	push   $0x8024ac
  800fc3:	e8 04 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fde:	b8 09 00 00 00       	mov    $0x9,%eax
  800fe3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	89 df                	mov    %ebx,%edi
  800feb:	89 de                	mov    %ebx,%esi
  800fed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	7e 17                	jle    80100a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	50                   	push   %eax
  800ff7:	6a 09                	push   $0x9
  800ff9:	68 8f 24 80 00       	push   $0x80248f
  800ffe:	6a 23                	push   $0x23
  801000:	68 ac 24 80 00       	push   $0x8024ac
  801005:	e8 c2 f2 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801020:	b8 0a 00 00 00       	mov    $0xa,%eax
  801025:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801028:	8b 55 08             	mov    0x8(%ebp),%edx
  80102b:	89 df                	mov    %ebx,%edi
  80102d:	89 de                	mov    %ebx,%esi
  80102f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	7e 17                	jle    80104c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	50                   	push   %eax
  801039:	6a 0a                	push   $0xa
  80103b:	68 8f 24 80 00       	push   $0x80248f
  801040:	6a 23                	push   $0x23
  801042:	68 ac 24 80 00       	push   $0x8024ac
  801047:	e8 80 f2 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105a:	be 00 00 00 00       	mov    $0x0,%esi
  80105f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801064:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801067:	8b 55 08             	mov    0x8(%ebp),%edx
  80106a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801070:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
  80107d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801080:	b9 00 00 00 00       	mov    $0x0,%ecx
  801085:	b8 0d 00 00 00       	mov    $0xd,%eax
  80108a:	8b 55 08             	mov    0x8(%ebp),%edx
  80108d:	89 cb                	mov    %ecx,%ebx
  80108f:	89 cf                	mov    %ecx,%edi
  801091:	89 ce                	mov    %ecx,%esi
  801093:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801095:	85 c0                	test   %eax,%eax
  801097:	7e 17                	jle    8010b0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	50                   	push   %eax
  80109d:	6a 0d                	push   $0xd
  80109f:	68 8f 24 80 00       	push   $0x80248f
  8010a4:	6a 23                	push   $0x23
  8010a6:	68 ac 24 80 00       	push   $0x8024ac
  8010ab:	e8 1c f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 ea 16             	shr    $0x16,%edx
  8010ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 11                	je     80110c <fd_alloc+0x2d>
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 ea 0c             	shr    $0xc,%edx
  801100:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	75 09                	jne    801115 <fd_alloc+0x36>
			*fd_store = fd;
  80110c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
  801113:	eb 17                	jmp    80112c <fd_alloc+0x4d>
  801115:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80111a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111f:	75 c9                	jne    8010ea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801121:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801127:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801134:	83 f8 1f             	cmp    $0x1f,%eax
  801137:	77 36                	ja     80116f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801139:	c1 e0 0c             	shl    $0xc,%eax
  80113c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 ea 16             	shr    $0x16,%edx
  801146:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114d:	f6 c2 01             	test   $0x1,%dl
  801150:	74 24                	je     801176 <fd_lookup+0x48>
  801152:	89 c2                	mov    %eax,%edx
  801154:	c1 ea 0c             	shr    $0xc,%edx
  801157:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115e:	f6 c2 01             	test   $0x1,%dl
  801161:	74 1a                	je     80117d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801163:	8b 55 0c             	mov    0xc(%ebp),%edx
  801166:	89 02                	mov    %eax,(%edx)
	return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
  80116d:	eb 13                	jmp    801182 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801174:	eb 0c                	jmp    801182 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb 05                	jmp    801182 <fd_lookup+0x54>
  80117d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118d:	ba 3c 25 80 00       	mov    $0x80253c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801192:	eb 13                	jmp    8011a7 <dev_lookup+0x23>
  801194:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801197:	39 08                	cmp    %ecx,(%eax)
  801199:	75 0c                	jne    8011a7 <dev_lookup+0x23>
			*dev = devtab[i];
  80119b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a5:	eb 2e                	jmp    8011d5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a7:	8b 02                	mov    (%edx),%eax
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	75 e7                	jne    801194 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ad:	a1 04 44 80 00       	mov    0x804404,%eax
  8011b2:	8b 40 48             	mov    0x48(%eax),%eax
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	51                   	push   %ecx
  8011b9:	50                   	push   %eax
  8011ba:	68 bc 24 80 00       	push   $0x8024bc
  8011bf:	e8 e1 f1 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  8011c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 10             	sub    $0x10,%esp
  8011df:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ef:	c1 e8 0c             	shr    $0xc,%eax
  8011f2:	50                   	push   %eax
  8011f3:	e8 36 ff ff ff       	call   80112e <fd_lookup>
  8011f8:	83 c4 08             	add    $0x8,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 05                	js     801204 <fd_close+0x2d>
	    || fd != fd2)
  8011ff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801202:	74 0c                	je     801210 <fd_close+0x39>
		return (must_exist ? r : 0);
  801204:	84 db                	test   %bl,%bl
  801206:	ba 00 00 00 00       	mov    $0x0,%edx
  80120b:	0f 44 c2             	cmove  %edx,%eax
  80120e:	eb 41                	jmp    801251 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	ff 36                	pushl  (%esi)
  801219:	e8 66 ff ff ff       	call   801184 <dev_lookup>
  80121e:	89 c3                	mov    %eax,%ebx
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 1a                	js     801241 <fd_close+0x6a>
		if (dev->dev_close)
  801227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801232:	85 c0                	test   %eax,%eax
  801234:	74 0b                	je     801241 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	56                   	push   %esi
  80123a:	ff d0                	call   *%eax
  80123c:	89 c3                	mov    %eax,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	56                   	push   %esi
  801245:	6a 00                	push   $0x0
  801247:	e8 00 fd ff ff       	call   800f4c <sys_page_unmap>
	return r;
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	89 d8                	mov    %ebx,%eax
}
  801251:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	ff 75 08             	pushl  0x8(%ebp)
  801265:	e8 c4 fe ff ff       	call   80112e <fd_lookup>
  80126a:	83 c4 08             	add    $0x8,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 10                	js     801281 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	6a 01                	push   $0x1
  801276:	ff 75 f4             	pushl  -0xc(%ebp)
  801279:	e8 59 ff ff ff       	call   8011d7 <fd_close>
  80127e:	83 c4 10             	add    $0x10,%esp
}
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <close_all>:

void
close_all(void)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80128a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	53                   	push   %ebx
  801293:	e8 c0 ff ff ff       	call   801258 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801298:	83 c3 01             	add    $0x1,%ebx
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	83 fb 20             	cmp    $0x20,%ebx
  8012a1:	75 ec                	jne    80128f <close_all+0xc>
		close(i);
}
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	57                   	push   %edi
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 2c             	sub    $0x2c,%esp
  8012b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	ff 75 08             	pushl  0x8(%ebp)
  8012bb:	e8 6e fe ff ff       	call   80112e <fd_lookup>
  8012c0:	83 c4 08             	add    $0x8,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	0f 88 c1 00 00 00    	js     80138c <dup+0xe4>
		return r;
	close(newfdnum);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	56                   	push   %esi
  8012cf:	e8 84 ff ff ff       	call   801258 <close>

	newfd = INDEX2FD(newfdnum);
  8012d4:	89 f3                	mov    %esi,%ebx
  8012d6:	c1 e3 0c             	shl    $0xc,%ebx
  8012d9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012df:	83 c4 04             	add    $0x4,%esp
  8012e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012e5:	e8 de fd ff ff       	call   8010c8 <fd2data>
  8012ea:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ec:	89 1c 24             	mov    %ebx,(%esp)
  8012ef:	e8 d4 fd ff ff       	call   8010c8 <fd2data>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012fa:	89 f8                	mov    %edi,%eax
  8012fc:	c1 e8 16             	shr    $0x16,%eax
  8012ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801306:	a8 01                	test   $0x1,%al
  801308:	74 37                	je     801341 <dup+0x99>
  80130a:	89 f8                	mov    %edi,%eax
  80130c:	c1 e8 0c             	shr    $0xc,%eax
  80130f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	74 26                	je     801341 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80131b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	25 07 0e 00 00       	and    $0xe07,%eax
  80132a:	50                   	push   %eax
  80132b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80132e:	6a 00                	push   $0x0
  801330:	57                   	push   %edi
  801331:	6a 00                	push   $0x0
  801333:	e8 d2 fb ff ff       	call   800f0a <sys_page_map>
  801338:	89 c7                	mov    %eax,%edi
  80133a:	83 c4 20             	add    $0x20,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 2e                	js     80136f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801341:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801344:	89 d0                	mov    %edx,%eax
  801346:	c1 e8 0c             	shr    $0xc,%eax
  801349:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	25 07 0e 00 00       	and    $0xe07,%eax
  801358:	50                   	push   %eax
  801359:	53                   	push   %ebx
  80135a:	6a 00                	push   $0x0
  80135c:	52                   	push   %edx
  80135d:	6a 00                	push   $0x0
  80135f:	e8 a6 fb ff ff       	call   800f0a <sys_page_map>
  801364:	89 c7                	mov    %eax,%edi
  801366:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801369:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136b:	85 ff                	test   %edi,%edi
  80136d:	79 1d                	jns    80138c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	53                   	push   %ebx
  801373:	6a 00                	push   $0x0
  801375:	e8 d2 fb ff ff       	call   800f4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801380:	6a 00                	push   $0x0
  801382:	e8 c5 fb ff ff       	call   800f4c <sys_page_unmap>
	return r;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	89 f8                	mov    %edi,%eax
}
  80138c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	53                   	push   %ebx
  801398:	83 ec 14             	sub    $0x14,%esp
  80139b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	53                   	push   %ebx
  8013a3:	e8 86 fd ff ff       	call   80112e <fd_lookup>
  8013a8:	83 c4 08             	add    $0x8,%esp
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 6d                	js     80141e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b7:	50                   	push   %eax
  8013b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bb:	ff 30                	pushl  (%eax)
  8013bd:	e8 c2 fd ff ff       	call   801184 <dev_lookup>
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 4c                	js     801415 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013cc:	8b 42 08             	mov    0x8(%edx),%eax
  8013cf:	83 e0 03             	and    $0x3,%eax
  8013d2:	83 f8 01             	cmp    $0x1,%eax
  8013d5:	75 21                	jne    8013f8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d7:	a1 04 44 80 00       	mov    0x804404,%eax
  8013dc:	8b 40 48             	mov    0x48(%eax),%eax
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	50                   	push   %eax
  8013e4:	68 00 25 80 00       	push   $0x802500
  8013e9:	e8 b7 ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f6:	eb 26                	jmp    80141e <read+0x8a>
	}
	if (!dev->dev_read)
  8013f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fb:	8b 40 08             	mov    0x8(%eax),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 17                	je     801419 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	ff 75 10             	pushl  0x10(%ebp)
  801408:	ff 75 0c             	pushl  0xc(%ebp)
  80140b:	52                   	push   %edx
  80140c:	ff d0                	call   *%eax
  80140e:	89 c2                	mov    %eax,%edx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb 09                	jmp    80141e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801415:	89 c2                	mov    %eax,%edx
  801417:	eb 05                	jmp    80141e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801419:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80141e:	89 d0                	mov    %edx,%eax
  801420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	57                   	push   %edi
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801431:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801434:	bb 00 00 00 00       	mov    $0x0,%ebx
  801439:	eb 21                	jmp    80145c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	89 f0                	mov    %esi,%eax
  801440:	29 d8                	sub    %ebx,%eax
  801442:	50                   	push   %eax
  801443:	89 d8                	mov    %ebx,%eax
  801445:	03 45 0c             	add    0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	57                   	push   %edi
  80144a:	e8 45 ff ff ff       	call   801394 <read>
		if (m < 0)
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 10                	js     801466 <readn+0x41>
			return m;
		if (m == 0)
  801456:	85 c0                	test   %eax,%eax
  801458:	74 0a                	je     801464 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145a:	01 c3                	add    %eax,%ebx
  80145c:	39 f3                	cmp    %esi,%ebx
  80145e:	72 db                	jb     80143b <readn+0x16>
  801460:	89 d8                	mov    %ebx,%eax
  801462:	eb 02                	jmp    801466 <readn+0x41>
  801464:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801466:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 14             	sub    $0x14,%esp
  801475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	53                   	push   %ebx
  80147d:	e8 ac fc ff ff       	call   80112e <fd_lookup>
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	89 c2                	mov    %eax,%edx
  801487:	85 c0                	test   %eax,%eax
  801489:	78 68                	js     8014f3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	ff 30                	pushl  (%eax)
  801497:	e8 e8 fc ff ff       	call   801184 <dev_lookup>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 47                	js     8014ea <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014aa:	75 21                	jne    8014cd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ac:	a1 04 44 80 00       	mov    0x804404,%eax
  8014b1:	8b 40 48             	mov    0x48(%eax),%eax
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	50                   	push   %eax
  8014b9:	68 1c 25 80 00       	push   $0x80251c
  8014be:	e8 e2 ee ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cb:	eb 26                	jmp    8014f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d3:	85 d2                	test   %edx,%edx
  8014d5:	74 17                	je     8014ee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	ff 75 10             	pushl  0x10(%ebp)
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	50                   	push   %eax
  8014e1:	ff d2                	call   *%edx
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 09                	jmp    8014f3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	eb 05                	jmp    8014f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014f3:	89 d0                	mov    %edx,%eax
  8014f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801500:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	e8 22 fc ff ff       	call   80112e <fd_lookup>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 0e                	js     801521 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801513:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801516:	8b 55 0c             	mov    0xc(%ebp),%edx
  801519:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80151c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	e8 f7 fb ff ff       	call   80112e <fd_lookup>
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 65                	js     8015a5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	ff 30                	pushl  (%eax)
  80154c:	e8 33 fc ff ff       	call   801184 <dev_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 44                	js     80159c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155f:	75 21                	jne    801582 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801561:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	53                   	push   %ebx
  80156d:	50                   	push   %eax
  80156e:	68 dc 24 80 00       	push   $0x8024dc
  801573:	e8 2d ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801580:	eb 23                	jmp    8015a5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	8b 52 18             	mov    0x18(%edx),%edx
  801588:	85 d2                	test   %edx,%edx
  80158a:	74 14                	je     8015a0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	50                   	push   %eax
  801593:	ff d2                	call   *%edx
  801595:	89 c2                	mov    %eax,%edx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb 09                	jmp    8015a5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	eb 05                	jmp    8015a5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a5:	89 d0                	mov    %edx,%eax
  8015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	e8 6c fb ff ff       	call   80112e <fd_lookup>
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 58                	js     801623 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	ff 30                	pushl  (%eax)
  8015d7:	e8 a8 fb ff ff       	call   801184 <dev_lookup>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 37                	js     80161a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ea:	74 32                	je     80161e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f6:	00 00 00 
	stat->st_isdir = 0;
  8015f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801600:	00 00 00 
	stat->st_dev = dev;
  801603:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	53                   	push   %ebx
  80160d:	ff 75 f0             	pushl  -0x10(%ebp)
  801610:	ff 50 14             	call   *0x14(%eax)
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	6a 00                	push   $0x0
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 b7 01 00 00       	call   8017f3 <open>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 1b                	js     801660 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	e8 5b ff ff ff       	call   8015ac <fstat>
  801651:	89 c6                	mov    %eax,%esi
	close(fd);
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 fd fb ff ff       	call   801258 <close>
	return r;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	89 f0                	mov    %esi,%eax
}
  801660:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	89 c6                	mov    %eax,%esi
  80166e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801670:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801677:	75 12                	jne    80168b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	6a 01                	push   $0x1
  80167e:	e8 49 07 00 00       	call   801dcc <ipc_find_env>
  801683:	a3 00 44 80 00       	mov    %eax,0x804400
  801688:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80168b:	6a 07                	push   $0x7
  80168d:	68 00 50 80 00       	push   $0x805000
  801692:	56                   	push   %esi
  801693:	ff 35 00 44 80 00    	pushl  0x804400
  801699:	e8 da 06 00 00       	call   801d78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169e:	83 c4 0c             	add    $0xc,%esp
  8016a1:	6a 00                	push   $0x0
  8016a3:	53                   	push   %ebx
  8016a4:	6a 00                	push   $0x0
  8016a6:	e8 58 06 00 00       	call   801d03 <ipc_recv>
}
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d5:	e8 8d ff ff ff       	call   801667 <fsipc>
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f7:	e8 6b ff ff ff       	call   801667 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	8b 40 0c             	mov    0xc(%eax),%eax
  80170e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801713:	ba 00 00 00 00       	mov    $0x0,%edx
  801718:	b8 05 00 00 00       	mov    $0x5,%eax
  80171d:	e8 45 ff ff ff       	call   801667 <fsipc>
  801722:	85 c0                	test   %eax,%eax
  801724:	78 2c                	js     801752 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	68 00 50 80 00       	push   $0x805000
  80172e:	53                   	push   %ebx
  80172f:	e8 90 f3 ff ff       	call   800ac4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801734:	a1 80 50 80 00       	mov    0x805080,%eax
  801739:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173f:	a1 84 50 80 00       	mov    0x805084,%eax
  801744:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80175d:	68 4c 25 80 00       	push   $0x80254c
  801762:	68 90 00 00 00       	push   $0x90
  801767:	68 6a 25 80 00       	push   $0x80256a
  80176c:	e8 5b eb ff ff       	call   8002cc <_panic>

00801771 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	56                   	push   %esi
  801775:	53                   	push   %ebx
  801776:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801779:	8b 45 08             	mov    0x8(%ebp),%eax
  80177c:	8b 40 0c             	mov    0xc(%eax),%eax
  80177f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801784:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 03 00 00 00       	mov    $0x3,%eax
  801794:	e8 ce fe ff ff       	call   801667 <fsipc>
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 4b                	js     8017ea <devfile_read+0x79>
		return r;
	assert(r <= n);
  80179f:	39 c6                	cmp    %eax,%esi
  8017a1:	73 16                	jae    8017b9 <devfile_read+0x48>
  8017a3:	68 75 25 80 00       	push   $0x802575
  8017a8:	68 7c 25 80 00       	push   $0x80257c
  8017ad:	6a 7c                	push   $0x7c
  8017af:	68 6a 25 80 00       	push   $0x80256a
  8017b4:	e8 13 eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  8017b9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017be:	7e 16                	jle    8017d6 <devfile_read+0x65>
  8017c0:	68 91 25 80 00       	push   $0x802591
  8017c5:	68 7c 25 80 00       	push   $0x80257c
  8017ca:	6a 7d                	push   $0x7d
  8017cc:	68 6a 25 80 00       	push   $0x80256a
  8017d1:	e8 f6 ea ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	50                   	push   %eax
  8017da:	68 00 50 80 00       	push   $0x805000
  8017df:	ff 75 0c             	pushl  0xc(%ebp)
  8017e2:	e8 6f f4 ff ff       	call   800c56 <memmove>
	return r;
  8017e7:	83 c4 10             	add    $0x10,%esp
}
  8017ea:	89 d8                	mov    %ebx,%eax
  8017ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 20             	sub    $0x20,%esp
  8017fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017fd:	53                   	push   %ebx
  8017fe:	e8 88 f2 ff ff       	call   800a8b <strlen>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80180b:	7f 67                	jg     801874 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801813:	50                   	push   %eax
  801814:	e8 c6 f8 ff ff       	call   8010df <fd_alloc>
  801819:	83 c4 10             	add    $0x10,%esp
		return r;
  80181c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 57                	js     801879 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801822:	83 ec 08             	sub    $0x8,%esp
  801825:	53                   	push   %ebx
  801826:	68 00 50 80 00       	push   $0x805000
  80182b:	e8 94 f2 ff ff       	call   800ac4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801830:	8b 45 0c             	mov    0xc(%ebp),%eax
  801833:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801838:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183b:	b8 01 00 00 00       	mov    $0x1,%eax
  801840:	e8 22 fe ff ff       	call   801667 <fsipc>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	79 14                	jns    801862 <open+0x6f>
		fd_close(fd, 0);
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	6a 00                	push   $0x0
  801853:	ff 75 f4             	pushl  -0xc(%ebp)
  801856:	e8 7c f9 ff ff       	call   8011d7 <fd_close>
		return r;
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	89 da                	mov    %ebx,%edx
  801860:	eb 17                	jmp    801879 <open+0x86>
	}

	return fd2num(fd);
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	ff 75 f4             	pushl  -0xc(%ebp)
  801868:	e8 4b f8 ff ff       	call   8010b8 <fd2num>
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	eb 05                	jmp    801879 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801874:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801879:	89 d0                	mov    %edx,%eax
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801886:	ba 00 00 00 00       	mov    $0x0,%edx
  80188b:	b8 08 00 00 00       	mov    $0x8,%eax
  801890:	e8 d2 fd ff ff       	call   801667 <fsipc>
}
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801897:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80189b:	7e 37                	jle    8018d4 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	53                   	push   %ebx
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018a6:	ff 70 04             	pushl  0x4(%eax)
  8018a9:	8d 40 10             	lea    0x10(%eax),%eax
  8018ac:	50                   	push   %eax
  8018ad:	ff 33                	pushl  (%ebx)
  8018af:	e8 ba fb ff ff       	call   80146e <write>
		if (result > 0)
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	7e 03                	jle    8018be <writebuf+0x27>
			b->result += result;
  8018bb:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018be:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018c1:	74 0d                	je     8018d0 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	0f 4f c2             	cmovg  %edx,%eax
  8018cd:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d3:	c9                   	leave  
  8018d4:	f3 c3                	repz ret 

008018d6 <putch>:

static void
putch(int ch, void *thunk)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018e0:	8b 53 04             	mov    0x4(%ebx),%edx
  8018e3:	8d 42 01             	lea    0x1(%edx),%eax
  8018e6:	89 43 04             	mov    %eax,0x4(%ebx)
  8018e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ec:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018f0:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018f5:	75 0e                	jne    801905 <putch+0x2f>
		writebuf(b);
  8018f7:	89 d8                	mov    %ebx,%eax
  8018f9:	e8 99 ff ff ff       	call   801897 <writebuf>
		b->idx = 0;
  8018fe:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801905:	83 c4 04             	add    $0x4,%esp
  801908:	5b                   	pop    %ebx
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801914:	8b 45 08             	mov    0x8(%ebp),%eax
  801917:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80191d:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801924:	00 00 00 
	b.result = 0;
  801927:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80192e:	00 00 00 
	b.error = 1;
  801931:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801938:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80193b:	ff 75 10             	pushl  0x10(%ebp)
  80193e:	ff 75 0c             	pushl  0xc(%ebp)
  801941:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	68 d6 18 80 00       	push   $0x8018d6
  80194d:	e8 50 eb ff ff       	call   8004a2 <vprintfmt>
	if (b.idx > 0)
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80195c:	7e 0b                	jle    801969 <vfprintf+0x5e>
		writebuf(&b);
  80195e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801964:	e8 2e ff ff ff       	call   801897 <writebuf>

	return (b.result ? b.result : b.error);
  801969:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80196f:	85 c0                	test   %eax,%eax
  801971:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801980:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801983:	50                   	push   %eax
  801984:	ff 75 0c             	pushl  0xc(%ebp)
  801987:	ff 75 08             	pushl  0x8(%ebp)
  80198a:	e8 7c ff ff ff       	call   80190b <vfprintf>
	va_end(ap);

	return cnt;
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <printf>:

int
printf(const char *fmt, ...)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801997:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80199a:	50                   	push   %eax
  80199b:	ff 75 08             	pushl  0x8(%ebp)
  80199e:	6a 01                	push   $0x1
  8019a0:	e8 66 ff ff ff       	call   80190b <vfprintf>
	va_end(ap);

	return cnt;
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
  8019ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	ff 75 08             	pushl  0x8(%ebp)
  8019b5:	e8 0e f7 ff ff       	call   8010c8 <fd2data>
  8019ba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019bc:	83 c4 08             	add    $0x8,%esp
  8019bf:	68 9d 25 80 00       	push   $0x80259d
  8019c4:	53                   	push   %ebx
  8019c5:	e8 fa f0 ff ff       	call   800ac4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ca:	8b 46 04             	mov    0x4(%esi),%eax
  8019cd:	2b 06                	sub    (%esi),%eax
  8019cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019dc:	00 00 00 
	stat->st_dev = &devpipe;
  8019df:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019e6:	30 80 00 
	return 0;
}
  8019e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	53                   	push   %ebx
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019ff:	53                   	push   %ebx
  801a00:	6a 00                	push   $0x0
  801a02:	e8 45 f5 ff ff       	call   800f4c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a07:	89 1c 24             	mov    %ebx,(%esp)
  801a0a:	e8 b9 f6 ff ff       	call   8010c8 <fd2data>
  801a0f:	83 c4 08             	add    $0x8,%esp
  801a12:	50                   	push   %eax
  801a13:	6a 00                	push   $0x0
  801a15:	e8 32 f5 ff ff       	call   800f4c <sys_page_unmap>
}
  801a1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	57                   	push   %edi
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	83 ec 1c             	sub    $0x1c,%esp
  801a28:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a2b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2d:	a1 04 44 80 00       	mov    0x804404,%eax
  801a32:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	ff 75 e0             	pushl  -0x20(%ebp)
  801a3b:	e8 c5 03 00 00       	call   801e05 <pageref>
  801a40:	89 c3                	mov    %eax,%ebx
  801a42:	89 3c 24             	mov    %edi,(%esp)
  801a45:	e8 bb 03 00 00       	call   801e05 <pageref>
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	39 c3                	cmp    %eax,%ebx
  801a4f:	0f 94 c1             	sete   %cl
  801a52:	0f b6 c9             	movzbl %cl,%ecx
  801a55:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a58:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a5e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a61:	39 ce                	cmp    %ecx,%esi
  801a63:	74 1b                	je     801a80 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a65:	39 c3                	cmp    %eax,%ebx
  801a67:	75 c4                	jne    801a2d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a69:	8b 42 58             	mov    0x58(%edx),%eax
  801a6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6f:	50                   	push   %eax
  801a70:	56                   	push   %esi
  801a71:	68 a4 25 80 00       	push   $0x8025a4
  801a76:	e8 2a e9 ff ff       	call   8003a5 <cprintf>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	eb ad                	jmp    801a2d <_pipeisclosed+0xe>
	}
}
  801a80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5f                   	pop    %edi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	57                   	push   %edi
  801a8f:	56                   	push   %esi
  801a90:	53                   	push   %ebx
  801a91:	83 ec 28             	sub    $0x28,%esp
  801a94:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a97:	56                   	push   %esi
  801a98:	e8 2b f6 ff ff       	call   8010c8 <fd2data>
  801a9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  801aa7:	eb 4b                	jmp    801af4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa9:	89 da                	mov    %ebx,%edx
  801aab:	89 f0                	mov    %esi,%eax
  801aad:	e8 6d ff ff ff       	call   801a1f <_pipeisclosed>
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	75 48                	jne    801afe <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab6:	e8 ed f3 ff ff       	call   800ea8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801abb:	8b 43 04             	mov    0x4(%ebx),%eax
  801abe:	8b 0b                	mov    (%ebx),%ecx
  801ac0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ac3:	39 d0                	cmp    %edx,%eax
  801ac5:	73 e2                	jae    801aa9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ace:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ad1:	89 c2                	mov    %eax,%edx
  801ad3:	c1 fa 1f             	sar    $0x1f,%edx
  801ad6:	89 d1                	mov    %edx,%ecx
  801ad8:	c1 e9 1b             	shr    $0x1b,%ecx
  801adb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ade:	83 e2 1f             	and    $0x1f,%edx
  801ae1:	29 ca                	sub    %ecx,%edx
  801ae3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aeb:	83 c0 01             	add    $0x1,%eax
  801aee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af1:	83 c7 01             	add    $0x1,%edi
  801af4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801af7:	75 c2                	jne    801abb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801af9:	8b 45 10             	mov    0x10(%ebp),%eax
  801afc:	eb 05                	jmp    801b03 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5f                   	pop    %edi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	57                   	push   %edi
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	83 ec 18             	sub    $0x18,%esp
  801b14:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b17:	57                   	push   %edi
  801b18:	e8 ab f5 ff ff       	call   8010c8 <fd2data>
  801b1d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b27:	eb 3d                	jmp    801b66 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b29:	85 db                	test   %ebx,%ebx
  801b2b:	74 04                	je     801b31 <devpipe_read+0x26>
				return i;
  801b2d:	89 d8                	mov    %ebx,%eax
  801b2f:	eb 44                	jmp    801b75 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b31:	89 f2                	mov    %esi,%edx
  801b33:	89 f8                	mov    %edi,%eax
  801b35:	e8 e5 fe ff ff       	call   801a1f <_pipeisclosed>
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	75 32                	jne    801b70 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b3e:	e8 65 f3 ff ff       	call   800ea8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b43:	8b 06                	mov    (%esi),%eax
  801b45:	3b 46 04             	cmp    0x4(%esi),%eax
  801b48:	74 df                	je     801b29 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b4a:	99                   	cltd   
  801b4b:	c1 ea 1b             	shr    $0x1b,%edx
  801b4e:	01 d0                	add    %edx,%eax
  801b50:	83 e0 1f             	and    $0x1f,%eax
  801b53:	29 d0                	sub    %edx,%eax
  801b55:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b5d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b60:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b63:	83 c3 01             	add    $0x1,%ebx
  801b66:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b69:	75 d8                	jne    801b43 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6e:	eb 05                	jmp    801b75 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b78:	5b                   	pop    %ebx
  801b79:	5e                   	pop    %esi
  801b7a:	5f                   	pop    %edi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b88:	50                   	push   %eax
  801b89:	e8 51 f5 ff ff       	call   8010df <fd_alloc>
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	89 c2                	mov    %eax,%edx
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 2c 01 00 00    	js     801cc7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9b:	83 ec 04             	sub    $0x4,%esp
  801b9e:	68 07 04 00 00       	push   $0x407
  801ba3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 1a f3 ff ff       	call   800ec7 <sys_page_alloc>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	89 c2                	mov    %eax,%edx
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 0d 01 00 00    	js     801cc7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc0:	50                   	push   %eax
  801bc1:	e8 19 f5 ff ff       	call   8010df <fd_alloc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	0f 88 e2 00 00 00    	js     801cb5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd3:	83 ec 04             	sub    $0x4,%esp
  801bd6:	68 07 04 00 00       	push   $0x407
  801bdb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bde:	6a 00                	push   $0x0
  801be0:	e8 e2 f2 ff ff       	call   800ec7 <sys_page_alloc>
  801be5:	89 c3                	mov    %eax,%ebx
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	85 c0                	test   %eax,%eax
  801bec:	0f 88 c3 00 00 00    	js     801cb5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf8:	e8 cb f4 ff ff       	call   8010c8 <fd2data>
  801bfd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bff:	83 c4 0c             	add    $0xc,%esp
  801c02:	68 07 04 00 00       	push   $0x407
  801c07:	50                   	push   %eax
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 b8 f2 ff ff       	call   800ec7 <sys_page_alloc>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	85 c0                	test   %eax,%eax
  801c16:	0f 88 89 00 00 00    	js     801ca5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c22:	e8 a1 f4 ff ff       	call   8010c8 <fd2data>
  801c27:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c2e:	50                   	push   %eax
  801c2f:	6a 00                	push   $0x0
  801c31:	56                   	push   %esi
  801c32:	6a 00                	push   $0x0
  801c34:	e8 d1 f2 ff ff       	call   800f0a <sys_page_map>
  801c39:	89 c3                	mov    %eax,%ebx
  801c3b:	83 c4 20             	add    $0x20,%esp
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 55                	js     801c97 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c42:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c50:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c57:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c60:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c65:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c72:	e8 41 f4 ff ff       	call   8010b8 <fd2num>
  801c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c7c:	83 c4 04             	add    $0x4,%esp
  801c7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c82:	e8 31 f4 ff ff       	call   8010b8 <fd2num>
  801c87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	ba 00 00 00 00       	mov    $0x0,%edx
  801c95:	eb 30                	jmp    801cc7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c97:	83 ec 08             	sub    $0x8,%esp
  801c9a:	56                   	push   %esi
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 aa f2 ff ff       	call   800f4c <sys_page_unmap>
  801ca2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca5:	83 ec 08             	sub    $0x8,%esp
  801ca8:	ff 75 f0             	pushl  -0x10(%ebp)
  801cab:	6a 00                	push   $0x0
  801cad:	e8 9a f2 ff ff       	call   800f4c <sys_page_unmap>
  801cb2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbb:	6a 00                	push   $0x0
  801cbd:	e8 8a f2 ff ff       	call   800f4c <sys_page_unmap>
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cc7:	89 d0                	mov    %edx,%eax
  801cc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccc:	5b                   	pop    %ebx
  801ccd:	5e                   	pop    %esi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd9:	50                   	push   %eax
  801cda:	ff 75 08             	pushl  0x8(%ebp)
  801cdd:	e8 4c f4 ff ff       	call   80112e <fd_lookup>
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 18                	js     801d01 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	ff 75 f4             	pushl  -0xc(%ebp)
  801cef:	e8 d4 f3 ff ff       	call   8010c8 <fd2data>
	return _pipeisclosed(fd, p);
  801cf4:	89 c2                	mov    %eax,%edx
  801cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf9:	e8 21 fd ff ff       	call   801a1f <_pipeisclosed>
  801cfe:	83 c4 10             	add    $0x10,%esp
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	56                   	push   %esi
  801d07:	53                   	push   %ebx
  801d08:	8b 75 08             	mov    0x8(%ebp),%esi
  801d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801d11:	85 c0                	test   %eax,%eax
  801d13:	74 0e                	je     801d23 <ipc_recv+0x20>
  801d15:	83 ec 0c             	sub    $0xc,%esp
  801d18:	50                   	push   %eax
  801d19:	e8 59 f3 ff ff       	call   801077 <sys_ipc_recv>
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	eb 10                	jmp    801d33 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	68 00 00 c0 ee       	push   $0xeec00000
  801d2b:	e8 47 f3 ff ff       	call   801077 <sys_ipc_recv>
  801d30:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801d33:	85 c0                	test   %eax,%eax
  801d35:	74 16                	je     801d4d <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801d37:	85 f6                	test   %esi,%esi
  801d39:	74 06                	je     801d41 <ipc_recv+0x3e>
  801d3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801d41:	85 db                	test   %ebx,%ebx
  801d43:	74 2c                	je     801d71 <ipc_recv+0x6e>
  801d45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d4b:	eb 24                	jmp    801d71 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801d4d:	85 f6                	test   %esi,%esi
  801d4f:	74 0a                	je     801d5b <ipc_recv+0x58>
  801d51:	a1 04 44 80 00       	mov    0x804404,%eax
  801d56:	8b 40 74             	mov    0x74(%eax),%eax
  801d59:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801d5b:	85 db                	test   %ebx,%ebx
  801d5d:	74 0a                	je     801d69 <ipc_recv+0x66>
  801d5f:	a1 04 44 80 00       	mov    0x804404,%eax
  801d64:	8b 40 78             	mov    0x78(%eax),%eax
  801d67:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d69:	a1 04 44 80 00       	mov    0x804404,%eax
  801d6e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	57                   	push   %edi
  801d7c:	56                   	push   %esi
  801d7d:	53                   	push   %ebx
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d87:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801d91:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801d94:	ff 75 14             	pushl  0x14(%ebp)
  801d97:	53                   	push   %ebx
  801d98:	56                   	push   %esi
  801d99:	57                   	push   %edi
  801d9a:	e8 b5 f2 ff ff       	call   801054 <sys_ipc_try_send>
		if (ret == 0) break;
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	74 1e                	je     801dc4 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801da6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801da9:	74 12                	je     801dbd <ipc_send+0x45>
  801dab:	50                   	push   %eax
  801dac:	68 bc 25 80 00       	push   $0x8025bc
  801db1:	6a 39                	push   $0x39
  801db3:	68 c9 25 80 00       	push   $0x8025c9
  801db8:	e8 0f e5 ff ff       	call   8002cc <_panic>
		sys_yield();
  801dbd:	e8 e6 f0 ff ff       	call   800ea8 <sys_yield>
	}
  801dc2:	eb d0                	jmp    801d94 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    

00801dcc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dd7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801dda:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801de0:	8b 52 50             	mov    0x50(%edx),%edx
  801de3:	39 ca                	cmp    %ecx,%edx
  801de5:	75 0d                	jne    801df4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801de7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801def:	8b 40 48             	mov    0x48(%eax),%eax
  801df2:	eb 0f                	jmp    801e03 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801df4:	83 c0 01             	add    $0x1,%eax
  801df7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dfc:	75 d9                	jne    801dd7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e03:	5d                   	pop    %ebp
  801e04:	c3                   	ret    

00801e05 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	c1 e8 16             	shr    $0x16,%eax
  801e10:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e1c:	f6 c1 01             	test   $0x1,%cl
  801e1f:	74 1d                	je     801e3e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e21:	c1 ea 0c             	shr    $0xc,%edx
  801e24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e2b:	f6 c2 01             	test   $0x1,%dl
  801e2e:	74 0e                	je     801e3e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e30:	c1 ea 0c             	shr    $0xc,%edx
  801e33:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e3a:	ef 
  801e3b:	0f b7 c0             	movzwl %ax,%eax
}
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    

00801e40 <__udivdi3>:
  801e40:	55                   	push   %ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	83 ec 1c             	sub    $0x1c,%esp
  801e47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e57:	85 f6                	test   %esi,%esi
  801e59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e5d:	89 ca                	mov    %ecx,%edx
  801e5f:	89 f8                	mov    %edi,%eax
  801e61:	75 3d                	jne    801ea0 <__udivdi3+0x60>
  801e63:	39 cf                	cmp    %ecx,%edi
  801e65:	0f 87 c5 00 00 00    	ja     801f30 <__udivdi3+0xf0>
  801e6b:	85 ff                	test   %edi,%edi
  801e6d:	89 fd                	mov    %edi,%ebp
  801e6f:	75 0b                	jne    801e7c <__udivdi3+0x3c>
  801e71:	b8 01 00 00 00       	mov    $0x1,%eax
  801e76:	31 d2                	xor    %edx,%edx
  801e78:	f7 f7                	div    %edi
  801e7a:	89 c5                	mov    %eax,%ebp
  801e7c:	89 c8                	mov    %ecx,%eax
  801e7e:	31 d2                	xor    %edx,%edx
  801e80:	f7 f5                	div    %ebp
  801e82:	89 c1                	mov    %eax,%ecx
  801e84:	89 d8                	mov    %ebx,%eax
  801e86:	89 cf                	mov    %ecx,%edi
  801e88:	f7 f5                	div    %ebp
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	89 d8                	mov    %ebx,%eax
  801e8e:	89 fa                	mov    %edi,%edx
  801e90:	83 c4 1c             	add    $0x1c,%esp
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    
  801e98:	90                   	nop
  801e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	39 ce                	cmp    %ecx,%esi
  801ea2:	77 74                	ja     801f18 <__udivdi3+0xd8>
  801ea4:	0f bd fe             	bsr    %esi,%edi
  801ea7:	83 f7 1f             	xor    $0x1f,%edi
  801eaa:	0f 84 98 00 00 00    	je     801f48 <__udivdi3+0x108>
  801eb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801eb5:	89 f9                	mov    %edi,%ecx
  801eb7:	89 c5                	mov    %eax,%ebp
  801eb9:	29 fb                	sub    %edi,%ebx
  801ebb:	d3 e6                	shl    %cl,%esi
  801ebd:	89 d9                	mov    %ebx,%ecx
  801ebf:	d3 ed                	shr    %cl,%ebp
  801ec1:	89 f9                	mov    %edi,%ecx
  801ec3:	d3 e0                	shl    %cl,%eax
  801ec5:	09 ee                	or     %ebp,%esi
  801ec7:	89 d9                	mov    %ebx,%ecx
  801ec9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecd:	89 d5                	mov    %edx,%ebp
  801ecf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ed3:	d3 ed                	shr    %cl,%ebp
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	d3 e2                	shl    %cl,%edx
  801ed9:	89 d9                	mov    %ebx,%ecx
  801edb:	d3 e8                	shr    %cl,%eax
  801edd:	09 c2                	or     %eax,%edx
  801edf:	89 d0                	mov    %edx,%eax
  801ee1:	89 ea                	mov    %ebp,%edx
  801ee3:	f7 f6                	div    %esi
  801ee5:	89 d5                	mov    %edx,%ebp
  801ee7:	89 c3                	mov    %eax,%ebx
  801ee9:	f7 64 24 0c          	mull   0xc(%esp)
  801eed:	39 d5                	cmp    %edx,%ebp
  801eef:	72 10                	jb     801f01 <__udivdi3+0xc1>
  801ef1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	d3 e6                	shl    %cl,%esi
  801ef9:	39 c6                	cmp    %eax,%esi
  801efb:	73 07                	jae    801f04 <__udivdi3+0xc4>
  801efd:	39 d5                	cmp    %edx,%ebp
  801eff:	75 03                	jne    801f04 <__udivdi3+0xc4>
  801f01:	83 eb 01             	sub    $0x1,%ebx
  801f04:	31 ff                	xor    %edi,%edi
  801f06:	89 d8                	mov    %ebx,%eax
  801f08:	89 fa                	mov    %edi,%edx
  801f0a:	83 c4 1c             	add    $0x1c,%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5f                   	pop    %edi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    
  801f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f18:	31 ff                	xor    %edi,%edi
  801f1a:	31 db                	xor    %ebx,%ebx
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
  801f30:	89 d8                	mov    %ebx,%eax
  801f32:	f7 f7                	div    %edi
  801f34:	31 ff                	xor    %edi,%edi
  801f36:	89 c3                	mov    %eax,%ebx
  801f38:	89 d8                	mov    %ebx,%eax
  801f3a:	89 fa                	mov    %edi,%edx
  801f3c:	83 c4 1c             	add    $0x1c,%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    
  801f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f48:	39 ce                	cmp    %ecx,%esi
  801f4a:	72 0c                	jb     801f58 <__udivdi3+0x118>
  801f4c:	31 db                	xor    %ebx,%ebx
  801f4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f52:	0f 87 34 ff ff ff    	ja     801e8c <__udivdi3+0x4c>
  801f58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f5d:	e9 2a ff ff ff       	jmp    801e8c <__udivdi3+0x4c>
  801f62:	66 90                	xchg   %ax,%ax
  801f64:	66 90                	xchg   %ax,%ax
  801f66:	66 90                	xchg   %ax,%ax
  801f68:	66 90                	xchg   %ax,%ax
  801f6a:	66 90                	xchg   %ax,%ax
  801f6c:	66 90                	xchg   %ax,%ax
  801f6e:	66 90                	xchg   %ax,%ax

00801f70 <__umoddi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 d2                	test   %edx,%edx
  801f89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f91:	89 f3                	mov    %esi,%ebx
  801f93:	89 3c 24             	mov    %edi,(%esp)
  801f96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f9a:	75 1c                	jne    801fb8 <__umoddi3+0x48>
  801f9c:	39 f7                	cmp    %esi,%edi
  801f9e:	76 50                	jbe    801ff0 <__umoddi3+0x80>
  801fa0:	89 c8                	mov    %ecx,%eax
  801fa2:	89 f2                	mov    %esi,%edx
  801fa4:	f7 f7                	div    %edi
  801fa6:	89 d0                	mov    %edx,%eax
  801fa8:	31 d2                	xor    %edx,%edx
  801faa:	83 c4 1c             	add    $0x1c,%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fb8:	39 f2                	cmp    %esi,%edx
  801fba:	89 d0                	mov    %edx,%eax
  801fbc:	77 52                	ja     802010 <__umoddi3+0xa0>
  801fbe:	0f bd ea             	bsr    %edx,%ebp
  801fc1:	83 f5 1f             	xor    $0x1f,%ebp
  801fc4:	75 5a                	jne    802020 <__umoddi3+0xb0>
  801fc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fca:	0f 82 e0 00 00 00    	jb     8020b0 <__umoddi3+0x140>
  801fd0:	39 0c 24             	cmp    %ecx,(%esp)
  801fd3:	0f 86 d7 00 00 00    	jbe    8020b0 <__umoddi3+0x140>
  801fd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fe1:	83 c4 1c             	add    $0x1c,%esp
  801fe4:	5b                   	pop    %ebx
  801fe5:	5e                   	pop    %esi
  801fe6:	5f                   	pop    %edi
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	85 ff                	test   %edi,%edi
  801ff2:	89 fd                	mov    %edi,%ebp
  801ff4:	75 0b                	jne    802001 <__umoddi3+0x91>
  801ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffb:	31 d2                	xor    %edx,%edx
  801ffd:	f7 f7                	div    %edi
  801fff:	89 c5                	mov    %eax,%ebp
  802001:	89 f0                	mov    %esi,%eax
  802003:	31 d2                	xor    %edx,%edx
  802005:	f7 f5                	div    %ebp
  802007:	89 c8                	mov    %ecx,%eax
  802009:	f7 f5                	div    %ebp
  80200b:	89 d0                	mov    %edx,%eax
  80200d:	eb 99                	jmp    801fa8 <__umoddi3+0x38>
  80200f:	90                   	nop
  802010:	89 c8                	mov    %ecx,%eax
  802012:	89 f2                	mov    %esi,%edx
  802014:	83 c4 1c             	add    $0x1c,%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5f                   	pop    %edi
  80201a:	5d                   	pop    %ebp
  80201b:	c3                   	ret    
  80201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802020:	8b 34 24             	mov    (%esp),%esi
  802023:	bf 20 00 00 00       	mov    $0x20,%edi
  802028:	89 e9                	mov    %ebp,%ecx
  80202a:	29 ef                	sub    %ebp,%edi
  80202c:	d3 e0                	shl    %cl,%eax
  80202e:	89 f9                	mov    %edi,%ecx
  802030:	89 f2                	mov    %esi,%edx
  802032:	d3 ea                	shr    %cl,%edx
  802034:	89 e9                	mov    %ebp,%ecx
  802036:	09 c2                	or     %eax,%edx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 14 24             	mov    %edx,(%esp)
  80203d:	89 f2                	mov    %esi,%edx
  80203f:	d3 e2                	shl    %cl,%edx
  802041:	89 f9                	mov    %edi,%ecx
  802043:	89 54 24 04          	mov    %edx,0x4(%esp)
  802047:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	89 e9                	mov    %ebp,%ecx
  80204f:	89 c6                	mov    %eax,%esi
  802051:	d3 e3                	shl    %cl,%ebx
  802053:	89 f9                	mov    %edi,%ecx
  802055:	89 d0                	mov    %edx,%eax
  802057:	d3 e8                	shr    %cl,%eax
  802059:	89 e9                	mov    %ebp,%ecx
  80205b:	09 d8                	or     %ebx,%eax
  80205d:	89 d3                	mov    %edx,%ebx
  80205f:	89 f2                	mov    %esi,%edx
  802061:	f7 34 24             	divl   (%esp)
  802064:	89 d6                	mov    %edx,%esi
  802066:	d3 e3                	shl    %cl,%ebx
  802068:	f7 64 24 04          	mull   0x4(%esp)
  80206c:	39 d6                	cmp    %edx,%esi
  80206e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802072:	89 d1                	mov    %edx,%ecx
  802074:	89 c3                	mov    %eax,%ebx
  802076:	72 08                	jb     802080 <__umoddi3+0x110>
  802078:	75 11                	jne    80208b <__umoddi3+0x11b>
  80207a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80207e:	73 0b                	jae    80208b <__umoddi3+0x11b>
  802080:	2b 44 24 04          	sub    0x4(%esp),%eax
  802084:	1b 14 24             	sbb    (%esp),%edx
  802087:	89 d1                	mov    %edx,%ecx
  802089:	89 c3                	mov    %eax,%ebx
  80208b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80208f:	29 da                	sub    %ebx,%edx
  802091:	19 ce                	sbb    %ecx,%esi
  802093:	89 f9                	mov    %edi,%ecx
  802095:	89 f0                	mov    %esi,%eax
  802097:	d3 e0                	shl    %cl,%eax
  802099:	89 e9                	mov    %ebp,%ecx
  80209b:	d3 ea                	shr    %cl,%edx
  80209d:	89 e9                	mov    %ebp,%ecx
  80209f:	d3 ee                	shr    %cl,%esi
  8020a1:	09 d0                	or     %edx,%eax
  8020a3:	89 f2                	mov    %esi,%edx
  8020a5:	83 c4 1c             	add    $0x1c,%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5f                   	pop    %edi
  8020ab:	5d                   	pop    %ebp
  8020ac:	c3                   	ret    
  8020ad:	8d 76 00             	lea    0x0(%esi),%esi
  8020b0:	29 f9                	sub    %edi,%ecx
  8020b2:	19 d6                	sbb    %edx,%esi
  8020b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020bc:	e9 18 ff ff ff       	jmp    801fd9 <__umoddi3+0x69>
