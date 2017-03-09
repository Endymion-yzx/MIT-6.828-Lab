
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 58 1e 80 00       	push   $0x801e58
  800118:	6a 23                	push   $0x23
  80011a:	68 75 1e 80 00       	push   $0x801e75
  80011f:	e8 f5 0e 00 00       	call   801019 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 58 1e 80 00       	push   $0x801e58
  800199:	6a 23                	push   $0x23
  80019b:	68 75 1e 80 00       	push   $0x801e75
  8001a0:	e8 74 0e 00 00       	call   801019 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 58 1e 80 00       	push   $0x801e58
  8001db:	6a 23                	push   $0x23
  8001dd:	68 75 1e 80 00       	push   $0x801e75
  8001e2:	e8 32 0e 00 00       	call   801019 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 58 1e 80 00       	push   $0x801e58
  80021d:	6a 23                	push   $0x23
  80021f:	68 75 1e 80 00       	push   $0x801e75
  800224:	e8 f0 0d 00 00       	call   801019 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 58 1e 80 00       	push   $0x801e58
  80025f:	6a 23                	push   $0x23
  800261:	68 75 1e 80 00       	push   $0x801e75
  800266:	e8 ae 0d 00 00       	call   801019 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 58 1e 80 00       	push   $0x801e58
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 75 1e 80 00       	push   $0x801e75
  8002a8:	e8 6c 0d 00 00       	call   801019 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 58 1e 80 00       	push   $0x801e58
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 75 1e 80 00       	push   $0x801e75
  8002ea:	e8 2a 0d 00 00       	call   801019 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 58 1e 80 00       	push   $0x801e58
  800347:	6a 23                	push   $0x23
  800349:	68 75 1e 80 00       	push   $0x801e75
  80034e:	e8 c6 0c 00 00       	call   801019 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba 00 1f 80 00       	mov    $0x801f00,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 84 1e 80 00       	push   $0x801e84
  800462:	e8 8b 0c 00 00       	call   8010f2 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 c5 1e 80 00       	push   $0x801ec5
  80068c:	e8 61 0a 00 00       	call   8010f2 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 e1 1e 80 00       	push   $0x801ee1
  800761:	e8 8c 09 00 00       	call   8010f2 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 a4 1e 80 00       	push   $0x801ea4
  800816:	e8 d7 08 00 00       	call   8010f2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 b7 01 00 00       	call   800a96 <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 08 12 00 00       	call   801b2e <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 99 11 00 00       	call   801ada <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 17 11 00 00       	call   801a65 <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 47 0d 00 00       	call   80171e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800a00:	68 10 1f 80 00       	push   $0x801f10
  800a05:	68 90 00 00 00       	push   $0x90
  800a0a:	68 2e 1f 80 00       	push   $0x801f2e
  800a0f:	e8 05 06 00 00       	call   801019 <_panic>

