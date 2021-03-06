From f02619fbce05cb82da19a48216b9ec67139112db Mon Sep 17 00:00:00 2001
From: Arianna Avanzini <avanzini.arianna@gmail.com>
Date: Mon, 27 Jan 2014 23:50:08 +0100
Subject: [PATCH 1/3] block: cgroups, kconfig, build bits for BFQ-v7r8-3.4

Update Kconfig.iosched and do the related Makefile changes to include
kernel configuration options for BFQ. Also add the bfqio controller
to the cgroups subsystem.

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
Signed-off-by: Arianna Avanzini <avanzini.arianna@gmail.com>
---
 block/Kconfig.iosched         | 33 +++++++++++++++++++++++++++++++++
 block/Makefile                |  1 +
 include/linux/cgroup_subsys.h |  6 ++++++
 3 files changed, 40 insertions(+)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 3199b76..2b6d805 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -43,6 +43,28 @@ config CFQ_GROUP_IOSCHED
 	---help---
 	  Enable group IO scheduling in CFQ.
 
+config IOSCHED_BFQ
+	tristate "BFQ I/O scheduler"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	  The BFQ I/O scheduler tries to distribute bandwidth among
+	  all processes according to their weights.
+	  It aims at distributing the bandwidth as desired, independently of
+	  the disk parameters and with any workload. It also tries to
+	  guarantee low latency to interactive and soft real-time
+	  applications. If compiled built-in (saying Y here), BFQ can
+	  be configured to support hierarchical scheduling.
+
+config CGROUP_BFQIO
+	bool "BFQ hierarchical scheduling support"
+	depends on CGROUPS && IOSCHED_BFQ=y
+	default n
+	---help---
+	  Enable hierarchical scheduling in BFQ, using the cgroups
+	  filesystem interface.  The name of the subsystem will be
+	  bfqio.
+
 choice
 	prompt "Default I/O scheduler"
 	default DEFAULT_CFQ
@@ -56,6 +78,16 @@ choice
 	config DEFAULT_CFQ
 		bool "CFQ" if IOSCHED_CFQ=y
 
+	config DEFAULT_BFQ
+		bool "BFQ" if IOSCHED_BFQ=y
+		help
+		  Selects BFQ as the default I/O scheduler which will be
+		  used by default for all block devices.
+		  The BFQ I/O scheduler aims at distributing the bandwidth
+		  as desired, independently of the disk parameters and with
+		  any workload. It also tries to guarantee low latency to
+		  interactive and soft real-time applications.
+
 	config DEFAULT_NOOP
 		bool "No-op"
 
@@ -65,6 +97,7 @@ config DEFAULT_IOSCHED
 	string
 	default "deadline" if DEFAULT_DEADLINE
 	default "cfq" if DEFAULT_CFQ
+	default "bfq" if DEFAULT_BFQ
 	default "noop" if DEFAULT_NOOP
 
 endmenu
diff --git a/block/Makefile b/block/Makefile
index 39b76ba..c0d20fa 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_BLK_DEV_THROTTLING)	+= blk-throttle.o
 obj-$(CONFIG_IOSCHED_NOOP)	+= noop-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
+obj-$(CONFIG_IOSCHED_BFQ)	+= bfq-iosched.o
 
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 0bd390c..cbf22b1 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -48,2 +48,8 @@ SUBSYS(net_prio)
 #endif
 
+
+#ifdef CONFIG_CGROUP_BFQIO
+SUBSYS(bfqio)
+#endif
+
+/* */
-- 
2.1.4

