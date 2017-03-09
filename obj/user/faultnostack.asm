
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ad 04 00 00       	call   800552 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ca 1e 80 00       	push   $0x801eca
  80011e:	6a 23                	push   $0x23
  800120:	68 e7 1e 80 00       	push   $0x801ee7
  800125:	e8 1b 0f 00 00       	call   801045 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ca 1e 80 00       	push   $0x801eca
  80019f:	6a 23                	push   $0x23
  8001a1:	68 e7 1e 80 00       	push   $0x801ee7
  8001a6:	e8 9a 0e 00 00       	call   801045 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ca 1e 80 00       	push   $0x801eca
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 e7 1e 80 00       	push   $0x801ee7
  8001e8:	e8 58 0e 00 00       	call   801045 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ca 1e 80 00       	push   $0x801eca
  800223:	6a 23                	push   $0x23
  800225:	68 e7 1e 80 00       	push   $0x801ee7
  80022a:	e8 16 0e 00 00       	call   801045 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ca 1e 80 00       	push   $0x801eca
  800265:	6a 23                	push   $0x23
  800267:	68 e7 1e 80 00       	push   $0x801ee7
  80026c:	e8 d4 0d 00 00       	call   801045 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 ca 1e 80 00       	push   $0x801eca
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 e7 1e 80 00       	push   $0x801ee7
  8002ae:	e8 92 0d 00 00       	call   801045 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 ca 1e 80 00       	push   $0x801eca
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 e7 1e 80 00       	push   $0x801ee7
  8002f0:	e8 50 0d 00 00       	call   801045 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 ca 1e 80 00       	push   $0x801eca
  80034d:	6a 23                	push   $0x23
  80034f:	68 e7 1e 80 00       	push   $0x801ee7
  800354:	e8 ec 0c 00 00       	call   801045 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp      // pop utf_fault_va and utf_err
  80036c:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax  // eax <- [esp + 32]
  80036f:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %ebx  // ebx <- [esp + 40]
  800373:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	leal -4(%ebx), %ebx  // ebx <- ebx - 4
  800377:	8d 5b fc             	lea    -0x4(%ebx),%ebx
	movl %eax, (%ebx)
  80037a:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 40(%esp)  // push trap eip and decrement trap esp manually
  80037c:	89 5c 24 28          	mov    %ebx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800380:	61                   	popa   
	addl $4, %esp        // skip eip
  800381:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popf
  800384:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  800385:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800386:	c3                   	ret    

00800387 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	05 00 00 00 30       	add    $0x30000000,%eax
  800392:	c1 e8 0c             	shr    $0xc,%eax
}
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 16             	shr    $0x16,%edx
  8003be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	74 11                	je     8003db <fd_alloc+0x2d>
  8003ca:	89 c2                	mov    %eax,%edx
  8003cc:	c1 ea 0c             	shr    $0xc,%edx
  8003cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d6:	f6 c2 01             	test   $0x1,%dl
  8003d9:	75 09                	jne    8003e4 <fd_alloc+0x36>
			*fd_store = fd;
  8003db:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e2:	eb 17                	jmp    8003fb <fd_alloc+0x4d>
  8003e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ee:	75 c9                	jne    8003b9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800403:	83 f8 1f             	cmp    $0x1f,%eax
  800406:	77 36                	ja     80043e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800408:	c1 e0 0c             	shl    $0xc,%eax
  80040b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 16             	shr    $0x16,%edx
  800415:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 24                	je     800445 <fd_lookup+0x48>
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 ea 0c             	shr    $0xc,%edx
  800426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042d:	f6 c2 01             	test   $0x1,%dl
  800430:	74 1a                	je     80044c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 02                	mov    %eax,(%edx)
	return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 13                	jmp    800451 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800443:	eb 0c                	jmp    800451 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044a:	eb 05                	jmp    800451 <fd_lookup+0x54>
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800451:	5d                   	pop    %ebp
  800452:	c3                   	ret    

00800453 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045c:	ba 74 1f 80 00       	mov    $0x801f74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	eb 13                	jmp    800476 <dev_lookup+0x23>
  800463:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800466:	39 08                	cmp    %ecx,(%eax)
  800468:	75 0c                	jne    800476 <dev_lookup+0x23>
			*dev = devtab[i];
  80046a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	eb 2e                	jmp    8004a4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800476:	8b 02                	mov    (%edx),%eax
  800478:	85 c0                	test   %eax,%eax
  80047a:	75 e7                	jne    800463 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047c:	a1 04 40 80 00       	mov    0x804004,%eax
  800481:	8b 40 48             	mov    0x48(%eax),%eax
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	51                   	push   %ecx
  800488:	50                   	push   %eax
  800489:	68 f8 1e 80 00       	push   $0x801ef8
  80048e:	e8 8b 0c 00 00       	call   80111e <cprintf>
	*dev = 0;
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
  800496:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	56                   	push   %esi
  8004aa:	53                   	push   %ebx
  8004ab:	83 ec 10             	sub    $0x10,%esp
  8004ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004be:	c1 e8 0c             	shr    $0xc,%eax
  8004c1:	50                   	push   %eax
  8004c2:	e8 36 ff ff ff       	call   8003fd <fd_lookup>
  8004c7:	83 c4 08             	add    $0x8,%esp
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	78 05                	js     8004d3 <fd_close+0x2d>
	    || fd != fd2)
  8004ce:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d1:	74 0c                	je     8004df <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d3:	84 db                	test   %bl,%bl
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004da:	0f 44 c2             	cmove  %edx,%eax
  8004dd:	eb 41                	jmp    800520 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e5:	50                   	push   %eax
  8004e6:	ff 36                	pushl  (%esi)
  8004e8:	e8 66 ff ff ff       	call   800453 <dev_lookup>
  8004ed:	89 c3                	mov    %eax,%ebx
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	78 1a                	js     800510 <fd_close+0x6a>
		if (dev->dev_close)
  8004f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800501:	85 c0                	test   %eax,%eax
  800503:	74 0b                	je     800510 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800505:	83 ec 0c             	sub    $0xc,%esp
  800508:	56                   	push   %esi
  800509:	ff d0                	call   *%eax
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 00                	push   $0x0
  800516:	e8 da fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	89 d8                	mov    %ebx,%eax
}
  800520:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800523:	5b                   	pop    %ebx
  800524:	5e                   	pop    %esi
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800530:	50                   	push   %eax
  800531:	ff 75 08             	pushl  0x8(%ebp)
  800534:	e8 c4 fe ff ff       	call   8003fd <fd_lookup>
  800539:	83 c4 08             	add    $0x8,%esp
  80053c:	85 c0                	test   %eax,%eax
  80053e:	78 10                	js     800550 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	6a 01                	push   $0x1
  800545:	ff 75 f4             	pushl  -0xc(%ebp)
  800548:	e8 59 ff ff ff       	call   8004a6 <fd_close>
  80054d:	83 c4 10             	add    $0x10,%esp
}
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <close_all>:

