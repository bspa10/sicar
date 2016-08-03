package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.sicar.familia.domain.model.Familia;
import br.com.bsparaujo.sicar.familia.domain.model.Pessoa;
import br.com.bsparaujo.sicar.familia.infra.mapper.FamiliaMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Component
class FamiliaJpaMapper extends AbstractJpaMapper implements FamiliaMapper {

    private final FamiliaJpaRepository familiaRepository;
    private final PessoaJpaRepository pessoaRepository;

    @Autowired
    public FamiliaJpaMapper(FamiliaJpaRepository familiaRepository, PessoaJpaRepository pessoaRepository) {
        this.familiaRepository = familiaRepository;
        this.pessoaRepository = pessoaRepository;
    }

    @Override
    public List<Familia> listarFamilias(final Email email) {
        final PessoaEntity pessoaEntity = pessoaRepository.findByEmail(email.getEndereco());
        if (pessoaEntity == null) {
            return Collections.emptyList();
        }

        final List <FamiliaEntity > entities = familiaRepository.listByMembro(pessoaEntity.getId());
        if (entities != null && !entities.isEmpty()) {
            final List<Familia> familias = new ArrayList<>(entities.size());
            entities
                    .stream()
                    .forEach(entity -> {
                        final Pessoa cabeca = fromEntity(entity.getCabeca());
                        final Nome nome = Nome.newNome(entity.getNome(), entity.getSobrenome());
                        final Familia familia = Familia.of(cabeca, nome);

                        configurarIdentidade(familia, entity.getId());
                        familias.add(familia);
                    });

            return familias;
        }

        return Collections.emptyList();
    }

    @Override
    public Optional<Familia> obterPorCabeca(final Email email) {
        final PessoaEntity pessoaEntity = pessoaRepository.findByEmail(email.getEndereco());
        if (pessoaEntity == null) {
            return Optional.empty();
        }

        final FamiliaEntity entity = familiaRepository.findByCabeca(pessoaEntity.getId());
        if (entity == null)  {
            // Se não achamos uma família para esta cabeça
            // Então ela não deve ser uma cabeça.
            return Optional.empty();
        }

        final Pessoa cabeca = fromEntity(entity.getCabeca());
        final Nome nome = Nome.newNome(entity.getNome(), entity.getSobrenome());
        final Familia familia = Familia.of(cabeca, nome);

        configurarIdentidade(familia, entity.getId());
        return Optional.of(familia);
    }

    @Override
    public void adicionarMembro(final long familiaId, final Email email) {
        final PessoaEntity pessoaEntity = pessoaRepository.findByEmail(email.getEndereco());
        if (pessoaEntity == null) {
            throw new RuntimeException("");
        }

        // Verifica que se a pessoa está na família
        final List<Familia> familias = listarFamilias(email);
        for (Familia f : familias) {
            final Optional<Long> op2 = f.identidade();
            if (op2.get().equals(familiaId)) {
                throw new RuntimeException("");
            }
        }

        familiaRepository.adicionarMembro(familiaId, pessoaEntity.getId());
        familiaRepository.flush();
    }

    @Override
    public void removerMembro(final long familiaId, final Email email) {
        final PessoaEntity pessoaEntity = pessoaRepository.findByEmail(email.getEndereco());
        if (pessoaEntity == null) {
            throw new RuntimeException("");
        }

        // Verifica que se a pessoa está na família
        final List<Familia> familias = listarFamilias(email);
        for (Familia f : familias) {
            final Optional<Long> op2 = f.identidade();
            if (op2.get().equals(familiaId)) {
                throw new RuntimeException("");
            }
        }

        familiaRepository.removerMembro(familiaId, pessoaEntity.getId());
        familiaRepository.flush();
    }
}
