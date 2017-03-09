
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 40 	movl   $0x801e40,0x803000
  800040:	1e 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 87 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 4f 1e 80 00       	push   $0x801e4f
  800114:	6a 23                	push   $0x23
  800116:	68 6c 1e 80 00       	push   $0x801e6c
  80011b:	e8 f5 0e 00 00       	call   801015 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 4f 1e 80 00       	push   $0x801e4f
  800195:	6a 23                	push   $0x23
  800197:	68 6c 1e 80 00       	push   $0x801e6c
  80019c:	e8 74 0e 00 00       	call   801015 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 4f 1e 80 00       	push   $0x801e4f
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 6c 1e 80 00       	push   $0x801e6c
  8001de:	e8 32 0e 00 00       	call   801015 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 4f 1e 80 00       	push   $0x801e4f
  800219:	6a 23                	push   $0x23
  80021b:	68 6c 1e 80 00       	push   $0x801e6c
  800220:	e8 f0 0d 00 00       	call   801015 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 4f 1e 80 00       	push   $0x801e4f
  80025b:	6a 23                	push   $0x23
  80025d:	68 6c 1e 80 00       	push   $0x801e6c
  800262:	e8 ae 0d 00 00       	call   801015 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 4f 1e 80 00       	push   $0x801e4f
  80029d:	6a 23                	push   $0x23
  80029f:	68 6c 1e 80 00       	push   $0x801e6c
  8002a4:	e8 6c 0d 00 00       	call   801015 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 4f 1e 80 00       	push   $0x801e4f
  8002df:	6a 23                	push   $0x23
  8002e1:	68 6c 1e 80 00       	push   $0x801e6c
  8002e6:	e8 2a 0d 00 00       	call   801015 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 4f 1e 80 00       	push   $0x801e4f
  800343:	6a 23                	push   $0x23
  800345:	68 6c 1e 80 00       	push   $0x801e6c
  80034a:	e8 c6 0c 00 00       	call   801015 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba f8 1e 80 00       	mov    $0x801ef8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 7c 1e 80 00       	push   $0x801e7c
  80045e:	e8 8b 0c 00 00       	call   8010ee <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 bd 1e 80 00       	push   $0x801ebd
  800688:	e8 61 0a 00 00       	call   8010ee <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 d9 1e 80 00       	push   $0x801ed9
  80075d:	e8 8c 09 00 00       	call   8010ee <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 9c 1e 80 00       	push   $0x801e9c
  800812:	e8 d7 08 00 00       	call   8010ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 b7 01 00 00       	call   800a92 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 08 12 00 00       	call   801b2a <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 99 11 00 00       	call   801ad6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 17 11 00 00       	call   801a61 <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 47 0d 00 00       	call   80171a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009fc:	68 08 1f 80 00       	push   $0x801f08
  800a01:	68 90 00 00 00       	push   $0x90
  800a06:	68 26 1f 80 00       	push   $0x801f26
  800a0b:	e8 05 06 00 00       	call   801015 <_panic>