00800a14 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 03 00 00 00       	mov    $0x3,%eax
  800a37:	e8 ce fe ff ff       	call   80090a <fsipc>
  800a3c:	89 c3                	mov    %eax,%ebx
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 4b                	js     800a8d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 16                	jae    800a5c <devfile_read+0x48>
  800a46:	68 39 1f 80 00       	push   $0x801f39
  800a4b:	68 40 1f 80 00       	push   $0x801f40
  800a50:	6a 7c                	push   $0x7c
  800a52:	68 2e 1f 80 00       	push   $0x801f2e
  800a57:	e8 bd 05 00 00       	call   801019 <_panic>
	assert(r <= PGSIZE);
  800a5c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a61:	7e 16                	jle    800a79 <devfile_read+0x65>
  800a63:	68 55 1f 80 00       	push   $0x801f55
  800a68:	68 40 1f 80 00       	push   $0x801f40
  800a6d:	6a 7d                	push   $0x7d
  800a6f:	68 2e 1f 80 00       	push   $0x801f2e
  800a74:	e8 a0 05 00 00       	call   801019 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a79:	83 ec 04             	sub    $0x4,%esp
  800a7c:	50                   	push   %eax
  800a7d:	68 00 50 80 00       	push   $0x805000
  800a82:	ff 75 0c             	pushl  0xc(%ebp)
  800a85:	e8 26 0e 00 00       	call   8018b0 <memmove>
	return r;
  800a8a:	83 c4 10             	add    $0x10,%esp
}
  800a8d:	89 d8                	mov    %ebx,%eax
  800a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 20             	sub    $0x20,%esp
  800a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aa0:	53                   	push   %ebx
  800aa1:	e8 3f 0c 00 00       	call   8016e5 <strlen>
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aae:	7f 67                	jg     800b17 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ab0:	83 ec 0c             	sub    $0xc,%esp
  800ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab6:	50                   	push   %eax
  800ab7:	e8 c6 f8 ff ff       	call   800382 <fd_alloc>
  800abc:	83 c4 10             	add    $0x10,%esp
		return r;
  800abf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 57                	js     800b1c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	53                   	push   %ebx
  800ac9:	68 00 50 80 00       	push   $0x805000
  800ace:	e8 4b 0c 00 00       	call   80171e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800adb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ade:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae3:	e8 22 fe ff ff       	call   80090a <fsipc>
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	85 c0                	test   %eax,%eax
  800aef:	79 14                	jns    800b05 <open+0x6f>
		fd_close(fd, 0);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	6a 00                	push   $0x0
  800af6:	ff 75 f4             	pushl  -0xc(%ebp)
  800af9:	e8 7c f9 ff ff       	call   80047a <fd_close>
		return r;
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	89 da                	mov    %ebx,%edx
  800b03:	eb 17                	jmp    800b1c <open+0x86>
	}

	return fd2num(fd);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0b:	e8 4b f8 ff ff       	call   80035b <fd2num>
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	eb 05                	jmp    800b1c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b17:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b1c:	89 d0                	mov    %edx,%eax
  800b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b33:	e8 d2 fd ff ff       	call   80090a <fsipc>
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	ff 75 08             	pushl  0x8(%ebp)
  800b48:	e8 1e f8 ff ff       	call   80036b <fd2data>
  800b4d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4f:	83 c4 08             	add    $0x8,%esp
  800b52:	68 61 1f 80 00       	push   $0x801f61
  800b57:	53                   	push   %ebx
  800b58:	e8 c1 0b 00 00       	call   80171e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5d:	8b 46 04             	mov    0x4(%esi),%eax
  800b60:	2b 06                	sub    (%esi),%eax
  800b62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6f:	00 00 00 
	stat->st_dev = &devpipe;
  800b72:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b79:	30 80 00 
	return 0;
}
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b92:	53                   	push   %ebx
  800b93:	6a 00                	push   $0x0
  800b95:	e8 55 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b9a:	89 1c 24             	mov    %ebx,(%esp)
  800b9d:	e8 c9 f7 ff ff       	call   80036b <fd2data>
  800ba2:	83 c4 08             	add    $0x8,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 00                	push   $0x0
  800ba8:	e8 42 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 1c             	sub    $0x1c,%esp
  800bbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bbe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bc0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bce:	e8 94 0f 00 00       	call   801b67 <pageref>
  800bd3:	89 c3                	mov    %eax,%ebx
  800bd5:	89 3c 24             	mov    %edi,(%esp)
  800bd8:	e8 8a 0f 00 00       	call   801b67 <pageref>
  800bdd:	83 c4 10             	add    $0x10,%esp
  800be0:	39 c3                	cmp    %eax,%ebx
  800be2:	0f 94 c1             	sete   %cl
  800be5:	0f b6 c9             	movzbl %cl,%ecx
  800be8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800beb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bf1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf4:	39 ce                	cmp    %ecx,%esi
  800bf6:	74 1b                	je     800c13 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bf8:	39 c3                	cmp    %eax,%ebx
  800bfa:	75 c4                	jne    800bc0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bfc:	8b 42 58             	mov    0x58(%edx),%eax
  800bff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c02:	50                   	push   %eax
  800c03:	56                   	push   %esi
  800c04:	68 68 1f 80 00       	push   $0x801f68
  800c09:	e8 e4 04 00 00       	call   8010f2 <cprintf>
  800c0e:	83 c4 10             	add    $0x10,%esp
  800c11:	eb ad                	jmp    800bc0 <_pipeisclosed+0xe>
	}
}
  800c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 28             	sub    $0x28,%esp
  800c27:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c2a:	56                   	push   %esi
  800c2b:	e8 3b f7 ff ff       	call   80036b <fd2data>
  800c30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3a:	eb 4b                	jmp    800c87 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c3c:	89 da                	mov    %ebx,%edx
  800c3e:	89 f0                	mov    %esi,%eax
  800c40:	e8 6d ff ff ff       	call   800bb2 <_pipeisclosed>
  800c45:	85 c0                	test   %eax,%eax
  800c47:	75 48                	jne    800c91 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c49:	e8 fd f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c51:	8b 0b                	mov    (%ebx),%ecx
  800c53:	8d 51 20             	lea    0x20(%ecx),%edx
  800c56:	39 d0                	cmp    %edx,%eax
  800c58:	73 e2                	jae    800c3c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c61:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c64:	89 c2                	mov    %eax,%edx
  800c66:	c1 fa 1f             	sar    $0x1f,%edx
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c71:	83 e2 1f             	and    $0x1f,%edx
  800c74:	29 ca                	sub    %ecx,%edx
  800c76:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c7a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7e:	83 c0 01             	add    $0x1,%eax
  800c81:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c84:	83 c7 01             	add    $0x1,%edi
  800c87:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c8a:	75 c2                	jne    800c4e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8f:	eb 05                	jmp    800c96 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c91:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 18             	sub    $0x18,%esp
  800ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800caa:	57                   	push   %edi
  800cab:	e8 bb f6 ff ff       	call   80036b <fd2data>
  800cb0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb2:	83 c4 10             	add    $0x10,%esp
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	eb 3d                	jmp    800cf9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cbc:	85 db                	test   %ebx,%ebx
  800cbe:	74 04                	je     800cc4 <devpipe_read+0x26>
				return i;
  800cc0:	89 d8                	mov    %ebx,%eax
  800cc2:	eb 44                	jmp    800d08 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cc4:	89 f2                	mov    %esi,%edx
  800cc6:	89 f8                	mov    %edi,%eax
  800cc8:	e8 e5 fe ff ff       	call   800bb2 <_pipeisclosed>
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	75 32                	jne    800d03 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cd1:	e8 75 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cd6:	8b 06                	mov    (%esi),%eax
  800cd8:	3b 46 04             	cmp    0x4(%esi),%eax
  800cdb:	74 df                	je     800cbc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cdd:	99                   	cltd   
  800cde:	c1 ea 1b             	shr    $0x1b,%edx
  800ce1:	01 d0                	add    %edx,%eax
  800ce3:	83 e0 1f             	and    $0x1f,%eax
  800ce6:	29 d0                	sub    %edx,%eax
  800ce8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cf3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf6:	83 c3 01             	add    $0x1,%ebx
  800cf9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cfc:	75 d8                	jne    800cd6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cfe:	8b 45 10             	mov    0x10(%ebp),%eax
  800d01:	eb 05                	jmp    800d08 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d03:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 61 f6 ff ff       	call   800382 <fd_alloc>
  800d21:	83 c4 10             	add    $0x10,%esp
  800d24:	89 c2                	mov    %eax,%edx
  800d26:	85 c0                	test   %eax,%eax
  800d28:	0f 88 2c 01 00 00    	js     800e5a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2e:	83 ec 04             	sub    $0x4,%esp
  800d31:	68 07 04 00 00       	push   $0x407
  800d36:	ff 75 f4             	pushl  -0xc(%ebp)
  800d39:	6a 00                	push   $0x0
  800d3b:	e8 2a f4 ff ff       	call   80016a <sys_page_alloc>
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	85 c0                	test   %eax,%eax
  800d47:	0f 88 0d 01 00 00    	js     800e5a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d53:	50                   	push   %eax
  800d54:	e8 29 f6 ff ff       	call   800382 <fd_alloc>
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	0f 88 e2 00 00 00    	js     800e48 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	68 07 04 00 00       	push   $0x407
  800d6e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d71:	6a 00                	push   $0x0
  800d73:	e8 f2 f3 ff ff       	call   80016a <sys_page_alloc>
  800d78:	89 c3                	mov    %eax,%ebx
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	0f 88 c3 00 00 00    	js     800e48 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8b:	e8 db f5 ff ff       	call   80036b <fd2data>
  800d90:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 c4 0c             	add    $0xc,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	50                   	push   %eax
  800d9b:	6a 00                	push   $0x0
  800d9d:	e8 c8 f3 ff ff       	call   80016a <sys_page_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 89 00 00 00    	js     800e38 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	ff 75 f0             	pushl  -0x10(%ebp)
  800db5:	e8 b1 f5 ff ff       	call   80036b <fd2data>
  800dba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dc1:	50                   	push   %eax
  800dc2:	6a 00                	push   $0x0
  800dc4:	56                   	push   %esi
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 e1 f3 ff ff       	call   8001ad <sys_page_map>
  800dcc:	89 c3                	mov    %eax,%ebx
  800dce:	83 c4 20             	add    $0x20,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	78 55                	js     800e2a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dd5:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dde:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dea:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800df0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	ff 75 f4             	pushl  -0xc(%ebp)
  800e05:	e8 51 f5 ff ff       	call   80035b <fd2num>
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e0f:	83 c4 04             	add    $0x4,%esp
  800e12:	ff 75 f0             	pushl  -0x10(%ebp)
  800e15:	e8 41 f5 ff ff       	call   80035b <fd2num>
  800e1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	ba 00 00 00 00       	mov    $0x0,%edx
  800e28:	eb 30                	jmp    800e5a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e2a:	83 ec 08             	sub    $0x8,%esp
  800e2d:	56                   	push   %esi
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 ba f3 ff ff       	call   8001ef <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 aa f3 ff ff       	call   8001ef <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 9a f3 ff ff       	call   8001ef <sys_page_unmap>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e5a:	89 d0                	mov    %edx,%eax
  800e5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6c:	50                   	push   %eax
  800e6d:	ff 75 08             	pushl  0x8(%ebp)
  800e70:	e8 5c f5 ff ff       	call   8003d1 <fd_lookup>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	78 18                	js     800e94 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e82:	e8 e4 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800e87:	89 c2                	mov    %eax,%edx
  800e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8c:	e8 21 fd ff ff       	call   800bb2 <_pipeisclosed>
  800e91:	83 c4 10             	add    $0x10,%esp
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ea6:	68 80 1f 80 00       	push   $0x801f80
  800eab:	ff 75 0c             	pushl  0xc(%ebp)
  800eae:	e8 6b 08 00 00       	call   80171e <strcpy>
	return 0;
}
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ecb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed1:	eb 2d                	jmp    800f00 <devcons_write+0x46>
		m = n - tot;
  800ed3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ed8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800edb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ee0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	53                   	push   %ebx
  800ee7:	03 45 0c             	add    0xc(%ebp),%eax
  800eea:	50                   	push   %eax
  800eeb:	57                   	push   %edi
  800eec:	e8 bf 09 00 00       	call   8018b0 <memmove>
		sys_cputs(buf, m);
  800ef1:	83 c4 08             	add    $0x8,%esp
  800ef4:	53                   	push   %ebx
  800ef5:	57                   	push   %edi
  800ef6:	e8 b3 f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efb:	01 de                	add    %ebx,%esi
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	89 f0                	mov    %esi,%eax
  800f02:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f05:	72 cc                	jb     800ed3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1e:	74 2a                	je     800f4a <devcons_read+0x3b>
  800f20:	eb 05                	jmp    800f27 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f22:	e8 24 f2 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f27:	e8 a0 f1 ff ff       	call   8000cc <sys_cgetc>
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	74 f2                	je     800f22 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 16                	js     800f4a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f34:	83 f8 04             	cmp    $0x4,%eax
  800f37:	74 0c                	je     800f45 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3c:	88 02                	mov    %al,(%edx)
	return 1;
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	eb 05                	jmp    800f4a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
  800f55:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f58:	6a 01                	push   $0x1
  800f5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5d:	50                   	push   %eax
  800f5e:	e8 4b f1 ff ff       	call   8000ae <sys_cputs>
}
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <getchar>:

int
getchar(void)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f6e:	6a 01                	push   $0x1
  800f70:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	6a 00                	push   $0x0
  800f76:	e8 bc f6 ff ff       	call   800637 <read>
	if (r < 0)
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 0f                	js     800f91 <getchar+0x29>
		return r;
	if (r < 1)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7e 06                	jle    800f8c <getchar+0x24>
		return -E_EOF;
	return c;
  800f86:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f8a:	eb 05                	jmp    800f91 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f8c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	ff 75 08             	pushl  0x8(%ebp)
  800fa0:	e8 2c f4 ff ff       	call   8003d1 <fd_lookup>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 11                	js     800fbd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faf:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fb5:	39 10                	cmp    %edx,(%eax)
  800fb7:	0f 94 c0             	sete   %al
  800fba:	0f b6 c0             	movzbl %al,%eax
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <opencons>:

int
opencons(void)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	e8 b4 f3 ff ff       	call   800382 <fd_alloc>
  800fce:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 3e                	js     801015 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	68 07 04 00 00       	push   $0x407
  800fdf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 81 f1 ff ff       	call   80016a <sys_page_alloc>
  800fe9:	83 c4 10             	add    $0x10,%esp
		return r;
  800fec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 23                	js     801015 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ff2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801000:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	50                   	push   %eax
  80100b:	e8 4b f3 ff ff       	call   80035b <fd2num>
  801010:	89 c2                	mov    %eax,%edx
  801012:	83 c4 10             	add    $0x10,%esp
}
  801015:	89 d0                	mov    %edx,%eax
  801017:	c9                   	leave  
  801018:	c3                   	ret    

00801019 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80101e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801021:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801027:	e8 00 f1 ff ff       	call   80012c <sys_getenvid>
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	ff 75 0c             	pushl  0xc(%ebp)
  801032:	ff 75 08             	pushl  0x8(%ebp)
  801035:	56                   	push   %esi
  801036:	50                   	push   %eax
  801037:	68 8c 1f 80 00       	push   $0x801f8c
  80103c:	e8 b1 00 00 00       	call   8010f2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801041:	83 c4 18             	add    $0x18,%esp
  801044:	53                   	push   %ebx
  801045:	ff 75 10             	pushl  0x10(%ebp)
  801048:	e8 54 00 00 00       	call   8010a1 <vcprintf>
	cprintf("\n");
  80104d:	c7 04 24 79 1f 80 00 	movl   $0x801f79,(%esp)
  801054:	e8 99 00 00 00       	call   8010f2 <cprintf>
  801059:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80105c:	cc                   	int3   
  80105d:	eb fd                	jmp    80105c <_panic+0x43>

0080105f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	53                   	push   %ebx
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801069:	8b 13                	mov    (%ebx),%edx
  80106b:	8d 42 01             	lea    0x1(%edx),%eax
  80106e:	89 03                	mov    %eax,(%ebx)
  801070:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801073:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801077:	3d ff 00 00 00       	cmp    $0xff,%eax
  80107c:	75 1a                	jne    801098 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	68 ff 00 00 00       	push   $0xff
  801086:	8d 43 08             	lea    0x8(%ebx),%eax
  801089:	50                   	push   %eax
  80108a:	e8 1f f0 ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  80108f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801095:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801098:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80109c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109f:	c9                   	leave  
  8010a0:	c3                   	ret    

