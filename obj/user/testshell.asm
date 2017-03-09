
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 da 18 00 00       	call   801929 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 d0 18 00 00       	call   801929 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 6b 2a 80 00 	movl   $0x802a6b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 ad 0e 00 00       	call   800f30 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 31 17 00 00       	call   8017c3 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 7a 2a 80 00       	push   $0x802a7a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 78 0e 00 00       	call   800f30 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 fc 16 00 00       	call   8017c3 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 75 2a 80 00       	push   $0x802a75
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 8c 15 00 00       	call   801687 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 80 15 00 00       	call   801687 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 88 2a 80 00       	push   $0x802a88
  80011b:	e8 02 1b 00 00       	call   801c22 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 95 2a 80 00       	push   $0x802a95
  80012f:	6a 13                	push   $0x13
  800131:	68 ab 2a 80 00       	push   $0x802aab
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 95 22 00 00       	call   8023dc <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 bc 2a 80 00       	push   $0x802abc
  800154:	6a 15                	push   $0x15
  800156:	68 ab 2a 80 00       	push   $0x802aab
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 24 2a 80 00       	push   $0x802a24
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 15 12 00 00       	call   80138a <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 c5 2a 80 00       	push   $0x802ac5
  800182:	6a 1a                	push   $0x1a
  800184:	68 ab 2a 80 00       	push   $0x802aab
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 3a 15 00 00       	call   8016d7 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 2f 15 00 00       	call   8016d7 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 d7 14 00 00       	call   801687 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 cf 14 00 00       	call   801687 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 ce 2a 80 00       	push   $0x802ace
  8001bf:	68 92 2a 80 00       	push   $0x802a92
  8001c4:	68 d1 2a 80 00       	push   $0x802ad1
  8001c9:	e8 c5 1f 00 00       	call   802193 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 d5 2a 80 00       	push   $0x802ad5
  8001dd:	6a 21                	push   $0x21
  8001df:	68 ab 2a 80 00       	push   $0x802aab
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 94 14 00 00       	call   801687 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 88 14 00 00       	call   801687 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 5b 23 00 00       	call   802562 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 6f 14 00 00       	call   801687 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 67 14 00 00       	call   801687 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 df 2a 80 00       	push   $0x802adf
  800230:	e8 ed 19 00 00       	call   801c22 <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 48 2a 80 00       	push   $0x802a48
  800245:	6a 2c                	push   $0x2c
  800247:	68 ab 2a 80 00       	push   $0x802aab
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 57 15 00 00       	call   8017c3 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 44 15 00 00       	call   8017c3 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 ed 2a 80 00       	push   $0x802aed
  80028c:	6a 33                	push   $0x33
  80028e:	68 ab 2a 80 00       	push   $0x802aab
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 07 2b 80 00       	push   $0x802b07
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 ab 2a 80 00       	push   $0x802aab
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 21 2b 80 00       	push   $0x802b21
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 36 2b 80 00       	push   $0x802b36
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 cb 08 00 00       	call   800be9 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 1f 0a 00 00       	call   800d7b <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 ca 0b 00 00       	call   800f30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 3b 0c 00 00       	call   800fcd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 b7 0b 00 00       	call   800f4e <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 62 0b 00 00       	call   800f30 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 dd 13 00 00       	call   8017c3 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 4d 11 00 00       	call   80155d <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 d5 10 00 00       	call   80150e <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 98 0b 00 00       	call   800fec <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 6c 10 00 00       	call   8014e7 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  80048f:	e8 1a 0b 00 00       	call   800fae <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 dd 11 00 00       	call   8016b2 <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 8e 0a 00 00       	call   800f6d <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 b7 0a 00 00       	call   800fae <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 4c 2b 80 00       	push   $0x802b4c
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 d6 09 00 00       	call   800f30 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 1a 01 00 00       	call   8006ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 7b 09 00 00       	call   800f30 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 3b 21 00 00       	call   802760 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 28 22 00 00       	call   802890 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 6f 2b 80 00 	movsbl 0x802b6f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800686:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	3b 50 04             	cmp    0x4(%eax),%edx
  80068f:	73 0a                	jae    80069b <sprintputch+0x1b>
		*b->buf++ = ch;
  800691:	8d 4a 01             	lea    0x1(%edx),%ecx
  800694:	89 08                	mov    %ecx,(%eax)
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	88 02                	mov    %al,(%edx)
}
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a6:	50                   	push   %eax
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	ff 75 08             	pushl  0x8(%ebp)
  8006b0:	e8 05 00 00 00       	call   8006ba <vprintfmt>
	va_end(ap);
}
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
  8006c0:	83 ec 2c             	sub    $0x2c,%esp
  8006c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006cc:	eb 12                	jmp    8006e0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ce:	85 c0                	test   %eax,%eax
  8006d0:	0f 84 6a 04 00 00    	je     800b40 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	50                   	push   %eax
  8006db:	ff d6                	call   *%esi
  8006dd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e0:	83 c7 01             	add    $0x1,%edi
  8006e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e7:	83 f8 25             	cmp    $0x25,%eax
  8006ea:	75 e2                	jne    8006ce <vprintfmt+0x14>
  8006ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	eb 07                	jmp    800713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80070f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800713:	8d 47 01             	lea    0x1(%edi),%eax
  800716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800719:	0f b6 07             	movzbl (%edi),%eax
  80071c:	0f b6 d0             	movzbl %al,%edx
  80071f:	83 e8 23             	sub    $0x23,%eax
  800722:	3c 55                	cmp    $0x55,%al
  800724:	0f 87 fb 03 00 00    	ja     800b25 <vprintfmt+0x46b>
  80072a:	0f b6 c0             	movzbl %al,%eax
  80072d:	ff 24 85 c0 2c 80 00 	jmp    *0x802cc0(,%eax,4)
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800737:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80073b:	eb d6                	jmp    800713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800748:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80074b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80074f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800752:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800755:	83 f9 09             	cmp    $0x9,%ecx
  800758:	77 3f                	ja     800799 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075d:	eb e9                	jmp    800748 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 00                	mov    (%eax),%eax
  800764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 40 04             	lea    0x4(%eax),%eax
  80076d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800773:	eb 2a                	jmp    80079f <vprintfmt+0xe5>
  800775:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800778:	85 c0                	test   %eax,%eax
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
  80077f:	0f 49 d0             	cmovns %eax,%edx
  800782:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800788:	eb 89                	jmp    800713 <vprintfmt+0x59>
  80078a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80078d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800794:	e9 7a ff ff ff       	jmp    800713 <vprintfmt+0x59>
  800799:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80079c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80079f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a3:	0f 89 6a ff ff ff    	jns    800713 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007b6:	e9 58 ff ff ff       	jmp    800713 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007bb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007c1:	e9 4d ff ff ff       	jmp    800713 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 78 04             	lea    0x4(%eax),%edi
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	ff 30                	pushl  (%eax)
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007dd:	e9 fe fe ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 78 04             	lea    0x4(%eax),%edi
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	99                   	cltd   
  8007eb:	31 d0                	xor    %edx,%eax
  8007ed:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007ef:	83 f8 0f             	cmp    $0xf,%eax
  8007f2:	7f 0b                	jg     8007ff <vprintfmt+0x145>
  8007f4:	8b 14 85 20 2e 80 00 	mov    0x802e20(,%eax,4),%edx
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	75 1b                	jne    80081a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8007ff:	50                   	push   %eax
  800800:	68 87 2b 80 00       	push   $0x802b87
  800805:	53                   	push   %ebx
  800806:	56                   	push   %esi
  800807:	e8 91 fe ff ff       	call   80069d <printfmt>
  80080c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800815:	e9 c6 fe ff ff       	jmp    8006e0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80081a:	52                   	push   %edx
  80081b:	68 5a 30 80 00       	push   $0x80305a
  800820:	53                   	push   %ebx
  800821:	56                   	push   %esi
  800822:	e8 76 fe ff ff       	call   80069d <printfmt>
  800827:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80082a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800830:	e9 ab fe ff ff       	jmp    8006e0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	83 c0 04             	add    $0x4,%eax
  80083b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800843:	85 ff                	test   %edi,%edi
  800845:	b8 80 2b 80 00       	mov    $0x802b80,%eax
  80084a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80084d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800851:	0f 8e 94 00 00 00    	jle    8008eb <vprintfmt+0x231>
  800857:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80085b:	0f 84 98 00 00 00    	je     8008f9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	ff 75 d0             	pushl  -0x30(%ebp)
  800867:	57                   	push   %edi
  800868:	e8 5b 03 00 00       	call   800bc8 <strnlen>
  80086d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800870:	29 c1                	sub    %eax,%ecx
  800872:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800875:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800878:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80087c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80087f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800882:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800884:	eb 0f                	jmp    800895 <vprintfmt+0x1db>
					putch(padc, putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	ff 75 e0             	pushl  -0x20(%ebp)
  80088d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ef 01             	sub    $0x1,%edi
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 ff                	test   %edi,%edi
  800897:	7f ed                	jg     800886 <vprintfmt+0x1cc>
  800899:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80089c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80089f:	85 c9                	test   %ecx,%ecx
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	0f 49 c1             	cmovns %ecx,%eax
  8008a9:	29 c1                	sub    %eax,%ecx
  8008ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008b4:	89 cb                	mov    %ecx,%ebx
  8008b6:	eb 4d                	jmp    800905 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008bc:	74 1b                	je     8008d9 <vprintfmt+0x21f>
  8008be:	0f be c0             	movsbl %al,%eax
  8008c1:	83 e8 20             	sub    $0x20,%eax
  8008c4:	83 f8 5e             	cmp    $0x5e,%eax
  8008c7:	76 10                	jbe    8008d9 <vprintfmt+0x21f>
					putch('?', putdat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	6a 3f                	push   $0x3f
  8008d1:	ff 55 08             	call   *0x8(%ebp)
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	eb 0d                	jmp    8008e6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	ff 75 0c             	pushl  0xc(%ebp)
  8008df:	52                   	push   %edx
  8008e0:	ff 55 08             	call   *0x8(%ebp)
  8008e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008e6:	83 eb 01             	sub    $0x1,%ebx
  8008e9:	eb 1a                	jmp    800905 <vprintfmt+0x24b>
  8008eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008f7:	eb 0c                	jmp    800905 <vprintfmt+0x24b>
  8008f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800905:	83 c7 01             	add    $0x1,%edi
  800908:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80090c:	0f be d0             	movsbl %al,%edx
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 23                	je     800936 <vprintfmt+0x27c>
  800913:	85 f6                	test   %esi,%esi
  800915:	78 a1                	js     8008b8 <vprintfmt+0x1fe>
  800917:	83 ee 01             	sub    $0x1,%esi
  80091a:	79 9c                	jns    8008b8 <vprintfmt+0x1fe>
  80091c:	89 df                	mov    %ebx,%edi
  80091e:	8b 75 08             	mov    0x8(%ebp),%esi
  800921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800924:	eb 18                	jmp    80093e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	53                   	push   %ebx
  80092a:	6a 20                	push   $0x20
  80092c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092e:	83 ef 01             	sub    $0x1,%edi
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb 08                	jmp    80093e <vprintfmt+0x284>
  800936:	89 df                	mov    %ebx,%edi
  800938:	8b 75 08             	mov    0x8(%ebp),%esi
  80093b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80093e:	85 ff                	test   %edi,%edi
  800940:	7f e4                	jg     800926 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800942:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800945:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094b:	e9 90 fd ff ff       	jmp    8006e0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800950:	83 f9 01             	cmp    $0x1,%ecx
  800953:	7e 19                	jle    80096e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8b 50 04             	mov    0x4(%eax),%edx
  80095b:	8b 00                	mov    (%eax),%eax
  80095d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800960:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8d 40 08             	lea    0x8(%eax),%eax
  800969:	89 45 14             	mov    %eax,0x14(%ebp)
  80096c:	eb 38                	jmp    8009a6 <vprintfmt+0x2ec>
	else if (lflag)
  80096e:	85 c9                	test   %ecx,%ecx
  800970:	74 1b                	je     80098d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8b 00                	mov    (%eax),%eax
  800977:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	c1 f9 1f             	sar    $0x1f,%ecx
  80097f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 40 04             	lea    0x4(%eax),%eax
  800988:	89 45 14             	mov    %eax,0x14(%ebp)
  80098b:	eb 19                	jmp    8009a6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	8b 00                	mov    (%eax),%eax
  800992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800995:	89 c1                	mov    %eax,%ecx
  800997:	c1 f9 1f             	sar    $0x1f,%ecx
  80099a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8d 40 04             	lea    0x4(%eax),%eax
  8009a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b5:	0f 89 36 01 00 00    	jns    800af1 <vprintfmt+0x437>
				putch('-', putdat);
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	53                   	push   %ebx
  8009bf:	6a 2d                	push   $0x2d
  8009c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8009c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009c9:	f7 da                	neg    %edx
  8009cb:	83 d1 00             	adc    $0x0,%ecx
  8009ce:	f7 d9                	neg    %ecx
  8009d0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d8:	e9 14 01 00 00       	jmp    800af1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009dd:	83 f9 01             	cmp    $0x1,%ecx
  8009e0:	7e 18                	jle    8009fa <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8b 10                	mov    (%eax),%edx
  8009e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ea:	8d 40 08             	lea    0x8(%eax),%eax
  8009ed:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8009f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f5:	e9 f7 00 00 00       	jmp    800af1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8009fa:	85 c9                	test   %ecx,%ecx
  8009fc:	74 1a                	je     800a18 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8009fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800a01:	8b 10                	mov    (%eax),%edx
  800a03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a08:	8d 40 04             	lea    0x4(%eax),%eax
  800a0b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a13:	e9 d9 00 00 00       	jmp    800af1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800a18:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1b:	8b 10                	mov    (%eax),%edx
  800a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a22:	8d 40 04             	lea    0x4(%eax),%eax
  800a25:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a2d:	e9 bf 00 00 00       	jmp    800af1 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a32:	83 f9 01             	cmp    $0x1,%ecx
  800a35:	7e 13                	jle    800a4a <vprintfmt+0x390>
		return va_arg(*ap, long long);
  800a37:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3a:	8b 50 04             	mov    0x4(%eax),%edx
  800a3d:	8b 00                	mov    (%eax),%eax
  800a3f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800a42:	8d 49 08             	lea    0x8(%ecx),%ecx
  800a45:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a48:	eb 28                	jmp    800a72 <vprintfmt+0x3b8>
	else if (lflag)
  800a4a:	85 c9                	test   %ecx,%ecx
  800a4c:	74 13                	je     800a61 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  800a4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a51:	8b 10                	mov    (%eax),%edx
  800a53:	89 d0                	mov    %edx,%eax
  800a55:	99                   	cltd   
  800a56:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800a59:	8d 49 04             	lea    0x4(%ecx),%ecx
  800a5c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a5f:	eb 11                	jmp    800a72 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  800a61:	8b 45 14             	mov    0x14(%ebp),%eax
  800a64:	8b 10                	mov    (%eax),%edx
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	99                   	cltd   
  800a69:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800a6c:	8d 49 04             	lea    0x4(%ecx),%ecx
  800a6f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  800a72:	89 d1                	mov    %edx,%ecx
  800a74:	89 c2                	mov    %eax,%edx
			base = 8;
  800a76:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a7b:	eb 74                	jmp    800af1 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	53                   	push   %ebx
  800a81:	6a 30                	push   $0x30
  800a83:	ff d6                	call   *%esi
			putch('x', putdat);
  800a85:	83 c4 08             	add    $0x8,%esp
  800a88:	53                   	push   %ebx
  800a89:	6a 78                	push   $0x78
  800a8b:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a90:	8b 10                	mov    (%eax),%edx
  800a92:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a97:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a9a:	8d 40 04             	lea    0x4(%eax),%eax
  800a9d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800aa0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800aa5:	eb 4a                	jmp    800af1 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aa7:	83 f9 01             	cmp    $0x1,%ecx
  800aaa:	7e 15                	jle    800ac1 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  800aac:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaf:	8b 10                	mov    (%eax),%edx
  800ab1:	8b 48 04             	mov    0x4(%eax),%ecx
  800ab4:	8d 40 08             	lea    0x8(%eax),%eax
  800ab7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800aba:	b8 10 00 00 00       	mov    $0x10,%eax
  800abf:	eb 30                	jmp    800af1 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800ac1:	85 c9                	test   %ecx,%ecx
  800ac3:	74 17                	je     800adc <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8b 10                	mov    (%eax),%edx
  800aca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acf:	8d 40 04             	lea    0x4(%eax),%eax
  800ad2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ad5:	b8 10 00 00 00       	mov    $0x10,%eax
  800ada:	eb 15                	jmp    800af1 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800adc:	8b 45 14             	mov    0x14(%ebp),%eax
  800adf:	8b 10                	mov    (%eax),%edx
  800ae1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae6:	8d 40 04             	lea    0x4(%eax),%eax
  800ae9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800aec:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800af8:	57                   	push   %edi
  800af9:	ff 75 e0             	pushl  -0x20(%ebp)
  800afc:	50                   	push   %eax
  800afd:	51                   	push   %ecx
  800afe:	52                   	push   %edx
  800aff:	89 da                	mov    %ebx,%edx
  800b01:	89 f0                	mov    %esi,%eax
  800b03:	e8 c9 fa ff ff       	call   8005d1 <printnum>
			break;
  800b08:	83 c4 20             	add    $0x20,%esp
  800b0b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b0e:	e9 cd fb ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	52                   	push   %edx
  800b18:	ff d6                	call   *%esi
			break;
  800b1a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b20:	e9 bb fb ff ff       	jmp    8006e0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	53                   	push   %ebx
  800b29:	6a 25                	push   $0x25
  800b2b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	eb 03                	jmp    800b35 <vprintfmt+0x47b>
  800b32:	83 ef 01             	sub    $0x1,%edi
  800b35:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b39:	75 f7                	jne    800b32 <vprintfmt+0x478>
  800b3b:	e9 a0 fb ff ff       	jmp    8006e0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 18             	sub    $0x18,%esp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b54:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b57:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b5b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	74 26                	je     800b8f <vsnprintf+0x47>
  800b69:	85 d2                	test   %edx,%edx
  800b6b:	7e 22                	jle    800b8f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b6d:	ff 75 14             	pushl  0x14(%ebp)
  800b70:	ff 75 10             	pushl  0x10(%ebp)
  800b73:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b76:	50                   	push   %eax
  800b77:	68 80 06 80 00       	push   $0x800680
  800b7c:	e8 39 fb ff ff       	call   8006ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b84:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	eb 05                	jmp    800b94 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b9c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b9f:	50                   	push   %eax
  800ba0:	ff 75 10             	pushl  0x10(%ebp)
  800ba3:	ff 75 0c             	pushl  0xc(%ebp)
  800ba6:	ff 75 08             	pushl  0x8(%ebp)
  800ba9:	e8 9a ff ff ff       	call   800b48 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	eb 03                	jmp    800bc0 <strlen+0x10>
		n++;
  800bbd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc4:	75 f7                	jne    800bbd <strlen+0xd>
		n++;
	return n;
}
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	eb 03                	jmp    800bdb <strnlen+0x13>
		n++;
  800bd8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bdb:	39 c2                	cmp    %eax,%edx
  800bdd:	74 08                	je     800be7 <strnlen+0x1f>
  800bdf:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800be3:	75 f3                	jne    800bd8 <strnlen+0x10>
  800be5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	53                   	push   %ebx
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bf3:	89 c2                	mov    %eax,%edx
  800bf5:	83 c2 01             	add    $0x1,%edx
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bff:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c02:	84 db                	test   %bl,%bl
  800c04:	75 ef                	jne    800bf5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c06:	5b                   	pop    %ebx
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	53                   	push   %ebx
  800c0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c10:	53                   	push   %ebx
  800c11:	e8 9a ff ff ff       	call   800bb0 <strlen>
  800c16:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c19:	ff 75 0c             	pushl  0xc(%ebp)
  800c1c:	01 d8                	add    %ebx,%eax
  800c1e:	50                   	push   %eax
  800c1f:	e8 c5 ff ff ff       	call   800be9 <strcpy>
	return dst;
}
  800c24:	89 d8                	mov    %ebx,%eax
  800c26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 75 08             	mov    0x8(%ebp),%esi
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	89 f3                	mov    %esi,%ebx
  800c38:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c3b:	89 f2                	mov    %esi,%edx
  800c3d:	eb 0f                	jmp    800c4e <strncpy+0x23>
		*dst++ = *src;
  800c3f:	83 c2 01             	add    $0x1,%edx
  800c42:	0f b6 01             	movzbl (%ecx),%eax
  800c45:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c48:	80 39 01             	cmpb   $0x1,(%ecx)
  800c4b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c4e:	39 da                	cmp    %ebx,%edx
  800c50:	75 ed                	jne    800c3f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c52:	89 f0                	mov    %esi,%eax
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	8b 75 08             	mov    0x8(%ebp),%esi
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 10             	mov    0x10(%ebp),%edx
  800c66:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c68:	85 d2                	test   %edx,%edx
  800c6a:	74 21                	je     800c8d <strlcpy+0x35>
  800c6c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c70:	89 f2                	mov    %esi,%edx
  800c72:	eb 09                	jmp    800c7d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c74:	83 c2 01             	add    $0x1,%edx
  800c77:	83 c1 01             	add    $0x1,%ecx
  800c7a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c7d:	39 c2                	cmp    %eax,%edx
  800c7f:	74 09                	je     800c8a <strlcpy+0x32>
  800c81:	0f b6 19             	movzbl (%ecx),%ebx
  800c84:	84 db                	test   %bl,%bl
  800c86:	75 ec                	jne    800c74 <strlcpy+0x1c>
  800c88:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c8a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c8d:	29 f0                	sub    %esi,%eax
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c99:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c9c:	eb 06                	jmp    800ca4 <strcmp+0x11>
		p++, q++;
  800c9e:	83 c1 01             	add    $0x1,%ecx
  800ca1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ca4:	0f b6 01             	movzbl (%ecx),%eax
  800ca7:	84 c0                	test   %al,%al
  800ca9:	74 04                	je     800caf <strcmp+0x1c>
  800cab:	3a 02                	cmp    (%edx),%al
  800cad:	74 ef                	je     800c9e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800caf:	0f b6 c0             	movzbl %al,%eax
  800cb2:	0f b6 12             	movzbl (%edx),%edx
  800cb5:	29 d0                	sub    %edx,%eax
}
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	53                   	push   %ebx
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc3:	89 c3                	mov    %eax,%ebx
  800cc5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800cc8:	eb 06                	jmp    800cd0 <strncmp+0x17>
		n--, p++, q++;
  800cca:	83 c0 01             	add    $0x1,%eax
  800ccd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cd0:	39 d8                	cmp    %ebx,%eax
  800cd2:	74 15                	je     800ce9 <strncmp+0x30>
  800cd4:	0f b6 08             	movzbl (%eax),%ecx
  800cd7:	84 c9                	test   %cl,%cl
  800cd9:	74 04                	je     800cdf <strncmp+0x26>
  800cdb:	3a 0a                	cmp    (%edx),%cl
  800cdd:	74 eb                	je     800cca <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cdf:	0f b6 00             	movzbl (%eax),%eax
  800ce2:	0f b6 12             	movzbl (%edx),%edx
  800ce5:	29 d0                	sub    %edx,%eax
  800ce7:	eb 05                	jmp    800cee <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cfb:	eb 07                	jmp    800d04 <strchr+0x13>
		if (*s == c)
  800cfd:	38 ca                	cmp    %cl,%dl
  800cff:	74 0f                	je     800d10 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d01:	83 c0 01             	add    $0x1,%eax
  800d04:	0f b6 10             	movzbl (%eax),%edx
  800d07:	84 d2                	test   %dl,%dl
  800d09:	75 f2                	jne    800cfd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d1c:	eb 03                	jmp    800d21 <strfind+0xf>
  800d1e:	83 c0 01             	add    $0x1,%eax
  800d21:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d24:	38 ca                	cmp    %cl,%dl
  800d26:	74 04                	je     800d2c <strfind+0x1a>
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	75 f2                	jne    800d1e <strfind+0xc>
			break;
	return (char *) s;
}
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d3a:	85 c9                	test   %ecx,%ecx
  800d3c:	74 36                	je     800d74 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d44:	75 28                	jne    800d6e <memset+0x40>
  800d46:	f6 c1 03             	test   $0x3,%cl
  800d49:	75 23                	jne    800d6e <memset+0x40>
		c &= 0xFF;
  800d4b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d4f:	89 d3                	mov    %edx,%ebx
  800d51:	c1 e3 08             	shl    $0x8,%ebx
  800d54:	89 d6                	mov    %edx,%esi
  800d56:	c1 e6 18             	shl    $0x18,%esi
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	c1 e0 10             	shl    $0x10,%eax
  800d5e:	09 f0                	or     %esi,%eax
  800d60:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d62:	89 d8                	mov    %ebx,%eax
  800d64:	09 d0                	or     %edx,%eax
  800d66:	c1 e9 02             	shr    $0x2,%ecx
  800d69:	fc                   	cld    
  800d6a:	f3 ab                	rep stos %eax,%es:(%edi)
  800d6c:	eb 06                	jmp    800d74 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	fc                   	cld    
  800d72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d74:	89 f8                	mov    %edi,%eax
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d89:	39 c6                	cmp    %eax,%esi
  800d8b:	73 35                	jae    800dc2 <memmove+0x47>
  800d8d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d90:	39 d0                	cmp    %edx,%eax
  800d92:	73 2e                	jae    800dc2 <memmove+0x47>
		s += n;
		d += n;
  800d94:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d97:	89 d6                	mov    %edx,%esi
  800d99:	09 fe                	or     %edi,%esi
  800d9b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800da1:	75 13                	jne    800db6 <memmove+0x3b>
  800da3:	f6 c1 03             	test   $0x3,%cl
  800da6:	75 0e                	jne    800db6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800da8:	83 ef 04             	sub    $0x4,%edi
  800dab:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dae:	c1 e9 02             	shr    $0x2,%ecx
  800db1:	fd                   	std    
  800db2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db4:	eb 09                	jmp    800dbf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800db6:	83 ef 01             	sub    $0x1,%edi
  800db9:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dbc:	fd                   	std    
  800dbd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dbf:	fc                   	cld    
  800dc0:	eb 1d                	jmp    800ddf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc2:	89 f2                	mov    %esi,%edx
  800dc4:	09 c2                	or     %eax,%edx
  800dc6:	f6 c2 03             	test   $0x3,%dl
  800dc9:	75 0f                	jne    800dda <memmove+0x5f>
  800dcb:	f6 c1 03             	test   $0x3,%cl
  800dce:	75 0a                	jne    800dda <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800dd0:	c1 e9 02             	shr    $0x2,%ecx
  800dd3:	89 c7                	mov    %eax,%edi
  800dd5:	fc                   	cld    
  800dd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dd8:	eb 05                	jmp    800ddf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dda:	89 c7                	mov    %eax,%edi
  800ddc:	fc                   	cld    
  800ddd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800de6:	ff 75 10             	pushl  0x10(%ebp)
  800de9:	ff 75 0c             	pushl  0xc(%ebp)
  800dec:	ff 75 08             	pushl  0x8(%ebp)
  800def:	e8 87 ff ff ff       	call   800d7b <memmove>
}
  800df4:	c9                   	leave  
  800df5:	c3                   	ret    

