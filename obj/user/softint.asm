
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 87 04 00 00       	call   800512 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 2a 1e 80 00       	push   $0x801e2a
  800104:	6a 23                	push   $0x23
  800106:	68 47 1e 80 00       	push   $0x801e47
  80010b:	e8 f5 0e 00 00       	call   801005 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 2a 1e 80 00       	push   $0x801e2a
  800185:	6a 23                	push   $0x23
  800187:	68 47 1e 80 00       	push   $0x801e47
  80018c:	e8 74 0e 00 00       	call   801005 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 2a 1e 80 00       	push   $0x801e2a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 47 1e 80 00       	push   $0x801e47
  8001ce:	e8 32 0e 00 00       	call   801005 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 2a 1e 80 00       	push   $0x801e2a
  800209:	6a 23                	push   $0x23
  80020b:	68 47 1e 80 00       	push   $0x801e47
  800210:	e8 f0 0d 00 00       	call   801005 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 2a 1e 80 00       	push   $0x801e2a
  80024b:	6a 23                	push   $0x23
  80024d:	68 47 1e 80 00       	push   $0x801e47
  800252:	e8 ae 0d 00 00       	call   801005 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 2a 1e 80 00       	push   $0x801e2a
  80028d:	6a 23                	push   $0x23
  80028f:	68 47 1e 80 00       	push   $0x801e47
  800294:	e8 6c 0d 00 00       	call   801005 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 2a 1e 80 00       	push   $0x801e2a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 47 1e 80 00       	push   $0x801e47
  8002d6:	e8 2a 0d 00 00       	call   801005 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 2a 1e 80 00       	push   $0x801e2a
  800333:	6a 23                	push   $0x23
  800335:	68 47 1e 80 00       	push   $0x801e47
  80033a:	e8 c6 0c 00 00       	call   801005 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 58 1e 80 00       	push   $0x801e58
  80044e:	e8 8b 0c 00 00       	call   8010de <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 99 1e 80 00       	push   $0x801e99
  800678:	e8 61 0a 00 00       	call   8010de <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 b5 1e 80 00       	push   $0x801eb5
  80074d:	e8 8c 09 00 00       	call   8010de <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 78 1e 80 00       	push   $0x801e78
  800802:	e8 d7 08 00 00       	call   8010de <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 b7 01 00 00       	call   800a82 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 08 12 00 00       	call   801b1a <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 99 11 00 00       	call   801ac6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 17 11 00 00       	call   801a51 <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 47 0d 00 00       	call   80170a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009ec:	68 e4 1e 80 00       	push   $0x801ee4
  8009f1:	68 90 00 00 00       	push   $0x90
  8009f6:	68 02 1f 80 00       	push   $0x801f02
  8009fb:	e8 05 06 00 00       	call   801005 <_panic>

