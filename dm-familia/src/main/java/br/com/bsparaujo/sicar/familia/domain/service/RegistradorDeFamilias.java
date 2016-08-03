package br.com.bsparaujo.sicar.familia.domain.service;

import br.com.bsparaujo.sicar.familia.domain.model.Familia;

public interface RegistradorDeFamilias {

    /**
     * Registra uma família na aplicação.
     *
     * @param familia Família que será registrada
     */
    void registar(Familia familia);

    void remover(Familia familia);
}