00800df6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e01:	89 c6                	mov    %eax,%esi
  800e03:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e06:	eb 1a                	jmp    800e22 <memcmp+0x2c>
		if (*s1 != *s2)
  800e08:	0f b6 08             	movzbl (%eax),%ecx
  800e0b:	0f b6 1a             	movzbl (%edx),%ebx
  800e0e:	38 d9                	cmp    %bl,%cl
  800e10:	74 0a                	je     800e1c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e12:	0f b6 c1             	movzbl %cl,%eax
  800e15:	0f b6 db             	movzbl %bl,%ebx
  800e18:	29 d8                	sub    %ebx,%eax
  800e1a:	eb 0f                	jmp    800e2b <memcmp+0x35>
		s1++, s2++;
  800e1c:	83 c0 01             	add    $0x1,%eax
  800e1f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e22:	39 f0                	cmp    %esi,%eax
  800e24:	75 e2                	jne    800e08 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	53                   	push   %ebx
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e36:	89 c1                	mov    %eax,%ecx
  800e38:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e3b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e3f:	eb 0a                	jmp    800e4b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e41:	0f b6 10             	movzbl (%eax),%edx
  800e44:	39 da                	cmp    %ebx,%edx
  800e46:	74 07                	je     800e4f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e48:	83 c0 01             	add    $0x1,%eax
  800e4b:	39 c8                	cmp    %ecx,%eax
  800e4d:	72 f2                	jb     800e41 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e4f:	5b                   	pop    %ebx
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e5e:	eb 03                	jmp    800e63 <strtol+0x11>
		s++;
  800e60:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e63:	0f b6 01             	movzbl (%ecx),%eax
  800e66:	3c 20                	cmp    $0x20,%al
  800e68:	74 f6                	je     800e60 <strtol+0xe>
  800e6a:	3c 09                	cmp    $0x9,%al
  800e6c:	74 f2                	je     800e60 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e6e:	3c 2b                	cmp    $0x2b,%al
  800e70:	75 0a                	jne    800e7c <strtol+0x2a>
		s++;
  800e72:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e75:	bf 00 00 00 00       	mov    $0x0,%edi
  800e7a:	eb 11                	jmp    800e8d <strtol+0x3b>
  800e7c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e81:	3c 2d                	cmp    $0x2d,%al
  800e83:	75 08                	jne    800e8d <strtol+0x3b>
		s++, neg = 1;
  800e85:	83 c1 01             	add    $0x1,%ecx
  800e88:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e8d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e93:	75 15                	jne    800eaa <strtol+0x58>
  800e95:	80 39 30             	cmpb   $0x30,(%ecx)
  800e98:	75 10                	jne    800eaa <strtol+0x58>
  800e9a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e9e:	75 7c                	jne    800f1c <strtol+0xca>
		s += 2, base = 16;
  800ea0:	83 c1 02             	add    $0x2,%ecx
  800ea3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ea8:	eb 16                	jmp    800ec0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800eaa:	85 db                	test   %ebx,%ebx
  800eac:	75 12                	jne    800ec0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800eae:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eb3:	80 39 30             	cmpb   $0x30,(%ecx)
  800eb6:	75 08                	jne    800ec0 <strtol+0x6e>
		s++, base = 8;
  800eb8:	83 c1 01             	add    $0x1,%ecx
  800ebb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ec8:	0f b6 11             	movzbl (%ecx),%edx
  800ecb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ece:	89 f3                	mov    %esi,%ebx
  800ed0:	80 fb 09             	cmp    $0x9,%bl
  800ed3:	77 08                	ja     800edd <strtol+0x8b>
			dig = *s - '0';
  800ed5:	0f be d2             	movsbl %dl,%edx
  800ed8:	83 ea 30             	sub    $0x30,%edx
  800edb:	eb 22                	jmp    800eff <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800edd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ee0:	89 f3                	mov    %esi,%ebx
  800ee2:	80 fb 19             	cmp    $0x19,%bl
  800ee5:	77 08                	ja     800eef <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ee7:	0f be d2             	movsbl %dl,%edx
  800eea:	83 ea 57             	sub    $0x57,%edx
  800eed:	eb 10                	jmp    800eff <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800eef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ef2:	89 f3                	mov    %esi,%ebx
  800ef4:	80 fb 19             	cmp    $0x19,%bl
  800ef7:	77 16                	ja     800f0f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ef9:	0f be d2             	movsbl %dl,%edx
  800efc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800eff:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f02:	7d 0b                	jge    800f0f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f04:	83 c1 01             	add    $0x1,%ecx
  800f07:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f0b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f0d:	eb b9                	jmp    800ec8 <strtol+0x76>

	if (endptr)
  800f0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f13:	74 0d                	je     800f22 <strtol+0xd0>
		*endptr = (char *) s;
  800f15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f18:	89 0e                	mov    %ecx,(%esi)
  800f1a:	eb 06                	jmp    800f22 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1c:	85 db                	test   %ebx,%ebx
  800f1e:	74 98                	je     800eb8 <strtol+0x66>
  800f20:	eb 9e                	jmp    800ec0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f22:	89 c2                	mov    %eax,%edx
  800f24:	f7 da                	neg    %edx
  800f26:	85 ff                	test   %edi,%edi
  800f28:	0f 45 c2             	cmovne %edx,%eax
}
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	89 c7                	mov    %eax,%edi
  800f45:	89 c6                	mov    %eax,%esi
  800f47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	ba 00 00 00 00       	mov    $0x0,%edx
  800f59:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5e:	89 d1                	mov    %edx,%ecx
  800f60:	89 d3                	mov    %edx,%ebx
  800f62:	89 d7                	mov    %edx,%edi
  800f64:	89 d6                	mov    %edx,%esi
  800f66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 cb                	mov    %ecx,%ebx
  800f85:	89 cf                	mov    %ecx,%edi
  800f87:	89 ce                	mov    %ecx,%esi
  800f89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	7e 17                	jle    800fa6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	50                   	push   %eax
  800f93:	6a 03                	push   $0x3
  800f95:	68 7f 2e 80 00       	push   $0x802e7f
  800f9a:	6a 23                	push   $0x23
  800f9c:	68 9c 2e 80 00       	push   $0x802e9c
  800fa1:	e8 3e f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	b8 02 00 00 00       	mov    $0x2,%eax
  800fbe:	89 d1                	mov    %edx,%ecx
  800fc0:	89 d3                	mov    %edx,%ebx
  800fc2:	89 d7                	mov    %edx,%edi
  800fc4:	89 d6                	mov    %edx,%esi
  800fc6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_yield>:

void
sys_yield(void)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fdd:	89 d1                	mov    %edx,%ecx
  800fdf:	89 d3                	mov    %edx,%ebx
  800fe1:	89 d7                	mov    %edx,%edi
  800fe3:	89 d6                	mov    %edx,%esi
  800fe5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff5:	be 00 00 00 00       	mov    $0x0,%esi
  800ffa:	b8 04 00 00 00       	mov    $0x4,%eax
  800fff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
  801005:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801008:	89 f7                	mov    %esi,%edi
  80100a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	7e 17                	jle    801027 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	50                   	push   %eax
  801014:	6a 04                	push   $0x4
  801016:	68 7f 2e 80 00       	push   $0x802e7f
  80101b:	6a 23                	push   $0x23
  80101d:	68 9c 2e 80 00       	push   $0x802e9c
  801022:	e8 bd f4 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801038:	b8 05 00 00 00       	mov    $0x5,%eax
  80103d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801040:	8b 55 08             	mov    0x8(%ebp),%edx
  801043:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801046:	8b 7d 14             	mov    0x14(%ebp),%edi
  801049:	8b 75 18             	mov    0x18(%ebp),%esi
  80104c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	7e 17                	jle    801069 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	50                   	push   %eax
  801056:	6a 05                	push   $0x5
  801058:	68 7f 2e 80 00       	push   $0x802e7f
  80105d:	6a 23                	push   $0x23
  80105f:	68 9c 2e 80 00       	push   $0x802e9c
  801064:	e8 7b f4 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801069:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107f:	b8 06 00 00 00       	mov    $0x6,%eax
  801084:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801087:	8b 55 08             	mov    0x8(%ebp),%edx
  80108a:	89 df                	mov    %ebx,%edi
  80108c:	89 de                	mov    %ebx,%esi
  80108e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801090:	85 c0                	test   %eax,%eax
  801092:	7e 17                	jle    8010ab <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	50                   	push   %eax
  801098:	6a 06                	push   $0x6
  80109a:	68 7f 2e 80 00       	push   $0x802e7f
  80109f:	6a 23                	push   $0x23
  8010a1:	68 9c 2e 80 00       	push   $0x802e9c
  8010a6:	e8 39 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cc:	89 df                	mov    %ebx,%edi
  8010ce:	89 de                	mov    %ebx,%esi
  8010d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	7e 17                	jle    8010ed <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	50                   	push   %eax
  8010da:	6a 08                	push   $0x8
  8010dc:	68 7f 2e 80 00       	push   $0x802e7f
  8010e1:	6a 23                	push   $0x23
  8010e3:	68 9c 2e 80 00       	push   $0x802e9c
  8010e8:	e8 f7 f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801103:	b8 09 00 00 00       	mov    $0x9,%eax
  801108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	89 df                	mov    %ebx,%edi
  801110:	89 de                	mov    %ebx,%esi
  801112:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801114:	85 c0                	test   %eax,%eax
  801116:	7e 17                	jle    80112f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	50                   	push   %eax
  80111c:	6a 09                	push   $0x9
  80111e:	68 7f 2e 80 00       	push   $0x802e7f
  801123:	6a 23                	push   $0x23
  801125:	68 9c 2e 80 00       	push   $0x802e9c
  80112a:	e8 b5 f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801140:	bb 00 00 00 00       	mov    $0x0,%ebx
  801145:	b8 0a 00 00 00       	mov    $0xa,%eax
  80114a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114d:	8b 55 08             	mov    0x8(%ebp),%edx
  801150:	89 df                	mov    %ebx,%edi
  801152:	89 de                	mov    %ebx,%esi
  801154:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	7e 17                	jle    801171 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	50                   	push   %eax
  80115e:	6a 0a                	push   $0xa
  801160:	68 7f 2e 80 00       	push   $0x802e7f
  801165:	6a 23                	push   $0x23
  801167:	68 9c 2e 80 00       	push   $0x802e9c
  80116c:	e8 73 f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801171:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5f                   	pop    %edi
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	57                   	push   %edi
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117f:	be 00 00 00 00       	mov    $0x0,%esi
  801184:	b8 0c 00 00 00       	mov    $0xc,%eax
  801189:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118c:	8b 55 08             	mov    0x8(%ebp),%edx
  80118f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801192:	8b 7d 14             	mov    0x14(%ebp),%edi
  801195:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011aa:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011af:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b2:	89 cb                	mov    %ecx,%ebx
  8011b4:	89 cf                	mov    %ecx,%edi
  8011b6:	89 ce                	mov    %ecx,%esi
  8011b8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	7e 17                	jle    8011d5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011be:	83 ec 0c             	sub    $0xc,%esp
  8011c1:	50                   	push   %eax
  8011c2:	6a 0d                	push   $0xd
  8011c4:	68 7f 2e 80 00       	push   $0x802e7f
  8011c9:	6a 23                	push   $0x23
  8011cb:	68 9c 2e 80 00       	push   $0x802e9c
  8011d0:	e8 0f f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011e7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  8011e9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011ed:	0f 84 48 01 00 00    	je     80133b <pgfault+0x15e>
  8011f3:	89 d8                	mov    %ebx,%eax
  8011f5:	c1 e8 16             	shr    $0x16,%eax
  8011f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011ff:	a8 01                	test   $0x1,%al
  801201:	0f 84 5f 01 00 00    	je     801366 <pgfault+0x189>
  801207:	89 d8                	mov    %ebx,%eax
  801209:	c1 e8 0c             	shr    $0xc,%eax
  80120c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801213:	f6 c2 01             	test   $0x1,%dl
  801216:	0f 84 4a 01 00 00    	je     801366 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  80121c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
  801223:	f6 c4 08             	test   $0x8,%ah
  801226:	75 79                	jne    8012a1 <pgfault+0xc4>
  801228:	e9 39 01 00 00       	jmp    801366 <pgfault+0x189>
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
		if (!(err & FEC_WR)) cprintf("Not write\n");
		if (!(uvpd[PDX(addr)] & PTE_P)) cprintf("PDE not present\n");
  80122d:	89 d8                	mov    %ebx,%eax
  80122f:	c1 e8 16             	shr    $0x16,%eax
  801232:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801239:	a8 01                	test   $0x1,%al
  80123b:	75 10                	jne    80124d <pgfault+0x70>
  80123d:	83 ec 0c             	sub    $0xc,%esp
  801240:	68 aa 2e 80 00       	push   $0x802eaa
  801245:	e8 73 f3 ff ff       	call   8005bd <cprintf>
  80124a:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_P)) cprintf("PTE not present\n");
  80124d:	c1 eb 0c             	shr    $0xc,%ebx
  801250:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801256:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80125d:	a8 01                	test   $0x1,%al
  80125f:	75 10                	jne    801271 <pgfault+0x94>
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	68 bb 2e 80 00       	push   $0x802ebb
  801269:	e8 4f f3 ff ff       	call   8005bd <cprintf>
  80126e:	83 c4 10             	add    $0x10,%esp
		if (!(uvpt[PTX(addr)] & PTE_COW)) cprintf("Not copy-on-write\n");
  801271:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801278:	f6 c4 08             	test   $0x8,%ah
  80127b:	75 10                	jne    80128d <pgfault+0xb0>
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	68 cc 2e 80 00       	push   $0x802ecc
  801285:	e8 33 f3 ff ff       	call   8005bd <cprintf>
  80128a:	83 c4 10             	add    $0x10,%esp
		panic("User page fault");
  80128d:	83 ec 04             	sub    $0x4,%esp
  801290:	68 df 2e 80 00       	push   $0x802edf
  801295:	6a 23                	push   $0x23
  801297:	68 ef 2e 80 00       	push   $0x802eef
  80129c:	e8 43 f2 ff ff       	call   8004e4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 0 refers to curenv
	if ((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8012a1:	83 ec 04             	sub    $0x4,%esp
  8012a4:	6a 07                	push   $0x7
  8012a6:	68 00 f0 7f 00       	push   $0x7ff000
  8012ab:	6a 00                	push   $0x0
  8012ad:	e8 3a fd ff ff       	call   800fec <sys_page_alloc>
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	79 12                	jns    8012cb <pgfault+0xee>
		panic("sys_page_alloc failed: %e", r);
  8012b9:	50                   	push   %eax
  8012ba:	68 fa 2e 80 00       	push   $0x802efa
  8012bf:	6a 2f                	push   $0x2f
  8012c1:	68 ef 2e 80 00       	push   $0x802eef
  8012c6:	e8 19 f2 ff ff       	call   8004e4 <_panic>
	memcpy((void*)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8012cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	68 00 10 00 00       	push   $0x1000
  8012d9:	53                   	push   %ebx
  8012da:	68 00 f0 7f 00       	push   $0x7ff000
  8012df:	e8 ff fa ff ff       	call   800de3 <memcpy>
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, (void*)ROUNDDOWN(addr, PGSIZE), 
  8012e4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8012eb:	53                   	push   %ebx
  8012ec:	6a 00                	push   $0x0
  8012ee:	68 00 f0 7f 00       	push   $0x7ff000
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 35 fd ff ff       	call   80102f <sys_page_map>
  8012fa:	83 c4 20             	add    $0x20,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	79 12                	jns    801313 <pgfault+0x136>
					PTE_P | PTE_U | PTE_W)) < 0)
		panic("sys_page_map failed: %e", r);
  801301:	50                   	push   %eax
  801302:	68 14 2f 80 00       	push   $0x802f14
  801307:	6a 33                	push   $0x33
  801309:	68 ef 2e 80 00       	push   $0x802eef
  80130e:	e8 d1 f1 ff ff       	call   8004e4 <_panic>
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	68 00 f0 7f 00       	push   $0x7ff000
  80131b:	6a 00                	push   $0x0
  80131d:	e8 4f fd ff ff       	call   801071 <sys_page_unmap>
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	79 5c                	jns    801385 <pgfault+0x1a8>
		panic("sys_page_unmap failed: %e", r);
  801329:	50                   	push   %eax
  80132a:	68 2c 2f 80 00       	push   $0x802f2c
  80132f:	6a 35                	push   $0x35
  801331:	68 ef 2e 80 00       	push   $0x802eef
  801336:	e8 a9 f1 ff ff       	call   8004e4 <_panic>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  80133b:	a1 04 50 80 00       	mov    0x805004,%eax
  801340:	8b 40 48             	mov    0x48(%eax),%eax
  801343:	83 ec 04             	sub    $0x4,%esp
  801346:	50                   	push   %eax
  801347:	53                   	push   %ebx
  801348:	68 68 2f 80 00       	push   $0x802f68
  80134d:	e8 6b f2 ff ff       	call   8005bd <cprintf>
		if (!(err & FEC_WR)) cprintf("Not write\n");
  801352:	c7 04 24 46 2f 80 00 	movl   $0x802f46,(%esp)
  801359:	e8 5f f2 ff ff       	call   8005bd <cprintf>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	e9 c7 fe ff ff       	jmp    80122d <pgfault+0x50>
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & 
				PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		cprintf("Fault address = %08x, envid = %08x\n", addr, thisenv->env_id);
  801366:	a1 04 50 80 00       	mov    0x805004,%eax
  80136b:	8b 40 48             	mov    0x48(%eax),%eax
  80136e:	83 ec 04             	sub    $0x4,%esp
  801371:	50                   	push   %eax
  801372:	53                   	push   %ebx
  801373:	68 68 2f 80 00       	push   $0x802f68
  801378:	e8 40 f2 ff ff       	call   8005bd <cprintf>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	e9 a8 fe ff ff       	jmp    80122d <pgfault+0x50>
		panic("sys_page_map failed: %e", r);
	if ((r = sys_page_unmap(0, (void*)PFTEMP)) < 0)
		panic("sys_page_unmap failed: %e", r);

	// panic("pgfault not implemented");
}
  801385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	57                   	push   %edi
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
  801390:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	int ret;
	set_pgfault_handler(pgfault);
  801393:	68 dd 11 80 00       	push   $0x8011dd
  801398:	e8 14 12 00 00       	call   8025b1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80139d:	b8 07 00 00 00       	mov    $0x7,%eax
  8013a2:	cd 30                	int    $0x30
  8013a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	0f 88 0d 01 00 00    	js     8014c2 <fork+0x138>
  8013b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ba:	be 00 00 00 00       	mov    $0x0,%esi
	else if (envid == 0) {
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	75 2f                	jne    8013f2 <fork+0x68>
		// Child returns
		thisenv = &envs[ENVX(sys_getenvid())];
  8013c3:	e8 e6 fb ff ff       	call   800fae <sys_getenvid>
  8013c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013d5:	a3 04 50 80 00       	mov    %eax,0x805004
		// set_pgfault_handler(pgfault);
		return 0;
  8013da:	b8 00 00 00 00       	mov    $0x0,%eax
  8013df:	e9 e1 00 00 00       	jmp    8014c5 <fork+0x13b>
  8013e4:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
  8013ea:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8013f0:	74 77                	je     801469 <fork+0xdf>
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_P | PTE_U;
	pde_t pde = uvpd[pn / NPTENTRIES];
  8013f2:	89 f0                	mov    %esi,%eax
  8013f4:	c1 e8 0a             	shr    $0xa,%eax
  8013f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	if (!(pde & PTE_P)) return 0;
  8013fe:	a8 01                	test   $0x1,%al
  801400:	74 0b                	je     80140d <fork+0x83>
	pte_t pte = uvpt[pn];
  801402:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	if (!(pte & PTE_P)) return 0;
  801409:	a8 01                	test   $0x1,%al
  80140b:	75 08                	jne    801415 <fork+0x8b>
  80140d:	8d 5e 01             	lea    0x1(%esi),%ebx
  801410:	c1 e3 0c             	shl    $0xc,%ebx
  801413:	eb 56                	jmp    80146b <fork+0xe1>
	// cprintf("virtual page %08x\n", pn * PGSIZE);

	if ((pte & PTE_W) || (pte & PTE_COW)) perm |= PTE_COW;
  801415:	25 02 08 00 00       	and    $0x802,%eax
  80141a:	83 f8 01             	cmp    $0x1,%eax
  80141d:	19 ff                	sbb    %edi,%edi
  80141f:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801425:	81 c7 05 08 00 00    	add    $0x805,%edi

	if ((r = sys_page_map(thisenv->env_id, (void*)(pn * PGSIZE), envid, 
  80142b:	a1 04 50 80 00       	mov    0x805004,%eax
  801430:	8b 40 48             	mov    0x48(%eax),%eax
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	57                   	push   %edi
  801437:	53                   	push   %ebx
  801438:	ff 75 e4             	pushl  -0x1c(%ebp)
  80143b:	53                   	push   %ebx
  80143c:	50                   	push   %eax
  80143d:	e8 ed fb ff ff       	call   80102f <sys_page_map>
  801442:	83 c4 20             	add    $0x20,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 7c                	js     8014c5 <fork+0x13b>
				(void*)(pn * PGSIZE), perm)) < 0) 
		return r;
	r = sys_page_map(envid, (void*)(pn * PGSIZE), thisenv->env_id, 
  801449:	a1 04 50 80 00       	mov    0x805004,%eax
  80144e:	8b 40 48             	mov    0x48(%eax),%eax
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	57                   	push   %edi
  801455:	53                   	push   %ebx
  801456:	50                   	push   %eax
  801457:	53                   	push   %ebx
  801458:	ff 75 e4             	pushl  -0x1c(%ebp)
  80145b:	e8 cf fb ff ff       	call   80102f <sys_page_map>
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
			// cprintf("virtual page %08x\n", pn * PGSIZE);
			if (pn * PGSIZE == UXSTACKTOP - PGSIZE) 
				continue;
			if ((ret = duppage(envid, pn)) < 0)
  801460:	83 c4 20             	add    $0x20,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	79 a6                	jns    80140d <fork+0x83>
  801467:	eb 5c                	jmp    8014c5 <fork+0x13b>
  801469:	89 c3                	mov    %eax,%ebx
		// set_pgfault_handler(pgfault);
		return 0;
	}
	else {
		uint32_t pn;
		for (pn = 0; pn * PGSIZE < UTOP; pn++){
  80146b:	83 c6 01             	add    $0x1,%esi
  80146e:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801474:	0f 86 6a ff ff ff    	jbe    8013e4 <fork+0x5a>
				return ret;
		}
		// cprintf("Fork: duppage finished\n");

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	6a 07                	push   $0x7
  80147f:	68 00 f0 bf ee       	push   $0xeebff000
  801484:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801487:	57                   	push   %edi
  801488:	e8 5f fb ff ff       	call   800fec <sys_page_alloc>
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 31                	js     8014c5 <fork+0x13b>
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
						thisenv->env_pgfault_upcall)) < 0)
  801494:	a1 04 50 80 00       	mov    0x805004,%eax

		// Should be done by parent
		if ((ret = sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P |
						PTE_U | PTE_W)) < 0)
			return ret;
		if ((ret = sys_env_set_pgfault_upcall(envid, 
  801499:	8b 40 64             	mov    0x64(%eax),%eax
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	50                   	push   %eax
  8014a0:	57                   	push   %edi
  8014a1:	e8 91 fc ff ff       	call   801137 <sys_env_set_pgfault_upcall>
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 18                	js     8014c5 <fork+0x13b>
						thisenv->env_pgfault_upcall)) < 0)
			return ret;

		if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	6a 02                	push   $0x2
  8014b2:	57                   	push   %edi
  8014b3:	e8 fb fb ff ff       	call   8010b3 <sys_env_set_status>
  8014b8:	83 c4 10             	add    $0x10,%esp
			return ret;
		return envid;
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	0f 49 c7             	cmovns %edi,%eax
  8014c0:	eb 03                	jmp    8014c5 <fork+0x13b>
	int ret;
	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();

	if (envid < 0) return envid;
  8014c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
			return ret;
		return envid;
	}

	panic("fork not implemented");
}
  8014c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <sfork>:

// Challenge!
int
sfork(void)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8014d3:	68 51 2f 80 00       	push   $0x802f51
  8014d8:	68 9f 00 00 00       	push   $0x9f
  8014dd:	68 ef 2e 80 00       	push   $0x802eef
  8014e2:	e8 fd ef ff ff       	call   8004e4 <_panic>

008014e7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	05 00 00 00 30       	add    $0x30000000,%eax
  8014f2:	c1 e8 0c             	shr    $0xc,%eax
}
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fd:	05 00 00 00 30       	add    $0x30000000,%eax
  801502:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801507:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80150c:	5d                   	pop    %ebp
  80150d:	c3                   	ret    

0080150e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801514:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801519:	89 c2                	mov    %eax,%edx
  80151b:	c1 ea 16             	shr    $0x16,%edx
  80151e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801525:	f6 c2 01             	test   $0x1,%dl
  801528:	74 11                	je     80153b <fd_alloc+0x2d>
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	c1 ea 0c             	shr    $0xc,%edx
  80152f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	75 09                	jne    801544 <fd_alloc+0x36>
			*fd_store = fd;
  80153b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
  801542:	eb 17                	jmp    80155b <fd_alloc+0x4d>
  801544:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801549:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80154e:	75 c9                	jne    801519 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801550:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801556:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801563:	83 f8 1f             	cmp    $0x1f,%eax
  801566:	77 36                	ja     80159e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801568:	c1 e0 0c             	shl    $0xc,%eax
  80156b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801570:	89 c2                	mov    %eax,%edx
  801572:	c1 ea 16             	shr    $0x16,%edx
  801575:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80157c:	f6 c2 01             	test   $0x1,%dl
  80157f:	74 24                	je     8015a5 <fd_lookup+0x48>
  801581:	89 c2                	mov    %eax,%edx
  801583:	c1 ea 0c             	shr    $0xc,%edx
  801586:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158d:	f6 c2 01             	test   $0x1,%dl
  801590:	74 1a                	je     8015ac <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801592:	8b 55 0c             	mov    0xc(%ebp),%edx
  801595:	89 02                	mov    %eax,(%edx)
	return 0;
  801597:	b8 00 00 00 00       	mov    $0x0,%eax
  80159c:	eb 13                	jmp    8015b1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80159e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a3:	eb 0c                	jmp    8015b1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015aa:	eb 05                	jmp    8015b1 <fd_lookup+0x54>
  8015ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015bc:	ba 08 30 80 00       	mov    $0x803008,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015c1:	eb 13                	jmp    8015d6 <dev_lookup+0x23>
  8015c3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015c6:	39 08                	cmp    %ecx,(%eax)
  8015c8:	75 0c                	jne    8015d6 <dev_lookup+0x23>
			*dev = devtab[i];
  8015ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015cd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d4:	eb 2e                	jmp    801604 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015d6:	8b 02                	mov    (%edx),%eax
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	75 e7                	jne    8015c3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015dc:	a1 04 50 80 00       	mov    0x805004,%eax
  8015e1:	8b 40 48             	mov    0x48(%eax),%eax
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	51                   	push   %ecx
  8015e8:	50                   	push   %eax
  8015e9:	68 8c 2f 80 00       	push   $0x802f8c
  8015ee:	e8 ca ef ff ff       	call   8005bd <cprintf>
	*dev = 0;
  8015f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	56                   	push   %esi
  80160a:	53                   	push   %ebx
  80160b:	83 ec 10             	sub    $0x10,%esp
  80160e:	8b 75 08             	mov    0x8(%ebp),%esi
  801611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80161e:	c1 e8 0c             	shr    $0xc,%eax
  801621:	50                   	push   %eax
  801622:	e8 36 ff ff ff       	call   80155d <fd_lookup>
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 05                	js     801633 <fd_close+0x2d>
	    || fd != fd2)
  80162e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801631:	74 0c                	je     80163f <fd_close+0x39>
		return (must_exist ? r : 0);
  801633:	84 db                	test   %bl,%bl
  801635:	ba 00 00 00 00       	mov    $0x0,%edx
  80163a:	0f 44 c2             	cmove  %edx,%eax
  80163d:	eb 41                	jmp    801680 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	ff 36                	pushl  (%esi)
  801648:	e8 66 ff ff ff       	call   8015b3 <dev_lookup>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 1a                	js     801670 <fd_close+0x6a>
		if (dev->dev_close)
  801656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801659:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80165c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801661:	85 c0                	test   %eax,%eax
  801663:	74 0b                	je     801670 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	56                   	push   %esi
  801669:	ff d0                	call   *%eax
  80166b:	89 c3                	mov    %eax,%ebx
  80166d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	56                   	push   %esi
  801674:	6a 00                	push   $0x0
  801676:	e8 f6 f9 ff ff       	call   801071 <sys_page_unmap>
	return r;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	89 d8                	mov    %ebx,%eax
}
  801680:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801683:	5b                   	pop    %ebx
  801684:	5e                   	pop    %esi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 c4 fe ff ff       	call   80155d <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 10                	js     8016b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	6a 01                	push   $0x1
  8016a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a8:	e8 59 ff ff ff       	call   801606 <fd_close>
  8016ad:	83 c4 10             	add    $0x10,%esp
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <close_all>:

void
close_all(void)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	53                   	push   %ebx
  8016c2:	e8 c0 ff ff ff       	call   801687 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c7:	83 c3 01             	add    $0x1,%ebx
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	83 fb 20             	cmp    $0x20,%ebx
  8016d0:	75 ec                	jne    8016be <close_all+0xc>
		close(i);
}
  8016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	57                   	push   %edi
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 2c             	sub    $0x2c,%esp
  8016e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	ff 75 08             	pushl  0x8(%ebp)
  8016ea:	e8 6e fe ff ff       	call   80155d <fd_lookup>
  8016ef:	83 c4 08             	add    $0x8,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	0f 88 c1 00 00 00    	js     8017bb <dup+0xe4>
		return r;
	close(newfdnum);
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	56                   	push   %esi
  8016fe:	e8 84 ff ff ff       	call   801687 <close>

	newfd = INDEX2FD(newfdnum);
  801703:	89 f3                	mov    %esi,%ebx
  801705:	c1 e3 0c             	shl    $0xc,%ebx
  801708:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80170e:	83 c4 04             	add    $0x4,%esp
  801711:	ff 75 e4             	pushl  -0x1c(%ebp)
  801714:	e8 de fd ff ff       	call   8014f7 <fd2data>
  801719:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80171b:	89 1c 24             	mov    %ebx,(%esp)
  80171e:	e8 d4 fd ff ff       	call   8014f7 <fd2data>
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801729:	89 f8                	mov    %edi,%eax
  80172b:	c1 e8 16             	shr    $0x16,%eax
  80172e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801735:	a8 01                	test   $0x1,%al
  801737:	74 37                	je     801770 <dup+0x99>
  801739:	89 f8                	mov    %edi,%eax
  80173b:	c1 e8 0c             	shr    $0xc,%eax
  80173e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801745:	f6 c2 01             	test   $0x1,%dl
  801748:	74 26                	je     801770 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80174a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801751:	83 ec 0c             	sub    $0xc,%esp
  801754:	25 07 0e 00 00       	and    $0xe07,%eax
  801759:	50                   	push   %eax
  80175a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80175d:	6a 00                	push   $0x0
  80175f:	57                   	push   %edi
  801760:	6a 00                	push   $0x0
  801762:	e8 c8 f8 ff ff       	call   80102f <sys_page_map>
  801767:	89 c7                	mov    %eax,%edi
  801769:	83 c4 20             	add    $0x20,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 2e                	js     80179e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801770:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801773:	89 d0                	mov    %edx,%eax
  801775:	c1 e8 0c             	shr    $0xc,%eax
  801778:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80177f:	83 ec 0c             	sub    $0xc,%esp
  801782:	25 07 0e 00 00       	and    $0xe07,%eax
  801787:	50                   	push   %eax
  801788:	53                   	push   %ebx
  801789:	6a 00                	push   $0x0
  80178b:	52                   	push   %edx
  80178c:	6a 00                	push   $0x0
  80178e:	e8 9c f8 ff ff       	call   80102f <sys_page_map>
  801793:	89 c7                	mov    %eax,%edi
  801795:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801798:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80179a:	85 ff                	test   %edi,%edi
  80179c:	79 1d                	jns    8017bb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	53                   	push   %ebx
  8017a2:	6a 00                	push   $0x0
  8017a4:	e8 c8 f8 ff ff       	call   801071 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017a9:	83 c4 08             	add    $0x8,%esp
  8017ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 bb f8 ff ff       	call   801071 <sys_page_unmap>
	return r;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	89 f8                	mov    %edi,%eax
}
  8017bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5f                   	pop    %edi
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 14             	sub    $0x14,%esp
  8017ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	53                   	push   %ebx
  8017d2:	e8 86 fd ff ff       	call   80155d <fd_lookup>
  8017d7:	83 c4 08             	add    $0x8,%esp
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 6d                	js     80184d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e0:	83 ec 08             	sub    $0x8,%esp
  8017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e6:	50                   	push   %eax
  8017e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ea:	ff 30                	pushl  (%eax)
  8017ec:	e8 c2 fd ff ff       	call   8015b3 <dev_lookup>
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 4c                	js     801844 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017fb:	8b 42 08             	mov    0x8(%edx),%eax
  8017fe:	83 e0 03             	and    $0x3,%eax
  801801:	83 f8 01             	cmp    $0x1,%eax
  801804:	75 21                	jne    801827 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801806:	a1 04 50 80 00       	mov    0x805004,%eax
  80180b:	8b 40 48             	mov    0x48(%eax),%eax
  80180e:	83 ec 04             	sub    $0x4,%esp
  801811:	53                   	push   %ebx
  801812:	50                   	push   %eax
  801813:	68 cd 2f 80 00       	push   $0x802fcd
  801818:	e8 a0 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801825:	eb 26                	jmp    80184d <read+0x8a>
	}
	if (!dev->dev_read)
  801827:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182a:	8b 40 08             	mov    0x8(%eax),%eax
  80182d:	85 c0                	test   %eax,%eax
  80182f:	74 17                	je     801848 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801831:	83 ec 04             	sub    $0x4,%esp
  801834:	ff 75 10             	pushl  0x10(%ebp)
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	52                   	push   %edx
  80183b:	ff d0                	call   *%eax
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	eb 09                	jmp    80184d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801844:	89 c2                	mov    %eax,%edx
  801846:	eb 05                	jmp    80184d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801848:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80184d:	89 d0                	mov    %edx,%eax
  80184f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	57                   	push   %edi
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801860:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801863:	bb 00 00 00 00       	mov    $0x0,%ebx
  801868:	eb 21                	jmp    80188b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80186a:	83 ec 04             	sub    $0x4,%esp
  80186d:	89 f0                	mov    %esi,%eax
  80186f:	29 d8                	sub    %ebx,%eax
  801871:	50                   	push   %eax
  801872:	89 d8                	mov    %ebx,%eax
  801874:	03 45 0c             	add    0xc(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	57                   	push   %edi
  801879:	e8 45 ff ff ff       	call   8017c3 <read>
		if (m < 0)
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	78 10                	js     801895 <readn+0x41>
			return m;
		if (m == 0)
  801885:	85 c0                	test   %eax,%eax
  801887:	74 0a                	je     801893 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801889:	01 c3                	add    %eax,%ebx
  80188b:	39 f3                	cmp    %esi,%ebx
  80188d:	72 db                	jb     80186a <readn+0x16>
  80188f:	89 d8                	mov    %ebx,%eax
  801891:	eb 02                	jmp    801895 <readn+0x41>
  801893:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801895:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801898:	5b                   	pop    %ebx
  801899:	5e                   	pop    %esi
  80189a:	5f                   	pop    %edi
  80189b:	5d                   	pop    %ebp
  80189c:	c3                   	ret    

0080189d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	53                   	push   %ebx
  8018a1:	83 ec 14             	sub    $0x14,%esp
  8018a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018aa:	50                   	push   %eax
  8018ab:	53                   	push   %ebx
  8018ac:	e8 ac fc ff ff       	call   80155d <fd_lookup>
  8018b1:	83 c4 08             	add    $0x8,%esp
  8018b4:	89 c2                	mov    %eax,%edx
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 68                	js     801922 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	ff 30                	pushl  (%eax)
  8018c6:	e8 e8 fc ff ff       	call   8015b3 <dev_lookup>
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 47                	js     801919 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d9:	75 21                	jne    8018fc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018db:	a1 04 50 80 00       	mov    0x805004,%eax
  8018e0:	8b 40 48             	mov    0x48(%eax),%eax
  8018e3:	83 ec 04             	sub    $0x4,%esp
  8018e6:	53                   	push   %ebx
  8018e7:	50                   	push   %eax
  8018e8:	68 e9 2f 80 00       	push   $0x802fe9
  8018ed:	e8 cb ec ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018fa:	eb 26                	jmp    801922 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ff:	8b 52 0c             	mov    0xc(%edx),%edx
  801902:	85 d2                	test   %edx,%edx
  801904:	74 17                	je     80191d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801906:	83 ec 04             	sub    $0x4,%esp
  801909:	ff 75 10             	pushl  0x10(%ebp)
  80190c:	ff 75 0c             	pushl  0xc(%ebp)
  80190f:	50                   	push   %eax
  801910:	ff d2                	call   *%edx
  801912:	89 c2                	mov    %eax,%edx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	eb 09                	jmp    801922 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801919:	89 c2                	mov    %eax,%edx
  80191b:	eb 05                	jmp    801922 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80191d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801922:	89 d0                	mov    %edx,%eax
  801924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <seek>:

int
seek(int fdnum, off_t offset)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801932:	50                   	push   %eax
  801933:	ff 75 08             	pushl  0x8(%ebp)
  801936:	e8 22 fc ff ff       	call   80155d <fd_lookup>
  80193b:	83 c4 08             	add    $0x8,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 0e                	js     801950 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801942:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801945:	8b 55 0c             	mov    0xc(%ebp),%edx
  801948:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	53                   	push   %ebx
  801956:	83 ec 14             	sub    $0x14,%esp
  801959:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195f:	50                   	push   %eax
  801960:	53                   	push   %ebx
  801961:	e8 f7 fb ff ff       	call   80155d <fd_lookup>
  801966:	83 c4 08             	add    $0x8,%esp
  801969:	89 c2                	mov    %eax,%edx
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 65                	js     8019d4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801975:	50                   	push   %eax
  801976:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801979:	ff 30                	pushl  (%eax)
  80197b:	e8 33 fc ff ff       	call   8015b3 <dev_lookup>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	85 c0                	test   %eax,%eax
  801985:	78 44                	js     8019cb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80198e:	75 21                	jne    8019b1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801990:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801995:	8b 40 48             	mov    0x48(%eax),%eax
  801998:	83 ec 04             	sub    $0x4,%esp
  80199b:	53                   	push   %ebx
  80199c:	50                   	push   %eax
  80199d:	68 ac 2f 80 00       	push   $0x802fac
  8019a2:	e8 16 ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019af:	eb 23                	jmp    8019d4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8019b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b4:	8b 52 18             	mov    0x18(%edx),%edx
  8019b7:	85 d2                	test   %edx,%edx
  8019b9:	74 14                	je     8019cf <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	50                   	push   %eax
  8019c2:	ff d2                	call   *%edx
  8019c4:	89 c2                	mov    %eax,%edx
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	eb 09                	jmp    8019d4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019cb:	89 c2                	mov    %eax,%edx
  8019cd:	eb 05                	jmp    8019d4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019d4:	89 d0                	mov    %edx,%eax
  8019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	53                   	push   %ebx
  8019df:	83 ec 14             	sub    $0x14,%esp
  8019e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e8:	50                   	push   %eax
  8019e9:	ff 75 08             	pushl  0x8(%ebp)
  8019ec:	e8 6c fb ff ff       	call   80155d <fd_lookup>
  8019f1:	83 c4 08             	add    $0x8,%esp
  8019f4:	89 c2                	mov    %eax,%edx
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 58                	js     801a52 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a00:	50                   	push   %eax
  801a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a04:	ff 30                	pushl  (%eax)
  801a06:	e8 a8 fb ff ff       	call   8015b3 <dev_lookup>
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 37                	js     801a49 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a15:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a19:	74 32                	je     801a4d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a1b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a1e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a25:	00 00 00 
	stat->st_isdir = 0;
  801a28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a2f:	00 00 00 
	stat->st_dev = dev;
  801a32:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a3f:	ff 50 14             	call   *0x14(%eax)
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	eb 09                	jmp    801a52 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a49:	89 c2                	mov    %eax,%edx
  801a4b:	eb 05                	jmp    801a52 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a4d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a52:	89 d0                	mov    %edx,%eax
  801a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	6a 00                	push   $0x0
  801a63:	ff 75 08             	pushl  0x8(%ebp)
  801a66:	e8 b7 01 00 00       	call   801c22 <open>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 1b                	js     801a8f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a74:	83 ec 08             	sub    $0x8,%esp
  801a77:	ff 75 0c             	pushl  0xc(%ebp)
  801a7a:	50                   	push   %eax
  801a7b:	e8 5b ff ff ff       	call   8019db <fstat>
  801a80:	89 c6                	mov    %eax,%esi
	close(fd);
  801a82:	89 1c 24             	mov    %ebx,(%esp)
  801a85:	e8 fd fb ff ff       	call   801687 <close>
	return r;
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	89 f0                	mov    %esi,%eax
}
  801a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	89 c6                	mov    %eax,%esi
  801a9d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a9f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801aa6:	75 12                	jne    801aba <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	6a 01                	push   $0x1
  801aad:	e8 38 0c 00 00       	call   8026ea <ipc_find_env>
  801ab2:	a3 00 50 80 00       	mov    %eax,0x805000
  801ab7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aba:	6a 07                	push   $0x7
  801abc:	68 00 60 80 00       	push   $0x806000
  801ac1:	56                   	push   %esi
  801ac2:	ff 35 00 50 80 00    	pushl  0x805000
  801ac8:	e8 c9 0b 00 00       	call   802696 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801acd:	83 c4 0c             	add    $0xc,%esp
  801ad0:	6a 00                	push   $0x0
  801ad2:	53                   	push   %ebx
  801ad3:	6a 00                	push   $0x0
  801ad5:	e8 47 0b 00 00       	call   802621 <ipc_recv>
}
  801ada:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aea:	8b 40 0c             	mov    0xc(%eax),%eax
  801aed:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af5:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801afa:	ba 00 00 00 00       	mov    $0x0,%edx
  801aff:	b8 02 00 00 00       	mov    $0x2,%eax
  801b04:	e8 8d ff ff ff       	call   801a96 <fsipc>
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	8b 40 0c             	mov    0xc(%eax),%eax
  801b17:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b21:	b8 06 00 00 00       	mov    $0x6,%eax
  801b26:	e8 6b ff ff ff       	call   801a96 <fsipc>
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	53                   	push   %ebx
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b42:	ba 00 00 00 00       	mov    $0x0,%edx
  801b47:	b8 05 00 00 00       	mov    $0x5,%eax
  801b4c:	e8 45 ff ff ff       	call   801a96 <fsipc>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 2c                	js     801b81 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b55:	83 ec 08             	sub    $0x8,%esp
  801b58:	68 00 60 80 00       	push   $0x806000
  801b5d:	53                   	push   %ebx
  801b5e:	e8 86 f0 ff ff       	call   800be9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b63:	a1 80 60 80 00       	mov    0x806080,%eax
  801b68:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b6e:	a1 84 60 80 00       	mov    0x806084,%eax
  801b73:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b8c:	68 18 30 80 00       	push   $0x803018
  801b91:	68 90 00 00 00       	push   $0x90
  801b96:	68 36 30 80 00       	push   $0x803036
  801b9b:	e8 44 e9 ff ff       	call   8004e4 <_panic>