void
close_all(void)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	53                   	push   %ebx
  800556:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800559:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	53                   	push   %ebx
  800562:	e8 c0 ff ff ff       	call   800527 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800567:	83 c3 01             	add    $0x1,%ebx
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	83 fb 20             	cmp    $0x20,%ebx
  800570:	75 ec                	jne    80055e <close_all+0xc>
		close(i);
}
  800572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	57                   	push   %edi
  80057b:	56                   	push   %esi
  80057c:	53                   	push   %ebx
  80057d:	83 ec 2c             	sub    $0x2c,%esp
  800580:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800583:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800586:	50                   	push   %eax
  800587:	ff 75 08             	pushl  0x8(%ebp)
  80058a:	e8 6e fe ff ff       	call   8003fd <fd_lookup>
  80058f:	83 c4 08             	add    $0x8,%esp
  800592:	85 c0                	test   %eax,%eax
  800594:	0f 88 c1 00 00 00    	js     80065b <dup+0xe4>
		return r;
	close(newfdnum);
  80059a:	83 ec 0c             	sub    $0xc,%esp
  80059d:	56                   	push   %esi
  80059e:	e8 84 ff ff ff       	call   800527 <close>

	newfd = INDEX2FD(newfdnum);
  8005a3:	89 f3                	mov    %esi,%ebx
  8005a5:	c1 e3 0c             	shl    $0xc,%ebx
  8005a8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ae:	83 c4 04             	add    $0x4,%esp
  8005b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b4:	e8 de fd ff ff       	call   800397 <fd2data>
  8005b9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005bb:	89 1c 24             	mov    %ebx,(%esp)
  8005be:	e8 d4 fd ff ff       	call   800397 <fd2data>
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c9:	89 f8                	mov    %edi,%eax
  8005cb:	c1 e8 16             	shr    $0x16,%eax
  8005ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d5:	a8 01                	test   $0x1,%al
  8005d7:	74 37                	je     800610 <dup+0x99>
  8005d9:	89 f8                	mov    %edi,%eax
  8005db:	c1 e8 0c             	shr    $0xc,%eax
  8005de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e5:	f6 c2 01             	test   $0x1,%dl
  8005e8:	74 26                	je     800610 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f9:	50                   	push   %eax
  8005fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fd:	6a 00                	push   $0x0
  8005ff:	57                   	push   %edi
  800600:	6a 00                	push   $0x0
  800602:	e8 ac fb ff ff       	call   8001b3 <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
  80060c:	85 c0                	test   %eax,%eax
  80060e:	78 2e                	js     80063e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800613:	89 d0                	mov    %edx,%eax
  800615:	c1 e8 0c             	shr    $0xc,%eax
  800618:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061f:	83 ec 0c             	sub    $0xc,%esp
  800622:	25 07 0e 00 00       	and    $0xe07,%eax
  800627:	50                   	push   %eax
  800628:	53                   	push   %ebx
  800629:	6a 00                	push   $0x0
  80062b:	52                   	push   %edx
  80062c:	6a 00                	push   $0x0
  80062e:	e8 80 fb ff ff       	call   8001b3 <sys_page_map>
  800633:	89 c7                	mov    %eax,%edi
  800635:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800638:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063a:	85 ff                	test   %edi,%edi
  80063c:	79 1d                	jns    80065b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 00                	push   $0x0
  800644:	e8 ac fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064f:	6a 00                	push   $0x0
  800651:	e8 9f fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	89 f8                	mov    %edi,%eax
}
  80065b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	53                   	push   %ebx
  800667:	83 ec 14             	sub    $0x14,%esp
  80066a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800670:	50                   	push   %eax
  800671:	53                   	push   %ebx
  800672:	e8 86 fd ff ff       	call   8003fd <fd_lookup>
  800677:	83 c4 08             	add    $0x8,%esp
  80067a:	89 c2                	mov    %eax,%edx
  80067c:	85 c0                	test   %eax,%eax
  80067e:	78 6d                	js     8006ed <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800686:	50                   	push   %eax
  800687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068a:	ff 30                	pushl  (%eax)
  80068c:	e8 c2 fd ff ff       	call   800453 <dev_lookup>
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	85 c0                	test   %eax,%eax
  800696:	78 4c                	js     8006e4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800698:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069b:	8b 42 08             	mov    0x8(%edx),%eax
  80069e:	83 e0 03             	and    $0x3,%eax
  8006a1:	83 f8 01             	cmp    $0x1,%eax
  8006a4:	75 21                	jne    8006c7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ab:	8b 40 48             	mov    0x48(%eax),%eax
  8006ae:	83 ec 04             	sub    $0x4,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	50                   	push   %eax
  8006b3:	68 39 1f 80 00       	push   $0x801f39
  8006b8:	e8 61 0a 00 00       	call   80111e <cprintf>
		return -E_INVAL;
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c5:	eb 26                	jmp    8006ed <read+0x8a>
	}
	if (!dev->dev_read)
  8006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ca:	8b 40 08             	mov    0x8(%eax),%eax
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	74 17                	je     8006e8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	52                   	push   %edx
  8006db:	ff d0                	call   *%eax
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 09                	jmp    8006ed <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	eb 05                	jmp    8006ed <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ed:	89 d0                	mov    %edx,%eax
  8006ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800700:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800703:	bb 00 00 00 00       	mov    $0x0,%ebx
  800708:	eb 21                	jmp    80072b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070a:	83 ec 04             	sub    $0x4,%esp
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	29 d8                	sub    %ebx,%eax
  800711:	50                   	push   %eax
  800712:	89 d8                	mov    %ebx,%eax
  800714:	03 45 0c             	add    0xc(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	57                   	push   %edi
  800719:	e8 45 ff ff ff       	call   800663 <read>
		if (m < 0)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	85 c0                	test   %eax,%eax
  800723:	78 10                	js     800735 <readn+0x41>
			return m;
		if (m == 0)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 0a                	je     800733 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800729:	01 c3                	add    %eax,%ebx
  80072b:	39 f3                	cmp    %esi,%ebx
  80072d:	72 db                	jb     80070a <readn+0x16>
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	eb 02                	jmp    800735 <readn+0x41>
  800733:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800735:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	83 ec 14             	sub    $0x14,%esp
  800744:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800747:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	53                   	push   %ebx
  80074c:	e8 ac fc ff ff       	call   8003fd <fd_lookup>
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	89 c2                	mov    %eax,%edx
  800756:	85 c0                	test   %eax,%eax
  800758:	78 68                	js     8007c2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	ff 30                	pushl  (%eax)
  800766:	e8 e8 fc ff ff       	call   800453 <dev_lookup>
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 47                	js     8007b9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800775:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800779:	75 21                	jne    80079c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077b:	a1 04 40 80 00       	mov    0x804004,%eax
  800780:	8b 40 48             	mov    0x48(%eax),%eax
  800783:	83 ec 04             	sub    $0x4,%esp
  800786:	53                   	push   %ebx
  800787:	50                   	push   %eax
  800788:	68 55 1f 80 00       	push   $0x801f55
  80078d:	e8 8c 09 00 00       	call   80111e <cprintf>
		return -E_INVAL;
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80079a:	eb 26                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079f:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	74 17                	je     8007bd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a6:	83 ec 04             	sub    $0x4,%esp
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	50                   	push   %eax
  8007b0:	ff d2                	call   *%edx
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 09                	jmp    8007c2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	eb 05                	jmp    8007c2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c2:	89 d0                	mov    %edx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	ff 75 08             	pushl  0x8(%ebp)
  8007d6:	e8 22 fc ff ff       	call   8003fd <fd_lookup>
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 0e                	js     8007f0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 14             	sub    $0x14,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	50                   	push   %eax
  800800:	53                   	push   %ebx
  800801:	e8 f7 fb ff ff       	call   8003fd <fd_lookup>
  800806:	83 c4 08             	add    $0x8,%esp
  800809:	89 c2                	mov    %eax,%edx
  80080b:	85 c0                	test   %eax,%eax
  80080d:	78 65                	js     800874 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800815:	50                   	push   %eax
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	ff 30                	pushl  (%eax)
  80081b:	e8 33 fc ff ff       	call   800453 <dev_lookup>
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	85 c0                	test   %eax,%eax
  800825:	78 44                	js     80086b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082e:	75 21                	jne    800851 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800830:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800835:	8b 40 48             	mov    0x48(%eax),%eax
  800838:	83 ec 04             	sub    $0x4,%esp
  80083b:	53                   	push   %ebx
  80083c:	50                   	push   %eax
  80083d:	68 18 1f 80 00       	push   $0x801f18
  800842:	e8 d7 08 00 00       	call   80111e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084f:	eb 23                	jmp    800874 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800851:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800854:	8b 52 18             	mov    0x18(%edx),%edx
  800857:	85 d2                	test   %edx,%edx
  800859:	74 14                	je     80086f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	50                   	push   %eax
  800862:	ff d2                	call   *%edx
  800864:	89 c2                	mov    %eax,%edx
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	eb 09                	jmp    800874 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	eb 05                	jmp    800874 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800874:	89 d0                	mov    %edx,%eax
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 14             	sub    $0x14,%esp
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	ff 75 08             	pushl  0x8(%ebp)
  80088c:	e8 6c fb ff ff       	call   8003fd <fd_lookup>
  800891:	83 c4 08             	add    $0x8,%esp
  800894:	89 c2                	mov    %eax,%edx
  800896:	85 c0                	test   %eax,%eax
  800898:	78 58                	js     8008f2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a4:	ff 30                	pushl  (%eax)
  8008a6:	e8 a8 fb ff ff       	call   800453 <dev_lookup>
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 37                	js     8008e9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b9:	74 32                	je     8008ed <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c5:	00 00 00 
	stat->st_isdir = 0;
  8008c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cf:	00 00 00 
	stat->st_dev = dev;
  8008d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008df:	ff 50 14             	call   *0x14(%eax)
  8008e2:	89 c2                	mov    %eax,%edx
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 09                	jmp    8008f2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	eb 05                	jmp    8008f2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	6a 00                	push   $0x0
  800903:	ff 75 08             	pushl  0x8(%ebp)
  800906:	e8 b7 01 00 00       	call   800ac2 <open>
  80090b:	89 c3                	mov    %eax,%ebx
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	85 c0                	test   %eax,%eax
  800912:	78 1b                	js     80092f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	50                   	push   %eax
  80091b:	e8 5b ff ff ff       	call   80087b <fstat>
  800920:	89 c6                	mov    %eax,%esi
	close(fd);
  800922:	89 1c 24             	mov    %ebx,(%esp)
  800925:	e8 fd fb ff ff       	call   800527 <close>
	return r;
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	89 f0                	mov    %esi,%eax
}
  80092f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	89 c6                	mov    %eax,%esi
  80093d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800946:	75 12                	jne    80095a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800948:	83 ec 0c             	sub    $0xc,%esp
  80094b:	6a 01                	push   $0x1
  80094d:	e8 52 12 00 00       	call   801ba4 <ipc_find_env>
  800952:	a3 00 40 80 00       	mov    %eax,0x804000
  800957:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095a:	6a 07                	push   $0x7
  80095c:	68 00 50 80 00       	push   $0x805000
  800961:	56                   	push   %esi
  800962:	ff 35 00 40 80 00    	pushl  0x804000
  800968:	e8 e3 11 00 00       	call   801b50 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096d:	83 c4 0c             	add    $0xc,%esp
  800970:	6a 00                	push   $0x0
  800972:	53                   	push   %ebx
  800973:	6a 00                	push   $0x0
  800975:	e8 61 11 00 00       	call   801adb <ipc_recv>
}
  80097a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 40 0c             	mov    0xc(%eax),%eax
  80098d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a4:	e8 8d ff ff ff       	call   800936 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c6:	e8 6b ff ff ff       	call   800936 <fsipc>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ec:	e8 45 ff ff ff       	call   800936 <fsipc>
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	78 2c                	js     800a21 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f5:	83 ec 08             	sub    $0x8,%esp
  8009f8:	68 00 50 80 00       	push   $0x805000
  8009fd:	53                   	push   %ebx
  8009fe:	e8 47 0d 00 00       	call   80174a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a03:	a1 80 50 80 00       	mov    0x805080,%eax
  800a08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a13:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a19:	83 c4 10             	add    $0x10,%esp
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800a2c:	68 84 1f 80 00       	push   $0x801f84
  800a31:	68 90 00 00 00       	push   $0x90
  800a36:	68 a2 1f 80 00       	push   $0x801fa2
  800a3b:	e8 05 06 00 00       	call   801045 <_panic>

