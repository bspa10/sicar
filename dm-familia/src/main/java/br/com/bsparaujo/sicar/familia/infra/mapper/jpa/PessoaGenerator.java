package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import br.com.bsparaujo.sicar.infra.mapper.jpa.AbstractSequenceGenerator;

public final class PessoaGenerator extends AbstractSequenceGenerator {

    public PessoaGenerator() {
        super((byte) 1);
    }
}