00801ba0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	56                   	push   %esi
  801ba4:	53                   	push   %ebx
  801ba5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bab:	8b 40 0c             	mov    0xc(%eax),%eax
  801bae:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bb3:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbe:	b8 03 00 00 00       	mov    $0x3,%eax
  801bc3:	e8 ce fe ff ff       	call   801a96 <fsipc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	78 4b                	js     801c19 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bce:	39 c6                	cmp    %eax,%esi
  801bd0:	73 16                	jae    801be8 <devfile_read+0x48>
  801bd2:	68 41 30 80 00       	push   $0x803041
  801bd7:	68 48 30 80 00       	push   $0x803048
  801bdc:	6a 7c                	push   $0x7c
  801bde:	68 36 30 80 00       	push   $0x803036
  801be3:	e8 fc e8 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801be8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bed:	7e 16                	jle    801c05 <devfile_read+0x65>
  801bef:	68 5d 30 80 00       	push   $0x80305d
  801bf4:	68 48 30 80 00       	push   $0x803048
  801bf9:	6a 7d                	push   $0x7d
  801bfb:	68 36 30 80 00       	push   $0x803036
  801c00:	e8 df e8 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c05:	83 ec 04             	sub    $0x4,%esp
  801c08:	50                   	push   %eax
  801c09:	68 00 60 80 00       	push   $0x806000
  801c0e:	ff 75 0c             	pushl  0xc(%ebp)
  801c11:	e8 65 f1 ff ff       	call   800d7b <memmove>
	return r;
  801c16:	83 c4 10             	add    $0x10,%esp
}
  801c19:	89 d8                	mov    %ebx,%eax
  801c1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	53                   	push   %ebx
  801c26:	83 ec 20             	sub    $0x20,%esp
  801c29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c2c:	53                   	push   %ebx
  801c2d:	e8 7e ef ff ff       	call   800bb0 <strlen>
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c3a:	7f 67                	jg     801ca3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c42:	50                   	push   %eax
  801c43:	e8 c6 f8 ff ff       	call   80150e <fd_alloc>
  801c48:	83 c4 10             	add    $0x10,%esp
		return r;
  801c4b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 57                	js     801ca8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c51:	83 ec 08             	sub    $0x8,%esp
  801c54:	53                   	push   %ebx
  801c55:	68 00 60 80 00       	push   $0x806000
  801c5a:	e8 8a ef ff ff       	call   800be9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c62:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6f:	e8 22 fe ff ff       	call   801a96 <fsipc>
  801c74:	89 c3                	mov    %eax,%ebx
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	79 14                	jns    801c91 <open+0x6f>
		fd_close(fd, 0);
  801c7d:	83 ec 08             	sub    $0x8,%esp
  801c80:	6a 00                	push   $0x0
  801c82:	ff 75 f4             	pushl  -0xc(%ebp)
  801c85:	e8 7c f9 ff ff       	call   801606 <fd_close>
		return r;
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	89 da                	mov    %ebx,%edx
  801c8f:	eb 17                	jmp    801ca8 <open+0x86>
	}

	return fd2num(fd);
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	ff 75 f4             	pushl  -0xc(%ebp)
  801c97:	e8 4b f8 ff ff       	call   8014e7 <fd2num>
  801c9c:	89 c2                	mov    %eax,%edx
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	eb 05                	jmp    801ca8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ca3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ca8:	89 d0                	mov    %edx,%eax
  801caa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cba:	b8 08 00 00 00       	mov    $0x8,%eax
  801cbf:	e8 d2 fd ff ff       	call   801a96 <fsipc>
}
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	57                   	push   %edi
  801cca:	56                   	push   %esi
  801ccb:	53                   	push   %ebx
  801ccc:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801cd2:	6a 00                	push   $0x0
  801cd4:	ff 75 08             	pushl  0x8(%ebp)
  801cd7:	e8 46 ff ff ff       	call   801c22 <open>
  801cdc:	89 c7                	mov    %eax,%edi
  801cde:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	0f 88 3a 04 00 00    	js     802129 <spawn+0x463>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801cef:	83 ec 04             	sub    $0x4,%esp
  801cf2:	68 00 02 00 00       	push   $0x200
  801cf7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	57                   	push   %edi
  801cff:	e8 50 fb ff ff       	call   801854 <readn>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d0c:	75 0c                	jne    801d1a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801d0e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d15:	45 4c 46 
  801d18:	74 33                	je     801d4d <spawn+0x87>
		close(fd);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d23:	e8 5f f9 ff ff       	call   801687 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d28:	83 c4 0c             	add    $0xc,%esp
  801d2b:	68 7f 45 4c 46       	push   $0x464c457f
  801d30:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d36:	68 69 30 80 00       	push   $0x803069
  801d3b:	e8 7d e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801d48:	e9 3c 04 00 00       	jmp    802189 <spawn+0x4c3>
  801d4d:	b8 07 00 00 00       	mov    $0x7,%eax
  801d52:	cd 30                	int    $0x30
  801d54:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d5a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d60:	85 c0                	test   %eax,%eax
  801d62:	0f 88 c9 03 00 00    	js     802131 <spawn+0x46b>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d68:	89 c6                	mov    %eax,%esi
  801d6a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d70:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d73:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d79:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d7f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d86:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d8c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d92:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d97:	be 00 00 00 00       	mov    $0x0,%esi
  801d9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d9f:	eb 13                	jmp    801db4 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801da1:	83 ec 0c             	sub    $0xc,%esp
  801da4:	50                   	push   %eax
  801da5:	e8 06 ee ff ff       	call   800bb0 <strlen>
  801daa:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801dae:	83 c3 01             	add    $0x1,%ebx
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801dbb:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	75 df                	jne    801da1 <spawn+0xdb>
  801dc2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801dc8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801dce:	bf 00 10 40 00       	mov    $0x401000,%edi
  801dd3:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dd5:	89 fa                	mov    %edi,%edx
  801dd7:	83 e2 fc             	and    $0xfffffffc,%edx
  801dda:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801de1:	29 c2                	sub    %eax,%edx
  801de3:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801de9:	8d 42 f8             	lea    -0x8(%edx),%eax
  801dec:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801df1:	0f 86 4a 03 00 00    	jbe    802141 <spawn+0x47b>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801df7:	83 ec 04             	sub    $0x4,%esp
  801dfa:	6a 07                	push   $0x7
  801dfc:	68 00 00 40 00       	push   $0x400000
  801e01:	6a 00                	push   $0x0
  801e03:	e8 e4 f1 ff ff       	call   800fec <sys_page_alloc>
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	0f 88 35 03 00 00    	js     802148 <spawn+0x482>
  801e13:	be 00 00 00 00       	mov    $0x0,%esi
  801e18:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e21:	eb 30                	jmp    801e53 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801e23:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e29:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e2f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801e32:	83 ec 08             	sub    $0x8,%esp
  801e35:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e38:	57                   	push   %edi
  801e39:	e8 ab ed ff ff       	call   800be9 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e3e:	83 c4 04             	add    $0x4,%esp
  801e41:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e44:	e8 67 ed ff ff       	call   800bb0 <strlen>
  801e49:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e4d:	83 c6 01             	add    $0x1,%esi
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e59:	7f c8                	jg     801e23 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e5b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e61:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e67:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e6e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e74:	74 19                	je     801e8f <spawn+0x1c9>
  801e76:	68 e0 30 80 00       	push   $0x8030e0
  801e7b:	68 48 30 80 00       	push   $0x803048
  801e80:	68 f2 00 00 00       	push   $0xf2
  801e85:	68 83 30 80 00       	push   $0x803083
  801e8a:	e8 55 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e8f:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e95:	89 c8                	mov    %ecx,%eax
  801e97:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e9c:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801e9f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ea5:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ea8:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801eae:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	6a 07                	push   $0x7
  801eb9:	68 00 d0 bf ee       	push   $0xeebfd000
  801ebe:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ec4:	68 00 00 40 00       	push   $0x400000
  801ec9:	6a 00                	push   $0x0
  801ecb:	e8 5f f1 ff ff       	call   80102f <sys_page_map>
  801ed0:	89 c3                	mov    %eax,%ebx
  801ed2:	83 c4 20             	add    $0x20,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	0f 88 9a 02 00 00    	js     802177 <spawn+0x4b1>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801edd:	83 ec 08             	sub    $0x8,%esp
  801ee0:	68 00 00 40 00       	push   $0x400000
  801ee5:	6a 00                	push   $0x0
  801ee7:	e8 85 f1 ff ff       	call   801071 <sys_page_unmap>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	0f 88 7e 02 00 00    	js     802177 <spawn+0x4b1>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ef9:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801eff:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801f06:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f0c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801f13:	00 00 00 
  801f16:	e9 86 01 00 00       	jmp    8020a1 <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801f1b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f21:	83 38 01             	cmpl   $0x1,(%eax)
  801f24:	0f 85 69 01 00 00    	jne    802093 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f2a:	89 c1                	mov    %eax,%ecx
  801f2c:	8b 40 18             	mov    0x18(%eax),%eax
  801f2f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f35:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f38:	83 f8 01             	cmp    $0x1,%eax
  801f3b:	19 c0                	sbb    %eax,%eax
  801f3d:	83 e0 fe             	and    $0xfffffffe,%eax
  801f40:	83 c0 07             	add    $0x7,%eax
  801f43:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f49:	89 c8                	mov    %ecx,%eax
  801f4b:	8b 49 04             	mov    0x4(%ecx),%ecx
  801f4e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801f54:	8b 78 10             	mov    0x10(%eax),%edi
  801f57:	8b 50 14             	mov    0x14(%eax),%edx
  801f5a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801f60:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f63:	89 f0                	mov    %esi,%eax
  801f65:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f6a:	74 14                	je     801f80 <spawn+0x2ba>
		va -= i;
  801f6c:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f6e:	01 c2                	add    %eax,%edx
  801f70:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801f76:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f78:	29 c1                	sub    %eax,%ecx
  801f7a:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f85:	e9 f7 00 00 00       	jmp    802081 <spawn+0x3bb>
		if (i >= filesz) {
  801f8a:	39 df                	cmp    %ebx,%edi
  801f8c:	77 27                	ja     801fb5 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f8e:	83 ec 04             	sub    $0x4,%esp
  801f91:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f97:	56                   	push   %esi
  801f98:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f9e:	e8 49 f0 ff ff       	call   800fec <sys_page_alloc>
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	0f 89 c7 00 00 00    	jns    802075 <spawn+0x3af>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	e9 a1 01 00 00       	jmp    802156 <spawn+0x490>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801fb5:	83 ec 04             	sub    $0x4,%esp
  801fb8:	6a 07                	push   $0x7
  801fba:	68 00 00 40 00       	push   $0x400000
  801fbf:	6a 00                	push   $0x0
  801fc1:	e8 26 f0 ff ff       	call   800fec <sys_page_alloc>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	0f 88 7b 01 00 00    	js     80214c <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801fd1:	83 ec 08             	sub    $0x8,%esp
  801fd4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801fda:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fe7:	e8 3d f9 ff ff       	call   801929 <seek>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	0f 88 59 01 00 00    	js     802150 <spawn+0x48a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ff7:	83 ec 04             	sub    $0x4,%esp
  801ffa:	89 f8                	mov    %edi,%eax
  801ffc:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802002:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802007:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80200c:	0f 47 c1             	cmova  %ecx,%eax
  80200f:	50                   	push   %eax
  802010:	68 00 00 40 00       	push   $0x400000
  802015:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80201b:	e8 34 f8 ff ff       	call   801854 <readn>
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	85 c0                	test   %eax,%eax
  802025:	0f 88 29 01 00 00    	js     802154 <spawn+0x48e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80202b:	83 ec 0c             	sub    $0xc,%esp
  80202e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802034:	56                   	push   %esi
  802035:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80203b:	68 00 00 40 00       	push   $0x400000
  802040:	6a 00                	push   $0x0
  802042:	e8 e8 ef ff ff       	call   80102f <sys_page_map>
  802047:	83 c4 20             	add    $0x20,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	79 15                	jns    802063 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  80204e:	50                   	push   %eax
  80204f:	68 8f 30 80 00       	push   $0x80308f
  802054:	68 25 01 00 00       	push   $0x125
  802059:	68 83 30 80 00       	push   $0x803083
  80205e:	e8 81 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  802063:	83 ec 08             	sub    $0x8,%esp
  802066:	68 00 00 40 00       	push   $0x400000
  80206b:	6a 00                	push   $0x0
  80206d:	e8 ff ef ff ff       	call   801071 <sys_page_unmap>
  802072:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802075:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80207b:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802081:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802087:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80208d:	0f 87 f7 fe ff ff    	ja     801f8a <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802093:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80209a:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8020a1:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8020a8:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8020ae:	0f 8c 67 fe ff ff    	jl     801f1b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8020b4:	83 ec 0c             	sub    $0xc,%esp
  8020b7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020bd:	e8 c5 f5 ff ff       	call   801687 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8020c2:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8020c9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020cc:	83 c4 08             	add    $0x8,%esp
  8020cf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020d5:	50                   	push   %eax
  8020d6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020dc:	e8 14 f0 ff ff       	call   8010f5 <sys_env_set_trapframe>
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	79 15                	jns    8020fd <spawn+0x437>
		panic("sys_env_set_trapframe: %e", r);
  8020e8:	50                   	push   %eax
  8020e9:	68 ac 30 80 00       	push   $0x8030ac
  8020ee:	68 86 00 00 00       	push   $0x86
  8020f3:	68 83 30 80 00       	push   $0x803083
  8020f8:	e8 e7 e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8020fd:	83 ec 08             	sub    $0x8,%esp
  802100:	6a 02                	push   $0x2
  802102:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802108:	e8 a6 ef ff ff       	call   8010b3 <sys_env_set_status>
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	85 c0                	test   %eax,%eax
  802112:	79 25                	jns    802139 <spawn+0x473>
		panic("sys_env_set_status: %e", r);
  802114:	50                   	push   %eax
  802115:	68 c6 30 80 00       	push   $0x8030c6
  80211a:	68 89 00 00 00       	push   $0x89
  80211f:	68 83 30 80 00       	push   $0x803083
  802124:	e8 bb e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802129:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80212f:	eb 58                	jmp    802189 <spawn+0x4c3>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802131:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802137:	eb 50                	jmp    802189 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802139:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80213f:	eb 48                	jmp    802189 <spawn+0x4c3>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802141:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802146:	eb 41                	jmp    802189 <spawn+0x4c3>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802148:	89 c3                	mov    %eax,%ebx
  80214a:	eb 3d                	jmp    802189 <spawn+0x4c3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80214c:	89 c3                	mov    %eax,%ebx
  80214e:	eb 06                	jmp    802156 <spawn+0x490>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802150:	89 c3                	mov    %eax,%ebx
  802152:	eb 02                	jmp    802156 <spawn+0x490>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802154:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80215f:	e8 09 ee ff ff       	call   800f6d <sys_env_destroy>
	close(fd);
  802164:	83 c4 04             	add    $0x4,%esp
  802167:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80216d:	e8 15 f5 ff ff       	call   801687 <close>
	return r;
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	eb 12                	jmp    802189 <spawn+0x4c3>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802177:	83 ec 08             	sub    $0x8,%esp
  80217a:	68 00 00 40 00       	push   $0x400000
  80217f:	6a 00                	push   $0x0
  802181:	e8 eb ee ff ff       	call   801071 <sys_page_unmap>
  802186:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802189:	89 d8                	mov    %ebx,%eax
  80218b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218e:	5b                   	pop    %ebx
  80218f:	5e                   	pop    %esi
  802190:	5f                   	pop    %edi
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    

00802193 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802198:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80219b:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021a0:	eb 03                	jmp    8021a5 <spawnl+0x12>
		argc++;
  8021a2:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021a5:	83 c2 04             	add    $0x4,%edx
  8021a8:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021ac:	75 f4                	jne    8021a2 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021ae:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021b5:	83 e2 f0             	and    $0xfffffff0,%edx
  8021b8:	29 d4                	sub    %edx,%esp
  8021ba:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021be:	c1 ea 02             	shr    $0x2,%edx
  8021c1:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021c8:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021cd:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021d4:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021db:	00 
  8021dc:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021de:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e3:	eb 0a                	jmp    8021ef <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8021e5:	83 c0 01             	add    $0x1,%eax
  8021e8:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8021ec:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021ef:	39 d0                	cmp    %edx,%eax
  8021f1:	75 f2                	jne    8021e5 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8021f3:	83 ec 08             	sub    $0x8,%esp
  8021f6:	56                   	push   %esi
  8021f7:	ff 75 08             	pushl  0x8(%ebp)
  8021fa:	e8 c7 fa ff ff       	call   801cc6 <spawn>
}
  8021ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802202:	5b                   	pop    %ebx
  802203:	5e                   	pop    %esi
  802204:	5d                   	pop    %ebp
  802205:	c3                   	ret    

00802206 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	56                   	push   %esi
  80220a:	53                   	push   %ebx
  80220b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80220e:	83 ec 0c             	sub    $0xc,%esp
  802211:	ff 75 08             	pushl  0x8(%ebp)
  802214:	e8 de f2 ff ff       	call   8014f7 <fd2data>
  802219:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80221b:	83 c4 08             	add    $0x8,%esp
  80221e:	68 08 31 80 00       	push   $0x803108
  802223:	53                   	push   %ebx
  802224:	e8 c0 e9 ff ff       	call   800be9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802229:	8b 46 04             	mov    0x4(%esi),%eax
  80222c:	2b 06                	sub    (%esi),%eax
  80222e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802234:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80223b:	00 00 00 
	stat->st_dev = &devpipe;
  80223e:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802245:	40 80 00 
	return 0;
}
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
  80224d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	53                   	push   %ebx
  802258:	83 ec 0c             	sub    $0xc,%esp
  80225b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80225e:	53                   	push   %ebx
  80225f:	6a 00                	push   $0x0
  802261:	e8 0b ee ff ff       	call   801071 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802266:	89 1c 24             	mov    %ebx,(%esp)
  802269:	e8 89 f2 ff ff       	call   8014f7 <fd2data>
  80226e:	83 c4 08             	add    $0x8,%esp
  802271:	50                   	push   %eax
  802272:	6a 00                	push   $0x0
  802274:	e8 f8 ed ff ff       	call   801071 <sys_page_unmap>
}
  802279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80227c:	c9                   	leave  
  80227d:	c3                   	ret    

0080227e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80228a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80228c:	a1 04 50 80 00       	mov    0x805004,%eax
  802291:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802294:	83 ec 0c             	sub    $0xc,%esp
  802297:	ff 75 e0             	pushl  -0x20(%ebp)
  80229a:	e8 84 04 00 00       	call   802723 <pageref>
  80229f:	89 c3                	mov    %eax,%ebx
  8022a1:	89 3c 24             	mov    %edi,(%esp)
  8022a4:	e8 7a 04 00 00       	call   802723 <pageref>
  8022a9:	83 c4 10             	add    $0x10,%esp
  8022ac:	39 c3                	cmp    %eax,%ebx
  8022ae:	0f 94 c1             	sete   %cl
  8022b1:	0f b6 c9             	movzbl %cl,%ecx
  8022b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022b7:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022bd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022c0:	39 ce                	cmp    %ecx,%esi
  8022c2:	74 1b                	je     8022df <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022c4:	39 c3                	cmp    %eax,%ebx
  8022c6:	75 c4                	jne    80228c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022c8:	8b 42 58             	mov    0x58(%edx),%eax
  8022cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022ce:	50                   	push   %eax
  8022cf:	56                   	push   %esi
  8022d0:	68 0f 31 80 00       	push   $0x80310f
  8022d5:	e8 e3 e2 ff ff       	call   8005bd <cprintf>
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	eb ad                	jmp    80228c <_pipeisclosed+0xe>
	}
}
  8022df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	57                   	push   %edi
  8022ee:	56                   	push   %esi
  8022ef:	53                   	push   %ebx
  8022f0:	83 ec 28             	sub    $0x28,%esp
  8022f3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022f6:	56                   	push   %esi
  8022f7:	e8 fb f1 ff ff       	call   8014f7 <fd2data>
  8022fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022fe:	83 c4 10             	add    $0x10,%esp
  802301:	bf 00 00 00 00       	mov    $0x0,%edi
  802306:	eb 4b                	jmp    802353 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802308:	89 da                	mov    %ebx,%edx
  80230a:	89 f0                	mov    %esi,%eax
  80230c:	e8 6d ff ff ff       	call   80227e <_pipeisclosed>
  802311:	85 c0                	test   %eax,%eax
  802313:	75 48                	jne    80235d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802315:	e8 b3 ec ff ff       	call   800fcd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80231a:	8b 43 04             	mov    0x4(%ebx),%eax
  80231d:	8b 0b                	mov    (%ebx),%ecx
  80231f:	8d 51 20             	lea    0x20(%ecx),%edx
  802322:	39 d0                	cmp    %edx,%eax
  802324:	73 e2                	jae    802308 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802329:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80232d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802330:	89 c2                	mov    %eax,%edx
  802332:	c1 fa 1f             	sar    $0x1f,%edx
  802335:	89 d1                	mov    %edx,%ecx
  802337:	c1 e9 1b             	shr    $0x1b,%ecx
  80233a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80233d:	83 e2 1f             	and    $0x1f,%edx
  802340:	29 ca                	sub    %ecx,%edx
  802342:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802346:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80234a:	83 c0 01             	add    $0x1,%eax
  80234d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802350:	83 c7 01             	add    $0x1,%edi
  802353:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802356:	75 c2                	jne    80231a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802358:	8b 45 10             	mov    0x10(%ebp),%eax
  80235b:	eb 05                	jmp    802362 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80235d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802365:	5b                   	pop    %ebx
  802366:	5e                   	pop    %esi
  802367:	5f                   	pop    %edi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    