00800a40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a53:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a63:	e8 ce fe ff ff       	call   800936 <fsipc>
  800a68:	89 c3                	mov    %eax,%ebx
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	78 4b                	js     800ab9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6e:	39 c6                	cmp    %eax,%esi
  800a70:	73 16                	jae    800a88 <devfile_read+0x48>
  800a72:	68 ad 1f 80 00       	push   $0x801fad
  800a77:	68 b4 1f 80 00       	push   $0x801fb4
  800a7c:	6a 7c                	push   $0x7c
  800a7e:	68 a2 1f 80 00       	push   $0x801fa2
  800a83:	e8 bd 05 00 00       	call   801045 <_panic>
	assert(r <= PGSIZE);
  800a88:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8d:	7e 16                	jle    800aa5 <devfile_read+0x65>
  800a8f:	68 c9 1f 80 00       	push   $0x801fc9
  800a94:	68 b4 1f 80 00       	push   $0x801fb4
  800a99:	6a 7d                	push   $0x7d
  800a9b:	68 a2 1f 80 00       	push   $0x801fa2
  800aa0:	e8 a0 05 00 00       	call   801045 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa5:	83 ec 04             	sub    $0x4,%esp
  800aa8:	50                   	push   %eax
  800aa9:	68 00 50 80 00       	push   $0x805000
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	e8 26 0e 00 00       	call   8018dc <memmove>
	return r;
  800ab6:	83 c4 10             	add    $0x10,%esp
}
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 20             	sub    $0x20,%esp
  800ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800acc:	53                   	push   %ebx
  800acd:	e8 3f 0c 00 00       	call   801711 <strlen>
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ada:	7f 67                	jg     800b43 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae2:	50                   	push   %eax
  800ae3:	e8 c6 f8 ff ff       	call   8003ae <fd_alloc>
  800ae8:	83 c4 10             	add    $0x10,%esp
		return r;
  800aeb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aed:	85 c0                	test   %eax,%eax
  800aef:	78 57                	js     800b48 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	53                   	push   %ebx
  800af5:	68 00 50 80 00       	push   $0x805000
  800afa:	e8 4b 0c 00 00       	call   80174a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	e8 22 fe ff ff       	call   800936 <fsipc>
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	79 14                	jns    800b31 <open+0x6f>
		fd_close(fd, 0);
  800b1d:	83 ec 08             	sub    $0x8,%esp
  800b20:	6a 00                	push   $0x0
  800b22:	ff 75 f4             	pushl  -0xc(%ebp)
  800b25:	e8 7c f9 ff ff       	call   8004a6 <fd_close>
		return r;
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	89 da                	mov    %ebx,%edx
  800b2f:	eb 17                	jmp    800b48 <open+0x86>
	}

	return fd2num(fd);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 4b f8 ff ff       	call   800387 <fd2num>
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	eb 05                	jmp    800b48 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b43:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b48:	89 d0                	mov    %edx,%eax
  800b4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5f:	e8 d2 fd ff ff       	call   800936 <fsipc>
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	ff 75 08             	pushl  0x8(%ebp)
  800b74:	e8 1e f8 ff ff       	call   800397 <fd2data>
  800b79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7b:	83 c4 08             	add    $0x8,%esp
  800b7e:	68 d5 1f 80 00       	push   $0x801fd5
  800b83:	53                   	push   %ebx
  800b84:	e8 c1 0b 00 00       	call   80174a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b89:	8b 46 04             	mov    0x4(%esi),%eax
  800b8c:	2b 06                	sub    (%esi),%eax
  800b8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9b:	00 00 00 
	stat->st_dev = &devpipe;
  800b9e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba5:	30 80 00 
	return 0;
}
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbe:	53                   	push   %ebx
  800bbf:	6a 00                	push   $0x0
  800bc1:	e8 2f f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc6:	89 1c 24             	mov    %ebx,(%esp)
  800bc9:	e8 c9 f7 ff ff       	call   800397 <fd2data>
  800bce:	83 c4 08             	add    $0x8,%esp
  800bd1:	50                   	push   %eax
  800bd2:	6a 00                	push   $0x0
  800bd4:	e8 1c f6 ff ff       	call   8001f5 <sys_page_unmap>
}
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 1c             	sub    $0x1c,%esp
  800be7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bea:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bec:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bfa:	e8 de 0f 00 00       	call   801bdd <pageref>
  800bff:	89 c3                	mov    %eax,%ebx
  800c01:	89 3c 24             	mov    %edi,(%esp)
  800c04:	e8 d4 0f 00 00       	call   801bdd <pageref>
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	39 c3                	cmp    %eax,%ebx
  800c0e:	0f 94 c1             	sete   %cl
  800c11:	0f b6 c9             	movzbl %cl,%ecx
  800c14:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c17:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c20:	39 ce                	cmp    %ecx,%esi
  800c22:	74 1b                	je     800c3f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c24:	39 c3                	cmp    %eax,%ebx
  800c26:	75 c4                	jne    800bec <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c28:	8b 42 58             	mov    0x58(%edx),%eax
  800c2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2e:	50                   	push   %eax
  800c2f:	56                   	push   %esi
  800c30:	68 dc 1f 80 00       	push   $0x801fdc
  800c35:	e8 e4 04 00 00       	call   80111e <cprintf>
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb ad                	jmp    800bec <_pipeisclosed+0xe>
	}
}
  800c3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 28             	sub    $0x28,%esp
  800c53:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c56:	56                   	push   %esi
  800c57:	e8 3b f7 ff ff       	call   800397 <fd2data>
  800c5c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
  800c66:	eb 4b                	jmp    800cb3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c68:	89 da                	mov    %ebx,%edx
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	e8 6d ff ff ff       	call   800bde <_pipeisclosed>
  800c71:	85 c0                	test   %eax,%eax
  800c73:	75 48                	jne    800cbd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c75:	e8 d7 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7d:	8b 0b                	mov    (%ebx),%ecx
  800c7f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c82:	39 d0                	cmp    %edx,%eax
  800c84:	73 e2                	jae    800c68 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	c1 fa 1f             	sar    $0x1f,%edx
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9d:	83 e2 1f             	and    $0x1f,%edx
  800ca0:	29 ca                	sub    %ecx,%edx
  800ca2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800caa:	83 c0 01             	add    $0x1,%eax
  800cad:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb0:	83 c7 01             	add    $0x1,%edi
  800cb3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb6:	75 c2                	jne    800c7a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbb:	eb 05                	jmp    800cc2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 18             	sub    $0x18,%esp
  800cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd6:	57                   	push   %edi
  800cd7:	e8 bb f6 ff ff       	call   800397 <fd2data>
  800cdc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cde:	83 c4 10             	add    $0x10,%esp
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	eb 3d                	jmp    800d25 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce8:	85 db                	test   %ebx,%ebx
  800cea:	74 04                	je     800cf0 <devpipe_read+0x26>
				return i;
  800cec:	89 d8                	mov    %ebx,%eax
  800cee:	eb 44                	jmp    800d34 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf0:	89 f2                	mov    %esi,%edx
  800cf2:	89 f8                	mov    %edi,%eax
  800cf4:	e8 e5 fe ff ff       	call   800bde <_pipeisclosed>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	75 32                	jne    800d2f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cfd:	e8 4f f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d02:	8b 06                	mov    (%esi),%eax
  800d04:	3b 46 04             	cmp    0x4(%esi),%eax
  800d07:	74 df                	je     800ce8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d09:	99                   	cltd   
  800d0a:	c1 ea 1b             	shr    $0x1b,%edx
  800d0d:	01 d0                	add    %edx,%eax
  800d0f:	83 e0 1f             	and    $0x1f,%eax
  800d12:	29 d0                	sub    %edx,%eax
  800d14:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d22:	83 c3 01             	add    $0x1,%ebx
  800d25:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d28:	75 d8                	jne    800d02 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2d:	eb 05                	jmp    800d34 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 61 f6 ff ff       	call   8003ae <fd_alloc>
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	89 c2                	mov    %eax,%edx
  800d52:	85 c0                	test   %eax,%eax
  800d54:	0f 88 2c 01 00 00    	js     800e86 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	68 07 04 00 00       	push   $0x407
  800d62:	ff 75 f4             	pushl  -0xc(%ebp)
  800d65:	6a 00                	push   $0x0
  800d67:	e8 04 f4 ff ff       	call   800170 <sys_page_alloc>
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 0d 01 00 00    	js     800e86 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 29 f6 ff ff       	call   8003ae <fd_alloc>
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 e2 00 00 00    	js     800e74 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 cc f3 ff ff       	call   800170 <sys_page_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 c3 00 00 00    	js     800e74 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	ff 75 f4             	pushl  -0xc(%ebp)
  800db7:	e8 db f5 ff ff       	call   800397 <fd2data>
  800dbc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbe:	83 c4 0c             	add    $0xc,%esp
  800dc1:	68 07 04 00 00       	push   $0x407
  800dc6:	50                   	push   %eax
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 a2 f3 ff ff       	call   800170 <sys_page_alloc>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	0f 88 89 00 00 00    	js     800e64 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	ff 75 f0             	pushl  -0x10(%ebp)
  800de1:	e8 b1 f5 ff ff       	call   800397 <fd2data>
  800de6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ded:	50                   	push   %eax
  800dee:	6a 00                	push   $0x0
  800df0:	56                   	push   %esi
  800df1:	6a 00                	push   $0x0
  800df3:	e8 bb f3 ff ff       	call   8001b3 <sys_page_map>
  800df8:	89 c3                	mov    %eax,%ebx
  800dfa:	83 c4 20             	add    $0x20,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	78 55                	js     800e56 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e16:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e24:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e31:	e8 51 f5 ff ff       	call   800387 <fd2num>
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3b:	83 c4 04             	add    $0x4,%esp
  800e3e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e41:	e8 41 f5 ff ff       	call   800387 <fd2num>
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e54:	eb 30                	jmp    800e86 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	56                   	push   %esi
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 94 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e61:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 84 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 74 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e98:	50                   	push   %eax
  800e99:	ff 75 08             	pushl  0x8(%ebp)
  800e9c:	e8 5c f5 ff ff       	call   8003fd <fd_lookup>
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 18                	js     800ec0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	e8 e4 f4 ff ff       	call   800397 <fd2data>
	return _pipeisclosed(fd, p);
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb8:	e8 21 fd ff ff       	call   800bde <_pipeisclosed>
  800ebd:	83 c4 10             	add    $0x10,%esp
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed2:	68 f4 1f 80 00       	push   $0x801ff4
  800ed7:	ff 75 0c             	pushl  0xc(%ebp)
  800eda:	e8 6b 08 00 00       	call   80174a <strcpy>
	return 0;
}
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efd:	eb 2d                	jmp    800f2c <devcons_write+0x46>
		m = n - tot;
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f04:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f07:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f0c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	53                   	push   %ebx
  800f13:	03 45 0c             	add    0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	57                   	push   %edi
  800f18:	e8 bf 09 00 00       	call   8018dc <memmove>
		sys_cputs(buf, m);
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	53                   	push   %ebx
  800f21:	57                   	push   %edi
  800f22:	e8 8d f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f27:	01 de                	add    %ebx,%esi
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	89 f0                	mov    %esi,%eax
  800f2e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f31:	72 cc                	jb     800eff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4a:	74 2a                	je     800f76 <devcons_read+0x3b>
  800f4c:	eb 05                	jmp    800f53 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f4e:	e8 fe f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f53:	e8 7a f1 ff ff       	call   8000d2 <sys_cgetc>
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	74 f2                	je     800f4e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 16                	js     800f76 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f60:	83 f8 04             	cmp    $0x4,%eax
  800f63:	74 0c                	je     800f71 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f68:	88 02                	mov    %al,(%edx)
	return 1;
  800f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6f:	eb 05                	jmp    800f76 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f84:	6a 01                	push   $0x1
  800f86:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	e8 25 f1 ff ff       	call   8000b4 <sys_cputs>
}
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <getchar>:

int
getchar(void)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f9a:	6a 01                	push   $0x1
  800f9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 bc f6 ff ff       	call   800663 <read>
	if (r < 0)
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 0f                	js     800fbd <getchar+0x29>
		return r;
	if (r < 1)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 06                	jle    800fb8 <getchar+0x24>
		return -E_EOF;
	return c;
  800fb2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb6:	eb 05                	jmp    800fbd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 2c f4 ff ff       	call   8003fd <fd_lookup>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 11                	js     800fe9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe1:	39 10                	cmp    %edx,(%eax)
  800fe3:	0f 94 c0             	sete   %al
  800fe6:	0f b6 c0             	movzbl %al,%eax
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <opencons>:

int
opencons(void)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	e8 b4 f3 ff ff       	call   8003ae <fd_alloc>
  800ffa:	83 c4 10             	add    $0x10,%esp
		return r;
  800ffd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 3e                	js     801041 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801003:	83 ec 04             	sub    $0x4,%esp
  801006:	68 07 04 00 00       	push   $0x407
  80100b:	ff 75 f4             	pushl  -0xc(%ebp)
  80100e:	6a 00                	push   $0x0
  801010:	e8 5b f1 ff ff       	call   800170 <sys_page_alloc>
  801015:	83 c4 10             	add    $0x10,%esp
		return r;
  801018:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 23                	js     801041 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80101e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801027:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	50                   	push   %eax
  801037:	e8 4b f3 ff ff       	call   800387 <fd2num>
  80103c:	89 c2                	mov    %eax,%edx
  80103e:	83 c4 10             	add    $0x10,%esp
}
  801041:	89 d0                	mov    %edx,%eax
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801053:	e8 da f0 ff ff       	call   800132 <sys_getenvid>
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	ff 75 08             	pushl  0x8(%ebp)
  801061:	56                   	push   %esi
  801062:	50                   	push   %eax
  801063:	68 00 20 80 00       	push   $0x802000
  801068:	e8 b1 00 00 00       	call   80111e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106d:	83 c4 18             	add    $0x18,%esp
  801070:	53                   	push   %ebx
  801071:	ff 75 10             	pushl  0x10(%ebp)
  801074:	e8 54 00 00 00       	call   8010cd <vcprintf>
	cprintf("\n");
  801079:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  801080:	e8 99 00 00 00       	call   80111e <cprintf>
  801085:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801088:	cc                   	int3   
  801089:	eb fd                	jmp    801088 <_panic+0x43>

0080108b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	53                   	push   %ebx
  80108f:	83 ec 04             	sub    $0x4,%esp
  801092:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801095:	8b 13                	mov    (%ebx),%edx
  801097:	8d 42 01             	lea    0x1(%edx),%eax
  80109a:	89 03                	mov    %eax,(%ebx)
  80109c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a8:	75 1a                	jne    8010c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	68 ff 00 00 00       	push   $0xff
  8010b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b5:	50                   	push   %eax
  8010b6:	e8 f9 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cb:	c9                   	leave  
  8010cc:	c3                   	ret    

