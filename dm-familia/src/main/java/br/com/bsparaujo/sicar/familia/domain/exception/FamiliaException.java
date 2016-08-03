package br.com.bsparaujo.sicar.familia.domain.exception;

import br.com.bsparaujo.sicar.domain.core.DomainException;

public class FamiliaException extends DomainException {
    public FamiliaException(String message) {
        super(message);
    }

    public FamiliaException(String message, Throwable cause) {
        super(message, cause);
    }
}
