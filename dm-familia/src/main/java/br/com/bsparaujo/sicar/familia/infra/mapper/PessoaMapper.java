package br.com.bsparaujo.sicar.familia.infra.mapper;

import br.com.bsparaujo.datatype.Documento;
import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.sicar.familia.domain.model.Pessoa;
import br.com.bsparaujo.sicar.infra.mapper.DataMapper;

import java.util.Optional;

public interface PessoaMapper extends DataMapper<Pessoa> {

    /**
     * Obtém uma pessoa segundo seu endereço de e-mail.
     *
     * @param email E-mail que será pesquisado
     * @return Pessoa encontrada, ou um {@link Optional#empty()}.
     */
    Optional<Pessoa> findByEmail(final Email email);

    Pessoa atualizar(final long pessoaId, Documento documento, Nome nome, Email email);

    void excluir(final Email email);
}