00800a10 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a23:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a33:	e8 ce fe ff ff       	call   800906 <fsipc>
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 4b                	js     800a89 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a3e:	39 c6                	cmp    %eax,%esi
  800a40:	73 16                	jae    800a58 <devfile_read+0x48>
  800a42:	68 31 1f 80 00       	push   $0x801f31
  800a47:	68 38 1f 80 00       	push   $0x801f38
  800a4c:	6a 7c                	push   $0x7c
  800a4e:	68 26 1f 80 00       	push   $0x801f26
  800a53:	e8 bd 05 00 00       	call   801015 <_panic>
	assert(r <= PGSIZE);
  800a58:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a5d:	7e 16                	jle    800a75 <devfile_read+0x65>
  800a5f:	68 4d 1f 80 00       	push   $0x801f4d
  800a64:	68 38 1f 80 00       	push   $0x801f38
  800a69:	6a 7d                	push   $0x7d
  800a6b:	68 26 1f 80 00       	push   $0x801f26
  800a70:	e8 a0 05 00 00       	call   801015 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a75:	83 ec 04             	sub    $0x4,%esp
  800a78:	50                   	push   %eax
  800a79:	68 00 50 80 00       	push   $0x805000
  800a7e:	ff 75 0c             	pushl  0xc(%ebp)
  800a81:	e8 26 0e 00 00       	call   8018ac <memmove>
	return r;
  800a86:	83 c4 10             	add    $0x10,%esp
}
  800a89:	89 d8                	mov    %ebx,%eax
  800a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	83 ec 20             	sub    $0x20,%esp
  800a99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a9c:	53                   	push   %ebx
  800a9d:	e8 3f 0c 00 00       	call   8016e1 <strlen>
  800aa2:	83 c4 10             	add    $0x10,%esp
  800aa5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aaa:	7f 67                	jg     800b13 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aac:	83 ec 0c             	sub    $0xc,%esp
  800aaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab2:	50                   	push   %eax
  800ab3:	e8 c6 f8 ff ff       	call   80037e <fd_alloc>
  800ab8:	83 c4 10             	add    $0x10,%esp
		return r;
  800abb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800abd:	85 c0                	test   %eax,%eax
  800abf:	78 57                	js     800b18 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ac1:	83 ec 08             	sub    $0x8,%esp
  800ac4:	53                   	push   %ebx
  800ac5:	68 00 50 80 00       	push   $0x805000
  800aca:	e8 4b 0c 00 00       	call   80171a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ada:	b8 01 00 00 00       	mov    $0x1,%eax
  800adf:	e8 22 fe ff ff       	call   800906 <fsipc>
  800ae4:	89 c3                	mov    %eax,%ebx
  800ae6:	83 c4 10             	add    $0x10,%esp
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	79 14                	jns    800b01 <open+0x6f>
		fd_close(fd, 0);
  800aed:	83 ec 08             	sub    $0x8,%esp
  800af0:	6a 00                	push   $0x0
  800af2:	ff 75 f4             	pushl  -0xc(%ebp)
  800af5:	e8 7c f9 ff ff       	call   800476 <fd_close>
		return r;
  800afa:	83 c4 10             	add    $0x10,%esp
  800afd:	89 da                	mov    %ebx,%edx
  800aff:	eb 17                	jmp    800b18 <open+0x86>
	}

	return fd2num(fd);
  800b01:	83 ec 0c             	sub    $0xc,%esp
  800b04:	ff 75 f4             	pushl  -0xc(%ebp)
  800b07:	e8 4b f8 ff ff       	call   800357 <fd2num>
  800b0c:	89 c2                	mov    %eax,%edx
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	eb 05                	jmp    800b18 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b13:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b18:	89 d0                	mov    %edx,%eax
  800b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b2f:	e8 d2 fd ff ff       	call   800906 <fsipc>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	e8 1e f8 ff ff       	call   800367 <fd2data>
  800b49:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4b:	83 c4 08             	add    $0x8,%esp
  800b4e:	68 59 1f 80 00       	push   $0x801f59
  800b53:	53                   	push   %ebx
  800b54:	e8 c1 0b 00 00       	call   80171a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b59:	8b 46 04             	mov    0x4(%esi),%eax
  800b5c:	2b 06                	sub    (%esi),%eax
  800b5e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b64:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6b:	00 00 00 
	stat->st_dev = &devpipe;
  800b6e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b75:	30 80 00 
	return 0;
}
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8e:	53                   	push   %ebx
  800b8f:	6a 00                	push   $0x0
  800b91:	e8 55 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b96:	89 1c 24             	mov    %ebx,(%esp)
  800b99:	e8 c9 f7 ff ff       	call   800367 <fd2data>
  800b9e:	83 c4 08             	add    $0x8,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 00                	push   $0x0
  800ba4:	e8 42 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 1c             	sub    $0x1c,%esp
  800bb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bba:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bbc:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bca:	e8 94 0f 00 00       	call   801b63 <pageref>
  800bcf:	89 c3                	mov    %eax,%ebx
  800bd1:	89 3c 24             	mov    %edi,(%esp)
  800bd4:	e8 8a 0f 00 00       	call   801b63 <pageref>
  800bd9:	83 c4 10             	add    $0x10,%esp
  800bdc:	39 c3                	cmp    %eax,%ebx
  800bde:	0f 94 c1             	sete   %cl
  800be1:	0f b6 c9             	movzbl %cl,%ecx
  800be4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800be7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bed:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf0:	39 ce                	cmp    %ecx,%esi
  800bf2:	74 1b                	je     800c0f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bf4:	39 c3                	cmp    %eax,%ebx
  800bf6:	75 c4                	jne    800bbc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf8:	8b 42 58             	mov    0x58(%edx),%eax
  800bfb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bfe:	50                   	push   %eax
  800bff:	56                   	push   %esi
  800c00:	68 60 1f 80 00       	push   $0x801f60
  800c05:	e8 e4 04 00 00       	call   8010ee <cprintf>
  800c0a:	83 c4 10             	add    $0x10,%esp
  800c0d:	eb ad                	jmp    800bbc <_pipeisclosed+0xe>
	}
}
  800c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 28             	sub    $0x28,%esp
  800c23:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c26:	56                   	push   %esi
  800c27:	e8 3b f7 ff ff       	call   800367 <fd2data>
  800c2c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	bf 00 00 00 00       	mov    $0x0,%edi
  800c36:	eb 4b                	jmp    800c83 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c38:	89 da                	mov    %ebx,%edx
  800c3a:	89 f0                	mov    %esi,%eax
  800c3c:	e8 6d ff ff ff       	call   800bae <_pipeisclosed>
  800c41:	85 c0                	test   %eax,%eax
  800c43:	75 48                	jne    800c8d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c45:	e8 fd f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c4d:	8b 0b                	mov    (%ebx),%ecx
  800c4f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c52:	39 d0                	cmp    %edx,%eax
  800c54:	73 e2                	jae    800c38 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c60:	89 c2                	mov    %eax,%edx
  800c62:	c1 fa 1f             	sar    $0x1f,%edx
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6d:	83 e2 1f             	and    $0x1f,%edx
  800c70:	29 ca                	sub    %ecx,%edx
  800c72:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c76:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c80:	83 c7 01             	add    $0x1,%edi
  800c83:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c86:	75 c2                	jne    800c4a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c88:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8b:	eb 05                	jmp    800c92 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 18             	sub    $0x18,%esp
  800ca3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ca6:	57                   	push   %edi
  800ca7:	e8 bb f6 ff ff       	call   800367 <fd2data>
  800cac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	eb 3d                	jmp    800cf5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cb8:	85 db                	test   %ebx,%ebx
  800cba:	74 04                	je     800cc0 <devpipe_read+0x26>
				return i;
  800cbc:	89 d8                	mov    %ebx,%eax
  800cbe:	eb 44                	jmp    800d04 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cc0:	89 f2                	mov    %esi,%edx
  800cc2:	89 f8                	mov    %edi,%eax
  800cc4:	e8 e5 fe ff ff       	call   800bae <_pipeisclosed>
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	75 32                	jne    800cff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ccd:	e8 75 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cd2:	8b 06                	mov    (%esi),%eax
  800cd4:	3b 46 04             	cmp    0x4(%esi),%eax
  800cd7:	74 df                	je     800cb8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd9:	99                   	cltd   
  800cda:	c1 ea 1b             	shr    $0x1b,%edx
  800cdd:	01 d0                	add    %edx,%eax
  800cdf:	83 e0 1f             	and    $0x1f,%eax
  800ce2:	29 d0                	sub    %edx,%eax
  800ce4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf2:	83 c3 01             	add    $0x1,%ebx
  800cf5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cf8:	75 d8                	jne    800cd2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfd:	eb 05                	jmp    800d04 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d17:	50                   	push   %eax
  800d18:	e8 61 f6 ff ff       	call   80037e <fd_alloc>
  800d1d:	83 c4 10             	add    $0x10,%esp
  800d20:	89 c2                	mov    %eax,%edx
  800d22:	85 c0                	test   %eax,%eax
  800d24:	0f 88 2c 01 00 00    	js     800e56 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2a:	83 ec 04             	sub    $0x4,%esp
  800d2d:	68 07 04 00 00       	push   $0x407
  800d32:	ff 75 f4             	pushl  -0xc(%ebp)
  800d35:	6a 00                	push   $0x0
  800d37:	e8 2a f4 ff ff       	call   800166 <sys_page_alloc>
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	89 c2                	mov    %eax,%edx
  800d41:	85 c0                	test   %eax,%eax
  800d43:	0f 88 0d 01 00 00    	js     800e56 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4f:	50                   	push   %eax
  800d50:	e8 29 f6 ff ff       	call   80037e <fd_alloc>
  800d55:	89 c3                	mov    %eax,%ebx
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	0f 88 e2 00 00 00    	js     800e44 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d62:	83 ec 04             	sub    $0x4,%esp
  800d65:	68 07 04 00 00       	push   $0x407
  800d6a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d6d:	6a 00                	push   $0x0
  800d6f:	e8 f2 f3 ff ff       	call   800166 <sys_page_alloc>
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	0f 88 c3 00 00 00    	js     800e44 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	ff 75 f4             	pushl  -0xc(%ebp)
  800d87:	e8 db f5 ff ff       	call   800367 <fd2data>
  800d8c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 c4 0c             	add    $0xc,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	50                   	push   %eax
  800d97:	6a 00                	push   $0x0
  800d99:	e8 c8 f3 ff ff       	call   800166 <sys_page_alloc>
  800d9e:	89 c3                	mov    %eax,%ebx
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	0f 88 89 00 00 00    	js     800e34 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	ff 75 f0             	pushl  -0x10(%ebp)
  800db1:	e8 b1 f5 ff ff       	call   800367 <fd2data>
  800db6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dbd:	50                   	push   %eax
  800dbe:	6a 00                	push   $0x0
  800dc0:	56                   	push   %esi
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 e1 f3 ff ff       	call   8001a9 <sys_page_map>
  800dc8:	89 c3                	mov    %eax,%ebx
  800dca:	83 c4 20             	add    $0x20,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	78 55                	js     800e26 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dd1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dda:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800de6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800def:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	ff 75 f4             	pushl  -0xc(%ebp)
  800e01:	e8 51 f5 ff ff       	call   800357 <fd2num>
  800e06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e09:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e0b:	83 c4 04             	add    $0x4,%esp
  800e0e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e11:	e8 41 f5 ff ff       	call   800357 <fd2num>
  800e16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e19:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e24:	eb 30                	jmp    800e56 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e26:	83 ec 08             	sub    $0x8,%esp
  800e29:	56                   	push   %esi
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 ba f3 ff ff       	call   8001eb <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 aa f3 ff ff       	call   8001eb <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 9a f3 ff ff       	call   8001eb <sys_page_unmap>
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e68:	50                   	push   %eax
  800e69:	ff 75 08             	pushl  0x8(%ebp)
  800e6c:	e8 5c f5 ff ff       	call   8003cd <fd_lookup>
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 18                	js     800e90 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7e:	e8 e4 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e88:	e8 21 fd ff ff       	call   800bae <_pipeisclosed>
  800e8d:	83 c4 10             	add    $0x10,%esp
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ea2:	68 78 1f 80 00       	push   $0x801f78
  800ea7:	ff 75 0c             	pushl  0xc(%ebp)
  800eaa:	e8 6b 08 00 00       	call   80171a <strcpy>
	return 0;
}
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
  800ebc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ecd:	eb 2d                	jmp    800efc <devcons_write+0x46>
		m = n - tot;
  800ecf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ed4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ed7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800edc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	53                   	push   %ebx
  800ee3:	03 45 0c             	add    0xc(%ebp),%eax
  800ee6:	50                   	push   %eax
  800ee7:	57                   	push   %edi
  800ee8:	e8 bf 09 00 00       	call   8018ac <memmove>
		sys_cputs(buf, m);
  800eed:	83 c4 08             	add    $0x8,%esp
  800ef0:	53                   	push   %ebx
  800ef1:	57                   	push   %edi
  800ef2:	e8 b3 f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef7:	01 de                	add    %ebx,%esi
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	89 f0                	mov    %esi,%eax
  800efe:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f01:	72 cc                	jb     800ecf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 08             	sub    $0x8,%esp
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f1a:	74 2a                	je     800f46 <devcons_read+0x3b>
  800f1c:	eb 05                	jmp    800f23 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f1e:	e8 24 f2 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f23:	e8 a0 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	74 f2                	je     800f1e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 16                	js     800f46 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f30:	83 f8 04             	cmp    $0x4,%eax
  800f33:	74 0c                	je     800f41 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f38:	88 02                	mov    %al,(%edx)
	return 1;
  800f3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3f:	eb 05                	jmp    800f46 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f46:	c9                   	leave  
  800f47:	c3                   	ret    