00800a00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a23:	e8 ce fe ff ff       	call   8008f6 <fsipc>
  800a28:	89 c3                	mov    %eax,%ebx
  800a2a:	85 c0                	test   %eax,%eax
  800a2c:	78 4b                	js     800a79 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a2e:	39 c6                	cmp    %eax,%esi
  800a30:	73 16                	jae    800a48 <devfile_read+0x48>
  800a32:	68 0d 1f 80 00       	push   $0x801f0d
  800a37:	68 14 1f 80 00       	push   $0x801f14
  800a3c:	6a 7c                	push   $0x7c
  800a3e:	68 02 1f 80 00       	push   $0x801f02
  800a43:	e8 bd 05 00 00       	call   801005 <_panic>
	assert(r <= PGSIZE);
  800a48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4d:	7e 16                	jle    800a65 <devfile_read+0x65>
  800a4f:	68 29 1f 80 00       	push   $0x801f29
  800a54:	68 14 1f 80 00       	push   $0x801f14
  800a59:	6a 7d                	push   $0x7d
  800a5b:	68 02 1f 80 00       	push   $0x801f02
  800a60:	e8 a0 05 00 00       	call   801005 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a65:	83 ec 04             	sub    $0x4,%esp
  800a68:	50                   	push   %eax
  800a69:	68 00 50 80 00       	push   $0x805000
  800a6e:	ff 75 0c             	pushl  0xc(%ebp)
  800a71:	e8 26 0e 00 00       	call   80189c <memmove>
	return r;
  800a76:	83 c4 10             	add    $0x10,%esp
}
  800a79:	89 d8                	mov    %ebx,%eax
  800a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	83 ec 20             	sub    $0x20,%esp
  800a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a8c:	53                   	push   %ebx
  800a8d:	e8 3f 0c 00 00       	call   8016d1 <strlen>
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9a:	7f 67                	jg     800b03 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa2:	50                   	push   %eax
  800aa3:	e8 c6 f8 ff ff       	call   80036e <fd_alloc>
  800aa8:	83 c4 10             	add    $0x10,%esp
		return r;
  800aab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	78 57                	js     800b08 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ab1:	83 ec 08             	sub    $0x8,%esp
  800ab4:	53                   	push   %ebx
  800ab5:	68 00 50 80 00       	push   $0x805000
  800aba:	e8 4b 0c 00 00       	call   80170a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	e8 22 fe ff ff       	call   8008f6 <fsipc>
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	79 14                	jns    800af1 <open+0x6f>
		fd_close(fd, 0);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	6a 00                	push   $0x0
  800ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae5:	e8 7c f9 ff ff       	call   800466 <fd_close>
		return r;
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	89 da                	mov    %ebx,%edx
  800aef:	eb 17                	jmp    800b08 <open+0x86>
	}

	return fd2num(fd);
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	ff 75 f4             	pushl  -0xc(%ebp)
  800af7:	e8 4b f8 ff ff       	call   800347 <fd2num>
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	eb 05                	jmp    800b08 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b03:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b08:	89 d0                	mov    %edx,%eax
  800b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b1f:	e8 d2 fd ff ff       	call   8008f6 <fsipc>
}
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	ff 75 08             	pushl  0x8(%ebp)
  800b34:	e8 1e f8 ff ff       	call   800357 <fd2data>
  800b39:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3b:	83 c4 08             	add    $0x8,%esp
  800b3e:	68 35 1f 80 00       	push   $0x801f35
  800b43:	53                   	push   %ebx
  800b44:	e8 c1 0b 00 00       	call   80170a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b49:	8b 46 04             	mov    0x4(%esi),%eax
  800b4c:	2b 06                	sub    (%esi),%eax
  800b4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b54:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5b:	00 00 00 
	stat->st_dev = &devpipe;
  800b5e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b65:	30 80 00 
	return 0;
}
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b7e:	53                   	push   %ebx
  800b7f:	6a 00                	push   $0x0
  800b81:	e8 55 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b86:	89 1c 24             	mov    %ebx,(%esp)
  800b89:	e8 c9 f7 ff ff       	call   800357 <fd2data>
  800b8e:	83 c4 08             	add    $0x8,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 00                	push   $0x0
  800b94:	e8 42 f6 ff ff       	call   8001db <sys_page_unmap>
}
  800b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 1c             	sub    $0x1c,%esp
  800ba7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800baa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bac:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bba:	e8 94 0f 00 00       	call   801b53 <pageref>
  800bbf:	89 c3                	mov    %eax,%ebx
  800bc1:	89 3c 24             	mov    %edi,(%esp)
  800bc4:	e8 8a 0f 00 00       	call   801b53 <pageref>
  800bc9:	83 c4 10             	add    $0x10,%esp
  800bcc:	39 c3                	cmp    %eax,%ebx
  800bce:	0f 94 c1             	sete   %cl
  800bd1:	0f b6 c9             	movzbl %cl,%ecx
  800bd4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bd7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bdd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be0:	39 ce                	cmp    %ecx,%esi
  800be2:	74 1b                	je     800bff <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800be4:	39 c3                	cmp    %eax,%ebx
  800be6:	75 c4                	jne    800bac <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be8:	8b 42 58             	mov    0x58(%edx),%eax
  800beb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bee:	50                   	push   %eax
  800bef:	56                   	push   %esi
  800bf0:	68 3c 1f 80 00       	push   $0x801f3c
  800bf5:	e8 e4 04 00 00       	call   8010de <cprintf>
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb ad                	jmp    800bac <_pipeisclosed+0xe>
	}
}
  800bff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 28             	sub    $0x28,%esp
  800c13:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c16:	56                   	push   %esi
  800c17:	e8 3b f7 ff ff       	call   800357 <fd2data>
  800c1c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c1e:	83 c4 10             	add    $0x10,%esp
  800c21:	bf 00 00 00 00       	mov    $0x0,%edi
  800c26:	eb 4b                	jmp    800c73 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c28:	89 da                	mov    %ebx,%edx
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	e8 6d ff ff ff       	call   800b9e <_pipeisclosed>
  800c31:	85 c0                	test   %eax,%eax
  800c33:	75 48                	jne    800c7d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c35:	e8 fd f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c3d:	8b 0b                	mov    (%ebx),%ecx
  800c3f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c42:	39 d0                	cmp    %edx,%eax
  800c44:	73 e2                	jae    800c28 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c4d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c50:	89 c2                	mov    %eax,%edx
  800c52:	c1 fa 1f             	sar    $0x1f,%edx
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	c1 e9 1b             	shr    $0x1b,%ecx
  800c5a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c5d:	83 e2 1f             	and    $0x1f,%edx
  800c60:	29 ca                	sub    %ecx,%edx
  800c62:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c6a:	83 c0 01             	add    $0x1,%eax
  800c6d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c70:	83 c7 01             	add    $0x1,%edi
  800c73:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c76:	75 c2                	jne    800c3a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	eb 05                	jmp    800c82 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 18             	sub    $0x18,%esp
  800c93:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c96:	57                   	push   %edi
  800c97:	e8 bb f6 ff ff       	call   800357 <fd2data>
  800c9c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca6:	eb 3d                	jmp    800ce5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	74 04                	je     800cb0 <devpipe_read+0x26>
				return i;
  800cac:	89 d8                	mov    %ebx,%eax
  800cae:	eb 44                	jmp    800cf4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cb0:	89 f2                	mov    %esi,%edx
  800cb2:	89 f8                	mov    %edi,%eax
  800cb4:	e8 e5 fe ff ff       	call   800b9e <_pipeisclosed>
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	75 32                	jne    800cef <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cbd:	e8 75 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cc2:	8b 06                	mov    (%esi),%eax
  800cc4:	3b 46 04             	cmp    0x4(%esi),%eax
  800cc7:	74 df                	je     800ca8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cc9:	99                   	cltd   
  800cca:	c1 ea 1b             	shr    $0x1b,%edx
  800ccd:	01 d0                	add    %edx,%eax
  800ccf:	83 e0 1f             	and    $0x1f,%eax
  800cd2:	29 d0                	sub    %edx,%eax
  800cd4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cdf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce2:	83 c3 01             	add    $0x1,%ebx
  800ce5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800ce8:	75 d8                	jne    800cc2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cea:	8b 45 10             	mov    0x10(%ebp),%eax
  800ced:	eb 05                	jmp    800cf4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d07:	50                   	push   %eax
  800d08:	e8 61 f6 ff ff       	call   80036e <fd_alloc>
  800d0d:	83 c4 10             	add    $0x10,%esp
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	85 c0                	test   %eax,%eax
  800d14:	0f 88 2c 01 00 00    	js     800e46 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1a:	83 ec 04             	sub    $0x4,%esp
  800d1d:	68 07 04 00 00       	push   $0x407
  800d22:	ff 75 f4             	pushl  -0xc(%ebp)
  800d25:	6a 00                	push   $0x0
  800d27:	e8 2a f4 ff ff       	call   800156 <sys_page_alloc>
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	89 c2                	mov    %eax,%edx
  800d31:	85 c0                	test   %eax,%eax
  800d33:	0f 88 0d 01 00 00    	js     800e46 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3f:	50                   	push   %eax
  800d40:	e8 29 f6 ff ff       	call   80036e <fd_alloc>
  800d45:	89 c3                	mov    %eax,%ebx
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	0f 88 e2 00 00 00    	js     800e34 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	68 07 04 00 00       	push   $0x407
  800d5a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d5d:	6a 00                	push   $0x0
  800d5f:	e8 f2 f3 ff ff       	call   800156 <sys_page_alloc>
  800d64:	89 c3                	mov    %eax,%ebx
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 c3 00 00 00    	js     800e34 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	ff 75 f4             	pushl  -0xc(%ebp)
  800d77:	e8 db f5 ff ff       	call   800357 <fd2data>
  800d7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7e:	83 c4 0c             	add    $0xc,%esp
  800d81:	68 07 04 00 00       	push   $0x407
  800d86:	50                   	push   %eax
  800d87:	6a 00                	push   $0x0
  800d89:	e8 c8 f3 ff ff       	call   800156 <sys_page_alloc>
  800d8e:	89 c3                	mov    %eax,%ebx
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	85 c0                	test   %eax,%eax
  800d95:	0f 88 89 00 00 00    	js     800e24 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	ff 75 f0             	pushl  -0x10(%ebp)
  800da1:	e8 b1 f5 ff ff       	call   800357 <fd2data>
  800da6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dad:	50                   	push   %eax
  800dae:	6a 00                	push   $0x0
  800db0:	56                   	push   %esi
  800db1:	6a 00                	push   $0x0
  800db3:	e8 e1 f3 ff ff       	call   800199 <sys_page_map>
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	83 c4 20             	add    $0x20,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	78 55                	js     800e16 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dd6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ddc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ddf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	ff 75 f4             	pushl  -0xc(%ebp)
  800df1:	e8 51 f5 ff ff       	call   800347 <fd2num>
  800df6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dfb:	83 c4 04             	add    $0x4,%esp
  800dfe:	ff 75 f0             	pushl  -0x10(%ebp)
  800e01:	e8 41 f5 ff ff       	call   800347 <fd2num>
  800e06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e09:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e14:	eb 30                	jmp    800e46 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e16:	83 ec 08             	sub    $0x8,%esp
  800e19:	56                   	push   %esi
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 ba f3 ff ff       	call   8001db <sys_page_unmap>
  800e21:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 aa f3 ff ff       	call   8001db <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 9a f3 ff ff       	call   8001db <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e46:	89 d0                	mov    %edx,%eax
  800e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e58:	50                   	push   %eax
  800e59:	ff 75 08             	pushl  0x8(%ebp)
  800e5c:	e8 5c f5 ff ff       	call   8003bd <fd_lookup>
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 18                	js     800e80 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6e:	e8 e4 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e78:	e8 21 fd ff ff       	call   800b9e <_pipeisclosed>
  800e7d:	83 c4 10             	add    $0x10,%esp
}
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e92:	68 54 1f 80 00       	push   $0x801f54
  800e97:	ff 75 0c             	pushl  0xc(%ebp)
  800e9a:	e8 6b 08 00 00       	call   80170a <strcpy>
	return 0;
}
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eb7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ebd:	eb 2d                	jmp    800eec <devcons_write+0x46>
		m = n - tot;
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ec4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ec7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ecc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	53                   	push   %ebx
  800ed3:	03 45 0c             	add    0xc(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	57                   	push   %edi
  800ed8:	e8 bf 09 00 00       	call   80189c <memmove>
		sys_cputs(buf, m);
  800edd:	83 c4 08             	add    $0x8,%esp
  800ee0:	53                   	push   %ebx
  800ee1:	57                   	push   %edi
  800ee2:	e8 b3 f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee7:	01 de                	add    %ebx,%esi
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	89 f0                	mov    %esi,%eax
  800eee:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef1:	72 cc                	jb     800ebf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0a:	74 2a                	je     800f36 <devcons_read+0x3b>
  800f0c:	eb 05                	jmp    800f13 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f0e:	e8 24 f2 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f13:	e8 a0 f1 ff ff       	call   8000b8 <sys_cgetc>
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	74 f2                	je     800f0e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 16                	js     800f36 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f20:	83 f8 04             	cmp    $0x4,%eax
  800f23:	74 0c                	je     800f31 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f28:	88 02                	mov    %al,(%edx)
	return 1;
  800f2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2f:	eb 05                	jmp    800f36 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f44:	6a 01                	push   $0x1
  800f46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	e8 4b f1 ff ff       	call   80009a <sys_cputs>
}
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <getchar>:

int
getchar(void)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f5a:	6a 01                	push   $0x1
  800f5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	6a 00                	push   $0x0
  800f62:	e8 bc f6 ff ff       	call   800623 <read>
	if (r < 0)
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 0f                	js     800f7d <getchar+0x29>
		return r;
	if (r < 1)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 06                	jle    800f78 <getchar+0x24>
		return -E_EOF;
	return c;
  800f72:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f76:	eb 05                	jmp    800f7d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f78:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	ff 75 08             	pushl  0x8(%ebp)
  800f8c:	e8 2c f4 ff ff       	call   8003bd <fd_lookup>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 11                	js     800fa9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa1:	39 10                	cmp    %edx,(%eax)
  800fa3:	0f 94 c0             	sete   %al
  800fa6:	0f b6 c0             	movzbl %al,%eax
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <opencons>:

int
opencons(void)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	e8 b4 f3 ff ff       	call   80036e <fd_alloc>
  800fba:	83 c4 10             	add    $0x10,%esp
		return r;
  800fbd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 3e                	js     801001 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc3:	83 ec 04             	sub    $0x4,%esp
  800fc6:	68 07 04 00 00       	push   $0x407
  800fcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 81 f1 ff ff       	call   800156 <sys_page_alloc>
  800fd5:	83 c4 10             	add    $0x10,%esp
		return r;
  800fd8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 23                	js     801001 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fde:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	50                   	push   %eax
  800ff7:	e8 4b f3 ff ff       	call   800347 <fd2num>
  800ffc:	89 c2                	mov    %eax,%edx
  800ffe:	83 c4 10             	add    $0x10,%esp
}
  801001:	89 d0                	mov    %edx,%eax
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801013:	e8 00 f1 ff ff       	call   800118 <sys_getenvid>
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	ff 75 0c             	pushl  0xc(%ebp)
  80101e:	ff 75 08             	pushl  0x8(%ebp)
  801021:	56                   	push   %esi
  801022:	50                   	push   %eax
  801023:	68 60 1f 80 00       	push   $0x801f60
  801028:	e8 b1 00 00 00       	call   8010de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102d:	83 c4 18             	add    $0x18,%esp
  801030:	53                   	push   %ebx
  801031:	ff 75 10             	pushl  0x10(%ebp)
  801034:	e8 54 00 00 00       	call   80108d <vcprintf>
	cprintf("\n");
  801039:	c7 04 24 4d 1f 80 00 	movl   $0x801f4d,(%esp)
  801040:	e8 99 00 00 00       	call   8010de <cprintf>
  801045:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801048:	cc                   	int3   
  801049:	eb fd                	jmp    801048 <_panic+0x43>