008010cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010dd:	00 00 00 
	b.cnt = 0;
  8010e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ea:	ff 75 0c             	pushl  0xc(%ebp)
  8010ed:	ff 75 08             	pushl  0x8(%ebp)
  8010f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	68 8b 10 80 00       	push   $0x80108b
  8010fc:	e8 1a 01 00 00       	call   80121b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80110a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	e8 9e ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801116:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801124:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801127:	50                   	push   %eax
  801128:	ff 75 08             	pushl  0x8(%ebp)
  80112b:	e8 9d ff ff ff       	call   8010cd <vcprintf>
	va_end(ap);

	return cnt;
}
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 1c             	sub    $0x1c,%esp
  80113b:	89 c7                	mov    %eax,%edi
  80113d:	89 d6                	mov    %edx,%esi
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	8b 55 0c             	mov    0xc(%ebp),%edx
  801145:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801148:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80114b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801153:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801156:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801159:	39 d3                	cmp    %edx,%ebx
  80115b:	72 05                	jb     801162 <printnum+0x30>
  80115d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801160:	77 45                	ja     8011a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	ff 75 18             	pushl  0x18(%ebp)
  801168:	8b 45 14             	mov    0x14(%ebp),%eax
  80116b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116e:	53                   	push   %ebx
  80116f:	ff 75 10             	pushl  0x10(%ebp)
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	ff 75 e4             	pushl  -0x1c(%ebp)
  801178:	ff 75 e0             	pushl  -0x20(%ebp)
  80117b:	ff 75 dc             	pushl  -0x24(%ebp)
  80117e:	ff 75 d8             	pushl  -0x28(%ebp)
  801181:	e8 9a 0a 00 00       	call   801c20 <__udivdi3>
  801186:	83 c4 18             	add    $0x18,%esp
  801189:	52                   	push   %edx
  80118a:	50                   	push   %eax
  80118b:	89 f2                	mov    %esi,%edx
  80118d:	89 f8                	mov    %edi,%eax
  80118f:	e8 9e ff ff ff       	call   801132 <printnum>
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	eb 18                	jmp    8011b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	56                   	push   %esi
  80119d:	ff 75 18             	pushl  0x18(%ebp)
  8011a0:	ff d7                	call   *%edi
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	eb 03                	jmp    8011aa <printnum+0x78>
  8011a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011aa:	83 eb 01             	sub    $0x1,%ebx
  8011ad:	85 db                	test   %ebx,%ebx
  8011af:	7f e8                	jg     801199 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	56                   	push   %esi
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011be:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c4:	e8 87 0b 00 00       	call   801d50 <__umoddi3>
  8011c9:	83 c4 14             	add    $0x14,%esp
  8011cc:	0f be 80 23 20 80 00 	movsbl 0x802023(%eax),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff d7                	call   *%edi
}
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011eb:	8b 10                	mov    (%eax),%edx
  8011ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f0:	73 0a                	jae    8011fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f5:	89 08                	mov    %ecx,(%eax)
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fa:	88 02                	mov    %al,(%edx)
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801204:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801207:	50                   	push   %eax
  801208:	ff 75 10             	pushl  0x10(%ebp)
  80120b:	ff 75 0c             	pushl  0xc(%ebp)
  80120e:	ff 75 08             	pushl  0x8(%ebp)
  801211:	e8 05 00 00 00       	call   80121b <vprintfmt>
	va_end(ap);
}
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 2c             	sub    $0x2c,%esp
  801224:	8b 75 08             	mov    0x8(%ebp),%esi
  801227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80122a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122d:	eb 12                	jmp    801241 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80122f:	85 c0                	test   %eax,%eax
  801231:	0f 84 6a 04 00 00    	je     8016a1 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	53                   	push   %ebx
  80123b:	50                   	push   %eax
  80123c:	ff d6                	call   *%esi
  80123e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801241:	83 c7 01             	add    $0x1,%edi
  801244:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801248:	83 f8 25             	cmp    $0x25,%eax
  80124b:	75 e2                	jne    80122f <vprintfmt+0x14>
  80124d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801251:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801258:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80125f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801266:	b9 00 00 00 00       	mov    $0x0,%ecx
  80126b:	eb 07                	jmp    801274 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801270:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801274:	8d 47 01             	lea    0x1(%edi),%eax
  801277:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127a:	0f b6 07             	movzbl (%edi),%eax
  80127d:	0f b6 d0             	movzbl %al,%edx
  801280:	83 e8 23             	sub    $0x23,%eax
  801283:	3c 55                	cmp    $0x55,%al
  801285:	0f 87 fb 03 00 00    	ja     801686 <vprintfmt+0x46b>
  80128b:	0f b6 c0             	movzbl %al,%eax
  80128e:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  801295:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801298:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80129c:	eb d6                	jmp    801274 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ac:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012b0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012b3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012b6:	83 f9 09             	cmp    $0x9,%ecx
  8012b9:	77 3f                	ja     8012fa <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012be:	eb e9                	jmp    8012a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c3:	8b 00                	mov    (%eax),%eax
  8012c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cb:	8d 40 04             	lea    0x4(%eax),%eax
  8012ce:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d4:	eb 2a                	jmp    801300 <vprintfmt+0xe5>
  8012d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e0:	0f 49 d0             	cmovns %eax,%edx
  8012e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e9:	eb 89                	jmp    801274 <vprintfmt+0x59>
  8012eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f5:	e9 7a ff ff ff       	jmp    801274 <vprintfmt+0x59>
  8012fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801300:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801304:	0f 89 6a ff ff ff    	jns    801274 <vprintfmt+0x59>
				width = precision, precision = -1;
  80130a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80130d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801310:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801317:	e9 58 ff ff ff       	jmp    801274 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80131c:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801322:	e9 4d ff ff ff       	jmp    801274 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801327:	8b 45 14             	mov    0x14(%ebp),%eax
  80132a:	8d 78 04             	lea    0x4(%eax),%edi
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	53                   	push   %ebx
  801331:	ff 30                	pushl  (%eax)
  801333:	ff d6                	call   *%esi
			break;
  801335:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801338:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80133e:	e9 fe fe ff ff       	jmp    801241 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801343:	8b 45 14             	mov    0x14(%ebp),%eax
  801346:	8d 78 04             	lea    0x4(%eax),%edi
  801349:	8b 00                	mov    (%eax),%eax
  80134b:	99                   	cltd   
  80134c:	31 d0                	xor    %edx,%eax
  80134e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801350:	83 f8 0f             	cmp    $0xf,%eax
  801353:	7f 0b                	jg     801360 <vprintfmt+0x145>
  801355:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  80135c:	85 d2                	test   %edx,%edx
  80135e:	75 1b                	jne    80137b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801360:	50                   	push   %eax
  801361:	68 3b 20 80 00       	push   $0x80203b
  801366:	53                   	push   %ebx
  801367:	56                   	push   %esi
  801368:	e8 91 fe ff ff       	call   8011fe <printfmt>
  80136d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801370:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801376:	e9 c6 fe ff ff       	jmp    801241 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80137b:	52                   	push   %edx
  80137c:	68 c6 1f 80 00       	push   $0x801fc6
  801381:	53                   	push   %ebx
  801382:	56                   	push   %esi
  801383:	e8 76 fe ff ff       	call   8011fe <printfmt>
  801388:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80138b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801391:	e9 ab fe ff ff       	jmp    801241 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801396:	8b 45 14             	mov    0x14(%ebp),%eax
  801399:	83 c0 04             	add    $0x4,%eax
  80139c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80139f:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013a4:	85 ff                	test   %edi,%edi
  8013a6:	b8 34 20 80 00       	mov    $0x802034,%eax
  8013ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b2:	0f 8e 94 00 00 00    	jle    80144c <vprintfmt+0x231>
  8013b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013bc:	0f 84 98 00 00 00    	je     80145a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c8:	57                   	push   %edi
  8013c9:	e8 5b 03 00 00       	call   801729 <strnlen>
  8013ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013d1:	29 c1                	sub    %eax,%ecx
  8013d3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e5:	eb 0f                	jmp    8013f6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	53                   	push   %ebx
  8013eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f0:	83 ef 01             	sub    $0x1,%edi
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 ff                	test   %edi,%edi
  8013f8:	7f ed                	jg     8013e7 <vprintfmt+0x1cc>
  8013fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013fd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801400:	85 c9                	test   %ecx,%ecx
  801402:	b8 00 00 00 00       	mov    $0x0,%eax
  801407:	0f 49 c1             	cmovns %ecx,%eax
  80140a:	29 c1                	sub    %eax,%ecx
  80140c:	89 75 08             	mov    %esi,0x8(%ebp)
  80140f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801412:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801415:	89 cb                	mov    %ecx,%ebx
  801417:	eb 4d                	jmp    801466 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801419:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80141d:	74 1b                	je     80143a <vprintfmt+0x21f>
  80141f:	0f be c0             	movsbl %al,%eax
  801422:	83 e8 20             	sub    $0x20,%eax
  801425:	83 f8 5e             	cmp    $0x5e,%eax
  801428:	76 10                	jbe    80143a <vprintfmt+0x21f>
					putch('?', putdat);
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	ff 75 0c             	pushl  0xc(%ebp)
  801430:	6a 3f                	push   $0x3f
  801432:	ff 55 08             	call   *0x8(%ebp)
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	eb 0d                	jmp    801447 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	ff 75 0c             	pushl  0xc(%ebp)
  801440:	52                   	push   %edx
  801441:	ff 55 08             	call   *0x8(%ebp)
  801444:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801447:	83 eb 01             	sub    $0x1,%ebx
  80144a:	eb 1a                	jmp    801466 <vprintfmt+0x24b>
  80144c:	89 75 08             	mov    %esi,0x8(%ebp)
  80144f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801452:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801455:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801458:	eb 0c                	jmp    801466 <vprintfmt+0x24b>
  80145a:	89 75 08             	mov    %esi,0x8(%ebp)
  80145d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801460:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801463:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801466:	83 c7 01             	add    $0x1,%edi
  801469:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80146d:	0f be d0             	movsbl %al,%edx
  801470:	85 d2                	test   %edx,%edx
  801472:	74 23                	je     801497 <vprintfmt+0x27c>
  801474:	85 f6                	test   %esi,%esi
  801476:	78 a1                	js     801419 <vprintfmt+0x1fe>
  801478:	83 ee 01             	sub    $0x1,%esi
  80147b:	79 9c                	jns    801419 <vprintfmt+0x1fe>
  80147d:	89 df                	mov    %ebx,%edi
  80147f:	8b 75 08             	mov    0x8(%ebp),%esi
  801482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801485:	eb 18                	jmp    80149f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	53                   	push   %ebx
  80148b:	6a 20                	push   $0x20
  80148d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80148f:	83 ef 01             	sub    $0x1,%edi
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb 08                	jmp    80149f <vprintfmt+0x284>
  801497:	89 df                	mov    %ebx,%edi
  801499:	8b 75 08             	mov    0x8(%ebp),%esi
  80149c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149f:	85 ff                	test   %edi,%edi
  8014a1:	7f e4                	jg     801487 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ac:	e9 90 fd ff ff       	jmp    801241 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014b1:	83 f9 01             	cmp    $0x1,%ecx
  8014b4:	7e 19                	jle    8014cf <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b9:	8b 50 04             	mov    0x4(%eax),%edx
  8014bc:	8b 00                	mov    (%eax),%eax
  8014be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8d 40 08             	lea    0x8(%eax),%eax
  8014ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8014cd:	eb 38                	jmp    801507 <vprintfmt+0x2ec>
	else if (lflag)
  8014cf:	85 c9                	test   %ecx,%ecx
  8014d1:	74 1b                	je     8014ee <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8b 00                	mov    (%eax),%eax
  8014d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014db:	89 c1                	mov    %eax,%ecx
  8014dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e6:	8d 40 04             	lea    0x4(%eax),%eax
  8014e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ec:	eb 19                	jmp    801507 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f1:	8b 00                	mov    (%eax),%eax
  8014f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f6:	89 c1                	mov    %eax,%ecx
  8014f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801501:	8d 40 04             	lea    0x4(%eax),%eax
  801504:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801507:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80150a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80150d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801512:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801516:	0f 89 36 01 00 00    	jns    801652 <vprintfmt+0x437>
				putch('-', putdat);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	53                   	push   %ebx
  801520:	6a 2d                	push   $0x2d
  801522:	ff d6                	call   *%esi
				num = -(long long) num;
  801524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80152a:	f7 da                	neg    %edx
  80152c:	83 d1 00             	adc    $0x0,%ecx
  80152f:	f7 d9                	neg    %ecx
  801531:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801534:	b8 0a 00 00 00       	mov    $0xa,%eax
  801539:	e9 14 01 00 00       	jmp    801652 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80153e:	83 f9 01             	cmp    $0x1,%ecx
  801541:	7e 18                	jle    80155b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801543:	8b 45 14             	mov    0x14(%ebp),%eax
  801546:	8b 10                	mov    (%eax),%edx
  801548:	8b 48 04             	mov    0x4(%eax),%ecx
  80154b:	8d 40 08             	lea    0x8(%eax),%eax
  80154e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801551:	b8 0a 00 00 00       	mov    $0xa,%eax
  801556:	e9 f7 00 00 00       	jmp    801652 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80155b:	85 c9                	test   %ecx,%ecx
  80155d:	74 1a                	je     801579 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80155f:	8b 45 14             	mov    0x14(%ebp),%eax
  801562:	8b 10                	mov    (%eax),%edx
  801564:	b9 00 00 00 00       	mov    $0x0,%ecx
  801569:	8d 40 04             	lea    0x4(%eax),%eax
  80156c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80156f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801574:	e9 d9 00 00 00       	jmp    801652 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801579:	8b 45 14             	mov    0x14(%ebp),%eax
  80157c:	8b 10                	mov    (%eax),%edx
  80157e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801583:	8d 40 04             	lea    0x4(%eax),%eax
  801586:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80158e:	e9 bf 00 00 00       	jmp    801652 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801593:	83 f9 01             	cmp    $0x1,%ecx
  801596:	7e 13                	jle    8015ab <vprintfmt+0x390>
		return va_arg(*ap, long long);
  801598:	8b 45 14             	mov    0x14(%ebp),%eax
  80159b:	8b 50 04             	mov    0x4(%eax),%edx
  80159e:	8b 00                	mov    (%eax),%eax
  8015a0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015a3:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015a6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015a9:	eb 28                	jmp    8015d3 <vprintfmt+0x3b8>
	else if (lflag)
  8015ab:	85 c9                	test   %ecx,%ecx
  8015ad:	74 13                	je     8015c2 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  8015af:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b2:	8b 10                	mov    (%eax),%edx
  8015b4:	89 d0                	mov    %edx,%eax
  8015b6:	99                   	cltd   
  8015b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015ba:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015c0:	eb 11                	jmp    8015d3 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  8015c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c5:	8b 10                	mov    (%eax),%edx
  8015c7:	89 d0                	mov    %edx,%eax
  8015c9:	99                   	cltd   
  8015ca:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015cd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8015d3:	89 d1                	mov    %edx,%ecx
  8015d5:	89 c2                	mov    %eax,%edx
			base = 8;
  8015d7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015dc:	eb 74                	jmp    801652 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	6a 30                	push   $0x30
  8015e4:	ff d6                	call   *%esi
			putch('x', putdat);
  8015e6:	83 c4 08             	add    $0x8,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	6a 78                	push   $0x78
  8015ec:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f1:	8b 10                	mov    (%eax),%edx
  8015f3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015f8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015fb:	8d 40 04             	lea    0x4(%eax),%eax
  8015fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801601:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801606:	eb 4a                	jmp    801652 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801608:	83 f9 01             	cmp    $0x1,%ecx
  80160b:	7e 15                	jle    801622 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  80160d:	8b 45 14             	mov    0x14(%ebp),%eax
  801610:	8b 10                	mov    (%eax),%edx
  801612:	8b 48 04             	mov    0x4(%eax),%ecx
  801615:	8d 40 08             	lea    0x8(%eax),%eax
  801618:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161b:	b8 10 00 00 00       	mov    $0x10,%eax
  801620:	eb 30                	jmp    801652 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801622:	85 c9                	test   %ecx,%ecx
  801624:	74 17                	je     80163d <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  801626:	8b 45 14             	mov    0x14(%ebp),%eax
  801629:	8b 10                	mov    (%eax),%edx
  80162b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801630:	8d 40 04             	lea    0x4(%eax),%eax
  801633:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801636:	b8 10 00 00 00       	mov    $0x10,%eax
  80163b:	eb 15                	jmp    801652 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80163d:	8b 45 14             	mov    0x14(%ebp),%eax
  801640:	8b 10                	mov    (%eax),%edx
  801642:	b9 00 00 00 00       	mov    $0x0,%ecx
  801647:	8d 40 04             	lea    0x4(%eax),%eax
  80164a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80164d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801652:	83 ec 0c             	sub    $0xc,%esp
  801655:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801659:	57                   	push   %edi
  80165a:	ff 75 e0             	pushl  -0x20(%ebp)
  80165d:	50                   	push   %eax
  80165e:	51                   	push   %ecx
  80165f:	52                   	push   %edx
  801660:	89 da                	mov    %ebx,%edx
  801662:	89 f0                	mov    %esi,%eax
  801664:	e8 c9 fa ff ff       	call   801132 <printnum>
			break;
  801669:	83 c4 20             	add    $0x20,%esp
  80166c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80166f:	e9 cd fb ff ff       	jmp    801241 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	53                   	push   %ebx
  801678:	52                   	push   %edx
  801679:	ff d6                	call   *%esi
			break;
  80167b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80167e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801681:	e9 bb fb ff ff       	jmp    801241 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	53                   	push   %ebx
  80168a:	6a 25                	push   $0x25
  80168c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	eb 03                	jmp    801696 <vprintfmt+0x47b>
  801693:	83 ef 01             	sub    $0x1,%edi
  801696:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80169a:	75 f7                	jne    801693 <vprintfmt+0x478>
  80169c:	e9 a0 fb ff ff       	jmp    801241 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5f                   	pop    %edi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	83 ec 18             	sub    $0x18,%esp
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	74 26                	je     8016f0 <vsnprintf+0x47>
  8016ca:	85 d2                	test   %edx,%edx
  8016cc:	7e 22                	jle    8016f0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016ce:	ff 75 14             	pushl  0x14(%ebp)
  8016d1:	ff 75 10             	pushl  0x10(%ebp)
  8016d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	68 e1 11 80 00       	push   $0x8011e1
  8016dd:	e8 39 fb ff ff       	call   80121b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	eb 05                	jmp    8016f5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801700:	50                   	push   %eax
  801701:	ff 75 10             	pushl  0x10(%ebp)
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	ff 75 08             	pushl  0x8(%ebp)
  80170a:	e8 9a ff ff ff       	call   8016a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801717:	b8 00 00 00 00       	mov    $0x0,%eax
  80171c:	eb 03                	jmp    801721 <strlen+0x10>
		n++;
  80171e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801721:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801725:	75 f7                	jne    80171e <strlen+0xd>
		n++;
	return n;
}
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80172f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801732:	ba 00 00 00 00       	mov    $0x0,%edx
  801737:	eb 03                	jmp    80173c <strnlen+0x13>
		n++;
  801739:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80173c:	39 c2                	cmp    %eax,%edx
  80173e:	74 08                	je     801748 <strnlen+0x1f>
  801740:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801744:	75 f3                	jne    801739 <strnlen+0x10>
  801746:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801754:	89 c2                	mov    %eax,%edx
  801756:	83 c2 01             	add    $0x1,%edx
  801759:	83 c1 01             	add    $0x1,%ecx
  80175c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801760:	88 5a ff             	mov    %bl,-0x1(%edx)
  801763:	84 db                	test   %bl,%bl
  801765:	75 ef                	jne    801756 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801767:	5b                   	pop    %ebx
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801771:	53                   	push   %ebx
  801772:	e8 9a ff ff ff       	call   801711 <strlen>
  801777:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80177a:	ff 75 0c             	pushl  0xc(%ebp)
  80177d:	01 d8                	add    %ebx,%eax
  80177f:	50                   	push   %eax
  801780:	e8 c5 ff ff ff       	call   80174a <strcpy>
	return dst;
}
  801785:	89 d8                	mov    %ebx,%eax
  801787:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	8b 75 08             	mov    0x8(%ebp),%esi
  801794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801797:	89 f3                	mov    %esi,%ebx
  801799:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80179c:	89 f2                	mov    %esi,%edx
  80179e:	eb 0f                	jmp    8017af <strncpy+0x23>
		*dst++ = *src;
  8017a0:	83 c2 01             	add    $0x1,%edx
  8017a3:	0f b6 01             	movzbl (%ecx),%eax
  8017a6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017a9:	80 39 01             	cmpb   $0x1,(%ecx)
  8017ac:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017af:	39 da                	cmp    %ebx,%edx
  8017b1:	75 ed                	jne    8017a0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017b3:	89 f0                	mov    %esi,%eax
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	56                   	push   %esi
  8017bd:	53                   	push   %ebx
  8017be:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8017c7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017c9:	85 d2                	test   %edx,%edx
  8017cb:	74 21                	je     8017ee <strlcpy+0x35>
  8017cd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017d1:	89 f2                	mov    %esi,%edx
  8017d3:	eb 09                	jmp    8017de <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017d5:	83 c2 01             	add    $0x1,%edx
  8017d8:	83 c1 01             	add    $0x1,%ecx
  8017db:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017de:	39 c2                	cmp    %eax,%edx
  8017e0:	74 09                	je     8017eb <strlcpy+0x32>
  8017e2:	0f b6 19             	movzbl (%ecx),%ebx
  8017e5:	84 db                	test   %bl,%bl
  8017e7:	75 ec                	jne    8017d5 <strlcpy+0x1c>
  8017e9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017eb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ee:	29 f0                	sub    %esi,%eax
}
  8017f0:	5b                   	pop    %ebx
  8017f1:	5e                   	pop    %esi
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017fd:	eb 06                	jmp    801805 <strcmp+0x11>
		p++, q++;
  8017ff:	83 c1 01             	add    $0x1,%ecx
  801802:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801805:	0f b6 01             	movzbl (%ecx),%eax
  801808:	84 c0                	test   %al,%al
  80180a:	74 04                	je     801810 <strcmp+0x1c>
  80180c:	3a 02                	cmp    (%edx),%al
  80180e:	74 ef                	je     8017ff <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801810:	0f b6 c0             	movzbl %al,%eax
  801813:	0f b6 12             	movzbl (%edx),%edx
  801816:	29 d0                	sub    %edx,%eax
}
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	8b 55 0c             	mov    0xc(%ebp),%edx
  801824:	89 c3                	mov    %eax,%ebx
  801826:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801829:	eb 06                	jmp    801831 <strncmp+0x17>
		n--, p++, q++;
  80182b:	83 c0 01             	add    $0x1,%eax
  80182e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801831:	39 d8                	cmp    %ebx,%eax
  801833:	74 15                	je     80184a <strncmp+0x30>
  801835:	0f b6 08             	movzbl (%eax),%ecx
  801838:	84 c9                	test   %cl,%cl
  80183a:	74 04                	je     801840 <strncmp+0x26>
  80183c:	3a 0a                	cmp    (%edx),%cl
  80183e:	74 eb                	je     80182b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801840:	0f b6 00             	movzbl (%eax),%eax
  801843:	0f b6 12             	movzbl (%edx),%edx
  801846:	29 d0                	sub    %edx,%eax
  801848:	eb 05                	jmp    80184f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80184f:	5b                   	pop    %ebx
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80185c:	eb 07                	jmp    801865 <strchr+0x13>
		if (*s == c)
  80185e:	38 ca                	cmp    %cl,%dl
  801860:	74 0f                	je     801871 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801862:	83 c0 01             	add    $0x1,%eax
  801865:	0f b6 10             	movzbl (%eax),%edx
  801868:	84 d2                	test   %dl,%dl
  80186a:	75 f2                	jne    80185e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80186c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80187d:	eb 03                	jmp    801882 <strfind+0xf>
  80187f:	83 c0 01             	add    $0x1,%eax
  801882:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801885:	38 ca                	cmp    %cl,%dl
  801887:	74 04                	je     80188d <strfind+0x1a>
  801889:	84 d2                	test   %dl,%dl
  80188b:	75 f2                	jne    80187f <strfind+0xc>
			break;
	return (char *) s;
}
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	57                   	push   %edi
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	8b 7d 08             	mov    0x8(%ebp),%edi
  801898:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80189b:	85 c9                	test   %ecx,%ecx
  80189d:	74 36                	je     8018d5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80189f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018a5:	75 28                	jne    8018cf <memset+0x40>
  8018a7:	f6 c1 03             	test   $0x3,%cl
  8018aa:	75 23                	jne    8018cf <memset+0x40>
		c &= 0xFF;
  8018ac:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018b0:	89 d3                	mov    %edx,%ebx
  8018b2:	c1 e3 08             	shl    $0x8,%ebx
  8018b5:	89 d6                	mov    %edx,%esi
  8018b7:	c1 e6 18             	shl    $0x18,%esi
  8018ba:	89 d0                	mov    %edx,%eax
  8018bc:	c1 e0 10             	shl    $0x10,%eax
  8018bf:	09 f0                	or     %esi,%eax
  8018c1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018c3:	89 d8                	mov    %ebx,%eax
  8018c5:	09 d0                	or     %edx,%eax
  8018c7:	c1 e9 02             	shr    $0x2,%ecx
  8018ca:	fc                   	cld    
  8018cb:	f3 ab                	rep stos %eax,%es:(%edi)
  8018cd:	eb 06                	jmp    8018d5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d2:	fc                   	cld    
  8018d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018d5:	89 f8                	mov    %edi,%eax
  8018d7:	5b                   	pop    %ebx
  8018d8:	5e                   	pop    %esi
  8018d9:	5f                   	pop    %edi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	57                   	push   %edi
  8018e0:	56                   	push   %esi
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ea:	39 c6                	cmp    %eax,%esi
  8018ec:	73 35                	jae    801923 <memmove+0x47>
  8018ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018f1:	39 d0                	cmp    %edx,%eax
  8018f3:	73 2e                	jae    801923 <memmove+0x47>
		s += n;
		d += n;
  8018f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f8:	89 d6                	mov    %edx,%esi
  8018fa:	09 fe                	or     %edi,%esi
  8018fc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801902:	75 13                	jne    801917 <memmove+0x3b>
  801904:	f6 c1 03             	test   $0x3,%cl
  801907:	75 0e                	jne    801917 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801909:	83 ef 04             	sub    $0x4,%edi
  80190c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80190f:	c1 e9 02             	shr    $0x2,%ecx
  801912:	fd                   	std    
  801913:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801915:	eb 09                	jmp    801920 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801917:	83 ef 01             	sub    $0x1,%edi
  80191a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80191d:	fd                   	std    
  80191e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801920:	fc                   	cld    
  801921:	eb 1d                	jmp    801940 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801923:	89 f2                	mov    %esi,%edx
  801925:	09 c2                	or     %eax,%edx
  801927:	f6 c2 03             	test   $0x3,%dl
  80192a:	75 0f                	jne    80193b <memmove+0x5f>
  80192c:	f6 c1 03             	test   $0x3,%cl
  80192f:	75 0a                	jne    80193b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801931:	c1 e9 02             	shr    $0x2,%ecx
  801934:	89 c7                	mov    %eax,%edi
  801936:	fc                   	cld    
  801937:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801939:	eb 05                	jmp    801940 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80193b:	89 c7                	mov    %eax,%edi
  80193d:	fc                   	cld    
  80193e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801947:	ff 75 10             	pushl  0x10(%ebp)
  80194a:	ff 75 0c             	pushl  0xc(%ebp)
  80194d:	ff 75 08             	pushl  0x8(%ebp)
  801950:	e8 87 ff ff ff       	call   8018dc <memmove>
}
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801962:	89 c6                	mov    %eax,%esi
  801964:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801967:	eb 1a                	jmp    801983 <memcmp+0x2c>
		if (*s1 != *s2)
  801969:	0f b6 08             	movzbl (%eax),%ecx
  80196c:	0f b6 1a             	movzbl (%edx),%ebx
  80196f:	38 d9                	cmp    %bl,%cl
  801971:	74 0a                	je     80197d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801973:	0f b6 c1             	movzbl %cl,%eax
  801976:	0f b6 db             	movzbl %bl,%ebx
  801979:	29 d8                	sub    %ebx,%eax
  80197b:	eb 0f                	jmp    80198c <memcmp+0x35>
		s1++, s2++;
  80197d:	83 c0 01             	add    $0x1,%eax
  801980:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801983:	39 f0                	cmp    %esi,%eax
  801985:	75 e2                	jne    801969 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198c:	5b                   	pop    %ebx
  80198d:	5e                   	pop    %esi
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801997:	89 c1                	mov    %eax,%ecx
  801999:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80199c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019a0:	eb 0a                	jmp    8019ac <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019a2:	0f b6 10             	movzbl (%eax),%edx
  8019a5:	39 da                	cmp    %ebx,%edx
  8019a7:	74 07                	je     8019b0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019a9:	83 c0 01             	add    $0x1,%eax
  8019ac:	39 c8                	cmp    %ecx,%eax
  8019ae:	72 f2                	jb     8019a2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019b0:	5b                   	pop    %ebx
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	57                   	push   %edi
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019bf:	eb 03                	jmp    8019c4 <strtol+0x11>
		s++;
  8019c1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019c4:	0f b6 01             	movzbl (%ecx),%eax
  8019c7:	3c 20                	cmp    $0x20,%al
  8019c9:	74 f6                	je     8019c1 <strtol+0xe>
  8019cb:	3c 09                	cmp    $0x9,%al
  8019cd:	74 f2                	je     8019c1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019cf:	3c 2b                	cmp    $0x2b,%al
  8019d1:	75 0a                	jne    8019dd <strtol+0x2a>
		s++;
  8019d3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019d6:	bf 00 00 00 00       	mov    $0x0,%edi
  8019db:	eb 11                	jmp    8019ee <strtol+0x3b>
  8019dd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019e2:	3c 2d                	cmp    $0x2d,%al
  8019e4:	75 08                	jne    8019ee <strtol+0x3b>
		s++, neg = 1;
  8019e6:	83 c1 01             	add    $0x1,%ecx
  8019e9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ee:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019f4:	75 15                	jne    801a0b <strtol+0x58>
  8019f6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019f9:	75 10                	jne    801a0b <strtol+0x58>
  8019fb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ff:	75 7c                	jne    801a7d <strtol+0xca>
		s += 2, base = 16;
  801a01:	83 c1 02             	add    $0x2,%ecx
  801a04:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a09:	eb 16                	jmp    801a21 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a0b:	85 db                	test   %ebx,%ebx
  801a0d:	75 12                	jne    801a21 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a0f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a14:	80 39 30             	cmpb   $0x30,(%ecx)
  801a17:	75 08                	jne    801a21 <strtol+0x6e>
		s++, base = 8;
  801a19:	83 c1 01             	add    $0x1,%ecx
  801a1c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a21:	b8 00 00 00 00       	mov    $0x0,%eax
  801a26:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a29:	0f b6 11             	movzbl (%ecx),%edx
  801a2c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a2f:	89 f3                	mov    %esi,%ebx
  801a31:	80 fb 09             	cmp    $0x9,%bl
  801a34:	77 08                	ja     801a3e <strtol+0x8b>
			dig = *s - '0';
  801a36:	0f be d2             	movsbl %dl,%edx
  801a39:	83 ea 30             	sub    $0x30,%edx
  801a3c:	eb 22                	jmp    801a60 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a3e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a41:	89 f3                	mov    %esi,%ebx
  801a43:	80 fb 19             	cmp    $0x19,%bl
  801a46:	77 08                	ja     801a50 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a48:	0f be d2             	movsbl %dl,%edx
  801a4b:	83 ea 57             	sub    $0x57,%edx
  801a4e:	eb 10                	jmp    801a60 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a50:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a53:	89 f3                	mov    %esi,%ebx
  801a55:	80 fb 19             	cmp    $0x19,%bl
  801a58:	77 16                	ja     801a70 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a5a:	0f be d2             	movsbl %dl,%edx
  801a5d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a60:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a63:	7d 0b                	jge    801a70 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a65:	83 c1 01             	add    $0x1,%ecx
  801a68:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a6c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a6e:	eb b9                	jmp    801a29 <strtol+0x76>

	if (endptr)
  801a70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a74:	74 0d                	je     801a83 <strtol+0xd0>
		*endptr = (char *) s;
  801a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a79:	89 0e                	mov    %ecx,(%esi)
  801a7b:	eb 06                	jmp    801a83 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a7d:	85 db                	test   %ebx,%ebx
  801a7f:	74 98                	je     801a19 <strtol+0x66>
  801a81:	eb 9e                	jmp    801a21 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a83:	89 c2                	mov    %eax,%edx
  801a85:	f7 da                	neg    %edx
  801a87:	85 ff                	test   %edi,%edi
  801a89:	0f 45 c2             	cmovne %edx,%eax
}
  801a8c:	5b                   	pop    %ebx
  801a8d:	5e                   	pop    %esi
  801a8e:	5f                   	pop    %edi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a97:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a9e:	75 31                	jne    801ad1 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(thisenv->env_id, (void*)(UXSTACKTOP - PGSIZE), PTE_P | 
  801aa0:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa5:	8b 40 48             	mov    0x48(%eax),%eax
  801aa8:	83 ec 04             	sub    $0x4,%esp
  801aab:	6a 07                	push   $0x7
  801aad:	68 00 f0 bf ee       	push   $0xeebff000
  801ab2:	50                   	push   %eax
  801ab3:	e8 b8 e6 ff ff       	call   800170 <sys_page_alloc>
				PTE_U | PTE_W);
		sys_env_set_pgfault_upcall(thisenv->env_id, (void*)_pgfault_upcall);
  801ab8:	a1 04 40 80 00       	mov    0x804004,%eax
  801abd:	8b 40 48             	mov    0x48(%eax),%eax
  801ac0:	83 c4 08             	add    $0x8,%esp
  801ac3:	68 61 03 80 00       	push   $0x800361
  801ac8:	50                   	push   %eax
  801ac9:	e8 ed e7 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801ace:	83 c4 10             	add    $0x10,%esp

		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad4:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	74 0e                	je     801afb <ipc_recv+0x20>
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	50                   	push   %eax
  801af1:	e8 2a e8 ff ff       	call   800320 <sys_ipc_recv>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	eb 10                	jmp    801b0b <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	68 00 00 c0 ee       	push   $0xeec00000
  801b03:	e8 18 e8 ff ff       	call   800320 <sys_ipc_recv>
  801b08:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	74 16                	je     801b25 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801b0f:	85 f6                	test   %esi,%esi
  801b11:	74 06                	je     801b19 <ipc_recv+0x3e>
  801b13:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801b19:	85 db                	test   %ebx,%ebx
  801b1b:	74 2c                	je     801b49 <ipc_recv+0x6e>
  801b1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b23:	eb 24                	jmp    801b49 <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801b25:	85 f6                	test   %esi,%esi
  801b27:	74 0a                	je     801b33 <ipc_recv+0x58>
  801b29:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2e:	8b 40 74             	mov    0x74(%eax),%eax
  801b31:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801b33:	85 db                	test   %ebx,%ebx
  801b35:	74 0a                	je     801b41 <ipc_recv+0x66>
  801b37:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3c:	8b 40 78             	mov    0x78(%eax),%eax
  801b3f:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b41:	a1 04 40 80 00       	mov    0x804004,%eax
  801b46:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b62:	85 c0                	test   %eax,%eax
  801b64:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b69:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801b6c:	ff 75 14             	pushl  0x14(%ebp)
  801b6f:	53                   	push   %ebx
  801b70:	56                   	push   %esi
  801b71:	57                   	push   %edi
  801b72:	e8 86 e7 ff ff       	call   8002fd <sys_ipc_try_send>
		if (ret == 0) break;
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	74 1e                	je     801b9c <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b7e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b81:	74 12                	je     801b95 <ipc_send+0x45>
  801b83:	50                   	push   %eax
  801b84:	68 20 23 80 00       	push   $0x802320
  801b89:	6a 39                	push   $0x39
  801b8b:	68 2d 23 80 00       	push   $0x80232d
  801b90:	e8 b0 f4 ff ff       	call   801045 <_panic>
		sys_yield();
  801b95:	e8 b7 e5 ff ff       	call   800151 <sys_yield>
	}
  801b9a:	eb d0                	jmp    801b6c <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5f                   	pop    %edi
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    