00800f48 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f54:	6a 01                	push   $0x1
  800f56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f59:	50                   	push   %eax
  800f5a:	e8 4b f1 ff ff       	call   8000aa <sys_cputs>
}
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <getchar>:

int
getchar(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f6a:	6a 01                	push   $0x1
  800f6c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	6a 00                	push   $0x0
  800f72:	e8 bc f6 ff ff       	call   800633 <read>
	if (r < 0)
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 0f                	js     800f8d <getchar+0x29>
		return r;
	if (r < 1)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 06                	jle    800f88 <getchar+0x24>
		return -E_EOF;
	return c;
  800f82:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f86:	eb 05                	jmp    800f8d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f88:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	ff 75 08             	pushl  0x8(%ebp)
  800f9c:	e8 2c f4 ff ff       	call   8003cd <fd_lookup>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 11                	js     800fb9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb1:	39 10                	cmp    %edx,(%eax)
  800fb3:	0f 94 c0             	sete   %al
  800fb6:	0f b6 c0             	movzbl %al,%eax
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <opencons>:

int
opencons(void)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	e8 b4 f3 ff ff       	call   80037e <fd_alloc>
  800fca:	83 c4 10             	add    $0x10,%esp
		return r;
  800fcd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 3e                	js     801011 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd3:	83 ec 04             	sub    $0x4,%esp
  800fd6:	68 07 04 00 00       	push   $0x407
  800fdb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 81 f1 ff ff       	call   800166 <sys_page_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 23                	js     801011 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	50                   	push   %eax
  801007:	e8 4b f3 ff ff       	call   800357 <fd2num>
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	83 c4 10             	add    $0x10,%esp
}
  801011:	89 d0                	mov    %edx,%eax
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80101a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801023:	e8 00 f1 ff ff       	call   800128 <sys_getenvid>
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	ff 75 0c             	pushl  0xc(%ebp)
  80102e:	ff 75 08             	pushl  0x8(%ebp)
  801031:	56                   	push   %esi
  801032:	50                   	push   %eax
  801033:	68 84 1f 80 00       	push   $0x801f84
  801038:	e8 b1 00 00 00       	call   8010ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103d:	83 c4 18             	add    $0x18,%esp
  801040:	53                   	push   %ebx
  801041:	ff 75 10             	pushl  0x10(%ebp)
  801044:	e8 54 00 00 00       	call   80109d <vcprintf>
	cprintf("\n");
  801049:	c7 04 24 71 1f 80 00 	movl   $0x801f71,(%esp)
  801050:	e8 99 00 00 00       	call   8010ee <cprintf>
  801055:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801058:	cc                   	int3   
  801059:	eb fd                	jmp    801058 <_panic+0x43>

