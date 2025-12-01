package ma.projet.gestionprofesseurs;

import org.junit.jupiter.api.Test;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(excludeAutoConfiguration = DataSourceAutoConfiguration.class)
@ActiveProfiles("test")
@Import(TestDatabaseConfig.class)
@TestPropertySource(properties = {
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.jpa.show-sql=false",
    "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect"
})
class GestionProfesseursApplicationTests {

    @Test
    void contextLoads() {
    }

}
