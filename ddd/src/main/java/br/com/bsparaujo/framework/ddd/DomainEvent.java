package br.com.bsparaujo.framework.ddd;

import lombok.AccessLevel;
import lombok.Data;
import lombok.Setter;

/**
 * Objetos que implementam essa interface representam eventos que ocorreram no domínio.
 */
@Data
@Setter(AccessLevel.PACKAGE)
public abstract class DomainEvent {

    private final long eventTime = System.currentTimeMillis();

}
