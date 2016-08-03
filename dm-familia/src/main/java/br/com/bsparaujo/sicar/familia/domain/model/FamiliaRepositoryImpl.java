package br.com.bsparaujo.sicar.familia.domain.model;

import br.com.bsparaujo.sicar.familia.infra.mapper.FamiliaMapper;
import br.com.bsparaujo.sicar.familia.infra.mapper.PessoaMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
@Transactional(transactionManager = "transactionManager", isolation = Isolation.READ_COMMITTED, readOnly = true)
class FamiliaRepositoryImpl implements FamiliaInternalRepository {

    private final FamiliaMapper familiaMapper;
    private final PessoaMapper pessoaMapper;

    @Autowired
    public FamiliaRepositoryImpl(FamiliaMapper familiaMapper, PessoaMapper pessoaMapper) {
        this.familiaMapper = familiaMapper;
        this.pessoaMapper = pessoaMapper;
    }

    @Override
    public List<Familia> listarFamilias (Pessoa pessoa) {
        return familiaMapper.listarFamilias(pessoa.getEmail());
    }

    @Override
    public Optional<Familia> obterPorCabeca(Pessoa pessoa) {
        return familiaMapper.obterPorCabeca(pessoa.getEmail());
    }

    @Override
    @Transactional(transactionManager = "transactionManager", isolation = Isolation.READ_COMMITTED)
    public void removerMembro(Familia familia, Pessoa pessoa) {
        final Optional<Long> optional = familia.identidade();
        if (optional.isPresent()) {
            familiaMapper.removerMembro(optional.get(), pessoa.getEmail());

        /*
         * Se a pessoa não faz parte de uma família
         * Então ela é excluída da base.
         */
            if (listarFamilias(pessoa).isEmpty()) {
                pessoaMapper.excluir(pessoa.getEmail());
            }
        }
    }

    @Override
    @Transactional(transactionManager = "transactionManager", isolation = Isolation.READ_COMMITTED)
    public void adicionarMembro(Familia familia, Pessoa pessoa) {
        final Optional<Long> optional = familia.identidade();
        if (optional.isPresent()) {
            familiaMapper.adicionarMembro(optional.get(), pessoa.getEmail());
        }
    }

    @Override
    @Transactional(transactionManager = "transactionManager", isolation = Isolation.READ_COMMITTED)
    public void salvar(Familia familia) {

    }
}