0080236a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	57                   	push   %edi
  80236e:	56                   	push   %esi
  80236f:	53                   	push   %ebx
  802370:	83 ec 18             	sub    $0x18,%esp
  802373:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802376:	57                   	push   %edi
  802377:	e8 7b f1 ff ff       	call   8014f7 <fd2data>
  80237c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80237e:	83 c4 10             	add    $0x10,%esp
  802381:	bb 00 00 00 00       	mov    $0x0,%ebx
  802386:	eb 3d                	jmp    8023c5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802388:	85 db                	test   %ebx,%ebx
  80238a:	74 04                	je     802390 <devpipe_read+0x26>
				return i;
  80238c:	89 d8                	mov    %ebx,%eax
  80238e:	eb 44                	jmp    8023d4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802390:	89 f2                	mov    %esi,%edx
  802392:	89 f8                	mov    %edi,%eax
  802394:	e8 e5 fe ff ff       	call   80227e <_pipeisclosed>
  802399:	85 c0                	test   %eax,%eax
  80239b:	75 32                	jne    8023cf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80239d:	e8 2b ec ff ff       	call   800fcd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023a2:	8b 06                	mov    (%esi),%eax
  8023a4:	3b 46 04             	cmp    0x4(%esi),%eax
  8023a7:	74 df                	je     802388 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023a9:	99                   	cltd   
  8023aa:	c1 ea 1b             	shr    $0x1b,%edx
  8023ad:	01 d0                	add    %edx,%eax
  8023af:	83 e0 1f             	and    $0x1f,%eax
  8023b2:	29 d0                	sub    %edx,%eax
  8023b4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023bc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023bf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023c2:	83 c3 01             	add    $0x1,%ebx
  8023c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023c8:	75 d8                	jne    8023a2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8023cd:	eb 05                	jmp    8023d4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023cf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    

008023dc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	56                   	push   %esi
  8023e0:	53                   	push   %ebx
  8023e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e7:	50                   	push   %eax
  8023e8:	e8 21 f1 ff ff       	call   80150e <fd_alloc>
  8023ed:	83 c4 10             	add    $0x10,%esp
  8023f0:	89 c2                	mov    %eax,%edx
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	0f 88 2c 01 00 00    	js     802526 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023fa:	83 ec 04             	sub    $0x4,%esp
  8023fd:	68 07 04 00 00       	push   $0x407
  802402:	ff 75 f4             	pushl  -0xc(%ebp)
  802405:	6a 00                	push   $0x0
  802407:	e8 e0 eb ff ff       	call   800fec <sys_page_alloc>
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	89 c2                	mov    %eax,%edx
  802411:	85 c0                	test   %eax,%eax
  802413:	0f 88 0d 01 00 00    	js     802526 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802419:	83 ec 0c             	sub    $0xc,%esp
  80241c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80241f:	50                   	push   %eax
  802420:	e8 e9 f0 ff ff       	call   80150e <fd_alloc>
  802425:	89 c3                	mov    %eax,%ebx
  802427:	83 c4 10             	add    $0x10,%esp
  80242a:	85 c0                	test   %eax,%eax
  80242c:	0f 88 e2 00 00 00    	js     802514 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802432:	83 ec 04             	sub    $0x4,%esp
  802435:	68 07 04 00 00       	push   $0x407
  80243a:	ff 75 f0             	pushl  -0x10(%ebp)
  80243d:	6a 00                	push   $0x0
  80243f:	e8 a8 eb ff ff       	call   800fec <sys_page_alloc>
  802444:	89 c3                	mov    %eax,%ebx
  802446:	83 c4 10             	add    $0x10,%esp
  802449:	85 c0                	test   %eax,%eax
  80244b:	0f 88 c3 00 00 00    	js     802514 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802451:	83 ec 0c             	sub    $0xc,%esp
  802454:	ff 75 f4             	pushl  -0xc(%ebp)
  802457:	e8 9b f0 ff ff       	call   8014f7 <fd2data>
  80245c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80245e:	83 c4 0c             	add    $0xc,%esp
  802461:	68 07 04 00 00       	push   $0x407
  802466:	50                   	push   %eax
  802467:	6a 00                	push   $0x0
  802469:	e8 7e eb ff ff       	call   800fec <sys_page_alloc>
  80246e:	89 c3                	mov    %eax,%ebx
  802470:	83 c4 10             	add    $0x10,%esp
  802473:	85 c0                	test   %eax,%eax
  802475:	0f 88 89 00 00 00    	js     802504 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80247b:	83 ec 0c             	sub    $0xc,%esp
  80247e:	ff 75 f0             	pushl  -0x10(%ebp)
  802481:	e8 71 f0 ff ff       	call   8014f7 <fd2data>
  802486:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80248d:	50                   	push   %eax
  80248e:	6a 00                	push   $0x0
  802490:	56                   	push   %esi
  802491:	6a 00                	push   $0x0
  802493:	e8 97 eb ff ff       	call   80102f <sys_page_map>
  802498:	89 c3                	mov    %eax,%ebx
  80249a:	83 c4 20             	add    $0x20,%esp
  80249d:	85 c0                	test   %eax,%eax
  80249f:	78 55                	js     8024f6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024a1:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024aa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024af:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024b6:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024bf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024c4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024cb:	83 ec 0c             	sub    $0xc,%esp
  8024ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8024d1:	e8 11 f0 ff ff       	call   8014e7 <fd2num>
  8024d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024d9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024db:	83 c4 04             	add    $0x4,%esp
  8024de:	ff 75 f0             	pushl  -0x10(%ebp)
  8024e1:	e8 01 f0 ff ff       	call   8014e7 <fd2num>
  8024e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024e9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024ec:	83 c4 10             	add    $0x10,%esp
  8024ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f4:	eb 30                	jmp    802526 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8024f6:	83 ec 08             	sub    $0x8,%esp
  8024f9:	56                   	push   %esi
  8024fa:	6a 00                	push   $0x0
  8024fc:	e8 70 eb ff ff       	call   801071 <sys_page_unmap>
  802501:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802504:	83 ec 08             	sub    $0x8,%esp
  802507:	ff 75 f0             	pushl  -0x10(%ebp)
  80250a:	6a 00                	push   $0x0
  80250c:	e8 60 eb ff ff       	call   801071 <sys_page_unmap>
  802511:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802514:	83 ec 08             	sub    $0x8,%esp
  802517:	ff 75 f4             	pushl  -0xc(%ebp)
  80251a:	6a 00                	push   $0x0
  80251c:	e8 50 eb ff ff       	call   801071 <sys_page_unmap>
  802521:	83 c4 10             	add    $0x10,%esp
  802524:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802526:	89 d0                	mov    %edx,%eax
  802528:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80252b:	5b                   	pop    %ebx
  80252c:	5e                   	pop    %esi
  80252d:	5d                   	pop    %ebp
  80252e:	c3                   	ret    

0080252f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80252f:	55                   	push   %ebp
  802530:	89 e5                	mov    %esp,%ebp
  802532:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802538:	50                   	push   %eax
  802539:	ff 75 08             	pushl  0x8(%ebp)
  80253c:	e8 1c f0 ff ff       	call   80155d <fd_lookup>
  802541:	83 c4 10             	add    $0x10,%esp
  802544:	85 c0                	test   %eax,%eax
  802546:	78 18                	js     802560 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802548:	83 ec 0c             	sub    $0xc,%esp
  80254b:	ff 75 f4             	pushl  -0xc(%ebp)
  80254e:	e8 a4 ef ff ff       	call   8014f7 <fd2data>
	return _pipeisclosed(fd, p);
  802553:	89 c2                	mov    %eax,%edx
  802555:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802558:	e8 21 fd ff ff       	call   80227e <_pipeisclosed>
  80255d:	83 c4 10             	add    $0x10,%esp
}
  802560:	c9                   	leave  
  802561:	c3                   	ret    

00802562 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802562:	55                   	push   %ebp
  802563:	89 e5                	mov    %esp,%ebp
  802565:	56                   	push   %esi
  802566:	53                   	push   %ebx
  802567:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80256a:	85 f6                	test   %esi,%esi
  80256c:	75 16                	jne    802584 <wait+0x22>
  80256e:	68 27 31 80 00       	push   $0x803127
  802573:	68 48 30 80 00       	push   $0x803048
  802578:	6a 09                	push   $0x9
  80257a:	68 32 31 80 00       	push   $0x803132
  80257f:	e8 60 df ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802584:	89 f3                	mov    %esi,%ebx
  802586:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80258c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80258f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802595:	eb 05                	jmp    80259c <wait+0x3a>
		sys_yield();
  802597:	e8 31 ea ff ff       	call   800fcd <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80259c:	8b 43 48             	mov    0x48(%ebx),%eax
  80259f:	39 c6                	cmp    %eax,%esi
  8025a1:	75 07                	jne    8025aa <wait+0x48>
  8025a3:	8b 43 54             	mov    0x54(%ebx),%eax
  8025a6:	85 c0                	test   %eax,%eax
  8025a8:	75 ed                	jne    802597 <wait+0x35>
		sys_yield();
}
  8025aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025b7:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025be:	75 31                	jne    8025f1 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  8025c0:	a1 04 50 80 00       	mov    0x805004,%eax
  8025c5:	8b 40 48             	mov    0x48(%eax),%eax
  8025c8:	83 ec 04             	sub    $0x4,%esp
  8025cb:	6a 07                	push   $0x7
  8025cd:	68 00 f0 bf ee       	push   $0xeebff000
  8025d2:	50                   	push   %eax
  8025d3:	e8 14 ea ff ff       	call   800fec <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  8025d8:	a1 04 50 80 00       	mov    0x805004,%eax
  8025dd:	8b 40 48             	mov    0x48(%eax),%eax
  8025e0:	83 c4 08             	add    $0x8,%esp
  8025e3:	68 fb 25 80 00       	push   $0x8025fb
  8025e8:	50                   	push   %eax
  8025e9:	e8 49 eb ff ff       	call   801137 <sys_env_set_pgfault_upcall>
  8025ee:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8025f4:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8025f9:	c9                   	leave  
  8025fa:	c3                   	ret    

008025fb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025fb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025fc:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802601:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802603:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  802606:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  802609:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  80260d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  802611:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  802614:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  802616:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80261a:	61                   	popa   
	addl $4, %esp        // skip eip
  80261b:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  80261e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  80261f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802620:	c3                   	ret    

00802621 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802621:	55                   	push   %ebp
  802622:	89 e5                	mov    %esp,%ebp
  802624:	56                   	push   %esi
  802625:	53                   	push   %ebx
  802626:	8b 75 08             	mov    0x8(%ebp),%esi
  802629:	8b 45 0c             	mov    0xc(%ebp),%eax
  80262c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  80262f:	85 c0                	test   %eax,%eax
  802631:	74 0e                	je     802641 <ipc_recv+0x20>
  802633:	83 ec 0c             	sub    $0xc,%esp
  802636:	50                   	push   %eax
  802637:	e8 60 eb ff ff       	call   80119c <sys_ipc_recv>
  80263c:	83 c4 10             	add    $0x10,%esp
  80263f:	eb 10                	jmp    802651 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  802641:	83 ec 0c             	sub    $0xc,%esp
  802644:	68 00 00 c0 ee       	push   $0xeec00000
  802649:	e8 4e eb ff ff       	call   80119c <sys_ipc_recv>
  80264e:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  802651:	85 c0                	test   %eax,%eax
  802653:	74 16                	je     80266b <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  802655:	85 f6                	test   %esi,%esi
  802657:	74 06                	je     80265f <ipc_recv+0x3e>
  802659:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80265f:	85 db                	test   %ebx,%ebx
  802661:	74 2c                	je     80268f <ipc_recv+0x6e>
  802663:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802669:	eb 24                	jmp    80268f <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  80266b:	85 f6                	test   %esi,%esi
  80266d:	74 0a                	je     802679 <ipc_recv+0x58>
  80266f:	a1 04 50 80 00       	mov    0x805004,%eax
  802674:	8b 40 74             	mov    0x74(%eax),%eax
  802677:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  802679:	85 db                	test   %ebx,%ebx
  80267b:	74 0a                	je     802687 <ipc_recv+0x66>
  80267d:	a1 04 50 80 00       	mov    0x805004,%eax
  802682:	8b 40 78             	mov    0x78(%eax),%eax
  802685:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802687:	a1 04 50 80 00       	mov    0x805004,%eax
  80268c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80268f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802692:	5b                   	pop    %ebx
  802693:	5e                   	pop    %esi
  802694:	5d                   	pop    %ebp
  802695:	c3                   	ret    

00802696 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802696:	55                   	push   %ebp
  802697:	89 e5                	mov    %esp,%ebp
  802699:	57                   	push   %edi
  80269a:	56                   	push   %esi
  80269b:	53                   	push   %ebx
  80269c:	83 ec 0c             	sub    $0xc,%esp
  80269f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8026a8:	85 c0                	test   %eax,%eax
  8026aa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8026af:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  8026b2:	ff 75 14             	pushl  0x14(%ebp)
  8026b5:	53                   	push   %ebx
  8026b6:	56                   	push   %esi
  8026b7:	57                   	push   %edi
  8026b8:	e8 bc ea ff ff       	call   801179 <sys_ipc_try_send>
		if (ret == 0) break;
  8026bd:	83 c4 10             	add    $0x10,%esp
  8026c0:	85 c0                	test   %eax,%eax
  8026c2:	74 1e                	je     8026e2 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  8026c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026c7:	74 12                	je     8026db <ipc_send+0x45>
  8026c9:	50                   	push   %eax
  8026ca:	68 3d 31 80 00       	push   $0x80313d
  8026cf:	6a 39                	push   $0x39
  8026d1:	68 4a 31 80 00       	push   $0x80314a
  8026d6:	e8 09 de ff ff       	call   8004e4 <_panic>
		sys_yield();
  8026db:	e8 ed e8 ff ff       	call   800fcd <sys_yield>
	}
  8026e0:	eb d0                	jmp    8026b2 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  8026e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026e5:	5b                   	pop    %ebx
  8026e6:	5e                   	pop    %esi
  8026e7:	5f                   	pop    %edi
  8026e8:	5d                   	pop    %ebp
  8026e9:	c3                   	ret    

