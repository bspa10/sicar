package br.com.bsparaujo.sicar.familia.domain.model;

import br.com.bsparaujo.datatype.Documento;
import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.sicar.familia.domain.repository.PessoaRepository;

interface PessoaInternalRepository extends PessoaRepository {

    Pessoa atualizar(final Pessoa antiga, final Documento documento, final Nome nome, final Email email);

    void salvar(final Pessoa pessoa);
}
