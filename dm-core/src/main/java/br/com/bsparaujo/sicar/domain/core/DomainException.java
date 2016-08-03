package br.com.bsparaujo.sicar.domain.core;

import br.com.bsparaujo.sicar.core.exception.SicarException;

/**
 * Exceção base para camada de domínio.
 */
public abstract class DomainException extends SicarException {
    public DomainException(String message) {
        super(message);
    }

    public DomainException(String message, Throwable cause) {
        super(message, cause);
    }
}
