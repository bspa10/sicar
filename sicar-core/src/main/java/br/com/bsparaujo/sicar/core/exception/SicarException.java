package br.com.bsparaujo.sicar.core.exception;

/**
 * Exceção base para da aplicação.
 */
public abstract class SicarException extends RuntimeException {

    public SicarException(String message) {
        super(message);
    }

    public SicarException(String message, Throwable cause) {
        super(message, cause);
    }
}
