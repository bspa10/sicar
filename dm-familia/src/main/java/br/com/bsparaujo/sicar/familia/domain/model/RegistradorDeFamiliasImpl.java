package br.com.bsparaujo.sicar.familia.domain.model;

import br.com.bsparaujo.sicar.familia.domain.service.RegistradorDeFamilias;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Optional;

public class RegistradorDeFamiliasImpl implements RegistradorDeFamilias {

    private final FamiliaInternalRepository familiaRepository;
    private final PessoaInternalRepository pessoaRepository;

    @Autowired
    public RegistradorDeFamiliasImpl(FamiliaInternalRepository familiaRepository, PessoaInternalRepository pessoaRepository) {
        this.familiaRepository = familiaRepository;
        this.pessoaRepository = pessoaRepository;
    }

    @Override
    public void registar(Familia familia) {
        final Pessoa cabeca = familia.getCabeca();
        final Optional<Pessoa> optional = pessoaRepository.obterPorEmail(cabeca.getEmail());

        // Se a pessoa em questão já existe então é necessário garantir
        // que ela não é cabeça em outra familia.
        if (optional.isPresent()) {
            final Pessoa pessoa = optional.get();
            final Optional<Long> op = pessoa.identidade();

            // Se a pessoa já é cabeça em outra familia então abortamos o processo
            if (op.isPresent()) {
                final Optional<Familia> op2 = familiaRepository.obterPorCabeca(pessoa);
                if (op2.isPresent()) {
                    throw new RuntimeException("");
                }
            }
        } else {
            // Como a pessoa não existe então primeiro criamos ela
            pessoaRepository.salvar(cabeca);

        }

        // Como a pessoa não é cabeça ela pode criar uma família para si
        familiaRepository.salvar(familia);
    }

    public void remover(Familia familia) {
        // Garante que foi passada uma família válida
        final Optional<Long> optional = familia.identidade();
        if (!optional.isPresent()) {
            throw new RuntimeException("");
        }

        // Garante que existe somente o cabeça na familia
        final List<Pessoa> membros = familia.membros();
        if (membros.size() > 1) {
            throw new RuntimeException("");
        }

        membros
                .stream()
                .forEach(membro -> familiaRepository.removerMembro(familia, membro));
    }
}