0080105b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	53                   	push   %ebx
  80105f:	83 ec 04             	sub    $0x4,%esp
  801062:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801065:	8b 13                	mov    (%ebx),%edx
  801067:	8d 42 01             	lea    0x1(%edx),%eax
  80106a:	89 03                	mov    %eax,(%ebx)
  80106c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801073:	3d ff 00 00 00       	cmp    $0xff,%eax
  801078:	75 1a                	jne    801094 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	68 ff 00 00 00       	push   $0xff
  801082:	8d 43 08             	lea    0x8(%ebx),%eax
  801085:	50                   	push   %eax
  801086:	e8 1f f0 ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  80108b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801091:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801094:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ad:	00 00 00 
	b.cnt = 0;
  8010b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	ff 75 08             	pushl  0x8(%ebp)
  8010c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	68 5b 10 80 00       	push   $0x80105b
  8010cc:	e8 1a 01 00 00       	call   8011eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d1:	83 c4 08             	add    $0x8,%esp
  8010d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e0:	50                   	push   %eax
  8010e1:	e8 c4 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8010e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f7:	50                   	push   %eax
  8010f8:	ff 75 08             	pushl  0x8(%ebp)
  8010fb:	e8 9d ff ff ff       	call   80109d <vcprintf>
	va_end(ap);

	return cnt;
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 1c             	sub    $0x1c,%esp
  80110b:	89 c7                	mov    %eax,%edi
  80110d:	89 d6                	mov    %edx,%esi
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	8b 55 0c             	mov    0xc(%ebp),%edx
  801115:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801118:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80111b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801123:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801126:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801129:	39 d3                	cmp    %edx,%ebx
  80112b:	72 05                	jb     801132 <printnum+0x30>
  80112d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801130:	77 45                	ja     801177 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	ff 75 18             	pushl  0x18(%ebp)
  801138:	8b 45 14             	mov    0x14(%ebp),%eax
  80113b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80113e:	53                   	push   %ebx
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	ff 75 e4             	pushl  -0x1c(%ebp)
  801148:	ff 75 e0             	pushl  -0x20(%ebp)
  80114b:	ff 75 dc             	pushl  -0x24(%ebp)
  80114e:	ff 75 d8             	pushl  -0x28(%ebp)
  801151:	e8 4a 0a 00 00       	call   801ba0 <__udivdi3>
  801156:	83 c4 18             	add    $0x18,%esp
  801159:	52                   	push   %edx
  80115a:	50                   	push   %eax
  80115b:	89 f2                	mov    %esi,%edx
  80115d:	89 f8                	mov    %edi,%eax
  80115f:	e8 9e ff ff ff       	call   801102 <printnum>
  801164:	83 c4 20             	add    $0x20,%esp
  801167:	eb 18                	jmp    801181 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	56                   	push   %esi
  80116d:	ff 75 18             	pushl  0x18(%ebp)
  801170:	ff d7                	call   *%edi
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	eb 03                	jmp    80117a <printnum+0x78>
  801177:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80117a:	83 eb 01             	sub    $0x1,%ebx
  80117d:	85 db                	test   %ebx,%ebx
  80117f:	7f e8                	jg     801169 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	56                   	push   %esi
  801185:	83 ec 04             	sub    $0x4,%esp
  801188:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118b:	ff 75 e0             	pushl  -0x20(%ebp)
  80118e:	ff 75 dc             	pushl  -0x24(%ebp)
  801191:	ff 75 d8             	pushl  -0x28(%ebp)
  801194:	e8 37 0b 00 00       	call   801cd0 <__umoddi3>
  801199:	83 c4 14             	add    $0x14,%esp
  80119c:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  8011a3:	50                   	push   %eax
  8011a4:	ff d7                	call   *%edi
}
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011bb:	8b 10                	mov    (%eax),%edx
  8011bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8011c0:	73 0a                	jae    8011cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8011c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011c5:	89 08                	mov    %ecx,(%eax)
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	88 02                	mov    %al,(%edx)
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d7:	50                   	push   %eax
  8011d8:	ff 75 10             	pushl  0x10(%ebp)
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	ff 75 08             	pushl  0x8(%ebp)
  8011e1:	e8 05 00 00 00       	call   8011eb <vprintfmt>
	va_end(ap);
}
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	57                   	push   %edi
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 2c             	sub    $0x2c,%esp
  8011f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011fd:	eb 12                	jmp    801211 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011ff:	85 c0                	test   %eax,%eax
  801201:	0f 84 6a 04 00 00    	je     801671 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	53                   	push   %ebx
  80120b:	50                   	push   %eax
  80120c:	ff d6                	call   *%esi
  80120e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801211:	83 c7 01             	add    $0x1,%edi
  801214:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801218:	83 f8 25             	cmp    $0x25,%eax
  80121b:	75 e2                	jne    8011ff <vprintfmt+0x14>
  80121d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801221:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801228:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80122f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801236:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123b:	eb 07                	jmp    801244 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801240:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801244:	8d 47 01             	lea    0x1(%edi),%eax
  801247:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80124a:	0f b6 07             	movzbl (%edi),%eax
  80124d:	0f b6 d0             	movzbl %al,%edx
  801250:	83 e8 23             	sub    $0x23,%eax
  801253:	3c 55                	cmp    $0x55,%al
  801255:	0f 87 fb 03 00 00    	ja     801656 <vprintfmt+0x46b>
  80125b:	0f b6 c0             	movzbl %al,%eax
  80125e:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801265:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801268:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80126c:	eb d6                	jmp    801244 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801279:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80127c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801280:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801283:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801286:	83 f9 09             	cmp    $0x9,%ecx
  801289:	77 3f                	ja     8012ca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80128b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80128e:	eb e9                	jmp    801279 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801290:	8b 45 14             	mov    0x14(%ebp),%eax
  801293:	8b 00                	mov    (%eax),%eax
  801295:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801298:	8b 45 14             	mov    0x14(%ebp),%eax
  80129b:	8d 40 04             	lea    0x4(%eax),%eax
  80129e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012a4:	eb 2a                	jmp    8012d0 <vprintfmt+0xe5>
  8012a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b0:	0f 49 d0             	cmovns %eax,%edx
  8012b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b9:	eb 89                	jmp    801244 <vprintfmt+0x59>
  8012bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012c5:	e9 7a ff ff ff       	jmp    801244 <vprintfmt+0x59>
  8012ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012d4:	0f 89 6a ff ff ff    	jns    801244 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012e7:	e9 58 ff ff ff       	jmp    801244 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012ec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8012f2:	e9 4d ff ff ff       	jmp    801244 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fa:	8d 78 04             	lea    0x4(%eax),%edi
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	53                   	push   %ebx
  801301:	ff 30                	pushl  (%eax)
  801303:	ff d6                	call   *%esi
			break;
  801305:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801308:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80130e:	e9 fe fe ff ff       	jmp    801211 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801313:	8b 45 14             	mov    0x14(%ebp),%eax
  801316:	8d 78 04             	lea    0x4(%eax),%edi
  801319:	8b 00                	mov    (%eax),%eax
  80131b:	99                   	cltd   
  80131c:	31 d0                	xor    %edx,%eax
  80131e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801320:	83 f8 0f             	cmp    $0xf,%eax
  801323:	7f 0b                	jg     801330 <vprintfmt+0x145>
  801325:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80132c:	85 d2                	test   %edx,%edx
  80132e:	75 1b                	jne    80134b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801330:	50                   	push   %eax
  801331:	68 bf 1f 80 00       	push   $0x801fbf
  801336:	53                   	push   %ebx
  801337:	56                   	push   %esi
  801338:	e8 91 fe ff ff       	call   8011ce <printfmt>
  80133d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801340:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801346:	e9 c6 fe ff ff       	jmp    801211 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80134b:	52                   	push   %edx
  80134c:	68 4a 1f 80 00       	push   $0x801f4a
  801351:	53                   	push   %ebx
  801352:	56                   	push   %esi
  801353:	e8 76 fe ff ff       	call   8011ce <printfmt>
  801358:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801361:	e9 ab fe ff ff       	jmp    801211 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801366:	8b 45 14             	mov    0x14(%ebp),%eax
  801369:	83 c0 04             	add    $0x4,%eax
  80136c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80136f:	8b 45 14             	mov    0x14(%ebp),%eax
  801372:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801374:	85 ff                	test   %edi,%edi
  801376:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  80137b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80137e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801382:	0f 8e 94 00 00 00    	jle    80141c <vprintfmt+0x231>
  801388:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80138c:	0f 84 98 00 00 00    	je     80142a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	ff 75 d0             	pushl  -0x30(%ebp)
  801398:	57                   	push   %edi
  801399:	e8 5b 03 00 00       	call   8016f9 <strnlen>
  80139e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013a1:	29 c1                	sub    %eax,%ecx
  8013a3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b5:	eb 0f                	jmp    8013c6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8013be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c0:	83 ef 01             	sub    $0x1,%edi
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	85 ff                	test   %edi,%edi
  8013c8:	7f ed                	jg     8013b7 <vprintfmt+0x1cc>
  8013ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013cd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013d0:	85 c9                	test   %ecx,%ecx
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d7:	0f 49 c1             	cmovns %ecx,%eax
  8013da:	29 c1                	sub    %eax,%ecx
  8013dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8013df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e5:	89 cb                	mov    %ecx,%ebx
  8013e7:	eb 4d                	jmp    801436 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ed:	74 1b                	je     80140a <vprintfmt+0x21f>
  8013ef:	0f be c0             	movsbl %al,%eax
  8013f2:	83 e8 20             	sub    $0x20,%eax
  8013f5:	83 f8 5e             	cmp    $0x5e,%eax
  8013f8:	76 10                	jbe    80140a <vprintfmt+0x21f>
					putch('?', putdat);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	ff 75 0c             	pushl  0xc(%ebp)
  801400:	6a 3f                	push   $0x3f
  801402:	ff 55 08             	call   *0x8(%ebp)
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	eb 0d                	jmp    801417 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	ff 75 0c             	pushl  0xc(%ebp)
  801410:	52                   	push   %edx
  801411:	ff 55 08             	call   *0x8(%ebp)
  801414:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801417:	83 eb 01             	sub    $0x1,%ebx
  80141a:	eb 1a                	jmp    801436 <vprintfmt+0x24b>
  80141c:	89 75 08             	mov    %esi,0x8(%ebp)
  80141f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801422:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801425:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801428:	eb 0c                	jmp    801436 <vprintfmt+0x24b>
  80142a:	89 75 08             	mov    %esi,0x8(%ebp)
  80142d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801430:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801433:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801436:	83 c7 01             	add    $0x1,%edi
  801439:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80143d:	0f be d0             	movsbl %al,%edx
  801440:	85 d2                	test   %edx,%edx
  801442:	74 23                	je     801467 <vprintfmt+0x27c>
  801444:	85 f6                	test   %esi,%esi
  801446:	78 a1                	js     8013e9 <vprintfmt+0x1fe>
  801448:	83 ee 01             	sub    $0x1,%esi
  80144b:	79 9c                	jns    8013e9 <vprintfmt+0x1fe>
  80144d:	89 df                	mov    %ebx,%edi
  80144f:	8b 75 08             	mov    0x8(%ebp),%esi
  801452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801455:	eb 18                	jmp    80146f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	53                   	push   %ebx
  80145b:	6a 20                	push   $0x20
  80145d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80145f:	83 ef 01             	sub    $0x1,%edi
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	eb 08                	jmp    80146f <vprintfmt+0x284>
  801467:	89 df                	mov    %ebx,%edi
  801469:	8b 75 08             	mov    0x8(%ebp),%esi
  80146c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146f:	85 ff                	test   %edi,%edi
  801471:	7f e4                	jg     801457 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801473:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801476:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80147c:	e9 90 fd ff ff       	jmp    801211 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801481:	83 f9 01             	cmp    $0x1,%ecx
  801484:	7e 19                	jle    80149f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801486:	8b 45 14             	mov    0x14(%ebp),%eax
  801489:	8b 50 04             	mov    0x4(%eax),%edx
  80148c:	8b 00                	mov    (%eax),%eax
  80148e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801491:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801494:	8b 45 14             	mov    0x14(%ebp),%eax
  801497:	8d 40 08             	lea    0x8(%eax),%eax
  80149a:	89 45 14             	mov    %eax,0x14(%ebp)
  80149d:	eb 38                	jmp    8014d7 <vprintfmt+0x2ec>
	else if (lflag)
  80149f:	85 c9                	test   %ecx,%ecx
  8014a1:	74 1b                	je     8014be <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a6:	8b 00                	mov    (%eax),%eax
  8014a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ab:	89 c1                	mov    %eax,%ecx
  8014ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b6:	8d 40 04             	lea    0x4(%eax),%eax
  8014b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8014bc:	eb 19                	jmp    8014d7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014be:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c1:	8b 00                	mov    (%eax),%eax
  8014c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c6:	89 c1                	mov    %eax,%ecx
  8014c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d1:	8d 40 04             	lea    0x4(%eax),%eax
  8014d4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014e6:	0f 89 36 01 00 00    	jns    801622 <vprintfmt+0x437>
				putch('-', putdat);
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	53                   	push   %ebx
  8014f0:	6a 2d                	push   $0x2d
  8014f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8014f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014fa:	f7 da                	neg    %edx
  8014fc:	83 d1 00             	adc    $0x0,%ecx
  8014ff:	f7 d9                	neg    %ecx
  801501:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801504:	b8 0a 00 00 00       	mov    $0xa,%eax
  801509:	e9 14 01 00 00       	jmp    801622 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80150e:	83 f9 01             	cmp    $0x1,%ecx
  801511:	7e 18                	jle    80152b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801513:	8b 45 14             	mov    0x14(%ebp),%eax
  801516:	8b 10                	mov    (%eax),%edx
  801518:	8b 48 04             	mov    0x4(%eax),%ecx
  80151b:	8d 40 08             	lea    0x8(%eax),%eax
  80151e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801521:	b8 0a 00 00 00       	mov    $0xa,%eax
  801526:	e9 f7 00 00 00       	jmp    801622 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80152b:	85 c9                	test   %ecx,%ecx
  80152d:	74 1a                	je     801549 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80152f:	8b 45 14             	mov    0x14(%ebp),%eax
  801532:	8b 10                	mov    (%eax),%edx
  801534:	b9 00 00 00 00       	mov    $0x0,%ecx
  801539:	8d 40 04             	lea    0x4(%eax),%eax
  80153c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80153f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801544:	e9 d9 00 00 00       	jmp    801622 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801549:	8b 45 14             	mov    0x14(%ebp),%eax
  80154c:	8b 10                	mov    (%eax),%edx
  80154e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801553:	8d 40 04             	lea    0x4(%eax),%eax
  801556:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801559:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155e:	e9 bf 00 00 00       	jmp    801622 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801563:	83 f9 01             	cmp    $0x1,%ecx
  801566:	7e 13                	jle    80157b <vprintfmt+0x390>
		return va_arg(*ap, long long);
  801568:	8b 45 14             	mov    0x14(%ebp),%eax
  80156b:	8b 50 04             	mov    0x4(%eax),%edx
  80156e:	8b 00                	mov    (%eax),%eax
  801570:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801573:	8d 49 08             	lea    0x8(%ecx),%ecx
  801576:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801579:	eb 28                	jmp    8015a3 <vprintfmt+0x3b8>
	else if (lflag)
  80157b:	85 c9                	test   %ecx,%ecx
  80157d:	74 13                	je     801592 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80157f:	8b 45 14             	mov    0x14(%ebp),%eax
  801582:	8b 10                	mov    (%eax),%edx
  801584:	89 d0                	mov    %edx,%eax
  801586:	99                   	cltd   
  801587:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80158a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80158d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801590:	eb 11                	jmp    8015a3 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  801592:	8b 45 14             	mov    0x14(%ebp),%eax
  801595:	8b 10                	mov    (%eax),%edx
  801597:	89 d0                	mov    %edx,%eax
  801599:	99                   	cltd   
  80159a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80159d:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8015a3:	89 d1                	mov    %edx,%ecx
  8015a5:	89 c2                	mov    %eax,%edx
			base = 8;
  8015a7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015ac:	eb 74                	jmp    801622 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	53                   	push   %ebx
  8015b2:	6a 30                	push   $0x30
  8015b4:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	53                   	push   %ebx
  8015ba:	6a 78                	push   $0x78
  8015bc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015be:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c1:	8b 10                	mov    (%eax),%edx
  8015c3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cb:	8d 40 04             	lea    0x4(%eax),%eax
  8015ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d6:	eb 4a                	jmp    801622 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d8:	83 f9 01             	cmp    $0x1,%ecx
  8015db:	7e 15                	jle    8015f2 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8015dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e0:	8b 10                	mov    (%eax),%edx
  8015e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e5:	8d 40 08             	lea    0x8(%eax),%eax
  8015e8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015eb:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f0:	eb 30                	jmp    801622 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015f2:	85 c9                	test   %ecx,%ecx
  8015f4:	74 17                	je     80160d <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8015f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f9:	8b 10                	mov    (%eax),%edx
  8015fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801600:	8d 40 04             	lea    0x4(%eax),%eax
  801603:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801606:	b8 10 00 00 00       	mov    $0x10,%eax
  80160b:	eb 15                	jmp    801622 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80160d:	8b 45 14             	mov    0x14(%ebp),%eax
  801610:	8b 10                	mov    (%eax),%edx
  801612:	b9 00 00 00 00       	mov    $0x0,%ecx
  801617:	8d 40 04             	lea    0x4(%eax),%eax
  80161a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801629:	57                   	push   %edi
  80162a:	ff 75 e0             	pushl  -0x20(%ebp)
  80162d:	50                   	push   %eax
  80162e:	51                   	push   %ecx
  80162f:	52                   	push   %edx
  801630:	89 da                	mov    %ebx,%edx
  801632:	89 f0                	mov    %esi,%eax
  801634:	e8 c9 fa ff ff       	call   801102 <printnum>
			break;
  801639:	83 c4 20             	add    $0x20,%esp
  80163c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80163f:	e9 cd fb ff ff       	jmp    801211 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	53                   	push   %ebx
  801648:	52                   	push   %edx
  801649:	ff d6                	call   *%esi
			break;
  80164b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801651:	e9 bb fb ff ff       	jmp    801211 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	53                   	push   %ebx
  80165a:	6a 25                	push   $0x25
  80165c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb 03                	jmp    801666 <vprintfmt+0x47b>
  801663:	83 ef 01             	sub    $0x1,%edi
  801666:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80166a:	75 f7                	jne    801663 <vprintfmt+0x478>
  80166c:	e9 a0 fb ff ff       	jmp    801211 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801674:	5b                   	pop    %ebx
  801675:	5e                   	pop    %esi
  801676:	5f                   	pop    %edi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	83 ec 18             	sub    $0x18,%esp
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801685:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801688:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80168c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80168f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801696:	85 c0                	test   %eax,%eax
  801698:	74 26                	je     8016c0 <vsnprintf+0x47>
  80169a:	85 d2                	test   %edx,%edx
  80169c:	7e 22                	jle    8016c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80169e:	ff 75 14             	pushl  0x14(%ebp)
  8016a1:	ff 75 10             	pushl  0x10(%ebp)
  8016a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a7:	50                   	push   %eax
  8016a8:	68 b1 11 80 00       	push   $0x8011b1
  8016ad:	e8 39 fb ff ff       	call   8011eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	eb 05                	jmp    8016c5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d0:	50                   	push   %eax
  8016d1:	ff 75 10             	pushl  0x10(%ebp)
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	ff 75 08             	pushl  0x8(%ebp)
  8016da:	e8 9a ff ff ff       	call   801679 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ec:	eb 03                	jmp    8016f1 <strlen+0x10>
		n++;
  8016ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f5:	75 f7                	jne    8016ee <strlen+0xd>
		n++;
	return n;
}
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801702:	ba 00 00 00 00       	mov    $0x0,%edx
  801707:	eb 03                	jmp    80170c <strnlen+0x13>
		n++;
  801709:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170c:	39 c2                	cmp    %eax,%edx
  80170e:	74 08                	je     801718 <strnlen+0x1f>
  801710:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801714:	75 f3                	jne    801709 <strnlen+0x10>
  801716:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801724:	89 c2                	mov    %eax,%edx
  801726:	83 c2 01             	add    $0x1,%edx
  801729:	83 c1 01             	add    $0x1,%ecx
  80172c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801730:	88 5a ff             	mov    %bl,-0x1(%edx)
  801733:	84 db                	test   %bl,%bl
  801735:	75 ef                	jne    801726 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801737:	5b                   	pop    %ebx
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801741:	53                   	push   %ebx
  801742:	e8 9a ff ff ff       	call   8016e1 <strlen>
  801747:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80174a:	ff 75 0c             	pushl  0xc(%ebp)
  80174d:	01 d8                	add    %ebx,%eax
  80174f:	50                   	push   %eax
  801750:	e8 c5 ff ff ff       	call   80171a <strcpy>
	return dst;
}
  801755:	89 d8                	mov    %ebx,%eax
  801757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	8b 75 08             	mov    0x8(%ebp),%esi
  801764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801767:	89 f3                	mov    %esi,%ebx
  801769:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176c:	89 f2                	mov    %esi,%edx
  80176e:	eb 0f                	jmp    80177f <strncpy+0x23>
		*dst++ = *src;
  801770:	83 c2 01             	add    $0x1,%edx
  801773:	0f b6 01             	movzbl (%ecx),%eax
  801776:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801779:	80 39 01             	cmpb   $0x1,(%ecx)
  80177c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177f:	39 da                	cmp    %ebx,%edx
  801781:	75 ed                	jne    801770 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801783:	89 f0                	mov    %esi,%eax
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	8b 75 08             	mov    0x8(%ebp),%esi
  801791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801794:	8b 55 10             	mov    0x10(%ebp),%edx
  801797:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801799:	85 d2                	test   %edx,%edx
  80179b:	74 21                	je     8017be <strlcpy+0x35>
  80179d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017a1:	89 f2                	mov    %esi,%edx
  8017a3:	eb 09                	jmp    8017ae <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a5:	83 c2 01             	add    $0x1,%edx
  8017a8:	83 c1 01             	add    $0x1,%ecx
  8017ab:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017ae:	39 c2                	cmp    %eax,%edx
  8017b0:	74 09                	je     8017bb <strlcpy+0x32>
  8017b2:	0f b6 19             	movzbl (%ecx),%ebx
  8017b5:	84 db                	test   %bl,%bl
  8017b7:	75 ec                	jne    8017a5 <strlcpy+0x1c>
  8017b9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017be:	29 f0                	sub    %esi,%eax
}
  8017c0:	5b                   	pop    %ebx
  8017c1:	5e                   	pop    %esi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017cd:	eb 06                	jmp    8017d5 <strcmp+0x11>
		p++, q++;
  8017cf:	83 c1 01             	add    $0x1,%ecx
  8017d2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d5:	0f b6 01             	movzbl (%ecx),%eax
  8017d8:	84 c0                	test   %al,%al
  8017da:	74 04                	je     8017e0 <strcmp+0x1c>
  8017dc:	3a 02                	cmp    (%edx),%al
  8017de:	74 ef                	je     8017cf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e0:	0f b6 c0             	movzbl %al,%eax
  8017e3:	0f b6 12             	movzbl (%edx),%edx
  8017e6:	29 d0                	sub    %edx,%eax
}
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f9:	eb 06                	jmp    801801 <strncmp+0x17>
		n--, p++, q++;
  8017fb:	83 c0 01             	add    $0x1,%eax
  8017fe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801801:	39 d8                	cmp    %ebx,%eax
  801803:	74 15                	je     80181a <strncmp+0x30>
  801805:	0f b6 08             	movzbl (%eax),%ecx
  801808:	84 c9                	test   %cl,%cl
  80180a:	74 04                	je     801810 <strncmp+0x26>
  80180c:	3a 0a                	cmp    (%edx),%cl
  80180e:	74 eb                	je     8017fb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801810:	0f b6 00             	movzbl (%eax),%eax
  801813:	0f b6 12             	movzbl (%edx),%edx
  801816:	29 d0                	sub    %edx,%eax
  801818:	eb 05                	jmp    80181f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80181f:	5b                   	pop    %ebx
  801820:	5d                   	pop    %ebp
  801821:	c3                   	ret    