00801ba4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801baf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bb2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bb8:	8b 52 50             	mov    0x50(%edx),%edx
  801bbb:	39 ca                	cmp    %ecx,%edx
  801bbd:	75 0d                	jne    801bcc <ipc_find_env+0x28>
			return envs[i].env_id;
  801bbf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bc2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bc7:	8b 40 48             	mov    0x48(%eax),%eax
  801bca:	eb 0f                	jmp    801bdb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bcc:	83 c0 01             	add    $0x1,%eax
  801bcf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bd4:	75 d9                	jne    801baf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be3:	89 d0                	mov    %edx,%eax
  801be5:	c1 e8 16             	shr    $0x16,%eax
  801be8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf4:	f6 c1 01             	test   $0x1,%cl
  801bf7:	74 1d                	je     801c16 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bf9:	c1 ea 0c             	shr    $0xc,%edx
  801bfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c03:	f6 c2 01             	test   $0x1,%dl
  801c06:	74 0e                	je     801c16 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c08:	c1 ea 0c             	shr    $0xc,%edx
  801c0b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c12:	ef 
  801c13:	0f b7 c0             	movzwl %ax,%eax
}
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	66 90                	xchg   %ax,%ax
  801c1a:	66 90                	xchg   %ax,%ax
  801c1c:	66 90                	xchg   %ax,%ax
  801c1e:	66 90                	xchg   %ax,%ax

