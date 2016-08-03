package br.com.bsparaujo.sicar.familia.domain.model;

import br.com.bsparaujo.datatype.Documento;
import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.sicar.familia.infra.mapper.PessoaMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
@Transactional(transactionManager = "transactionManager", isolation = Isolation.READ_COMMITTED, readOnly = true)
class PessoaRepositoryImpl implements PessoaInternalRepository {

    private final PessoaMapper pessoaMapper;

    @Autowired
    public PessoaRepositoryImpl(final PessoaMapper pessoaMapper) {
        this.pessoaMapper = pessoaMapper;
    }

    @Override
    public Optional<Pessoa> obterPorEmail(final Email email) {
        return pessoaMapper.findByEmail(email);
    }

    @Override
    @Transactional(transactionManager = "transactionManager", isolation = Isolation.READ_COMMITTED)
    public Pessoa atualizar(final Pessoa antiga, final Documento documento, final Nome nome, final Email email) {
        final Optional<Long> optional = antiga.identidade();
        if (!optional.isPresent()) {
            throw new RuntimeException("");
        }

        return pessoaMapper.atualizar(optional.get(), documento, nome, email);
    }

    @Override
    @Transactional(transactionManager = "transactionManager", isolation = Isolation.READ_COMMITTED)
    public void salvar(Pessoa pessoa) {

    }
}