00801822 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182c:	eb 07                	jmp    801835 <strchr+0x13>
		if (*s == c)
  80182e:	38 ca                	cmp    %cl,%dl
  801830:	74 0f                	je     801841 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801832:	83 c0 01             	add    $0x1,%eax
  801835:	0f b6 10             	movzbl (%eax),%edx
  801838:	84 d2                	test   %dl,%dl
  80183a:	75 f2                	jne    80182e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80183c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184d:	eb 03                	jmp    801852 <strfind+0xf>
  80184f:	83 c0 01             	add    $0x1,%eax
  801852:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801855:	38 ca                	cmp    %cl,%dl
  801857:	74 04                	je     80185d <strfind+0x1a>
  801859:	84 d2                	test   %dl,%dl
  80185b:	75 f2                	jne    80184f <strfind+0xc>
			break;
	return (char *) s;
}
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	57                   	push   %edi
  801863:	56                   	push   %esi
  801864:	53                   	push   %ebx
  801865:	8b 7d 08             	mov    0x8(%ebp),%edi
  801868:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80186b:	85 c9                	test   %ecx,%ecx
  80186d:	74 36                	je     8018a5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80186f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801875:	75 28                	jne    80189f <memset+0x40>
  801877:	f6 c1 03             	test   $0x3,%cl
  80187a:	75 23                	jne    80189f <memset+0x40>
		c &= 0xFF;
  80187c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801880:	89 d3                	mov    %edx,%ebx
  801882:	c1 e3 08             	shl    $0x8,%ebx
  801885:	89 d6                	mov    %edx,%esi
  801887:	c1 e6 18             	shl    $0x18,%esi
  80188a:	89 d0                	mov    %edx,%eax
  80188c:	c1 e0 10             	shl    $0x10,%eax
  80188f:	09 f0                	or     %esi,%eax
  801891:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801893:	89 d8                	mov    %ebx,%eax
  801895:	09 d0                	or     %edx,%eax
  801897:	c1 e9 02             	shr    $0x2,%ecx
  80189a:	fc                   	cld    
  80189b:	f3 ab                	rep stos %eax,%es:(%edi)
  80189d:	eb 06                	jmp    8018a5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80189f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a2:	fc                   	cld    
  8018a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a5:	89 f8                	mov    %edi,%eax
  8018a7:	5b                   	pop    %ebx
  8018a8:	5e                   	pop    %esi
  8018a9:	5f                   	pop    %edi
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    