00801c20 <__udivdi3>:
  801c20:	55                   	push   %ebp
  801c21:	57                   	push   %edi
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	83 ec 1c             	sub    $0x1c,%esp
  801c27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c37:	85 f6                	test   %esi,%esi
  801c39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3d:	89 ca                	mov    %ecx,%edx
  801c3f:	89 f8                	mov    %edi,%eax
  801c41:	75 3d                	jne    801c80 <__udivdi3+0x60>
  801c43:	39 cf                	cmp    %ecx,%edi
  801c45:	0f 87 c5 00 00 00    	ja     801d10 <__udivdi3+0xf0>
  801c4b:	85 ff                	test   %edi,%edi
  801c4d:	89 fd                	mov    %edi,%ebp
  801c4f:	75 0b                	jne    801c5c <__udivdi3+0x3c>
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	31 d2                	xor    %edx,%edx
  801c58:	f7 f7                	div    %edi
  801c5a:	89 c5                	mov    %eax,%ebp
  801c5c:	89 c8                	mov    %ecx,%eax
  801c5e:	31 d2                	xor    %edx,%edx
  801c60:	f7 f5                	div    %ebp
  801c62:	89 c1                	mov    %eax,%ecx
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	89 cf                	mov    %ecx,%edi
  801c68:	f7 f5                	div    %ebp
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	39 ce                	cmp    %ecx,%esi
  801c82:	77 74                	ja     801cf8 <__udivdi3+0xd8>
  801c84:	0f bd fe             	bsr    %esi,%edi
  801c87:	83 f7 1f             	xor    $0x1f,%edi
  801c8a:	0f 84 98 00 00 00    	je     801d28 <__udivdi3+0x108>
  801c90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	89 c5                	mov    %eax,%ebp
  801c99:	29 fb                	sub    %edi,%ebx
  801c9b:	d3 e6                	shl    %cl,%esi
  801c9d:	89 d9                	mov    %ebx,%ecx
  801c9f:	d3 ed                	shr    %cl,%ebp
  801ca1:	89 f9                	mov    %edi,%ecx
  801ca3:	d3 e0                	shl    %cl,%eax
  801ca5:	09 ee                	or     %ebp,%esi
  801ca7:	89 d9                	mov    %ebx,%ecx
  801ca9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cad:	89 d5                	mov    %edx,%ebp
  801caf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cb3:	d3 ed                	shr    %cl,%ebp
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	d3 e2                	shl    %cl,%edx
  801cb9:	89 d9                	mov    %ebx,%ecx
  801cbb:	d3 e8                	shr    %cl,%eax
  801cbd:	09 c2                	or     %eax,%edx
  801cbf:	89 d0                	mov    %edx,%eax
  801cc1:	89 ea                	mov    %ebp,%edx
  801cc3:	f7 f6                	div    %esi
  801cc5:	89 d5                	mov    %edx,%ebp
  801cc7:	89 c3                	mov    %eax,%ebx
  801cc9:	f7 64 24 0c          	mull   0xc(%esp)
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	72 10                	jb     801ce1 <__udivdi3+0xc1>
  801cd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e6                	shl    %cl,%esi
  801cd9:	39 c6                	cmp    %eax,%esi
  801cdb:	73 07                	jae    801ce4 <__udivdi3+0xc4>
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	75 03                	jne    801ce4 <__udivdi3+0xc4>
  801ce1:	83 eb 01             	sub    $0x1,%ebx
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 d8                	mov    %ebx,%eax
  801ce8:	89 fa                	mov    %edi,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	31 ff                	xor    %edi,%edi
  801cfa:	31 db                	xor    %ebx,%ebx
  801cfc:	89 d8                	mov    %ebx,%eax
  801cfe:	89 fa                	mov    %edi,%edx
  801d00:	83 c4 1c             	add    $0x1c,%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    
  801d08:	90                   	nop
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	f7 f7                	div    %edi
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 c3                	mov    %eax,%ebx
  801d18:	89 d8                	mov    %ebx,%eax
  801d1a:	89 fa                	mov    %edi,%edx
  801d1c:	83 c4 1c             	add    $0x1c,%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    
  801d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d28:	39 ce                	cmp    %ecx,%esi
  801d2a:	72 0c                	jb     801d38 <__udivdi3+0x118>
  801d2c:	31 db                	xor    %ebx,%ebx
  801d2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d32:	0f 87 34 ff ff ff    	ja     801c6c <__udivdi3+0x4c>
  801d38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d3d:	e9 2a ff ff ff       	jmp    801c6c <__udivdi3+0x4c>
  801d42:	66 90                	xchg   %ax,%ax
  801d44:	66 90                	xchg   %ax,%ax
  801d46:	66 90                	xchg   %ax,%ax
  801d48:	66 90                	xchg   %ax,%ax
  801d4a:	66 90                	xchg   %ax,%ax
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <__umoddi3>:
  801d50:	55                   	push   %ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 1c             	sub    $0x1c,%esp
  801d57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d67:	85 d2                	test   %edx,%edx
  801d69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d71:	89 f3                	mov    %esi,%ebx
  801d73:	89 3c 24             	mov    %edi,(%esp)
  801d76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d7a:	75 1c                	jne    801d98 <__umoddi3+0x48>
  801d7c:	39 f7                	cmp    %esi,%edi
  801d7e:	76 50                	jbe    801dd0 <__umoddi3+0x80>
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	f7 f7                	div    %edi
  801d86:	89 d0                	mov    %edx,%eax
  801d88:	31 d2                	xor    %edx,%edx
  801d8a:	83 c4 1c             	add    $0x1c,%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
  801d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d98:	39 f2                	cmp    %esi,%edx
  801d9a:	89 d0                	mov    %edx,%eax
  801d9c:	77 52                	ja     801df0 <__umoddi3+0xa0>
  801d9e:	0f bd ea             	bsr    %edx,%ebp
  801da1:	83 f5 1f             	xor    $0x1f,%ebp
  801da4:	75 5a                	jne    801e00 <__umoddi3+0xb0>
  801da6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801daa:	0f 82 e0 00 00 00    	jb     801e90 <__umoddi3+0x140>
  801db0:	39 0c 24             	cmp    %ecx,(%esp)
  801db3:	0f 86 d7 00 00 00    	jbe    801e90 <__umoddi3+0x140>
  801db9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dc1:	83 c4 1c             	add    $0x1c,%esp
  801dc4:	5b                   	pop    %ebx
  801dc5:	5e                   	pop    %esi
  801dc6:	5f                   	pop    %edi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	85 ff                	test   %edi,%edi
  801dd2:	89 fd                	mov    %edi,%ebp
  801dd4:	75 0b                	jne    801de1 <__umoddi3+0x91>
  801dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	f7 f7                	div    %edi
  801ddf:	89 c5                	mov    %eax,%ebp
  801de1:	89 f0                	mov    %esi,%eax
  801de3:	31 d2                	xor    %edx,%edx
  801de5:	f7 f5                	div    %ebp
  801de7:	89 c8                	mov    %ecx,%eax
  801de9:	f7 f5                	div    %ebp
  801deb:	89 d0                	mov    %edx,%eax
  801ded:	eb 99                	jmp    801d88 <__umoddi3+0x38>
  801def:	90                   	nop
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	83 c4 1c             	add    $0x1c,%esp
  801df7:	5b                   	pop    %ebx
  801df8:	5e                   	pop    %esi
  801df9:	5f                   	pop    %edi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    
  801dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e00:	8b 34 24             	mov    (%esp),%esi
  801e03:	bf 20 00 00 00       	mov    $0x20,%edi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	29 ef                	sub    %ebp,%edi
  801e0c:	d3 e0                	shl    %cl,%eax
  801e0e:	89 f9                	mov    %edi,%ecx
  801e10:	89 f2                	mov    %esi,%edx
  801e12:	d3 ea                	shr    %cl,%edx
  801e14:	89 e9                	mov    %ebp,%ecx
  801e16:	09 c2                	or     %eax,%edx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 14 24             	mov    %edx,(%esp)
  801e1d:	89 f2                	mov    %esi,%edx
  801e1f:	d3 e2                	shl    %cl,%edx
  801e21:	89 f9                	mov    %edi,%ecx
  801e23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	89 c6                	mov    %eax,%esi
  801e31:	d3 e3                	shl    %cl,%ebx
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 d0                	mov    %edx,%eax
  801e37:	d3 e8                	shr    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	09 d8                	or     %ebx,%eax
  801e3d:	89 d3                	mov    %edx,%ebx
  801e3f:	89 f2                	mov    %esi,%edx
  801e41:	f7 34 24             	divl   (%esp)
  801e44:	89 d6                	mov    %edx,%esi
  801e46:	d3 e3                	shl    %cl,%ebx
  801e48:	f7 64 24 04          	mull   0x4(%esp)
  801e4c:	39 d6                	cmp    %edx,%esi
  801e4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e52:	89 d1                	mov    %edx,%ecx
  801e54:	89 c3                	mov    %eax,%ebx
  801e56:	72 08                	jb     801e60 <__umoddi3+0x110>
  801e58:	75 11                	jne    801e6b <__umoddi3+0x11b>
  801e5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e5e:	73 0b                	jae    801e6b <__umoddi3+0x11b>
  801e60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e64:	1b 14 24             	sbb    (%esp),%edx
  801e67:	89 d1                	mov    %edx,%ecx
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e6f:	29 da                	sub    %ebx,%edx
  801e71:	19 ce                	sbb    %ecx,%esi
  801e73:	89 f9                	mov    %edi,%ecx
  801e75:	89 f0                	mov    %esi,%eax
  801e77:	d3 e0                	shl    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	d3 ea                	shr    %cl,%edx
  801e7d:	89 e9                	mov    %ebp,%ecx
  801e7f:	d3 ee                	shr    %cl,%esi
  801e81:	09 d0                	or     %edx,%eax
  801e83:	89 f2                	mov    %esi,%edx
  801e85:	83 c4 1c             	add    $0x1c,%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5f                   	pop    %edi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    
  801e8d:	8d 76 00             	lea    0x0(%esi),%esi
  801e90:	29 f9                	sub    %edi,%ecx
  801e92:	19 d6                	sbb    %edx,%esi
  801e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e9c:	e9 18 ff ff ff       	jmp    801db9 <__umoddi3+0x69>