0080104b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	53                   	push   %ebx
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801055:	8b 13                	mov    (%ebx),%edx
  801057:	8d 42 01             	lea    0x1(%edx),%eax
  80105a:	89 03                	mov    %eax,(%ebx)
  80105c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801063:	3d ff 00 00 00       	cmp    $0xff,%eax
  801068:	75 1a                	jne    801084 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	68 ff 00 00 00       	push   $0xff
  801072:	8d 43 08             	lea    0x8(%ebx),%eax
  801075:	50                   	push   %eax
  801076:	e8 1f f0 ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80107b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801081:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801084:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801088:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801096:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109d:	00 00 00 
	b.cnt = 0;
  8010a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010aa:	ff 75 0c             	pushl  0xc(%ebp)
  8010ad:	ff 75 08             	pushl  0x8(%ebp)
  8010b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	68 4b 10 80 00       	push   $0x80104b
  8010bc:	e8 1a 01 00 00       	call   8011db <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c1:	83 c4 08             	add    $0x8,%esp
  8010c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d0:	50                   	push   %eax
  8010d1:	e8 c4 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8010d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e7:	50                   	push   %eax
  8010e8:	ff 75 08             	pushl  0x8(%ebp)
  8010eb:	e8 9d ff ff ff       	call   80108d <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 1c             	sub    $0x1c,%esp
  8010fb:	89 c7                	mov    %eax,%edi
  8010fd:	89 d6                	mov    %edx,%esi
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	8b 55 0c             	mov    0xc(%ebp),%edx
  801105:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801108:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801113:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801116:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801119:	39 d3                	cmp    %edx,%ebx
  80111b:	72 05                	jb     801122 <printnum+0x30>
  80111d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801120:	77 45                	ja     801167 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	ff 75 18             	pushl  0x18(%ebp)
  801128:	8b 45 14             	mov    0x14(%ebp),%eax
  80112b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80112e:	53                   	push   %ebx
  80112f:	ff 75 10             	pushl  0x10(%ebp)
  801132:	83 ec 08             	sub    $0x8,%esp
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	ff 75 e0             	pushl  -0x20(%ebp)
  80113b:	ff 75 dc             	pushl  -0x24(%ebp)
  80113e:	ff 75 d8             	pushl  -0x28(%ebp)
  801141:	e8 4a 0a 00 00       	call   801b90 <__udivdi3>
  801146:	83 c4 18             	add    $0x18,%esp
  801149:	52                   	push   %edx
  80114a:	50                   	push   %eax
  80114b:	89 f2                	mov    %esi,%edx
  80114d:	89 f8                	mov    %edi,%eax
  80114f:	e8 9e ff ff ff       	call   8010f2 <printnum>
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	eb 18                	jmp    801171 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	56                   	push   %esi
  80115d:	ff 75 18             	pushl  0x18(%ebp)
  801160:	ff d7                	call   *%edi
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	eb 03                	jmp    80116a <printnum+0x78>
  801167:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80116a:	83 eb 01             	sub    $0x1,%ebx
  80116d:	85 db                	test   %ebx,%ebx
  80116f:	7f e8                	jg     801159 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	56                   	push   %esi
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117b:	ff 75 e0             	pushl  -0x20(%ebp)
  80117e:	ff 75 dc             	pushl  -0x24(%ebp)
  801181:	ff 75 d8             	pushl  -0x28(%ebp)
  801184:	e8 37 0b 00 00       	call   801cc0 <__umoddi3>
  801189:	83 c4 14             	add    $0x14,%esp
  80118c:	0f be 80 83 1f 80 00 	movsbl 0x801f83(%eax),%eax
  801193:	50                   	push   %eax
  801194:	ff d7                	call   *%edi
}
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ab:	8b 10                	mov    (%eax),%edx
  8011ad:	3b 50 04             	cmp    0x4(%eax),%edx
  8011b0:	73 0a                	jae    8011bc <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011b5:	89 08                	mov    %ecx,(%eax)
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	88 02                	mov    %al,(%edx)
}
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c7:	50                   	push   %eax
  8011c8:	ff 75 10             	pushl  0x10(%ebp)
  8011cb:	ff 75 0c             	pushl  0xc(%ebp)
  8011ce:	ff 75 08             	pushl  0x8(%ebp)
  8011d1:	e8 05 00 00 00       	call   8011db <vprintfmt>
	va_end(ap);
}
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	57                   	push   %edi
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 2c             	sub    $0x2c,%esp
  8011e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ea:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011ed:	eb 12                	jmp    801201 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	0f 84 6a 04 00 00    	je     801661 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	53                   	push   %ebx
  8011fb:	50                   	push   %eax
  8011fc:	ff d6                	call   *%esi
  8011fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801201:	83 c7 01             	add    $0x1,%edi
  801204:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801208:	83 f8 25             	cmp    $0x25,%eax
  80120b:	75 e2                	jne    8011ef <vprintfmt+0x14>
  80120d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801211:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801218:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80121f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801226:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122b:	eb 07                	jmp    801234 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80122d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801230:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801234:	8d 47 01             	lea    0x1(%edi),%eax
  801237:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80123a:	0f b6 07             	movzbl (%edi),%eax
  80123d:	0f b6 d0             	movzbl %al,%edx
  801240:	83 e8 23             	sub    $0x23,%eax
  801243:	3c 55                	cmp    $0x55,%al
  801245:	0f 87 fb 03 00 00    	ja     801646 <vprintfmt+0x46b>
  80124b:	0f b6 c0             	movzbl %al,%eax
  80124e:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801255:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801258:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80125c:	eb d6                	jmp    801234 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80125e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801261:	b8 00 00 00 00       	mov    $0x0,%eax
  801266:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801269:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80126c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801270:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801273:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801276:	83 f9 09             	cmp    $0x9,%ecx
  801279:	77 3f                	ja     8012ba <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80127b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80127e:	eb e9                	jmp    801269 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801280:	8b 45 14             	mov    0x14(%ebp),%eax
  801283:	8b 00                	mov    (%eax),%eax
  801285:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801288:	8b 45 14             	mov    0x14(%ebp),%eax
  80128b:	8d 40 04             	lea    0x4(%eax),%eax
  80128e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801291:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801294:	eb 2a                	jmp    8012c0 <vprintfmt+0xe5>
  801296:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801299:	85 c0                	test   %eax,%eax
  80129b:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a0:	0f 49 d0             	cmovns %eax,%edx
  8012a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a9:	eb 89                	jmp    801234 <vprintfmt+0x59>
  8012ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012b5:	e9 7a ff ff ff       	jmp    801234 <vprintfmt+0x59>
  8012ba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012bd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012c4:	0f 89 6a ff ff ff    	jns    801234 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d7:	e9 58 ff ff ff       	jmp    801234 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012dc:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8012e2:	e9 4d ff ff ff       	jmp    801234 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ea:	8d 78 04             	lea    0x4(%eax),%edi
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	53                   	push   %ebx
  8012f1:	ff 30                	pushl  (%eax)
  8012f3:	ff d6                	call   *%esi
			break;
  8012f5:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012f8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8012fe:	e9 fe fe ff ff       	jmp    801201 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801303:	8b 45 14             	mov    0x14(%ebp),%eax
  801306:	8d 78 04             	lea    0x4(%eax),%edi
  801309:	8b 00                	mov    (%eax),%eax
  80130b:	99                   	cltd   
  80130c:	31 d0                	xor    %edx,%eax
  80130e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801310:	83 f8 0f             	cmp    $0xf,%eax
  801313:	7f 0b                	jg     801320 <vprintfmt+0x145>
  801315:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80131c:	85 d2                	test   %edx,%edx
  80131e:	75 1b                	jne    80133b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801320:	50                   	push   %eax
  801321:	68 9b 1f 80 00       	push   $0x801f9b
  801326:	53                   	push   %ebx
  801327:	56                   	push   %esi
  801328:	e8 91 fe ff ff       	call   8011be <printfmt>
  80132d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801330:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801336:	e9 c6 fe ff ff       	jmp    801201 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80133b:	52                   	push   %edx
  80133c:	68 26 1f 80 00       	push   $0x801f26
  801341:	53                   	push   %ebx
  801342:	56                   	push   %esi
  801343:	e8 76 fe ff ff       	call   8011be <printfmt>
  801348:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80134b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801351:	e9 ab fe ff ff       	jmp    801201 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801356:	8b 45 14             	mov    0x14(%ebp),%eax
  801359:	83 c0 04             	add    $0x4,%eax
  80135c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80135f:	8b 45 14             	mov    0x14(%ebp),%eax
  801362:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801364:	85 ff                	test   %edi,%edi
  801366:	b8 94 1f 80 00       	mov    $0x801f94,%eax
  80136b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80136e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801372:	0f 8e 94 00 00 00    	jle    80140c <vprintfmt+0x231>
  801378:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80137c:	0f 84 98 00 00 00    	je     80141a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	ff 75 d0             	pushl  -0x30(%ebp)
  801388:	57                   	push   %edi
  801389:	e8 5b 03 00 00       	call   8016e9 <strnlen>
  80138e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801391:	29 c1                	sub    %eax,%ecx
  801393:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801396:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801399:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80139d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a5:	eb 0f                	jmp    8013b6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	53                   	push   %ebx
  8013ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ae:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b0:	83 ef 01             	sub    $0x1,%edi
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 ff                	test   %edi,%edi
  8013b8:	7f ed                	jg     8013a7 <vprintfmt+0x1cc>
  8013ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013bd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013c0:	85 c9                	test   %ecx,%ecx
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c7:	0f 49 c1             	cmovns %ecx,%eax
  8013ca:	29 c1                	sub    %eax,%ecx
  8013cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8013cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013d5:	89 cb                	mov    %ecx,%ebx
  8013d7:	eb 4d                	jmp    801426 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013dd:	74 1b                	je     8013fa <vprintfmt+0x21f>
  8013df:	0f be c0             	movsbl %al,%eax
  8013e2:	83 e8 20             	sub    $0x20,%eax
  8013e5:	83 f8 5e             	cmp    $0x5e,%eax
  8013e8:	76 10                	jbe    8013fa <vprintfmt+0x21f>
					putch('?', putdat);
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	ff 75 0c             	pushl  0xc(%ebp)
  8013f0:	6a 3f                	push   $0x3f
  8013f2:	ff 55 08             	call   *0x8(%ebp)
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	eb 0d                	jmp    801407 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	ff 75 0c             	pushl  0xc(%ebp)
  801400:	52                   	push   %edx
  801401:	ff 55 08             	call   *0x8(%ebp)
  801404:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801407:	83 eb 01             	sub    $0x1,%ebx
  80140a:	eb 1a                	jmp    801426 <vprintfmt+0x24b>
  80140c:	89 75 08             	mov    %esi,0x8(%ebp)
  80140f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801412:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801415:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801418:	eb 0c                	jmp    801426 <vprintfmt+0x24b>
  80141a:	89 75 08             	mov    %esi,0x8(%ebp)
  80141d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801420:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801423:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801426:	83 c7 01             	add    $0x1,%edi
  801429:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80142d:	0f be d0             	movsbl %al,%edx
  801430:	85 d2                	test   %edx,%edx
  801432:	74 23                	je     801457 <vprintfmt+0x27c>
  801434:	85 f6                	test   %esi,%esi
  801436:	78 a1                	js     8013d9 <vprintfmt+0x1fe>
  801438:	83 ee 01             	sub    $0x1,%esi
  80143b:	79 9c                	jns    8013d9 <vprintfmt+0x1fe>
  80143d:	89 df                	mov    %ebx,%edi
  80143f:	8b 75 08             	mov    0x8(%ebp),%esi
  801442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801445:	eb 18                	jmp    80145f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	53                   	push   %ebx
  80144b:	6a 20                	push   $0x20
  80144d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80144f:	83 ef 01             	sub    $0x1,%edi
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb 08                	jmp    80145f <vprintfmt+0x284>
  801457:	89 df                	mov    %ebx,%edi
  801459:	8b 75 08             	mov    0x8(%ebp),%esi
  80145c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80145f:	85 ff                	test   %edi,%edi
  801461:	7f e4                	jg     801447 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801463:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801466:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80146c:	e9 90 fd ff ff       	jmp    801201 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801471:	83 f9 01             	cmp    $0x1,%ecx
  801474:	7e 19                	jle    80148f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801476:	8b 45 14             	mov    0x14(%ebp),%eax
  801479:	8b 50 04             	mov    0x4(%eax),%edx
  80147c:	8b 00                	mov    (%eax),%eax
  80147e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801481:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801484:	8b 45 14             	mov    0x14(%ebp),%eax
  801487:	8d 40 08             	lea    0x8(%eax),%eax
  80148a:	89 45 14             	mov    %eax,0x14(%ebp)
  80148d:	eb 38                	jmp    8014c7 <vprintfmt+0x2ec>
	else if (lflag)
  80148f:	85 c9                	test   %ecx,%ecx
  801491:	74 1b                	je     8014ae <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801493:	8b 45 14             	mov    0x14(%ebp),%eax
  801496:	8b 00                	mov    (%eax),%eax
  801498:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149b:	89 c1                	mov    %eax,%ecx
  80149d:	c1 f9 1f             	sar    $0x1f,%ecx
  8014a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a6:	8d 40 04             	lea    0x4(%eax),%eax
  8014a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ac:	eb 19                	jmp    8014c7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b1:	8b 00                	mov    (%eax),%eax
  8014b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b6:	89 c1                	mov    %eax,%ecx
  8014b8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014bb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014be:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c1:	8d 40 04             	lea    0x4(%eax),%eax
  8014c4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014cd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014d6:	0f 89 36 01 00 00    	jns    801612 <vprintfmt+0x437>
				putch('-', putdat);
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	53                   	push   %ebx
  8014e0:	6a 2d                	push   $0x2d
  8014e2:	ff d6                	call   *%esi
				num = -(long long) num;
  8014e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014ea:	f7 da                	neg    %edx
  8014ec:	83 d1 00             	adc    $0x0,%ecx
  8014ef:	f7 d9                	neg    %ecx
  8014f1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f9:	e9 14 01 00 00       	jmp    801612 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014fe:	83 f9 01             	cmp    $0x1,%ecx
  801501:	7e 18                	jle    80151b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801503:	8b 45 14             	mov    0x14(%ebp),%eax
  801506:	8b 10                	mov    (%eax),%edx
  801508:	8b 48 04             	mov    0x4(%eax),%ecx
  80150b:	8d 40 08             	lea    0x8(%eax),%eax
  80150e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801511:	b8 0a 00 00 00       	mov    $0xa,%eax
  801516:	e9 f7 00 00 00       	jmp    801612 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80151b:	85 c9                	test   %ecx,%ecx
  80151d:	74 1a                	je     801539 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80151f:	8b 45 14             	mov    0x14(%ebp),%eax
  801522:	8b 10                	mov    (%eax),%edx
  801524:	b9 00 00 00 00       	mov    $0x0,%ecx
  801529:	8d 40 04             	lea    0x4(%eax),%eax
  80152c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80152f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801534:	e9 d9 00 00 00       	jmp    801612 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801539:	8b 45 14             	mov    0x14(%ebp),%eax
  80153c:	8b 10                	mov    (%eax),%edx
  80153e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801543:	8d 40 04             	lea    0x4(%eax),%eax
  801546:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801549:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154e:	e9 bf 00 00 00       	jmp    801612 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801553:	83 f9 01             	cmp    $0x1,%ecx
  801556:	7e 13                	jle    80156b <vprintfmt+0x390>
		return va_arg(*ap, long long);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8b 50 04             	mov    0x4(%eax),%edx
  80155e:	8b 00                	mov    (%eax),%eax
  801560:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801563:	8d 49 08             	lea    0x8(%ecx),%ecx
  801566:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801569:	eb 28                	jmp    801593 <vprintfmt+0x3b8>
	else if (lflag)
  80156b:	85 c9                	test   %ecx,%ecx
  80156d:	74 13                	je     801582 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8b 10                	mov    (%eax),%edx
  801574:	89 d0                	mov    %edx,%eax
  801576:	99                   	cltd   
  801577:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80157a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80157d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801580:	eb 11                	jmp    801593 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  801582:	8b 45 14             	mov    0x14(%ebp),%eax
  801585:	8b 10                	mov    (%eax),%edx
  801587:	89 d0                	mov    %edx,%eax
  801589:	99                   	cltd   
  80158a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80158d:	8d 49 04             	lea    0x4(%ecx),%ecx
  801590:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  801593:	89 d1                	mov    %edx,%ecx
  801595:	89 c2                	mov    %eax,%edx
			base = 8;
  801597:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80159c:	eb 74                	jmp    801612 <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	53                   	push   %ebx
  8015a2:	6a 30                	push   $0x30
  8015a4:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	53                   	push   %ebx
  8015aa:	6a 78                	push   $0x78
  8015ac:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b1:	8b 10                	mov    (%eax),%edx
  8015b3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015bb:	8d 40 04             	lea    0x4(%eax),%eax
  8015be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c6:	eb 4a                	jmp    801612 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015c8:	83 f9 01             	cmp    $0x1,%ecx
  8015cb:	7e 15                	jle    8015e2 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8015cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d0:	8b 10                	mov    (%eax),%edx
  8015d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d5:	8d 40 08             	lea    0x8(%eax),%eax
  8015d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015db:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e0:	eb 30                	jmp    801612 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015e2:	85 c9                	test   %ecx,%ecx
  8015e4:	74 17                	je     8015fd <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8015e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e9:	8b 10                	mov    (%eax),%edx
  8015eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f0:	8d 40 04             	lea    0x4(%eax),%eax
  8015f3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fb:	eb 15                	jmp    801612 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8015fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801600:	8b 10                	mov    (%eax),%edx
  801602:	b9 00 00 00 00       	mov    $0x0,%ecx
  801607:	8d 40 04             	lea    0x4(%eax),%eax
  80160a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80160d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801619:	57                   	push   %edi
  80161a:	ff 75 e0             	pushl  -0x20(%ebp)
  80161d:	50                   	push   %eax
  80161e:	51                   	push   %ecx
  80161f:	52                   	push   %edx
  801620:	89 da                	mov    %ebx,%edx
  801622:	89 f0                	mov    %esi,%eax
  801624:	e8 c9 fa ff ff       	call   8010f2 <printnum>
			break;
  801629:	83 c4 20             	add    $0x20,%esp
  80162c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80162f:	e9 cd fb ff ff       	jmp    801201 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	53                   	push   %ebx
  801638:	52                   	push   %edx
  801639:	ff d6                	call   *%esi
			break;
  80163b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80163e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801641:	e9 bb fb ff ff       	jmp    801201 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	53                   	push   %ebx
  80164a:	6a 25                	push   $0x25
  80164c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	eb 03                	jmp    801656 <vprintfmt+0x47b>
  801653:	83 ef 01             	sub    $0x1,%edi
  801656:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80165a:	75 f7                	jne    801653 <vprintfmt+0x478>
  80165c:	e9 a0 fb ff ff       	jmp    801201 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801661:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801664:	5b                   	pop    %ebx
  801665:	5e                   	pop    %esi
  801666:	5f                   	pop    %edi
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 18             	sub    $0x18,%esp
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801675:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801678:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80167c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80167f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801686:	85 c0                	test   %eax,%eax
  801688:	74 26                	je     8016b0 <vsnprintf+0x47>
  80168a:	85 d2                	test   %edx,%edx
  80168c:	7e 22                	jle    8016b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80168e:	ff 75 14             	pushl  0x14(%ebp)
  801691:	ff 75 10             	pushl  0x10(%ebp)
  801694:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	68 a1 11 80 00       	push   $0x8011a1
  80169d:	e8 39 fb ff ff       	call   8011db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	83 c4 10             	add    $0x10,%esp
  8016ae:	eb 05                	jmp    8016b5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c0:	50                   	push   %eax
  8016c1:	ff 75 10             	pushl  0x10(%ebp)
  8016c4:	ff 75 0c             	pushl  0xc(%ebp)
  8016c7:	ff 75 08             	pushl  0x8(%ebp)
  8016ca:	e8 9a ff ff ff       	call   801669 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dc:	eb 03                	jmp    8016e1 <strlen+0x10>
		n++;
  8016de:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e5:	75 f7                	jne    8016de <strlen+0xd>
		n++;
	return n;
}
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f7:	eb 03                	jmp    8016fc <strnlen+0x13>
		n++;
  8016f9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fc:	39 c2                	cmp    %eax,%edx
  8016fe:	74 08                	je     801708 <strnlen+0x1f>
  801700:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801704:	75 f3                	jne    8016f9 <strnlen+0x10>
  801706:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801714:	89 c2                	mov    %eax,%edx
  801716:	83 c2 01             	add    $0x1,%edx
  801719:	83 c1 01             	add    $0x1,%ecx
  80171c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801720:	88 5a ff             	mov    %bl,-0x1(%edx)
  801723:	84 db                	test   %bl,%bl
  801725:	75 ef                	jne    801716 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801727:	5b                   	pop    %ebx
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	53                   	push   %ebx
  80172e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801731:	53                   	push   %ebx
  801732:	e8 9a ff ff ff       	call   8016d1 <strlen>
  801737:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	01 d8                	add    %ebx,%eax
  80173f:	50                   	push   %eax
  801740:	e8 c5 ff ff ff       	call   80170a <strcpy>
	return dst;
}
  801745:	89 d8                	mov    %ebx,%eax
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
  801751:	8b 75 08             	mov    0x8(%ebp),%esi
  801754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801757:	89 f3                	mov    %esi,%ebx
  801759:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80175c:	89 f2                	mov    %esi,%edx
  80175e:	eb 0f                	jmp    80176f <strncpy+0x23>
		*dst++ = *src;
  801760:	83 c2 01             	add    $0x1,%edx
  801763:	0f b6 01             	movzbl (%ecx),%eax
  801766:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801769:	80 39 01             	cmpb   $0x1,(%ecx)
  80176c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176f:	39 da                	cmp    %ebx,%edx
  801771:	75 ed                	jne    801760 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801773:	89 f0                	mov    %esi,%eax
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	8b 75 08             	mov    0x8(%ebp),%esi
  801781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801784:	8b 55 10             	mov    0x10(%ebp),%edx
  801787:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801789:	85 d2                	test   %edx,%edx
  80178b:	74 21                	je     8017ae <strlcpy+0x35>
  80178d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801791:	89 f2                	mov    %esi,%edx
  801793:	eb 09                	jmp    80179e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801795:	83 c2 01             	add    $0x1,%edx
  801798:	83 c1 01             	add    $0x1,%ecx
  80179b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80179e:	39 c2                	cmp    %eax,%edx
  8017a0:	74 09                	je     8017ab <strlcpy+0x32>
  8017a2:	0f b6 19             	movzbl (%ecx),%ebx
  8017a5:	84 db                	test   %bl,%bl
  8017a7:	75 ec                	jne    801795 <strlcpy+0x1c>
  8017a9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ae:	29 f0                	sub    %esi,%eax
}
  8017b0:	5b                   	pop    %ebx
  8017b1:	5e                   	pop    %esi
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017bd:	eb 06                	jmp    8017c5 <strcmp+0x11>
		p++, q++;
  8017bf:	83 c1 01             	add    $0x1,%ecx
  8017c2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017c5:	0f b6 01             	movzbl (%ecx),%eax
  8017c8:	84 c0                	test   %al,%al
  8017ca:	74 04                	je     8017d0 <strcmp+0x1c>
  8017cc:	3a 02                	cmp    (%edx),%al
  8017ce:	74 ef                	je     8017bf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d0:	0f b6 c0             	movzbl %al,%eax
  8017d3:	0f b6 12             	movzbl (%edx),%edx
  8017d6:	29 d0                	sub    %edx,%eax
}
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	53                   	push   %ebx
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e4:	89 c3                	mov    %eax,%ebx
  8017e6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e9:	eb 06                	jmp    8017f1 <strncmp+0x17>
		n--, p++, q++;
  8017eb:	83 c0 01             	add    $0x1,%eax
  8017ee:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017f1:	39 d8                	cmp    %ebx,%eax
  8017f3:	74 15                	je     80180a <strncmp+0x30>
  8017f5:	0f b6 08             	movzbl (%eax),%ecx
  8017f8:	84 c9                	test   %cl,%cl
  8017fa:	74 04                	je     801800 <strncmp+0x26>
  8017fc:	3a 0a                	cmp    (%edx),%cl
  8017fe:	74 eb                	je     8017eb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801800:	0f b6 00             	movzbl (%eax),%eax
  801803:	0f b6 12             	movzbl (%edx),%edx
  801806:	29 d0                	sub    %edx,%eax
  801808:	eb 05                	jmp    80180f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80180f:	5b                   	pop    %ebx
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181c:	eb 07                	jmp    801825 <strchr+0x13>
		if (*s == c)
  80181e:	38 ca                	cmp    %cl,%dl
  801820:	74 0f                	je     801831 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801822:	83 c0 01             	add    $0x1,%eax
  801825:	0f b6 10             	movzbl (%eax),%edx
  801828:	84 d2                	test   %dl,%dl
  80182a:	75 f2                	jne    80181e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80182c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	8b 45 08             	mov    0x8(%ebp),%eax
  801839:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183d:	eb 03                	jmp    801842 <strfind+0xf>
  80183f:	83 c0 01             	add    $0x1,%eax
  801842:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801845:	38 ca                	cmp    %cl,%dl
  801847:	74 04                	je     80184d <strfind+0x1a>
  801849:	84 d2                	test   %dl,%dl
  80184b:	75 f2                	jne    80183f <strfind+0xc>
			break;
	return (char *) s;
}
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	57                   	push   %edi
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	8b 7d 08             	mov    0x8(%ebp),%edi
  801858:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80185b:	85 c9                	test   %ecx,%ecx
  80185d:	74 36                	je     801895 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80185f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801865:	75 28                	jne    80188f <memset+0x40>
  801867:	f6 c1 03             	test   $0x3,%cl
  80186a:	75 23                	jne    80188f <memset+0x40>
		c &= 0xFF;
  80186c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801870:	89 d3                	mov    %edx,%ebx
  801872:	c1 e3 08             	shl    $0x8,%ebx
  801875:	89 d6                	mov    %edx,%esi
  801877:	c1 e6 18             	shl    $0x18,%esi
  80187a:	89 d0                	mov    %edx,%eax
  80187c:	c1 e0 10             	shl    $0x10,%eax
  80187f:	09 f0                	or     %esi,%eax
  801881:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801883:	89 d8                	mov    %ebx,%eax
  801885:	09 d0                	or     %edx,%eax
  801887:	c1 e9 02             	shr    $0x2,%ecx
  80188a:	fc                   	cld    
  80188b:	f3 ab                	rep stos %eax,%es:(%edi)
  80188d:	eb 06                	jmp    801895 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80188f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801892:	fc                   	cld    
  801893:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801895:	89 f8                	mov    %edi,%eax
  801897:	5b                   	pop    %ebx
  801898:	5e                   	pop    %esi
  801899:	5f                   	pop    %edi
  80189a:	5d                   	pop    %ebp
  80189b:	c3                   	ret    

