# $FreeBSD$

PORTNAME=	lwjgl
DISTVERSION=	3.2.0
CATEGORIES=	games java
MASTER_SITES=	https://github.com/JetBrains/kotlin/releases/download/v1.2.71/:kotlinzip
DISTFILES=	kotlin-compiler-1.2.71.zip:kotlinzip

MAINTAINER=	mmokhi@FreeBSD.org
COMMENT=	Lightweight Java Game Library

LICENSE=	BSD3CLAUSE

BUILD_DEPENDS=	${JAVALIBDIR}/jutils/jutils.jar:games/jutils \
		${JAVALIBDIR}/jinput/jinput.jar:games/jinput
LIB_DEPENDS=	libicuuc.so:devel/icu
RUN_DEPENDS:=	${BUILD_DEPENDS}

ONLY_FOR_ARCHS=	i386 amd64

USES=		pkgconfig
USE_ANT=	yes
USE_GCC=	yes
USE_GNOME=	glib20 gtk30
USE_JAVA=	yes
USE_LDCONFIG=	yes
USE_XORG=	xcursor xrandr xxf86vm
JAVA_VERSION=	1.7+
JAVA_OS=	native
JAVA_VENDOR=	openjdk

LWJGL_BUILD_ARCH=	${ARCH:S/amd/X/:S/i3/X/}
WRKSRC_kotlinzip=	${WRKSRC}/bin/libs/

.for _group in ${_GITHUB_GROUPS:NDEFAULT}
EXTRACT_ONLY:=	${EXTRACT_ONLY} ${DISTFILE_${_group}}:${_group}
.endfor

USE_GITHUB=	yes
GH_ACCOUNT=	LWJGL
GH_PROJECT=	lwjgl3
GH_TAGNAME=	b60d7f9
####GH_TUPLE=	JetBrains:kotlin:v1.2.71:kotlinc/bin/libs

MAKE_ENV+=	CLASSPATH=${JAVALIBDIR}/jutils/jutils.jar:${JAVALIBDIR}/jinput/jinput.jar:${WRKSRC}/${DISTNAME}/jar/ \
		LWJGL_BUILD_ARCH=${LWJGL_BUILD_ARCH} #### LWJGL_BUILD_OFFLINE=yes

PLIST_FILES=	%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}.jar \
		%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}_test.jar \
		%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}_util.jar \
		%%JAVAJARDIR%%/${PORTNAME}/${PORTNAME}_util_applet.jar \
		lib/${PORTNAME}${PORTVERSION}/lib${PORTNAME}.so
PLIST_DIRS=	%%JAVAJARDIR%%/${PORTNAME} \
		lib/${PORTNAME}${PORTVERSION}


post-extract:
	${MKDIR} ${WRKSRC_kotlinzip}
	${CP} ${DISTDIR}/${DIST_SUBDIR}/kotlin-compiler-1.2.71.zip ${WRKSRC_kotlinzip}/
	${TOUCH} ${WRKSRC_kotlinzip}/touch.txt
	#Command below must be changed sometime with a more approproate version....
	unzip ${WRKSRC_kotlinzip}/kotlin-compiler-1.2.71.zip -d ${WRKSRC_kotlinzip}/

post-patch:
	@${REINPLACE_CMD} -e 's|%GCCVER%|${_USE_GCC}|g' \
		${WRKSRC}/config/freebsd/build.xml

do-install:
	@${MKDIR} ${STAGEDIR}${JAVAJARDIR}/${PORTNAME}
.for _jar in ${PLIST_FILES:M*.jar}
	${INSTALL_DATA} ${WRKSRC}/libs/${_jar:T} \
		${STAGEDIR}${JAVAJARDIR}/${PORTNAME}
.endfor
	@${MKDIR} ${STAGEDIR}${PREFIX}/lib/${PORTNAME}${PORTVERSION}
	${INSTALL_DATA} ${WRKSRC}/libs/freebsd/lib${PORTNAME}.so \
		${STAGEDIR}${PREFIX}/lib/${PORTNAME}${PORTVERSION}

.include <bsd.port.mk>
