package br.com.bsparaujo.sicar.familia.infra.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

@Aspect
@Order(1)
@Component
public class LoggingAspect {
	private static final Logger LOGGER = LoggerFactory.getLogger(LoggingAspect.class);
	
	@Around("execution (* br.com.bsparaujo.sicar.domain..*(..))")
	public void logBefore(ProceedingJoinPoint joinPoint) {
		final String klass = joinPoint.getSignature().getDeclaringTypeName();
		final String method = joinPoint.getSignature().getName();
	}

}