008018ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	57                   	push   %edi
  8018b0:	56                   	push   %esi
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ba:	39 c6                	cmp    %eax,%esi
  8018bc:	73 35                	jae    8018f3 <memmove+0x47>
  8018be:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c1:	39 d0                	cmp    %edx,%eax
  8018c3:	73 2e                	jae    8018f3 <memmove+0x47>
		s += n;
		d += n;
  8018c5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c8:	89 d6                	mov    %edx,%esi
  8018ca:	09 fe                	or     %edi,%esi
  8018cc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d2:	75 13                	jne    8018e7 <memmove+0x3b>
  8018d4:	f6 c1 03             	test   $0x3,%cl
  8018d7:	75 0e                	jne    8018e7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d9:	83 ef 04             	sub    $0x4,%edi
  8018dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018df:	c1 e9 02             	shr    $0x2,%ecx
  8018e2:	fd                   	std    
  8018e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e5:	eb 09                	jmp    8018f0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e7:	83 ef 01             	sub    $0x1,%edi
  8018ea:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ed:	fd                   	std    
  8018ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f0:	fc                   	cld    
  8018f1:	eb 1d                	jmp    801910 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f3:	89 f2                	mov    %esi,%edx
  8018f5:	09 c2                	or     %eax,%edx
  8018f7:	f6 c2 03             	test   $0x3,%dl
  8018fa:	75 0f                	jne    80190b <memmove+0x5f>
  8018fc:	f6 c1 03             	test   $0x3,%cl
  8018ff:	75 0a                	jne    80190b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801901:	c1 e9 02             	shr    $0x2,%ecx
  801904:	89 c7                	mov    %eax,%edi
  801906:	fc                   	cld    
  801907:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801909:	eb 05                	jmp    801910 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190b:	89 c7                	mov    %eax,%edi
  80190d:	fc                   	cld    
  80190e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801917:	ff 75 10             	pushl  0x10(%ebp)
  80191a:	ff 75 0c             	pushl  0xc(%ebp)
  80191d:	ff 75 08             	pushl  0x8(%ebp)
  801920:	e8 87 ff ff ff       	call   8018ac <memmove>
}
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801932:	89 c6                	mov    %eax,%esi
  801934:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801937:	eb 1a                	jmp    801953 <memcmp+0x2c>
		if (*s1 != *s2)
  801939:	0f b6 08             	movzbl (%eax),%ecx
  80193c:	0f b6 1a             	movzbl (%edx),%ebx
  80193f:	38 d9                	cmp    %bl,%cl
  801941:	74 0a                	je     80194d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801943:	0f b6 c1             	movzbl %cl,%eax
  801946:	0f b6 db             	movzbl %bl,%ebx
  801949:	29 d8                	sub    %ebx,%eax
  80194b:	eb 0f                	jmp    80195c <memcmp+0x35>
		s1++, s2++;
  80194d:	83 c0 01             	add    $0x1,%eax
  801950:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801953:	39 f0                	cmp    %esi,%eax
  801955:	75 e2                	jne    801939 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195c:	5b                   	pop    %ebx
  80195d:	5e                   	pop    %esi
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	53                   	push   %ebx
  801964:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801967:	89 c1                	mov    %eax,%ecx
  801969:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80196c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801970:	eb 0a                	jmp    80197c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801972:	0f b6 10             	movzbl (%eax),%edx
  801975:	39 da                	cmp    %ebx,%edx
  801977:	74 07                	je     801980 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801979:	83 c0 01             	add    $0x1,%eax
  80197c:	39 c8                	cmp    %ecx,%eax
  80197e:	72 f2                	jb     801972 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801980:	5b                   	pop    %ebx
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	57                   	push   %edi
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198f:	eb 03                	jmp    801994 <strtol+0x11>
		s++;
  801991:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801994:	0f b6 01             	movzbl (%ecx),%eax
  801997:	3c 20                	cmp    $0x20,%al
  801999:	74 f6                	je     801991 <strtol+0xe>
  80199b:	3c 09                	cmp    $0x9,%al
  80199d:	74 f2                	je     801991 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80199f:	3c 2b                	cmp    $0x2b,%al
  8019a1:	75 0a                	jne    8019ad <strtol+0x2a>
		s++;
  8019a3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ab:	eb 11                	jmp    8019be <strtol+0x3b>
  8019ad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b2:	3c 2d                	cmp    $0x2d,%al
  8019b4:	75 08                	jne    8019be <strtol+0x3b>
		s++, neg = 1;
  8019b6:	83 c1 01             	add    $0x1,%ecx
  8019b9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019be:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c4:	75 15                	jne    8019db <strtol+0x58>
  8019c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c9:	75 10                	jne    8019db <strtol+0x58>
  8019cb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019cf:	75 7c                	jne    801a4d <strtol+0xca>
		s += 2, base = 16;
  8019d1:	83 c1 02             	add    $0x2,%ecx
  8019d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d9:	eb 16                	jmp    8019f1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019db:	85 db                	test   %ebx,%ebx
  8019dd:	75 12                	jne    8019f1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019df:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e4:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e7:	75 08                	jne    8019f1 <strtol+0x6e>
		s++, base = 8;
  8019e9:	83 c1 01             	add    $0x1,%ecx
  8019ec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f9:	0f b6 11             	movzbl (%ecx),%edx
  8019fc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ff:	89 f3                	mov    %esi,%ebx
  801a01:	80 fb 09             	cmp    $0x9,%bl
  801a04:	77 08                	ja     801a0e <strtol+0x8b>
			dig = *s - '0';
  801a06:	0f be d2             	movsbl %dl,%edx
  801a09:	83 ea 30             	sub    $0x30,%edx
  801a0c:	eb 22                	jmp    801a30 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a11:	89 f3                	mov    %esi,%ebx
  801a13:	80 fb 19             	cmp    $0x19,%bl
  801a16:	77 08                	ja     801a20 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a18:	0f be d2             	movsbl %dl,%edx
  801a1b:	83 ea 57             	sub    $0x57,%edx
  801a1e:	eb 10                	jmp    801a30 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a20:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a23:	89 f3                	mov    %esi,%ebx
  801a25:	80 fb 19             	cmp    $0x19,%bl
  801a28:	77 16                	ja     801a40 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a2a:	0f be d2             	movsbl %dl,%edx
  801a2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a30:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a33:	7d 0b                	jge    801a40 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a35:	83 c1 01             	add    $0x1,%ecx
  801a38:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a3e:	eb b9                	jmp    8019f9 <strtol+0x76>

	if (endptr)
  801a40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a44:	74 0d                	je     801a53 <strtol+0xd0>
		*endptr = (char *) s;
  801a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a49:	89 0e                	mov    %ecx,(%esi)
  801a4b:	eb 06                	jmp    801a53 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4d:	85 db                	test   %ebx,%ebx
  801a4f:	74 98                	je     8019e9 <strtol+0x66>
  801a51:	eb 9e                	jmp    8019f1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a53:	89 c2                	mov    %eax,%edx
  801a55:	f7 da                	neg    %edx
  801a57:	85 ff                	test   %edi,%edi
  801a59:	0f 45 c2             	cmovne %edx,%eax
}
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5f                   	pop    %edi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	8b 75 08             	mov    0x8(%ebp),%esi
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	74 0e                	je     801a81 <ipc_recv+0x20>
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	50                   	push   %eax
  801a77:	e8 9a e8 ff ff       	call   800316 <sys_ipc_recv>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	eb 10                	jmp    801a91 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	68 00 00 c0 ee       	push   $0xeec00000
  801a89:	e8 88 e8 ff ff       	call   800316 <sys_ipc_recv>
  801a8e:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801a91:	85 c0                	test   %eax,%eax
  801a93:	74 16                	je     801aab <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801a95:	85 f6                	test   %esi,%esi
  801a97:	74 06                	je     801a9f <ipc_recv+0x3e>
  801a99:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801a9f:	85 db                	test   %ebx,%ebx
  801aa1:	74 2c                	je     801acf <ipc_recv+0x6e>
  801aa3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa9:	eb 24                	jmp    801acf <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801aab:	85 f6                	test   %esi,%esi
  801aad:	74 0a                	je     801ab9 <ipc_recv+0x58>
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 40 74             	mov    0x74(%eax),%eax
  801ab7:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801ab9:	85 db                	test   %ebx,%ebx
  801abb:	74 0a                	je     801ac7 <ipc_recv+0x66>
  801abd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac2:	8b 40 78             	mov    0x78(%eax),%eax
  801ac5:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ac7:	a1 04 40 80 00       	mov    0x804004,%eax
  801acc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	57                   	push   %edi
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801aef:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801af2:	ff 75 14             	pushl  0x14(%ebp)
  801af5:	53                   	push   %ebx
  801af6:	56                   	push   %esi
  801af7:	57                   	push   %edi
  801af8:	e8 f6 e7 ff ff       	call   8002f3 <sys_ipc_try_send>
		if (ret == 0) break;
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	74 1e                	je     801b22 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b04:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b07:	74 12                	je     801b1b <ipc_send+0x45>
  801b09:	50                   	push   %eax
  801b0a:	68 a0 22 80 00       	push   $0x8022a0
  801b0f:	6a 39                	push   $0x39
  801b11:	68 ad 22 80 00       	push   $0x8022ad
  801b16:	e8 fa f4 ff ff       	call   801015 <_panic>
		sys_yield();
  801b1b:	e8 27 e6 ff ff       	call   800147 <sys_yield>
	}
  801b20:	eb d0                	jmp    801af2 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5f                   	pop    %edi
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b35:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b38:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b3e:	8b 52 50             	mov    0x50(%edx),%edx
  801b41:	39 ca                	cmp    %ecx,%edx
  801b43:	75 0d                	jne    801b52 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b45:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b48:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b4d:	8b 40 48             	mov    0x48(%eax),%eax
  801b50:	eb 0f                	jmp    801b61 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b52:	83 c0 01             	add    $0x1,%eax
  801b55:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b5a:	75 d9                	jne    801b35 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b69:	89 d0                	mov    %edx,%eax
  801b6b:	c1 e8 16             	shr    $0x16,%eax
  801b6e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7a:	f6 c1 01             	test   $0x1,%cl
  801b7d:	74 1d                	je     801b9c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b7f:	c1 ea 0c             	shr    $0xc,%edx
  801b82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b89:	f6 c2 01             	test   $0x1,%dl
  801b8c:	74 0e                	je     801b9c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b8e:	c1 ea 0c             	shr    $0xc,%edx
  801b91:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b98:	ef 
  801b99:	0f b7 c0             	movzwl %ax,%eax
}
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bb7:	85 f6                	test   %esi,%esi
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 ca                	mov    %ecx,%edx
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	75 3d                	jne    801c00 <__udivdi3+0x60>
  801bc3:	39 cf                	cmp    %ecx,%edi
  801bc5:	0f 87 c5 00 00 00    	ja     801c90 <__udivdi3+0xf0>
  801bcb:	85 ff                	test   %edi,%edi
  801bcd:	89 fd                	mov    %edi,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f7                	div    %edi
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 c8                	mov    %ecx,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c1                	mov    %eax,%ecx
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	89 cf                	mov    %ecx,%edi
  801be8:	f7 f5                	div    %ebp
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	39 ce                	cmp    %ecx,%esi
  801c02:	77 74                	ja     801c78 <__udivdi3+0xd8>
  801c04:	0f bd fe             	bsr    %esi,%edi
  801c07:	83 f7 1f             	xor    $0x1f,%edi
  801c0a:	0f 84 98 00 00 00    	je     801ca8 <__udivdi3+0x108>
  801c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	89 c5                	mov    %eax,%ebp
  801c19:	29 fb                	sub    %edi,%ebx
  801c1b:	d3 e6                	shl    %cl,%esi
  801c1d:	89 d9                	mov    %ebx,%ecx
  801c1f:	d3 ed                	shr    %cl,%ebp
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	09 ee                	or     %ebp,%esi
  801c27:	89 d9                	mov    %ebx,%ecx
  801c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2d:	89 d5                	mov    %edx,%ebp
  801c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c33:	d3 ed                	shr    %cl,%ebp
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e2                	shl    %cl,%edx
  801c39:	89 d9                	mov    %ebx,%ecx
  801c3b:	d3 e8                	shr    %cl,%eax
  801c3d:	09 c2                	or     %eax,%edx
  801c3f:	89 d0                	mov    %edx,%eax
  801c41:	89 ea                	mov    %ebp,%edx
  801c43:	f7 f6                	div    %esi
  801c45:	89 d5                	mov    %edx,%ebp
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	f7 64 24 0c          	mull   0xc(%esp)
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	72 10                	jb     801c61 <__udivdi3+0xc1>
  801c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e6                	shl    %cl,%esi
  801c59:	39 c6                	cmp    %eax,%esi
  801c5b:	73 07                	jae    801c64 <__udivdi3+0xc4>
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	75 03                	jne    801c64 <__udivdi3+0xc4>
  801c61:	83 eb 01             	sub    $0x1,%ebx
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	31 ff                	xor    %edi,%edi
  801c7a:	31 db                	xor    %ebx,%ebx
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
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	f7 f7                	div    %edi
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	89 d8                	mov    %ebx,%eax
  801c9a:	89 fa                	mov    %edi,%edx
  801c9c:	83 c4 1c             	add    $0x1c,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    
  801ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	39 ce                	cmp    %ecx,%esi
  801caa:	72 0c                	jb     801cb8 <__udivdi3+0x118>
  801cac:	31 db                	xor    %ebx,%ebx
  801cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cb2:	0f 87 34 ff ff ff    	ja     801bec <__udivdi3+0x4c>
  801cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cbd:	e9 2a ff ff ff       	jmp    801bec <__udivdi3+0x4c>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	66 90                	xchg   %ax,%ax
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 d2                	test   %edx,%edx
  801ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f3                	mov    %esi,%ebx
  801cf3:	89 3c 24             	mov    %edi,(%esp)
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	75 1c                	jne    801d18 <__umoddi3+0x48>
  801cfc:	39 f7                	cmp    %esi,%edi
  801cfe:	76 50                	jbe    801d50 <__umoddi3+0x80>
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	f7 f7                	div    %edi
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	31 d2                	xor    %edx,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	39 f2                	cmp    %esi,%edx
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	77 52                	ja     801d70 <__umoddi3+0xa0>
  801d1e:	0f bd ea             	bsr    %edx,%ebp
  801d21:	83 f5 1f             	xor    $0x1f,%ebp
  801d24:	75 5a                	jne    801d80 <__umoddi3+0xb0>
  801d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d2a:	0f 82 e0 00 00 00    	jb     801e10 <__umoddi3+0x140>
  801d30:	39 0c 24             	cmp    %ecx,(%esp)
  801d33:	0f 86 d7 00 00 00    	jbe    801e10 <__umoddi3+0x140>
  801d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d41:	83 c4 1c             	add    $0x1c,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	85 ff                	test   %edi,%edi
  801d52:	89 fd                	mov    %edi,%ebp
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x91>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f7                	div    %edi
  801d5f:	89 c5                	mov    %eax,%ebp
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f5                	div    %ebp
  801d67:	89 c8                	mov    %ecx,%eax
  801d69:	f7 f5                	div    %ebp
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	eb 99                	jmp    801d08 <__umoddi3+0x38>
  801d6f:	90                   	nop
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 1c             	add    $0x1c,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	8b 34 24             	mov    (%esp),%esi
  801d83:	bf 20 00 00 00       	mov    $0x20,%edi
  801d88:	89 e9                	mov    %ebp,%ecx
  801d8a:	29 ef                	sub    %ebp,%edi
  801d8c:	d3 e0                	shl    %cl,%eax
  801d8e:	89 f9                	mov    %edi,%ecx
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	d3 ea                	shr    %cl,%edx
  801d94:	89 e9                	mov    %ebp,%ecx
  801d96:	09 c2                	or     %eax,%edx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 14 24             	mov    %edx,(%esp)
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	d3 e2                	shl    %cl,%edx
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dab:	d3 e8                	shr    %cl,%eax
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	d3 e3                	shl    %cl,%ebx
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 d0                	mov    %edx,%eax
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	09 d8                	or     %ebx,%eax
  801dbd:	89 d3                	mov    %edx,%ebx
  801dbf:	89 f2                	mov    %esi,%edx
  801dc1:	f7 34 24             	divl   (%esp)
  801dc4:	89 d6                	mov    %edx,%esi
  801dc6:	d3 e3                	shl    %cl,%ebx
  801dc8:	f7 64 24 04          	mull   0x4(%esp)
  801dcc:	39 d6                	cmp    %edx,%esi
  801dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd2:	89 d1                	mov    %edx,%ecx
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	72 08                	jb     801de0 <__umoddi3+0x110>
  801dd8:	75 11                	jne    801deb <__umoddi3+0x11b>
  801dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dde:	73 0b                	jae    801deb <__umoddi3+0x11b>
  801de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801de4:	1b 14 24             	sbb    (%esp),%edx
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801def:	29 da                	sub    %ebx,%edx
  801df1:	19 ce                	sbb    %ecx,%esi
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	d3 e0                	shl    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	d3 ea                	shr    %cl,%edx
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 ee                	shr    %cl,%esi
  801e01:	09 d0                	or     %edx,%eax
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	29 f9                	sub    %edi,%ecx
  801e12:	19 d6                	sbb    %edx,%esi
  801e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1c:	e9 18 ff ff ff       	jmp    801d39 <__umoddi3+0x69>