0080189c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	57                   	push   %edi
  8018a0:	56                   	push   %esi
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018aa:	39 c6                	cmp    %eax,%esi
  8018ac:	73 35                	jae    8018e3 <memmove+0x47>
  8018ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b1:	39 d0                	cmp    %edx,%eax
  8018b3:	73 2e                	jae    8018e3 <memmove+0x47>
		s += n;
		d += n;
  8018b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b8:	89 d6                	mov    %edx,%esi
  8018ba:	09 fe                	or     %edi,%esi
  8018bc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c2:	75 13                	jne    8018d7 <memmove+0x3b>
  8018c4:	f6 c1 03             	test   $0x3,%cl
  8018c7:	75 0e                	jne    8018d7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018c9:	83 ef 04             	sub    $0x4,%edi
  8018cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018cf:	c1 e9 02             	shr    $0x2,%ecx
  8018d2:	fd                   	std    
  8018d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d5:	eb 09                	jmp    8018e0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018d7:	83 ef 01             	sub    $0x1,%edi
  8018da:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018dd:	fd                   	std    
  8018de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e0:	fc                   	cld    
  8018e1:	eb 1d                	jmp    801900 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e3:	89 f2                	mov    %esi,%edx
  8018e5:	09 c2                	or     %eax,%edx
  8018e7:	f6 c2 03             	test   $0x3,%dl
  8018ea:	75 0f                	jne    8018fb <memmove+0x5f>
  8018ec:	f6 c1 03             	test   $0x3,%cl
  8018ef:	75 0a                	jne    8018fb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018f1:	c1 e9 02             	shr    $0x2,%ecx
  8018f4:	89 c7                	mov    %eax,%edi
  8018f6:	fc                   	cld    
  8018f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f9:	eb 05                	jmp    801900 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018fb:	89 c7                	mov    %eax,%edi
  8018fd:	fc                   	cld    
  8018fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801900:	5e                   	pop    %esi
  801901:	5f                   	pop    %edi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801907:	ff 75 10             	pushl  0x10(%ebp)
  80190a:	ff 75 0c             	pushl  0xc(%ebp)
  80190d:	ff 75 08             	pushl  0x8(%ebp)
  801910:	e8 87 ff ff ff       	call   80189c <memmove>
}
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801922:	89 c6                	mov    %eax,%esi
  801924:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801927:	eb 1a                	jmp    801943 <memcmp+0x2c>
		if (*s1 != *s2)
  801929:	0f b6 08             	movzbl (%eax),%ecx
  80192c:	0f b6 1a             	movzbl (%edx),%ebx
  80192f:	38 d9                	cmp    %bl,%cl
  801931:	74 0a                	je     80193d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801933:	0f b6 c1             	movzbl %cl,%eax
  801936:	0f b6 db             	movzbl %bl,%ebx
  801939:	29 d8                	sub    %ebx,%eax
  80193b:	eb 0f                	jmp    80194c <memcmp+0x35>
		s1++, s2++;
  80193d:	83 c0 01             	add    $0x1,%eax
  801940:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801943:	39 f0                	cmp    %esi,%eax
  801945:	75 e2                	jne    801929 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	53                   	push   %ebx
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801957:	89 c1                	mov    %eax,%ecx
  801959:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80195c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801960:	eb 0a                	jmp    80196c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801962:	0f b6 10             	movzbl (%eax),%edx
  801965:	39 da                	cmp    %ebx,%edx
  801967:	74 07                	je     801970 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801969:	83 c0 01             	add    $0x1,%eax
  80196c:	39 c8                	cmp    %ecx,%eax
  80196e:	72 f2                	jb     801962 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801970:	5b                   	pop    %ebx
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	57                   	push   %edi
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197f:	eb 03                	jmp    801984 <strtol+0x11>
		s++;
  801981:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801984:	0f b6 01             	movzbl (%ecx),%eax
  801987:	3c 20                	cmp    $0x20,%al
  801989:	74 f6                	je     801981 <strtol+0xe>
  80198b:	3c 09                	cmp    $0x9,%al
  80198d:	74 f2                	je     801981 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80198f:	3c 2b                	cmp    $0x2b,%al
  801991:	75 0a                	jne    80199d <strtol+0x2a>
		s++;
  801993:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801996:	bf 00 00 00 00       	mov    $0x0,%edi
  80199b:	eb 11                	jmp    8019ae <strtol+0x3b>
  80199d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a2:	3c 2d                	cmp    $0x2d,%al
  8019a4:	75 08                	jne    8019ae <strtol+0x3b>
		s++, neg = 1;
  8019a6:	83 c1 01             	add    $0x1,%ecx
  8019a9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b4:	75 15                	jne    8019cb <strtol+0x58>
  8019b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b9:	75 10                	jne    8019cb <strtol+0x58>
  8019bb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019bf:	75 7c                	jne    801a3d <strtol+0xca>
		s += 2, base = 16;
  8019c1:	83 c1 02             	add    $0x2,%ecx
  8019c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019c9:	eb 16                	jmp    8019e1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019cb:	85 db                	test   %ebx,%ebx
  8019cd:	75 12                	jne    8019e1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019cf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019d4:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d7:	75 08                	jne    8019e1 <strtol+0x6e>
		s++, base = 8;
  8019d9:	83 c1 01             	add    $0x1,%ecx
  8019dc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e9:	0f b6 11             	movzbl (%ecx),%edx
  8019ec:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ef:	89 f3                	mov    %esi,%ebx
  8019f1:	80 fb 09             	cmp    $0x9,%bl
  8019f4:	77 08                	ja     8019fe <strtol+0x8b>
			dig = *s - '0';
  8019f6:	0f be d2             	movsbl %dl,%edx
  8019f9:	83 ea 30             	sub    $0x30,%edx
  8019fc:	eb 22                	jmp    801a20 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019fe:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a01:	89 f3                	mov    %esi,%ebx
  801a03:	80 fb 19             	cmp    $0x19,%bl
  801a06:	77 08                	ja     801a10 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a08:	0f be d2             	movsbl %dl,%edx
  801a0b:	83 ea 57             	sub    $0x57,%edx
  801a0e:	eb 10                	jmp    801a20 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a10:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a13:	89 f3                	mov    %esi,%ebx
  801a15:	80 fb 19             	cmp    $0x19,%bl
  801a18:	77 16                	ja     801a30 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a1a:	0f be d2             	movsbl %dl,%edx
  801a1d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a20:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a23:	7d 0b                	jge    801a30 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a25:	83 c1 01             	add    $0x1,%ecx
  801a28:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a2c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a2e:	eb b9                	jmp    8019e9 <strtol+0x76>

	if (endptr)
  801a30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a34:	74 0d                	je     801a43 <strtol+0xd0>
		*endptr = (char *) s;
  801a36:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a39:	89 0e                	mov    %ecx,(%esi)
  801a3b:	eb 06                	jmp    801a43 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a3d:	85 db                	test   %ebx,%ebx
  801a3f:	74 98                	je     8019d9 <strtol+0x66>
  801a41:	eb 9e                	jmp    8019e1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a43:	89 c2                	mov    %eax,%edx
  801a45:	f7 da                	neg    %edx
  801a47:	85 ff                	test   %edi,%edi
  801a49:	0f 45 c2             	cmovne %edx,%eax
}
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5f                   	pop    %edi
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	8b 75 08             	mov    0x8(%ebp),%esi
  801a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	74 0e                	je     801a71 <ipc_recv+0x20>
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	50                   	push   %eax
  801a67:	e8 9a e8 ff ff       	call   800306 <sys_ipc_recv>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	eb 10                	jmp    801a81 <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	68 00 00 c0 ee       	push   $0xeec00000
  801a79:	e8 88 e8 ff ff       	call   800306 <sys_ipc_recv>
  801a7e:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801a81:	85 c0                	test   %eax,%eax
  801a83:	74 16                	je     801a9b <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801a85:	85 f6                	test   %esi,%esi
  801a87:	74 06                	je     801a8f <ipc_recv+0x3e>
  801a89:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801a8f:	85 db                	test   %ebx,%ebx
  801a91:	74 2c                	je     801abf <ipc_recv+0x6e>
  801a93:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a99:	eb 24                	jmp    801abf <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801a9b:	85 f6                	test   %esi,%esi
  801a9d:	74 0a                	je     801aa9 <ipc_recv+0x58>
  801a9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa4:	8b 40 74             	mov    0x74(%eax),%eax
  801aa7:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801aa9:	85 db                	test   %ebx,%ebx
  801aab:	74 0a                	je     801ab7 <ipc_recv+0x66>
  801aad:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab2:	8b 40 78             	mov    0x78(%eax),%eax
  801ab5:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ab7:	a1 04 40 80 00       	mov    0x804004,%eax
  801abc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	57                   	push   %edi
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801adf:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801ae2:	ff 75 14             	pushl  0x14(%ebp)
  801ae5:	53                   	push   %ebx
  801ae6:	56                   	push   %esi
  801ae7:	57                   	push   %edi
  801ae8:	e8 f6 e7 ff ff       	call   8002e3 <sys_ipc_try_send>
		if (ret == 0) break;
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	74 1e                	je     801b12 <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801af4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af7:	74 12                	je     801b0b <ipc_send+0x45>
  801af9:	50                   	push   %eax
  801afa:	68 80 22 80 00       	push   $0x802280
  801aff:	6a 39                	push   $0x39
  801b01:	68 8d 22 80 00       	push   $0x80228d
  801b06:	e8 fa f4 ff ff       	call   801005 <_panic>
		sys_yield();
  801b0b:	e8 27 e6 ff ff       	call   800137 <sys_yield>
	}
  801b10:	eb d0                	jmp    801ae2 <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5f                   	pop    %edi
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b25:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b28:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2e:	8b 52 50             	mov    0x50(%edx),%edx
  801b31:	39 ca                	cmp    %ecx,%edx
  801b33:	75 0d                	jne    801b42 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b35:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b38:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3d:	8b 40 48             	mov    0x48(%eax),%eax
  801b40:	eb 0f                	jmp    801b51 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b42:	83 c0 01             	add    $0x1,%eax
  801b45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4a:	75 d9                	jne    801b25 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b59:	89 d0                	mov    %edx,%eax
  801b5b:	c1 e8 16             	shr    $0x16,%eax
  801b5e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6a:	f6 c1 01             	test   $0x1,%cl
  801b6d:	74 1d                	je     801b8c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6f:	c1 ea 0c             	shr    $0xc,%edx
  801b72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b79:	f6 c2 01             	test   $0x1,%dl
  801b7c:	74 0e                	je     801b8c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7e:	c1 ea 0c             	shr    $0xc,%edx
  801b81:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b88:	ef 
  801b89:	0f b7 c0             	movzwl %ax,%eax
}
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
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
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