008010a1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010aa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010b1:	00 00 00 
	b.cnt = 0;
  8010b4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010bb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010be:	ff 75 0c             	pushl  0xc(%ebp)
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	68 5f 10 80 00       	push   $0x80105f
  8010d0:	e8 1a 01 00 00       	call   8011ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	e8 c4 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8010ea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010fb:	50                   	push   %eax
  8010fc:	ff 75 08             	pushl  0x8(%ebp)
  8010ff:	e8 9d ff ff ff       	call   8010a1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	57                   	push   %edi
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
  80110c:	83 ec 1c             	sub    $0x1c,%esp
  80110f:	89 c7                	mov    %eax,%edi
  801111:	89 d6                	mov    %edx,%esi
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	8b 55 0c             	mov    0xc(%ebp),%edx
  801119:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80111c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801122:	bb 00 00 00 00       	mov    $0x0,%ebx
  801127:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80112a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80112d:	39 d3                	cmp    %edx,%ebx
  80112f:	72 05                	jb     801136 <printnum+0x30>
  801131:	39 45 10             	cmp    %eax,0x10(%ebp)
  801134:	77 45                	ja     80117b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	ff 75 18             	pushl  0x18(%ebp)
  80113c:	8b 45 14             	mov    0x14(%ebp),%eax
  80113f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801142:	53                   	push   %ebx
  801143:	ff 75 10             	pushl  0x10(%ebp)
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114c:	ff 75 e0             	pushl  -0x20(%ebp)
  80114f:	ff 75 dc             	pushl  -0x24(%ebp)
  801152:	ff 75 d8             	pushl  -0x28(%ebp)
  801155:	e8 56 0a 00 00       	call   801bb0 <__udivdi3>
  80115a:	83 c4 18             	add    $0x18,%esp
  80115d:	52                   	push   %edx
  80115e:	50                   	push   %eax
  80115f:	89 f2                	mov    %esi,%edx
  801161:	89 f8                	mov    %edi,%eax
  801163:	e8 9e ff ff ff       	call   801106 <printnum>
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	eb 18                	jmp    801185 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	56                   	push   %esi
  801171:	ff 75 18             	pushl  0x18(%ebp)
  801174:	ff d7                	call   *%edi
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	eb 03                	jmp    80117e <printnum+0x78>
  80117b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80117e:	83 eb 01             	sub    $0x1,%ebx
  801181:	85 db                	test   %ebx,%ebx
  801183:	7f e8                	jg     80116d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	56                   	push   %esi
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118f:	ff 75 e0             	pushl  -0x20(%ebp)
  801192:	ff 75 dc             	pushl  -0x24(%ebp)
  801195:	ff 75 d8             	pushl  -0x28(%ebp)
  801198:	e8 43 0b 00 00       	call   801ce0 <__umoddi3>
  80119d:	83 c4 14             	add    $0x14,%esp
  8011a0:	0f be 80 af 1f 80 00 	movsbl 0x801faf(%eax),%eax
  8011a7:	50                   	push   %eax
  8011a8:	ff d7                	call   *%edi
}
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011bf:	8b 10                	mov    (%eax),%edx
  8011c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011c4:	73 0a                	jae    8011d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011c9:	89 08                	mov    %ecx,(%eax)
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	88 02                	mov    %al,(%edx)
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011db:	50                   	push   %eax
  8011dc:	ff 75 10             	pushl  0x10(%ebp)
  8011df:	ff 75 0c             	pushl  0xc(%ebp)
  8011e2:	ff 75 08             	pushl  0x8(%ebp)
  8011e5:	e8 05 00 00 00       	call   8011ef <vprintfmt>
	va_end(ap);
}
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	57                   	push   %edi
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 2c             	sub    $0x2c,%esp
  8011f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801201:	eb 12                	jmp    801215 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801203:	85 c0                	test   %eax,%eax
  801205:	0f 84 6a 04 00 00    	je     801675 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	53                   	push   %ebx
  80120f:	50                   	push   %eax
  801210:	ff d6                	call   *%esi
  801212:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801215:	83 c7 01             	add    $0x1,%edi
  801218:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80121c:	83 f8 25             	cmp    $0x25,%eax
  80121f:	75 e2                	jne    801203 <vprintfmt+0x14>
  801221:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801225:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80122c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801233:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80123a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123f:	eb 07                	jmp    801248 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801241:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801244:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801248:	8d 47 01             	lea    0x1(%edi),%eax
  80124b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80124e:	0f b6 07             	movzbl (%edi),%eax
  801251:	0f b6 d0             	movzbl %al,%edx
  801254:	83 e8 23             	sub    $0x23,%eax
  801257:	3c 55                	cmp    $0x55,%al
  801259:	0f 87 fb 03 00 00    	ja     80165a <vprintfmt+0x46b>
  80125f:	0f b6 c0             	movzbl %al,%eax
  801262:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  801269:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80126c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801270:	eb d6                	jmp    801248 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801272:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80127d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801280:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801284:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801287:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80128a:	83 f9 09             	cmp    $0x9,%ecx
  80128d:	77 3f                	ja     8012ce <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80128f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801292:	eb e9                	jmp    80127d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801294:	8b 45 14             	mov    0x14(%ebp),%eax
  801297:	8b 00                	mov    (%eax),%eax
  801299:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80129c:	8b 45 14             	mov    0x14(%ebp),%eax
  80129f:	8d 40 04             	lea    0x4(%eax),%eax
  8012a2:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012a8:	eb 2a                	jmp    8012d4 <vprintfmt+0xe5>
  8012aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b4:	0f 49 d0             	cmovns %eax,%edx
  8012b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012bd:	eb 89                	jmp    801248 <vprintfmt+0x59>
  8012bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012c9:	e9 7a ff ff ff       	jmp    801248 <vprintfmt+0x59>
  8012ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012d1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012d8:	0f 89 6a ff ff ff    	jns    801248 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012eb:	e9 58 ff ff ff       	jmp    801248 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012f0:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8012f6:	e9 4d ff ff ff       	jmp    801248 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fe:	8d 78 04             	lea    0x4(%eax),%edi
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	53                   	push   %ebx
  801305:	ff 30                	pushl  (%eax)
  801307:	ff d6                	call   *%esi
			break;
  801309:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80130c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801312:	e9 fe fe ff ff       	jmp    801215 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801317:	8b 45 14             	mov    0x14(%ebp),%eax
  80131a:	8d 78 04             	lea    0x4(%eax),%edi
  80131d:	8b 00                	mov    (%eax),%eax
  80131f:	99                   	cltd   
  801320:	31 d0                	xor    %edx,%eax
  801322:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801324:	83 f8 0f             	cmp    $0xf,%eax
  801327:	7f 0b                	jg     801334 <vprintfmt+0x145>
  801329:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  801330:	85 d2                	test   %edx,%edx
  801332:	75 1b                	jne    80134f <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801334:	50                   	push   %eax
  801335:	68 c7 1f 80 00       	push   $0x801fc7
  80133a:	53                   	push   %ebx
  80133b:	56                   	push   %esi
  80133c:	e8 91 fe ff ff       	call   8011d2 <printfmt>
  801341:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801344:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80134a:	e9 c6 fe ff ff       	jmp    801215 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80134f:	52                   	push   %edx
  801350:	68 52 1f 80 00       	push   $0x801f52
  801355:	53                   	push   %ebx
  801356:	56                   	push   %esi
  801357:	e8 76 fe ff ff       	call   8011d2 <printfmt>
  80135c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801365:	e9 ab fe ff ff       	jmp    801215 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80136a:	8b 45 14             	mov    0x14(%ebp),%eax
  80136d:	83 c0 04             	add    $0x4,%eax
  801370:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801373:	8b 45 14             	mov    0x14(%ebp),%eax
  801376:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801378:	85 ff                	test   %edi,%edi
  80137a:	b8 c0 1f 80 00       	mov    $0x801fc0,%eax
  80137f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801382:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801386:	0f 8e 94 00 00 00    	jle    801420 <vprintfmt+0x231>
  80138c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801390:	0f 84 98 00 00 00    	je     80142e <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	ff 75 d0             	pushl  -0x30(%ebp)
  80139c:	57                   	push   %edi
  80139d:	e8 5b 03 00 00       	call   8016fd <strnlen>
  8013a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013a5:	29 c1                	sub    %eax,%ecx
  8013a7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013aa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013ad:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013b7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b9:	eb 0f                	jmp    8013ca <vprintfmt+0x1db>
					putch(padc, putdat);
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	53                   	push   %ebx
  8013bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8013c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c4:	83 ef 01             	sub    $0x1,%edi
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 ff                	test   %edi,%edi
  8013cc:	7f ed                	jg     8013bb <vprintfmt+0x1cc>
  8013ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013d1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013d4:	85 c9                	test   %ecx,%ecx
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013db:	0f 49 c1             	cmovns %ecx,%eax
  8013de:	29 c1                	sub    %eax,%ecx
  8013e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8013e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e9:	89 cb                	mov    %ecx,%ebx
  8013eb:	eb 4d                	jmp    80143a <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f1:	74 1b                	je     80140e <vprintfmt+0x21f>
  8013f3:	0f be c0             	movsbl %al,%eax
  8013f6:	83 e8 20             	sub    $0x20,%eax
  8013f9:	83 f8 5e             	cmp    $0x5e,%eax
  8013fc:	76 10                	jbe    80140e <vprintfmt+0x21f>
					putch('?', putdat);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	6a 3f                	push   $0x3f
  801406:	ff 55 08             	call   *0x8(%ebp)
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	eb 0d                	jmp    80141b <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	ff 75 0c             	pushl  0xc(%ebp)
  801414:	52                   	push   %edx
  801415:	ff 55 08             	call   *0x8(%ebp)
  801418:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80141b:	83 eb 01             	sub    $0x1,%ebx
  80141e:	eb 1a                	jmp    80143a <vprintfmt+0x24b>
  801420:	89 75 08             	mov    %esi,0x8(%ebp)
  801423:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801426:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801429:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80142c:	eb 0c                	jmp    80143a <vprintfmt+0x24b>
  80142e:	89 75 08             	mov    %esi,0x8(%ebp)
  801431:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801434:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801437:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80143a:	83 c7 01             	add    $0x1,%edi
  80143d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801441:	0f be d0             	movsbl %al,%edx
  801444:	85 d2                	test   %edx,%edx
  801446:	74 23                	je     80146b <vprintfmt+0x27c>
  801448:	85 f6                	test   %esi,%esi
  80144a:	78 a1                	js     8013ed <vprintfmt+0x1fe>
  80144c:	83 ee 01             	sub    $0x1,%esi
  80144f:	79 9c                	jns    8013ed <vprintfmt+0x1fe>
  801451:	89 df                	mov    %ebx,%edi
  801453:	8b 75 08             	mov    0x8(%ebp),%esi
  801456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801459:	eb 18                	jmp    801473 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	53                   	push   %ebx
  80145f:	6a 20                	push   $0x20
  801461:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801463:	83 ef 01             	sub    $0x1,%edi
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	eb 08                	jmp    801473 <vprintfmt+0x284>
  80146b:	89 df                	mov    %ebx,%edi
  80146d:	8b 75 08             	mov    0x8(%ebp),%esi
  801470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801473:	85 ff                	test   %edi,%edi
  801475:	7f e4                	jg     80145b <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801477:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80147a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80147d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801480:	e9 90 fd ff ff       	jmp    801215 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801485:	83 f9 01             	cmp    $0x1,%ecx
  801488:	7e 19                	jle    8014a3 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80148a:	8b 45 14             	mov    0x14(%ebp),%eax
  80148d:	8b 50 04             	mov    0x4(%eax),%edx
  801490:	8b 00                	mov    (%eax),%eax
  801492:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801495:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801498:	8b 45 14             	mov    0x14(%ebp),%eax
  80149b:	8d 40 08             	lea    0x8(%eax),%eax
  80149e:	89 45 14             	mov    %eax,0x14(%ebp)
  8014a1:	eb 38                	jmp    8014db <vprintfmt+0x2ec>
	else if (lflag)
  8014a3:	85 c9                	test   %ecx,%ecx
  8014a5:	74 1b                	je     8014c2 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014aa:	8b 00                	mov    (%eax),%eax
  8014ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014af:	89 c1                	mov    %eax,%ecx
  8014b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ba:	8d 40 04             	lea    0x4(%eax),%eax
  8014bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c0:	eb 19                	jmp    8014db <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c5:	8b 00                	mov    (%eax),%eax
  8014c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ca:	89 c1                	mov    %eax,%ecx
  8014cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d5:	8d 40 04             	lea    0x4(%eax),%eax
  8014d8:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014de:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014e1:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014ea:	0f 89 36 01 00 00    	jns    801626 <vprintfmt+0x437>
				putch('-', putdat);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	53                   	push   %ebx
  8014f4:	6a 2d                	push   $0x2d
  8014f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8014f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014fe:	f7 da                	neg    %edx
  801500:	83 d1 00             	adc    $0x0,%ecx
  801503:	f7 d9                	neg    %ecx
  801505:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801508:	b8 0a 00 00 00       	mov    $0xa,%eax
  80150d:	e9 14 01 00 00       	jmp    801626 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801512:	83 f9 01             	cmp    $0x1,%ecx
  801515:	7e 18                	jle    80152f <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801517:	8b 45 14             	mov    0x14(%ebp),%eax
  80151a:	8b 10                	mov    (%eax),%edx
  80151c:	8b 48 04             	mov    0x4(%eax),%ecx
  80151f:	8d 40 08             	lea    0x8(%eax),%eax
  801522:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801525:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152a:	e9 f7 00 00 00       	jmp    801626 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80152f:	85 c9                	test   %ecx,%ecx
  801531:	74 1a                	je     80154d <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801533:	8b 45 14             	mov    0x14(%ebp),%eax
  801536:	8b 10                	mov    (%eax),%edx
  801538:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153d:	8d 40 04             	lea    0x4(%eax),%eax
  801540:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801543:	b8 0a 00 00 00       	mov    $0xa,%eax
  801548:	e9 d9 00 00 00       	jmp    801626 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80154d:	8b 45 14             	mov    0x14(%ebp),%eax
  801550:	8b 10                	mov    (%eax),%edx
  801552:	b9 00 00 00 00       	mov    $0x0,%ecx
  801557:	8d 40 04             	lea    0x4(%eax),%eax
  80155a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80155d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801562:	e9 bf 00 00 00       	jmp    801626 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801567:	83 f9 01             	cmp    $0x1,%ecx
  80156a:	7e 13                	jle    80157f <vprintfmt+0x390>
		return va_arg(*ap, long long);
  80156c:	8b 45 14             	mov    0x14(%ebp),%eax
  80156f:	8b 50 04             	mov    0x4(%eax),%edx
  801572:	8b 00                	mov    (%eax),%eax
  801574:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801577:	8d 49 08             	lea    0x8(%ecx),%ecx
  80157a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80157d:	eb 28                	jmp    8015a7 <vprintfmt+0x3b8>
	else if (lflag)
  80157f:	85 c9                	test   %ecx,%ecx
  801581:	74 13                	je     801596 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  801583:	8b 45 14             	mov    0x14(%ebp),%eax
  801586:	8b 10                	mov    (%eax),%edx
  801588:	89 d0                	mov    %edx,%eax
  80158a:	99                   	cltd   
  80158b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80158e:	8d 49 04             	lea    0x4(%ecx),%ecx
  801591:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801594:	eb 11                	jmp    8015a7 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  801596:	8b 45 14             	mov    0x14(%ebp),%eax
  801599:	8b 10                	mov    (%eax),%edx
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	99                   	cltd   
  80159e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015a1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015a4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8015a7:	89 d1                	mov    %edx,%ecx
  8015a9:	89 c2                	mov    %eax,%edx
			base = 8;
  8015ab:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015b0:	eb 74                	jmp    801626 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	6a 30                	push   $0x30
  8015b8:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	53                   	push   %ebx
  8015be:	6a 78                	push   $0x78
  8015c0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c5:	8b 10                	mov    (%eax),%edx
  8015c7:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015cc:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cf:	8d 40 04             	lea    0x4(%eax),%eax
  8015d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015da:	eb 4a                	jmp    801626 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015dc:	83 f9 01             	cmp    $0x1,%ecx
  8015df:	7e 15                	jle    8015f6 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8015e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e4:	8b 10                	mov    (%eax),%edx
  8015e6:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e9:	8d 40 08             	lea    0x8(%eax),%eax
  8015ec:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015ef:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f4:	eb 30                	jmp    801626 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015f6:	85 c9                	test   %ecx,%ecx
  8015f8:	74 17                	je     801611 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8015fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fd:	8b 10                	mov    (%eax),%edx
  8015ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801604:	8d 40 04             	lea    0x4(%eax),%eax
  801607:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80160a:	b8 10 00 00 00       	mov    $0x10,%eax
  80160f:	eb 15                	jmp    801626 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801611:	8b 45 14             	mov    0x14(%ebp),%eax
  801614:	8b 10                	mov    (%eax),%edx
  801616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161b:	8d 40 04             	lea    0x4(%eax),%eax
  80161e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801621:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80162d:	57                   	push   %edi
  80162e:	ff 75 e0             	pushl  -0x20(%ebp)
  801631:	50                   	push   %eax
  801632:	51                   	push   %ecx
  801633:	52                   	push   %edx
  801634:	89 da                	mov    %ebx,%edx
  801636:	89 f0                	mov    %esi,%eax
  801638:	e8 c9 fa ff ff       	call   801106 <printnum>
			break;
  80163d:	83 c4 20             	add    $0x20,%esp
  801640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801643:	e9 cd fb ff ff       	jmp    801215 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	53                   	push   %ebx
  80164c:	52                   	push   %edx
  80164d:	ff d6                	call   *%esi
			break;
  80164f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801655:	e9 bb fb ff ff       	jmp    801215 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	53                   	push   %ebx
  80165e:	6a 25                	push   $0x25
  801660:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 03                	jmp    80166a <vprintfmt+0x47b>
  801667:	83 ef 01             	sub    $0x1,%edi
  80166a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80166e:	75 f7                	jne    801667 <vprintfmt+0x478>
  801670:	e9 a0 fb ff ff       	jmp    801215 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5f                   	pop    %edi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 18             	sub    $0x18,%esp
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80168c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801690:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801693:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80169a:	85 c0                	test   %eax,%eax
  80169c:	74 26                	je     8016c4 <vsnprintf+0x47>
  80169e:	85 d2                	test   %edx,%edx
  8016a0:	7e 22                	jle    8016c4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016a2:	ff 75 14             	pushl  0x14(%ebp)
  8016a5:	ff 75 10             	pushl  0x10(%ebp)
  8016a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	68 b5 11 80 00       	push   $0x8011b5
  8016b1:	e8 39 fb ff ff       	call   8011ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb 05                	jmp    8016c9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d4:	50                   	push   %eax
  8016d5:	ff 75 10             	pushl  0x10(%ebp)
  8016d8:	ff 75 0c             	pushl  0xc(%ebp)
  8016db:	ff 75 08             	pushl  0x8(%ebp)
  8016de:	e8 9a ff ff ff       	call   80167d <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f0:	eb 03                	jmp    8016f5 <strlen+0x10>
		n++;
  8016f2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f9:	75 f7                	jne    8016f2 <strlen+0xd>
		n++;
	return n;
}
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	eb 03                	jmp    801710 <strnlen+0x13>
		n++;
  80170d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801710:	39 c2                	cmp    %eax,%edx
  801712:	74 08                	je     80171c <strnlen+0x1f>
  801714:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801718:	75 f3                	jne    80170d <strnlen+0x10>
  80171a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	53                   	push   %ebx
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801728:	89 c2                	mov    %eax,%edx
  80172a:	83 c2 01             	add    $0x1,%edx
  80172d:	83 c1 01             	add    $0x1,%ecx
  801730:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801734:	88 5a ff             	mov    %bl,-0x1(%edx)
  801737:	84 db                	test   %bl,%bl
  801739:	75 ef                	jne    80172a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80173b:	5b                   	pop    %ebx
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801745:	53                   	push   %ebx
  801746:	e8 9a ff ff ff       	call   8016e5 <strlen>
  80174b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	01 d8                	add    %ebx,%eax
  801753:	50                   	push   %eax
  801754:	e8 c5 ff ff ff       	call   80171e <strcpy>
	return dst;
}
  801759:	89 d8                	mov    %ebx,%eax
  80175b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	8b 75 08             	mov    0x8(%ebp),%esi
  801768:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176b:	89 f3                	mov    %esi,%ebx
  80176d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801770:	89 f2                	mov    %esi,%edx
  801772:	eb 0f                	jmp    801783 <strncpy+0x23>
		*dst++ = *src;
  801774:	83 c2 01             	add    $0x1,%edx
  801777:	0f b6 01             	movzbl (%ecx),%eax
  80177a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80177d:	80 39 01             	cmpb   $0x1,(%ecx)
  801780:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801783:	39 da                	cmp    %ebx,%edx
  801785:	75 ed                	jne    801774 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801787:	89 f0                	mov    %esi,%eax
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
  801792:	8b 75 08             	mov    0x8(%ebp),%esi
  801795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801798:	8b 55 10             	mov    0x10(%ebp),%edx
  80179b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80179d:	85 d2                	test   %edx,%edx
  80179f:	74 21                	je     8017c2 <strlcpy+0x35>
  8017a1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017a5:	89 f2                	mov    %esi,%edx
  8017a7:	eb 09                	jmp    8017b2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a9:	83 c2 01             	add    $0x1,%edx
  8017ac:	83 c1 01             	add    $0x1,%ecx
  8017af:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017b2:	39 c2                	cmp    %eax,%edx
  8017b4:	74 09                	je     8017bf <strlcpy+0x32>
  8017b6:	0f b6 19             	movzbl (%ecx),%ebx
  8017b9:	84 db                	test   %bl,%bl
  8017bb:	75 ec                	jne    8017a9 <strlcpy+0x1c>
  8017bd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017bf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c2:	29 f0                	sub    %esi,%eax
}
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d1:	eb 06                	jmp    8017d9 <strcmp+0x11>
		p++, q++;
  8017d3:	83 c1 01             	add    $0x1,%ecx
  8017d6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d9:	0f b6 01             	movzbl (%ecx),%eax
  8017dc:	84 c0                	test   %al,%al
  8017de:	74 04                	je     8017e4 <strcmp+0x1c>
  8017e0:	3a 02                	cmp    (%edx),%al
  8017e2:	74 ef                	je     8017d3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e4:	0f b6 c0             	movzbl %al,%eax
  8017e7:	0f b6 12             	movzbl (%edx),%edx
  8017ea:	29 d0                	sub    %edx,%eax
}
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017fd:	eb 06                	jmp    801805 <strncmp+0x17>
		n--, p++, q++;
  8017ff:	83 c0 01             	add    $0x1,%eax
  801802:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801805:	39 d8                	cmp    %ebx,%eax
  801807:	74 15                	je     80181e <strncmp+0x30>
  801809:	0f b6 08             	movzbl (%eax),%ecx
  80180c:	84 c9                	test   %cl,%cl
  80180e:	74 04                	je     801814 <strncmp+0x26>
  801810:	3a 0a                	cmp    (%edx),%cl
  801812:	74 eb                	je     8017ff <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801814:	0f b6 00             	movzbl (%eax),%eax
  801817:	0f b6 12             	movzbl (%edx),%edx
  80181a:	29 d0                	sub    %edx,%eax
  80181c:	eb 05                	jmp    801823 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80181e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801823:	5b                   	pop    %ebx
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801830:	eb 07                	jmp    801839 <strchr+0x13>
		if (*s == c)
  801832:	38 ca                	cmp    %cl,%dl
  801834:	74 0f                	je     801845 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801836:	83 c0 01             	add    $0x1,%eax
  801839:	0f b6 10             	movzbl (%eax),%edx
  80183c:	84 d2                	test   %dl,%dl
  80183e:	75 f2                	jne    801832 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801840:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801851:	eb 03                	jmp    801856 <strfind+0xf>
  801853:	83 c0 01             	add    $0x1,%eax
  801856:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801859:	38 ca                	cmp    %cl,%dl
  80185b:	74 04                	je     801861 <strfind+0x1a>
  80185d:	84 d2                	test   %dl,%dl
  80185f:	75 f2                	jne    801853 <strfind+0xc>
			break;
	return (char *) s;
}
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	57                   	push   %edi
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80186f:	85 c9                	test   %ecx,%ecx
  801871:	74 36                	je     8018a9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801873:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801879:	75 28                	jne    8018a3 <memset+0x40>
  80187b:	f6 c1 03             	test   $0x3,%cl
  80187e:	75 23                	jne    8018a3 <memset+0x40>
		c &= 0xFF;
  801880:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801884:	89 d3                	mov    %edx,%ebx
  801886:	c1 e3 08             	shl    $0x8,%ebx
  801889:	89 d6                	mov    %edx,%esi
  80188b:	c1 e6 18             	shl    $0x18,%esi
  80188e:	89 d0                	mov    %edx,%eax
  801890:	c1 e0 10             	shl    $0x10,%eax
  801893:	09 f0                	or     %esi,%eax
  801895:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801897:	89 d8                	mov    %ebx,%eax
  801899:	09 d0                	or     %edx,%eax
  80189b:	c1 e9 02             	shr    $0x2,%ecx
  80189e:	fc                   	cld    
  80189f:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a1:	eb 06                	jmp    8018a9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	fc                   	cld    
  8018a7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a9:	89 f8                	mov    %edi,%eax
  8018ab:	5b                   	pop    %ebx
  8018ac:	5e                   	pop    %esi
  8018ad:	5f                   	pop    %edi
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018be:	39 c6                	cmp    %eax,%esi
  8018c0:	73 35                	jae    8018f7 <memmove+0x47>
  8018c2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c5:	39 d0                	cmp    %edx,%eax
  8018c7:	73 2e                	jae    8018f7 <memmove+0x47>
		s += n;
		d += n;
  8018c9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018cc:	89 d6                	mov    %edx,%esi
  8018ce:	09 fe                	or     %edi,%esi
  8018d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d6:	75 13                	jne    8018eb <memmove+0x3b>
  8018d8:	f6 c1 03             	test   $0x3,%cl
  8018db:	75 0e                	jne    8018eb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018dd:	83 ef 04             	sub    $0x4,%edi
  8018e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e3:	c1 e9 02             	shr    $0x2,%ecx
  8018e6:	fd                   	std    
  8018e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e9:	eb 09                	jmp    8018f4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018eb:	83 ef 01             	sub    $0x1,%edi
  8018ee:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018f1:	fd                   	std    
  8018f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f4:	fc                   	cld    
  8018f5:	eb 1d                	jmp    801914 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f7:	89 f2                	mov    %esi,%edx
  8018f9:	09 c2                	or     %eax,%edx
  8018fb:	f6 c2 03             	test   $0x3,%dl
  8018fe:	75 0f                	jne    80190f <memmove+0x5f>
  801900:	f6 c1 03             	test   $0x3,%cl
  801903:	75 0a                	jne    80190f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801905:	c1 e9 02             	shr    $0x2,%ecx
  801908:	89 c7                	mov    %eax,%edi
  80190a:	fc                   	cld    
  80190b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190d:	eb 05                	jmp    801914 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190f:	89 c7                	mov    %eax,%edi
  801911:	fc                   	cld    
  801912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80191b:	ff 75 10             	pushl  0x10(%ebp)
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	ff 75 08             	pushl  0x8(%ebp)
  801924:	e8 87 ff ff ff       	call   8018b0 <memmove>
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	8b 55 0c             	mov    0xc(%ebp),%edx
  801936:	89 c6                	mov    %eax,%esi
  801938:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193b:	eb 1a                	jmp    801957 <memcmp+0x2c>
		if (*s1 != *s2)
  80193d:	0f b6 08             	movzbl (%eax),%ecx
  801940:	0f b6 1a             	movzbl (%edx),%ebx
  801943:	38 d9                	cmp    %bl,%cl
  801945:	74 0a                	je     801951 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801947:	0f b6 c1             	movzbl %cl,%eax
  80194a:	0f b6 db             	movzbl %bl,%ebx
  80194d:	29 d8                	sub    %ebx,%eax
  80194f:	eb 0f                	jmp    801960 <memcmp+0x35>
		s1++, s2++;
  801951:	83 c0 01             	add    $0x1,%eax
  801954:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801957:	39 f0                	cmp    %esi,%eax
  801959:	75 e2                	jne    80193d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80196b:	89 c1                	mov    %eax,%ecx
  80196d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801970:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801974:	eb 0a                	jmp    801980 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801976:	0f b6 10             	movzbl (%eax),%edx
  801979:	39 da                	cmp    %ebx,%edx
  80197b:	74 07                	je     801984 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197d:	83 c0 01             	add    $0x1,%eax
  801980:	39 c8                	cmp    %ecx,%eax
  801982:	72 f2                	jb     801976 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801984:	5b                   	pop    %ebx
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	57                   	push   %edi
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801990:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801993:	eb 03                	jmp    801998 <strtol+0x11>
		s++;
  801995:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801998:	0f b6 01             	movzbl (%ecx),%eax
  80199b:	3c 20                	cmp    $0x20,%al
  80199d:	74 f6                	je     801995 <strtol+0xe>
  80199f:	3c 09                	cmp    $0x9,%al
  8019a1:	74 f2                	je     801995 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a3:	3c 2b                	cmp    $0x2b,%al
  8019a5:	75 0a                	jne    8019b1 <strtol+0x2a>
		s++;
  8019a7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8019af:	eb 11                	jmp    8019c2 <strtol+0x3b>
  8019b1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b6:	3c 2d                	cmp    $0x2d,%al
  8019b8:	75 08                	jne    8019c2 <strtol+0x3b>
		s++, neg = 1;
  8019ba:	83 c1 01             	add    $0x1,%ecx
  8019bd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c8:	75 15                	jne    8019df <strtol+0x58>
  8019ca:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cd:	75 10                	jne    8019df <strtol+0x58>
  8019cf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d3:	75 7c                	jne    801a51 <strtol+0xca>
		s += 2, base = 16;
  8019d5:	83 c1 02             	add    $0x2,%ecx
  8019d8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019dd:	eb 16                	jmp    8019f5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019df:	85 db                	test   %ebx,%ebx
  8019e1:	75 12                	jne    8019f5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019e3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019eb:	75 08                	jne    8019f5 <strtol+0x6e>
		s++, base = 8;
  8019ed:	83 c1 01             	add    $0x1,%ecx
  8019f0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019fd:	0f b6 11             	movzbl (%ecx),%edx
  801a00:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a03:	89 f3                	mov    %esi,%ebx
  801a05:	80 fb 09             	cmp    $0x9,%bl
  801a08:	77 08                	ja     801a12 <strtol+0x8b>
			dig = *s - '0';
  801a0a:	0f be d2             	movsbl %dl,%edx
  801a0d:	83 ea 30             	sub    $0x30,%edx
  801a10:	eb 22                	jmp    801a34 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a12:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a15:	89 f3                	mov    %esi,%ebx
  801a17:	80 fb 19             	cmp    $0x19,%bl
  801a1a:	77 08                	ja     801a24 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a1c:	0f be d2             	movsbl %dl,%edx
  801a1f:	83 ea 57             	sub    $0x57,%edx
  801a22:	eb 10                	jmp    801a34 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a24:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a27:	89 f3                	mov    %esi,%ebx
  801a29:	80 fb 19             	cmp    $0x19,%bl
  801a2c:	77 16                	ja     801a44 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a2e:	0f be d2             	movsbl %dl,%edx
  801a31:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a34:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a37:	7d 0b                	jge    801a44 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a39:	83 c1 01             	add    $0x1,%ecx
  801a3c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a40:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a42:	eb b9                	jmp    8019fd <strtol+0x76>

	if (endptr)
  801a44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a48:	74 0d                	je     801a57 <strtol+0xd0>
		*endptr = (char *) s;
  801a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4d:	89 0e                	mov    %ecx,(%esi)
  801a4f:	eb 06                	jmp    801a57 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a51:	85 db                	test   %ebx,%ebx
  801a53:	74 98                	je     8019ed <strtol+0x66>
  801a55:	eb 9e                	jmp    8019f5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	f7 da                	neg    %edx
  801a5b:	85 ff                	test   %edi,%edi
  801a5d:	0f 45 c2             	cmovne %edx,%eax
}
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5f                   	pop    %edi
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a73:	85 c0                	test   %eax,%eax
  801a75:	74 0e                	je     801a85 <ipc_recv+0x20>
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	50                   	push   %eax
  801a7b:	e8 9a e8 ff ff       	call   80031a <sys_ipc_recv>
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	eb 10                	jmp    801a95 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	68 00 00 c0 ee       	push   $0xeec00000
  801a8d:	e8 88 e8 ff ff       	call   80031a <sys_ipc_recv>
  801a92:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801a95:	85 c0                	test   %eax,%eax
  801a97:	74 16                	je     801aaf <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801a99:	85 f6                	test   %esi,%esi
  801a9b:	74 06                	je     801aa3 <ipc_recv+0x3e>
  801a9d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801aa3:	85 db                	test   %ebx,%ebx
  801aa5:	74 2c                	je     801ad3 <ipc_recv+0x6e>
  801aa7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aad:	eb 24                	jmp    801ad3 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801aaf:	85 f6                	test   %esi,%esi
  801ab1:	74 0a                	je     801abd <ipc_recv+0x58>
  801ab3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab8:	8b 40 74             	mov    0x74(%eax),%eax
  801abb:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801abd:	85 db                	test   %ebx,%ebx
  801abf:	74 0a                	je     801acb <ipc_recv+0x66>
  801ac1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac6:	8b 40 78             	mov    0x78(%eax),%eax
  801ac9:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801acb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ad3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	57                   	push   %edi
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aec:	85 c0                	test   %eax,%eax
  801aee:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801af3:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801af6:	ff 75 14             	pushl  0x14(%ebp)
  801af9:	53                   	push   %ebx
  801afa:	56                   	push   %esi
  801afb:	57                   	push   %edi
  801afc:	e8 f6 e7 ff ff       	call   8002f7 <sys_ipc_try_send>
		if (ret == 0) break;
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	74 1e                	je     801b26 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0b:	74 12                	je     801b1f <ipc_send+0x45>
  801b0d:	50                   	push   %eax
  801b0e:	68 c0 22 80 00       	push   $0x8022c0
  801b13:	6a 39                	push   $0x39
  801b15:	68 cd 22 80 00       	push   $0x8022cd
  801b1a:	e8 fa f4 ff ff       	call   801019 <_panic>
		sys_yield();
  801b1f:	e8 27 e6 ff ff       	call   80014b <sys_yield>
	}
  801b24:	eb d0                	jmp    801af6 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b39:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b3c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b42:	8b 52 50             	mov    0x50(%edx),%edx
  801b45:	39 ca                	cmp    %ecx,%edx
  801b47:	75 0d                	jne    801b56 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
  801b54:	eb 0f                	jmp    801b65 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b56:	83 c0 01             	add    $0x1,%eax
  801b59:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b5e:	75 d9                	jne    801b39 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6d:	89 d0                	mov    %edx,%eax
  801b6f:	c1 e8 16             	shr    $0x16,%eax
  801b72:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7e:	f6 c1 01             	test   $0x1,%cl
  801b81:	74 1d                	je     801ba0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b83:	c1 ea 0c             	shr    $0xc,%edx
  801b86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b8d:	f6 c2 01             	test   $0x1,%dl
  801b90:	74 0e                	je     801ba0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b92:	c1 ea 0c             	shr    $0xc,%edx
  801b95:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b9c:	ef 
  801b9d:	0f b7 c0             	movzwl %ax,%eax
}
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    
  801ba2:	66 90                	xchg   %ax,%ax
  801ba4:	66 90                	xchg   %ax,%ax
  801ba6:	66 90                	xchg   %ax,%ax
  801ba8:	66 90                	xchg   %ax,%ax
  801baa:	66 90                	xchg   %ax,%ax
  801bac:	66 90                	xchg   %ax,%ax
  801bae:	66 90                	xchg   %ax,%ax

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bc7:	85 f6                	test   %esi,%esi
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 ca                	mov    %ecx,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	75 3d                	jne    801c10 <__udivdi3+0x60>
  801bd3:	39 cf                	cmp    %ecx,%edi
  801bd5:	0f 87 c5 00 00 00    	ja     801ca0 <__udivdi3+0xf0>
  801bdb:	85 ff                	test   %edi,%edi
  801bdd:	89 fd                	mov    %edi,%ebp
  801bdf:	75 0b                	jne    801bec <__udivdi3+0x3c>
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	31 d2                	xor    %edx,%edx
  801be8:	f7 f7                	div    %edi
  801bea:	89 c5                	mov    %eax,%ebp
  801bec:	89 c8                	mov    %ecx,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f5                	div    %ebp
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	89 cf                	mov    %ecx,%edi
  801bf8:	f7 f5                	div    %ebp
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 ce                	cmp    %ecx,%esi
  801c12:	77 74                	ja     801c88 <__udivdi3+0xd8>
  801c14:	0f bd fe             	bsr    %esi,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0x108>
  801c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 c5                	mov    %eax,%ebp
  801c29:	29 fb                	sub    %edi,%ebx
  801c2b:	d3 e6                	shl    %cl,%esi
  801c2d:	89 d9                	mov    %ebx,%ecx
  801c2f:	d3 ed                	shr    %cl,%ebp
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e0                	shl    %cl,%eax
  801c35:	09 ee                	or     %ebp,%esi
  801c37:	89 d9                	mov    %ebx,%ecx
  801c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c3d:	89 d5                	mov    %edx,%ebp
  801c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c43:	d3 ed                	shr    %cl,%ebp
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 d9                	mov    %ebx,%ecx
  801c4b:	d3 e8                	shr    %cl,%eax
  801c4d:	09 c2                	or     %eax,%edx
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	89 ea                	mov    %ebp,%edx
  801c53:	f7 f6                	div    %esi
  801c55:	89 d5                	mov    %edx,%ebp
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	f7 64 24 0c          	mull   0xc(%esp)
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	72 10                	jb     801c71 <__udivdi3+0xc1>
  801c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e6                	shl    %cl,%esi
  801c69:	39 c6                	cmp    %eax,%esi
  801c6b:	73 07                	jae    801c74 <__udivdi3+0xc4>
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	75 03                	jne    801c74 <__udivdi3+0xc4>
  801c71:	83 eb 01             	sub    $0x1,%ebx
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	31 ff                	xor    %edi,%edi
  801c8a:	31 db                	xor    %ebx,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	f7 f7                	div    %edi
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	89 fa                	mov    %edi,%edx
  801cac:	83 c4 1c             	add    $0x1c,%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 ce                	cmp    %ecx,%esi
  801cba:	72 0c                	jb     801cc8 <__udivdi3+0x118>
  801cbc:	31 db                	xor    %ebx,%ebx
  801cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cc2:	0f 87 34 ff ff ff    	ja     801bfc <__udivdi3+0x4c>
  801cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ccd:	e9 2a ff ff ff       	jmp    801bfc <__udivdi3+0x4c>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f3                	mov    %esi,%ebx
  801d03:	89 3c 24             	mov    %edi,(%esp)
  801d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0a:	75 1c                	jne    801d28 <__umoddi3+0x48>
  801d0c:	39 f7                	cmp    %esi,%edi
  801d0e:	76 50                	jbe    801d60 <__umoddi3+0x80>
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	f7 f7                	div    %edi
  801d16:	89 d0                	mov    %edx,%eax
  801d18:	31 d2                	xor    %edx,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	77 52                	ja     801d80 <__umoddi3+0xa0>
  801d2e:	0f bd ea             	bsr    %edx,%ebp
  801d31:	83 f5 1f             	xor    $0x1f,%ebp
  801d34:	75 5a                	jne    801d90 <__umoddi3+0xb0>
  801d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d3a:	0f 82 e0 00 00 00    	jb     801e20 <__umoddi3+0x140>
  801d40:	39 0c 24             	cmp    %ecx,(%esp)
  801d43:	0f 86 d7 00 00 00    	jbe    801e20 <__umoddi3+0x140>
  801d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d51:	83 c4 1c             	add    $0x1c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	85 ff                	test   %edi,%edi
  801d62:	89 fd                	mov    %edi,%ebp
  801d64:	75 0b                	jne    801d71 <__umoddi3+0x91>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f7                	div    %edi
  801d6f:	89 c5                	mov    %eax,%ebp
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f5                	div    %ebp
  801d77:	89 c8                	mov    %ecx,%eax
  801d79:	f7 f5                	div    %ebp
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	eb 99                	jmp    801d18 <__umoddi3+0x38>
  801d7f:	90                   	nop
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	8b 34 24             	mov    (%esp),%esi
  801d93:	bf 20 00 00 00       	mov    $0x20,%edi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	29 ef                	sub    %ebp,%edi
  801d9c:	d3 e0                	shl    %cl,%eax
  801d9e:	89 f9                	mov    %edi,%ecx
  801da0:	89 f2                	mov    %esi,%edx
  801da2:	d3 ea                	shr    %cl,%edx
  801da4:	89 e9                	mov    %ebp,%ecx
  801da6:	09 c2                	or     %eax,%edx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	d3 e3                	shl    %cl,%ebx
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	09 d8                	or     %ebx,%eax
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 34 24             	divl   (%esp)
  801dd4:	89 d6                	mov    %edx,%esi
  801dd6:	d3 e3                	shl    %cl,%ebx
  801dd8:	f7 64 24 04          	mull   0x4(%esp)
  801ddc:	39 d6                	cmp    %edx,%esi
  801dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	72 08                	jb     801df0 <__umoddi3+0x110>
  801de8:	75 11                	jne    801dfb <__umoddi3+0x11b>
  801dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dee:	73 0b                	jae    801dfb <__umoddi3+0x11b>
  801df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801df4:	1b 14 24             	sbb    (%esp),%edx
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dff:	29 da                	sub    %ebx,%edx
  801e01:	19 ce                	sbb    %ecx,%esi
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	d3 e0                	shl    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 ea                	shr    %cl,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 ee                	shr    %cl,%esi
  801e11:	09 d0                	or     %edx,%eax
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	29 f9                	sub    %edi,%ecx
  801e22:	19 d6                	sbb    %edx,%esi
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	e9 18 ff ff ff       	jmp    801d49 <__umoddi3+0x69>
