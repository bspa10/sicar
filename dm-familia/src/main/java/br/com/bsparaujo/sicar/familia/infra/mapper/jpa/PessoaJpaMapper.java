package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import br.com.bsparaujo.datatype.Documento;
import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.sicar.familia.domain.model.Pessoa;
import br.com.bsparaujo.sicar.familia.infra.mapper.PessoaMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
class PessoaJpaMapper extends AbstractJpaMapper implements PessoaMapper {

    private final PessoaJpaRepository pessoaRepository;

    @Autowired
    public PessoaJpaMapper(PessoaJpaRepository pessoaRepository) {
        this.pessoaRepository = pessoaRepository;
    }

    @Override
    public Optional<Pessoa> findByEmail(final Email email) {
        final PessoaEntity entity = pessoaRepository.findByEmail(email.getEndereco());

        if (entity != null) {
            final Pessoa pessoa = Pessoa.of(
                    Documento.newDocumento(entity.getTipoDocumento(), entity.getDocumento()),
                    Nome.newNome(entity.getNome(), entity.getSobrenome()),
                    Email.newEmail(entity.getEmail())
            );

            configurarIdentidade(pessoa, entity.getId());
            return Optional.of(pessoa);
        } else {
            return Optional.empty();
        }
    }

    @Override
    public Pessoa atualizar(final long pessoaId, final Documento documento, final Nome nome, final Email email) {
        final PessoaEntity entity = pessoaRepository.findOne(pessoaId);

        if (documento != null) {
            entity.setTipoDocumento(documento.getTipoDocumento());
            entity.setDocumento(documento.semFormato());
        }

        if (nome != null) {
            entity.setNome(nome.getPrimeiro());
            entity.setSobrenome(nome.getSobrenome());
        }

        if (email != null) {
            entity.setEmail(email.getEndereco());
        }

        pessoaRepository.saveAndFlush(entity);

        // Cria a nova pessoa e configura sua identidade
        final Pessoa pessoa = Pessoa.of(
                Documento.newDocumento(entity.getTipoDocumento(), entity.getDocumento()),
                Nome.newNome(entity.getNome(), entity.getSobrenome()),
                Email.newEmail(entity.getEmail())
        );

        configurarIdentidade(pessoa, pessoaId);
        return pessoa;
    }

    @Override
    public void excluir(final Email email) {
        final PessoaEntity entity = pessoaRepository.findByEmail(email.getEndereco());
        pessoaRepository.delete(entity);
        pessoaRepository.flush();
    }
}
