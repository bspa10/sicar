package br.com.bsparaujo.sicar.familia.domain.repository;

import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.framework.ddd.DomainRepository;
import br.com.bsparaujo.sicar.familia.domain.model.Pessoa;

import java.util.Optional;

public interface PessoaRepository extends DomainRepository<Pessoa> {

    /**
     * Obtém uma pessoa segundo o e-mail que foi cadastrado.
     *
     * @param email Email de cadastro da pessoa
     * @return A pessoa que foi cadastrada, <code>null</code> caso não exista uma pessoa cadastrada com o e-mail informado
     */
    Optional<Pessoa> obterPorEmail(final Email email);

}
