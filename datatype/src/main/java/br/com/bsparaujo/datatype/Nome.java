package br.com.bsparaujo.datatype;

import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;

@EqualsAndHashCode
@Getter(AccessLevel.PUBLIC)
public final class Nome {
    private static final String NOME_REGEX = "^[a-zA-ZÁÂÃÀÇÉÊÍÓÔÕÚÜáâãàçéêíóôõúü ]*$";

    private final String primeiro;
    private final String sobrenome;
    private final String completo;

    private Nome(final String primeiro, final String sobrenome) {
        if (primeiro == null || primeiro.trim().length() < 3 || !primeiro.trim().matches(NOME_REGEX)) {
            throw new NomeException("O primeiro nome deve ser informado.");
        }

        if (sobrenome == null || sobrenome.trim().length() < 3 || !sobrenome.trim().matches(NOME_REGEX)) {
            throw new NomeException("O sobrenome deve ser informado.");
        }

        this.primeiro = primeiro;
        this.sobrenome = sobrenome;
        completo = primeiro + " " + sobrenome;
    }

    public static Nome newNome(final String primeiro, final String ultimo) {
        return new Nome(primeiro, ultimo);
    }

}