008026ea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026ea:	55                   	push   %ebp
  8026eb:	89 e5                	mov    %esp,%ebp
  8026ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026f5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026f8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026fe:	8b 52 50             	mov    0x50(%edx),%edx
  802701:	39 ca                	cmp    %ecx,%edx
  802703:	75 0d                	jne    802712 <ipc_find_env+0x28>
			return envs[i].env_id;
  802705:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802708:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80270d:	8b 40 48             	mov    0x48(%eax),%eax
  802710:	eb 0f                	jmp    802721 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802712:	83 c0 01             	add    $0x1,%eax
  802715:	3d 00 04 00 00       	cmp    $0x400,%eax
  80271a:	75 d9                	jne    8026f5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80271c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802721:	5d                   	pop    %ebp
  802722:	c3                   	ret    

00802723 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802723:	55                   	push   %ebp
  802724:	89 e5                	mov    %esp,%ebp
  802726:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802729:	89 d0                	mov    %edx,%eax
  80272b:	c1 e8 16             	shr    $0x16,%eax
  80272e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802735:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80273a:	f6 c1 01             	test   $0x1,%cl
  80273d:	74 1d                	je     80275c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80273f:	c1 ea 0c             	shr    $0xc,%edx
  802742:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802749:	f6 c2 01             	test   $0x1,%dl
  80274c:	74 0e                	je     80275c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80274e:	c1 ea 0c             	shr    $0xc,%edx
  802751:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802758:	ef 
  802759:	0f b7 c0             	movzwl %ax,%eax
}
  80275c:	5d                   	pop    %ebp
  80275d:	c3                   	ret    
  80275e:	66 90                	xchg   %ax,%ax

00802760 <__udivdi3>:
  802760:	55                   	push   %ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	53                   	push   %ebx
  802764:	83 ec 1c             	sub    $0x1c,%esp
  802767:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80276b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80276f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802773:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802777:	85 f6                	test   %esi,%esi
  802779:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80277d:	89 ca                	mov    %ecx,%edx
  80277f:	89 f8                	mov    %edi,%eax
  802781:	75 3d                	jne    8027c0 <__udivdi3+0x60>
  802783:	39 cf                	cmp    %ecx,%edi
  802785:	0f 87 c5 00 00 00    	ja     802850 <__udivdi3+0xf0>
  80278b:	85 ff                	test   %edi,%edi
  80278d:	89 fd                	mov    %edi,%ebp
  80278f:	75 0b                	jne    80279c <__udivdi3+0x3c>
  802791:	b8 01 00 00 00       	mov    $0x1,%eax
  802796:	31 d2                	xor    %edx,%edx
  802798:	f7 f7                	div    %edi
  80279a:	89 c5                	mov    %eax,%ebp
  80279c:	89 c8                	mov    %ecx,%eax
  80279e:	31 d2                	xor    %edx,%edx
  8027a0:	f7 f5                	div    %ebp
  8027a2:	89 c1                	mov    %eax,%ecx
  8027a4:	89 d8                	mov    %ebx,%eax
  8027a6:	89 cf                	mov    %ecx,%edi
  8027a8:	f7 f5                	div    %ebp
  8027aa:	89 c3                	mov    %eax,%ebx
  8027ac:	89 d8                	mov    %ebx,%eax
  8027ae:	89 fa                	mov    %edi,%edx
  8027b0:	83 c4 1c             	add    $0x1c,%esp
  8027b3:	5b                   	pop    %ebx
  8027b4:	5e                   	pop    %esi
  8027b5:	5f                   	pop    %edi
  8027b6:	5d                   	pop    %ebp
  8027b7:	c3                   	ret    
  8027b8:	90                   	nop
  8027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	39 ce                	cmp    %ecx,%esi
  8027c2:	77 74                	ja     802838 <__udivdi3+0xd8>
  8027c4:	0f bd fe             	bsr    %esi,%edi
  8027c7:	83 f7 1f             	xor    $0x1f,%edi
  8027ca:	0f 84 98 00 00 00    	je     802868 <__udivdi3+0x108>
  8027d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027d5:	89 f9                	mov    %edi,%ecx
  8027d7:	89 c5                	mov    %eax,%ebp
  8027d9:	29 fb                	sub    %edi,%ebx
  8027db:	d3 e6                	shl    %cl,%esi
  8027dd:	89 d9                	mov    %ebx,%ecx
  8027df:	d3 ed                	shr    %cl,%ebp
  8027e1:	89 f9                	mov    %edi,%ecx
  8027e3:	d3 e0                	shl    %cl,%eax
  8027e5:	09 ee                	or     %ebp,%esi
  8027e7:	89 d9                	mov    %ebx,%ecx
  8027e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027ed:	89 d5                	mov    %edx,%ebp
  8027ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027f3:	d3 ed                	shr    %cl,%ebp
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	d3 e2                	shl    %cl,%edx
  8027f9:	89 d9                	mov    %ebx,%ecx
  8027fb:	d3 e8                	shr    %cl,%eax
  8027fd:	09 c2                	or     %eax,%edx
  8027ff:	89 d0                	mov    %edx,%eax
  802801:	89 ea                	mov    %ebp,%edx
  802803:	f7 f6                	div    %esi
  802805:	89 d5                	mov    %edx,%ebp
  802807:	89 c3                	mov    %eax,%ebx
  802809:	f7 64 24 0c          	mull   0xc(%esp)
  80280d:	39 d5                	cmp    %edx,%ebp
  80280f:	72 10                	jb     802821 <__udivdi3+0xc1>
  802811:	8b 74 24 08          	mov    0x8(%esp),%esi
  802815:	89 f9                	mov    %edi,%ecx
  802817:	d3 e6                	shl    %cl,%esi
  802819:	39 c6                	cmp    %eax,%esi
  80281b:	73 07                	jae    802824 <__udivdi3+0xc4>
  80281d:	39 d5                	cmp    %edx,%ebp
  80281f:	75 03                	jne    802824 <__udivdi3+0xc4>
  802821:	83 eb 01             	sub    $0x1,%ebx
  802824:	31 ff                	xor    %edi,%edi
  802826:	89 d8                	mov    %ebx,%eax
  802828:	89 fa                	mov    %edi,%edx
  80282a:	83 c4 1c             	add    $0x1c,%esp
  80282d:	5b                   	pop    %ebx
  80282e:	5e                   	pop    %esi
  80282f:	5f                   	pop    %edi
  802830:	5d                   	pop    %ebp
  802831:	c3                   	ret    
  802832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802838:	31 ff                	xor    %edi,%edi
  80283a:	31 db                	xor    %ebx,%ebx
  80283c:	89 d8                	mov    %ebx,%eax
  80283e:	89 fa                	mov    %edi,%edx
  802840:	83 c4 1c             	add    $0x1c,%esp
  802843:	5b                   	pop    %ebx
  802844:	5e                   	pop    %esi
  802845:	5f                   	pop    %edi
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
  802848:	90                   	nop
  802849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802850:	89 d8                	mov    %ebx,%eax
  802852:	f7 f7                	div    %edi
  802854:	31 ff                	xor    %edi,%edi
  802856:	89 c3                	mov    %eax,%ebx
  802858:	89 d8                	mov    %ebx,%eax
  80285a:	89 fa                	mov    %edi,%edx
  80285c:	83 c4 1c             	add    $0x1c,%esp
  80285f:	5b                   	pop    %ebx
  802860:	5e                   	pop    %esi
  802861:	5f                   	pop    %edi
  802862:	5d                   	pop    %ebp
  802863:	c3                   	ret    
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	39 ce                	cmp    %ecx,%esi
  80286a:	72 0c                	jb     802878 <__udivdi3+0x118>
  80286c:	31 db                	xor    %ebx,%ebx
  80286e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802872:	0f 87 34 ff ff ff    	ja     8027ac <__udivdi3+0x4c>
  802878:	bb 01 00 00 00       	mov    $0x1,%ebx
  80287d:	e9 2a ff ff ff       	jmp    8027ac <__udivdi3+0x4c>
  802882:	66 90                	xchg   %ax,%ax
  802884:	66 90                	xchg   %ax,%ax
  802886:	66 90                	xchg   %ax,%ax
  802888:	66 90                	xchg   %ax,%ax
  80288a:	66 90                	xchg   %ax,%ax
  80288c:	66 90                	xchg   %ax,%ax
  80288e:	66 90                	xchg   %ax,%ax

00802890 <__umoddi3>:
  802890:	55                   	push   %ebp
  802891:	57                   	push   %edi
  802892:	56                   	push   %esi
  802893:	53                   	push   %ebx
  802894:	83 ec 1c             	sub    $0x1c,%esp
  802897:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80289b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80289f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028a7:	85 d2                	test   %edx,%edx
  8028a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028b1:	89 f3                	mov    %esi,%ebx
  8028b3:	89 3c 24             	mov    %edi,(%esp)
  8028b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028ba:	75 1c                	jne    8028d8 <__umoddi3+0x48>
  8028bc:	39 f7                	cmp    %esi,%edi
  8028be:	76 50                	jbe    802910 <__umoddi3+0x80>
  8028c0:	89 c8                	mov    %ecx,%eax
  8028c2:	89 f2                	mov    %esi,%edx
  8028c4:	f7 f7                	div    %edi
  8028c6:	89 d0                	mov    %edx,%eax
  8028c8:	31 d2                	xor    %edx,%edx
  8028ca:	83 c4 1c             	add    $0x1c,%esp
  8028cd:	5b                   	pop    %ebx
  8028ce:	5e                   	pop    %esi
  8028cf:	5f                   	pop    %edi
  8028d0:	5d                   	pop    %ebp
  8028d1:	c3                   	ret    
  8028d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028d8:	39 f2                	cmp    %esi,%edx
  8028da:	89 d0                	mov    %edx,%eax
  8028dc:	77 52                	ja     802930 <__umoddi3+0xa0>
  8028de:	0f bd ea             	bsr    %edx,%ebp
  8028e1:	83 f5 1f             	xor    $0x1f,%ebp
  8028e4:	75 5a                	jne    802940 <__umoddi3+0xb0>
  8028e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ea:	0f 82 e0 00 00 00    	jb     8029d0 <__umoddi3+0x140>
  8028f0:	39 0c 24             	cmp    %ecx,(%esp)
  8028f3:	0f 86 d7 00 00 00    	jbe    8029d0 <__umoddi3+0x140>
  8028f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802901:	83 c4 1c             	add    $0x1c,%esp
  802904:	5b                   	pop    %ebx
  802905:	5e                   	pop    %esi
  802906:	5f                   	pop    %edi
  802907:	5d                   	pop    %ebp
  802908:	c3                   	ret    
  802909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802910:	85 ff                	test   %edi,%edi
  802912:	89 fd                	mov    %edi,%ebp
  802914:	75 0b                	jne    802921 <__umoddi3+0x91>
  802916:	b8 01 00 00 00       	mov    $0x1,%eax
  80291b:	31 d2                	xor    %edx,%edx
  80291d:	f7 f7                	div    %edi
  80291f:	89 c5                	mov    %eax,%ebp
  802921:	89 f0                	mov    %esi,%eax
  802923:	31 d2                	xor    %edx,%edx
  802925:	f7 f5                	div    %ebp
  802927:	89 c8                	mov    %ecx,%eax
  802929:	f7 f5                	div    %ebp
  80292b:	89 d0                	mov    %edx,%eax
  80292d:	eb 99                	jmp    8028c8 <__umoddi3+0x38>
  80292f:	90                   	nop
  802930:	89 c8                	mov    %ecx,%eax
  802932:	89 f2                	mov    %esi,%edx
  802934:	83 c4 1c             	add    $0x1c,%esp
  802937:	5b                   	pop    %ebx
  802938:	5e                   	pop    %esi
  802939:	5f                   	pop    %edi
  80293a:	5d                   	pop    %ebp
  80293b:	c3                   	ret    
  80293c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802940:	8b 34 24             	mov    (%esp),%esi
  802943:	bf 20 00 00 00       	mov    $0x20,%edi
  802948:	89 e9                	mov    %ebp,%ecx
  80294a:	29 ef                	sub    %ebp,%edi
  80294c:	d3 e0                	shl    %cl,%eax
  80294e:	89 f9                	mov    %edi,%ecx
  802950:	89 f2                	mov    %esi,%edx
  802952:	d3 ea                	shr    %cl,%edx
  802954:	89 e9                	mov    %ebp,%ecx
  802956:	09 c2                	or     %eax,%edx
  802958:	89 d8                	mov    %ebx,%eax
  80295a:	89 14 24             	mov    %edx,(%esp)
  80295d:	89 f2                	mov    %esi,%edx
  80295f:	d3 e2                	shl    %cl,%edx
  802961:	89 f9                	mov    %edi,%ecx
  802963:	89 54 24 04          	mov    %edx,0x4(%esp)
  802967:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80296b:	d3 e8                	shr    %cl,%eax
  80296d:	89 e9                	mov    %ebp,%ecx
  80296f:	89 c6                	mov    %eax,%esi
  802971:	d3 e3                	shl    %cl,%ebx
  802973:	89 f9                	mov    %edi,%ecx
  802975:	89 d0                	mov    %edx,%eax
  802977:	d3 e8                	shr    %cl,%eax
  802979:	89 e9                	mov    %ebp,%ecx
  80297b:	09 d8                	or     %ebx,%eax
  80297d:	89 d3                	mov    %edx,%ebx
  80297f:	89 f2                	mov    %esi,%edx
  802981:	f7 34 24             	divl   (%esp)
  802984:	89 d6                	mov    %edx,%esi
  802986:	d3 e3                	shl    %cl,%ebx
  802988:	f7 64 24 04          	mull   0x4(%esp)
  80298c:	39 d6                	cmp    %edx,%esi
  80298e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802992:	89 d1                	mov    %edx,%ecx
  802994:	89 c3                	mov    %eax,%ebx
  802996:	72 08                	jb     8029a0 <__umoddi3+0x110>
  802998:	75 11                	jne    8029ab <__umoddi3+0x11b>
  80299a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80299e:	73 0b                	jae    8029ab <__umoddi3+0x11b>
  8029a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029a4:	1b 14 24             	sbb    (%esp),%edx
  8029a7:	89 d1                	mov    %edx,%ecx
  8029a9:	89 c3                	mov    %eax,%ebx
  8029ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029af:	29 da                	sub    %ebx,%edx
  8029b1:	19 ce                	sbb    %ecx,%esi
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 f0                	mov    %esi,%eax
  8029b7:	d3 e0                	shl    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	d3 ea                	shr    %cl,%edx
  8029bd:	89 e9                	mov    %ebp,%ecx
  8029bf:	d3 ee                	shr    %cl,%esi
  8029c1:	09 d0                	or     %edx,%eax
  8029c3:	89 f2                	mov    %esi,%edx
  8029c5:	83 c4 1c             	add    $0x1c,%esp
  8029c8:	5b                   	pop    %ebx
  8029c9:	5e                   	pop    %esi
  8029ca:	5f                   	pop    %edi
  8029cb:	5d                   	pop    %ebp
  8029cc:	c3                   	ret    
  8029cd:	8d 76 00             	lea    0x0(%esi),%esi
  8029d0:	29 f9                	sub    %edi,%ecx
  8029d2:	19 d6                	sbb    %edx,%esi
  8029d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029dc:	e9 18 ff ff ff       	jmp    8028f9 <__umoddi3+0x69>
